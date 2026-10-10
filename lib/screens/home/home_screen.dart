import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../widgets/book_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _genre = 'All';

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(booksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Store'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).logout(),
          ),
        ],
      ),
      body: books.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_outlined, size: 64),
                  const SizedBox(height: 12),
                  const Text('No books yet'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 48),
                    ),
                    onPressed: () => ref.read(bookServiceProvider).seedBooks(),
                    child: const Text('Add 20 sample books'),
                  ),
                ],
              ),
            );
          }

          final genres = [
            'All',
            ...{...list.map((b) => b.genre)},
          ];
          final filtered = _genre == 'All'
              ? list
              : list.where((b) => b.genre == _genre).toList();
          final bestsellers = filtered.where((b) => b.isBestseller).toList();
          final newArrivals = [...filtered]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              SizedBox(
                height: 42,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: genres.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ChoiceChip(
                    label: Text(genres[i]),
                    selected: _genre == genres[i],
                    onSelected: (_) => setState(() => _genre = genres[i]),
                  ),
                ),
              ),
              _section('Bestsellers', bestsellers),
              _section('New Arrivals', newArrivals.take(10).toList()),
            ],
          );
        },
      ),
    );
  }

  Widget _section(String title, List<Book> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 285,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (_, i) => BookCard(book: items[i]),
          ),
        ),
      ],
    );
  }
}
