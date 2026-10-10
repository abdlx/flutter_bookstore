import '../../core/models/address.dart';

abstract class AddressRepository {
  Future<List<AddressItem>> getAddresses();
  Stream<List<AddressItem>> watchAddresses();
  Future<AddressItem?> getDefaultAddress();
  Future<void> addAddress(AddressItem address);
  Future<void> updateAddress(AddressItem address);
  Future<void> deleteAddress(String id);
  Future<void> setDefaultAddress(String id);
}
