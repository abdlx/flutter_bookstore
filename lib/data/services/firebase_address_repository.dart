import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../contracts/address_repository.dart';
import '../../core/models/address.dart';

class FirebaseAddressRepository implements AddressRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _addressesCol {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('User not authenticated');
    }
    return _db.collection('users').doc(uid).collection('addresses');
  }

  @override
  Future<List<AddressItem>> getAddresses() async {
    final snap = await _addressesCol.get();
    return snap.docs.map((d) => _addressFromDoc(d.id, d.data())).toList();
  }

  @override
  Stream<List<AddressItem>> watchAddresses() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value([]);
    }
    return _db
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => _addressFromDoc(d.id, d.data())).toList());
  }

  @override
  Future<AddressItem?> getDefaultAddress() async {
    final snap = await _addressesCol.where('isDefault', isEqualTo: true).get();
    if (snap.docs.isEmpty) {
      final all = await _addressesCol.get();
      if (all.docs.isEmpty) return null;
      return _addressFromDoc(all.docs.first.id, all.docs.first.data());
    }
    return _addressFromDoc(snap.docs.first.id, snap.docs.first.data());
  }

  @override
  Future<void> addAddress(AddressItem address) async {
    if (address.isDefault) {
      await _clearDefaultAddresses();
    }
    await _addressesCol.add(_addressToMap(address));
  }

  @override
  Future<void> updateAddress(AddressItem address) async {
    if (address.isDefault) {
      await _clearDefaultAddresses();
    }
    await _addressesCol.doc(address.id).update(_addressToMap(address));
  }

  @override
  Future<void> deleteAddress(String id) async {
    await _addressesCol.doc(id).delete();
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    final batch = _db.batch();
    final snap = await _addressesCol.get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == id});
    }
    await batch.commit();
  }

  Future<void> _clearDefaultAddresses() async {
    final snap = await _addressesCol.where('isDefault', isEqualTo: true).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }

  AddressItem _addressFromDoc(String id, Map<String, dynamic> m) {
    return AddressItem(
      id: id,
      label: m['label'] ?? '',
      recipientName: m['recipientName'] ?? '',
      phone: m['phone'] ?? '',
      street: m['street'] ?? '',
      city: m['city'] ?? '',
      state: m['state'] ?? '',
      postalCode: m['postalCode'] ?? '',
      country: m['country'] ?? 'United States',
      isDefault: m['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> _addressToMap(AddressItem address) {
    return {
      'label': address.label,
      'recipientName': address.recipientName,
      'phone': address.phone,
      'street': address.street,
      'city': address.city,
      'state': address.state,
      'postalCode': address.postalCode,
      'country': address.country,
      'isDefault': address.isDefault,
    };
  }
}