import '../../core/models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<UserProfile> updateProfile({
    required String fullName,
    required String email,
    String? phone,
    String? avatarUrl,
  });
}
