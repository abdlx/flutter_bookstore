import 'package:flutter/material.dart';

import 'bookstore_theme_data.dart';

class AppTheme {
  static ThemeData get light => BookstoreThemeData.lightTheme;
  static ThemeData get dark =>
      BookstoreThemeData.lightTheme; // fallback to light luxury aesthetic
}
