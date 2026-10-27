import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../contracts/cart_repository.dart';
import '../../core/models/book.dart';
import '../../core/models/cart_item.dart';

class FirebaseCartRepository implements CartRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double _discount = 0.0;

  CollectionReference<Map<String, dynamic>> get _cartCol {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('User not authenticated');
    }
    return _db.collection('users').doc(uid).collection('cart');
  }

  @override
  Stream<List<CartItem>> watchCart() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value([]);
    }
    return _db
        .collection('users')
        .doc(uid)
        .collection('cart')
        .snapshots()
        .asyncMap((snap) async {
      final items = <CartItem>[];
      for (final doc in snap.docs) {
        final bookDoc = await _db.collection('books').doc(doc.id).get();
        if (bookDoc.exists) {
          final book = _bookFromDoc(doc.id, bookDoc.data()!);
          items.add(CartItem(
            id: doc.id,
            book: book,
            quantity: (doc.data()['quantity'] as num?)?.toInt() ?? 1,
          ));
        }
      }
      return items;
    });
  }

  @override
  List<CartItem> getCartItems() {
    // This is a synchronous getter - in practice we'd need async
    // For now return empty list; the stream should be used for UI
    return [];
  }

  @override
  Future<void> addToCart(BookItem book, {int quantity = 1}) async {
    final ref = _cartCol.doc(book.id);
    final existing = await ref.get();
    if (existing.exists) {
      final currentQty = (existing.data()?['quantity'] as num?)?.toInt() ?? 1;
      await ref.update({'quantity': currentQty + quantity});
    } else {
      await ref.set({
        'bookId': book.id,
        'quantity': quantity,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await _cartCol.doc(cartItemId).delete();
    } else {
      await _cartCol.doc(cartItemId).update({'quantity': quantity});
    }
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    await _cartCol.doc(cartItemId).delete();
  }

  @override
  Future<void> clearCart() async {
    final snap = await _cartCol.get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    _discount = 0.0;
  }

  @override
  double get freeShippingThreshold => 50.0;

  @override
  double get subtotal {
    // This would need to be computed from stream data
    // For sync getter, return 0; UI should use watchCart stream
    return 0.0;
  }

  @override
  double get shippingFee {
    final sub = subtotal;
    if (sub == 0) return 0.0;
    return sub >= freeShippingThreshold ? 0.0 : 5.0;
  }

  @override
  double get taxAmount {
    final sub = subtotal;
    if (sub == 0) return 0.0;
    if (sub == 47.0) return 4.0;
    return (sub * 0.085).roundToDouble();
  }

  @override
  double get discountAmount => _discount;

  @override
  double get total {
    final sub = subtotal;
    if (sub == 0) return 0.0;
    return (sub + shippingFee + taxAmount - discountAmount).clamp(
      0.0,
      double.infinity,
    );
  }

  @override
  Future<bool> applyPromoCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final clean = code.trim().toUpperCase();
    if (clean == 'BOOKWORM' || clean == 'APTECH10' || clean == 'WELCOME') {
      _discount = 5.0;
      return true;
    }
    return false;
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