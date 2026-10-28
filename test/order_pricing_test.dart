import 'package:bookstore_app/data/firestore/firestore_order_repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const settings = {
    'freeShippingThreshold': 50,
    'shippingFee': 5,
    'taxRate': 0.08,
  };
  Map<String, dynamic> item(double price, int quantity) => {
    'book': {'price': price},
    'quantity': quantity,
  };

  test('order pricing rounds currency in cents after percentage discounts', () {
    expect(
      calculateOrderTotals(
        [item(19.99, 2)],
        settings,
        {'active': true, 'type': 'percent', 'amount': 10},
      ),
      {
        'subtotal': 39.98,
        'shipping': 5.0,
        'tax': 2.88,
        'discount': 4.0,
        'total': 43.86,
      },
    );
  });

  test('fixed discount cannot exceed the item subtotal', () {
    final totals = calculateOrderTotals(
      [item(10, 1)],
      settings,
      {'active': true, 'type': 'fixed', 'amount': 30},
    );
    expect(totals['discount'], 10);
    expect(totals['tax'], 0);
    expect(totals['total'], 5);
  });

  test('shipping unlocks at the configured threshold', () {
    expect(calculateOrderTotals([item(25, 2)], settings, null)['shipping'], 0);
    expect(
      calculateOrderTotals([item(24.99, 2)], settings, null)['shipping'],
      5,
    );
  });

  test('expired and inactive promotions cannot reach checkout', () {
    for (final promo in [
      {'active': false, 'type': 'fixed', 'amount': 1},
      {'active': true, 'type': 'unknown', 'amount': 1},
      {'active': true, 'type': 'percent', 'amount': 101},
      {'active': true, 'type': 'fixed', 'amount': -1},
      {'active': true, 'type': 'fixed', 'amount': 1, 'expiresAt': '2000-01-01'},
      {'active': true, 'type': 'fixed', 'amount': 1, 'minimumSubtotal': 100},
    ]) {
      expect(
        () => calculateOrderTotals([item(10, 1)], settings, promo),
        throwsStateError,
      );
    }
  });
}
