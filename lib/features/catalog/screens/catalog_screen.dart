import '../../../core/utils/store_action.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/book_card.dart';
import '../../../shared/widgets/book_list_tile.dart';
import '../../../shared/widgets/category_selector.dart';
import '../../../shared/widgets/premium_search_bar.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  bool _isGridView = true;
  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(allBooksStreamProvider);
    final selectedGenre = ref.watch(selectedGenreProvider);
    final cartRepo = ref.read(cartRepositoryProvider);

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Explore Catalog',
          style: BookstoreTokens.body(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: BookstoreTokens.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: BookstoreTokens.textPrimary,
            ),
            tooltip: _isGridView
                ? 'Switch to list view'
                : 'Switch to grid view',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: PremiumSearchBar(
                readOnly: true,
                onTap: () => context.push('/search'),
                onFilterTap: () => context.push('/search'),
              ),
            ),

            // Horizontal Genre chips
            CategorySelector(
              categories: ref.watch(catalogGenresProvider),
              selectedCategory: selectedGenre,
              onSelected: (g) {
                ref.read(selectedGenreProvider.notifier).state = g;
              },
            ),

            const SizedBox(height: 14),

            // Book count and active filter header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedGenre == 'All'
                        ? 'All Curated Titles'
                        : '$selectedGenre Books',
                    style: BookstoreTokens.body(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: BookstoreTokens.textPrimary,
                    ),
                  ),
                  booksAsync.maybeWhen(
                    data: (books) {
                      final count = selectedGenre == 'All'
                          ? books.length
                          : books
                                .where(
                                  (b) =>
                                      b.genre.toLowerCase() ==
                                      selectedGenre.toLowerCase(),
                                )
                                .length;
                      return Text(
                        '$count volumes',
                        style: BookstoreTokens.body(
                          fontSize: 12,
                          color: BookstoreTokens.textSecondary,
                        ),
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Books listing (Grid or List)
            Expanded(
              child: booksAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: BookstoreTokens.primary,
                  ),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (books) {
                  final filtered = selectedGenre == 'All'
                      ? books
                      : books.where((b) {
                          return b.genre.toLowerCase() ==
                                  selectedGenre.toLowerCase() ||
                              b.tags.any(
                                (t) =>
                                    t.toLowerCase() ==
                                    selectedGenre.toLowerCase(),
                              );
                        }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No books found in "$selectedGenre"',
                        style: BookstoreTokens.body(
                          color: BookstoreTokens.textSecondary,
                        ),
                      ),
                    );
                  }

                  if (_isGridView) {
                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 0.47,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 20,
                          ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final book = filtered[index];
                        return BookCard(
                          book: book,
                          onTap: () => context.push('/book/${book.id}'),
                          onAddToCart: () async {
                            if (!await storeAction(
                              context,
                              ref,
                              () => cartRepo.addToCart(book),
                            )) {
                              return;
                            }
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added "${book.title}" to cart'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                    );
                  } else {
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final book = filtered[index];
                        return BookListTile(
                          book: book,
                          onTap: () => context.push('/book/${book.id}'),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.add_shopping_cart_rounded,
                              color: BookstoreTokens.primary,
                            ),
                            onPressed: () async {
                              if (!await storeAction(
                                context,
                                ref,
                                () => cartRepo.addToCart(book),
                              )) {
                                return;
                              }
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Added "${book.title}" to cart',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
