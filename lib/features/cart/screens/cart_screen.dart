import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/cart_item_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/order_summary.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/shipping_progress_card.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartStreamProvider);
    final cartRepo = ref.read(cartRepositoryProvider);

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: _CircleHeaderBtn(
              icon: Icons.chevron_left_rounded,
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/home');
                }
              },
            ),
          ),
        ),
        title: Text(
          'Your Cart',
          style: BookstoreTokens.body(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: BookstoreTokens.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: _CircleHeaderBtn(
                icon: Icons.more_vert_rounded,
                onTap: () {
                  _showCartMenu(context, cartRepo);
                },
              ),
            ),
          ),
        ],
      ),
      body: cartAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: BookstoreTokens.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your Cart is Empty',
              subtitle: 'Explore our curated library and discover your next great read.',
              buttonLabel: 'Explore Books',
              onButtonPressed: () => context.go('/explore'),
            );
          }

          final subtotal = cartRepo.subtotal;
          final shipping = cartRepo.shippingFee;
          final tax = cartRepo.taxAmount;
          final discount = cartRepo.discountAmount;
          final total = cartRepo.total;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  children: [
                    // Free Shipping Progress Card
                    ShippingProgressCard(
                      currentSubtotal: subtotal,
                      threshold: cartRepo.freeShippingThreshold,
                    ),

                    const SizedBox(height: 18),

                    // Cart Items List
                    ...items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: CartItemCard(
                          item: item,
                          onQuantityChanged: (newQty) {
                            cartRepo.updateQuantity(item.id, newQty);
                          },
                          onRemove: () {
                            cartRepo.removeFromCart(item.id);
                          },
                          onTap: () => context.push('/book/${item.book.id}'),
                        ),
                      );
                    }),

                    const SizedBox(height: 8),

                    // Promo Code Card
                    _PromoCodeCard(
                      onTap: () => _showPromoCodeDialog(context, cartRepo),
                      isApplied: discount > 0,
                    ),

                    const SizedBox(height: 24),

                    // Order Summary Breakdown
                    OrderSummary(
                      subtotal: subtotal,
                      shipping: shipping,
                      tax: tax,
                      discount: discount,
                      total: total,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Bottom Proceed to Checkout CTA
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  16 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 18,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: PremiumButton(
                  label: 'Proceed to Checkout',
                  leadingIcon: const Icon(
                    Icons.lock_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  trailingIcon: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  height: 54,
                  borderRadius: 27,
                  onPressed: () => context.push('/checkout'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCartMenu(BuildContext context, dynamic cartRepo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.delete_sweep_outlined,
                  color: BookstoreTokens.error,
                ),
                title: const Text('Clear Cart'),
                onTap: () {
                  Navigator.pop(ctx);
                  cartRepo.clearCart();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPromoCodeDialog(BuildContext context, dynamic cartRepo) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Apply Promo Code',
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
              'Try "BOOKWORM" for \$5 off your order',
              style: BookstoreTokens.body(
                fontSize: 12.5,
                color: BookstoreTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Enter promo code'),
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
              backgroundColor: const Color(0xFFBA7822),
              minimumSize: const Size(100, 42),
            ),
            onPressed: () async {
              final ok = await cartRepo.applyPromoCode(controller.text);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok ? 'Promo applied successfully!' : 'Invalid promo code',
                    ),
                    backgroundColor: ok
                        ? BookstoreTokens.success
                        : BookstoreTokens.error,
                  ),
                );
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _PromoCodeCard extends StatelessWidget {
  final VoidCallback onTap;
  final bool isApplied;

  const _PromoCodeCard({required this.onTap, required this.isApplied});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_offer_outlined,
              color: isApplied
                  ? BookstoreTokens.success
                  : const Color(0xFF191C24),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isApplied ? 'Promo Applied: \$5 Discount' : 'Add a promo code',
                style: BookstoreTokens.body(
                  fontSize: 14,
                  fontWeight: isApplied ? FontWeight.w600 : FontWeight.normal,
                  color: isApplied
                      ? BookstoreTokens.success
                      : const Color(0xFF191C24),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF8E8E93),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleHeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleHeaderBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, size: 20, color: const Color(0xFF191C24)),
        ),
      ),
    );
  }
}
