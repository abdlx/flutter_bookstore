import 'package:flutter/material.dart';

import '../../core/theme/bookstore_tokens.dart';

class PriceLabel extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final double fontSize;
  final Color? color;
  final bool isGold;

  const PriceLabel({
    super.key,
    required this.price,
    this.originalPrice,
    this.fontSize = 16,
    this.color,
    this.isGold = false,
  });

  String _formatPrice(double val) {
    if (val == val.roundToDouble()) {
      return '\$${val.toInt()}';
    }
    return '\$${val.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ??
        (isGold ? BookstoreTokens.primary : BookstoreTokens.textPrimary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatPrice(price),
          style: BookstoreTokens.body(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: effectiveColor,
          ),
        ),
        if (originalPrice != null && originalPrice! > price) ...[
          const SizedBox(height: 2),
          Text(
            _formatPrice(originalPrice!),
            style: BookstoreTokens.body(
              fontSize: fontSize * 0.72,
              fontWeight: FontWeight.normal,
              color: BookstoreTokens.textMuted,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}
