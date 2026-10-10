import '../../core/models/review.dart';
import '../contracts/review_repository.dart';
import 'mock_database.dart';

class MockReviewRepository implements ReviewRepository {
  final MockDatabase _db = MockDatabase.instance;

  @override
  Future<List<ReviewItem>> getReviewsForBook(String bookId) async {
    return _db.reviews.where((r) => r.bookId == bookId).toList();
  }

  @override
  Future<void> addReview({
    required String bookId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    final newReview = ReviewItem(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      bookId: bookId,
      userName: userName,
      userAvatar: _db.currentUser.avatarUrl ?? '',
      rating: rating,
      dateString: 'Just now',
      content: comment,
      helpfulCount: 0,
    );
    _db.reviews.insert(0, newReview);
  }
}
