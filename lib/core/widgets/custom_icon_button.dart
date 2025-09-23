import 'package:flutter/material.dart';

import '../utils/accessibility_helper.dart';

/// 아이콘 버튼 크기 옵션
enum IconButtonSize { small, medium, large, extraLarge }

/// 아이콘 버튼 스타일 옵션
enum IconButtonStyle { filled, outlined, text, ghost }

/// 커스텀 아이콘 버튼 컴포넌트
/// Material Design 3 기반으로 다양한 스타일과 크기를 지원하는 아이콘 전용 버튼입니다.
class CustomIconButton extends StatelessWidget {
  /// 아이콘 (Material Icons 또는 커스텀 아이콘)
  final IconData? icon;

  /// 커스텀 아이콘 위젯 (icon과 함께 사용 불가)
  final Widget? customIcon;

  /// 클릭 콜백
  final VoidCallback? onPressed;

  /// 버튼 스타일 (filled, outlined, text, ghost)
  final IconButtonStyle style;

  /// 버튼 크기 (small, medium, large, extraLarge)
  final IconButtonSize size;

  /// 로딩 상태
  final bool isLoading;

  /// 비활성화 상태
  final bool isDisabled;

  /// 툴팁 메시지
  final String? tooltip;

  /// 배경색 (선택사항)
  final Color? backgroundColor;

  /// 전경색 (선택사항)
  final Color? foregroundColor;

  /// 테두리 색상 (outlined 스타일일 때)
  final Color? borderColor;

  /// 호버 색상 (선택사항)
  final Color? hoverColor;

  /// 포커스 색상 (선택사항)
  final Color? focusColor;

  /// 원형 버튼 여부
  final bool isCircular;

  /// 그림자 여부
  final bool hasShadow;

  /// 접근성 라벨
  final String? semanticLabel;

  /// 접근성 힌트
  final String? semanticHint;

  /// 키보드 단축키
  final LogicalKeySet? shortcut;

  const CustomIconButton({
    super.key,
    this.icon,
    this.customIcon,
    this.onPressed,
    this.style = IconButtonStyle.filled,
    this.size = IconButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.hoverColor,
    this.focusColor,
    this.isCircular = true,
    this.hasShadow = false,
    this.semanticLabel,
    this.semanticHint,
    this.shortcut,
  }) : assert(
         (icon != null && customIcon == null) ||
             (icon == null && customIcon != null),
         'icon과 customIcon 중 하나만 제공해야 합니다.',
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 비활성화 상태 또는 로딩 중일 때 onPressed를 null로 설정
    final effectiveOnPressed = (isDisabled || isLoading) ? null : onPressed;

    // 색상 결정
    final effectiveBackgroundColor = _getBackgroundColor(colorScheme);
    final effectiveForegroundColor = _getForegroundColor(colorScheme);
    final effectiveBorderColor = _getBorderColor(colorScheme);

    // 크기 결정
    final buttonSize = _getButtonSize(context);
    final iconSize = _getIconSize(context);

    // 아이콘 위젯 구성
    Widget iconWidget;
    if (isLoading) {
      iconWidget = SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(effectiveForegroundColor),
        ),
      );
    } else if (customIcon != null) {
      iconWidget = SizedBox(
        width: iconSize,
        height: iconSize,
        child: customIcon,
      );
    } else if (icon != null) {
      iconWidget = Icon(icon, size: iconSize, color: effectiveForegroundColor);
    } else {
      iconWidget = const SizedBox.shrink();
    }

    // 버튼 위젯 구성
    Widget buttonWidget = _buildButton(
      context: context,
      theme: theme,
      colorScheme: colorScheme,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      borderColor: effectiveBorderColor,
      buttonSize: buttonSize,
      iconWidget: iconWidget,
      effectiveOnPressed: effectiveOnPressed,
    );

    // 툴팁 래핑
    if (tooltip != null && effectiveOnPressed != null) {
      buttonWidget = Tooltip(message: tooltip!, child: buttonWidget);
    }

    // 접근성 래핑 강화
    buttonWidget = AccessibilityHelper.wrapButton(
      child: buttonWidget,
      label: semanticLabel ?? (icon != null ? '아이콘 버튼' : '버튼'),
      hint: semanticHint,
      isEnabled: effectiveOnPressed != null,
      isSelected: false,
      onTap: effectiveOnPressed,
    );

    // 키보드 단축키 래핑
    if (shortcut != null && effectiveOnPressed != null) {
      buttonWidget = Shortcuts(
        shortcuts: {shortcut!: VoidCallbackIntent(effectiveOnPressed)},
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }

  /// 버튼 위젯 구성
  Widget _buildButton({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required Color? backgroundColor,
    required Color foregroundColor,
    required Color? borderColor,
    required double buttonSize,
    required Widget iconWidget,
    required VoidCallback? effectiveOnPressed,
  }) {
    final borderRadius = isCircular
        ? BorderRadius.circular(buttonSize / 2)
        : BorderRadius.circular(8);

    switch (style) {
      case IconButtonStyle.filled:
        return Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            boxShadow: hasShadow
                ? [
                    BoxShadow(
                      color:
                          backgroundColor?.withValues(alpha: 0.3) ??
                          Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: effectiveOnPressed,
              borderRadius: borderRadius,
              hoverColor: hoverColor ?? foregroundColor.withValues(alpha: 0.08),
              focusColor: focusColor ?? foregroundColor.withValues(alpha: 0.12),
              splashColor: foregroundColor.withValues(alpha: 0.12),
              child: Center(child: iconWidget),
            ),
          ),
        );

      case IconButtonStyle.outlined:
        return Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: Border.all(
              color: borderColor ?? foregroundColor.withValues(alpha: 0.5),
              width: 1.0,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: effectiveOnPressed,
              borderRadius: borderRadius,
              hoverColor: hoverColor ?? foregroundColor.withValues(alpha: 0.08),
              focusColor: focusColor ?? foregroundColor.withValues(alpha: 0.12),
              splashColor: foregroundColor.withValues(alpha: 0.12),
              child: Center(child: iconWidget),
            ),
          ),
        );

      case IconButtonStyle.text:
        return SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: effectiveOnPressed,
              borderRadius: borderRadius,
              hoverColor: hoverColor ?? foregroundColor.withValues(alpha: 0.08),
              focusColor: focusColor ?? foregroundColor.withValues(alpha: 0.12),
              splashColor: foregroundColor.withValues(alpha: 0.12),
              child: Center(child: iconWidget),
            ),
          ),
        );

      case IconButtonStyle.ghost:
        return SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: effectiveOnPressed,
              borderRadius: borderRadius,
              hoverColor: hoverColor ?? foregroundColor.withValues(alpha: 0.04),
              focusColor: focusColor ?? foregroundColor.withValues(alpha: 0.08),
              splashColor: foregroundColor.withValues(alpha: 0.08),
              child: Center(child: iconWidget),
            ),
          ),
        );
    }
  }

  /// 배경색 결정
  Color? _getBackgroundColor(ColorScheme colorScheme) {
    if (backgroundColor != null) return backgroundColor;

    switch (style) {
      case IconButtonStyle.filled:
        return colorScheme.primary;
      case IconButtonStyle.outlined:
      case IconButtonStyle.text:
      case IconButtonStyle.ghost:
        return null;
    }
  }

  /// 전경색 결정
  Color _getForegroundColor(ColorScheme colorScheme) {
    if (foregroundColor != null) return foregroundColor!;

    if (isDisabled) {
      return colorScheme.onSurface.withValues(alpha: 0.38);
    }

    switch (style) {
      case IconButtonStyle.filled:
        return colorScheme.onPrimary;
      case IconButtonStyle.outlined:
      case IconButtonStyle.text:
      case IconButtonStyle.ghost:
        return colorScheme.primary;
    }
  }

  /// 테두리 색상 결정
  Color? _getBorderColor(ColorScheme colorScheme) {
    if (borderColor != null) return borderColor;
    if (style != IconButtonStyle.outlined) return null;

    return isDisabled
        ? colorScheme.onSurface.withValues(alpha: 0.12)
        : colorScheme.outline;
  }

  /// 버튼 크기 반환 (반응형)
  double _getButtonSize(BuildContext context) {
    final baseSize = _getBaseButtonSize();
    return AccessibilityHelper.adjustSizeForAccessibility(context, baseSize);
  }

  /// 기본 버튼 크기 반환
  double _getBaseButtonSize() {
    switch (size) {
      case IconButtonSize.small:
        return 32;
      case IconButtonSize.medium:
        return 40;
      case IconButtonSize.large:
        return 48;
      case IconButtonSize.extraLarge:
        return 56;
    }
  }

  /// 아이콘 크기 반환 (반응형)
  double _getIconSize(BuildContext context) {
    final baseSize = _getBaseIconSize();
    return AccessibilityHelper.adjustIconSizeForAccessibility(
      context,
      baseSize,
    );
  }

  /// 기본 아이콘 크기 반환
  double _getBaseIconSize() {
    switch (size) {
      case IconButtonSize.small:
        return 16;
      case IconButtonSize.medium:
        return 20;
      case IconButtonSize.large:
        return 24;
      case IconButtonSize.extraLarge:
        return 28;
    }
  }

  // === 편의 팩토리 메서드들 ===

  /// 작은 크기 아이콘 버튼
  static Widget small({
    required IconData icon,
    VoidCallback? onPressed,
    IconButtonStyle style = IconButtonStyle.filled,
    String? tooltip,
    Color? backgroundColor,
    Color? foregroundColor,
    bool isCircular = true,
    String? semanticLabel,
  }) {
    return CustomIconButton(
      icon: icon,
      onPressed: onPressed,
      style: style,
      size: IconButtonSize.small,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      isCircular: isCircular,
      semanticLabel: semanticLabel,
    );
  }

  /// 중간 크기 아이콘 버튼
  static Widget medium({
    required IconData icon,
    VoidCallback? onPressed,
    IconButtonStyle style = IconButtonStyle.filled,
    String? tooltip,
    Color? backgroundColor,
    Color? foregroundColor,
    bool isCircular = true,
    String? semanticLabel,
  }) {
    return CustomIconButton(
      icon: icon,
      onPressed: onPressed,
      style: style,
      size: IconButtonSize.medium,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      isCircular: isCircular,
      semanticLabel: semanticLabel,
    );
  }

  /// 큰 크기 아이콘 버튼
  static Widget large({
    required IconData icon,
    VoidCallback? onPressed,
    IconButtonStyle style = IconButtonStyle.filled,
    String? tooltip,
    Color? backgroundColor,
    Color? foregroundColor,
    bool isCircular = true,
    String? semanticLabel,
  }) {
    return CustomIconButton(
      icon: icon,
      onPressed: onPressed,
      style: style,
      size: IconButtonSize.large,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      isCircular: isCircular,
      semanticLabel: semanticLabel,
    );
  }

  /// 매우 큰 크기 아이콘 버튼
  static Widget extraLarge({
    required IconData icon,
    VoidCallback? onPressed,
    IconButtonStyle style = IconButtonStyle.filled,
    String? tooltip,
    Color? backgroundColor,
    Color? foregroundColor,
    bool isCircular = true,
    String? semanticLabel,
  }) {
    return CustomIconButton(
      icon: icon,
      onPressed: onPressed,
      style: style,
      size: IconButtonSize.extraLarge,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      isCircular: isCircular,
      semanticLabel: semanticLabel,
    );
  }

  /// 액션 버튼 (일반적으로 앱바에서 사용)
  static Widget action({
    required IconData icon,
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
    String? semanticLabel,
  }) {
    return CustomIconButton(
      icon: icon,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip,
      foregroundColor: foregroundColor,
      isCircular: false,
      semanticLabel: semanticLabel,
    );
  }

  /// 닫기 버튼
  static Widget close({
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
  }) {
    return CustomIconButton(
      icon: Icons.close,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip ?? '닫기',
      foregroundColor: foregroundColor,
      isCircular: false,
      semanticLabel: '닫기',
    );
  }

  /// 뒤로가기 버튼
  static Widget back({
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
  }) {
    return CustomIconButton(
      icon: Icons.arrow_back,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip ?? '뒤로가기',
      foregroundColor: foregroundColor,
      isCircular: false,
      semanticLabel: '뒤로가기',
    );
  }

  /// 메뉴 버튼
  static Widget menu({
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
  }) {
    return CustomIconButton(
      icon: Icons.menu,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip ?? '메뉴',
      foregroundColor: foregroundColor,
      isCircular: false,
      semanticLabel: '메뉴',
    );
  }

  /// 더보기 버튼
  static Widget more({
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
  }) {
    return CustomIconButton(
      icon: Icons.more_vert,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip ?? '더보기',
      foregroundColor: foregroundColor,
      isCircular: false,
      semanticLabel: '더보기',
    );
  }

  /// 검색 버튼
  static Widget search({
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
  }) {
    return CustomIconButton(
      icon: Icons.search,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip ?? '검색',
      foregroundColor: foregroundColor,
      isCircular: false,
      semanticLabel: '검색',
    );
  }

  /// 즐겨찾기 버튼
  static Widget favorite({
    required bool isFavorited,
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
    Color? favoritedColor,
  }) {
    return CustomIconButton(
      icon: isFavorited ? Icons.favorite : Icons.favorite_border,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip ?? (isFavorited ? '즐겨찾기 해제' : '즐겨찾기'),
      foregroundColor: isFavorited
          ? (favoritedColor ?? Colors.red)
          : foregroundColor,
      isCircular: false,
      semanticLabel: isFavorited ? '즐겨찾기 해제' : '즐겨찾기',
    );
  }

  /// 공유 버튼
  static Widget share({
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
  }) {
    return CustomIconButton(
      icon: Icons.share,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip ?? '공유',
      foregroundColor: foregroundColor,
      isCircular: false,
      semanticLabel: '공유',
    );
  }

  /// 편집 버튼
  static Widget edit({
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
  }) {
    return CustomIconButton(
      icon: Icons.edit,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip ?? '편집',
      foregroundColor: foregroundColor,
      isCircular: false,
      semanticLabel: '편집',
    );
  }

  /// 삭제 버튼
  static Widget delete({
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
  }) {
    return CustomIconButton(
      icon: Icons.delete,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip ?? '삭제',
      foregroundColor: foregroundColor ?? Colors.red,
      isCircular: false,
      semanticLabel: '삭제',
    );
  }

  /// 저장 버튼
  static Widget save({
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
  }) {
    return CustomIconButton(
      icon: Icons.save,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip ?? '저장',
      foregroundColor: foregroundColor,
      isCircular: false,
      semanticLabel: '저장',
    );
  }

  /// 새로고침 버튼
  static Widget refresh({
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
    bool isLoading = false,
  }) {
    return CustomIconButton(
      icon: Icons.refresh,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip ?? '새로고침',
      foregroundColor: foregroundColor,
      isCircular: false,
      isLoading: isLoading,
      semanticLabel: '새로고침',
    );
  }

  /// 설정 버튼
  static Widget settings({
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
  }) {
    return CustomIconButton(
      icon: Icons.settings,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip ?? '설정',
      foregroundColor: foregroundColor,
      isCircular: false,
      semanticLabel: '설정',
    );
  }

  /// 도움말 버튼
  static Widget help({
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
  }) {
    return CustomIconButton(
      icon: Icons.help_outline,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip ?? '도움말',
      foregroundColor: foregroundColor,
      isCircular: false,
      semanticLabel: '도움말',
    );
  }

  /// 정보 버튼
  static Widget info({
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
  }) {
    return CustomIconButton(
      icon: Icons.info_outline,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip ?? '정보',
      foregroundColor: foregroundColor,
      isCircular: false,
      semanticLabel: '정보',
    );
  }

  /// 경고 버튼
  static Widget warning({
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
  }) {
    return CustomIconButton(
      icon: Icons.warning_amber_outlined,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip ?? '경고',
      foregroundColor: foregroundColor ?? Colors.orange,
      isCircular: false,
      semanticLabel: '경고',
    );
  }

  /// 오류 버튼
  static Widget error({
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
  }) {
    return CustomIconButton(
      icon: Icons.error_outline,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip ?? '오류',
      foregroundColor: foregroundColor ?? Colors.red,
      isCircular: false,
      semanticLabel: '오류',
    );
  }

  /// 성공 버튼
  static Widget success({
    VoidCallback? onPressed,
    String? tooltip,
    Color? foregroundColor,
  }) {
    return CustomIconButton(
      icon: Icons.check_circle_outline,
      onPressed: onPressed,
      style: IconButtonStyle.text,
      size: IconButtonSize.medium,
      tooltip: tooltip ?? '성공',
      foregroundColor: foregroundColor ?? Colors.green,
      isCircular: false,
      semanticLabel: '성공',
    );
  }
}
