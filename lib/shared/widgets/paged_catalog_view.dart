import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/book.dart';
import '../../core/utils/store_action.dart';
import '../../providers/app_providers.dart';
import '../../data/firestore/catalog_queries.dart';
import '../../data/firestore/firestore_codec.dart';
import 'book_card.dart';
import 'book_list_tile.dart';
import 'empty_state.dart';

class PagedCatalogView extends ConsumerStatefulWidget {
  final String keyword, genre, sort;
  final double? maxPrice;
  final bool grid;
  final bool administrator;
  const PagedCatalogView({
    super.key,
    this.keyword = '',
    this.genre = 'All',
    this.sort = 'popular',
    this.maxPrice,
    this.grid = false,
    this.administrator = false,
  });
  @override
  ConsumerState<PagedCatalogView> createState() => _PagedCatalogViewState();
}

class _PagedCatalogViewState extends ConsumerState<PagedCatalogView> {
  static const _size = 24;
  final _pages = <int, QuerySnapshot<Map<String, dynamic>>>{};
  final _subscriptions = <StreamSubscription<dynamic>>[];
  bool _loading = true, _hasMore = false;
  Object? _error;
  int _generation = 0;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(PagedCatalogView old) {
    super.didUpdateWidget(old);
    if (old.keyword != widget.keyword ||
        old.genre != widget.genre ||
        old.sort != widget.sort ||
        old.maxPrice != widget.maxPrice) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 250), _reset);
    }
  }

  Future<void> _reset() async {
    final generation = ++_generation;
    await Future.wait(_subscriptions.map((s) => s.cancel()));
    if (!mounted || generation != _generation) return;
    _subscriptions.clear();
    _pages.clear();
    setState(() {
      _loading = true;
      _error = null;
      _hasMore = false;
    });
    _listenPage(0, null, generation);
  }

  void _listenPage(
    int index,
    DocumentSnapshot<Map<String, dynamic>>? cursor,
    int generation,
  ) {
    var query = catalogQuery(
      ref.read(firebaseFirestoreProvider),
      keyword: widget.keyword,
      genre: widget.genre,
      sort: widget.sort,
    );
    if (cursor != null) query = query.startAfterDocument(cursor);
    _subscriptions.add(
      query
          .limit(_size)
          .snapshots()
          .listen(
            (page) {
              if (!mounted || generation != _generation) return;
              final old = _pages[index];
              if (old != null &&
                  _pages.length > index + 1 &&
                  (old.docs.map((d) => d.id).join(',') !=
                          page.docs.map((d) => d.id).join(',') ||
                      (old.docs.isNotEmpty &&
                          page.docs.isNotEmpty &&
                          old.docs.last.data().toString() !=
                              page.docs.last.data().toString()))) {
                _reset();
                return;
              }
              setState(() {
                _pages[index] = page;
                _loading = _pages.length < _subscriptions.length;
                _error = null;
                _hasMore =
                    _pages[_pages.keys.reduce((a, b) => a > b ? a : b)]!.size ==
                    _size;
              });
            },
            onError: (Object e) {
              if (mounted && generation == _generation) {
                setState(() {
                  _error = e;
                  _loading = false;
                });
              }
            },
          ),
    );
  }

  void _more() {
    if (_loading || !_hasMore) return;
    final index = _pages.length;
    final previous = _pages[index - 1]!;
    setState(() => _loading = true);
    _listenPage(index, previous.docs.last, _generation);
  }

  @override
  void dispose() {
    _generation++;
    _debounce?.cancel();
    for (final s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final distinct = <String, BookItem>{};
    for (final page
        in _pages.entries.toList()..sort((a, b) => a.key.compareTo(b.key))) {
      for (final d in page.value.docs) {
        distinct[d.id] = readBook(d.id, d.data());
      }
    }
    final books = distinct.values
        .where((b) => matchesCatalog(b, widget.keyword, widget.maxPrice))
        .toList();
    if (_loading && _pages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _pages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Unable to load catalog: $_error'),
            TextButton(onPressed: _reset, child: const Text('Retry')),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _reset,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Text('${books.length} titles loaded'),
            ),
          ),
          if (books.isEmpty && !_hasMore)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.search_off,
                title: 'No Books Found',
                subtitle: 'Try another search or genre.',
              ),
            ),
          if (widget.grid && !widget.administrator)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final b = books[index];
                  return BookCard(
                    book: b,
                    onTap: () => context.push('/book/${b.id}'),
                    onAddToCart: () async {
                      await storeAction(
                        context,
                        ref,
                        () => ref.read(cartRepositoryProvider).addToCart(b),
                      );
                    },
                  );
                }, childCount: books.length),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  mainAxisExtent: 350,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 16,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final b = books[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: BookListTile(
                      book: b,
                      showStock: widget.administrator,
                      onTap: () => context.push(
                        widget.administrator
                            ? '/admin/books/edit?id=${Uri.encodeComponent(b.id)}'
                            : '/book/${b.id}',
                      ),
                      trailing: widget.administrator
                          ? IconButton(
                              tooltip: 'Delete book',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _delete(b),
                            )
                          : IconButton(
                              tooltip: 'Add to cart',
                              icon: const Icon(Icons.add_shopping_cart),
                              onPressed: () async {
                                await storeAction(
                                  context,
                                  ref,
                                  () => ref
                                      .read(cartRepositoryProvider)
                                      .addToCart(b),
                                );
                              },
                            ),
                    ),
                  );
                }, childCount: books.length),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                children: [
                  if (_error != null)
                    Text('Unable to load the next page: $_error'),
                  if (_loading)
                    const CircularProgressIndicator()
                  else if (_error != null)
                    TextButton(onPressed: _reset, child: const Text('Retry'))
                  else if (_hasMore)
                    OutlinedButton(
                      onPressed: _more,
                      child: const Text('Load More'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(BookItem book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete book?'),
        content: Text(book.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await storeAction(
        context,
        ref,
        () => ref.read(adminRepositoryProvider).deleteBook(book.id),
      );
    }
  }
}
