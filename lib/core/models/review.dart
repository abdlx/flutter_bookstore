class ReviewItem {
  final String id;
  final String bookId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String dateString;
  final String content;
  final int helpfulCount;

  const ReviewItem({
    required this.id,
    required this.bookId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.dateString,
    required this.content,
    this.helpfulCount = 0,
  });
}
