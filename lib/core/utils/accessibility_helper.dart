import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// 접근성 헬퍼 유틸리티 클래스
/// 접근성 기능을 쉽게 적용할 수 있는 유틸리티 메서드들을 제공합니다.
class AccessibilityHelper {
  /// 접근성 라벨 생성
  static String generateLabel({
    required String baseLabel,
    String? state,
    String? action,
    String? context,
  }) {
    final parts = <String>[baseLabel];

    if (state != null) parts.add(state);
    if (action != null) parts.add(action);
    if (context != null) parts.add(context);

    return parts.join(', ');
  }

  /// 버튼 접근성 라벨 생성
  static String buttonLabel({
    required String label,
    bool? isEnabled,
    bool? isSelected,
    String? state,
  }) {
    final parts = <String>[label];

    if (isEnabled == false) parts.add('비활성화됨');
    if (isSelected == true) parts.add('선택됨');
    if (state != null) parts.add(state);

    return parts.join(', ');
  }

  /// 텍스트 필드 접근성 라벨 생성
  static String textFieldLabel({
    required String label,
    String? hint,
    String? error,
    bool? isRequired,
  }) {
    final parts = <String>[label];

    if (isRequired == true) parts.add('필수 입력');
    if (hint != null) parts.add('힌트: $hint');
    if (error != null) parts.add('오류: $error');

    return parts.join(', ');
  }

  /// 이미지 접근성 라벨 생성
  static String imageLabel({
    required String description,
    String? context,
    bool? isDecorative,
  }) {
    if (isDecorative == true) {
      return '장식용 이미지';
    }

    final parts = <String>[description];
    if (context != null) parts.add(context);

    return parts.join(', ');
  }

  /// 리스트 접근성 라벨 생성
  static String listLabel({
    required String itemLabel,
    required int index,
    required int total,
    String? context,
  }) {
    final parts = <String>[itemLabel, '항목 ${index + 1} / $total'];

    if (context != null) parts.add(context);

    return parts.join(', ');
  }

  /// 진행률 접근성 라벨 생성
  static String progressLabel({
    required double value,
    required double max,
    String? context,
  }) {
    final percentage = ((value / max) * 100).round();
    final parts = <String>['진행률 $percentage%'];

    if (context != null) parts.add(context);

    return parts.join(', ');
  }

  /// 접근성 위젯 래핑
  static Widget wrapWithSemantics({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    bool? button,
    bool? textField,
    bool? image,
    bool? slider,
    bool? checked,
    bool? selected,
    bool? enabled,
    bool? focused,
    bool? inMutuallyExclusiveGroup,
    bool? header,
    bool? link,
    bool? liveRegion,
    bool? onTap,
    bool? onLongPress,
    bool? onScrollLeft,
    bool? onScrollRight,
    bool? onScrollUp,
    bool? onScrollDown,
    bool? onIncrease,
    bool? onDecrease,
    bool? onCopy,
    bool? onCut,
    bool? onPaste,
    bool? onMoveCursorForwardByCharacter,
    bool? onMoveCursorBackwardByCharacter,
    bool? onMoveCursorForwardByWord,
    bool? onMoveCursorBackwardByWord,
    bool? onSetSelection,
    bool? onDidGainAccessibilityFocus,
    bool? onDidLoseAccessibilityFocus,
    bool? onDismiss,
    VoidCallback? onTapAction,
    VoidCallback? onLongPressAction,
    VoidCallback? onScrollLeftAction,
    VoidCallback? onScrollRightAction,
    VoidCallback? onScrollUpAction,
    VoidCallback? onScrollDownAction,
    VoidCallback? onIncreaseAction,
    VoidCallback? onDecreaseAction,
    VoidCallback? onCopyAction,
    VoidCallback? onCutAction,
    VoidCallback? onPasteAction,
    VoidCallback? onMoveCursorForwardByCharacterAction,
    VoidCallback? onMoveCursorBackwardByCharacterAction,
    VoidCallback? onMoveCursorForwardByWordAction,
    VoidCallback? onMoveCursorBackwardByWordAction,
    VoidCallback? onSetSelectionAction,
    VoidCallback? onDidGainAccessibilityFocusAction,
    VoidCallback? onDidLoseAccessibilityFocusAction,
    VoidCallback? onDismissAction,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      textField: textField,
      image: image,
      slider: slider,
      checked: checked,
      selected: selected,
      enabled: enabled,
      focused: focused,
      inMutuallyExclusiveGroup: inMutuallyExclusiveGroup,
      header: header,
      link: link,
      liveRegion: liveRegion,
      onTap: onTap == true ? onTapAction : null,
      onLongPress: onLongPress == true ? onLongPressAction : null,
      onScrollLeft: onScrollLeft == true ? onScrollLeftAction : null,
      onScrollRight: onScrollRight == true ? onScrollRightAction : null,
      onScrollUp: onScrollUp == true ? onScrollUpAction : null,
      onScrollDown: onScrollDown == true ? onScrollDownAction : null,
      onIncrease: onIncrease == true ? onIncreaseAction : null,
      onDecrease: onDecrease == true ? onDecreaseAction : null,
      onCopy: onCopy == true ? onCopyAction : null,
      onCut: onCut == true ? onCutAction : null,
      onPaste: onPaste == true ? onPasteAction : null,
      // 커서 이동 및 선택 관련 기능은 복잡한 타입으로 인해 제외
      onDidGainAccessibilityFocus: onDidGainAccessibilityFocus == true
          ? onDidGainAccessibilityFocusAction
          : null,
      onDidLoseAccessibilityFocus: onDidLoseAccessibilityFocus == true
          ? onDidLoseAccessibilityFocusAction
          : null,
      onDismiss: onDismiss == true ? onDismissAction : null,
      child: child,
    );
  }

  /// 버튼 접근성 래핑
  static Widget wrapButton({
    required Widget child,
    required String label,
    String? hint,
    bool? isEnabled,
    bool? isSelected,
    VoidCallback? onTap,
  }) {
    return wrapWithSemantics(
      child: child,
      label: buttonLabel(
        label: label,
        isEnabled: isEnabled,
        isSelected: isSelected,
      ),
      hint: hint,
      button: true,
      enabled: isEnabled,
      selected: isSelected,
      onTap: onTap != null,
      onTapAction: onTap,
    );
  }

  /// 텍스트 필드 접근성 래핑
  static Widget wrapTextField({
    required Widget child,
    required String label,
    String? hint,
    String? error,
    bool? isRequired,
    bool? isEnabled,
    bool? isFocused,
  }) {
    return wrapWithSemantics(
      child: child,
      label: textFieldLabel(
        label: label,
        hint: hint,
        error: error,
        isRequired: isRequired,
      ),
      textField: true,
      enabled: isEnabled,
      focused: isFocused,
    );
  }

  /// 이미지 접근성 래핑
  static Widget wrapImage({
    required Widget child,
    required String description,
    String? context,
    bool? isDecorative,
  }) {
    return wrapWithSemantics(
      child: child,
      label: imageLabel(
        description: description,
        context: context,
        isDecorative: isDecorative,
      ),
      image: true,
    );
  }

  /// 리스트 아이템 접근성 래핑
  static Widget wrapListItem({
    required Widget child,
    required String itemLabel,
    required int index,
    required int total,
    String? context,
    bool? isSelected,
    VoidCallback? onTap,
  }) {
    return wrapWithSemantics(
      child: child,
      label: listLabel(
        itemLabel: itemLabel,
        index: index,
        total: total,
        context: context,
      ),
      selected: isSelected,
      onTap: onTap != null,
      onTapAction: onTap,
    );
  }

  /// 진행률 접근성 래핑
  static Widget wrapProgress({
    required Widget child,
    required double value,
    required double max,
    String? context,
  }) {
    return wrapWithSemantics(
      child: child,
      label: progressLabel(value: value, max: max, context: context),
      slider: true,
    );
  }

  /// 접근성 알림 표시
  static void announceToAccessibility(
    BuildContext context,
    String message, {
    bool polite = true,
  }) {
    SemanticsService.announce(
      message,
      polite ? TextDirection.ltr : TextDirection.rtl,
    );
  }

  /// 접근성 포커스 설정
  static void requestFocus(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  /// 접근성 포커스 해제
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// 고대비 모드 확인
  static bool isHighContrast(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// 애니메이션 감소 모드 확인
  static bool isAnimationReduced(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// 접근성 설정 확인
  static bool isAccessibilityEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// 텍스트 스케일 팩터 확인
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  /// 접근성 설정에 따른 색상 조정
  static Color adjustColorForAccessibility(
    BuildContext context,
    Color baseColor, {
    double? opacity,
  }) {
    if (isHighContrast(context)) {
      // 고대비 모드에서는 더 진한 색상 사용
      return baseColor.withValues(alpha: opacity ?? 1.0);
    }
    return baseColor.withValues(alpha: opacity ?? 0.8);
  }

  /// 접근성 설정에 따른 크기 조정
  static double adjustSizeForAccessibility(
    BuildContext context,
    double baseSize, {
    double? scaleFactor,
  }) {
    final textScaleFactor = getTextScaleFactor(context);
    final adjustedScaleFactor = scaleFactor ?? 1.0;
    return baseSize * textScaleFactor * adjustedScaleFactor;
  }

  /// 접근성 설정에 따른 패딩 조정
  static EdgeInsets adjustPaddingForAccessibility(
    BuildContext context,
    EdgeInsets basePadding, {
    double? scaleFactor,
  }) {
    final textScaleFactor = getTextScaleFactor(context);
    final adjustedScaleFactor = scaleFactor ?? 1.0;
    final scale = textScaleFactor * adjustedScaleFactor;

    return EdgeInsets.only(
      left: basePadding.left * scale,
      top: basePadding.top * scale,
      right: basePadding.right * scale,
      bottom: basePadding.bottom * scale,
    );
  }

  /// 접근성 설정에 따른 마진 조정
  static EdgeInsets adjustMarginForAccessibility(
    BuildContext context,
    EdgeInsets baseMargin, {
    double? scaleFactor,
  }) {
    final textScaleFactor = getTextScaleFactor(context);
    final adjustedScaleFactor = scaleFactor ?? 1.0;
    final scale = textScaleFactor * adjustedScaleFactor;

    return EdgeInsets.only(
      left: baseMargin.left * scale,
      top: baseMargin.top * scale,
      right: baseMargin.right * scale,
      bottom: baseMargin.bottom * scale,
    );
  }

  /// 접근성 설정에 따른 폰트 크기 조정
  static double adjustFontSizeForAccessibility(
    BuildContext context,
    double baseFontSize, {
    double? scaleFactor,
  }) {
    final textScaleFactor = getTextScaleFactor(context);
    final adjustedScaleFactor = scaleFactor ?? 1.0;
    return baseFontSize * textScaleFactor * adjustedScaleFactor;
  }

  /// 접근성 설정에 따른 아이콘 크기 조정
  static double adjustIconSizeForAccessibility(
    BuildContext context,
    double baseIconSize, {
    double? scaleFactor,
  }) {
    final textScaleFactor = getTextScaleFactor(context);
    final adjustedScaleFactor = scaleFactor ?? 1.0;
    return baseIconSize * textScaleFactor * adjustedScaleFactor;
  }

  /// 접근성 설정에 따른 테두리 두께 조정
  static double adjustBorderWidthForAccessibility(
    BuildContext context,
    double baseBorderWidth, {
    double? scaleFactor,
  }) {
    if (isHighContrast(context)) {
      // 고대비 모드에서는 더 두꺼운 테두리 사용
      return baseBorderWidth * 2;
    }
    return baseBorderWidth;
  }

  /// 접근성 설정에 따른 그림자 조정
  static List<BoxShadow> adjustShadowForAccessibility(
    BuildContext context,
    List<BoxShadow> baseShadows, {
    double? scaleFactor,
  }) {
    if (isHighContrast(context)) {
      // 고대비 모드에서는 그림자 제거
      return [];
    }
    return baseShadows;
  }

  /// 접근성 설정에 따른 애니메이션 지속 시간 조정
  static Duration adjustAnimationDurationForAccessibility(
    BuildContext context,
    Duration baseDuration, {
    double? scaleFactor,
  }) {
    if (isAnimationReduced(context)) {
      // 애니메이션 감소 모드에서는 즉시 완료
      return Duration.zero;
    }
    return baseDuration;
  }

  /// 접근성 설정에 따른 애니메이션 곡선 조정
  static Curve adjustAnimationCurveForAccessibility(
    BuildContext context,
    Curve baseCurve,
  ) {
    if (isAnimationReduced(context)) {
      // 애니메이션 감소 모드에서는 선형 곡선 사용
      return Curves.linear;
    }
    return baseCurve;
  }

  /// 접근성 설정 정보 반환
  static Map<String, dynamic> getAccessibilityInfo(BuildContext context) {
    return {
      'isHighContrast': isHighContrast(context),
      'isAnimationReduced': isAnimationReduced(context),
      'isAccessibilityEnabled': isAccessibilityEnabled(context),
      'textScaleFactor': getTextScaleFactor(context),
      'screenWidth': MediaQuery.of(context).size.width,
      'screenHeight': MediaQuery.of(context).size.height,
      'platformBrightness': MediaQuery.of(context).platformBrightness,
    };
  }

  /// 접근성 설정에 따른 테마 조정
  static ThemeData adjustThemeForAccessibility(
    BuildContext context,
    ThemeData baseTheme,
  ) {
    if (isHighContrast(context)) {
      // 고대비 모드에서는 더 강한 대비의 색상 사용
      return baseTheme.copyWith(
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: baseTheme.colorScheme.primary.withValues(alpha: 1.0),
          secondary: baseTheme.colorScheme.secondary.withValues(alpha: 1.0),
          error: baseTheme.colorScheme.error.withValues(alpha: 1.0),
        ),
      );
    }
    return baseTheme;
  }

  /// 접근성 설정에 따른 텍스트 스타일 조정
  static TextStyle adjustTextStyleForAccessibility(
    BuildContext context,
    TextStyle baseStyle, {
    double? scaleFactor,
  }) {
    final adjustedFontSize = adjustFontSizeForAccessibility(
      context,
      baseStyle.fontSize ?? 14.0,
      scaleFactor: scaleFactor,
    );

    return baseStyle.copyWith(
      fontSize: adjustedFontSize,
      fontWeight: isHighContrast(context)
          ? FontWeight.w600
          : baseStyle.fontWeight,
    );
  }
}
