import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/book_cover.dart';

class HeroBannerCard extends ConsumerWidget {
  final VoidCallback onShopNow;
  const HeroBannerCard({super.key, required this.onShopNow});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books =
        ref.watch(homeBooksProvider(ref.watch(selectedGenreProvider))).value ??
        [];
    final featured = books
        .where((b) => b.isRecommended && b.stockQuantity > 0)
        .firstOrNull;
    if (featured == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: BookstoreTokens.textPrimary,
          borderRadius: BorderRadius.circular(BookstoreTokens.radiusCard),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A reading recommendation',
                    style: BookstoreTokens.body(
                      color: BookstoreTokens.primaryLight,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    featured.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: BookstoreTokens.display(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    featured.author,
                    style: BookstoreTokens.body(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: onShopNow,
                    child: const Text('Explore books'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            BookCover(
              imageUrl: featured.coverUrl,
              title: featured.title,
              author: featured.author,
              width: 90,
              height: 90 / BookstoreTokens.bookCoverAspectRatio,
            ),
          ],
        ),
      ),
    );
  }
}
