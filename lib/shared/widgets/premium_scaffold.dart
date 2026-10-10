import 'package:flutter/material.dart';

import '../../core/theme/bookstore_tokens.dart';

class PremiumScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;
  final bool safeArea;

  const PremiumScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.floatingActionButton,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.extendBodyBehindAppBar = false,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;
    if (safeArea) {
      content = SafeArea(
        top: !extendBodyBehindAppBar,
        bottom: bottomNavigationBar == null && bottomSheet == null,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? BookstoreTokens.background,
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}
