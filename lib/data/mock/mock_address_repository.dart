import 'dart:async';

import '../../core/models/address.dart';
import '../contracts/address_repository.dart';
import 'mock_database.dart';

class MockAddressRepository implements AddressRepository {
  final MockDatabase _db = MockDatabase.instance;
  final StreamController<List<AddressItem>> _controller =
      StreamController<List<AddressItem>>.broadcast();

  MockAddressRepository() {
    Timer.run(() => _controller.add(List.unmodifiable(_db.addresses)));
  }

  @override
  Stream<List<AddressItem>> watchAddresses() => _controller.stream;

  @override
  Future<List<AddressItem>> getAddresses() async {
    return List.unmodifiable(_db.addresses);
  }

  @override
  Future<AddressItem?> getDefaultAddress() async {
    try {
      return _db.addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _db.addresses.isNotEmpty ? _db.addresses.first : null;
    }
  }

  @override
  Future<void> addAddress(AddressItem address) async {
    if (address.isDefault) {
      for (int i = 0; i < _db.addresses.length; i++) {
        _db.addresses[i] = _db.addresses[i].copyWith(isDefault: false);
      }
    }
    _db.addresses.add(address);
    _controller.add(List.unmodifiable(_db.addresses));
  }

  @override
  Future<void> updateAddress(AddressItem address) async {
    final index = _db.addresses.indexWhere((a) => a.id == address.id);
    if (index != -1) {
      if (address.isDefault) {
        for (int i = 0; i < _db.addresses.length; i++) {
          _db.addresses[i] = _db.addresses[i].copyWith(isDefault: false);
        }
      }
      _db.addresses[index] = address;
      _controller.add(List.unmodifiable(_db.addresses));
    }
  }

  @override
  Future<void> deleteAddress(String id) async {
    _db.addresses.removeWhere((a) => a.id == id);
    _controller.add(List.unmodifiable(_db.addresses));
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    for (int i = 0; i < _db.addresses.length; i++) {
      _db.addresses[i] = _db.addresses[i].copyWith(
        isDefault: _db.addresses[i].id == id,
      );
    }
    _controller.add(List.unmodifiable(_db.addresses));
  }
}
