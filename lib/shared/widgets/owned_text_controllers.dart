import 'package:flutter/material.dart';

/// Keep form controllers alive until the route's closing animation finishes.
class OwnedTextControllers extends StatefulWidget {
  final List<TextEditingController> controllers;
  final Widget child;
  const OwnedTextControllers({
    super.key,
    required this.controllers,
    required this.child,
  });
  @override
  State<OwnedTextControllers> createState() => _OwnedTextControllersState();
}

class _OwnedTextControllersState extends State<OwnedTextControllers> {
  @override
  void dispose() {
    for (final controller in widget.controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
