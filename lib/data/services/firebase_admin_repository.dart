import 'package:cloud_firestore/cloud_firestore.dart';

import '../contracts/admin_repository.dart';
import '../../core/models/address.dart';
import '../../core/models/book.dart';
import '../../core/models/cart_item.dart';
import '../../core/models/order.dart';
import '../../core/models/payment_method.dart';
import '../../core/models/user_profile.dart';

class FirebaseAdminRepository implements AdminRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<AdminDashboardStats> getDashboardStats() async {
    final booksSnap = await _db.collection('books').get();
    final ordersSnap = await _db.collection('orders').get();
    final usersSnap = await _db.collection('users').get();

    final revenue = ordersSnap.docs.fold<double>(
      0.0,
      (total, d) => total + ((d.data()['total'] as num?)?.toDouble() ?? 0.0),
    );

    return AdminDashboardStats(
      totalRevenue: revenue,
      totalOrders: ordersSnap.docs.length,
      totalBooks: booksSnap.docs.length,
      totalUsers: usersSnap.docs.length,
      growthRate: 18.4,
    );
  }

  @override
  Future<List<OrderItem>> getAllOrders() async {
    final snap = await _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => _orderFromDoc(d.id, d.data())).toList();
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status.name,
    });
  }

  @override
  Future<List<UserProfile>> getAllUsers() async {
    final snap = await _db.collection('users').get();
    return snap.docs.map((d) => _userFromDoc(d.id, d.data())).toList();
  }

  @override
  Future<void> updateUserRole(String userId, UserRole role) async {
    await _db.collection('users').doc(userId).update({
      'role': role == UserRole.admin ? 'admin' : 'user',
    });
  }

  @override
  Future<List<BookItem>> getAllBooks() async {
    final snap = await _db.collection('books').get();
    return snap.docs.map((d) => _bookFromDoc(d.id, d.data())).toList();
  }

  @override
  Future<void> saveBook(BookItem book) async {
    if (book.id.isEmpty) {
      await _db.collection('books').add(_bookToMap(book));
    } else {
      await _db.collection('books').doc(book.id).set(_bookToMap(book));
    }
  }

  @override
  Future<void> deleteBook(String bookId) async {
    await _db.collection('books').doc(bookId).delete();
  }

  UserProfile _userFromDoc(String id, Map<String, dynamic> m) {
    return UserProfile(
      id: id,
      fullName: m['name'] ?? '',
      email: m['email'] ?? '',
      phone: m['phone'],
      avatarUrl: m['avatarUrl'],
      role: m['role'] == 'admin' ? UserRole.admin : UserRole.customer,
      membershipTier: m['membershipTier'] ?? 'Gold Member',
      memberSince: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
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

  Map<String, dynamic> _bookToMap(BookItem book) {
    return {
      'title': book.title,
      'author': book.author,
      'genre': book.genre,
      'tags': book.tags,
      'description': book.description,
      'coverUrl': book.coverUrl,
      'price': book.price,
      'originalPrice': book.originalPrice,
      'rating': book.rating,
      'reviewCount': book.reviewCount,
      'ratingBreakdown': book.ratingBreakdown,
      'isBestseller': book.isBestseller,
      'isRecommended': book.isRecommended,
      'format': book.format,
      'pages': book.pages,
      'language': book.language,
      'publisher': book.publisher,
      'stockQuantity': book.stockQuantity,
      'publishedDate': book.publishedDate.toIso8601String(),
    };
  }

  OrderItem _orderFromDoc(String id, Map<String, dynamic> m) {
    final items = (m['items'] as List? ?? [])
        .map((e) {
          final map = Map<String, dynamic>.from(e);
          return CartItem(
            id: map['bookId'] ?? '',
            book: BookItem(
              id: map['bookId'] ?? '',
              title: map['title'] ?? '',
              author: '',
              genre: '',
              description: '',
              coverUrl: map['coverUrl'] ?? '',
              price: (map['price'] as num?)?.toDouble() ?? 0.0,
              publishedDate: DateTime.now(),
            ),
            quantity: (map['quantity'] as num?)?.toInt() ?? 1,
          );
        })
        .toList();

    final shippingAddr = m['shippingAddress'] as Map<String, dynamic>?;
    final paymentMeth = m['paymentMethod'] as Map<String, dynamic>?;

    return OrderItem(
      id: id,
      orderNumber: m['orderNumber'] ?? '',
      items: items,
      subtotal: (m['subtotal'] as num?)?.toDouble() ?? 0.0,
      shipping: (m['shipping'] as num?)?.toDouble() ?? 0.0,
      tax: (m['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (m['discount'] as num?)?.toDouble() ?? 0.0,
      total: (m['total'] as num?)?.toDouble() ?? 0.0,
      status: _parseOrderStatus(m['status'] as String?),
      shippingAddress: shippingAddr != null
          ? AddressItem(
              id: '',
              label: shippingAddr['label'] ?? '',
              recipientName: shippingAddr['recipientName'] ?? '',
              phone: shippingAddr['phone'] ?? '',
              street: shippingAddr['street'] ?? '',
              city: shippingAddr['city'] ?? '',
              state: shippingAddr['state'] ?? '',
              postalCode: shippingAddr['postalCode'] ?? '',
              country: shippingAddr['country'] ?? 'United States',
              isDefault: shippingAddr['isDefault'] ?? false,
            )
          : AddressItem(
              id: '',
              label: 'Home',
              recipientName: '',
              phone: '',
              street: '',
              city: '',
              state: '',
              postalCode: '',
            ),
      paymentMethod: paymentMeth != null
          ? PaymentMethodItem(
              id: '',
              type: paymentMeth['type'] ?? 'card',
              title: paymentMeth['title'] ?? '',
              subtitle: paymentMeth['subtitle'] ?? '',
              last4: paymentMeth['last4'],
              brand: paymentMeth['brand'],
              expiry: paymentMeth['expiry'],
              isDefault: paymentMeth['isDefault'] ?? false,
            )
          : PaymentMethodItem(
              id: '',
              type: 'card',
              title: 'Visa',
              subtitle: '****',
            ),
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      trackingSteps: (m['trackingSteps'] as List? ?? [])
          .map((e) {
            final map = Map<String, dynamic>.from(e);
            return TrackingStep(
              title: map['title'] ?? '',
              description: map['description'] ?? '',
              time: (map['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
              isCompleted: map['isCompleted'] ?? false,
            );
          })
          .toList(),
    );
  }

  OrderStatus _parseOrderStatus(String? status) {
    switch (status) {
      case 'placed':
        return OrderStatus.placed;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.placed;
    }
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