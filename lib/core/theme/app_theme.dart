import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 앱 테마 설정
class AppTheme {
  // Material Design 3 기반 컬러 팔레트 (심리적 안정감을 주는 색상)

  // 부드러운 블루 팔레트 (#E3F2FD, #BBDEFB)
  static const Color primaryBlue = Color(0xFF1976D2); // Primary
  static const Color primaryBlueLight = Color(0xFFBBDEFB); // Light variant
  static const Color primaryBlueDark = Color(0xFF0D47A1); // Dark variant
  static const Color primaryBlueContainer = Color(0xFFE3F2FD); // Container

  // 따뜻한 베이지 팔레트 (#FFF8E1, #FFECB3)
  static const Color secondaryBeige = Color(0xFFF57C00); // Secondary
  static const Color secondaryBeigeLight = Color(0xFFFFECB3); // Light variant
  static const Color secondaryBeigeDark = Color(0xFFE65100); // Dark variant
  static const Color secondaryBeigeContainer = Color(0xFFFFF8E1); // Container

  // 차분한 회백색 팔레트 (#F5F5F5, #EEEEEE)
  static const Color neutralGray = Color(0xFF616161); // Neutral
  static const Color neutralGrayLight = Color(0xFFEEEEEE); // Light variant
  static const Color neutralGrayDark = Color(0xFF424242); // Dark variant
  static const Color neutralGrayContainer = Color(0xFFF5F5F5); // Container

  // 시스템 컬러
  static const Color positiveGreen = Color(0xFF4CAF50); // Success
  static const Color warningOrange = Color(0xFFFF9800); // Warning
  static const Color errorRed = Color(0xFFF44336); // Error
  static const Color infoBlue = Color(0xFF2196F3); // Info

  // 표면 컬러
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Surface
  static const Color surfaceVariant = Color(0xFFF8F9FA); // Surface variant
  static const Color backgroundLight = Color(0xFFFAFAFA); // Background

  // 텍스트 컬러
  static const Color textPrimary = Color(0xFF212121); // On surface
  static const Color textSecondary = Color(0xFF757575); // On surface variant
  static const Color textDisabled = Color(0xFFBDBDBD); // Disabled

  // 다크 모드 컬러 팔레트
  static const Color darkPrimary = Color(0xFF90CAF9); // Primary
  static const Color darkPrimaryContainer = Color(
    0xFF1565C0,
  ); // Primary container
  static const Color darkSecondary = Color(0xFFFFCC02); // Secondary
  static const Color darkSecondaryContainer = Color(
    0xFFE65100,
  ); // Secondary container
  static const Color darkSurface = Color(0xFF121212); // Surface
  static const Color darkSurfaceVariant = Color(0xFF1E1E1E); // Surface variant
  static const Color darkBackground = Color(0xFF0A0A0A); // Background
  static const Color darkOnSurface = Color(0xFFE0E0E0); // On surface
  static const Color darkOnSurfaceVariant = Color(
    0xFFB0B0B0,
  ); // On surface variant

  /// 라이트 테마
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Material Design 3 ColorScheme
      colorScheme: const ColorScheme.light(
        // Primary colors
        primary: primaryBlue,
        onPrimary: Colors.white,
        primaryContainer: primaryBlueContainer,
        onPrimaryContainer: primaryBlueDark,

        // Secondary colors
        secondary: secondaryBeige,
        onSecondary: Colors.white,
        secondaryContainer: secondaryBeigeContainer,
        onSecondaryContainer: secondaryBeigeDark,

        // Tertiary colors (neutral)
        tertiary: neutralGray,
        onTertiary: Colors.white,
        tertiaryContainer: neutralGrayContainer,
        onTertiaryContainer: neutralGrayDark,

        // Surface colors
        surface: surfaceWhite,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        surfaceContainerHighest: neutralGrayLight,

        // Error colors
        error: errorRed,
        onError: Colors.white,
        errorContainer: Color(0xFFFFEBEE),
        onErrorContainer: Color(0xFFB71C1C),

        // Outline colors
        outline: textDisabled,
        outlineVariant: neutralGrayLight,

        // Shadow
        shadow: Colors.black,
        scrim: Colors.black,

        // Inverse colors
        inverseSurface: neutralGrayDark,
        onInverseSurface: Colors.white,
        inversePrimary: primaryBlueLight,
      ),

      // 앱바 테마
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.notoSans(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textPrimary, size: 24),
        actionsIconTheme: const IconThemeData(color: textPrimary, size: 24),
      ),

      // 카드 테마
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),

      // 버튼 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 1,
          shadowColor: primaryBlue.withValues(alpha: 0.3),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'NotoSansKR',
          ),
        ),
      ),

      // 텍스트 버튼 테마
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'NotoSansKR',
          ),
        ),
      ),

      // 아웃라인 버튼 테마
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'NotoSansKR',
          ),
        ),
      ),

      // 입력 필드 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: textDisabled, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: textSecondary,
          fontSize: 16,
          fontFamily: 'NotoSansKR',
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 16,
          fontFamily: 'NotoSansKR',
        ),
        floatingLabelStyle: const TextStyle(
          color: primaryBlue,
          fontSize: 14,
          fontFamily: 'NotoSansKR',
        ),
      ),

      // 텍스트 테마
      textTheme: GoogleFonts.notoSansTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 57,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            height: 1.12,
          ),
          displayMedium: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            height: 1.16,
          ),
          displaySmall: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            height: 1.22,
          ),
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            height: 1.25,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            height: 1.29,
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            height: 1.33,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            height: 1.27,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            height: 1.50,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            height: 1.43,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            height: 1.50,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            height: 1.43,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            height: 1.33,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            height: 1.43,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            height: 1.33,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textSecondary,
            height: 1.45,
          ),
        ),
      ),

      // 스크롤바 테마
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(primaryBlue.withValues(alpha: 0.7)),
        trackColor: WidgetStateProperty.all(primaryBlue.withValues(alpha: 0.1)),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(6),
      ),

      // 다이얼로그 테마
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceWhite,
        elevation: 3,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          fontFamily: 'NotoSansKR',
        ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          color: textPrimary,
          fontFamily: 'NotoSansKR',
        ),
      ),

      // 스낵바 테마
      snackBarTheme: SnackBarThemeData(
        backgroundColor: neutralGrayDark,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'NotoSansKR',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 3,
      ),

      // 접근성 설정
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // 테마 확장
      extensions: darkThemeExtensions,
    );
  }

  /// 다크 테마
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Material Design 3 ColorScheme (Dark)
      colorScheme: const ColorScheme.dark(
        // Primary colors
        primary: darkPrimary,
        onPrimary: Colors.black,
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: Colors.white,

        // Secondary colors
        secondary: darkSecondary,
        onSecondary: Colors.black,
        secondaryContainer: darkSecondaryContainer,
        onSecondaryContainer: Colors.white,

        // Tertiary colors (neutral)
        tertiary: neutralGrayLight,
        onTertiary: Colors.black,
        tertiaryContainer: neutralGrayDark,
        onTertiaryContainer: Colors.white,

        // Surface colors
        surface: darkSurface,
        onSurface: darkOnSurface,
        onSurfaceVariant: darkOnSurfaceVariant,
        surfaceContainerHighest: Color(0xFF2A2A2A),

        // Error colors
        error: errorRed,
        onError: Colors.white,
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),

        // Outline colors
        outline: darkOnSurfaceVariant,
        outlineVariant: Color(0xFF444444),

        // Shadow
        shadow: Colors.black,
        scrim: Colors.black,

        // Inverse colors
        inverseSurface: Colors.white,
        onInverseSurface: Colors.black,
        inversePrimary: primaryBlueDark,
      ),

      // 앱바 테마
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.notoSans(
          color: darkOnSurface,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: darkOnSurface, size: 24),
        actionsIconTheme: const IconThemeData(color: darkOnSurface, size: 24),
      ),

      // 카드 테마
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),

      // 버튼 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.black,
          elevation: 1,
          shadowColor: darkPrimary.withValues(alpha: 0.3),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'NotoSansKR',
          ),
        ),
      ),

      // 텍스트 버튼 테마
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'NotoSansKR',
          ),
        ),
      ),

      // 아웃라인 버튼 테마
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          side: const BorderSide(color: darkPrimary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'NotoSansKR',
          ),
        ),
      ),

      // 입력 필드 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkOnSurfaceVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: darkOnSurfaceVariant,
          fontSize: 16,
          fontFamily: 'NotoSansKR',
        ),
        labelStyle: const TextStyle(
          color: darkOnSurfaceVariant,
          fontSize: 16,
          fontFamily: 'NotoSansKR',
        ),
        floatingLabelStyle: const TextStyle(
          color: darkPrimary,
          fontSize: 14,
          fontFamily: 'NotoSansKR',
        ),
      ),

      // 텍스트 테마
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          color: darkOnSurface,
          fontFamily: 'NotoSansKR',
          height: 1.12,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: darkOnSurface,
          fontFamily: 'NotoSansKR',
          height: 1.16,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: darkOnSurface,
          fontFamily: 'NotoSansKR',
          height: 1.22,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: darkOnSurface,
          fontFamily: 'NotoSansKR',
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: darkOnSurface,
          fontFamily: 'NotoSansKR',
          height: 1.29,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: darkOnSurface,
          fontFamily: 'NotoSansKR',
          height: 1.33,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: darkOnSurface,
          fontFamily: 'NotoSansKR',
          height: 1.27,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkOnSurface,
          fontFamily: 'NotoSansKR',
          height: 1.50,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkOnSurface,
          fontFamily: 'NotoSansKR',
          height: 1.43,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkOnSurface,
          fontFamily: 'NotoSansKR',
          height: 1.50,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkOnSurface,
          fontFamily: 'NotoSansKR',
          height: 1.43,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: darkOnSurfaceVariant,
          fontFamily: 'NotoSansKR',
          height: 1.33,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkOnSurface,
          fontFamily: 'NotoSansKR',
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkOnSurface,
          fontFamily: 'NotoSansKR',
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: darkOnSurfaceVariant,
          fontFamily: 'NotoSansKR',
          height: 1.45,
        ),
      ),

      // 스크롤바 테마
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(darkPrimary.withValues(alpha: 0.7)),
        trackColor: WidgetStateProperty.all(darkPrimary.withValues(alpha: 0.1)),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(6),
      ),

      // 다이얼로그 테마
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        elevation: 3,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: darkOnSurface,
          fontFamily: 'NotoSansKR',
        ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          color: darkOnSurface,
          fontFamily: 'NotoSansKR',
        ),
      ),

      // 스낵바 테마
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkOnSurface,
        contentTextStyle: const TextStyle(
          color: darkBackground,
          fontSize: 14,
          fontFamily: 'NotoSansKR',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 3,
      ),

      // 접근성 설정
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // 테마 확장
      extensions: themeExtensions,
    );
  }

  /// 테마 확장 클래스
  static List<ThemeExtension<dynamic>> get themeExtensions => [
    AppThemeExtension.light,
  ];

  /// 다크 테마 확장 클래스
  static List<ThemeExtension<dynamic>> get darkThemeExtensions => [
    AppThemeExtension.dark,
  ];
}

/// 앱 테마 확장
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.successColor,
    required this.warningColor,
    required this.infoColor,
    required this.cardElevation,
    required this.borderRadius,
  });

  final Color successColor;
  final Color warningColor;
  final Color infoColor;
  final double cardElevation;
  final double borderRadius;

  /// 라이트 테마 확장
  static const AppThemeExtension light = AppThemeExtension(
    successColor: AppTheme.positiveGreen,
    warningColor: AppTheme.warningOrange,
    infoColor: AppTheme.infoBlue,
    cardElevation: 1.0,
    borderRadius: 16.0,
  );

  /// 다크 테마 확장
  static const AppThemeExtension dark = AppThemeExtension(
    successColor: AppTheme.positiveGreen,
    warningColor: AppTheme.warningOrange,
    infoColor: AppTheme.infoBlue,
    cardElevation: 1.0,
    borderRadius: 16.0,
  );

  @override
  AppThemeExtension copyWith({
    Color? successColor,
    Color? warningColor,
    Color? infoColor,
    double? cardElevation,
    double? borderRadius,
  }) {
    return AppThemeExtension(
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
      cardElevation: cardElevation ?? this.cardElevation,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      infoColor: Color.lerp(infoColor, other.infoColor, t)!,
      cardElevation: cardElevation + (other.cardElevation - cardElevation) * t,
      borderRadius: borderRadius + (other.borderRadius - borderRadius) * t,
    );
  }
}
