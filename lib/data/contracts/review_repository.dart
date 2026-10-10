import '../../core/models/review.dart';

abstract class ReviewRepository {
  Future<List<ReviewItem>> getReviewsForBook(String bookId);
  Future<void> addReview({
    required String bookId,
    required String userName,
    required double rating,
    required String comment,
  });
}
