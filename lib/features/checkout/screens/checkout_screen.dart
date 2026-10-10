import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/order_summary.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_button.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _selectedAddressId;
  String? _selectedPaymentId;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final cartRepo = ref.read(cartRepositoryProvider);
    final addressesAsync = ref.watch(addressesStreamProvider);
    final paymentMethodsAsync = ref.watch(paymentMethodsStreamProvider);
    final cartItems = cartRepo.getCartItems();

    if (cartItems.isEmpty) {
      return Scaffold(
        backgroundColor: BookstoreTokens.background,
        appBar: const PremiumAppBar(title: 'Checkout'),
        body: Center(
          child: Text(
            'Your cart is empty',
            style: BookstoreTokens.body(color: BookstoreTokens.textSecondary),
          ),
        ),
      );
    }

    final subtotal = cartRepo.subtotal;
    final shipping = cartRepo.shippingFee;
    final tax = cartRepo.taxAmount;
    final discount = cartRepo.discountAmount;
    final total = cartRepo.total;

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: const PremiumAppBar(title: 'Checkout'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Shipping Address Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shipping Address',
                  style: BookstoreTokens.body(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: BookstoreTokens.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/profile/addresses'),
                  child: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            addressesAsync.when(
              loading: () => const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Error loading addresses: $e'),
              data: (addresses) {
                if (addresses.isEmpty) {
                  return TextButton(
                    onPressed: () => context.push('/profile/addresses/edit'),
                    child: const Text('+ Add Delivery Address'),
                  );
                }

                _selectedAddressId ??= addresses
                    .firstWhere(
                      (a) => a.isDefault,
                      orElse: () => addresses.first,
                    )
                    .id;

                return Column(
                  children: addresses.map((addr) {
                    final isSel = addr.id == _selectedAddressId;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAddressId = addr.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: BookstoreTokens.surface,
                          borderRadius: BorderRadius.circular(
                            BookstoreTokens.radiusCard,
                          ),
                          border: Border.all(
                            color: isSel
                                ? BookstoreTokens.primary
                                : BookstoreTokens.border,
                            width: isSel ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isSel
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSel
                                  ? BookstoreTokens.primary
                                  : BookstoreTokens.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        addr.label,
                                        style: BookstoreTokens.body(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (addr.isDefault) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: BookstoreTokens.surfaceWarm,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            'Default',
                                            style: BookstoreTokens.body(
                                              fontSize: 10,
                                              color:
                                                  BookstoreTokens.primaryDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${addr.recipientName} • ${addr.phone}',
                                    style: BookstoreTokens.body(
                                      fontSize: 12.5,
                                      color: BookstoreTokens.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    addr.formattedAddress,
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
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            // 2. Payment Method Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Method',
                  style: BookstoreTokens.body(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: BookstoreTokens.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/profile/payments'),
                  child: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            paymentMethodsAsync.when(
              loading: () => const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Error loading payments: $e'),
              data: (payments) {
                if (payments.isEmpty) {
                  return TextButton(
                    onPressed: () => context.push('/profile/payments/edit'),
                    child: const Text('+ Add Payment Method'),
                  );
                }

                _selectedPaymentId ??= payments
                    .firstWhere(
                      (p) => p.isDefault,
                      orElse: () => payments.first,
                    )
                    .id;

                return Column(
                  children: payments.map((pm) {
                    final isSel = pm.id == _selectedPaymentId;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPaymentId = pm.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: BookstoreTokens.surface,
                          borderRadius: BorderRadius.circular(
                            BookstoreTokens.radiusCard,
                          ),
                          border: Border.all(
                            color: isSel
                                ? BookstoreTokens.primary
                                : BookstoreTokens.border,
                            width: isSel ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSel
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSel
                                  ? BookstoreTokens.primary
                                  : BookstoreTokens.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              pm.type == 'card'
                                  ? Icons.credit_card_rounded
                                  : pm.type == 'apple_pay'
                                  ? Icons.phone_iphone_rounded
                                  : Icons.payments_outlined,
                              color: BookstoreTokens.textPrimary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pm.title,
                                    style: BookstoreTokens.body(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    pm.subtitle,
                                    style: BookstoreTokens.body(
                                      fontSize: 12,
                                      color: BookstoreTokens.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            // 3. Order Items Summary
            Text(
              'Order Items (${cartItems.length})',
              style: BookstoreTokens.body(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: BookstoreTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: BookstoreTokens.surface,
                borderRadius: BorderRadius.circular(BookstoreTokens.radiusCard),
                border: Border.all(color: BookstoreTokens.border, width: 1),
              ),
              child: Column(
                children: cartItems.map((ci) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${ci.quantity}x ${ci.book.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: BookstoreTokens.body(fontSize: 13.5),
                          ),
                        ),
                        Text(
                          '\$${ci.totalPrice.toStringAsFixed(0)}',
                          style: BookstoreTokens.body(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // 4. Cost Breakdown
            OrderSummary(
              subtotal: subtotal,
              shipping: shipping,
              tax: tax,
              discount: discount,
              total: total,
            ),

            const SizedBox(height: 28),

            // 5. Place Order Button
            PremiumButton(
              label: 'Place Order • \$${total.toStringAsFixed(0)}',
              leadingIcon: const Icon(
                Icons.check_circle_outline,
                color: BookstoreTokens.white,
                size: 20,
              ),
              isLoading: _isProcessing,
              onPressed: () async {
                setState(() => _isProcessing = true);
                final addresses = await ref
                    .read(addressRepositoryProvider)
                    .getAddresses();
                final payments = await ref
                    .read(paymentMethodRepositoryProvider)
                    .getPaymentMethods();

                final selectedAddress = addresses.firstWhere(
                  (a) => a.id == _selectedAddressId,
                  orElse: () => addresses.first,
                );
                final selectedPayment = payments.firstWhere(
                  (p) => p.id == _selectedPaymentId,
                  orElse: () => payments.first,
                );

                final order = await ref
                    .read(orderRepositoryProvider)
                    .createOrder(
                      items: cartItems,
                      shippingAddress: selectedAddress,
                      paymentMethod: selectedPayment,
                      subtotal: subtotal,
                      shipping: shipping,
                      tax: tax,
                      discount: discount,
                      total: total,
                    );

                await cartRepo.clearCart();

                if (!context.mounted) return;
                setState(() => _isProcessing = false);
                context.go('/order-confirmation/${order.id}');
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
