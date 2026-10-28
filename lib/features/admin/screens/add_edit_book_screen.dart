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
  final _genreController = TextEditingController();
  final _priceController = TextEditingController();
  final _origPriceController = TextEditingController();
  final _descController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _stockController = TextEditingController();
  final _publisherController = TextEditingController();
  final _pagesController = TextEditingController();
  final _formatController = TextEditingController();
  final _languageController = TextEditingController();
  final _publishedDateController = TextEditingController();
  BookItem? _existingBook;
  bool _isRecommended = false;
  bool _loadingBook = false;
  String? _loadError;
  bool _isBestseller = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.bookId != null) {
      _loadingBook = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadBook();
      });
    }
  }

  Future<void> _loadBook() async {
    try {
      final book = await ref
          .read(bookRepositoryProvider)
          .getBookById(widget.bookId!);
      if (book != null && mounted) {
        setState(() {
          _existingBook = book;
          _titleController.text = book.title;
          _authorController.text = book.author;
          _genreController.text = book.genre;
          _priceController.text = book.price.toStringAsFixed(2);
          _origPriceController.text =
              book.originalPrice?.toStringAsFixed(2) ?? '';
          _descController.text = book.description;
          _coverUrlController.text = book.coverUrl;
          _stockController.text = book.stockQuantity.toString();
          _publisherController.text = book.publisher;
          _pagesController.text = book.pages.toString();
          _formatController.text = book.format;
          _languageController.text = book.language;
          _publishedDateController.text = book.publishedDate.year > 1970
              ? book.publishedDate.toIso8601String().split('T').first
              : '';
          _isBestseller = book.isBestseller;
          _isRecommended = book.isRecommended;
        });
      } else {
        throw StateError('Book not found.');
      }
    } catch (e) {
      if (mounted) setState(() => _loadError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingBook = false);
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
    _formatController.dispose();
    _languageController.dispose();
    _publishedDateController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final id =
          widget.bookId ??
          ref.read(firebaseFirestoreProvider).collection('books').doc().id;
      final price = double.parse(_priceController.text);
      final origPrice = double.tryParse(_origPriceController.text);
      final stock = int.parse(_stockController.text);
      final pages = int.parse(_pagesController.text);

      final book = BookItem(
        id: id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        genre: _genreController.text.trim(),
        tags: {...?_existingBook?.tags, _genreController.text.trim()}.toList(),
        description: _descController.text.trim(),
        coverUrl: _coverUrlController.text.trim(),
        price: price,
        originalPrice: origPrice,
        rating: _existingBook?.rating ?? 0,
        reviewCount: _existingBook?.reviewCount ?? 0,
        isRecommended: _isRecommended,
        format: _formatController.text.trim(),
        language: _languageController.text.trim(),
        stockQuantity: stock,
        isBestseller: _isBestseller,
        pages: pages,
        publisher: _publisherController.text.trim(),
        publishedDate:
            DateTime.tryParse(_publishedDateController.text.trim()) ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );

      await ref.read(adminRepositoryProvider).saveBook(book);
      ref.invalidate(allBooksStreamProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book "${book.title}" saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Unable to save: $e')));
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
      body: _loadingBook
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(child: Text(_loadError!))
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
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
                              validator: (v) {
                                final n = double.tryParse(v ?? '');
                                return n == null || !n.isFinite || n < 0
                                    ? 'Enter a valid price'
                                    : null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PremiumTextField(
                              controller: _origPriceController,
                              validator: (v) {
                                if (v == null || v.isEmpty) return null;
                                final n = double.tryParse(v);
                                return n == null || !n.isFinite || n < 0
                                    ? 'Invalid price'
                                    : null;
                              },
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
                              validator: (v) =>
                                  int.tryParse(v ?? '') == null ||
                                      int.parse(v!) < 0
                                  ? 'Enter a positive whole number'
                                  : null,
                              label: 'Stock Quantity',
                              hint: '40',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PremiumTextField(
                              controller: _pagesController,
                              validator: (v) =>
                                  int.tryParse(v ?? '') == null ||
                                      int.parse(v!) < 0
                                  ? 'Enter a positive whole number'
                                  : null,
                              label: 'Page Count',
                              hint: '320',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      PremiumTextField(
                        controller: _formatController,
                        label: 'Format',
                        hint: 'Paperback, Hardcover, ...',
                      ),
                      const SizedBox(height: 14),
                      PremiumTextField(
                        controller: _languageController,
                        label: 'Language',
                      ),
                      const SizedBox(height: 14),
                      PremiumTextField(
                        controller: _publisherController,
                        label: 'Publisher',
                        hint: 'Andrews McMeel',
                      ),
                      const SizedBox(height: 14),
                      PremiumTextField(
                        controller: _publishedDateController,
                        label: 'Publication Date',
                        hint: 'YYYY-MM-DD (optional)',
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return null;
                          final parsed = DateTime.tryParse(text);
                          return parsed == null ||
                                  parsed.toIso8601String().split('T').first !=
                                      text
                              ? 'Use YYYY-MM-DD'
                              : null;
                        },
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
                      SwitchListTile(
                        value: _isRecommended,
                        onChanged: (v) => setState(() => _isRecommended = v),
                        title: const Text('Recommend on the home page'),
                      ),
                      const SizedBox(height: 28),
                      PremiumButton(
                        label: isEditing
                            ? 'Update Book'
                            : 'Publish Book to Catalog',
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
