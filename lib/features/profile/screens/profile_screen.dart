import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/user_profile.dart';
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
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: BookstoreTokens.primaryLight,
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            currentUser?.avatarUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser?.fullName ?? 'Alex Morgan',
                            style: BookstoreTokens.body(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: BookstoreTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentUser?.email ?? 'alex.morgan@aptech.edu',
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
                                  currentUser?.membershipTier ?? 'Gold Member',
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

              // Demo Role Switcher Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: BookstoreTokens.surfaceWarm,
                  borderRadius: BorderRadius.circular(
                    BookstoreTokens.radiusCard,
                  ),
                  border: Border.all(
                    color: BookstoreTokens.primaryLight.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: BookstoreTokens.primaryDark,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demo Role Mode',
                            style: BookstoreTokens.body(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: BookstoreTokens.primaryDark,
                            ),
                          ),
                          Text(
                            'Currently active: ${currentUser?.isAdmin == true ? "Admin" : "Customer"}',
                            style: BookstoreTokens.body(
                              fontSize: 11.5,
                              color: BookstoreTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: currentUser?.isAdmin ?? false,
                      activeThumbColor: BookstoreTokens.primary,
                      onChanged: (isAdmin) {
                        authRepo.switchDemoRole(
                          isAdmin ? UserRole.admin : UserRole.customer,
                        );
                      },
                    ),
                  ],
                ),
              ),

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
                subtitle: 'Credit cards, Apple Pay, and billing options',
                onTap: () => context.push('/profile/payments'),
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Concierge Support',
                subtitle: 'Frequently asked questions and support desk',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Support concierge available 24/7'),
                    ),
                  );
                },
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
