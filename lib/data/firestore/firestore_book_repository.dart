import 'catalog_queries.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/models/book.dart';
import '../contracts/book_repository.dart';
import 'firestore_codec.dart';

List<BookItem> filterBooks(
  List<BookItem> books,
  String query, {
  String? genre,
  double? maxPrice,
  String? sortBy,
}) {
  final q = query.trim().toLowerCase();
  final result = books
      .where(
        (b) =>
            (q.isEmpty ||
                '${b.title} ${b.author} ${b.genre} ${b.tags.join(' ')}'
                    .toLowerCase()
                    .contains(q)) &&
            (genre == null || genre == 'All' || b.genre == genre) &&
            (maxPrice == null || b.price <= maxPrice),
      )
      .toList();
  switch (sortBy) {
    case 'price_low':
      result.sort((a, b) => a.price.compareTo(b.price));
    case 'price_high':
      result.sort((a, b) => b.price.compareTo(a.price));
    case 'rating':
      result.sort((a, b) => b.rating.compareTo(a.rating));
    case 'newest':
      result.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
    default:
      result.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
  }
  return result;
}

class FirestoreBookRepository implements BookRepository {
  final FirebaseFirestore db;
  FirestoreBookRepository(this.db);
  CollectionReference<Map<String, dynamic>> get collection =>
      db.collection('books');
  @override
  Future<List<BookItem>> getBooks() async => (await collection.get()).docs
      .map((d) => readBook(d.id, d.data()))
      .toList();
  @override
  Stream<List<BookItem>> watchBooks() => collection.snapshots().map(
    (s) => s.docs.map((d) => readBook(d.id, d.data())).toList(),
  );
  @override
  Future<BookItem?> getBookById(String id) async {
    final doc = await collection.doc(id).get();
    return doc.exists ? readBook(doc.id, doc.data()!) : null;
  }

  @override
  Future<List<BookItem>> getRecommendedBooks() async =>
      (await getBooks()).where((b) => b.isRecommended).toList();
  @override
  Future<List<BookItem>> getBestsellers() async =>
      (await getBooks()).where((b) => b.isBestseller).toList();
  @override
  Future<List<BookItem>> getBooksByGenre(String genre) async =>
      filterBooks(await getBooks(), '', genre: genre);
  @override
  Future<List<BookItem>> searchBooks(
    String query, {
    String? genre,
    double? maxPrice,
    String? sortBy,
  }) async => filterBooks(
    await getBooks(),
    query,
    genre: genre,
    maxPrice: maxPrice,
    sortBy: sortBy,
  );
  @override
  Future<void> addBook(BookItem book) => saveCatalogBook(db, book);
  @override
  Future<void> updateBook(BookItem book) => saveCatalogBook(db, book);
  @override
  Future<void> deleteBook(String id) => deleteCatalogBook(db, id);
}
