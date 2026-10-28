import 'referenced_books.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/models/address.dart';
import '../../core/models/book.dart';
import '../../core/models/cart_item.dart';
import '../../core/models/payment_method.dart';
import '../../core/models/user_profile.dart';
import '../contracts/address_repository.dart';
import '../contracts/cart_repository.dart';
import '../contracts/payment_method_repository.dart';
import '../contracts/profile_repository.dart';
import '../contracts/wishlist_repository.dart';
import 'firestore_codec.dart';

class CustomerStore {
  final FirebaseFirestore db;
  final String? uid;
  CustomerStore(this.db, this.uid);
  DocumentReference<Map<String, dynamic>> get user {
    if (uid == null) throw StateError('Please sign in to continue.');
    return db.collection('users').doc(uid);
  }

  CollectionReference<Map<String, dynamic>> collection(String name) =>
      user.collection(name);
  Stream<List<T>> watch<T>(
    String name,
    T Function(String, Map<String, dynamic>) read,
  ) => uid == null
      ? Stream.value(<T>[])
      : collection(name)
            .snapshots()
            .map((s) => s.docs.map((d) => read(d.id, d.data())).toList());
  Future<void> saveDefault(
    String name,
    String id,
    Map<String, dynamic> data,
  ) async {
    // Parent default pointers serialize concurrent default changes.
    await db.runTransaction((tx) async {
      final parent = await tx.get(user);
      final pointer = '${name}DefaultId';
      final previous = parent.data()?[pointer] as String?;
      final old = previous == null
          ? null
          : await tx.get(collection(name).doc(previous));
      if (data['isDefault'] == true || previous == null) {
        if (old?.exists == true && previous != id) {
          tx.update(old!.reference, {'isDefault': false});
        }
        data = {...data, 'isDefault': true};
        tx.update(user, {pointer: id});
      } else if (previous == id) {
        data = {...data, 'isDefault': true};
      }
      tx.set(collection(name).doc(id), data);
      tx.update(user, {'updatedAt': FieldValue.serverTimestamp()});
    });
  }

  Future<void> delete(String name, String id) => db.runTransaction((tx) async {
    final parent = await tx.get(user);
    if (parent.data()?['${name}DefaultId'] == id) {
      tx.update(user, {'${name}DefaultId': FieldValue.delete()});
    }
    tx.delete(collection(name).doc(id));
  });
  Future<void> setDefault(String name, String id) async {
    final doc = await collection(name).doc(id).get();
    if (!doc.exists) throw StateError('This item no longer exists.');
    await saveDefault(name, id, {...doc.data()!, 'isDefault': true});
  }
}

class FirestoreAddressRepository implements AddressRepository {
  final CustomerStore store;
  FirestoreAddressRepository(this.store);
  @override
  Stream<List<AddressItem>> watchAddresses() =>
      store.watch('addresses', readAddress);
  @override
  Future<List<AddressItem>> getAddresses() async => store.uid == null
      ? []
      : (await store.collection('addresses').get()).docs
            .map((d) => readAddress(d.id, d.data()))
            .toList();
  @override
  Future<AddressItem?> getDefaultAddress() async {
    final a = await getAddresses();
    return a.where((a) => a.isDefault).firstOrNull ?? a.firstOrNull;
  }

  @override
  Future<void> addAddress(AddressItem a) =>
      store.saveDefault('addresses', a.id, writeAddress(a));
  @override
  Future<void> updateAddress(AddressItem a) => addAddress(a);
  @override
  Future<void> deleteAddress(String id) => store.delete('addresses', id);
  @override
  Future<void> setDefaultAddress(String id) =>
      store.setDefault('addresses', id);
}

class FirestorePaymentMethodRepository implements PaymentMethodRepository {
  final CustomerStore store;
  FirestorePaymentMethodRepository(this.store);
  @override
  Stream<List<PaymentMethodItem>> watchPaymentMethods() =>
      store.watch('paymentMethods', readPayment);
  @override
  Future<List<PaymentMethodItem>> getPaymentMethods() async => store.uid == null
      ? []
      : (await store.collection('paymentMethods').get()).docs
            .map((d) => readPayment(d.id, d.data()))
            .toList();
  @override
  Future<PaymentMethodItem?> getDefaultPaymentMethod() async {
    final p = await getPaymentMethods();
    return p.where((p) => p.isDefault).firstOrNull ?? p.firstOrNull;
  }

  @override
  Future<void> addPaymentMethod(PaymentMethodItem p) {
    if (p.type != 'cod') {
      throw StateError('Only cash on delivery is currently supported.');
    }
    return store.saveDefault('paymentMethods', p.id, writePayment(p));
  }

  @override
  Future<void> deletePaymentMethod(String id) =>
      store.delete('paymentMethods', id);
  @override
  Future<void> setDefaultPaymentMethod(String id) =>
      store.setDefault('paymentMethods', id);
}

class FirestoreProfileRepository implements ProfileRepository {
  final CustomerStore store;
  final FirebaseAuth auth;
  FirestoreProfileRepository(this.store, this.auth);
  @override
  Future<UserProfile> getProfile() async {
    final doc = await store.user.get();
    if (!doc.exists) {
      throw StateError('Profile not found. Please sign in again.');
    }
    return readProfile(doc.id, doc.data()!);
  }

  @override
  Future<UserProfile> updateProfile({
    required String fullName,
    required String email,
    String? phone,
    String? avatarUrl,
  }) async {
    final user = auth.currentUser;
    if (user == null) throw StateError('Please sign in.');
    if (email.trim() != user.email) {
      await user.verifyBeforeUpdateEmail(email.trim());
      throw StateError(
        'A verification link was sent to the new email. Verify it, sign in again, then save your profile.',
      );
    }
    await store.user.update({
      'fullName': fullName.trim(),
      'email': user.email,
      'phone': phone,
      'avatarUrl': avatarUrl,
    });
    await user.updateDisplayName(fullName.trim());
    return getProfile();
  }
}

class FirestoreCartRepository implements CartRepository {
  final CustomerStore store;
  final _changes = StreamController<List<CartItem>>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  List<CartItem> _items = [];
  Map<String, BookItem> _books = {};
  bool _booksLoaded = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _rows = [];
  Map<String, dynamic> _settings = {};
  Map<String, dynamic>? _promo;
  String? promoCode;
  late final _bookWatcher = ReferencedBooks(
    store.db,
    onData: (books) {
      _books = books;
      _booksLoaded = true;
      _emit();
    },
    onError: _changes.addError,
  );
  FirestoreCartRepository(this.store) {
    if (store.uid == null) return;
    _subscriptions.add(
      store.collection('cart').snapshots().listen((s) {
        _rows = s.docs;
        _booksLoaded = false;
        _bookWatcher.watch(_rows.map((d) => d.id));
      }, onError: _changes.addError),
    );
    _subscriptions.add(
      store.db.doc('settings/store').snapshots().listen((s) {
        _settings = s.data() ?? {};
        _emit();
      }, onError: _changes.addError),
    );
  }
  void _emit() {
    if (_booksLoaded && _rows.any((row) => !_books.containsKey(row.id))) {
      _changes.addError(
        StateError(
          'A title in your cart is no longer available. Use the cart menu to clear your cart, then add available books.',
        ),
      );
      return;
    }
    _items = [
      for (final d in _rows)
        if (_books.containsKey(d.id))
          CartItem(
            id: d.id,
            book: _books[d.id]!,
            quantity: (d.data()['quantity'] as num).toInt(),
          ),
    ];
    _changes.add(List.unmodifiable(_items));
  }

  @override
  Stream<List<CartItem>> watchCart() async* {
    yield List.unmodifiable(_items);
    yield* _changes.stream;
  }

  @override
  List<CartItem> getCartItems() => List.unmodifiable(_items);
  @override
  Future<void> addToCart(BookItem book, {int quantity = 1}) async {
    if (quantity < 1) throw StateError('Quantity must be positive.');
    final doc = store.collection('cart').doc(book.id);
    await store.db.runTransaction((tx) async {
      final b = await tx.get(store.db.collection('books').doc(book.id));
      final c = await tx.get(doc);
      final next = ((c.data()?['quantity'] as num?)?.toInt() ?? 0) + quantity;
      if (!b.exists || next > (b.data()?['stockQuantity'] as num? ?? 0)) {
        throw StateError('Not enough stock available.');
      }
      tx.set(doc, {'bookId': book.id, 'quantity': next});
    });
  }

  @override
  Future<void> updateQuantity(String id, int quantity) async {
    if (quantity < 1) {
      await removeFromCart(id);
      return;
    }
    await store.db.runTransaction((tx) async {
      final b = await tx.get(store.db.collection('books').doc(id));
      if (!b.exists || quantity > (b.data()?['stockQuantity'] as num? ?? 0)) {
        throw StateError('Not enough stock available.');
      }
      tx.set(store.collection('cart').doc(id), {
        'bookId': id,
        'quantity': quantity,
      });
    });
  }

  @override
  Future<void> removeFromCart(String id) =>
      store.collection('cart').doc(id).delete();
  @override
  Future<void> clearCart() async {
    final docs = await store.collection('cart').get();
    final batch = store.db.batch();
    for (final d in docs.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
    promoCode = null;
    _promo = null;
    _emit();
  }

  double _money(double v) => (v * 100).round() / 100;
  @override
  double get subtotal => _money(_items.fold(0.0, (s, i) => s + i.totalPrice));
  @override
  double get freeShippingThreshold =>
      _money((_settings['freeShippingThreshold'] as num? ?? 0).toDouble());
  @override
  double get shippingFee => _items.isEmpty || subtotal >= freeShippingThreshold
      ? 0
      : _money((_settings['shippingFee'] as num? ?? 0).toDouble());
  @override
  double get discountAmount {
    final p = _promo;
    final amount = (p?['amount'] as num?)?.toDouble();
    if (p == null ||
        p['active'] != true ||
        !['fixed', 'percent'].contains(p['type']) ||
        amount == null ||
        !amount.isFinite ||
        amount <= 0 ||
        (p['type'] == 'percent' && amount > 100) ||
        subtotal < (p['minimumSubtotal'] as num? ?? 0) ||
        (p['expiresAt'] != null &&
            !readDate(p['expiresAt']).isAfter(DateTime.now()))) {
      return 0;
    }
    return _money(
      math.min(
        subtotal,
        p['type'] == 'percent' ? subtotal * _money(amount) / 100 : amount,
      ),
    );
  }

  @override
  double get taxAmount => _money(
    (subtotal - discountAmount) *
        (_settings['taxRate'] as num? ?? 0).toDouble(),
  );
  @override
  double get total =>
      _money(subtotal + shippingFee + taxAmount - discountAmount);
  @override
  Future<bool> applyPromoCode(String code) async {
    final key = code.trim().toUpperCase();
    if (key.isEmpty || key.contains('/')) {
      promoCode = null;
      _promo = null;
      _emit();
      return false;
    }
    final doc = await store.db.collection('promotions').doc(key).get();
    _promo = doc.data();
    promoCode = doc.exists ? key : null;
    final valid = discountAmount > 0;
    if (!valid) {
      promoCode = null;
      _promo = null;
    }
    _emit();
    return valid;
  }

  Future<void> dispose() async {
    if (store.uid != null) await _bookWatcher.dispose();
    for (final s in _subscriptions) {
      await s.cancel();
    }
    await _changes.close();
  }
}

class FirestoreWishlistRepository implements WishlistRepository {
  final CustomerStore store;
  final _changes = StreamController<List<BookItem>>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Set<String> _ids = {};
  Map<String, BookItem> _books = {};
  late final _bookWatcher = ReferencedBooks(
    store.db,
    onData: (books) {
      _books = books;
      _emit();
    },
    onError: _changes.addError,
  );
  FirestoreWishlistRepository(this.store) {
    if (store.uid == null) return;
    _subscriptions.add(
      store.collection('wishlist').snapshots().listen((s) {
        _ids = s.docs.map((d) => d.id).toSet();
        _bookWatcher.watch(_ids);
      }, onError: _changes.addError),
    );
  }
  void _emit() => _changes.add(getWishlistItems());
  @override
  List<BookItem> getWishlistItems() => List.unmodifiable(
    _ids.where(_books.containsKey).map((id) => _books[id]!),
  );
  @override
  Stream<List<BookItem>> watchWishlist() async* {
    yield getWishlistItems();
    yield* _changes.stream;
  }

  @override
  bool isInWishlist(String id) => _ids.contains(id);
  @override
  Future<void> toggleWishlist(BookItem b) async {
    final doc = store.collection('wishlist').doc(b.id);
    await store.db.runTransaction((tx) async {
      final s = await tx.get(doc);
      if (s.exists) {
        tx.delete(doc);
      } else {
        tx.set(doc, {'bookId': b.id});
      }
    });
  }

  @override
  Future<void> removeFromWishlist(String id) =>
      store.collection('wishlist').doc(id).delete();
  Future<void> dispose() async {
    if (store.uid != null) await _bookWatcher.dispose();
    for (final s in _subscriptions) {
      await s.cancel();
    }
    await _changes.close();
  }
}
