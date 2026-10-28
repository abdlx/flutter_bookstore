import '../../../shared/widgets/profile_avatar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/confirmation_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserStreamProvider);
    final authRepo = ref.read(authRepositoryProvider);

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Profile',
          style: BookstoreTokens.body(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: BookstoreTokens.textPrimary,
          ),
        ),
      ),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: BookstoreTokens.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          final currentUser = user ?? authRepo.currentUser;

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            children: [
              // User Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: BookstoreTokens.surface,
                  borderRadius: BorderRadius.circular(
                    BookstoreTokens.radiusCard,
                  ),
                  border: Border.all(color: BookstoreTokens.border, width: 1),
                  boxShadow: BookstoreTokens.cardShadow,
                ),
                child: Row(
                  children: [
                    ProfileAvatar(url: currentUser?.avatarUrl, radius: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser?.fullName ?? 'Reader',
                            style: BookstoreTokens.body(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: BookstoreTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentUser?.email ?? '',
                            style: BookstoreTokens.body(
                              fontSize: 12.5,
                              color: BookstoreTokens.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: BookstoreTokens.surfaceWarm,
                              borderRadius: BorderRadius.circular(
                                BookstoreTokens.radiusPill,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: BookstoreTokens.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  currentUser?.membershipTier ?? 'Member',
                                  style: BookstoreTokens.body(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: BookstoreTokens.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (currentUser?.isAdmin == true) ...[
                const SizedBox(height: 14),
                _MenuTile(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Admin Management Dashboard',
                  subtitle: 'Manage catalog inventory, orders, and users',
                  isAccent: true,
                  onTap: () => context.push('/admin'),
                ),
              ],

              const SizedBox(height: 16),

              // Menu Items
              _MenuTile(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profile',
                subtitle: 'Personal details and credentials',
                onTap: () => context.push('/profile/edit'),
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.receipt_long_outlined,
                title: 'My Orders',
                subtitle: 'Track order packages and review history',
                onTap: () => context.push('/orders'),
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.location_on_outlined,
                title: 'Shipping Addresses',
                subtitle: 'Manage your home & office delivery points',
                onTap: () => context.push('/profile/addresses'),
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.credit_card_outlined,
                title: 'Payment Methods',
                subtitle: 'Manage cash on delivery',
                onTap: () => context.push('/profile/payments'),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 20),

              _MenuTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Read the project terms',
                onTap: () => context.push('/policies/terms'),
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'How your information is used',
                onTap: () => context.push('/policies/privacy'),
              ),
              const SizedBox(height: 20),
              // Logout Button
              _MenuTile(
                icon: Icons.logout_rounded,
                title: 'Log Out',
                subtitle: 'Sign out of this session',
                isDestructive: true,
                onTap: () async {
                  final confirmed = await ConfirmationDialog.show(
                    context: context,
                    title: 'Sign Out?',
                    message:
                        'Are you sure you want to end your current session?',
                    confirmLabel: 'Log Out',
                    isDestructive: true,
                  );
                  if (confirmed == true) {
                    await authRepo.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isAccent;
  final bool isDestructive;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isAccent = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAccent
              ? BookstoreTokens.surfaceWarm
              : BookstoreTokens.surface,
          borderRadius: BorderRadius.circular(BookstoreTokens.radiusCard),
          border: Border.all(
            color: isAccent ? BookstoreTokens.primary : BookstoreTokens.border,
            width: 1,
          ),
          boxShadow: BookstoreTokens.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? BookstoreTokens.error.withValues(alpha: 0.08)
                    : isAccent
                    ? BookstoreTokens.primary.withValues(alpha: 0.15)
                    : BookstoreTokens.surfaceWarm,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: isDestructive
                      ? BookstoreTokens.error
                      : isAccent
                      ? BookstoreTokens.primaryDark
                      : BookstoreTokens.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: BookstoreTokens.body(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: isDestructive
                          ? BookstoreTokens.error
                          : BookstoreTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: BookstoreTokens.body(
                      fontSize: 11.5,
                      color: BookstoreTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDestructive
                  ? BookstoreTokens.error
                  : BookstoreTokens.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
