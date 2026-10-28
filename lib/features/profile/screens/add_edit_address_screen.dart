import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/address.dart';
import '../../../core/theme/bookstore_tokens.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/premium_text_field.dart';

class AddEditAddressScreen extends ConsumerStatefulWidget {
  final String? addressId;
  const AddEditAddressScreen({super.key, this.addressId});

  @override
  ConsumerState<AddEditAddressScreen> createState() =>
      _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController(text: 'Home');
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();
  bool _loadingAddress = false;
  String? _loadError;
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.addressId != null) {
      _loadingAddress = true;
      _loadAddress();
    }
  }

  Future<void> _loadAddress() async {
    try {
      final addresses = await ref
          .read(addressRepositoryProvider)
          .getAddresses();
      final address = addresses
          .where((a) => a.id == widget.addressId)
          .firstOrNull;
      if (address == null) throw StateError('Address not found.');
      if (!mounted) return;
      _labelController.text = address.label;
      _nameController.text = address.recipientName;
      _phoneController.text = address.phone;
      _streetController.text = address.street;
      _cityController.text = address.city;
      _stateController.text = address.state;
      _zipController.text = address.postalCode;
      _countryController.text = address.country;
      _isDefault = address.isDefault;
    } catch (e) {
      if (mounted) _loadError = e.toString();
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  @override
  void dispose() {
    _countryController.dispose();
    _labelController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final newAddress = AddressItem(
        id:
            widget.addressId ??
            ref.read(firebaseFirestoreProvider).collection('users').doc().id,
        label: _labelController.text.trim(),
        recipientName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _zipController.text.trim(),
        country: _countryController.text.trim(),
        isDefault: _isDefault,
      );

      await ref.read(addressRepositoryProvider).addAddress(newAddress);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Unable to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: PremiumAppBar(
        title: widget.addressId == null ? 'Add Address' : 'Edit Address',
      ),
      body: _loadingAddress
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(child: Text(_loadError!))
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PremiumTextField(
                        controller: _labelController,
                        label: 'Address Label',
                        hint: 'e.g. Home, Office, Studio',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      PremiumTextField(
                        controller: _nameController,
                        label: 'Recipient Name',
                        hint: 'Full name',
                        validator: Validators.name,
                      ),
                      const SizedBox(height: 14),
                      PremiumTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: '+1 (555) 000-0000',
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Phone number required'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      PremiumTextField(
                        controller: _streetController,
                        label: 'Street Address',
                        hint: 'Street and apartment or suite',
                        validator: (v) => v == null || v.isEmpty
                            ? 'Street address required'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: PremiumTextField(
                              controller: _cityController,
                              label: 'City',
                              hint: 'City',
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: PremiumTextField(
                              controller: _stateController,
                              label: 'State',
                              hint: 'OR',
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: PremiumTextField(
                              controller: _zipController,
                              label: 'Postal Code',
                              hint: '97477',
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      PremiumTextField(
                        controller: _countryController,
                        label: 'Country',
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Country required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Switch(
                            value: _isDefault,
                            activeThumbColor: BookstoreTokens.primary,
                            onChanged: (v) => setState(() => _isDefault = v),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Make this my default shipping address',
                            style: BookstoreTokens.body(
                              fontSize: 13,
                              color: BookstoreTokens.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      PremiumButton(
                        label: 'Save Address',
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
