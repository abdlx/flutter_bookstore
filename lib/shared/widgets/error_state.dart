import 'package:flutter/material.dart';

import '../../core/theme/bookstore_tokens.dart';
import 'premium_button.dart';

class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'Unable to load content at this moment. Please check your connection and try again.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: BookstoreTokens.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 36,
                  color: BookstoreTokens.error,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: BookstoreTokens.display(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: BookstoreTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: BookstoreTokens.body(
                fontSize: 13.5,
                color: BookstoreTokens.textSecondary,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              PremiumButton(
                label: 'Try Again',
                onPressed: onRetry,
                width: 160,
                height: 46,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
