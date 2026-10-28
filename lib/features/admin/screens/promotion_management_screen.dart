import '../../../shared/widgets/owned_text_controllers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/promotion.dart';
import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_text_field.dart';

class PromotionManagementScreen extends ConsumerWidget {
  const PromotionManagementScreen({super.key});
  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    Promotion? promotion,
  ]) async {
    final form = GlobalKey<FormState>();
    final code = TextEditingController(text: promotion?.code);
    final amount = TextEditingController(text: promotion?.amount.toString());
    final minimum = TextEditingController(
      text: promotion?.minimumSubtotal.toString() ?? '0',
    );
    final expiry = TextEditingController(
      text: promotion?.expiresAt?.toLocal().toIso8601String() ?? '',
    );
    var type = promotion?.type ?? 'percent';
    var active = promotion?.active ?? true;
    var saving = false;
    String? error;
    String? money(String? v, {bool positive = false, double? max}) {
      final n = double.tryParse(v?.trim() ?? '');
      return n == null ||
              !n.isFinite ||
              n < 0 ||
              (positive && n == 0) ||
              (max != null && n > max)
          ? 'Enter a valid amount'
          : null;
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => OwnedTextControllers(
        controllers: [code, amount, minimum, expiry],
        child: StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text(
              promotion == null ? 'Create Promotion' : 'Edit ${promotion.code}',
            ),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Form(
                  key: form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PremiumTextField(
                        controller: code,
                        label: 'Promotion Code',
                        readOnly: promotion != null,
                        validator: (v) =>
                            RegExp(r'^[A-Z0-9_-]{2,40}$')
                                .hasMatch(v?.trim().toUpperCase() ?? '')
                            ? null
                            : 'Use 2–40 letters, numbers, _ or -',
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: type,
                        decoration: const InputDecoration(
                          labelText: 'Discount Type',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'percent',
                            child: Text('Percentage'),
                          ),
                          DropdownMenuItem(
                            value: 'fixed',
                            child: Text('Fixed amount (USD)'),
                          ),
                        ],
                        onChanged: saving
                            ? null
                            : (value) => setDialogState(() => type = value!),
                      ),
                      const SizedBox(height: 16),
                      PremiumTextField(
                        controller: amount,
                        label: type == 'percent'
                            ? 'Discount (%)'
                            : 'Discount (USD)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) => money(
                          v,
                          positive: true,
                          max: type == 'percent' ? 100 : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      PremiumTextField(
                        controller: minimum,
                        label: 'Minimum Item Subtotal (USD)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: money,
                      ),
                      const SizedBox(height: 16),
                      PremiumTextField(
                        controller: expiry,
                        label: 'Expiry (optional, local date/time)',
                        hint: 'YYYY-MM-DDTHH:MM',
                        validator: (v) =>
                            v == null ||
                                v.trim().isEmpty ||
                                DateTime.tryParse(v.trim()) != null
                            ? null
                            : 'Enter a valid ISO date/time',
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active'),
                        value: active,
                        onChanged: saving
                            ? null
                            : (v) => setDialogState(() => active = v),
                      ),
                      if (error != null)
                        Text(
                          error!,
                          style: const TextStyle(color: BookstoreTokens.error),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (!form.currentState!.validate()) return;
                        setDialogState(() {
                          saving = true;
                          error = null;
                        });
                        try {
                          await ref
                              .read(promotionRepositoryProvider)
                              .save(
                                Promotion(
                                  code: code.text.trim().toUpperCase(),
                                  active: active,
                                  type: type,
                                  amount: double.parse(amount.text.trim()),
                                  minimumSubtotal: double.parse(
                                    minimum.text.trim(),
                                  ),
                                  expiresAt: expiry.text.trim().isEmpty
                                      ? null
                                      : DateTime.parse(expiry.text.trim()),
                                ),
                                creating: promotion == null,
                              );
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          if (ctx.mounted) {
                            setDialogState(
                              () => error = 'Unable to save promotion: $e',
                            );
                          }
                        } finally {
                          if (ctx.mounted) setDialogState(() => saving = false);
                        }
                      },
                child: Text(saving ? 'Saving…' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Promotion promotion,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${promotion.code}?'),
        content: const Text(
          'Existing order receipts will keep their recorded discounts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(promotionRepositoryProvider).delete(promotion.code);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to delete promotion: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: const PremiumAppBar(title: 'Promotions'),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _edit(context, ref),
      icon: const Icon(Icons.add),
      label: const Text('Create Promotion'),
    ),
    body: ref
        .watch(promotionsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Unable to load promotions: $e')),
          data: (promotions) => promotions.isEmpty
              ? EmptyState(
                  icon: Icons.local_offer_outlined,
                  title: 'No Promotions',
                  subtitle: 'Create discount codes for your catalog.',
                  buttonLabel: 'Create Promotion',
                  onButtonPressed: () => _edit(context, ref),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  itemCount: promotions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final p = promotions[index];
                    return Card(
                      child: ListTile(
                        title: Text(p.code),
                        subtitle: Text(
                          '${p.type == 'percent' ? '${p.amount}%' : '\$${p.amount.toStringAsFixed(2)}'} off · ${p.expired
                              ? 'Expired'
                              : p.active
                              ? 'Active'
                              : 'Inactive'}\nMinimum \$${p.minimumSubtotal.toStringAsFixed(2)}${p.expiresAt == null ? '' : ' · Ends ${DateFormat.yMMMd().add_Hm().format(p.expiresAt!.toLocal())}'}',
                        ),
                        onTap: () => _edit(context, ref, p),
                        trailing: IconButton(
                          tooltip: 'Delete promotion',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(context, ref, p),
                        ),
                      ),
                    );
                  },
                ),
        ),
  );
}
