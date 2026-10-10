import '../../core/models/book.dart';

abstract class WishlistRepository {
  Stream<List<BookItem>> watchWishlist();
  List<BookItem> getWishlistItems();
  bool isInWishlist(String bookId);
  Future<void> toggleWishlist(BookItem book);
  Future<void> removeFromWishlist(String bookId);
}
