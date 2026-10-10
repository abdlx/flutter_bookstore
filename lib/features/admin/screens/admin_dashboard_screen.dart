import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/bookstore_tokens.dart';
import '../../../data/contracts/admin_repository.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/premium_app_bar.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminRepo = ref.read(adminRepositoryProvider);

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: const PremiumAppBar(title: 'Admin Management'),
      body: FutureBuilder<AdminDashboardStats>(
        future: adminRepo.getDashboardStats(),
        builder: (context, snapshot) {
          final stats =
              snapshot.data ??
              const AdminDashboardStats(
                totalRevenue: 12450.0,
                totalOrders: 144,
                totalBooks: 21,
                totalUsers: 323,
              );

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            children: [
              // Notice banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF2E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: BookstoreTokens.primary,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.security_rounded,
                      size: 20,
                      color: BookstoreTokens.primaryDark,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Demo Mode: Simulated admin operations. Real authorization is managed by backend services.',
                        style: BookstoreTokens.body(
                          fontSize: 12,
                          color: BookstoreTokens.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Store Performance',
                style: BookstoreTokens.body(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // 2x2 Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _StatCard(
                    title: 'Total Revenue',
                    value: '\$${stats.totalRevenue.toStringAsFixed(0)}',
                    subtext: '+${stats.growthRate}% this month',
                    icon: Icons.payments_outlined,
                  ),
                  _StatCard(
                    title: 'Orders',
                    value: stats.totalOrders.toString(),
                    subtext: 'Fulfillment queue',
                    icon: Icons.shopping_bag_outlined,
                  ),
                  _StatCard(
                    title: 'Catalog Titles',
                    value: stats.totalBooks.toString(),
                    subtext: 'Active volumes',
                    icon: Icons.menu_book_outlined,
                  ),
                  _StatCard(
                    title: 'Total Readers',
                    value: stats.totalUsers.toString(),
                    subtext: 'Registered members',
                    icon: Icons.people_outline_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Text(
                'Management Modules',
                style: BookstoreTokens.body(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _AdminModuleCard(
                title: 'Catalog & Inventory',
                description: 'Add new volumes, edit prices, descriptions, and restock counts',
                icon: Icons.inventory_2_outlined,
                onTap: () => context.push('/admin/books'),
              ),
              const SizedBox(height: 12),
              _AdminModuleCard(
                title: 'Order Fulfillment',
                description: 'Review placed customer orders and update shipping transit status',
                icon: Icons.local_shipping_outlined,
                onTap: () => context.push('/admin/orders'),
              ),
              const SizedBox(height: 12),
              _AdminModuleCard(
                title: 'User Management',
                description: 'View members, membership tiers, and toggle administrative privileges',
                icon: Icons.manage_accounts_outlined,
                onTap: () => context.push('/admin/users'),
              ),

              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtext,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BookstoreTokens.surface,
        borderRadius: BorderRadius.circular(BookstoreTokens.radiusCard),
        border: Border.all(color: BookstoreTokens.border, width: 1),
        boxShadow: BookstoreTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: BookstoreTokens.body(
                  fontSize: 12,
                  color: BookstoreTokens.textSecondary,
                ),
              ),
              Icon(icon, size: 18, color: BookstoreTokens.primary),
            ],
          ),
          Text(
            value,
            style: BookstoreTokens.body(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: BookstoreTokens.textPrimary,
            ),
          ),
          Text(
            subtext,
            style: BookstoreTokens.body(
              fontSize: 10.5,
              color: BookstoreTokens.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _AdminModuleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BookstoreTokens.surface,
          borderRadius: BorderRadius.circular(BookstoreTokens.radiusCard),
          border: Border.all(color: BookstoreTokens.border, width: 1),
          boxShadow: BookstoreTokens.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: BookstoreTokens.surfaceWarm,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: BookstoreTokens.primary, size: 22),
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
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: BookstoreTokens.body(
                      fontSize: 12,
                      color: BookstoreTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: BookstoreTokens.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
