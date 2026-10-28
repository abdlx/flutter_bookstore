import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/premium_button.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  final String orderId;

  const OrderConfirmationScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailsProvider(orderId));

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Unable to load order: $e')),
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Success Icon
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: BookstoreTokens.surfaceWarm,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: BookstoreTokens.primary,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: BookstoreTokens.primary.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 48,
                            color: BookstoreTokens.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Thank You For Your Order!',
                      textAlign: TextAlign.center,
                      style: BookstoreTokens.display(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: BookstoreTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order #${order.orderNumber} has been received.',
                      textAlign: TextAlign.center,
                      style: BookstoreTokens.body(
                        fontSize: 14,
                        color: BookstoreTokens.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Order Details Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: BookstoreTokens.surface,
                        borderRadius: BorderRadius.circular(
                          BookstoreTokens.radiusCard,
                        ),
                        border: Border.all(
                          color: BookstoreTokens.border,
                          width: 1,
                        ),
                        boxShadow: BookstoreTokens.cardShadow,
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'Order Total',
                            '\$${order.total.toStringAsFixed(2)}',
                            isBold: true,
                          ),
                          const Divider(
                            height: 20,
                            color: BookstoreTokens.divider,
                          ),
                          _buildInfoRow(
                            'Delivery Address',
                            order.shippingAddress.label,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow('Payment', order.paymentMethod.title),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            'Items Purchased',
                            '${order.items.length} titles',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Track Order CTA
                    PremiumButton(
                      label: 'Track Order',
                      leadingIcon: const Icon(
                        Icons.location_searching_rounded,
                        color: BookstoreTokens.white,
                        size: 18,
                      ),
                      onPressed: () {
                        context.go('/orders/$orderId');
                      },
                    ),

                    const SizedBox(height: 14),

                    // Continue Shopping CTA
                    PremiumButton(
                      label: 'Continue Shopping',
                      variant: PremiumButtonVariant.secondary,
                      onPressed: () => context.go('/home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: BookstoreTokens.body(
            fontSize: 13.5,
            color: BookstoreTokens.textSecondary,
          ),
        ),
        Text(
          value,
          style: BookstoreTokens.body(
            fontSize: 13.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: BookstoreTokens.textPrimary,
          ),
        ),
      ],
    );
  }
}
