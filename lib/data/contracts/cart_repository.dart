import '../../core/models/book.dart';
import '../../core/models/cart_item.dart';

abstract class CartRepository {
  Stream<List<CartItem>> watchCart();
  List<CartItem> getCartItems();
  Future<void> addToCart(BookItem book, {int quantity = 1});
  Future<void> updateQuantity(String cartItemId, int quantity);
  Future<void> removeFromCart(String cartItemId);
  Future<void> clearCart();
  double get subtotal;
  double get shippingFee; // From settings/store
  double get taxAmount; // From settings/store
  double get discountAmount;
  double get total;
  double get freeShippingThreshold; // From settings/store
  Future<bool> applyPromoCode(String code);
}
