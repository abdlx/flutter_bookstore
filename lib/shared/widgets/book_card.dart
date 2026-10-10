import 'package:flutter/material.dart';

import '../../core/models/book.dart';
import '../../core/theme/bookstore_tokens.dart';
import 'book_cover.dart';
import 'book_rating.dart';
import 'price_label.dart';

class BookCard extends StatelessWidget {
  final BookItem book;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final double? width;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onAddToCart,
    this.width = 138,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (width != null && width!.isFinite)
            ? width!
            : (constraints.maxWidth.isFinite ? constraints.maxWidth : 138.0);
        final double coverHeight =
            cardWidth / BookstoreTokens.bookCoverAspectRatio;

        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating book cover
                BookCover(
                  imageUrl: book.coverUrl,
                  title: book.title,
                  author: book.author,
                  width: cardWidth,
                  height: coverHeight,
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BookstoreTokens.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: BookstoreTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                // Author
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BookstoreTokens.body(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: BookstoreTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                // Rating
                BookRating(rating: book.rating, reviewCount: book.reviewCount),
                const SizedBox(height: 6),
                // Price & Add to Cart button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PriceLabel(price: book.price, fontSize: 16, isGold: true),
                    GestureDetector(
                      onTap: () {
                        if (onAddToCart != null) {
                          onAddToCart!();
                        }
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFBA7822),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFBA7822).withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
