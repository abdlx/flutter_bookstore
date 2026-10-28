import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/order.dart';
import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/premium_app_bar.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: const PremiumAppBar(title: 'My Orders'),
      body: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: BookstoreTokens.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (orders) {
          if (orders.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No Orders Yet',
              subtitle: 'You have not placed any orders yet. Discover our catalog today!',
              buttonLabel: 'Explore Books',
              onButtonPressed: () => context.go('/explore'),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderCard(
                order: order,
                onTap: () => context.push('/orders/${order.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderItem order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  Color _getStatusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.delivered:
        return BookstoreTokens.success;
      case OrderStatus.shipped:
        return BookstoreTokens.primary;
      case OrderStatus.processing:
      case OrderStatus.confirmed:
        return const Color(0xFF2E75B6);
      case OrderStatus.cancelled:
        return BookstoreTokens.error;
      case OrderStatus.placed:
        return BookstoreTokens.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final dateFormatted = DateFormat('MMM d, yyyy').format(order.createdAt);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: BookstoreTokens.body(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: BookstoreTokens.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      BookstoreTokens.radiusPill,
                    ),
                  ),
                  child: Text(
                    order.statusDisplay,
                    style: BookstoreTokens.body(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Placed on $dateFormatted',
              style: BookstoreTokens.body(
                fontSize: 12,
                color: BookstoreTokens.textMuted,
              ),
            ),
            const Divider(height: 20, color: BookstoreTokens.divider),
            Text(
              order.items
                  .map((i) => '${i.quantity}x ${i.book.title}')
                  .join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: BookstoreTokens.body(
                fontSize: 13,
                color: BookstoreTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: BookstoreTokens.body(
                      fontSize: 13,
                      color: BookstoreTokens.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'Total: '),
                      TextSpan(
                        text: '\$${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: BookstoreTokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Details',
                      style: BookstoreTokens.body(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: BookstoreTokens.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: BookstoreTokens.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
