import '../../core/models/user_profile.dart';
import '../contracts/profile_repository.dart';
import 'mock_database.dart';

class MockProfileRepository implements ProfileRepository {
  final MockDatabase _db = MockDatabase.instance;

  @override
  Future<UserProfile> getProfile() async {
    return _db.currentUser;
  }

  @override
  Future<UserProfile> updateProfile({
    required String fullName,
    required String email,
    String? phone,
    String? avatarUrl,
  }) async {
    _db.currentUser = _db.currentUser.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
    );
    return _db.currentUser;
  }
}
