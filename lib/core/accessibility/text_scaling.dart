import 'package:flutter/material.dart';

/// 텍스트 크기 조절 유틸리티
class TextScaling {
  /// 기본 텍스트 크기
  static const double baseFontSize = 16.0;

  /// 최소 텍스트 크기
  static const double minFontSize = 12.0;

  /// 최대 텍스트 크기
  static const double maxFontSize = 24.0;

  /// 텍스트 크기 스케일 팩터 계산
  static double getTextScaleFactor(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textScaleFactor = mediaQuery.textScaler.scale(1.0);

    // 시스템 텍스트 크기 설정을 고려하여 조정
    return textScaleFactor.clamp(0.8, 2.0);
  }

  /// 스케일된 폰트 크기 계산
  static double getScaledFontSize(BuildContext context, double baseFontSize) {
    final scaleFactor = getTextScaleFactor(context);
    final scaledSize = baseFontSize * scaleFactor;

    return scaledSize.clamp(minFontSize, maxFontSize);
  }

  /// 텍스트 스타일 스케일링
  static TextStyle getScaledTextStyle(
    BuildContext context,
    TextStyle baseStyle,
  ) {
    final scaledFontSize = getScaledFontSize(
      context,
      baseStyle.fontSize ?? baseFontSize,
    );

    return baseStyle.copyWith(fontSize: scaledFontSize);
  }

  /// 텍스트 테마 스케일링
  static TextTheme getScaledTextTheme(
    BuildContext context,
    TextTheme baseTheme,
  ) {
    return TextTheme(
      displayLarge: getScaledTextStyle(context, baseTheme.displayLarge!),
      displayMedium: getScaledTextStyle(context, baseTheme.displayMedium!),
      displaySmall: getScaledTextStyle(context, baseTheme.displaySmall!),
      headlineLarge: getScaledTextStyle(context, baseTheme.headlineLarge!),
      headlineMedium: getScaledTextStyle(context, baseTheme.headlineMedium!),
      headlineSmall: getScaledTextStyle(context, baseTheme.headlineSmall!),
      titleLarge: getScaledTextStyle(context, baseTheme.titleLarge!),
      titleMedium: getScaledTextStyle(context, baseTheme.titleMedium!),
      titleSmall: getScaledTextStyle(context, baseTheme.titleSmall!),
      bodyLarge: getScaledTextStyle(context, baseTheme.bodyLarge!),
      bodyMedium: getScaledTextStyle(context, baseTheme.bodyMedium!),
      bodySmall: getScaledTextStyle(context, baseTheme.bodySmall!),
      labelLarge: getScaledTextStyle(context, baseTheme.labelLarge!),
      labelMedium: getScaledTextStyle(context, baseTheme.labelMedium!),
      labelSmall: getScaledTextStyle(context, baseTheme.labelSmall!),
    );
  }
}

/// 스케일된 텍스트 위젯
class ScaledText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? baseFontSize;

  const ScaledText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.baseFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final scaledStyle = style != null
        ? TextScaling.getScaledTextStyle(context, style!)
        : TextStyle(
            fontSize: TextScaling.getScaledFontSize(
              context,
              baseFontSize ?? TextScaling.baseFontSize,
            ),
          );

    return Text(
      text,
      style: scaledStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// 스케일된 텍스트 스타일 빌더
class ScaledTextStyleBuilder extends StatelessWidget {
  final Widget Function(TextStyle scaledStyle) builder;
  final TextStyle baseStyle;
  final double? baseFontSize;

  const ScaledTextStyleBuilder({
    super.key,
    required this.builder,
    required this.baseStyle,
    this.baseFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final scaledStyle = TextScaling.getScaledTextStyle(context, baseStyle);
    return builder(scaledStyle);
  }
}

/// 텍스트 크기 설정 위젯
class TextSizeSettings extends StatefulWidget {
  final Widget child;
  final double initialScale;
  final ValueChanged<double>? onScaleChanged;

  const TextSizeSettings({
    super.key,
    required this.child,
    this.initialScale = 1.0,
    this.onScaleChanged,
  });

  @override
  State<TextSizeSettings> createState() => _TextSizeSettingsState();
}

class _TextSizeSettingsState extends State<TextSizeSettings> {
  late double _currentScale;

  @override
  void initState() {
    super.initState();
    _currentScale = widget.initialScale;
  }

  void _increaseTextSize() {
    setState(() {
      _currentScale = (_currentScale + 0.1).clamp(0.8, 2.0);
    });
    widget.onScaleChanged?.call(_currentScale);
  }

  void _decreaseTextSize() {
    setState(() {
      _currentScale = (_currentScale - 0.1).clamp(0.8, 2.0);
    });
    widget.onScaleChanged?.call(_currentScale);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(_currentScale)),
      child: Column(
        children: [
          // 텍스트 크기 조절 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _decreaseTextSize,
                icon: const Icon(Icons.text_decrease),
                tooltip: '텍스트 크기 줄이기',
              ),
              Text('텍스트 크기: ${(_currentScale * 100).round()}%'),
              IconButton(
                onPressed: _increaseTextSize,
                icon: const Icon(Icons.text_increase),
                tooltip: '텍스트 크기 늘리기',
              ),
            ],
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
