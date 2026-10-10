import '../../core/models/user_profile.dart';

abstract class AuthRepository {
  Stream<UserProfile?> get authStateChanges;
  UserProfile? get currentUser;
  Future<UserProfile> login(String email, String password);
  Future<UserProfile> register(String fullName, String email, String password);
  Future<void> sendPasswordReset(String email);
  Future<void> logout();
  void switchDemoRole(UserRole role);
}
