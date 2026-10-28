import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bookstore_tokens.dart';

class BookstoreThemeData {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: BookstoreTokens.primary,
      onPrimary: BookstoreTokens.white,
      primaryContainer: BookstoreTokens.accentSoft,
      onPrimaryContainer: BookstoreTokens.primaryDark,
      secondary: BookstoreTokens.primaryDark,
      onSecondary: BookstoreTokens.white,
      secondaryContainer: BookstoreTokens.surfaceWarm,
      onSecondaryContainer: BookstoreTokens.textPrimary,
      surface: BookstoreTokens.surface,
      onSurface: BookstoreTokens.textPrimary,
      surfaceDim: BookstoreTokens.surfaceWarm,
      surfaceBright: BookstoreTokens.white,
      surfaceContainerLowest: BookstoreTokens.white,
      surfaceContainerLow: BookstoreTokens.surfaceWarm,
      surfaceContainer: BookstoreTokens.surfaceMuted,
      surfaceContainerHigh: BookstoreTokens.border,
      surfaceContainerHighest: BookstoreTokens.border,
      onSurfaceVariant: BookstoreTokens.textSecondary,
      outline: BookstoreTokens.border,
      outlineVariant: BookstoreTokens.divider,
      error: BookstoreTokens.error,
      onError: BookstoreTokens.white,
      shadow: BookstoreTokens.black.withValues(alpha: 0.08),
    );

    final textTheme = TextTheme(
      // Display: Cormorant Garamond
      displayLarge: TextStyle(
        fontFamily: 'Cormorant Garamond',
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: BookstoreTokens.textPrimary,
        height: 1.15,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Cormorant Garamond',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: BookstoreTokens.textPrimary,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Cormorant Garamond',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: BookstoreTokens.textPrimary,
        height: 1.25,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Cormorant Garamond',
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: BookstoreTokens.textPrimary,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Cormorant Garamond',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: BookstoreTokens.textPrimary,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Cormorant Garamond',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: BookstoreTokens.textPrimary,
        height: 1.3,
      ),
      // Inter for UI, body, labels
      titleLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: BookstoreTokens.textPrimary,
        height: 1.35,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: BookstoreTokens.textPrimary,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: BookstoreTokens.textPrimary,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: BookstoreTokens.textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: BookstoreTokens.textPrimary,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: BookstoreTokens.textSecondary,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: BookstoreTokens.textPrimary,
        letterSpacing: 0.2,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: BookstoreTokens.textSecondary,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: BookstoreTokens.textMuted,
        letterSpacing: 0.1,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BookstoreTokens.background,
      textTheme: textTheme,
      fontFamily: 'Inter',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: BookstoreTokens.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: BookstoreTokens.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: BookstoreTokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide.none,
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BookstoreTokens.primary,
          foregroundColor: BookstoreTokens.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(
            BookstoreTokens.primaryButtonHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BookstoreTokens.radiusButton),
          ),
          textStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BookstoreTokens.primary,
          minimumSize: const Size.fromHeight(
            BookstoreTokens.primaryButtonHeight,
          ),
          side: const BorderSide(color: BookstoreTokens.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BookstoreTokens.radiusButton),
          ),
          textStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BookstoreTokens.primary,
          textStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BookstoreTokens.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BookstoreTokens.radiusInput),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BookstoreTokens.radiusInput),
          borderSide: const BorderSide(color: BookstoreTokens.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BookstoreTokens.radiusInput),
          borderSide: const BorderSide(
            color: BookstoreTokens.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BookstoreTokens.radiusInput),
          borderSide: const BorderSide(color: BookstoreTokens.error, width: 1),
        ),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: BookstoreTokens.textMuted,
          fontWeight: FontWeight.normal,
        ),
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: BookstoreTokens.textSecondary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: BookstoreTokens.divider,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: BookstoreTokens.surfaceWarm,
        selectedColor: BookstoreTokens.primary,
        disabledColor: BookstoreTokens.surfaceMuted,
        secondarySelectedColor: BookstoreTokens.primary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BookstoreTokens.radiusPill),
          side: BorderSide.none,
        ),
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: BookstoreTokens.textSecondary,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: BookstoreTokens.white,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: BookstoreTokens.surface,
        selectedItemColor: BookstoreTokens.primary,
        unselectedItemColor: BookstoreTokens.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
    );
  }
}
