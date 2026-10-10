import 'package:flutter/material.dart';

import '../../core/theme/bookstore_tokens.dart';

class PremiumSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;

  const PremiumSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search books, authors or genres...',
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF2EFEB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        autofocus: autofocus,
        onTap: onTap,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        style: BookstoreTokens.body(
          fontSize: 14,
          color: BookstoreTokens.textPrimary,
        ),
        decoration: InputDecoration(
          filled: false,
          hintText: hintText,
          hintStyle: BookstoreTokens.body(
            fontSize: 13.5,
            color: BookstoreTokens.textMuted,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: BookstoreTokens.textSecondary,
            size: 22,
          ),
          suffixIcon: onFilterTap != null
              ? IconButton(
                  icon: const Icon(
                    Icons.tune_rounded,
                    color: BookstoreTokens.textSecondary,
                    size: 20,
                  ),
                  onPressed: onFilterTap,
                  tooltip: 'Filter',
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
