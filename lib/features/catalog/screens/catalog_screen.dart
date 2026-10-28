import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/app_providers.dart';
import '../../../shared/widgets/category_selector.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_search_bar.dart';
import '../../../shared/widgets/paged_catalog_view.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});
  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  bool _grid = true;
  @override
  Widget build(BuildContext context) {
    final genre = ref.watch(selectedGenreProvider);
    return Scaffold(
      appBar: PremiumAppBar(
        title: 'Explore Books',
        actions: [
          IconButton(
            tooltip: _grid ? 'List view' : 'Grid view',
            icon: Icon(_grid ? Icons.view_list_outlined : Icons.grid_view),
            onPressed: () => setState(() => _grid = !_grid),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: PremiumSearchBar(
              readOnly: true,
              onTap: () => context.push('/search'),
              onFilterTap: () => context.push('/search'),
            ),
          ),
          CategorySelector(
            categories: ref.watch(catalogGenresProvider),
            selectedCategory: genre,
            onSelected: (g) =>
                ref.read(selectedGenreProvider.notifier).state = g,
          ),
          Expanded(
            child: PagedCatalogView(genre: genre, grid: _grid),
          ),
        ],
      ),
    );
  }
}
