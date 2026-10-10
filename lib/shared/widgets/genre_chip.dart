import 'package:flutter/material.dart';

import '../../core/theme/bookstore_tokens.dart';

class GenreChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GenreChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: BookstoreTokens.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFBA7822)
              : const Color(0xFFF7F3EC).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(BookstoreTokens.radiusPill),
          border: isSelected
              ? null
              : Border.all(
                  color: const Color(0xFFEBE6DC).withValues(alpha: 0.7),
                  width: 0.8,
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFBA7822).withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: BookstoreTokens.body(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? BookstoreTokens.white
                  : BookstoreTokens.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
