import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/bookstore_tokens.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/premium_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.sendPasswordReset(_emailController.text);
      if (mounted) {
        setState(() => _isSent = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: BookstoreTokens.error,
          ),
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
      appBar: const PremiumAppBar(title: 'Reset Password'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: _isSent ? _buildSuccessView() : _buildFormView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 72,
            height: 72,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: BookstoreTokens.surfaceWarm,
              shape: BoxShape.circle,
              border: Border.all(color: BookstoreTokens.border, width: 1),
            ),
            child: const Center(
              child: Icon(
                Icons.lock_reset_rounded,
                size: 34,
                color: BookstoreTokens.primary,
              ),
            ),
          ),
          Text(
            'Forgot Password',
            textAlign: TextAlign.center,
            style: BookstoreTokens.display(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: BookstoreTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your registered email address and we will send instructions to securely reset your credentials.',
            textAlign: TextAlign.center,
            style: BookstoreTokens.body(
              fontSize: 13.5,
              color: BookstoreTokens.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          PremiumTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'name@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 24),
          PremiumButton(
            label: 'Send Reset Link',
            isLoading: _isLoading,
            onPressed: _handleReset,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 76,
          height: 76,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: BookstoreTokens.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.mark_email_read_rounded,
              size: 38,
              color: BookstoreTokens.success,
            ),
          ),
        ),
        Text(
          'Check Your Inbox',
          textAlign: TextAlign.center,
          style: BookstoreTokens.display(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: BookstoreTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'We have dispatched password recovery instructions to ${_emailController.text}.',
          textAlign: TextAlign.center,
          style: BookstoreTokens.body(
            fontSize: 14,
            color: BookstoreTokens.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),
        PremiumButton(
          label: 'Back to Sign In',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}
