import 'package:flutter/material.dart';

import '../theme/bookstore_tokens.dart';

/// Legacy AppColors aliasing the canonical BookstoreTokens.
/// Ensures 100% backward compatibility for teammate code.
class AppColors {
  static const Color primary = BookstoreTokens.primary;
  static const Color primaryDark = BookstoreTokens.primaryDark;
  static const Color primaryLight = BookstoreTokens.primaryLight;
  static const Color secondary = BookstoreTokens.primaryDark;
  static const Color accentSoft = BookstoreTokens.accentSoft;

  static const Color background = BookstoreTokens.background;
  static const Color backgroundWarm = BookstoreTokens.backgroundWarm;
  static const Color darkBackground = Color(0xFF141312);

  static const Color surface = BookstoreTokens.surface;
  static const Color surfaceWarm = BookstoreTokens.surfaceWarm;
  static const Color surfaceMuted = BookstoreTokens.surfaceMuted;

  static const Color textPrimary = BookstoreTokens.textPrimary;
  static const Color textSecondary = BookstoreTokens.textSecondary;
  static const Color textMuted = BookstoreTokens.textMuted;

  static const Color border = BookstoreTokens.border;
  static const Color divider = BookstoreTokens.divider;

  static const Color success = BookstoreTokens.success;
  static const Color error = BookstoreTokens.error;
  static const Color warning = BookstoreTokens.warning;
  static const Color rating = BookstoreTokens.rating;
}
