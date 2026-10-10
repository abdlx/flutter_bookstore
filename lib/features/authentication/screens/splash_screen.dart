import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();

    _timer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) {
        final currentUser = ref.read(authRepositoryProvider).currentUser;
        if (currentUser != null) {
          context.go('/home');
        } else {
          context.go('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: BookstoreTokens.surfaceWarm,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: BookstoreTokens.primaryLight,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: BookstoreTokens.primary.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_stories,
                    size: 42,
                    color: BookstoreTokens.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Aptech Book Store',
                style: BookstoreTokens.display(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: BookstoreTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'CURATED LITERARY EXCELLENCE',
                style: BookstoreTokens.body(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: BookstoreTokens.primaryDark,
                ),
              ),
              const SizedBox(height: 36),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(BookstoreTokens.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
