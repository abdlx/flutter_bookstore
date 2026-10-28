import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/payment_method.dart';
import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_button.dart';

class AddEditPaymentScreen extends ConsumerStatefulWidget {
  const AddEditPaymentScreen({super.key});
  @override
  ConsumerState<AddEditPaymentScreen> createState() =>
      _AddEditPaymentScreenState();
}

class _AddEditPaymentScreenState extends ConsumerState<AddEditPaymentScreen> {
  bool _saving = false;
  bool _default = true;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const PremiumAppBar(title: 'Add Payment Method'),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(
          Icons.payments_outlined,
          size: 56,
          color: BookstoreTokens.primary,
        ),
        const SizedBox(height: 24),
        Text('Cash on delivery', style: BookstoreTokens.display(fontSize: 28)),
        const SizedBox(height: 12),
        const Text(
          'Pay when your order arrives. Your order will remain unpaid until delivery.',
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          value: _default,
          onChanged: (v) => setState(() => _default = v),
          title: const Text('Use as default'),
        ),
        const SizedBox(height: 24),
        PremiumButton(
          label: 'Save Payment Method',
          isLoading: _saving,
          onPressed: () async {
            setState(() => _saving = true);
            try {
              await ref
                  .read(paymentMethodRepositoryProvider)
                  .addPaymentMethod(
                    PaymentMethodItem(
                      id: 'cash-on-delivery',
                      type: 'cod',
                      title: 'Cash on delivery',
                      subtitle: 'Pay when your order arrives',
                      isDefault: _default,
                    ),
                  );
              if (context.mounted) Navigator.pop(context);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Unable to save payment method: $e')),
                );
              }
            } finally {
              if (mounted) setState(() => _saving = false);
            }
          },
        ),
      ],
    ),
  );
}
