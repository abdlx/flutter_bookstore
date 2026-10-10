import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/order.dart';
import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/order_summary.dart';
import '../../../shared/widgets/premium_app_bar.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderRepo = ref.read(orderRepositoryProvider);

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: const PremiumAppBar(title: 'Order Tracking'),
      body: FutureBuilder<OrderItem?>(
        future: orderRepo.getOrderById(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: BookstoreTokens.primary),
            );
          }

          final order = snapshot.data;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BookstoreTokens.surfaceWarm,
                  borderRadius: BorderRadius.circular(
                    BookstoreTokens.radiusCard,
                  ),
                  border: Border.all(color: BookstoreTokens.border, width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.orderNumber}',
                          style: BookstoreTokens.body(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: BookstoreTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMMM d, yyyy • h:mm a')
                              .format(order.createdAt),
                          style: BookstoreTokens.body(
                            fontSize: 12,
                            color: BookstoreTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      order.statusDisplay,
                      style: BookstoreTokens.body(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: BookstoreTokens.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tracking Timeline
              Text(
                'Delivery Timeline',
                style: BookstoreTokens.body(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: BookstoreTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: BookstoreTokens.surface,
                  borderRadius: BorderRadius.circular(
                    BookstoreTokens.radiusCard,
                  ),
                  border: Border.all(color: BookstoreTokens.border, width: 1),
                ),
                child: Column(
                  children: List.generate(order.trackingSteps.length, (index) {
                    final step = order.trackingSteps[index];
                    final isLast = index == order.trackingSteps.length - 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: step.isCompleted
                                    ? BookstoreTokens.primary
                                    : BookstoreTokens.surfaceWarm,
                                border: Border.all(
                                  color: step.isCompleted
                                      ? BookstoreTokens.primary
                                      : BookstoreTokens.border,
                                  width: 2,
                                ),
                              ),
                              child: step.isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 13,
                                      color: BookstoreTokens.white,
                                    )
                                  : null,
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 38,
                                color: step.isCompleted
                                    ? BookstoreTokens.primary
                                    : BookstoreTokens.divider,
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.title,
                                  style: BookstoreTokens.body(
                                    fontSize: 14,
                                    fontWeight: step.isCompleted
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: step.isCompleted
                                        ? BookstoreTokens.textPrimary
                                        : BookstoreTokens.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  step.description,
                                  style: BookstoreTokens.body(
                                    fontSize: 12,
                                    color: BookstoreTokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),

              const SizedBox(height: 24),

              // Destination Address
              Text(
                'Destination',
                style: BookstoreTokens.body(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: BookstoreTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
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
                    const Icon(
                      Icons.location_on_outlined,
                      color: BookstoreTokens.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${order.shippingAddress.label} • ${order.shippingAddress.recipientName}',
                            style: BookstoreTokens.body(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.shippingAddress.formattedAddress,
                            style: BookstoreTokens.body(
                              fontSize: 12.5,
                              color: BookstoreTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Order Summary
              OrderSummary(
                subtotal: order.subtotal,
                shipping: order.shipping,
                tax: order.tax,
                discount: order.discount,
                total: order.total,
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}
