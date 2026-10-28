import 'catalog_queries.dart';

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/models/address.dart';
import '../../core/models/book.dart';
import '../../core/models/cart_item.dart';
import '../../core/models/order.dart';
import '../../core/models/payment_method.dart';
import '../../core/models/review.dart';
import '../../core/models/user_profile.dart';
import '../contracts/admin_repository.dart';
import '../contracts/order_repository.dart';
import '../contracts/review_repository.dart';
import 'firestore_book_repository.dart';
import 'firestore_codec.dart';
import 'firestore_customer_repositories.dart';

class FirestoreOrderRepository implements OrderRepository {
  final CustomerStore store;
  final FirestoreCartRepository cart;
  String? _checkoutKey;
  FirestoreOrderRepository(this.store, this.cart);
  Query<Map<String, dynamic>> get query =>
      store.db.collection('orders').where('userId', isEqualTo: store.uid);
  List<OrderItem> _read(QuerySnapshot<Map<String, dynamic>> s) =>
      s.docs.map((d) => readOrder(d.id, d.data())).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  @override
  Stream<List<OrderItem>> watchOrders() =>
      store.uid == null ? Stream.value([]) : query.snapshots().map(_read);
  @override
  Future<List<OrderItem>> getOrders() async =>
      store.uid == null ? [] : _read(await query.get());
  @override
  Future<OrderItem?> getOrderById(String id) async {
    final d = await store.db.collection('orders').doc(id).get();
    return d.exists ? readOrder(d.id, d.data()!) : null;
  }

  @override
  Future<OrderItem> createOrder({
    required List<CartItem> items,
    required AddressItem shippingAddress,
    required PaymentMethodItem paymentMethod,
    required double subtotal,
    required double shipping,
    required double tax,
    required double discount,
    required double total,
  }) async {
    final user = store.user;
    _checkoutKey ??= store.db.collection('orders').doc().id;
    final orderRef = store.db.collection('orders').doc(_checkoutKey);
    final promoCode = cart.promoCode;
    final rows = await store.collection('cart').get();
    await store.db.runTransaction((tx) async {
      final existing = await tx.get(orderRef);
      if (existing.exists) return;
      if (rows.docs.isEmpty || rows.docs.length > 5) {
        throw StateError(
          'Checkout accepts one to five different titles per order. Adjust your cart and try again.',
        );
      }
      final address = await tx.get(
        user.collection('addresses').doc(shippingAddress.id),
      );
      final payment = await tx.get(
        user.collection('paymentMethods').doc(paymentMethod.id),
      );
      final settings = await tx.get(store.db.doc('settings/store'));
      final promo = promoCode == null
          ? null
          : await tx.get(store.db.collection('promotions').doc(promoCode));
      if (!address.exists ||
          !payment.exists ||
          payment.data()!['type'] != 'cod') {
        throw StateError(
          'Select a saved delivery address and cash on delivery.',
        );
      }
      if (!settings.exists) {
        throw StateError('Store shipping and tax settings are unavailable.');
      }
      if (promoCode != null && promo?.exists != true) {
        throw StateError('This promotion is unavailable.');
      }
      final rawItems = <Map<String, dynamic>>[];
      final books = <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final row in rows.docs) {
        final c = await tx.get(row.reference);
        final b = await tx.get(store.db.collection('books').doc(row.id));
        if (!c.exists || !b.exists) {
          throw StateError('Your cart changed. Please check it and try again.');
        }
        final q = (c.data()!['quantity'] as num).toInt();
        if (q < 1 || q > (b.data()!['stockQuantity'] as num)) {
          throw StateError('Not enough stock for ${b.data()!['title']}.');
        }
        books.add(b);
        rawItems.add({'bookId': row.id, 'quantity': q, 'book': b.data()!});
      }
      final prices = calculateOrderTotals(
        rawItems,
        settings.data()!,
        promo?.data(),
      );
      if ((prices['total']! * 100).round() != (total * 100).round() ||
          (prices['subtotal']! * 100).round() != (subtotal * 100).round()) {
        throw StateError(
          'Prices or fees changed. Review the updated cart before placing your order.',
        );
      }
      tx.set(orderRef, {
        'userId': store.uid,
        'orderNumber': orderRef.id
            .substring(orderRef.id.length - 12)
            .toUpperCase(),
        'items': rawItems,
        'itemIndex': {
          for (var i = 0; i < rawItems.length; i++) rawItems[i]['bookId']: i,
        },
        ...prices,
        'addressId': address.id,
        'shippingAddress': address.data(),
        'paymentMethodId': payment.id,
        'paymentMethod': payment.data(),
        'promoCode': promoCode,
        'status': 'placed',
        'paymentStatus': 'unpaid',
        'createdAt': FieldValue.serverTimestamp(),
        'statusHistory': {'placed': FieldValue.serverTimestamp()},
      });
      for (var i = 0; i < books.length; i++) {
        tx.update(books[i].reference, {
          'stockQuantity':
              (books[i].data()!['stockQuantity'] as num).toInt() -
              (rawItems[i]['quantity'] as int),
          'lastOrderId': orderRef.id,
        });
        tx.delete(rows.docs[i].reference);
      }
    });
    final receipt = await getOrderById(orderRef.id);
    if (receipt == null) {
      throw StateError('Check My Orders before retrying this checkout.');
    }
    _checkoutKey = null;
    return receipt;
  }

  @override
  Future<void> updateOrderStatus(String id, OrderStatus status) =>
      setOrderStatus(store.db, id, status);
}

Future<void> setOrderStatus(
  FirebaseFirestore db,
  String id,
  OrderStatus status,
) async {
  const transitions = {
    'placed': ['confirmed', 'cancelled'],
    'confirmed': ['processing', 'cancelled'],
    'processing': ['shipped', 'cancelled'],
    'shipped': ['delivered'],
    'delivered': <String>[],
    'cancelled': <String>[],
  };
  await db.runTransaction((tx) async {
    final order = await tx.get(db.collection('orders').doc(id));
    if (!order.exists) throw StateError('Order not found.');
    final data = order.data()!;
    if (data['status'] == status.name) return;
    if (!(transitions[data['status']] ?? []).contains(status.name)) {
      throw StateError('This order status transition is not allowed.');
    }
    final items = List<Map<String, dynamic>>.from(
      (data['items'] as List).map((v) => Map<String, dynamic>.from(v)),
    );
    final books = <DocumentSnapshot<Map<String, dynamic>>>[];
    if (status == OrderStatus.cancelled) {
      for (final item in items) {
        books.add(await tx.get(db.collection('books').doc(item['bookId'])));
      }
    }
    for (var i = 0; i < books.length; i++) {
      if (books[i].exists) {
        tx.update(books[i].reference, {
          'stockQuantity':
              (books[i].data()!['stockQuantity'] as num).toInt() +
              (items[i]['quantity'] as num).toInt(),
        });
      }
    }
    tx.update(order.reference, {
      'status': status.name,
      'paymentStatus': status == OrderStatus.delivered
          ? 'paid'
          : data['paymentStatus'],
      'statusHistory': {
        ...Map<String, dynamic>.from(data['statusHistory']),
        status.name: FieldValue.serverTimestamp(),
      },
    });
  });
}

Map<String, double> calculateOrderTotals(
  List<Map<String, dynamic>> items,
  Map<String, dynamic> settings,
  Map<String, dynamic>? promo,
) {
  int cents(num n) => (n * 100).round();
  final sub = items.fold<int>(
    0,
    (runningTotal, i) =>
        runningTotal +
        cents(i['book']['price'] as num) * (i['quantity'] as int),
  );
  var off = 0;
  if (promo != null) {
    final amount = promo['amount'];
    if (promo['active'] != true ||
        !['fixed', 'percent'].contains(promo['type']) ||
        amount is! num ||
        !amount.isFinite ||
        amount <= 0 ||
        (promo['type'] == 'percent' && amount > 100) ||
        (promo['expiresAt'] != null &&
            !readDate(promo['expiresAt']).isAfter(DateTime.now())) ||
        sub < cents(promo['minimumSubtotal'] as num? ?? 0)) {
      throw StateError('This promotion is no longer valid.');
    }
    off = promo['type'] == 'percent'
        ? (sub * cents(promo['amount'] as num) / 10000).round()
        : cents(promo['amount'] as num);
    if (off > sub) off = sub;
  }
  final ship = sub >= cents(settings['freeShippingThreshold'] as num)
      ? 0
      : cents(settings['shippingFee'] as num);
  final tax = ((sub - off) * (settings['taxRate'] as num)).round();
  return {
    'subtotal': sub / 100,
    'shipping': ship / 100,
    'tax': tax / 100,
    'discount': off / 100,
    'total': (sub - off + ship + tax) / 100,
  };
}

class FirestoreReviewRepository implements ReviewRepository {
  final CustomerStore store;
  FirebaseFirestore get db => store.db;
  FirestoreReviewRepository(this.store);
  @override
  Stream<List<ReviewItem>> watchReviews(String bookId) => db
      .collection('books')
      .doc(bookId)
      .collection('reviews')
      .snapshots()
      .map((snapshot) {
        final docs = snapshot.docs.toList()
          ..sort(
            (a, b) =>
                readDate(b.data()['createdAt'])
                    .compareTo(readDate(a.data()['createdAt'])),
          );
        return docs
            .map(
              (d) => ReviewItem(
                id: d.id,
                bookId: bookId,
                userName: d.data()['userName'] ?? '',
                userAvatar: d.data()['userAvatar'] ?? '',
                rating: (d.data()['rating'] as num).toDouble(),
                dateString: readDate(d.data()['createdAt'])
                    .toLocal()
                    .toString()
                    .split(' ')
                    .first,
                content: d.data()['content'] ?? '',
                helpfulCount: (d.data()['helpfulCount'] as num? ?? 0).toInt(),
              ),
            )
            .toList();
      });

  @override
  Stream<bool> watchHelpfulVote(String bookId, String reviewId) => db
      .collection('books')
      .doc(bookId)
      .collection('reviews')
      .doc(reviewId)
      .snapshots()
      .map(
        (d) => (d.data()?['helpfulBy'] as Map? ?? {}).containsKey(store.uid),
      );
  @override
  Future<void> toggleHelpfulVote(String bookId, String reviewId) async {
    final uid = store.user.id;
    if (uid == reviewId) {
      throw StateError('You cannot vote on your own review.');
    }
    final review = db
        .collection('books')
        .doc(bookId)
        .collection('reviews')
        .doc(reviewId);
    await db.runTransaction((tx) async {
      final doc = await tx.get(review);
      if (!doc.exists) throw StateError('This review is no longer available.');
      final voters = doc.data()?['helpfulBy'] as Map? ?? {};
      final hadVote = voters.containsKey(uid);
      if (!hadVote && voters.length >= 10000) {
        throw StateError('This review has reached its voting limit.');
      }
      tx.update(review, {
        FieldPath(['helpfulBy', uid]): hadVote ? FieldValue.delete() : true,
        'helpfulCount': FieldValue.increment(hadVote ? -1 : 1),
      });
    });
  }

  @override
  Future<List<ReviewItem>> getReviewsForBook(String bookId) async {
    final snapshot = await db
        .collection('books')
        .doc(bookId)
        .collection('reviews')
        .get();
    final docs = snapshot.docs.toList()
      ..sort(
        (a, b) =>
            readDate(b.data()['createdAt'])
                .compareTo(readDate(a.data()['createdAt'])),
      );
    return docs.map((d) {
      final v = d.data();
      return ReviewItem(
        id: d.id,
        bookId: bookId,
        userName: v['userName'] ?? '',
        userAvatar: v['userAvatar'] ?? '',
        rating: (v['rating'] as num).toDouble(),
        dateString: readDate(v['createdAt'])
            .toLocal()
            .toString()
            .split(' ')
            .first,
        content: v['content'] ?? '',
        helpfulCount: (v['helpfulCount'] as num? ?? 0).toInt(),
      );
    }).toList();
  }

  @override
  Future<void> addReview({
    required String bookId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    if (rating < 1 ||
        rating > 5 ||
        rating != rating.roundToDouble() ||
        comment.trim().isEmpty ||
        comment.trim().length > 4000) {
      throw StateError(
        'Choose a 1-5 rating and write a review of up to 4000 characters.',
      );
    }
    final user = store.user;
    await db.runTransaction((tx) async {
      final bookRef = db.collection('books').doc(bookId);
      final reviewRef = bookRef.collection('reviews').doc(store.uid);
      final book = await tx.get(bookRef);
      final old = await tx.get(reviewRef);
      final profile = await tx.get(user);
      if (!book.exists || !profile.exists) {
        throw StateError('Book or profile not found.');
      }
      final counts = <String, int>{
        for (final entry
            in (book.data()!['ratingCounts'] as Map? ?? {}).entries)
          entry.key.toString(): (entry.value as num).toInt(),
      };
      if (old.exists) {
        final key = (old.data()!['rating'] as num).toInt().toString();
        counts[key] = (counts[key] ?? 1) - 1;
      }
      final key = rating.toInt().toString();
      counts[key] = (counts[key] ?? 0) + 1;
      final count = counts.values.fold<int>(0, (s, n) => s + n);
      final sum = counts.entries.fold<int>(
        0,
        (s, e) => s + int.parse(e.key) * e.value,
      );
      tx.set(reviewRef, {
        'userId': store.uid,
        'userName': profile.data()!['fullName'],
        'userAvatar': profile.data()!['avatarUrl'] ?? '',
        'rating': rating.toInt(),
        'content': comment.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        if (!old.exists) 'helpfulCount': 0,
        if (!old.exists) 'helpfulBy': <String, bool>{},
      }, SetOptions(merge: true));
      tx.update(bookRef, {
        'ratingScore': sum / count,
        'reviewTotal': count,
        'rating': sum / count,
        'reviewCount': count,
        'ratingCounts': counts,
        'ratingBreakdown': {
          for (var r = 1; r <= 5; r++) '$r': (counts['$r'] ?? 0) / count,
        },
      });
    });
  }
}

class FirestoreAdminRepository implements AdminRepository {
  final FirebaseFirestore db;
  FirestoreAdminRepository(this.db);
  @override
  Stream<List<UserProfile>> watchUsers() => db
      .collection('users')
      .snapshots()
      .map((s) => s.docs.map((d) => readProfile(d.id, d.data())).toList());
  @override
  Stream<AdminDashboardStats> watchDashboardStats() {
    late StreamController<AdminDashboardStats> controller;
    final subscriptions = <StreamSubscription<dynamic>>[];
    List<OrderItem>? orders;
    int? books, users;
    void emit() {
      if (orders == null || books == null || users == null) return;
      controller.add(
        AdminDashboardStats(
          totalRevenue: orders!
              .where((o) => o.status == OrderStatus.delivered)
              .fold(0.0, (s, o) => s + o.total),
          totalOrders: orders!.length,
          totalBooks: books!,
          totalUsers: users!,
        ),
      );
    }

    controller = StreamController<AdminDashboardStats>(
      onListen: () {
        subscriptions.add(
          db.collection('orders').snapshots().listen((s) {
            orders = s.docs.map((d) => readOrder(d.id, d.data())).toList();
            emit();
          }, onError: controller.addError),
        );
        subscriptions.add(
          db.collection('books').snapshots().listen((s) {
            books = s.size;
            emit();
          }, onError: controller.addError),
        );
        subscriptions.add(
          db.collection('users').snapshots().listen((s) {
            users = s.size;
            emit();
          }, onError: controller.addError),
        );
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );
    return controller.stream;
  }

  @override
  Future<AdminDashboardStats> getDashboardStats() async {
    final orders = await getAllOrders();
    final books = await db.collection('books').count().get();
    final users = await db.collection('users').count().get();
    return AdminDashboardStats(
      totalRevenue: orders
          .where((o) => o.status == OrderStatus.delivered)
          .fold(0.0, (s, o) => s + o.total),
      totalOrders: orders.length,
      totalBooks: books.count ?? 0,
      totalUsers: users.count ?? 0,
      growthRate: 0,
    );
  }

  @override
  Future<List<OrderItem>> getAllOrders() async =>
      (await db.collection('orders').get()).docs
          .map((d) => readOrder(d.id, d.data()))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  @override
  Future<void> updateOrderStatus(String id, OrderStatus status) async {
    await setOrderStatus(db, id, status);
  }

  @override
  Future<List<UserProfile>> getAllUsers() async =>
      (await db.collection('users').get()).docs
          .map((d) => readProfile(d.id, d.data()))
          .toList();
  @override
  Future<void> updateUserRole(String id, UserRole role) async {
    await db.collection('users').doc(id).update({'role': role.name});
  }

  @override
  Future<List<BookItem>> getAllBooks() =>
      FirestoreBookRepository(db).getBooks();
  @override
  Future<void> saveBook(BookItem book) => saveCatalogBook(db, book);
  @override
  Future<void> deleteBook(String id) => deleteCatalogBook(db, id);
}
