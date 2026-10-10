import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/payment_method.dart';
import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/premium_text_field.dart';

class AddEditPaymentScreen extends ConsumerStatefulWidget {
  const AddEditPaymentScreen({super.key});

  @override
  ConsumerState<AddEditPaymentScreen> createState() =>
      _AddEditPaymentScreenState();
}

class _AddEditPaymentScreenState extends ConsumerState<AddEditPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final last4 = _cardNumberController.text.trim().replaceAll(' ', '');
      final cleanLast4 = last4.length >= 4
          ? last4.substring(last4.length - 4)
          : '1234';

      final newPayment = PaymentMethodItem(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        type: 'card',
        title: 'Visa Debit Card',
        subtitle: 'Ending in $cleanLast4',
        last4: cleanLast4,
        brand: 'Visa',
        expiry: _expiryController.text.trim(),
        isDefault: _isDefault,
      );

      await ref
          .read(paymentMethodRepositoryProvider)
          .addPaymentMethod(newPayment);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment card added successfully')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: const PremiumAppBar(title: 'Add Payment Card'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PremiumTextField(
                  controller: _cardHolderController,
                  label: 'Cardholder Name',
                  hint: 'Name as printed on card',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                PremiumTextField(
                  controller: _cardNumberController,
                  label: 'Card Number',
                  hint: '•••• •••• •••• 4242',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.credit_card_rounded,
                  validator: (v) => v == null || v.length < 12
                      ? 'Valid card number required'
                      : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: PremiumTextField(
                        controller: _expiryController,
                        label: 'Expires (MM/YY)',
                        hint: '12/28',
                        keyboardType: TextInputType.datetime,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PremiumTextField(
                        controller: _cvvController,
                        label: 'CVV Security Code',
                        hint: '•••',
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        validator: (v) =>
                            v == null || v.length < 3 ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Switch(
                      value: _isDefault,
                      activeThumbColor: BookstoreTokens.primary,
                      onChanged: (v) => setState(() => _isDefault = v),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Use as default payment method',
                      style: BookstoreTokens.body(
                        fontSize: 13,
                        color: BookstoreTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                PremiumButton(
                  label: 'Save Card',
                  isLoading: _isLoading,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
