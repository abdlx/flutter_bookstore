import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/book.dart';
import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/premium_app_bar.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/premium_text_field.dart';

class AddEditBookScreen extends ConsumerStatefulWidget {
  final String? bookId;

  const AddEditBookScreen({super.key, this.bookId});

  @override
  ConsumerState<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends ConsumerState<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController(text: 'Fiction');
  final _priceController = TextEditingController(text: '18');
  final _origPriceController = TextEditingController(text: '22');
  final _descController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _stockController = TextEditingController(text: '25');
  final _publisherController = TextEditingController(
    text: 'Penguin Random House',
  );
  final _pagesController = TextEditingController(text: '320');
  bool _isBestseller = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.bookId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadBook();
      });
    }
  }

  Future<void> _loadBook() async {
    final book = await ref
        .read(bookRepositoryProvider)
        .getBookById(widget.bookId!);
    if (book != null && mounted) {
      setState(() {
        _titleController.text = book.title;
        _authorController.text = book.author;
        _genreController.text = book.genre;
        _priceController.text = book.price.toStringAsFixed(0);
        _origPriceController.text =
            book.originalPrice?.toStringAsFixed(0) ?? '';
        _descController.text = book.description;
        _coverUrlController.text = book.coverUrl;
        _stockController.text = book.stockQuantity.toString();
        _publisherController.text = book.publisher;
        _pagesController.text = book.pages.toString();
        _isBestseller = book.isBestseller;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _priceController.dispose();
    _origPriceController.dispose();
    _descController.dispose();
    _coverUrlController.dispose();
    _stockController.dispose();
    _publisherController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final id =
          widget.bookId ?? 'book_${DateTime.now().millisecondsSinceEpoch}';
      final price = double.tryParse(_priceController.text) ?? 15.0;
      final origPrice = double.tryParse(_origPriceController.text);
      final stock = int.tryParse(_stockController.text) ?? 20;
      final pages = int.tryParse(_pagesController.text) ?? 300;

      final book = BookItem(
        id: id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        genre: _genreController.text.trim(),
        tags: [_genreController.text.trim()],
        description: _descController.text.trim().isNotEmpty
            ? _descController.text.trim()
            : 'An exceptional literary work offering profound insight and timeless craftsmanship.',
        coverUrl: _coverUrlController.text.trim().isNotEmpty
            ? _coverUrlController.text.trim()
            : 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=600&q=80',
        price: price,
        originalPrice: origPrice,
        rating: 4.8,
        reviewCount: 120,
        stockQuantity: stock,
        isBestseller: _isBestseller,
        pages: pages,
        publisher: _publisherController.text.trim(),
        publishedDate: DateTime.now(),
      );

      await ref.read(adminRepositoryProvider).saveBook(book);
      ref.invalidate(allBooksStreamProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book "${book.title}" saved successfully')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bookId != null;

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      appBar: PremiumAppBar(title: isEditing ? 'Edit Book' : 'Add New Book'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PremiumTextField(
                  controller: _titleController,
                  label: 'Book Title',
                  hint: 'e.g. Milk and Honey',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Title required' : null,
                ),
                const SizedBox(height: 14),
                PremiumTextField(
                  controller: _authorController,
                  label: 'Author',
                  hint: 'e.g. Rupi Kaur',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Author required' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: PremiumTextField(
                        controller: _genreController,
                        label: 'Genre',
                        hint: 'Poetry',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PremiumTextField(
                        controller: _priceController,
                        label: 'Price (\$) ',
                        hint: '18',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PremiumTextField(
                        controller: _origPriceController,
                        label: 'Original (\$)',
                        hint: '22',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                PremiumTextField(
                  controller: _coverUrlController,
                  label: 'Cover Image URL',
                  hint: 'https://...',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: PremiumTextField(
                        controller: _stockController,
                        label: 'Stock Quantity',
                        hint: '40',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PremiumTextField(
                        controller: _pagesController,
                        label: 'Page Count',
                        hint: '320',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                PremiumTextField(
                  controller: _publisherController,
                  label: 'Publisher',
                  hint: 'Andrews McMeel',
                ),
                const SizedBox(height: 14),
                PremiumTextField(
                  controller: _descController,
                  label: 'Description',
                  hint: 'Summary or editorial excerpt...',
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Switch(
                      value: _isBestseller,
                      activeThumbColor: BookstoreTokens.primary,
                      onChanged: (v) => setState(() => _isBestseller = v),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mark as Curated Bestseller',
                      style: BookstoreTokens.body(
                        fontSize: 13,
                        color: BookstoreTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                PremiumButton(
                  label: isEditing ? 'Update Book' : 'Publish Book to Catalog',
                  isLoading: _isLoading,
                  onPressed: _handleSave,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
