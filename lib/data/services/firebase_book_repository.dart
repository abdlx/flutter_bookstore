import 'package:cloud_firestore/cloud_firestore.dart';

import '../contracts/book_repository.dart';
import '../../core/models/book.dart';

class FirebaseBookRepository implements BookRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('books');

  @override
  Future<List<BookItem>> getBooks() async {
    final snap = await _col.get();
    return snap.docs.map((d) => _bookFromDoc(d)).toList();
  }

  @override
  Stream<List<BookItem>> watchBooks() {
    return _col.snapshots().map(
      (s) => s.docs.map((d) => _bookFromDoc(d)).toList(),
    );
  }

  @override
  Future<BookItem?> getBookById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return _bookFromDoc(doc);
  }

  @override
  Future<List<BookItem>> getRecommendedBooks() async {
    final snap = await _col.where('isRecommended', isEqualTo: true).get();
    return snap.docs.map((d) => _bookFromDoc(d)).toList();
  }

  @override
  Future<List<BookItem>> getBestsellers() async {
    final snap = await _col.where('isBestseller', isEqualTo: true).get();
    return snap.docs.map((d) => _bookFromDoc(d)).toList();
  }

  @override
  Future<List<BookItem>> getBooksByGenre(String genre) async {
    if (genre.toLowerCase() == 'all') {
      return getBooks();
    }
    final snap = await _col
        .where('genre', isEqualTo: genre)
        .get();
    return snap.docs.map((d) => _bookFromDoc(d)).toList();
  }

  @override
  Future<List<BookItem>> searchBooks(
    String query, {
    String? genre,
    double? maxPrice,
    String? sortBy,
  }) async {
    Query<Map<String, dynamic>> queryRef = _col;

    if (genre != null && genre.toLowerCase() != 'all') {
      queryRef = queryRef.where('genre', isEqualTo: genre);
    }

    final snap = await queryRef.get();
    var results = snap.docs.map((d) => _bookFromDoc(d)).toList();

    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      results = results.where((b) {
        return b.title.toLowerCase().contains(lowerQuery) ||
            b.author.toLowerCase().contains(lowerQuery) ||
            b.genre.toLowerCase().contains(lowerQuery) ||
            b.tags.any((t) => t.toLowerCase().contains(lowerQuery));
      }).toList();
    }

    if (maxPrice != null) {
      results = results.where((b) => b.price <= maxPrice).toList();
    }

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
    await _col.add(_bookToMap(book));
  }

  @override
  Future<void> updateBook(BookItem book) async {
    await _col.doc(book.id).update(_bookToMap(book));
  }

  @override
  Future<void> deleteBook(String id) async {
    await _col.doc(id).delete();
  }

  BookItem _bookFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data()!;
    return BookItem(
      id: doc.id,
      title: m['title'] ?? '',
      author: m['author'] ?? '',
      genre: m['genre'] ?? '',
      tags: List<String>.from(m['tags'] ?? []),
      description: m['description'] ?? '',
      coverUrl: m['coverUrl'] ?? '',
      price: (m['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (m['originalPrice'] as num?)?.toDouble(),
      rating: (m['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (m['reviewCount'] as num?)?.toInt() ?? 0,
      ratingBreakdown: _parseRatingBreakdown(m['ratingBreakdown']),
      isBestseller: m['isBestseller'] ?? false,
      isRecommended: m['isRecommended'] ?? false,
      format: m['format'] ?? 'Paperback',
      pages: (m['pages'] as num?)?.toInt() ?? 320,
      language: m['language'] ?? 'English',
      publisher: m['publisher'] ?? '',
      stockQuantity: (m['stockQuantity'] as num?)?.toInt() ?? 0,
      publishedDate: m['publishedDate'] != null
          ? DateTime.tryParse(m['publishedDate']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> _bookToMap(BookItem book) {
    return {
      'title': book.title,
      'author': book.author,
      'genre': book.genre,
      'tags': book.tags,
      'description': book.description,
      'coverUrl': book.coverUrl,
      'price': book.price,
      'originalPrice': book.originalPrice,
      'rating': book.rating,
      'reviewCount': book.reviewCount,
      'ratingBreakdown': book.ratingBreakdown,
      'isBestseller': book.isBestseller,
      'isRecommended': book.isRecommended,
      'format': book.format,
      'pages': book.pages,
      'language': book.language,
      'publisher': book.publisher,
      'stockQuantity': book.stockQuantity,
      'publishedDate': book.publishedDate.toIso8601String(),
    };
  }

  Map<int, double> _parseRatingBreakdown(dynamic data) {
    if (data == null) {
      return const {5: 0.82, 4: 0.12, 3: 0.04, 2: 0.01, 1: 0.01};
    }
    if (data is Map) {
      return data.map((k, v) => MapEntry(int.parse(k.toString()), (v as num).toDouble()));
    }
    return const {5: 0.82, 4: 0.12, 3: 0.04, 2: 0.01, 1: 0.01};
  }
}