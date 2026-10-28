import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/premium_text_field.dart';

class StoreSettingsScreen extends ConsumerStatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  ConsumerState<StoreSettingsScreen> createState() =>
      _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends ConsumerState<StoreSettingsScreen> {
  final _form = GlobalKey<FormState>();
  final _shipping = TextEditingController();
  final _threshold = TextEditingController();
  final _tax = TextEditingController();
  final _url = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final doc = await ref
          .read(firebaseFirestoreProvider)
          .doc('settings/store')
          .get();
      if (!mounted) return;
      final data = doc.data() ?? {};
      _shipping.text = (data['shippingFee'] as num?)?.toStringAsFixed(2) ?? '';
      _threshold.text =
          (data['freeShippingThreshold'] as num?)?.toStringAsFixed(2) ?? '';
      _tax.text = data['taxRate'] == null
          ? ''
          : ((data['taxRate'] as num) * 100).toString();
      _url.text = data['storefrontUrl'] as String? ?? '';
    } catch (e) {
      _error = 'Unable to load store settings: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _shipping.dispose();
    _threshold.dispose();
    _tax.dispose();
    _url.dispose();
    super.dispose();
  }

  String? _amount(String? text, {double? maximum}) {
    final amount = double.tryParse(text?.trim() ?? '');
    return amount == null ||
            !amount.isFinite ||
            amount < 0 ||
            (maximum != null && amount > maximum)
        ? 'Enter a valid nonnegative amount'
        : null;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(firebaseFirestoreProvider).doc('settings/store').set({
        'shippingFee': double.parse(_shipping.text.trim()),
        'freeShippingThreshold': double.parse(_threshold.text.trim()),
        'taxRate': double.parse(_tax.text.trim()) / 100,
        'storefrontUrl': _url.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Store settings saved')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to save settings: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const PremiumAppBar(title: 'Store Settings'),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(_error!),
            ),
          )
        : Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Shipping & tax',
                  style: BookstoreTokens.display(fontSize: 28),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Set the policies used to calculate customer order totals. Prices are in US dollars.',
                ),
                const SizedBox(height: 24),
                PremiumTextField(
                  controller: _shipping,
                  label: 'Standard Shipping Fee',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _amount,
                ),
                const SizedBox(height: 16),
                PremiumTextField(
                  controller: _threshold,
                  label: 'Free Shipping Subtotal',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _amount,
                ),
                const SizedBox(height: 16),
                PremiumTextField(
                  controller: _tax,
                  label: 'Tax Rate (%)',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) => _amount(v, maximum: 100),
                ),
                const SizedBox(height: 16),
                PremiumTextField(
                  controller: _url,
                  label: 'Public Store URL (optional)',
                  keyboardType: TextInputType.url,
                  hint: 'https://...',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final uri = Uri.tryParse(v.trim());
                    return uri == null ||
                            !['http', 'https'].contains(uri.scheme) ||
                            uri.host.isEmpty
                        ? 'Enter a complete website URL'
                        : null;
                  },
                ),
                const SizedBox(height: 28),
                PremiumButton(
                  label: 'Save Store Settings',
                  onPressed: _save,
                  isLoading: _saving,
                ),
              ],
            ),
          ),
  );
}
