import '../../../shared/widgets/profile_avatar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/bookstore_tokens.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/premium_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _avatarController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authRepositoryProvider).currentUser;
    _avatarController = TextEditingController(text: profile?.avatarUrl ?? '');
    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      await profileRepo.updateProfile(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarUrl: _avatarController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: BookstoreTokens.success,
          ),
        );
        Navigator.pop(context);
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
      appBar: const PremiumAppBar(title: 'Edit Profile'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ProfileAvatar(
                    url: ref.watch(currentUserStreamProvider).value?.avatarUrl,
                    radius: 45,
                  ),
                ),
                const SizedBox(height: 32),
                PremiumTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: Validators.name,
                ),
                const SizedBox(height: 18),
                PremiumTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 18),
                PremiumTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 18),
                PremiumTextField(
                  controller: _avatarController,
                  label: 'Profile Image URL',
                  hint: 'https://...',
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 32),
                PremiumButton(
                  label: 'Save Changes',
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
