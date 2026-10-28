import 'address.dart';
import 'cart_item.dart';
import 'payment_method.dart';

enum OrderStatus {
  placed,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

extension OrderTransitions on OrderStatus {
  List<OrderStatus> get nextStatuses => switch (this) {
    OrderStatus.placed => [OrderStatus.confirmed, OrderStatus.cancelled],
    OrderStatus.confirmed => [OrderStatus.processing, OrderStatus.cancelled],
    OrderStatus.processing => [OrderStatus.shipped, OrderStatus.cancelled],
    OrderStatus.shipped => [OrderStatus.delivered],
    OrderStatus.delivered || OrderStatus.cancelled => [],
  };
}

class TrackingStep {
  final String title;
  final String description;
  final DateTime time;
  final bool isCompleted;

  const TrackingStep({
    required this.title,
    required this.description,
    required this.time,
    required this.isCompleted,
  });
}

class OrderItem {
  final String id;
  final String orderNumber;
  final List<CartItem> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;
  final OrderStatus status;
  final AddressItem shippingAddress;
  final PaymentMethodItem paymentMethod;
  final DateTime createdAt;
  final List<TrackingStep> trackingSteps;

  const OrderItem({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    this.discount = 0.0,
    required this.total,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.createdAt,
    this.trackingSteps = const [],
  });

  String get statusDisplay {
    switch (status) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  OrderItem copyWith({
    String? id,
    String? orderNumber,
    List<CartItem>? items,
    double? subtotal,
    double? shipping,
    double? tax,
    double? discount,
    double? total,
    OrderStatus? status,
    AddressItem? shippingAddress,
    PaymentMethodItem? paymentMethod,
    DateTime? createdAt,
    List<TrackingStep>? trackingSteps,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shipping: shipping ?? this.shipping,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      trackingSteps: trackingSteps ?? this.trackingSteps,
    );
  }
}
