import 'dart:async';

import '../../core/models/user_profile.dart';
import '../contracts/auth_repository.dart';
import 'mock_database.dart';

class MockAuthRepository implements AuthRepository {
  final MockDatabase _db = MockDatabase.instance;
  late final StreamController<UserProfile?> _controller;

  MockAuthRepository() {
    _controller = StreamController<UserProfile?>.broadcast();
    // emit current user on creation
    Timer.run(() => _controller.add(_db.currentUser));
  }

  @override
  Stream<UserProfile?> get authStateChanges => _controller.stream;

  @override
  UserProfile? get currentUser => _db.currentUser;

  @override
  Future<UserProfile> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = _db.currentUser.copyWith(email: email);
    _db.currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<UserProfile> register(
    String fullName,
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newUser = UserProfile(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      email: email,
      memberSince: DateTime.now(),
    );
    _db.currentUser = newUser;
    _db.allUsers.add(newUser);
    _controller.add(newUser);
    return newUser;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 250));
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // For demo, switch to a guest state or re-emit
    _controller.add(null);
  }

  @override
  void switchDemoRole(UserRole role) {
    _db.currentUser = _db.currentUser.copyWith(role: role);
    _controller.add(_db.currentUser);
  }
}
