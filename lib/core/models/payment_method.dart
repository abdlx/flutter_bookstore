class PaymentMethodItem {
  final String id;
  final String type; // 'card', 'apple_pay', 'cod'
  final String title;
  final String subtitle;
  final String? last4;
  final String? brand; // 'Visa', 'Mastercard'
  final String? expiry; // '12/28'
  final bool isDefault;

  const PaymentMethodItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.last4,
    this.brand,
    this.expiry,
    this.isDefault = false,
  });

  PaymentMethodItem copyWith({
    String? id,
    String? type,
    String? title,
    String? subtitle,
    String? last4,
    String? brand,
    String? expiry,
    bool? isDefault,
  }) {
    return PaymentMethodItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      last4: last4 ?? this.last4,
      brand: brand ?? this.brand,
      expiry: expiry ?? this.expiry,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
