import 'package:flutter/material.dart';

import '../../core/theme/bookstore_tokens.dart';

class PremiumBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailingHeader;

  const PremiumBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.trailingHeader,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    Widget? trailingHeader,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PremiumBottomSheet(
        title: title,
        trailingHeader: trailingHeader,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: BookstoreTokens.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(BookstoreTokens.radiusCard + 4),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4.5,
              decoration: BoxDecoration(
                color: BookstoreTokens.border,
                borderRadius: BorderRadius.circular(BookstoreTokens.radiusPill),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: BookstoreTokens.body(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BookstoreTokens.textPrimary,
                  ),
                ),
                ?trailingHeader,
              ],
            ),
          ),
          const Divider(height: 1, color: BookstoreTokens.divider),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
