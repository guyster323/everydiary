import 'package:flutter/material.dart';

/// 반응형 레이아웃을 위한 브레이크포인트 정의
class ResponsiveBreakpoints {
  // 화면 크기별 브레이크포인트
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1600;

  // 화면 크기 타입
  static ScreenSize getScreenSize(double width) {
    if (width < mobile) {
      return ScreenSize.mobile;
    } else if (width < tablet) {
      return ScreenSize.tablet;
    } else if (width < desktop) {
      return ScreenSize.desktop;
    } else {
      return ScreenSize.largeDesktop;
    }
  }

  // 컬럼 수 계산
  static int getColumnCount(double width) {
    switch (getScreenSize(width)) {
      case ScreenSize.mobile:
        return 1;
      case ScreenSize.tablet:
        return 2;
      case ScreenSize.desktop:
        return 3;
      case ScreenSize.largeDesktop:
        return 4;
    }
  }

  // 패딩 계산
  static double getPadding(double width) {
    switch (getScreenSize(width)) {
      case ScreenSize.mobile:
        return 16.0;
      case ScreenSize.tablet:
        return 24.0;
      case ScreenSize.desktop:
        return 32.0;
      case ScreenSize.largeDesktop:
        return 48.0;
    }
  }

  // 최대 컨테이너 너비
  static double getMaxContainerWidth(double width) {
    switch (getScreenSize(width)) {
      case ScreenSize.mobile:
        return double.infinity;
      case ScreenSize.tablet:
        return 800;
      case ScreenSize.desktop:
        return 1200;
      case ScreenSize.largeDesktop:
        return 1600;
    }
  }
}

/// 화면 크기 타입
enum ScreenSize { mobile, tablet, desktop, largeDesktop }

/// 화면 크기별 설정
class ScreenConfig {
  final ScreenSize screenSize;
  final double width;
  final double height;
  final bool isLandscape;
  final bool isTablet;
  final bool isMobile;
  final bool isDesktop;

  const ScreenConfig({
    required this.screenSize,
    required this.width,
    required this.height,
    required this.isLandscape,
    required this.isTablet,
    required this.isMobile,
    required this.isDesktop,
  });

  factory ScreenConfig.fromSize(Size size) {
    final screenSize = ResponsiveBreakpoints.getScreenSize(size.width);
    final isLandscape = size.width > size.height;

    return ScreenConfig(
      screenSize: screenSize,
      width: size.width,
      height: size.height,
      isLandscape: isLandscape,
      isTablet: screenSize == ScreenSize.tablet,
      isMobile: screenSize == ScreenSize.mobile,
      isDesktop:
          screenSize == ScreenSize.desktop ||
          screenSize == ScreenSize.largeDesktop,
    );
  }
}
