import '../../../shared/widgets/owned_text_controllers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/paged_catalog_view.dart';
import '../../../shared/widgets/premium_text_field.dart';
import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
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
  double? _maxPrice;
  String _sortBy = 'popular'; // 'popular', 'rating', 'price_low', 'price_high'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    final priceController = TextEditingController(
      text: _maxPrice?.toStringAsFixed(2) ?? '',
    );
    PremiumBottomSheet.show(
      context: context,
      title: 'Filter & Refine',
      child: OwnedTextControllers(
        controllers: [priceController],
        child: StatefulBuilder(
          builder: (ctx, setSheetState) {
            final genres = ref.read(catalogGenresProvider);
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
                PremiumTextField(
                  controller: priceController,
                  label: 'Maximum Price (optional)',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (v) {
                    final amount = double.tryParse(v.trim());
                    setState(
                      () => _maxPrice =
                          amount != null && amount.isFinite && amount >= 0
                          ? amount
                          : null,
                    );
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
                    _sortChip(
                      'Price: High to Low',
                      'price_high',
                      setSheetState,
                    ),
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
                _maxPrice != null ||
                _sortBy != 'popular')
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      'Filters: $_selectedGenre • ${_maxPrice == null ? 'Any price' : 'Up to \$${_maxPrice!.toStringAsFixed(2)}'}',
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
                          _maxPrice = null;
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

            // Firestore results loaded in pages
            Expanded(
              child: PagedCatalogView(
                keyword: _activeQuery,
                genre: _selectedGenre,
                maxPrice: _maxPrice,
                sort: _sortBy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
