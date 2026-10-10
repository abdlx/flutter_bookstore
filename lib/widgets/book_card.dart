import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/book_model.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  const BookCard({super.key, required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'cover_${book.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: book.coverUrl,
                  height: 190,
                  width: 140,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(height: 190, color: cs.surfaceContainerHighest),
                  errorWidget: (_, _, _) => Container(
                    height: 190,
                    color: cs.surfaceContainerHighest,
                    child: const Icon(Icons.book, size: 40),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                Text(' ${book.rating}', style: const TextStyle(fontSize: 12)),
                const Spacer(),
                Text(
                  '\$${book.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
