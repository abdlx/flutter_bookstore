import 'package:flutter_test/flutter_test.dart';
import 'package:bookstore_app/core/models/book.dart';
import 'package:bookstore_app/data/firestore/firestore_book_repository.dart';
import 'package:bookstore_app/data/firestore/firestore_codec.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

BookItem fixture(
  String id,
  String title,
  String author,
  String genre,
  double price,
) => BookItem(
  id: id,
  title: title,
  author: author,
  genre: genre,
  description: '',
  coverUrl: '',
  price: price,
  publishedDate: DateTime(2026),
);
void main() {
  final books = [
    fixture('a', 'River', 'Ada', 'Fiction', 19.99),
    fixture('b', 'Mountain', 'Lin', 'Travel', 49.99),
    fixture('c', 'Sky', 'Ada', 'Fiction', 59.99),
  ];
  test(
    'search combines author, genre and maximum price and preserves cents',
    () {
      final results = filterBooks(
        books,
        ' ADA ',
        genre: 'Fiction',
        maxPrice: 50,
        sortBy: 'price_low',
      );
      expect(results.map((b) => b.id), ['a']);
      expect(results.single.price, 19.99);
      expect(filterBooks(books, 'unknown'), isEmpty);
      expect(filterBooks(books, '', sortBy: 'price_high').map((b) => b.id), [
        'c',
        'b',
        'a',
      ]);
    },
  );
  test('Firestore document identity and timestamp override payload fields', () {
    final b = readBook('actual', {
      ...books.first.toMap(),
      'id': 'wrong',
      'publishedDate': Timestamp.fromDate(DateTime(2026, 4, 2)),
    });
    expect(b.id, 'actual');
    expect(b.publishedDate, DateTime(2026, 4, 2));
  });
  test('rating distribution round-trips with Firestore string keys', () {
    final b = books.first.copyWith(ratingBreakdown: {5: 0.75, 4: 0.25});
    expect(BookItem.fromMap(b.toMap()).ratingBreakdown, b.ratingBreakdown);
    expect(books.first.ratingBreakdown, isEmpty);
    expect(books.first.stockQuantity, 0);
  });
}
