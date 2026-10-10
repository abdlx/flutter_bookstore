import 'package:flutter/material.dart';

import '../../core/theme/bookstore_tokens.dart';

class OrderSummary extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;
  final bool showDivider;

  const OrderSummary({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    this.discount = 0.0,
    required this.total,
    this.showDivider = false,
  });

  String _format(double v) {
    if (v == v.roundToDouble()) return '\$${v.toInt()}';
    return '\$${v.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRow('Subtotal', _format(subtotal)),
        const SizedBox(height: 12),
        _buildRow('Shipping', shipping == 0.0 ? 'Free' : _format(shipping)),
        const SizedBox(height: 12),
        _buildRow('Estimated Tax', _format(tax)),
        if (discount > 0) ...[
          const SizedBox(height: 12),
          _buildRow(
            'Discount',
            '-${_format(discount)}',
            valueColor: BookstoreTokens.success,
          ),
        ],
        if (showDivider) ...[
          const SizedBox(height: 16),
          const Divider(color: BookstoreTokens.divider),
          const SizedBox(height: 16),
        ] else ...[
          const SizedBox(height: 22),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Total',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191C24),
              ),
            ),
            Text(
              _format(total),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191C24),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: BookstoreTokens.body(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: BookstoreTokens.textSecondary,
          ),
        ),
        Text(
          value,
          style: BookstoreTokens.body(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? BookstoreTokens.textPrimary,
          ),
        ),
      ],
    );
  }
}
