import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../contracts/auth_repository.dart';
import '../../core/models/user_profile.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserRole? _demoRoleOverride;

  @override
  Stream<UserProfile?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user == null) return null;
      return _buildUserProfile(user);
    });
  }

  @override
  UserProfile? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _buildUserProfileSync(user);
  }

  Future<UserProfile> _buildUserProfile(User user) async {
    final doc = await _db.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data == null) {
      return UserProfile(
        id: user.uid,
        fullName: user.displayName ?? 'User',
        email: user.email ?? '',
        phone: data?['phone'] as String?,
        avatarUrl: user.photoURL,
        role: _demoRoleOverride ?? _parseRole(data?['role'] as String?),
        membershipTier: data?['membershipTier'] as String? ?? 'Gold Member',
        memberSince: (data?['createdAt'] as Timestamp?)?.toDate() ??
            DateTime.now(),
      );
    }
    return UserProfile(
      id: user.uid,
      fullName: data['name'] as String? ?? user.displayName ?? 'User',
      email: data['email'] as String? ?? user.email ?? '',
      phone: data['phone'] as String?,
      avatarUrl: user.photoURL,
      role: _demoRoleOverride ?? _parseRole(data['role'] as String?),
      membershipTier: data['membershipTier'] as String? ?? 'Gold Member',
      memberSince: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  UserProfile? _buildUserProfileSync(User user) {
    // Synchronous version for currentUser getter - uses cached data if available
    // In practice, we'd need to fetch from Firestore, but for sync getter we return a basic profile
    return UserProfile(
      id: user.uid,
      fullName: user.displayName ?? 'User',
      email: user.email ?? '',
      avatarUrl: user.photoURL,
      role: _demoRoleOverride ?? UserRole.customer,
      membershipTier: 'Gold Member',
      memberSince: DateTime.now(),
    );
  }

  UserRole _parseRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }

  @override
  Future<UserProfile> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _buildUserProfile(cred.user!);
  }

  @override
  Future<UserProfile> register(String fullName, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user!.updateDisplayName(fullName.trim());
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': fullName.trim(),
      'email': email.trim(),
      'role': 'user',
      'membershipTier': 'Gold Member',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return _buildUserProfile(cred.user!);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  void switchDemoRole(UserRole role) {
    _demoRoleOverride = role;
    final user = _auth.currentUser;
    if (user != null) {
      // Trigger a rebuild by re-emitting (in practice this would be handled by the stream)
      // The authStateChanges stream will pick up the role change on next auth event
    }
  }
}