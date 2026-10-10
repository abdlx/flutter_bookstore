import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/models/review.dart';
import '../../core/theme/bookstore_tokens.dart';

class ReviewCard extends StatelessWidget {
  final ReviewItem review;
  final VoidCallback? onHelpful;

  const ReviewCard({super.key, required this.review, this.onHelpful});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BookstoreTokens.surface,
        borderRadius: BorderRadius.circular(BookstoreTokens.radiusCard),
        border: Border.all(color: BookstoreTokens.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CachedNetworkImage(
                  imageUrl: review.userAvatar,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => Container(
                    width: 36,
                    height: 36,
                    color: BookstoreTokens.surfaceWarm,
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: BookstoreTokens.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: BookstoreTokens.body(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: BookstoreTokens.textPrimary,
                      ),
                    ),
                    Text(
                      review.dateString,
                      style: BookstoreTokens.body(
                        fontSize: 11,
                        color: BookstoreTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating.floor()
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 16,
                    color: BookstoreTokens.rating,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.content,
            style: BookstoreTokens.body(
              fontSize: 13.5,
              height: 1.5,
              color: BookstoreTokens.textPrimary,
            ),
          ),
          if (review.helpfulCount > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: onHelpful,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.thumb_up_alt_outlined,
                        size: 14,
                        color: BookstoreTokens.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Helpful (${review.helpfulCount})',
                        style: BookstoreTokens.body(
                          fontSize: 11.5,
                          color: BookstoreTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
