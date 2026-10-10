import '../../core/models/book.dart';

abstract class BookRepository {
  Future<List<BookItem>> getBooks();
  Stream<List<BookItem>> watchBooks();
  Future<BookItem?> getBookById(String id);
  Future<List<BookItem>> getRecommendedBooks();
  Future<List<BookItem>> getBestsellers();
  Future<List<BookItem>> getBooksByGenre(String genre);
  Future<List<BookItem>> searchBooks(
    String query, {
    String? genre,
    double? maxPrice,
    String? sortBy,
  });
  Future<void> addBook(BookItem book);
  Future<void> updateBook(BookItem book);
  Future<void> deleteBook(String id);
}
