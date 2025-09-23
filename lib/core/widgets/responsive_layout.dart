import 'package:flutter/material.dart';

/// 화면 크기 타입 열거형
enum ScreenSize {
  small,    // 모바일 (0-600px)
  medium,   // 태블릿 (600-1200px)
  large,    // 데스크톱 (1200px+)
}

/// 반응형 레이아웃 위젯
/// 화면 크기에 따라 다른 레이아웃을 제공하는 위젯입니다.
class ResponsiveLayout extends StatelessWidget {
  /// 모바일 레이아웃
  final Widget mobile;

  /// 태블릿 레이아웃 (선택사항)
  final Widget? tablet;

  /// 데스크톱 레이아웃 (선택사항)
  final Widget? desktop;

  /// 최소 너비 (선택사항)
  final double? minWidth;

  /// 최대 너비 (선택사항)
  final double? maxWidth;

  /// 중앙 정렬 여부
  final bool centerContent;

  /// 패딩
  final EdgeInsets? padding;

  /// 배경색
  final Color? backgroundColor;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.minWidth,
    this.maxWidth,
    this.centerContent = true,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = _getScreenSize(context);

    // 화면 크기에 따른 위젯 선택
    Widget child;
    switch (screenSize) {
      case ScreenSize.small:
        child = mobile;
        break;
      case ScreenSize.medium:
        child = tablet ?? mobile;
        break;
      case ScreenSize.large:
        child = desktop ?? tablet ?? mobile;
        break;
    }

    // 최소/최대 너비 제한
    if (minWidth != null || maxWidth != null) {
      child = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth ?? 0,
          maxWidth: maxWidth ?? double.infinity,
        ),
        child: child,
      );
    }

    // 중앙 정렬
    if (centerContent) {
      child = Center(child: child);
    }

    // 패딩 적용
    if (padding != null) {
      child = Padding(padding: padding!, child: child);
    }

    // 배경색 적용
    if (backgroundColor != null) {
      child = Container(color: backgroundColor, child: child);
    }

    return child;
  }

  /// 화면 크기 결정
  ScreenSize _getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return ScreenSize.small;
    } else if (width < 1200) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }

  // === 편의 팩토리 메서드들 ===

  /// 모바일 전용 레이아웃
  static Widget mobileOnly({
    required Widget child,
    EdgeInsets? padding,
    Color? backgroundColor,
  }) {
    return ResponsiveLayout(
      mobile: child,
      padding: padding,
      backgroundColor: backgroundColor,
    );
  }

  /// 태블릿과 모바일 레이아웃
  static Widget mobileTablet({
    required Widget mobile,
    required Widget tablet,
    EdgeInsets? padding,
    Color? backgroundColor,
  }) {
    return ResponsiveLayout(
      mobile: mobile,
      tablet: tablet,
      padding: padding,
      backgroundColor: backgroundColor,
    );
  }

  /// 모든 화면 크기 레이아웃
  static Widget all({
    required Widget mobile,
    required Widget tablet,
    required Widget desktop,
    EdgeInsets? padding,
    Color? backgroundColor,
  }) {
    return ResponsiveLayout(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      padding: padding,
      backgroundColor: backgroundColor,
    );
  }

  /// 컨테이너 제한 레이아웃
  static Widget constrained({
    required Widget child,
    double? minWidth,
    double? maxWidth,
    EdgeInsets? padding,
    Color? backgroundColor,
  }) {
    return ResponsiveLayout(
      mobile: child,
      minWidth: minWidth,
      maxWidth: maxWidth,
      padding: padding,
      backgroundColor: backgroundColor,
    );
  }
}

/// 반응형 그리드 레이아웃
class ResponsiveGrid extends StatelessWidget {
  /// 자식 위젯들
  final List<Widget> children;

  /// 모바일 열 수
  final int mobileColumns;

  /// 태블릿 열 수
  final int? tabletColumns;

  /// 데스크톱 열 수
  final int? desktopColumns;

  /// 간격
  final double spacing;

  /// 실행 간격
  final double runSpacing;

  /// 패딩
  final EdgeInsets? padding;

  /// 배경색
  final Color? backgroundColor;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns,
    this.desktopColumns,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = _getScreenSize(context);

    int columns;
    switch (screenSize) {
      case ScreenSize.small:
        columns = mobileColumns;
        break;
      case ScreenSize.medium:
        columns = tabletColumns ?? mobileColumns;
        break;
      case ScreenSize.large:
        columns = desktopColumns ?? tabletColumns ?? mobileColumns;
        break;
    }

    Widget child = Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((widget) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width -
                 (columns - 1) * spacing -
                 (padding?.horizontal ?? 0)) / columns,
          child: widget,
        );
      }).toList(),
    );

    if (padding != null) {
      child = Padding(padding: padding!, child: child);
    }

    if (backgroundColor != null) {
      child = Container(color: backgroundColor, child: child);
    }

    return child;
  }

  /// 화면 크기 결정
  ScreenSize _getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return ScreenSize.small;
    } else if (width < 1200) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }
}

/// 반응형 컨테이너
class ResponsiveContainer extends StatelessWidget {
  /// 자식 위젯
  final Widget child;

  /// 모바일 크기
  final Size? mobileSize;

  /// 태블릿 크기
  final Size? tabletSize;

  /// 데스크톱 크기
  final Size? desktopSize;

  /// 패딩
  final EdgeInsets? padding;

  /// 마진
  final EdgeInsets? margin;

  /// 배경색
  final Color? backgroundColor;

  /// 테두리
  final Border? border;

  /// 테두리 반경
  final BorderRadius? borderRadius;

  /// 그림자
  final List<BoxShadow>? boxShadow;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileSize,
    this.tabletSize,
    this.desktopSize,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = _getScreenSize(context);

    Size? size;
    switch (screenSize) {
      case ScreenSize.small:
        size = mobileSize;
        break;
      case ScreenSize.medium:
        size = tabletSize ?? mobileSize;
        break;
      case ScreenSize.large:
        size = desktopSize ?? tabletSize ?? mobileSize;
        break;
    }

    final Widget container = Container(
      width: size?.width,
      height: size?.height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: border,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: child,
    );

    return container;
  }

  /// 화면 크기 결정
  ScreenSize _getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return ScreenSize.small;
    } else if (width < 1200) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }
}

/// 반응형 텍스트
class ResponsiveText extends StatelessWidget {
  /// 텍스트
  final String text;

  /// 모바일 스타일
  final TextStyle? mobileStyle;

  /// 태블릿 스타일
  final TextStyle? tabletStyle;

  /// 데스크톱 스타일
  final TextStyle? desktopStyle;

  /// 텍스트 정렬
  final TextAlign? textAlign;

  /// 최대 라인 수
  final int? maxLines;

  /// 오버플로우 처리
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.mobileStyle,
    this.tabletStyle,
    this.desktopStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = _getScreenSize(context);

    TextStyle? style;
    switch (screenSize) {
      case ScreenSize.small:
        style = mobileStyle;
        break;
      case ScreenSize.medium:
        style = tabletStyle ?? mobileStyle;
        break;
      case ScreenSize.large:
        style = desktopStyle ?? tabletStyle ?? mobileStyle;
        break;
    }

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// 화면 크기 결정
  ScreenSize _getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return ScreenSize.small;
    } else if (width < 1200) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }
}

/// 반응형 패딩
class ResponsivePadding extends StatelessWidget {
  /// 자식 위젯
  final Widget child;

  /// 모바일 패딩
  final EdgeInsets mobilePadding;

  /// 태블릿 패딩
  final EdgeInsets? tabletPadding;

  /// 데스크톱 패딩
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    required this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = _getScreenSize(context);

    EdgeInsets padding;
    switch (screenSize) {
      case ScreenSize.small:
        padding = mobilePadding;
        break;
      case ScreenSize.medium:
        padding = tabletPadding ?? mobilePadding;
        break;
      case ScreenSize.large:
        padding = desktopPadding ?? tabletPadding ?? mobilePadding;
        break;
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }

  /// 화면 크기 결정
  ScreenSize _getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return ScreenSize.small;
    } else if (width < 1200) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }
}

/// 반응형 마진
class ResponsiveMargin extends StatelessWidget {
  /// 자식 위젯
  final Widget child;

  /// 모바일 마진
  final EdgeInsets mobileMargin;

  /// 태블릿 마진
  final EdgeInsets? tabletMargin;

  /// 데스크톱 마진
  final EdgeInsets? desktopMargin;

  const ResponsiveMargin({
    super.key,
    required this.child,
    required this.mobileMargin,
    this.tabletMargin,
    this.desktopMargin,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = _getScreenSize(context);

    EdgeInsets margin;
    switch (screenSize) {
      case ScreenSize.small:
        margin = mobileMargin;
        break;
      case ScreenSize.medium:
        margin = tabletMargin ?? mobileMargin;
        break;
      case ScreenSize.large:
        margin = desktopMargin ?? tabletMargin ?? mobileMargin;
        break;
    }

    return Container(
      margin: margin,
      child: child,
    );
  }

  /// 화면 크기 결정
  ScreenSize _getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return ScreenSize.small;
    } else if (width < 1200) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }
}

/// 반응형 유틸리티 클래스
class ResponsiveUtils {
  /// 화면 크기 결정
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return ScreenSize.small;
    } else if (width < 1200) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }

  /// 모바일인지 확인
  static bool isMobile(BuildContext context) {
    return getScreenSize(context) == ScreenSize.small;
  }

  /// 태블릿인지 확인
  static bool isTablet(BuildContext context) {
    return getScreenSize(context) == ScreenSize.medium;
  }

  /// 데스크톱인지 확인
  static bool isDesktop(BuildContext context) {
    return getScreenSize(context) == ScreenSize.large;
  }

  /// 화면 너비 반환
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// 화면 높이 반환
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// 안전 영역 고려한 화면 높이 반환
  static double getSafeScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height -
           MediaQuery.of(context).padding.top -
           MediaQuery.of(context).padding.bottom;
  }

  /// 화면 크기에 따른 값 반환
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return mobile;
      case ScreenSize.medium:
        return tablet ?? mobile;
      case ScreenSize.large:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// 화면 크기에 따른 패딩 반환
  static EdgeInsets responsivePadding(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    return responsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// 화면 크기에 따른 마진 반환
  static EdgeInsets responsiveMargin(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    return responsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// 화면 크기에 따른 폰트 크기 반환
  static double responsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// 화면 크기에 따른 아이콘 크기 반환
  static double responsiveIconSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}
