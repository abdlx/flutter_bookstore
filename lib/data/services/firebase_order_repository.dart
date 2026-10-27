import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../contracts/order_repository.dart';
import '../../core/models/address.dart';
import '../../core/models/book.dart';
import '../../core/models/cart_item.dart';
import '../../core/models/order.dart';
import '../../core/models/payment_method.dart';

class FirebaseOrderRepository implements OrderRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _allOrdersCol =>
      _db.collection('orders');

  @override
  Stream<List<OrderItem>> watchOrders() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value([]);
    }
    return _db
        .collection('users')
        .doc(uid)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => _orderFromDoc(d.id, d.data())).toList());
  }

  @override
  Future<List<OrderItem>> getOrders() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => _orderFromDoc(d.id, d.data())).toList();
  }

  @override
  Future<OrderItem?> getOrderById(String orderId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('orders')
        .doc(orderId)
        .get();
    if (!doc.exists) return null;
    return _orderFromDoc(doc.id, doc.data()!);
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
    final uid = _auth.currentUser!.uid;
    final orderRef = _allOrdersCol.doc();
    final orderNumber = 'AP-${10000 + DateTime.now().millisecondsSinceEpoch % 100000}';

    final orderData = {
      'userId': uid,
      'orderNumber': orderNumber,
      'items': items
          .map((c) => {
                'bookId': c.book.id,
                'title': c.book.title,
                'coverUrl': c.book.coverUrl,
                'price': c.book.price,
                'quantity': c.quantity,
              })
          .toList(),
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'discount': discount,
      'total': total,
      'status': 'placed',
      'shippingAddress': {
        'label': shippingAddress.label,
        'recipientName': shippingAddress.recipientName,
        'phone': shippingAddress.phone,
        'street': shippingAddress.street,
        'city': shippingAddress.city,
        'state': shippingAddress.state,
        'postalCode': shippingAddress.postalCode,
        'country': shippingAddress.country,
        'isDefault': shippingAddress.isDefault,
      },
      'paymentMethod': {
        'type': paymentMethod.type,
        'title': paymentMethod.title,
        'subtitle': paymentMethod.subtitle,
        'last4': paymentMethod.last4,
        'brand': paymentMethod.brand,
        'expiry': paymentMethod.expiry,
        'isDefault': paymentMethod.isDefault,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'trackingSteps': [
        {
          'title': 'Order Placed',
          'description': 'Your order was successfully placed.',
          'time': Timestamp.fromDate(DateTime.now()),
          'isCompleted': true,
        },
        {
          'title': 'Processing',
          'description': 'Our curators are preparing your books.',
          'time': Timestamp.fromDate(
              DateTime.now().add(const Duration(hours: 4))),
          'isCompleted': false,
        },
        {
          'title': 'Shipped',
          'description': 'Package handed over to shipping courier.',
          'time': Timestamp.fromDate(
              DateTime.now().add(const Duration(days: 1))),
          'isCompleted': false,
        },
        {
          'title': 'Delivered',
          'description': 'Package safely delivered.',
          'time': Timestamp.fromDate(
              DateTime.now().add(const Duration(days: 3))),
          'isCompleted': false,
        },
      ],
    };

    await orderRef.set(orderData);

    // Also write to user's subcollection for easy querying
    await _db
        .collection('users')
        .doc(uid)
        .collection('orders')
        .doc(orderRef.id)
        .set(orderData);

    return _orderFromDoc(orderRef.id, orderData);
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final statusStr = status.name;
    await _allOrdersCol.doc(orderId).update({'status': statusStr});

    // Also update in user's subcollection if we can find it
    // This is a best-effort approach
  }

  OrderItem _orderFromDoc(String id, Map<String, dynamic> m) {
    final items = (m['items'] as List? ?? [])
        .map((e) {
          final map = Map<String, dynamic>.from(e);
          return CartItem(
            id: map['bookId'] ?? '',
            book: BookItem(
              id: map['bookId'] ?? '',
              title: map['title'] ?? '',
              author: '',
              genre: '',
              description: '',
              coverUrl: map['coverUrl'] ?? '',
              price: (map['price'] as num?)?.toDouble() ?? 0.0,
              publishedDate: DateTime.now(),
            ),
            quantity: (map['quantity'] as num?)?.toInt() ?? 1,
          );
        })
        .toList();

    final shippingAddr = m['shippingAddress'] as Map<String, dynamic>?;
    final paymentMeth = m['paymentMethod'] as Map<String, dynamic>?;

    return OrderItem(
      id: id,
      orderNumber: m['orderNumber'] ?? '',
      items: items,
      subtotal: (m['subtotal'] as num?)?.toDouble() ?? 0.0,
      shipping: (m['shipping'] as num?)?.toDouble() ?? 0.0,
      tax: (m['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (m['discount'] as num?)?.toDouble() ?? 0.0,
      total: (m['total'] as num?)?.toDouble() ?? 0.0,
      status: _parseOrderStatus(m['status'] as String?),
      shippingAddress: shippingAddr != null
          ? AddressItem(
              id: '',
              label: shippingAddr['label'] ?? '',
              recipientName: shippingAddr['recipientName'] ?? '',
              phone: shippingAddr['phone'] ?? '',
              street: shippingAddr['street'] ?? '',
              city: shippingAddr['city'] ?? '',
              state: shippingAddr['state'] ?? '',
              postalCode: shippingAddr['postalCode'] ?? '',
              country: shippingAddr['country'] ?? 'United States',
              isDefault: shippingAddr['isDefault'] ?? false,
            )
          : AddressItem(
              id: '',
              label: 'Home',
              recipientName: '',
              phone: '',
              street: '',
              city: '',
              state: '',
              postalCode: '',
            ),
      paymentMethod: paymentMeth != null
          ? PaymentMethodItem(
              id: '',
              type: paymentMeth['type'] ?? 'card',
              title: paymentMeth['title'] ?? '',
              subtitle: paymentMeth['subtitle'] ?? '',
              last4: paymentMeth['last4'],
              brand: paymentMeth['brand'],
              expiry: paymentMeth['expiry'],
              isDefault: paymentMeth['isDefault'] ?? false,
            )
          : PaymentMethodItem(
              id: '',
              type: 'card',
              title: 'Visa',
              subtitle: '****',
            ),
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      trackingSteps: (m['trackingSteps'] as List? ?? [])
          .map((e) {
            final map = Map<String, dynamic>.from(e);
            return TrackingStep(
              title: map['title'] ?? '',
              description: map['description'] ?? '',
              time: (map['time'] as Timestamp?)?.toDate() ?? DateTime.now(),
              isCompleted: map['isCompleted'] ?? false,
            );
          })
          .toList(),
    );
  }

  OrderStatus _parseOrderStatus(String? status) {
    switch (status) {
      case 'placed':
        return OrderStatus.placed;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.placed;
    }
  }
}