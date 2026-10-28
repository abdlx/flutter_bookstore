import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/bookstore_tokens.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/premium_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service to continue'),
          backgroundColor: BookstoreTokens.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome! Account created successfully'),
            backgroundColor: BookstoreTokens.success,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
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
      appBar: const PremiumAppBar(title: 'Create Account'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Join Aptech Book Store',
                      textAlign: TextAlign.center,
                      style: BookstoreTokens.display(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: BookstoreTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Become a member to track reading lists and enjoy luxury literary rewards',
                      textAlign: TextAlign.center,
                      style: BookstoreTokens.body(
                        fontSize: 13.5,
                        color: BookstoreTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Full Name
                    PremiumTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'e.g. Alex Morgan',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: Validators.name,
                    ),

                    const SizedBox(height: 18),

                    // Email Address
                    PremiumTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'name@example.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),

                    const SizedBox(height: 18),

                    // Password
                    PremiumTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Minimum 6 characters',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      validator: Validators.password,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: BookstoreTokens.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Terms Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          activeColor: BookstoreTokens.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (v) {
                            setState(() {
                              _agreeToTerms = v ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            'I agree to the Terms of Service & Privacy Policy',
                            style: BookstoreTokens.body(
                              fontSize: 12.5,
                              color: BookstoreTokens.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => context.push('/policies/terms'),
                          child: const Text('Read Terms'),
                        ),
                        TextButton(
                          onPressed: () => context.push('/policies/privacy'),
                          child: const Text('Read Privacy Policy'),
                        ),
                      ],
                    ),
                    // Register Button
                    PremiumButton(
                      label: 'Create Account',
                      isLoading: _isLoading,
                      onPressed: _handleRegister,
                    ),

                    const SizedBox(height: 24),

                    // Already have an account? Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: BookstoreTokens.body(
                            fontSize: 13.5,
                            color: BookstoreTokens.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: Text(
                            'Sign In',
                            style: BookstoreTokens.body(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: BookstoreTokens.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
