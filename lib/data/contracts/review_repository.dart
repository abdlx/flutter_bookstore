import '../../core/models/review.dart';

abstract class ReviewRepository {
  Stream<List<ReviewItem>> watchReviews(String bookId);
  Stream<bool> watchHelpfulVote(String bookId, String reviewId);
  Future<void> toggleHelpfulVote(String bookId, String reviewId);
  Future<List<ReviewItem>> getReviewsForBook(String bookId);
  Future<void> addReview({
    required String bookId,
    required String userName,
    required double rating,
    required String comment,
  });
}
