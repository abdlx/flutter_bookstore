import 'dart:async';

import '../../core/models/book.dart';
import '../contracts/wishlist_repository.dart';
import 'mock_database.dart';

class MockWishlistRepository implements WishlistRepository {
  final MockDatabase _db = MockDatabase.instance;
  final StreamController<List<BookItem>> _controller =
      StreamController<List<BookItem>>.broadcast();

  MockWishlistRepository() {
    Timer.run(() => _controller.add(List.unmodifiable(_db.wishlist)));
  }

  @override
  Stream<List<BookItem>> watchWishlist() => _controller.stream;

  @override
  List<BookItem> getWishlistItems() => List.unmodifiable(_db.wishlist);

  @override
  bool isInWishlist(String bookId) {
    return _db.wishlist.any((b) => b.id == bookId);
  }

  @override
  Future<void> toggleWishlist(BookItem book) async {
    final exists = isInWishlist(book.id);
    if (exists) {
      _db.wishlist.removeWhere((b) => b.id == book.id);
    } else {
      _db.wishlist.insert(0, book);
    }
    _controller.add(List.unmodifiable(_db.wishlist));
  }

  @override
  Future<void> removeFromWishlist(String bookId) async {
    _db.wishlist.removeWhere((b) => b.id == bookId);
    _controller.add(List.unmodifiable(_db.wishlist));
  }
}
