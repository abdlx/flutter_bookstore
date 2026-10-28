import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/models/address.dart';
import '../../core/models/book.dart';
import '../../core/models/cart_item.dart';
import '../../core/models/order.dart';
import '../../core/models/payment_method.dart';
import '../../core/models/user_profile.dart';

DateTime readDate(dynamic value) => value is Timestamp
    ? value.toDate()
    : value is DateTime
    ? value
    : DateTime.tryParse(value?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);

BookItem readBook(String id, Map<String, dynamic> data) => BookItem.fromMap({
  ...data,
  'id': id,
  'publishedDate': readDate(data['publishedDate']).toIso8601String(),
});

UserProfile readProfile(String id, Map<String, dynamic> d) => UserProfile(
  id: id,
  fullName: d['fullName'] ?? '',
  email: d['email'] ?? '',
  phone: d['phone'],
  avatarUrl: d['avatarUrl'],
  role: d['role'] == 'admin' ? UserRole.admin : UserRole.customer,
  membershipTier: d['membershipTier'] ?? 'Member',
  memberSince: readDate(d['memberSince']),
);

Map<String, dynamic> writeAddress(AddressItem a) => {
  'label': a.label,
  'recipientName': a.recipientName,
  'phone': a.phone,
  'street': a.street,
  'city': a.city,
  'state': a.state,
  'postalCode': a.postalCode,
  'country': a.country,
  'isDefault': a.isDefault,
};
AddressItem readAddress(String id, Map<String, dynamic> d) => AddressItem(
  id: id,
  label: d['label'] ?? '',
  recipientName: d['recipientName'] ?? '',
  phone: d['phone'] ?? '',
  street: d['street'] ?? '',
  city: d['city'] ?? '',
  state: d['state'] ?? '',
  postalCode: d['postalCode'] ?? '',
  country: d['country'] ?? '',
  isDefault: d['isDefault'] == true,
);
Map<String, dynamic> writePayment(PaymentMethodItem p) => {
  'type': p.type,
  'title': p.title,
  'subtitle': p.subtitle,
  'isDefault': p.isDefault,
};
PaymentMethodItem readPayment(String id, Map<String, dynamic> d) =>
    PaymentMethodItem(
      id: id,
      type: d['type'] ?? '',
      title: d['title'] ?? '',
      subtitle: d['subtitle'] ?? '',
      last4: d['last4'],
      brand: d['brand'],
      expiry: d['expiry'],
      isDefault: d['isDefault'] == true,
    );
OrderItem readOrder(String id, Map<String, dynamic> d) => OrderItem(
  id: id,
  orderNumber: d['orderNumber'] ?? id,
  items: (d['items'] as List? ?? []).map((v) {
    final item = Map<String, dynamic>.from(v);
    return CartItem(
      id: item['bookId'],
      quantity: (item['quantity'] as num).toInt(),
      book: readBook(item['bookId'], Map<String, dynamic>.from(item['book'])),
    );
  }).toList(),
  subtotal: (d['subtotal'] as num).toDouble(),
  shipping: (d['shipping'] as num).toDouble(),
  tax: (d['tax'] as num).toDouble(),
  discount: (d['discount'] as num? ?? 0).toDouble(),
  total: (d['total'] as num).toDouble(),
  status: OrderStatus.values.firstWhere(
    (s) => s.name == d['status'],
    orElse: () => OrderStatus.placed,
  ),
  shippingAddress: readAddress(
    d['addressId'] ?? '',
    Map<String, dynamic>.from(d['shippingAddress']),
  ),
  paymentMethod: readPayment(
    d['paymentMethodId'] ?? '',
    Map<String, dynamic>.from(d['paymentMethod']),
  ),
  createdAt: readDate(d['createdAt']),
  trackingSteps:
      (d['statusHistory'] as Map? ?? {}).entries
          .map(
            (e) => TrackingStep(
              title:
                  e.key.toString()[0].toUpperCase() +
                  e.key.toString().substring(1),
              description: '',
              time: readDate(e.value),
              isCompleted: true,
            ),
          )
          .toList()
        ..sort((a, b) => a.time.compareTo(b.time)),
);
