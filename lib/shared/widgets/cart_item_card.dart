import 'package:flutter/material.dart';

import '../../core/models/cart_item.dart';
import '../../core/theme/bookstore_tokens.dart';
import 'book_cover.dart';
import 'quantity_stepper.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            BookCover(
              imageUrl: item.book.coverUrl,
              title: item.book.title,
              author: item.book.author,
              width: 58,
              height: 58 / BookstoreTokens.bookCoverAspectRatio,
              borderRadius: 8,
              shadows: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // Info & Stepper
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.book.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: BookstoreTokens.body(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF191C24),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.book.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: BookstoreTokens.body(
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                                color: const Color(0xFF7A7875),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Price on top right (gold)
                      Text(
                        '\$${item.totalPrice.toInt()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFBA7822),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Bottom controls row: Stepper and trash icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      QuantityStepper(
                        quantity: item.quantity,
                        height: 32,
                        backgroundColor: const Color(0xFFF7F2E8),
                        onChanged: onQuantityChanged,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: BookstoreTokens.textSecondary,
                          size: 20,
                        ),
                        onPressed: onRemove,
                        tooltip: 'Remove',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
