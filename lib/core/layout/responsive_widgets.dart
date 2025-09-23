import 'package:flutter/material.dart';

import 'responsive_breakpoints.dart';

/// 반응형 위젯을 위한 유틸리티 클래스
class ResponsiveWidgets {
  /// 화면 크기에 따라 다른 위젯을 반환
  static Widget responsive({
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
    Widget? largeDesktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = ResponsiveBreakpoints.getScreenSize(constraints.maxWidth);

        switch (screenSize) {
          case ScreenSize.mobile:
            return mobile;
          case ScreenSize.tablet:
            return tablet ?? mobile;
          case ScreenSize.desktop:
            return desktop ?? tablet ?? mobile;
          case ScreenSize.largeDesktop:
            return largeDesktop ?? desktop ?? tablet ?? mobile;
        }
      },
    );
  }

  /// 화면 크기에 따라 다른 값 반환
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final screenSize = ResponsiveBreakpoints.getScreenSize(
      MediaQuery.of(context).size.width,
    );

    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenSize.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  /// 반응형 그리드 레이아웃
  static Widget responsiveGrid({
    required List<Widget> children,
    double spacing = 16.0,
    double runSpacing = 16.0,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = ResponsiveBreakpoints.getColumnCount(constraints.maxWidth);
        final crossAxisCount = columnCount;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: 1.0,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  /// 반응형 리스트 레이아웃
  static Widget responsiveList({
    required List<Widget> children,
    double spacing = 16.0,
    bool isHorizontal = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isHorizontal) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: children
                  .expand((child) => [child, SizedBox(width: spacing)])
                  .take(children.length * 2 - 1)
                  .toList(),
            ),
          );
        }

        return Column(
          children: children
              .expand((child) => [child, SizedBox(height: spacing)])
              .take(children.length * 2 - 1)
              .toList(),
        );
      },
    );
  }

  /// 반응형 컨테이너
  static Widget responsiveContainer({
    required Widget child,
    double? maxWidth,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? color,
    BoxDecoration? decoration,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenPadding = ResponsiveBreakpoints.getPadding(constraints.maxWidth);
        final containerMaxWidth = maxWidth ??
            ResponsiveBreakpoints.getMaxContainerWidth(constraints.maxWidth);

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: containerMaxWidth,
          ),
          padding: padding ?? EdgeInsets.all(screenPadding),
          margin: margin,
          color: color,
          decoration: decoration,
          child: child,
        );
      },
    );
  }
}

/// 반응형 위젯 래퍼
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final BoxDecoration? decoration;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidgets.responsiveContainer(
      maxWidth: maxWidth,
      padding: padding,
      margin: margin,
      color: color,
      decoration: decoration,
      child: child,
    );
  }
}

/// 반응형 텍스트
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveBreakpoints.getScreenSize(
      MediaQuery.of(context).size.width,
    );

    double fontSize = 16.0;
    switch (screenSize) {
      case ScreenSize.mobile:
        fontSize = 14.0;
        break;
      case ScreenSize.tablet:
        fontSize = 16.0;
        break;
      case ScreenSize.desktop:
        fontSize = 18.0;
        break;
      case ScreenSize.largeDesktop:
        fontSize = 20.0;
        break;
    }

    return Text(
      text,
      style: style?.copyWith(fontSize: fontSize) ??
             TextStyle(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
