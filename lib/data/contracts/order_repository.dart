import '../../core/models/address.dart';
import '../../core/models/cart_item.dart';
import '../../core/models/order.dart';
import '../../core/models/payment_method.dart';

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
