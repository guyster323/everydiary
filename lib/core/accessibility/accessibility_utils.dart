import 'package:flutter/material.dart';

/// 접근성 유틸리티 클래스
class AccessibilityUtils {
  /// 시맨틱 라벨 설정
  static Widget semanticLabel({
    required Widget child,
    required String label,
    String? hint,
    bool? excludeSemantics,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      excludeSemantics: excludeSemantics ?? false,
      child: child,
    );
  }

  /// 버튼 시맨틱
  static Widget semanticButton({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      onTap: onTap,
      child: child,
    );
  }

  /// 이미지 시맨틱
  static Widget semanticImage({
    required Widget child,
    required String label,
    String? hint,
  }) {
    return Semantics(label: label, hint: hint, image: true, child: child);
  }

  /// 텍스트 필드 시맨틱
  static Widget semanticTextField({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      textField: true,
      value: value,
      enabled: enabled,
      child: child,
    );
  }

  /// 헤딩 시맨틱
  static Widget semanticHeading({
    required Widget child,
    required String label,
    int level = 1,
  }) {
    return Semantics(label: label, header: true, child: child);
  }

  /// 리스트 시맨틱
  static Widget semanticList({
    required Widget child,
    required String label,
    int? itemCount,
  }) {
    return Semantics(label: label, child: child);
  }

  /// 리스트 아이템 시맨틱
  static Widget semanticListItem({
    required Widget child,
    required String label,
    int? index,
    int? totalCount,
  }) {
    final position = index != null && totalCount != null
        ? '$index of $totalCount'
        : null;

    return Semantics(label: label, hint: position, child: child);
  }

  /// 스크롤 가능한 영역 시맨틱
  static Widget semanticScrollable({
    required Widget child,
    required String label,
    Axis scrollDirection = Axis.vertical,
  }) {
    return Semantics(label: label, child: child);
  }

  /// 포커스 가능한 위젯
  static Widget focusable({
    required Widget child,
    VoidCallback? onFocusChange,
    bool autofocus = false,
  }) {
    return Focus(
      autofocus: autofocus,
      onFocusChange: (hasFocus) => onFocusChange?.call(),
      child: child,
    );
  }

  /// 키보드 네비게이션 지원
  static Widget keyboardNavigable({
    required Widget child,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return Focus(focusNode: focusNode, autofocus: autofocus, child: child);
  }
}

/// 접근성 설정
class AccessibilitySettings {
  static const double minTouchTargetSize = 48.0;
  static const double minContrastRatio = 4.5;
  static const double minFontSize = 12.0;
  static const double maxFontSize = 24.0;

  /// 최소 터치 타겟 크기 확인
  static bool isTouchTargetSizeValid(Size size) {
    return size.width >= minTouchTargetSize &&
        size.height >= minTouchTargetSize;
  }

  /// 고대비 모드 확인
  static bool isHighContrastMode(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// 텍스트 크기 스케일 확인
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  /// 접근성 설정 확인
  static bool isAccessibilityEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }
}

/// 접근성 위젯 래퍼
class AccessibilityWrapper extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final bool excludeSemantics;
  final bool button;
  final bool image;
  final bool textField;
  final bool header;
  final VoidCallback? onTap;
  final bool enabled;

  const AccessibilityWrapper({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.excludeSemantics = false,
    this.button = false,
    this.image = false,
    this.textField = false,
    this.header = false,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      excludeSemantics: excludeSemantics,
      button: button,
      image: image,
      textField: textField,
      header: header,
      onTap: onTap,
      enabled: enabled,
      child: child,
    );
  }
}
