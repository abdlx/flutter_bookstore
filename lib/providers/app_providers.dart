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
import '../data/mock/mock_address_repository.dart';
import '../data/mock/mock_admin_repository.dart';
import '../data/mock/mock_auth_repository.dart';
import '../data/mock/mock_book_repository.dart';
import '../data/mock/mock_cart_repository.dart';
import '../data/mock/mock_order_repository.dart';
import '../data/mock/mock_payment_method_repository.dart';
import '../data/mock/mock_profile_repository.dart';
import '../data/mock/mock_review_repository.dart';
import '../data/mock/mock_wishlist_repository.dart';

// Singletons / Repositories
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(),
);

final bookRepositoryProvider = Provider<BookRepository>(
  (ref) => MockBookRepository(),
);

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => MockCartRepository(),
);

final wishlistRepositoryProvider = Provider<WishlistRepository>(
  (ref) => MockWishlistRepository(),
);

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => MockOrderRepository(),
);

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => MockReviewRepository(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => MockProfileRepository(),
);

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => MockAddressRepository(),
);

final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>(
  (ref) => MockPaymentMethodRepository(),
);

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => MockAdminRepository(),
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
