import '../data/firestore/firestore_codec.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
import '../data/firestore/firebase_auth_repository.dart';
import '../data/firestore/firestore_book_repository.dart';
import '../data/firestore/firestore_customer_repositories.dart';
import '../data/firestore/firestore_order_repositories.dart';

final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final firebaseFirestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repo = FirebaseAuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firebaseFirestoreProvider),
  );
  ref.onDispose(repo.dispose);
  return repo;
});
final currentUserStreamProvider = StreamProvider<UserProfile?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges,
);
final customerStoreProvider = Provider(
  (ref) => CustomerStore(
    ref.watch(firebaseFirestoreProvider),
    ref.watch(currentUserStreamProvider.select((u) => u.value?.id)),
  ),
);
final bookRepositoryProvider = Provider<BookRepository>(
  (ref) => FirestoreBookRepository(ref.watch(firebaseFirestoreProvider)),
);
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final repo = FirestoreCartRepository(ref.watch(customerStoreProvider));
  ref.onDispose(repo.dispose);
  return repo;
});
final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final repo = FirestoreWishlistRepository(ref.watch(customerStoreProvider));
  ref.onDispose(repo.dispose);
  return repo;
});
final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => FirestoreOrderRepository(
    ref.watch(customerStoreProvider),
    ref.watch(cartRepositoryProvider) as FirestoreCartRepository,
  ),
);
final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => FirestoreReviewRepository(ref.watch(customerStoreProvider)),
);
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => FirestoreProfileRepository(
    ref.watch(customerStoreProvider),
    ref.watch(firebaseAuthProvider),
  ),
);
final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => FirestoreAddressRepository(ref.watch(customerStoreProvider)),
);
final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>(
  (ref) => FirestorePaymentMethodRepository(ref.watch(customerStoreProvider)),
);
final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => FirestoreAdminRepository(ref.watch(firebaseFirestoreProvider)),
);
final allBooksStreamProvider = StreamProvider<List<BookItem>>(
  (ref) => ref.watch(bookRepositoryProvider).watchBooks(),
);
final cartStreamProvider = StreamProvider<List<CartItem>>(
  (ref) => ref.watch(cartRepositoryProvider).watchCart(),
);
final wishlistStreamProvider = StreamProvider<List<BookItem>>(
  (ref) => ref.watch(wishlistRepositoryProvider).watchWishlist(),
);
final ordersStreamProvider = StreamProvider<List<OrderItem>>(
  (ref) => ref.watch(orderRepositoryProvider).watchOrders(),
);
final addressesStreamProvider = StreamProvider<List<AddressItem>>(
  (ref) => ref.watch(addressRepositoryProvider).watchAddresses(),
);
final paymentMethodsStreamProvider = StreamProvider<List<PaymentMethodItem>>(
  (ref) => ref.watch(paymentMethodRepositoryProvider).watchPaymentMethods(),
);
final catalogGenresProvider = Provider<List<String>>(
  (ref) => [
    'All',
    ...({
      ...?ref
          .watch(allBooksStreamProvider)
          .value
          ?.map((b) => b.genre)
          .where((g) => g.isNotEmpty),
    }.toList()..sort()),
  ],
);
final storeSettingsProvider = StreamProvider<Map<String, dynamic>>(
  (ref) => ref
      .watch(firebaseFirestoreProvider)
      .doc('settings/store')
      .snapshots()
      .map((s) => s.data() ?? {}),
);

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

final adminOrdersStreamProvider = StreamProvider<List<OrderItem>>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  final user = ref.watch(currentUserStreamProvider).value;
  if (user?.isAdmin != true) return Stream.value([]);
  return db
      .collection('orders')
      .snapshots()
      .map(
        (s) =>
            s.docs.map((d) => readOrder(d.id, d.data())).toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );
});
final orderDetailsProvider = StreamProvider.autoDispose
    .family<OrderItem?, String>((ref, id) {
      final store = ref.watch(customerStoreProvider);
      if (store.uid == null) return Stream.value(null);
      return store.db
          .collection('orders')
          .doc(id)
          .snapshots()
          .map((s) => s.exists ? readOrder(s.id, s.data()!) : null);
    });
