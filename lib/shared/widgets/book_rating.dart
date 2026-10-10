import 'package:flutter/material.dart';

import '../../core/theme/bookstore_tokens.dart';

class BookRating extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double starSize;
  final double fontSize;
  final bool showParentheses;

  const BookRating({
    super.key,
    required this.rating,
    this.reviewCount,
    this.starSize = 14,
    this.fontSize = 12,
    this.showParentheses = true,
  });

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}k';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.star_rounded, size: starSize, color: BookstoreTokens.rating),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: BookstoreTokens.body(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: BookstoreTokens.textPrimary,
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 3),
          Text(
            showParentheses
                ? '(${_formatCount(reviewCount!)})'
                : _formatCount(reviewCount!),
            style: BookstoreTokens.body(
              fontSize: fontSize,
              fontWeight: FontWeight.normal,
              color: BookstoreTokens.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
