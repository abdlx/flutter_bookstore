import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/address.dart';
import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_button.dart';

class AddressManagementScreen extends ConsumerWidget {
  const AddressManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressesStreamProvider);
    final addressRepo = ref.read(addressRepositoryProvider);

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: const PremiumAppBar(title: 'Delivery Addresses'),
      body: addressesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: BookstoreTokens.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (addresses) {
          if (addresses.isEmpty) {
            return EmptyState(
              icon: Icons.location_off_outlined,
              title: 'No Addresses Found',
              subtitle:
                  'Add your home or office address for seamless delivery.',
              buttonLabel: '+ Add Address',
              onButtonPressed: () => context.push('/profile/addresses/edit'),
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
                  itemCount: addresses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final addr = addresses[index];
                    return _AddressCard(
                      address: addr,
                      onSetDefault: () =>
                          addressRepo.setDefaultAddress(addr.id),
                      onDelete: () => addressRepo.deleteAddress(addr.id),
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
                  label: '+ Add New Address',
                  onPressed: () => context.push('/profile/addresses/edit'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressItem address;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
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
          color: address.isDefault
              ? BookstoreTokens.primary
              : BookstoreTokens.border,
          width: address.isDefault ? 1.5 : 1,
        ),
        boxShadow: BookstoreTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    address.label.toLowerCase() == 'home'
                        ? Icons.home_outlined
                        : Icons.business_outlined,
                    color: BookstoreTokens.primaryDark,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    address.label,
                    style: BookstoreTokens.body(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: BookstoreTokens.textPrimary,
                    ),
                  ),
                  if (address.isDefault) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
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
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: BookstoreTokens.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: BookstoreTokens.textSecondary,
                  size: 20,
                ),
                onPressed: onDelete,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${address.recipientName} • ${address.phone}',
            style: BookstoreTokens.body(
              fontSize: 13,
              color: BookstoreTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            address.formattedAddress,
            style: BookstoreTokens.body(
              fontSize: 12.5,
              color: BookstoreTokens.textSecondary,
            ),
          ),
          if (!address.isDefault) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onSetDefault,
              child: Text(
                'Set as Default Delivery Address',
                style: BookstoreTokens.body(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: BookstoreTokens.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
