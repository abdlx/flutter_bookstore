import 'package:flutter/material.dart';

import '../../core/theme/bookstore_tokens.dart';

class QuantityStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final double height;
  final Color? backgroundColor;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
    this.height = 36,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? BookstoreTokens.surfaceWarm,
        borderRadius: BorderRadius.circular(BookstoreTokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            enabled: quantity > min,
            onTap: () {
              if (quantity > min) {
                onChanged(quantity - 1);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              quantity.toString(),
              style: BookstoreTokens.body(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: BookstoreTokens.textPrimary,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            enabled: quantity < max,
            onTap: () {
              if (quantity < max) {
                onChanged(quantity + 1);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Center(
          child: Icon(
            icon,
            size: 16,
            color: enabled
                ? BookstoreTokens.textPrimary
                : BookstoreTokens.textMuted,
          ),
        ),
      ),
    );
  }
}
