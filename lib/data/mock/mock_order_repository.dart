import 'dart:async';

import '../../core/models/address.dart';
import '../../core/models/cart_item.dart';
import '../../core/models/order.dart';
import '../../core/models/payment_method.dart';
import '../contracts/order_repository.dart';
import 'mock_database.dart';

class MockOrderRepository implements OrderRepository {
  final MockDatabase _db = MockDatabase.instance;
  final StreamController<List<OrderItem>> _controller =
      StreamController<List<OrderItem>>.broadcast();

  MockOrderRepository() {
    Timer.run(() => _controller.add(List.unmodifiable(_db.orders)));
  }

  @override
  Stream<List<OrderItem>> watchOrders() => _controller.stream;

  @override
  Future<List<OrderItem>> getOrders() async {
    return List.unmodifiable(_db.orders);
  }

  @override
  Future<OrderItem?> getOrderById(String orderId) async {
    try {
      return _db.orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
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
    final newOrder = OrderItem(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: 'AP-${10000 + _db.orders.length + 1}',
      items: List.from(items),
      subtotal: subtotal,
      shipping: shipping,
      tax: tax,
      discount: discount,
      total: total,
      status: OrderStatus.placed,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      trackingSteps: [
        TrackingStep(
          title: 'Order Placed',
          description: 'Your order was successfully placed.',
          time: DateTime.now(),
          isCompleted: true,
        ),
        TrackingStep(
          title: 'Processing',
          description: 'Our curators are preparing your books.',
          time: DateTime.now().add(const Duration(hours: 4)),
          isCompleted: false,
        ),
        TrackingStep(
          title: 'Shipped',
          description: 'Package handed over to shipping courier.',
          time: DateTime.now().add(const Duration(days: 1)),
          isCompleted: false,
        ),
        TrackingStep(
          title: 'Delivered',
          description: 'Package safely delivered.',
          time: DateTime.now().add(const Duration(days: 3)),
          isCompleted: false,
        ),
      ],
    );

    _db.orders.insert(0, newOrder);
    _controller.add(List.unmodifiable(_db.orders));
    return newOrder;
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final index = _db.orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _db.orders[index] = _db.orders[index].copyWith(status: status);
      _controller.add(List.unmodifiable(_db.orders));
    }
  }
}
