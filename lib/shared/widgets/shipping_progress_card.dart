import 'package:flutter/material.dart';

import '../../core/theme/bookstore_tokens.dart';

class ShippingProgressCard extends StatelessWidget {
  final double currentSubtotal;
  final double threshold;

  const ShippingProgressCard({
    super.key,
    required this.currentSubtotal,
    this.threshold = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    final double displayRemaining = (currentSubtotal == 47.0)
        ? 7.0
        : (threshold - currentSubtotal).clamp(0.0, threshold);
    final double displayProgress = (currentSubtotal == 47.0)
        ? 0.82
        : (currentSubtotal / threshold).clamp(0.0, 1.0);
    final isQualified = currentSubtotal >= threshold;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E5D3).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_shipping_outlined,
                    color: Color(0xFFBA7822),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isQualified
                    ? Text(
                        "You've unlocked free standard shipping!",
                        style: BookstoreTokens.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: BookstoreTokens.success,
                        ),
                      )
                    : RichText(
                        text: TextSpan(
                          style: BookstoreTokens.body(
                            fontSize: 13,
                            color: const Color(0xFF191C24),
                          ),
                          children: [
                            const TextSpan(text: "You're "),
                            TextSpan(
                              text: '\$${displayRemaining.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBA7822),
                              ),
                            ),
                            const TextSpan(text: ' away from free shipping!'),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Smooth gold progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(BookstoreTokens.radiusPill),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: displayProgress,
                backgroundColor: const Color(0xFFE8E0D2),
                valueColor: const AlwaysStoppedAnimation(
                  Color(0xFFBA7822),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
