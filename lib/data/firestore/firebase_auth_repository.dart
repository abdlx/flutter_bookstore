import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/models/user_profile.dart';
import '../contracts/auth_repository.dart';
import 'firestore_codec.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore db;
  final _changes = StreamController<UserProfile?>.broadcast();
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _profileSubscription;
  UserProfile? _current;
  int _generation = 0;
  FirebaseAuthRepository(this.auth, this.db) {
    _authSubscription = auth.userChanges().listen((user) async {
      final generation = ++_generation;
      await _profileSubscription?.cancel();
      if (generation != _generation) return;
      if (user?.uid != _current?.id) {
        _current = null;
        _changes.add(null);
      }
      if (user == null) return;
      _profileSubscription = db
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((doc) {
            if (generation != _generation) return;
            _current = doc.exists ? readProfile(doc.id, doc.data()!) : null;
            _changes.add(_current);
          }, onError: _changes.addError);
    }, onError: _changes.addError);
  }
  @override
  UserProfile? get currentUser => _current;
  @override
  Stream<UserProfile?> get authStateChanges async* {
    yield _current;
    yield* _changes.stream;
  }

  Future<UserProfile> _ensureProfile(User user, {String? fullName}) async {
    final doc = db.collection('users').doc(user.uid);
    final data = await db.runTransaction<Map<String, dynamic>>((tx) async {
      final snapshot = await tx.get(doc);
      if (snapshot.exists) {
        final data = snapshot.data()!;
        if (user.email != null && data['email'] != user.email) {
          tx.update(doc, {'email': user.email});
          return {...data, 'email': user.email};
        }
        return data;
      }
      final profile = <String, dynamic>{
        'fullName': fullName ?? user.displayName ?? '',
        'email': user.email ?? '',
        'role': 'customer',
        'membershipTier': 'Member',
        'memberSince': Timestamp.now(),
        'phone': null,
        'avatarUrl': user.photoURL,
      };
      tx.set(doc, profile);
      return profile;
    });
    _current = readProfile(user.uid, data);
    _changes.add(_current);
    return _current!;
  }

  @override
  Future<UserProfile> login(String email, String password) async {
    final result = await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _ensureProfile(result.user!);
  }

  @override
  Future<UserProfile> register(
    String fullName,
    String email,
    String password,
  ) async {
    final result = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await result.user!.updateDisplayName(fullName.trim());
    return _ensureProfile(result.user!, fullName: fullName.trim());
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      auth.sendPasswordResetEmail(email: email.trim());
  @override
  Future<void> logout() => auth.signOut();
  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _profileSubscription?.cancel();
    await _changes.close();
  }
}
