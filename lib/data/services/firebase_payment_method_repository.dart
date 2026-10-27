import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../contracts/payment_method_repository.dart';
import '../../core/models/payment_method.dart';

class FirebasePaymentMethodRepository
    implements PaymentMethodRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _paymentMethodsCol {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('User not authenticated');
    }
    return _db.collection('users').doc(uid).collection('paymentMethods');
  }

  @override
  Future<List<PaymentMethodItem>> getPaymentMethods() async {
    final snap = await _paymentMethodsCol.get();
    return snap.docs.map((d) => _paymentFromDoc(d.id, d.data())).toList();
  }

  @override
  Stream<List<PaymentMethodItem>> watchPaymentMethods() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value([]);
    }
    return _db
        .collection('users')
        .doc(uid)
        .collection('paymentMethods')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => _paymentFromDoc(d.id, d.data())).toList());
  }

  @override
  Future<PaymentMethodItem?> getDefaultPaymentMethod() async {
    final snap = await _paymentMethodsCol.where('isDefault', isEqualTo: true).get();
    if (snap.docs.isEmpty) {
      final all = await _paymentMethodsCol.get();
      if (all.docs.isEmpty) return null;
      return _paymentFromDoc(all.docs.first.id, all.docs.first.data());
    }
    return _paymentFromDoc(snap.docs.first.id, snap.docs.first.data());
  }

  @override
  Future<void> addPaymentMethod(PaymentMethodItem paymentMethod) async {
    if (paymentMethod.isDefault) {
      await _clearDefaultPaymentMethods();
    }
    await _paymentMethodsCol.add(_paymentToMap(paymentMethod));
  }

  @override
  Future<void> deletePaymentMethod(String id) async {
    await _paymentMethodsCol.doc(id).delete();
  }

  @override
  Future<void> setDefaultPaymentMethod(String id) async {
    final batch = _db.batch();
    final snap = await _paymentMethodsCol.get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == id});
    }
    await batch.commit();
  }

  Future<void> _clearDefaultPaymentMethods() async {
    final snap = await _paymentMethodsCol.where('isDefault', isEqualTo: true).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }

  PaymentMethodItem _paymentFromDoc(String id, Map<String, dynamic> m) {
    return PaymentMethodItem(
      id: id,
      type: m['type'] ?? 'card',
      title: m['title'] ?? '',
      subtitle: m['subtitle'] ?? '',
      last4: m['last4'],
      brand: m['brand'],
      expiry: m['expiry'],
      isDefault: m['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> _paymentToMap(PaymentMethodItem payment) {
    return {
      'type': payment.type,
      'title': payment.title,
      'subtitle': payment.subtitle,
      'last4': payment.last4,
      'brand': payment.brand,
      'expiry': payment.expiry,
      'isDefault': payment.isDefault,
    };
  }
}