import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../core/utils/store_action.dart';

import 'profile_avatar.dart';

import 'package:flutter/material.dart';

import '../../core/models/review.dart';
import '../../core/theme/bookstore_tokens.dart';

class ReviewCard extends StatelessWidget {
  final ReviewItem review;
  final VoidCallback? onHelpful;
  final bool isHelpful;
  final bool voting;

  const ReviewCard({
    super.key,
    required this.review,
    this.onHelpful,
    this.isHelpful = false,
    this.voting = false,
  });

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
              ProfileAvatar(url: review.userAvatar, radius: 18),
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
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: voting ? null : onHelpful,
              icon: voting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      isHelpful
                          ? Icons.thumb_up_alt
                          : Icons.thumb_up_alt_outlined,
                      size: 16,
                    ),
              label: Text('Helpful (${review.helpfulCount})'),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpfulReviewCard extends ConsumerStatefulWidget {
  final ReviewItem review;
  const HelpfulReviewCard({super.key, required this.review});
  @override
  ConsumerState<HelpfulReviewCard> createState() => _HelpfulReviewCardState();
}

class _HelpfulReviewCardState extends ConsumerState<HelpfulReviewCard> {
  bool _busy = false;
  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final vote = ref.watch(
      helpfulVoteProvider((bookId: review.bookId, reviewId: review.id)),
    );
    final ownReview =
        ref.watch(currentUserStreamProvider).value?.id == review.id;
    return ReviewCard(
      review: review,
      isHelpful: vote.value ?? false,
      voting: _busy,
      onHelpful: ownReview || vote.isLoading
          ? null
          : () async {
              setState(() => _busy = true);
              try {
                await storeAction(
                  context,
                  ref,
                  () => ref
                      .read(reviewRepositoryProvider)
                      .toggleHelpfulVote(review.bookId, review.id),
                );
              } finally {
                if (mounted) setState(() => _busy = false);
              }
            },
    );
  }
}
