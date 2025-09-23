import 'package:flutter/material.dart';

import '../accessibility/accessibility_utils.dart';
import '../animations/interaction_animations.dart';

/// 커스텀 카드 위젯
/// 다양한 스타일과 상태를 지원하는 재사용 가능한 카드입니다.
class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.child,
    this.elevation,
    this.borderRadius,
    this.margin,
    this.padding,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.border,
    this.clipBehavior = Clip.none,
    this.onTap,
    this.onLongPress,
    this.semanticContainer = true,
    this.shape,
  });

  /// 카드 내용
  final Widget child;

  /// 그림자 높이
  final double? elevation;

  /// 테두리 반지름
  final double? borderRadius;

  /// 외부 여백
  final EdgeInsetsGeometry? margin;

  /// 내부 여백
  final EdgeInsetsGeometry? padding;

  /// 배경색
  final Color? color;

  /// 그림자 색상
  final Color? shadowColor;

  /// 표면 틴트 색상
  final Color? surfaceTintColor;

  /// 테두리
  final Border? border;

  /// 클리핑 동작
  final Clip clipBehavior;

  /// 탭 콜백
  final VoidCallback? onTap;

  /// 롱 프레스 콜백
  final VoidCallback? onLongPress;

  /// 시맨틱 컨테이너 여부
  final bool semanticContainer;

  /// 모양
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 카드 스타일 계산
    final cardTheme = _buildCardTheme(context, theme, colorScheme);

    // 내용 위젯 생성
    final cardChild = _buildCardChild();

    // 카드 위젯 생성
    Widget card = Card(
      elevation: cardTheme.elevation,
      color: cardTheme.color,
      shadowColor: cardTheme.shadowColor,
      surfaceTintColor: cardTheme.surfaceTintColor,
      shape: cardTheme.shape,
      margin: cardTheme.margin,
      clipBehavior: clipBehavior,
      semanticContainer: semanticContainer,
      child: cardChild,
    );

    // 탭 가능한 경우 InkWell로 감싸기
    if (onTap != null || onLongPress != null) {
      card = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        child: card,
      );
    }

    // 애니메이션 적용
    if (onTap != null) {
      card = InteractionAnimations.tapFeedback(onTap: onTap!, child: card);
    }

    // 접근성 적용 (기본적으로 카드에 대한 시맨틱 라벨 제공)
    card = AccessibilityUtils.semanticLabel(label: '카드', child: card);

    return card;
  }

  /// 카드 테마 생성
  CardTheme _buildCardTheme(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final borderRadius = this.borderRadius ?? 16.0;
    final margin = this.margin ?? const EdgeInsets.all(8);

    return CardTheme(
      elevation: elevation ?? 1,
      color: color ?? colorScheme.surface,
      shadowColor: shadowColor ?? colorScheme.shadow.withValues(alpha: 0.1),
      surfaceTintColor: surfaceTintColor ?? Colors.transparent,
      shape:
          shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: border?.left ?? BorderSide.none,
          ),
      margin: margin,
    );
  }

  /// 카드 내용 위젯 생성
  Widget _buildCardChild() {
    if (padding != null) {
      return Padding(padding: padding!, child: child);
    }
    return child;
  }
}

/// 편의 생성자들
extension CustomCardConvenience on CustomCard {
  /// 작은 카드
  static CustomCard small({
    required Widget child,
    double? elevation,
    double? borderRadius,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return CustomCard(
      elevation: elevation ?? 0.5,
      borderRadius: borderRadius ?? 8,
      margin: margin ?? const EdgeInsets.all(4),
      padding: padding ?? const EdgeInsets.all(12),
      color: color,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  /// 큰 카드
  static CustomCard large({
    required Widget child,
    double? elevation,
    double? borderRadius,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return CustomCard(
      elevation: elevation ?? 2,
      borderRadius: borderRadius ?? 20,
      margin: margin ?? const EdgeInsets.all(12),
      padding: padding ?? const EdgeInsets.all(20),
      color: color,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  /// 플랫 카드 (그림자 없음)
  static CustomCard flat({
    required Widget child,
    double? borderRadius,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    Border? border,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return CustomCard(
      elevation: 0,
      borderRadius: borderRadius ?? 16,
      margin: margin ?? const EdgeInsets.all(8),
      padding: padding ?? const EdgeInsets.all(16),
      color: color,
      border: border,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  /// 강조된 카드 (높은 그림자)
  static CustomCard elevated({
    required Widget child,
    double? elevation,
    double? borderRadius,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return CustomCard(
      elevation: elevation ?? 4,
      borderRadius: borderRadius ?? 16,
      margin: margin ?? const EdgeInsets.all(8),
      padding: padding ?? const EdgeInsets.all(16),
      color: color,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  /// 리스트 아이템 카드
  static CustomCard listItem({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return CustomCard(
      elevation: 0,
      borderRadius: 0,
      margin: margin ?? EdgeInsets.zero,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: color,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  /// 투명한 배경 카드 (감정 배경과 조화)
  static CustomCard transparent({
    required Widget child,
    double? borderRadius,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return CustomCard(
      elevation: 0,
      borderRadius: borderRadius ?? 16,
      margin: margin ?? const EdgeInsets.all(8),
      padding: padding ?? const EdgeInsets.all(16),
      color:
          color?.withValues(alpha: 0.6) ?? Colors.white.withValues(alpha: 0.6),
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
}
