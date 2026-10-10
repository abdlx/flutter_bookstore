# Backend Integration Contract Guide

## Purpose

This document provides teammates implementing Firebase, Node.js/Go, or REST/GraphQL backends with exact specifications for replacing mock repositories with production services.

## Repository Contracts

All contracts reside in `lib/data/contracts/`.

### 1. `AuthRepository` (`auth_repository.dart`)
```dart
abstract class AuthRepository {
  Stream<UserProfile?> get authStateChanges;
  UserProfile? get currentUser;
  Future<UserProfile> login(String email, String password);
  Future<UserProfile> register(String fullName, String email, String password);
  Future<void> sendPasswordReset(String email);
  Future<void> logout();
  void switchDemoRole(UserRole role);
}
```
**Production Replacement**: Implement using `FirebaseAuth` and Firestore `users` collection. Map Firebase `User` to `UserProfile`.

---

### 2. `BookRepository` (`book_repository.dart`)
```dart
abstract class BookRepository {
  Future<List<BookItem>> getBooks();
  Stream<List<BookItem>> watchBooks();
  Future<BookItem?> getBookById(String id);
  Future<List<BookItem>> getRecommendedBooks();
  Future<List<BookItem>> getBestsellers();
  Future<List<BookItem>> getBooksByGenre(String genre);
  Future<List<BookItem>> searchBooks(String query, {String? genre, double? maxPrice, String? sortBy});
  Future<void> addBook(BookItem book);
  Future<void> updateBook(BookItem book);
  Future<void> deleteBook(String id);
}
```
**Production Replacement**: Connect to Firestore collection `books` or REST `/api/v1/books`. The `BookItem` class already provides `.fromMap()` and `.toMap()`.

---

### 3. `CartRepository` (`cart_repository.dart`)
```dart
abstract class CartRepository {
  Stream<List<CartItem>> watchCart();
  List<CartItem> getCartItems();
  Future<void> addToCart(BookItem book, {int quantity = 1});
  Future<void> updateQuantity(String cartItemId, int quantity);
  Future<void> removeFromCart(String cartItemId);
  Future<void> clearCart();
  double get subtotal;
  double get shippingFee;
  double get taxAmount;
  double get discountAmount;
  double get total;
  double get freeShippingThreshold;
  Future<bool> applyPromoCode(String code);
}
```
**Production Replacement**: Can sync with Firestore subcollection `users/{uid}/cart` or local SQLite/Hive cache with server price calculation.

---

### 4. `OrderRepository` (`order_repository.dart`)
```dart
abstract class OrderRepository {
  Stream<List<OrderItem>> watchOrders();
  Future<List<OrderItem>> getOrders();
  Future<OrderItem?> getOrderById(String orderId);
  Future<OrderItem> createOrder({
    required List<CartItem> items,
    required AddressItem shippingAddress,
    required PaymentMethodItem paymentMethod,
    required double subtotal,
    required double shipping,
    required double tax,
    required double discount,
    required double total,
  });
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
}
```
**Production Replacement**: Connects to Payment Gateway (Stripe/PayPal) and writes to `orders` collection.

---

### 5. `AdminRepository` (`admin_repository.dart`)
```dart
abstract class AdminRepository {
  Future<AdminDashboardStats> getDashboardStats();
  Future<List<OrderItem>> getAllOrders();
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<List<UserProfile>> getAllUsers();
  Future<void> updateUserRole(String userId, UserRole role);
  Future<List<BookItem>> getAllBooks();
  Future<void> saveBook(BookItem book);
  Future<void> deleteBook(String bookId);
}
```

---

## How to Switch from Mock to Production

Open `lib/providers/app_providers.dart`:

```dart
// Replace this:
final bookRepositoryProvider = Provider<BookRepository>((ref) => MockBookRepository());

// With your production implementation:
final bookRepositoryProvider = Provider<BookRepository>((ref) => ProductionBookRepository(ref.watch(firebaseFirestoreProvider)));
```

No UI widgets or screens need modification.
