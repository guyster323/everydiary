import 'package:flutter/material.dart';

/// 고대비 모드 테마
class HighContrastTheme {
  /// 고대비 색상 팔레트
  static const Color highContrastBlack = Color(0xFF000000);
  static const Color highContrastWhite = Color(0xFFFFFFFF);
  static const Color highContrastYellow = Color(0xFFFFFF00);
  static const Color highContrastBlue = Color(0xFF0000FF);
  static const Color highContrastRed = Color(0xFFFF0000);
  static const Color highContrastGreen = Color(0xFF00FF00);

  /// 고대비 라이트 테마
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: highContrastBlack,
      scaffoldBackgroundColor: highContrastWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: highContrastBlack,
        foregroundColor: highContrastWhite,
        elevation: 0,
      ),
      colorScheme: const ColorScheme.light(
        primary: highContrastBlack,
        onPrimary: highContrastWhite,
        secondary: highContrastBlue,
        onSecondary: highContrastWhite,
        surface: highContrastWhite,
        onSurface: highContrastBlack,
        error: highContrastRed,
        onError: highContrastWhite,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: highContrastBlack,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: highContrastBlack,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: highContrastBlack,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: highContrastBlack,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: highContrastBlack,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: highContrastBlack,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: highContrastBlack,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: highContrastBlack,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: highContrastBlack,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: highContrastBlack, fontSize: 16),
        bodyMedium: TextStyle(color: highContrastBlack, fontSize: 14),
        bodySmall: TextStyle(color: highContrastBlack, fontSize: 12),
        labelLarge: TextStyle(
          color: highContrastBlack,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: highContrastBlack,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: highContrastBlack,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: highContrastBlack,
          foregroundColor: highContrastWhite,
          side: const BorderSide(color: highContrastBlack, width: 2),
          minimumSize: const Size(48, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: highContrastBlack,
          side: const BorderSide(color: highContrastBlack, width: 2),
          minimumSize: const Size(48, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: highContrastBlack,
          minimumSize: const Size(48, 48),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: highContrastBlack, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: highContrastBlack, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: highContrastRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: highContrastRed, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: highContrastWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: highContrastBlack, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: highContrastBlack,
        thickness: 2,
      ),
    );
  }

  /// 고대비 다크 테마
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: highContrastWhite,
      scaffoldBackgroundColor: highContrastBlack,
      appBarTheme: const AppBarTheme(
        backgroundColor: highContrastBlack,
        foregroundColor: highContrastWhite,
        elevation: 0,
      ),
      colorScheme: const ColorScheme.dark(
        primary: highContrastWhite,
        onPrimary: highContrastBlack,
        secondary: highContrastYellow,
        onSecondary: highContrastBlack,
        surface: highContrastBlack,
        onSurface: highContrastWhite,
        error: highContrastRed,
        onError: highContrastWhite,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: highContrastWhite,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: highContrastWhite,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: highContrastWhite,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: highContrastWhite,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: highContrastWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: highContrastWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: highContrastWhite,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: highContrastWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: highContrastWhite,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: highContrastWhite, fontSize: 16),
        bodyMedium: TextStyle(color: highContrastWhite, fontSize: 14),
        bodySmall: TextStyle(color: highContrastWhite, fontSize: 12),
        labelLarge: TextStyle(
          color: highContrastWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: highContrastWhite,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: highContrastWhite,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: highContrastWhite,
          foregroundColor: highContrastBlack,
          side: const BorderSide(color: highContrastWhite, width: 2),
          minimumSize: const Size(48, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: highContrastWhite,
          side: const BorderSide(color: highContrastWhite, width: 2),
          minimumSize: const Size(48, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: highContrastWhite,
          minimumSize: const Size(48, 48),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: highContrastWhite, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: highContrastWhite, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: highContrastRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: highContrastRed, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: highContrastBlack,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: highContrastWhite, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: highContrastWhite,
        thickness: 2,
      ),
    );
  }
}
