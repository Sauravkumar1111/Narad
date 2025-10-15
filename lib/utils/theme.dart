import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF00BCD4); // Neon Cyan
  static const Color secondaryColor = Color(0xFF2196F3); // Blue
  static const Color accentColor = Color(0xFF00E676); // Neon Green
  static const Color errorColor = Color(0xFFFF5252); // Red
  static const Color warningColor = Color(0xFFFFC107); // Amber
  static const Color successColor = Color(0xFF4CAF50); // Green

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2D2D2D);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF5F5F5);
  static const Color lightText = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);

  // Chat Colors
  static const Color userMessageColor = primaryColor;
  static const Color jarvisMessageColor = Color(0xFF424242);
  static const Color chatBackground = Color(0xFF0A0A0A);

  // Voice Colors
  static const Color voiceActiveColor = accentColor;
  static const Color voiceInactiveColor = Color(0xFF666666);
  static const Color voiceWaveColor = primaryColor;

  // Camera Colors
  static const Color cameraOverlayColor = Color(0x80000000);
  static const Color cameraButtonColor = primaryColor;
  static const Color cameraButtonInactiveColor = Color(0xFF666666);

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkText,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: darkCard,
        elevation: 4,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: darkText, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: darkText, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: darkText, fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: darkText, fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: darkText, fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: darkText, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: darkText, fontSize: 16, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: darkText, fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: darkText, fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: darkText, fontSize: 16),
        bodyMedium: TextStyle(color: darkText, fontSize: 14),
        bodySmall: TextStyle(color: darkTextSecondary, fontSize: 12),
        labelLarge: TextStyle(color: darkText, fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: darkText, fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: darkTextSecondary, fontSize: 10, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: darkText,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: darkText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: const TextStyle(color: darkTextSecondary),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkSurface,
        background: darkBackground,
        error: errorColor,
        onPrimary: darkText,
        onSecondary: darkText,
        onSurface: darkText,
        onBackground: darkText,
        onError: darkText,
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightText,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: lightCard,
        elevation: 4,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: lightText, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: lightText, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: lightText, fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: lightText, fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: lightText, fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: lightText, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: lightText, fontSize: 16, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: lightText, fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: lightText, fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: lightText, fontSize: 16),
        bodyMedium: TextStyle(color: lightText, fontSize: 14),
        bodySmall: TextStyle(color: lightTextSecondary, fontSize: 12),
        labelLarge: TextStyle(color: lightText, fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: lightText, fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: lightTextSecondary, fontSize: 10, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: lightText,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: lightText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: const TextStyle(color: lightTextSecondary),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurface,
        background: lightBackground,
        error: errorColor,
        onPrimary: lightText,
        onSecondary: lightText,
        onSurface: lightText,
        onBackground: lightText,
        onError: lightText,
      ),
    );
  }
}
