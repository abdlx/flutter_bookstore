class Promotion {
  final String code;
  final bool active;
  final String type;
  final double amount;
  final double minimumSubtotal;
  final DateTime? expiresAt;
  const Promotion({
    required this.code,
    required this.active,
    required this.type,
    required this.amount,
    this.minimumSubtotal = 0,
    this.expiresAt,
  });
  bool get expired => expiresAt != null && !expiresAt!.isAfter(DateTime.now());
  void validate() {
    if (!RegExp(r'^[A-Z0-9_-]{2,40}$').hasMatch(code) ||
        !['fixed', 'percent'].contains(type) ||
        !amount.isFinite ||
        amount <= 0 ||
        (type == 'percent' && amount > 100) ||
        !minimumSubtotal.isFinite ||
        minimumSubtotal < 0) {
      throw ArgumentError(
        'Enter a valid code, positive discount and nonnegative minimum subtotal.',
      );
    }
  }
}
