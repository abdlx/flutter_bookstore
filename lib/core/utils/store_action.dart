import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/app_providers.dart';

Future<bool> storeAction(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function() action,
) async {
  if (ref.read(firebaseAuthProvider).currentUser == null) {
    context.push('/login');
    return false;
  }
  try {
    await action();
    return context.mounted;
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to complete this action: $error')),
      );
    }
    return false;
  }
}
