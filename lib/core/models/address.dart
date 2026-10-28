class AddressItem {
  final String id;
  final String label; // 'Home', 'Office'
  final String recipientName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;

  const AddressItem({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = '',
    this.isDefault = false,
  });

  String get formattedAddress => '$street, $city, $state $postalCode, $country';

  AddressItem copyWith({
    String? id,
    String? label,
    String? recipientName,
    String? phone,
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
  }) {
    return AddressItem(
      id: id ?? this.id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
