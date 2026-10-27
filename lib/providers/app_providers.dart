import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/address.dart';
import '../core/models/book.dart';
import '../core/models/cart_item.dart';
import '../core/models/order.dart';
import '../core/models/payment_method.dart';
import '../core/models/user_profile.dart';
import '../data/contracts/address_repository.dart';
import '../data/contracts/admin_repository.dart';
import '../data/contracts/auth_repository.dart';
import '../data/contracts/book_repository.dart';
import '../data/contracts/cart_repository.dart';
import '../data/contracts/order_repository.dart';
import '../data/contracts/payment_method_repository.dart';
import '../data/contracts/profile_repository.dart';
import '../data/contracts/review_repository.dart';
import '../data/contracts/wishlist_repository.dart';
import '../data/services/firebase_address_repository.dart';
import '../data/services/firebase_admin_repository.dart';
import '../data/services/firebase_auth_repository.dart';
import '../data/services/firebase_book_repository.dart';
import '../data/services/firebase_cart_repository.dart';
import '../data/services/firebase_order_repository.dart';
import '../data/services/firebase_payment_method_repository.dart';
import '../data/services/firebase_profile_repository.dart';
import '../data/services/firebase_review_repository.dart';
import '../data/services/firebase_wishlist_repository.dart';

// Firebase core providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Singletons / Repositories (Firebase implementations)
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(),
);

final bookRepositoryProvider = Provider<BookRepository>(
  (ref) => FirebaseBookRepository(),
);

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => FirebaseCartRepository(),
);

final wishlistRepositoryProvider = Provider<WishlistRepository>(
  (ref) => FirebaseWishlistRepository(),
);

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => FirebaseOrderRepository(),
);

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => FirebaseReviewRepository(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => FirebaseProfileRepository(),
);

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => FirebaseAddressRepository(),
);

final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>(
  (ref) => FirebasePaymentMethodRepository(),
);

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => FirebaseAdminRepository(),
);

// Reactive Data Streams
final currentUserStreamProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final allBooksStreamProvider = StreamProvider<List<BookItem>>((ref) {
  return ref.watch(bookRepositoryProvider).watchBooks();
});

final cartStreamProvider = StreamProvider<List<CartItem>>((ref) {
  return ref.watch(cartRepositoryProvider).watchCart();
});

final wishlistStreamProvider = StreamProvider<List<BookItem>>((ref) {
  return ref.watch(wishlistRepositoryProvider).watchWishlist();
});

final ordersStreamProvider = StreamProvider<List<OrderItem>>((ref) {
  return ref.watch(orderRepositoryProvider).watchOrders();
});

final addressesStreamProvider = StreamProvider<List<AddressItem>>((ref) {
  return ref.watch(addressRepositoryProvider).watchAddresses();
});

final paymentMethodsStreamProvider = StreamProvider<List<PaymentMethodItem>>((
  ref,
) {
  return ref.watch(paymentMethodRepositoryProvider).watchPaymentMethods();
});

// UI Filters - Notifier implementations for Riverpod 3
class SelectedGenreNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  @override
  set state(String value) {
    super.state = value;
  }
}

final selectedGenreProvider = NotifierProvider<SelectedGenreNotifier, String>(
  SelectedGenreNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  @override
  set state(String value) {
    super.state = value;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchSortNotifier extends Notifier<String> {
  @override
  String build() => 'popular';

  @override
  set state(String value) {
    super.state = value;
  }
}

final searchSortProvider = NotifierProvider<SearchSortNotifier, String>(
  SearchSortNotifier.new,
);