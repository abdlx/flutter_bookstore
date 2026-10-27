import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../contracts/wishlist_repository.dart';
import '../../core/models/book.dart';

class FirebaseWishlistRepository implements WishlistRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _wishlistCol {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('User not authenticated');
    }
    return _db.collection('wishlists').doc(uid).collection('books');
  }

  @override
  Stream<List<BookItem>> watchWishlist() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value([]);
    }
    return _db
        .collection('wishlists')
        .doc(uid)
        .collection('books')
        .snapshots()
        .asyncMap((snap) async {
      final items = <BookItem>[];
      for (final doc in snap.docs) {
        final bookDoc = await _db.collection('books').doc(doc.id).get();
        if (bookDoc.exists) {
          items.add(_bookFromDoc(doc.id, bookDoc.data()!));
        }
      }
      return items;
    });
  }

  @override
  List<BookItem> getWishlistItems() {
    return [];
  }

  @override
  bool isInWishlist(String bookId) {
    return false;
  }

  @override
  Future<void> toggleWishlist(BookItem book) async {
    final ref = _wishlistCol.doc(book.id);
    final existing = await ref.get();
    if (existing.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'bookId': book.id,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> removeFromWishlist(String bookId) async {
    await _wishlistCol.doc(bookId).delete();
  }

  BookItem _bookFromDoc(String id, Map<String, dynamic> m) {
    return BookItem(
      id: id,
      title: m['title'] ?? '',
      author: m['author'] ?? '',
      genre: m['genre'] ?? '',
      tags: List<String>.from(m['tags'] ?? []),
      description: m['description'] ?? '',
      coverUrl: m['coverUrl'] ?? '',
      price: (m['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (m['originalPrice'] as num?)?.toDouble(),
      rating: (m['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (m['reviewCount'] as num?)?.toInt() ?? 0,
      ratingBreakdown: _parseRatingBreakdown(m['ratingBreakdown']),
      isBestseller: m['isBestseller'] ?? false,
      isRecommended: m['isRecommended'] ?? false,
      format: m['format'] ?? 'Paperback',
      pages: (m['pages'] as num?)?.toInt() ?? 320,
      language: m['language'] ?? 'English',
      publisher: m['publisher'] ?? '',
      stockQuantity: (m['stockQuantity'] as num?)?.toInt() ?? 0,
      publishedDate: m['publishedDate'] != null
          ? DateTime.tryParse(m['publishedDate']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<int, double> _parseRatingBreakdown(dynamic data) {
    if (data == null) {
      return const {5: 0.82, 4: 0.12, 3: 0.04, 2: 0.01, 1: 0.01};
    }
    if (data is Map) {
      return data.map((k, v) => MapEntry(int.parse(k.toString()), (v as num).toDouble()));
    }
    return const {5: 0.82, 4: 0.12, 3: 0.04, 2: 0.01, 1: 0.01};
  }
}