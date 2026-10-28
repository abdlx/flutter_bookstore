import 'package:flutter/material.dart';

import '../../core/theme/bookstore_tokens.dart';

enum PremiumButtonVariant { primary, secondary, outline, dark }

class PremiumButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool isLoading;
  final PremiumButtonVariant variant;
  final double height;
  final double? width;
  final double borderRadius;

  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.variant = PremiumButtonVariant.primary,
    this.height = BookstoreTokens.primaryButtonHeight,
    this.width,
    this.borderRadius = BookstoreTokens.radiusButton,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Border? border;
    List<BoxShadow>? shadows;

    switch (variant) {
      case PremiumButtonVariant.primary:
        bg = BookstoreTokens.primary;
        fg = Colors.white;
        shadows = [
          BoxShadow(
            color: BookstoreTokens.primary.withValues(alpha: 0.32),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ];
        break;
      case PremiumButtonVariant.secondary:
        bg = BookstoreTokens.surfaceWarm;
        fg = BookstoreTokens.textPrimary;
        border = Border.all(color: BookstoreTokens.border, width: 1);
        break;
      case PremiumButtonVariant.outline:
        bg = Colors.transparent;
        fg = BookstoreTokens.primary;
        border = Border.all(color: BookstoreTokens.primary, width: 1.5);
        break;
      case PremiumButtonVariant.dark:
        bg = BookstoreTokens.textPrimary;
        fg = BookstoreTokens.white;
        shadows = [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ];
        break;
    }

    final isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      height: height,
      width: width,
      child: Material(
        color: isEnabled ? bg : bg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: border,
              boxShadow: isEnabled ? shadows : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation(fg),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (leadingIcon != null) ...[
                          leadingIcon!,
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: BookstoreTokens.body(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: fg,
                            ),
                          ),
                        ),
                        if (trailingIcon != null) ...[
                          const SizedBox(width: 8),
                          trailingIcon!,
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
