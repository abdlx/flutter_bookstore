import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../contracts/profile_repository.dart';
import '../../core/models/user_profile.dart';

class FirebaseProfileRepository implements ProfileRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> get _userDoc {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('User not authenticated');
    }
    return _db.collection('users').doc(uid);
  }

  @override
  Future<UserProfile> getProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User not authenticated');

    final doc = await _db.collection('users').doc(uid).get();
    final user = _auth.currentUser!;
    final data = doc.data();

    return UserProfile(
      id: uid,
      fullName: data?['name'] as String? ?? user.displayName ?? 'User',
      email: data?['email'] as String? ?? user.email ?? '',
      phone: data?['phone'] as String?,
      avatarUrl: user.photoURL,
      role: _parseRole(data?['role'] as String?),
      membershipTier: data?['membershipTier'] as String? ?? 'Gold Member',
      memberSince: (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  Future<UserProfile> updateProfile({
    required String fullName,
    required String email,
    String? phone,
    String? avatarUrl,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User not authenticated');

    final updates = <String, dynamic>{
      'name': fullName,
      'email': email,
    };
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;

    await _userDoc.set(updates, SetOptions(merge: true));
    await _auth.currentUser!.updateDisplayName(fullName);
    if (avatarUrl != null) {
      await _auth.currentUser!.updatePhotoURL(avatarUrl);
    }

    return getProfile();
  }

  UserRole _parseRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }
}