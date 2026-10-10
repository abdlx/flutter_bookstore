import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/theme/bookstore_tokens.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/premium_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(
    text: 'alex.morgan@aptech.edu',
  );
  final _passwordController = TextEditingController(text: 'secret123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.login(_emailController.text, _passwordController.text);
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: BookstoreTokens.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _demoFill(String email, UserRole role) {
    _emailController.text = email;
    _passwordController.text = 'secret123';
    ref.read(authRepositoryProvider).switchDemoRole(role);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pre-filled as ${role == UserRole.admin ? "Admin" : "Customer (Alex)"}',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Icon
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: BookstoreTokens.surfaceWarm,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: BookstoreTokens.primaryLight.withValues(
                              alpha: 0.6,
                            ),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: BookstoreTokens.primary.withValues(
                                alpha: 0.16,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.auto_stories,
                            size: 36,
                            color: BookstoreTokens.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: BookstoreTokens.display(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: BookstoreTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to access your curated book sanctuary',
                      textAlign: TextAlign.center,
                      style: BookstoreTokens.body(
                        fontSize: 13.5,
                        color: BookstoreTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Email Field
                    PremiumTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'name@example.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),

                    const SizedBox(height: 18),

                    // Password Field
                    PremiumTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline,
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

                    const SizedBox(height: 10),

                    // Forgot Password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: Text(
                          'Forgot Password?',
                          style: BookstoreTokens.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: BookstoreTokens.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sign In Button
                    PremiumButton(
                      label: 'Sign In',
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),

                    const SizedBox(height: 20),

                    // Demo Quick-Fill Buttons for painless testing
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: BookstoreTokens.surfaceWarm,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: BookstoreTokens.border,
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 14,
                                color: BookstoreTokens.primaryDark,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Frontend Demo Quick Roles:',
                                style: BookstoreTokens.body(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: BookstoreTokens.primaryDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    side: const BorderSide(
                                      color: BookstoreTokens.primary,
                                      width: 1,
                                    ),
                                  ),
                                  onPressed: () => _demoFill(
                                    'alex.morgan@aptech.edu',
                                    UserRole.customer,
                                  ),
                                  child: const Text(
                                    'Customer',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    side: const BorderSide(
                                      color: BookstoreTokens.primaryDark,
                                      width: 1,
                                    ),
                                  ),
                                  onPressed: () => _demoFill(
                                    'sarah.sterling@aptech.edu',
                                    UserRole.admin,
                                  ),
                                  child: const Text(
                                    'Admin',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Don't have an account? Register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: BookstoreTokens.body(
                            fontSize: 13.5,
                            color: BookstoreTokens.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: Text(
                            'Create Account',
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
