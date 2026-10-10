import '../../core/models/payment_method.dart';

abstract class PaymentMethodRepository {
  Future<List<PaymentMethodItem>> getPaymentMethods();
  Stream<List<PaymentMethodItem>> watchPaymentMethods();
  Future<PaymentMethodItem?> getDefaultPaymentMethod();
  Future<void> addPaymentMethod(PaymentMethodItem paymentMethod);
  Future<void> deletePaymentMethod(String id);
  Future<void> setDefaultPaymentMethod(String id);
}
