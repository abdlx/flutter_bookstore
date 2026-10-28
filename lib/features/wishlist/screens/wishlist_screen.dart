import '../../../core/utils/store_action.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/book_list_tile.dart';
import '../../../shared/widgets/empty_state.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistStreamProvider);
    final wishlistRepo = ref.read(wishlistRepositoryProvider);
    final cartRepo = ref.read(cartRepositoryProvider);

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Saved Wishlist',
          style: BookstoreTokens.body(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: BookstoreTokens.textPrimary,
          ),
        ),
      ),
      body: wishlistAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: BookstoreTokens.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (books) {
          if (books.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'Your Wishlist is Empty',
              subtitle: 'Save books you love to your personal sanctuary for future reading.',
              buttonLabel: 'Explore Books',
              onButtonPressed: () => context.go('/explore'),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: books.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final book = books[index];
              return BookListTile(
                book: book,
                onTap: () => context.push('/book/${book.id}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        color: BookstoreTokens.primary,
                        size: 22,
                      ),
                      tooltip: 'Move to Cart',
                      onPressed: () async {
                        if (!await storeAction(
                          context,
                          ref,
                          () => cartRepo.addToCart(book),
                        )) {
                          return;
                        }
                        if (!context.mounted) return;
                        if (!await storeAction(
                          context,
                          ref,
                          () => wishlistRepo.removeFromWishlist(book.id),
                        )) {
                          return;
                        }
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Moved "${book.title}" to cart'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.favorite_rounded,
                        color: BookstoreTokens.primary,
                        size: 22,
                      ),
                      tooltip: 'Remove from Wishlist',
                      onPressed: () async {
                        if (!context.mounted) return;
                        if (!await storeAction(
                          context,
                          ref,
                          () => wishlistRepo.removeFromWishlist(book.id),
                        )) {
                          return;
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
