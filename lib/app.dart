import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router/app_router.dart';
import 'core/theme/bookstore_theme_data.dart';

class BookStoreApp extends ConsumerWidget {
  const BookStoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Aptech Book Store',
      debugShowCheckedModeBanner: false,
      theme: BookstoreThemeData.lightTheme,
      routerConfig: router,
    );
  }
}
