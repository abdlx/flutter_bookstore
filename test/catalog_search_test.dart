import 'package:bookstore_app/data/mock/mock_book_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Catalog Search & Filter Tests', () {
    late MockBookRepository bookRepo;

    setUp(() {
      bookRepo = MockBookRepository();
    });

    test('Searches by book title', () async {
      final results = await bookRepo.searchBooks('Alchemist');
      expect(results.length, 1);
      expect(results.first.title, 'The Alchemist');
    });

    test('Searches by author name', () async {
      final results = await bookRepo.searchBooks('Rupi Kaur');
      expect(results.length, 1);
      expect(results.first.title, 'Milk and Honey');
    });

    test('Filters by genre', () async {
      final results = await bookRepo.searchBooks('', genre: 'Fantasy');
      expect(
        results.every(
          (b) => b.genre == 'Fantasy' || b.tags.contains('Fantasy'),
        ),
        true,
      );
    });

    test('Filters by maximum price', () async {
      final results = await bookRepo.searchBooks('', maxPrice: 15.0);
      expect(results.every((b) => b.price <= 15.0), true);
    });

    test('Sorts by price ascending', () async {
      final results = await bookRepo.searchBooks('', sortBy: 'price_low');
      for (int i = 0; i < results.length - 1; i++) {
        expect(results[i].price <= results[i + 1].price, true);
      }
    });
  });
}
