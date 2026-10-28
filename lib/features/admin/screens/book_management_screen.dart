import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_search_bar.dart';
import '../../../shared/widgets/paged_catalog_view.dart';

class BookManagementScreen extends StatefulWidget {
  const BookManagementScreen({super.key});
  @override
  State<BookManagementScreen> createState() => _BookManagementScreenState();
}

class _BookManagementScreenState extends State<BookManagementScreen> {
  String _query = '';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const PremiumAppBar(title: 'Catalog Management'),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => context.push('/admin/books/edit'),
      icon: const Icon(Icons.add),
      label: const Text('Add Book'),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: PremiumSearchBar(
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Expanded(child: PagedCatalogView(keyword: _query, administrator: true)),
      ],
    ),
  );
}
