import '../../../core/utils/store_action.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/order.dart';
import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/premium_app_bar.dart';

class OrderManagementScreen extends ConsumerStatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  ConsumerState<OrderManagementScreen> createState() =>
      _OrderManagementScreenState();
}

class _OrderManagementScreenState extends ConsumerState<OrderManagementScreen> {
  void _showStatusDialog(BuildContext context, OrderItem order) {
    OrderStatus selected = order.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: BookstoreTokens.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Update Order Status',
            style: BookstoreTokens.body(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${order.orderNumber}',
                style: BookstoreTokens.body(
                  fontSize: 13,
                  color: BookstoreTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<OrderStatus>(
                initialValue: selected,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                items: [order.status, ...order.status.nextStatuses].map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text(s.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selected = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: BookstoreTokens.primary,
                minimumSize: const Size(100, 40),
              ),
              onPressed: () async {
                if (!await storeAction(
                  context,
                  ref,
                  () => ref
                      .read(adminRepositoryProvider)
                      .updateOrderStatus(order.id, selected),
                )) {
                  return;
                }
                ref.invalidate(adminOrdersStreamProvider);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order status updated')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersStreamProvider);

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: const PremiumAppBar(title: 'Order Fulfillment'),
      body: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: BookstoreTokens.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_outlined,
              title: 'No Orders',
              subtitle: 'No customer orders have been placed yet.',
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BookstoreTokens.surface,
                  borderRadius: BorderRadius.circular(
                    BookstoreTokens.radiusCard,
                  ),
                  border: Border.all(color: BookstoreTokens.border, width: 1),
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
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: BookstoreTokens.surfaceWarm,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            order.statusDisplay,
                            style: BookstoreTokens.body(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: BookstoreTokens.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Customer: ${order.shippingAddress.recipientName} • ${DateFormat('MMM d').format(order.createdAt)}',
                      style: BookstoreTokens.body(
                        fontSize: 12.5,
                        color: BookstoreTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Items: ${order.items.map((i) => '${i.quantity}x ${i.book.title}').join(', ')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BookstoreTokens.body(
                        fontSize: 12,
                        color: BookstoreTokens.textMuted,
                      ),
                    ),
                    const Divider(height: 20, color: BookstoreTokens.divider),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: \$${order.total.toStringAsFixed(2)}',
                          style: BookstoreTokens.body(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(120, 36),
                            side: const BorderSide(
                              color: BookstoreTokens.primary,
                              width: 1,
                            ),
                          ),
                          icon: const Icon(Icons.edit_note_rounded, size: 16),
                          label: const Text(
                            'Update Status',
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () => _showStatusDialog(context, order),
                        ),
                      ],
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
