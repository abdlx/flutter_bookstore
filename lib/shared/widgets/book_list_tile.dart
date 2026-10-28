import 'package:flutter/material.dart';

import '../../core/models/book.dart';
import '../../core/theme/bookstore_tokens.dart';
import 'book_cover.dart';
import 'book_rating.dart';
import 'price_label.dart';

class BookListTile extends StatelessWidget {
  final BookItem book;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showStock;

  const BookListTile({
    super.key,
    required this.book,
    this.onTap,
    this.trailing,
    this.showStock = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: BookstoreTokens.surface,
          borderRadius: BorderRadius.circular(BookstoreTokens.radiusCard),
          border: Border.all(color: BookstoreTokens.border, width: 1),
          boxShadow: BookstoreTokens.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BookCover(
              imageUrl: book.coverUrl,
              title: book.title,
              author: book.author,
              width: 58,
              height: 58 / BookstoreTokens.bookCoverAspectRatio,
              borderRadius: 8,
              shadows: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BookstoreTokens.body(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: BookstoreTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BookstoreTokens.body(
                      fontSize: 12.5,
                      fontWeight: FontWeight.normal,
                      color: BookstoreTokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      BookRating(
                        rating: book.rating,
                        reviewCount: book.reviewCount,
                        fontSize: 11,
                        starSize: 13,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: BookstoreTokens.surfaceWarm,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          book.genre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BookstoreTokens.body(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: BookstoreTokens.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (showStock)
                    Text(
                      '${book.stockQuantity} in stock${book.isBestseller ? ' · Bestseller' : ''}',
                      style: BookstoreTokens.body(fontSize: 12),
                    ),
                  PriceLabel(
                    price: book.price,
                    originalPrice: book.originalPrice,
                    fontSize: 15,
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}
