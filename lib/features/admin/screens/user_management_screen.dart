import '../../../shared/widgets/profile_avatar.dart';
import '../../../core/utils/store_action.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/premium_app_bar.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final adminRepo = ref.read(adminRepositoryProvider);

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: const PremiumAppBar(title: 'User Management'),
      body: StreamBuilder<List<UserProfile>>(
        stream: ref.watch(adminUsersProvider),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: BookstoreTokens.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Unable to load users: ${snapshot.error}'),
            );
          }
          final users = snapshot.data ?? [];

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            itemCount: users.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BookstoreTokens.surface,
                  borderRadius: BorderRadius.circular(
                    BookstoreTokens.radiusCard,
                  ),
                  border: Border.all(color: BookstoreTokens.border, width: 1),
                ),
                child: Row(
                  children: [
                    ProfileAvatar(url: user.avatarUrl, radius: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.fullName,
                                style: BookstoreTokens.body(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: user.isAdmin
                                      ? BookstoreTokens.primary.withValues(
                                          alpha: 0.15,
                                        )
                                      : BookstoreTokens.surfaceWarm,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  user.role.name.toUpperCase(),
                                  style: BookstoreTokens.body(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: user.isAdmin
                                        ? BookstoreTokens.primaryDark
                                        : BookstoreTokens.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: BookstoreTokens.body(
                              fontSize: 12,
                              color: BookstoreTokens.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tier: ${user.membershipTier}',
                            style: BookstoreTokens.body(
                              fontSize: 11,
                              color: BookstoreTokens.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: user.isAdmin,
                      activeThumbColor: BookstoreTokens.primary,
                      onChanged:
                          user.id ==
                              ref.watch(currentUserStreamProvider).value?.id
                          ? null
                          : (newIsAdmin) async {
                              if (!await storeAction(
                                context,
                                ref,
                                () => adminRepo.updateUserRole(
                                  user.id,
                                  newIsAdmin
                                      ? UserRole.admin
                                      : UserRole.customer,
                                ),
                              )) {
                                return;
                              }
                              setState(() {});
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Updated ${user.fullName} to ${newIsAdmin ? "Admin" : "Customer"}',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
