import 'dart:async';

import '../../core/models/payment_method.dart';
import '../contracts/payment_method_repository.dart';
import 'mock_database.dart';

class MockPaymentMethodRepository implements PaymentMethodRepository {
  final MockDatabase _db = MockDatabase.instance;
  final StreamController<List<PaymentMethodItem>> _controller =
      StreamController<List<PaymentMethodItem>>.broadcast();

  MockPaymentMethodRepository() {
    Timer.run(() => _controller.add(List.unmodifiable(_db.paymentMethods)));
  }

  @override
  Stream<List<PaymentMethodItem>> watchPaymentMethods() => _controller.stream;

  @override
  Future<List<PaymentMethodItem>> getPaymentMethods() async {
    return List.unmodifiable(_db.paymentMethods);
  }

  @override
  Future<PaymentMethodItem?> getDefaultPaymentMethod() async {
    try {
      return _db.paymentMethods.firstWhere((p) => p.isDefault);
    } catch (_) {
      return _db.paymentMethods.isNotEmpty ? _db.paymentMethods.first : null;
    }
  }

  @override
  Future<void> addPaymentMethod(PaymentMethodItem paymentMethod) async {
    if (paymentMethod.isDefault) {
      for (int i = 0; i < _db.paymentMethods.length; i++) {
        _db.paymentMethods[i] = _db.paymentMethods[i].copyWith(
          isDefault: false,
        );
      }
    }
    _db.paymentMethods.add(paymentMethod);
    _controller.add(List.unmodifiable(_db.paymentMethods));
  }

  @override
  Future<void> deletePaymentMethod(String id) async {
    _db.paymentMethods.removeWhere((p) => p.id == id);
    _controller.add(List.unmodifiable(_db.paymentMethods));
  }

  @override
  Future<void> setDefaultPaymentMethod(String id) async {
    for (int i = 0; i < _db.paymentMethods.length; i++) {
      _db.paymentMethods[i] = _db.paymentMethods[i].copyWith(
        isDefault: _db.paymentMethods[i].id == id,
      );
    }
    _controller.add(List.unmodifiable(_db.paymentMethods));
  }
}
