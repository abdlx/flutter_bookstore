import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Strongly-typed Dart representation of bookstore_theme.json design tokens.
class BookstoreTokens {
  // Meta
  static const String themeName = 'Bookstore Premium';
  static const String version = '1.0.0';
  static const String designLanguage = 'Warm editorial luxury';

  // Colors
  static const Color background = Color(0xFFFFFCF8);
  static const Color backgroundWarm = Color(0xFFF5EBDD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceWarm = Color(0xFFFAF4EB);
  static const Color surfaceMuted = Color(0xFFF4F0EA);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  static const Color primary = Color(0xFFC99442);
  static const Color primaryDark = Color(0xFFA76E24);
  static const Color primaryLight = Color(0xFFE6BF82);
  static const Color accentSoft = Color(0xFFF9EEDC);

  static const Color textPrimary = Color(0xFF191C24);
  static const Color textSecondary = Color(0xFF777A80);
  static const Color textMuted = Color(0xFFA4A4A8);

  static const Color border = Color(0xFFEAE5DD);
  static const Color divider = Color(0xFFEEEAE4);

  static const Color success = Color(0xFF39815B);
  static const Color error = Color(0xFFCC4545);
  static const Color warning = Color(0xFFD99B26);
  static const Color rating = Color(0xFFF5AE21);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Spacing
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceBase = 16.0;
  static const double spaceLg = 20.0;
  static const double spaceXl = 24.0;
  static const double spaceXxl = 32.0;
  static const double spaceSection = 36.0;

  // Radii
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusCard = 18.0;
  static const double radiusInput = 16.0;
  static const double radiusButton = 15.0;
  static const double radiusPill = 999.0;

  // Component geometries
  static const double bookCoverAspectRatio = 0.68;
  static const double bookCoverRadius = 9.0;
  static const double primaryButtonHeight = 54.0;
  static const double iconButtonSize = 44.0;
  static const double bottomNavHeight = 72.0;
  static const double horizontalPadding = 20.0;
  static const double sectionSpacing = 28.0;

  // Motion
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);
  static const Curve defaultCurve = Curves.easeInOut;

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0D000000), // opacity 0.05
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Color(0x1A000000), // opacity 0.10
      blurRadius: 28,
      spreadRadius: 0,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> bookShadow = [
    BoxShadow(
      color: Color(0x2E000000), // opacity 0.18
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> heroBookShadow = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 32,
      spreadRadius: -4,
      offset: Offset(0, 16),
    ),
  ];

  // Typography styles helper
  static TextStyle display({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: 'Cormorant Garamond',
      fontSize: fontSize ?? 34,
      fontWeight: fontWeight ?? FontWeight.bold,
      color: color ?? textPrimary,
      height: height ?? 1.15,
      fontStyle: fontStyle,
    );
  }

  static TextStyle body({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? textPrimary,
      height: height ?? 1.4,
      decoration: decoration,
    );
  }

  /// Optional loader that verifies that bookstore_theme.json is readable and valid.
  static Future<Map<String, dynamic>> loadTokensFromJson() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/theme/bookstore_theme.json',
      );
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
