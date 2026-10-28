enum UserRole { customer, admin }

class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final UserRole role;
  final String membershipTier;
  final DateTime memberSince;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.role = UserRole.customer,
    this.membershipTier = 'Member',
    required this.memberSince,
  });

  bool get isAdmin => role == UserRole.admin;

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    String? membershipTier,
    DateTime? memberSince,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      membershipTier: membershipTier ?? this.membershipTier,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}
