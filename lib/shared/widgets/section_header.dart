import 'package:flutter/material.dart';

import '../../core/theme/bookstore_tokens.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText = 'See all',
    this.onActionTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: BookstoreTokens.body(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BookstoreTokens.textPrimary,
            ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionText!,
                    style: BookstoreTokens.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: BookstoreTokens.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: BookstoreTokens.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
