import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color lightPrimaryColor = Color(0xFF1976D2);
  static const Color lightSecondaryColor = Color(0xFF42A5F5);
  static const Color lightAccentColor = Color(0xFFFF6F00);
  static const Color lightBackgroundColor = Color(0xFFF5F5F5);
  static const Color lightSurfaceColor = Colors.white;
  static const Color lightErrorColor = Color(0xFFE53935);

  static const Color darkPrimaryColor = Color(0xFF0D47A1);
  static const Color darkSecondaryColor = Color(0xFF1E88E5);
  static const Color darkAccentColor = Color(0xFFFF8F00);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkErrorColor = Color(0xFFEF5350);

  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightTextHint = Color(0xFF9E9E9E);

  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFBDBDBD);
  static const Color darkTextHint = Color(0xFF757575);

  static const String titleFontFamily = 'OrangeJuice';
  static const String bodyFontFamily = 'Lato';

  static TextTheme get _lightTextTheme => TextTheme(
    displayLarge: TextStyle(
      fontFamily: titleFontFamily,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      color: lightTextPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: titleFontFamily,
      fontSize: 45,
      fontWeight: FontWeight.w400,
      color: lightTextPrimary,
    ),
    displaySmall: TextStyle(
      fontFamily: titleFontFamily,
      fontSize: 36,
      fontWeight: FontWeight.w400,
      color: lightTextPrimary,
    ),
    headlineLarge: TextStyle(
      fontFamily: titleFontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: lightTextPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: titleFontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w400,
      color: lightTextPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: titleFontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: lightTextPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: titleFontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: lightTextPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: lightTextPrimary,
    ),
    titleSmall: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: lightTextPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: lightTextPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: lightTextPrimary,
    ),
    bodySmall: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: lightTextSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: lightTextPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: lightTextPrimary,
    ),
    labelSmall: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: lightTextSecondary,
    ),
  );

  static TextTheme get _darkTextTheme => TextTheme(
    displayLarge: TextStyle(
      fontFamily: titleFontFamily,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      color: darkTextPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: titleFontFamily,
      fontSize: 45,
      fontWeight: FontWeight.w400,
      color: darkTextPrimary,
    ),
    displaySmall: TextStyle(
      fontFamily: titleFontFamily,
      fontSize: 36,
      fontWeight: FontWeight.w400,
      color: darkTextPrimary,
    ),
    headlineLarge: TextStyle(
      fontFamily: titleFontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: darkTextPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: titleFontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w400,
      color: darkTextPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: titleFontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: darkTextPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: titleFontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: darkTextPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: darkTextPrimary,
    ),
    titleSmall: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: darkTextPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: darkTextPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: darkTextPrimary,
    ),
    bodySmall: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: darkTextSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: darkTextPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: darkTextPrimary,
    ),
    labelSmall: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: darkTextSecondary,
    ),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: bodyFontFamily,
      textTheme: _lightTextTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightPrimaryColor,
        brightness: Brightness.light,
        primary: lightPrimaryColor,
        secondary: lightSecondaryColor,
        surface: lightSurfaceColor,
        error: lightErrorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: lightBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: lightPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: titleFontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: lightSurfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimaryColor,
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontFamily: bodyFontFamily,
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightPrimaryColor,
          textStyle: TextStyle(
            fontFamily: bodyFontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: TextStyle(
          fontFamily: bodyFontFamily,
          color: lightTextSecondary,
        ),
        hintStyle: TextStyle(fontFamily: bodyFontFamily, color: lightTextHint),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: bodyFontFamily,
      textTheme: _darkTextTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimaryColor,
        brightness: Brightness.dark,
        primary: darkPrimaryColor,
        secondary: darkSecondaryColor,
        surface: darkSurfaceColor,
        error: darkErrorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurfaceColor,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: titleFontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: darkTextPrimary,
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: darkSurfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontFamily: bodyFontFamily,
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkSecondaryColor,
          textStyle: TextStyle(
            fontFamily: bodyFontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: TextStyle(
          fontFamily: bodyFontFamily,
          color: darkTextSecondary,
        ),
        hintStyle: TextStyle(fontFamily: bodyFontFamily, color: darkTextHint),
      ),
    );
  }
}
