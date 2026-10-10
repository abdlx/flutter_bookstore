import 'package:flutter/material.dart';

import '../../core/theme/bookstore_tokens.dart';

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const PremiumAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.onBack,
    this.actions,
    this.backgroundColor = Colors.transparent,
    this.centerTitle = true,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leading: showBackButton
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: _CircleIconButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: onBack ?? () => Navigator.of(context).maybePop(),
                ),
              ),
            )
          : null,
      title:
          titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: BookstoreTokens.body(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BookstoreTokens.textPrimary,
                  ),
                )
              : null),
      actions: actions != null ? [...actions!, const SizedBox(width: 8)] : null,
      bottom: bottom,
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: BookstoreTokens.iconButtonSize,
      height: BookstoreTokens.iconButtonSize,
      decoration: BoxDecoration(
        color: BookstoreTokens.surface,
        shape: BoxShape.circle,
        border: Border.all(color: BookstoreTokens.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            BookstoreTokens.iconButtonSize / 2,
          ),
          onTap: onTap,
          child: Icon(icon, size: 22, color: BookstoreTokens.textPrimary),
        ),
      ),
    );
  }
}
