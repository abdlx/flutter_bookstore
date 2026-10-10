import 'package:flutter/material.dart';

import '../../core/theme/bookstore_tokens.dart';
import 'premium_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: BookstoreTokens.surfaceWarm,
                shape: BoxShape.circle,
                border: Border.all(color: BookstoreTokens.border, width: 1),
              ),
              child: Center(
                child: Icon(icon, size: 38, color: BookstoreTokens.primary),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: BookstoreTokens.display(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: BookstoreTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: BookstoreTokens.body(
                fontSize: 14,
                color: BookstoreTokens.textSecondary,
                height: 1.4,
              ),
            ),
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              PremiumButton(
                label: buttonLabel!,
                onPressed: onButtonPressed,
                width: 200,
                height: 48,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
