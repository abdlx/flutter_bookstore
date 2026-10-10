import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/bookstore_tokens.dart';
import '../../../shared/widgets/premium_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Discover Timeless Works',
      'subtitle': 'Immerse yourself in our hand-curated collection of classic literature, award-winning poetry, and thought-provoking nonfiction.',
      'icon': Icons.auto_stories_rounded,
    },
    {
      'title': 'Your Personal Literary Haven',
      'subtitle': 'Curate custom wishlists, receive tailored recommendations, and celebrate the transformative pleasure of physical books.',
      'icon': Icons.bookmark_added_rounded,
    },
    {
      'title': 'Pristine White-Glove Delivery',
      'subtitle': 'Enjoy complimentary shipping on orders over \$50 with careful archival packaging and live real-time doorstep tracking.',
      'icon': Icons.local_shipping_rounded,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: Text(
              'Skip',
              style: BookstoreTokens.body(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: BookstoreTokens.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final item = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: BookstoreTokens.surfaceWarm,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: BookstoreTokens.primaryLight.withValues(
                                alpha: 0.5,
                              ),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: BookstoreTokens.primary.withValues(
                                  alpha: 0.12,
                                ),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              item['icon'] as IconData,
                              size: 64,
                              color: BookstoreTokens.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          item['title'] as String,
                          textAlign: TextAlign.center,
                          style: BookstoreTokens.display(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: BookstoreTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            item['subtitle'] as String,
                            textAlign: TextAlign.center,
                            style: BookstoreTokens.body(
                              fontSize: 14,
                              color: BookstoreTokens.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Page Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  final isSelected = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 22 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? BookstoreTokens.primary
                          : const Color(0xFFDCD6CC),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 36),

              // Bottom Actions
              Row(
                children: [
                  if (_currentIndex > 0) ...[
                    Expanded(
                      flex: 1,
                      child: PremiumButton(
                        label: 'Back',
                        variant: PremiumButtonVariant.secondary,
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: PremiumButton(
                      label: _currentIndex == _slides.length - 1
                          ? 'Get Started'
                          : 'Continue',
                      trailingIcon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: BookstoreTokens.white,
                        size: 18,
                      ),
                      onPressed: () {
                        if (_currentIndex < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          context.go('/login');
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
