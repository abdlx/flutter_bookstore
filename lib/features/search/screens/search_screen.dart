import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/book.dart';
import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/book_list_tile.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/premium_search_bar.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeQuery = '';
  String _selectedGenre = 'All';
  double _maxPrice = 50.0;
  String _sortBy = 'popular'; // 'popular', 'rating', 'price_low', 'price_high'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    PremiumBottomSheet.show(
      context: context,
      title: 'Filter & Refine',
      child: StatefulBuilder(
        builder: (ctx, setSheetState) {
          final genres = [
            'All',
            'Fiction',
            'Non-Fiction',
            'Education',
            'Self Help',
            'Fantasy',
            'Sci-Fi',
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Genre',
                style: BookstoreTokens.body(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genres.map((g) {
                  final isSel = _selectedGenre == g;
                  return ChoiceChip(
                    label: Text(g),
                    selected: isSel,
                    selectedColor: BookstoreTokens.primary,
                    labelStyle: TextStyle(
                      color: isSel
                          ? BookstoreTokens.white
                          : BookstoreTokens.textPrimary,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      setSheetState(() => _selectedGenre = g);
                      setState(() => _selectedGenre = g);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Maximum Price',
                    style: BookstoreTokens.body(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${_maxPrice.toStringAsFixed(0)}',
                    style: BookstoreTokens.body(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: BookstoreTokens.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _maxPrice,
                min: 5,
                max: 50,
                divisions: 9,
                activeColor: BookstoreTokens.primary,
                inactiveColor: BookstoreTokens.border,
                onChanged: (val) {
                  setSheetState(() => _maxPrice = val);
                  setState(() => _maxPrice = val);
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Sort Order',
                style: BookstoreTokens.body(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  _sortChip('Most Popular', 'popular', setSheetState),
                  _sortChip('Highest Rated', 'rating', setSheetState),
                  _sortChip('Price: Low to High', 'price_low', setSheetState),
                  _sortChip('Price: High to Low', 'price_high', setSheetState),
                ],
              ),
              const SizedBox(height: 28),
              PremiumButton(
                label: 'Apply Filters',
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sortChip(String label, String value, StateSetter setSheetState) {
    final isSel = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSel,
      selectedColor: BookstoreTokens.primary,
      labelStyle: TextStyle(
        color: isSel ? BookstoreTokens.white : BookstoreTokens.textPrimary,
        fontSize: 12,
      ),
      onSelected: (_) {
        setSheetState(() => _sortBy = value);
        setState(() => _sortBy = value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final booksRepo = ref.read(bookRepositoryProvider);

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: const PremiumAppBar(title: 'Search Catalog'),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: PremiumSearchBar(
                controller: _searchController,
                autofocus: false,
                onChanged: (val) {
                  setState(() {
                    _activeQuery = val;
                  });
                },
                onFilterTap: _openFilterSheet,
              ),
            ),

            // Active filters bar if modified
            if (_selectedGenre != 'All' ||
                _maxPrice < 50 ||
                _sortBy != 'popular')
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      'Filters: $_selectedGenre • Up to \$${_maxPrice.toInt()}',
                      style: BookstoreTokens.body(
                        fontSize: 12,
                        color: BookstoreTokens.primaryDark,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGenre = 'All';
                          _maxPrice = 50.0;
                          _sortBy = 'popular';
                        });
                      },
                      child: Text(
                        'Reset',
                        style: BookstoreTokens.body(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: BookstoreTokens.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Search Results Future
            Expanded(
              child: FutureBuilder<List<BookItem>>(
                future: booksRepo.searchBooks(
                  _activeQuery,
                  genre: _selectedGenre,
                  maxPrice: _maxPrice,
                  sortBy: _sortBy,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: BookstoreTokens.primary,
                      ),
                    );
                  }

                  final results = snapshot.data ?? [];

                  if (results.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No Books Found',
                      subtitle: _activeQuery.isEmpty
                          ? 'Adjust your filter criteria to view matching literature.'
                          : 'No matching titles or authors for "$_activeQuery". Try "Alchemist", "Dune", or "Clear".',
                      buttonLabel: 'Clear Search',
                      onButtonPressed: () {
                        _searchController.clear();
                        setState(() {
                          _activeQuery = '';
                          _selectedGenre = 'All';
                          _maxPrice = 50.0;
                        });
                      },
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final book = results[index];
                      return BookListTile(
                        book: book,
                        onTap: () => context.push('/book/${book.id}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
