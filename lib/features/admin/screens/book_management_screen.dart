import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/book.dart';
import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/book_cover.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_button.dart';

class BookManagementScreen extends ConsumerStatefulWidget {
  const BookManagementScreen({super.key});

  @override
  ConsumerState<BookManagementScreen> createState() =>
      _BookManagementScreenState();
}

class _BookManagementScreenState extends ConsumerState<BookManagementScreen> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(allBooksStreamProvider);
    final adminRepo = ref.read(adminRepositoryProvider);

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: const PremiumAppBar(title: 'Catalog Management'),
      body: booksAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: BookstoreTokens.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (books) {
          final filtered = _filter.isEmpty
              ? books
              : books.where((b) {
                  return b.title.toLowerCase().contains(
                        _filter.toLowerCase(),
                      ) ||
                      b.author.toLowerCase().contains(_filter.toLowerCase());
                }).toList();

          return Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: TextField(
                  onChanged: (val) => setState(() => _filter = val),
                  decoration: const InputDecoration(
                    hintText: 'Filter by title or author...',
                    prefixIcon: Icon(Icons.search_rounded),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              // Book count
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Titles: ${filtered.length}',
                      style: BookstoreTokens.body(
                        fontSize: 12.5,
                        color: BookstoreTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Books list
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final book = filtered[index];
                    return _AdminBookTile(
                      book: book,
                      onEdit: () =>
                          context.push('/admin/books/edit?id=${book.id}'),
                      onDelete: () async {
                        final confirm = await ConfirmationDialog.show(
                          context: context,
                          title: 'Remove Volume?',
                          message:
                              'Are you sure you want to remove "${book.title}" from catalog?',
                          confirmLabel: 'Delete',
                          isDestructive: true,
                        );
                        if (confirm == true) {
                          await adminRepo.deleteBook(book.id);
                          ref.invalidate(allBooksStreamProvider);
                        }
                      },
                    );
                  },
                ),
              ),

              // Bottom Add Book CTA
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  16 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: const BoxDecoration(
                  color: BookstoreTokens.surface,
                  border: Border(
                    top: BorderSide(color: BookstoreTokens.divider, width: 1),
                  ),
                ),
                child: PremiumButton(
                  label: '+ Add New Book Title',
                  onPressed: () => context.push('/admin/books/edit'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AdminBookTile extends StatelessWidget {
  final BookItem book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminBookTile({
    required this.book,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BookstoreTokens.surface,
        borderRadius: BorderRadius.circular(BookstoreTokens.radiusCard),
        border: Border.all(color: BookstoreTokens.border, width: 1),
      ),
      child: Row(
        children: [
          BookCover(
            imageUrl: book.coverUrl,
            title: book.title,
            author: book.author,
            width: 46,
            height: 46 / BookstoreTokens.bookCoverAspectRatio,
            borderRadius: 6,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BookstoreTokens.body(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${book.author} • \$${book.price.toStringAsFixed(0)}',
                  style: BookstoreTokens.body(
                    fontSize: 12,
                    color: BookstoreTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: BookstoreTokens.surfaceWarm,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Stock: ${book.stockQuantity}',
                        style: BookstoreTokens.body(
                          fontSize: 10.5,
                          color: BookstoreTokens.primaryDark,
                        ),
                      ),
                    ),
                    if (book.isBestseller) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF4E9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Bestseller',
                          style: BookstoreTokens.body(
                            fontSize: 10.5,
                            color: BookstoreTokens.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: BookstoreTokens.primary,
              size: 20,
            ),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: BookstoreTokens.error,
              size: 20,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
