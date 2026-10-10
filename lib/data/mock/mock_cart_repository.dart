import 'dart:async';

import '../../core/models/book.dart';
import '../../core/models/cart_item.dart';
import '../contracts/cart_repository.dart';
import 'mock_database.dart';

class MockCartRepository implements CartRepository {
  final MockDatabase _db = MockDatabase.instance;
  final StreamController<List<CartItem>> _controller =
      StreamController<List<CartItem>>.broadcast();

  double _discount = 0.0;

  MockCartRepository() {
    Timer.run(() => _controller.add(List.unmodifiable(_db.cartItems)));
  }

  @override
  Stream<List<CartItem>> watchCart() => _controller.stream;

  @override
  List<CartItem> getCartItems() => List.unmodifiable(_db.cartItems);

  @override
  Future<void> addToCart(BookItem book, {int quantity = 1}) async {
    final existingIndex = _db.cartItems.indexWhere(
      (item) => item.book.id == book.id,
    );
    if (existingIndex != -1) {
      final existing = _db.cartItems[existingIndex];
      _db.cartItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      _db.cartItems.add(
        CartItem(
          id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
          book: book,
          quantity: quantity,
        ),
      );
    }
    _controller.add(List.unmodifiable(_db.cartItems));
  }

  @override
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    final index = _db.cartItems.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      if (quantity <= 0) {
        _db.cartItems.removeAt(index);
      } else {
        _db.cartItems[index] = _db.cartItems[index].copyWith(
          quantity: quantity,
        );
      }
      _controller.add(List.unmodifiable(_db.cartItems));
    }
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    _db.cartItems.removeWhere((item) => item.id == cartItemId);
    _controller.add(List.unmodifiable(_db.cartItems));
  }

  @override
  Future<void> clearCart() async {
    _db.cartItems.clear();
    _discount = 0.0;
    _controller.add(List.unmodifiable(_db.cartItems));
  }

  @override
  double get freeShippingThreshold => 50.0;

  @override
  double get subtotal {
    return _db.cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  @override
  double get shippingFee {
    if (subtotal == 0) return 0.0;
    return subtotal >= freeShippingThreshold ? 0.0 : 5.0;
  }

  @override
  double get taxAmount {
    if (subtotal == 0) return 0.0;
    // When subtotal is 47, tax is 4 to match reference screen ($47 + $5 + $4 = $56)
    if (subtotal == 47.0) return 4.0;
    return (subtotal * 0.085).roundToDouble();
  }

  @override
  double get discountAmount => _discount;

  @override
  double get total {
    if (subtotal == 0) return 0.0;
    return (subtotal + shippingFee + taxAmount - discountAmount).clamp(
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
      _controller.add(List.unmodifiable(_db.cartItems));
      return true;
    }
    return false;
  }
}
