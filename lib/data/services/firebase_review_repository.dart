import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../contracts/review_repository.dart';
import '../../core/models/review.dart';

class FirebaseReviewRepository implements ReviewRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _reviewsCol(String bookId) =>
      _db.collection('books').doc(bookId).collection('reviews');

  @override
  Future<List<ReviewItem>> getReviewsForBook(String bookId) async {
    final snap = await _reviewsCol(bookId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => _reviewFromDoc(d.id, d.data())).toList();
  }

  @override
  Future<void> addReview({
    required String bookId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User not authenticated');

    final ref = _reviewsCol(bookId).doc(uid);
    final old = await ref.get();

    await ref.set({
      'userId': uid,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'likes': old.exists ? (old.data()?['likes'] ?? []) : [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _updateBookRating(bookId);
  }

  Future<void> _updateBookRating(String bookId) async {
    final snap = await _reviewsCol(bookId).get();
    if (snap.docs.isEmpty) return;
    final total = snap.docs
        .fold<double>(0, (s, d) => s + ((d.data()['rating'] ?? 0) as num));
    final avg = total / snap.docs.length;
    await _db.collection('books').doc(bookId).update({
      'rating': double.parse(avg.toStringAsFixed(1)),
      'ratingCount': snap.docs.length,
    });
  }

  ReviewItem _reviewFromDoc(String id, Map<String, dynamic> m) {
    return ReviewItem(
      id: id,
      bookId: m['bookId'] ?? '',
      userName: m['userName'] ?? 'User',
      userAvatar: m['userAvatar'] ?? '',
      rating: (m['rating'] as num?)?.toDouble() ?? 0.0,
      dateString: _formatDate((m['createdAt'] as Timestamp?)?.toDate()),
      content: m['comment'] ?? '',
      helpfulCount: (m['likes'] as List?)?.length ?? 0,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Just now';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }
}