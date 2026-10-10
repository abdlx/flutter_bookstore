import 'dart:async';

import '../../core/models/book.dart';
import '../contracts/book_repository.dart';
import 'mock_database.dart';

class MockBookRepository implements BookRepository {
  final MockDatabase _db = MockDatabase.instance;
  final StreamController<List<BookItem>> _controller =
      StreamController<List<BookItem>>.broadcast();

  MockBookRepository() {
    Timer.run(() => _controller.add(List.unmodifiable(_db.books)));
  }

  @override
  Future<List<BookItem>> getBooks() async {
    return List.unmodifiable(_db.books);
  }

  @override
  Stream<List<BookItem>> watchBooks() => _controller.stream;

  @override
  Future<BookItem?> getBookById(String id) async {
    try {
      return _db.books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<BookItem>> getRecommendedBooks() async {
    return _db.books.where((b) => b.isRecommended).toList();
  }

  @override
  Future<List<BookItem>> getBestsellers() async {
    return _db.books.where((b) => b.isBestseller).toList();
  }

  @override
  Future<List<BookItem>> getBooksByGenre(String genre) async {
    if (genre.toLowerCase() == 'all') {
      return List.unmodifiable(_db.books);
    }
    return _db.books
        .where(
          (b) =>
              b.genre.toLowerCase() == genre.toLowerCase() ||
              b.tags.any((t) => t.toLowerCase() == genre.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<List<BookItem>> searchBooks(
    String query, {
    String? genre,
    double? maxPrice,
    String? sortBy,
  }) async {
    var results = _db.books.where((b) {
      final matchesQuery =
          query.isEmpty ||
          b.title.toLowerCase().contains(query.toLowerCase()) ||
          b.author.toLowerCase().contains(query.toLowerCase()) ||
          b.genre.toLowerCase().contains(query.toLowerCase());

      final matchesGenre =
          genre == null ||
          genre.toLowerCase() == 'all' ||
          b.genre.toLowerCase() == genre.toLowerCase() ||
          b.tags.any((t) => t.toLowerCase() == genre.toLowerCase());

      final matchesPrice = maxPrice == null || b.price <= maxPrice;

      return matchesQuery && matchesGenre && matchesPrice;
    }).toList();

    if (sortBy != null) {
      switch (sortBy) {
        case 'price_low':
          results.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          results.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'rating':
          results.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'popular':
        default:
          results.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
          break;
      }
    }

    return results;
  }

  @override
  Future<void> addBook(BookItem book) async {
    _db.books.insert(0, book);
    _controller.add(List.unmodifiable(_db.books));
  }

  @override
  Future<void> updateBook(BookItem book) async {
    final index = _db.books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      _db.books[index] = book;
      _controller.add(List.unmodifiable(_db.books));
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    _db.books.removeWhere((b) => b.id == id);
    _controller.add(List.unmodifiable(_db.books));
  }
}
