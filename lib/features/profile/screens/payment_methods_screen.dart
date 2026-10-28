import '../../../core/utils/store_action.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/payment_method.dart';
import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_button.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentMethodsAsync = ref.watch(paymentMethodsStreamProvider);
    final paymentRepo = ref.read(paymentMethodRepositoryProvider);

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: const PremiumAppBar(title: 'Payment Methods'),
      body: paymentMethodsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: BookstoreTokens.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (methods) {
          if (methods.isEmpty) {
            return EmptyState(
              icon: Icons.credit_card_off_outlined,
              title: 'No Payment Methods',
              subtitle: 'Save cash on delivery for a faster checkout.',
              buttonLabel: '+ Add Payment Method',
              onButtonPressed: () => context.push('/profile/payments/edit'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  itemCount: methods.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final pm = methods[index];
                    return _PaymentMethodCard(
                      payment: pm,
                      onSetDefault: () => storeAction(
                        context,
                        ref,
                        () => paymentRepo.setDefaultPaymentMethod(pm.id),
                      ),
                      onDelete: () => storeAction(
                        context,
                        ref,
                        () => paymentRepo.deletePaymentMethod(pm.id),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  16 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: const BoxDecoration(
                  color: BookstoreTokens.surface,
                  border: Border(
                    top: BorderSide(color: BookstoreTokens.divider, width: 1),
                  ),
                ),
                child: PremiumButton(
                  label: '+ Add Payment Method',
                  onPressed: () => context.push('/profile/payments/edit'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethodItem payment;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _PaymentMethodCard({
    required this.payment,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BookstoreTokens.surface,
        borderRadius: BorderRadius.circular(BookstoreTokens.radiusCard),
        border: Border.all(
          color: payment.isDefault
              ? BookstoreTokens.primary
              : BookstoreTokens.border,
          width: payment.isDefault ? 1.5 : 1,
        ),
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
              child: Icon(
                payment.type == 'card'
                    ? Icons.credit_card_rounded
                    : payment.type == 'apple_pay'
                    ? Icons.phone_iphone_rounded
                    : Icons.payments_outlined,
                color: BookstoreTokens.primaryDark,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      payment.title,
                      style: BookstoreTokens.body(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (payment.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: BookstoreTokens.surfaceWarm,
                          borderRadius: BorderRadius.circular(
                            BookstoreTokens.radiusPill,
                          ),
                        ),
                        child: Text(
                          'Default',
                          style: BookstoreTokens.body(
                            fontSize: 10,
                            color: BookstoreTokens.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  payment.subtitle,
                  style: BookstoreTokens.body(
                    fontSize: 12,
                    color: BookstoreTokens.textSecondary,
                  ),
                ),
                if (!payment.isDefault) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onSetDefault,
                    child: Text(
                      'Set as default payment',
                      style: BookstoreTokens.body(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: BookstoreTokens.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: BookstoreTokens.textSecondary,
              size: 20,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
