import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 타이포그래피 유틸리티 클래스
/// 반응형 폰트 크기와 접근성 기능을 제공합니다.
class TypographyUtils {
  /// 기본 폰트 크기 스케일 팩터
  static const double _baseScaleFactor = 1.0;

  /// 최소 폰트 크기 스케일 팩터
  static const double _minScaleFactor = 0.8;

  /// 최대 폰트 크기 스케일 팩터
  static const double _maxScaleFactor = 1.3;

  /// 화면 크기별 브레이크포인트
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;
  static const double _desktopBreakpoint = 1200;

  /// 현재 화면 크기에 따른 폰트 스케일 팩터 계산
  static double getFontScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaler.scale(1.0);

    // 기본 스케일 팩터
    double scaleFactor = _baseScaleFactor;

    // 화면 크기에 따른 스케일 조정
    if (screenWidth < _mobileBreakpoint) {
      // 모바일: 기본 크기
      scaleFactor = _baseScaleFactor;
    } else if (screenWidth < _tabletBreakpoint) {
      // 태블릿: 약간 큰 크기
      scaleFactor = _baseScaleFactor * 1.1;
    } else if (screenWidth < _desktopBreakpoint) {
      // 작은 데스크톱: 더 큰 크기
      scaleFactor = _baseScaleFactor * 1.2;
    } else {
      // 큰 데스크톱: 가장 큰 크기
      scaleFactor = _baseScaleFactor * 1.3;
    }

    // 접근성 텍스트 스케일 팩터 적용
    scaleFactor *= textScaleFactor;

    // 최소/최대 범위 제한
    return scaleFactor.clamp(_minScaleFactor, _maxScaleFactor);
  }

  /// 반응형 폰트 크기 계산
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    return baseFontSize * getFontScaleFactor(context);
  }

  /// 반응형 텍스트 스타일 생성
  static TextStyle getResponsiveTextStyle(
    BuildContext context, {
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.notoSans(
      fontSize: getResponsiveFontSize(context, fontSize),
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Material Design 3 타이포그래피 스타일 생성
  static Map<String, TextStyle> getMaterial3TextStyles(BuildContext context) {
    final scaleFactor = getFontScaleFactor(context);

    return {
      'displayLarge': GoogleFonts.notoSans(
        fontSize: 57 * scaleFactor,
        fontWeight: FontWeight.w400,
        height: 1.12,
      ),
      'displayMedium': GoogleFonts.notoSans(
        fontSize: 45 * scaleFactor,
        fontWeight: FontWeight.w400,
        height: 1.16,
      ),
      'displaySmall': GoogleFonts.notoSans(
        fontSize: 36 * scaleFactor,
        fontWeight: FontWeight.w400,
        height: 1.22,
      ),
      'headlineLarge': GoogleFonts.notoSans(
        fontSize: 32 * scaleFactor,
        fontWeight: FontWeight.w400,
        height: 1.25,
      ),
      'headlineMedium': GoogleFonts.notoSans(
        fontSize: 28 * scaleFactor,
        fontWeight: FontWeight.w400,
        height: 1.29,
      ),
      'headlineSmall': GoogleFonts.notoSans(
        fontSize: 24 * scaleFactor,
        fontWeight: FontWeight.w400,
        height: 1.33,
      ),
      'titleLarge': GoogleFonts.notoSans(
        fontSize: 22 * scaleFactor,
        fontWeight: FontWeight.w400,
        height: 1.27,
      ),
      'titleMedium': GoogleFonts.notoSans(
        fontSize: 16 * scaleFactor,
        fontWeight: FontWeight.w500,
        height: 1.50,
      ),
      'titleSmall': GoogleFonts.notoSans(
        fontSize: 14 * scaleFactor,
        fontWeight: FontWeight.w500,
        height: 1.43,
      ),
      'bodyLarge': GoogleFonts.notoSans(
        fontSize: 16 * scaleFactor,
        fontWeight: FontWeight.w400,
        height: 1.50,
      ),
      'bodyMedium': GoogleFonts.notoSans(
        fontSize: 14 * scaleFactor,
        fontWeight: FontWeight.w400,
        height: 1.43,
      ),
      'bodySmall': GoogleFonts.notoSans(
        fontSize: 12 * scaleFactor,
        fontWeight: FontWeight.w400,
        height: 1.33,
      ),
      'labelLarge': GoogleFonts.notoSans(
        fontSize: 14 * scaleFactor,
        fontWeight: FontWeight.w500,
        height: 1.43,
      ),
      'labelMedium': GoogleFonts.notoSans(
        fontSize: 12 * scaleFactor,
        fontWeight: FontWeight.w500,
        height: 1.33,
      ),
      'labelSmall': GoogleFonts.notoSans(
        fontSize: 11 * scaleFactor,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
    };
  }

  /// 접근성 텍스트 크기 조절 기능 확인
  static bool isAccessibilityTextSizeEnabled(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0) > 1.0;
  }

  /// 현재 화면 크기 카테고리 반환
  static ScreenSizeCategory getScreenSizeCategory(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < _mobileBreakpoint) {
      return ScreenSizeCategory.mobile;
    } else if (screenWidth < _tabletBreakpoint) {
      return ScreenSizeCategory.tablet;
    } else if (screenWidth < _desktopBreakpoint) {
      return ScreenSizeCategory.smallDesktop;
    } else {
      return ScreenSizeCategory.largeDesktop;
    }
  }

  /// 화면 크기별 최적화된 폰트 크기 반환
  static double getOptimizedFontSize(
    BuildContext context,
    double mobileSize,
    double? tabletSize,
    double? desktopSize,
  ) {
    final category = getScreenSizeCategory(context);

    switch (category) {
      case ScreenSizeCategory.mobile:
        return mobileSize;
      case ScreenSizeCategory.tablet:
        return tabletSize ?? mobileSize * 1.1;
      case ScreenSizeCategory.smallDesktop:
        return desktopSize ?? mobileSize * 1.2;
      case ScreenSizeCategory.largeDesktop:
        return desktopSize ?? mobileSize * 1.3;
    }
  }
}

/// 화면 크기 카테고리 열거형
enum ScreenSizeCategory { mobile, tablet, smallDesktop, largeDesktop }

/// 반응형 텍스트 위젯
class ResponsiveText extends StatelessWidget {
  const ResponsiveText(
    this.text, {
    super.key,
    required this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.mobileStyle,
    this.tabletStyle,
    this.desktopStyle,
  });

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? mobileStyle;
  final TextStyle? tabletStyle;
  final TextStyle? desktopStyle;

  @override
  Widget build(BuildContext context) {
    final category = TypographyUtils.getScreenSizeCategory(context);
    final scaleFactor = TypographyUtils.getFontScaleFactor(context);

    TextStyle effectiveStyle = style;

    // 화면 크기별 스타일 적용
    switch (category) {
      case ScreenSizeCategory.mobile:
        effectiveStyle = mobileStyle ?? style;
        break;
      case ScreenSizeCategory.tablet:
        effectiveStyle = tabletStyle ?? style;
        break;
      case ScreenSizeCategory.smallDesktop:
      case ScreenSizeCategory.largeDesktop:
        effectiveStyle = desktopStyle ?? style;
        break;
    }

    // 폰트 크기 스케일링 적용
    effectiveStyle = effectiveStyle.copyWith(
      fontSize: (effectiveStyle.fontSize ?? 14) * scaleFactor,
    );

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
