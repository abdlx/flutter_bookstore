import '../../../core/utils/store_action.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/review.dart';
import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/premium_text_field.dart';
import '../../../shared/widgets/review_card.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  final String bookId;

  const ReviewsScreen({super.key, required this.bookId});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  void _openWriteReviewSheet(BuildContext context, String bookTitle) {
    double selectedRating = 5.0;
    final commentController = TextEditingController();

    PremiumBottomSheet.show(
      context: context,
      title: 'Write a Review',
      child: StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reviewing: $bookTitle',
                style: BookstoreTokens.body(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: BookstoreTokens.primaryDark,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Rating',
                style: BookstoreTokens.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starVal = index + 1.0;
                  return IconButton(
                    icon: Icon(
                      starVal <= selectedRating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: BookstoreTokens.rating,
                      size: 34,
                    ),
                    onPressed: () {
                      setSheetState(() => selectedRating = starVal);
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              PremiumTextField(
                controller: commentController,
                label: 'Your Review',
                hint: 'Share what you thought about the prose, themes, and characters...',
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              PremiumButton(
                label: 'Submit Review',
                onPressed: () async {
                  if (commentController.text.trim().isEmpty) return;
                  final user = ref.read(authRepositoryProvider).currentUser;
                  if (!await storeAction(
                    context,
                    ref,
                    () => ref
                        .read(reviewRepositoryProvider)
                        .addReview(
                          bookId: widget.bookId,
                          userName: user?.fullName ?? '',
                          rating: selectedRating,
                          comment: commentController.text.trim(),
                        ),
                  )) {
                    return;
                  }
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Review published successfully!'),
                        backgroundColor: BookstoreTokens.success,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(allBooksStreamProvider);
    final reviewRepo = ref.read(reviewRepositoryProvider);

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: const PremiumAppBar(title: 'Customer Reviews'),
      body: booksAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: BookstoreTokens.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (books) {
          final book = books.where((b) => b.id == widget.bookId).firstOrNull;
          if (book == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Book unavailable')),
              body: const Center(
                child: Text('This book is no longer available.'),
              ),
            );
          }

          return FutureBuilder<List<ReviewItem>>(
            future: reviewRepo.getReviewsForBook(book.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Unable to load reviews: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final reviews = snapshot.data!;

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                children: [
                  // Book mini header
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: BookstoreTokens.surfaceWarm,
                      borderRadius: BorderRadius.circular(
                        BookstoreTokens.radiusCard,
                      ),
                      border: Border.all(
                        color: BookstoreTokens.border,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          book.rating.toStringAsFixed(1),
                          style: BookstoreTokens.display(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: BookstoreTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < book.rating.round()
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    size: 16,
                                    color: BookstoreTokens.rating,
                                  );
                                }),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${book.title} • ${book.reviewCount} total reviews',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: BookstoreTokens.body(
                                  fontSize: 12,
                                  color: BookstoreTokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Write Review CTA Button
                  PremiumButton(
                    label: 'Write a Review',
                    leadingIcon: const Icon(
                      Icons.rate_review_outlined,
                      color: BookstoreTokens.white,
                      size: 18,
                    ),
                    onPressed: () => _openWriteReviewSheet(context, book.title),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Community Reviews',
                    style: BookstoreTokens.body(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: BookstoreTokens.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: EmptyState(
                        icon: Icons.rate_review_outlined,
                        title: 'No Reviews Yet',
                        subtitle: 'Be the first to share your thoughts on this volume.',
                      ),
                    )
                  else
                    ...reviews.map((rev) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ReviewCard(review: rev),
                      );
                    }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
