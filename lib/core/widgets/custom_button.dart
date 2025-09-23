import 'package:flutter/material.dart';

import '../accessibility/accessibility_utils.dart';
import '../animations/interaction_animations.dart';

/// 커스텀 버튼 위젯
/// 다양한 스타일과 상태를 지원하는 재사용 가능한 버튼입니다.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = ButtonVariant.filled,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.iconPosition = IconPosition.start,
    this.fullWidth = false,
    this.borderRadius,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
    this.minimumSize,
    this.maximumSize,
    this.tooltip,
  });

  /// 버튼 클릭 콜백
  final VoidCallback? onPressed;

  /// 버튼 내용
  final Widget child;

  /// 버튼 스타일 변형
  final ButtonVariant variant;

  /// 버튼 크기
  final ButtonSize size;

  /// 로딩 상태
  final bool isLoading;

  /// 비활성화 상태
  final bool isDisabled;

  /// 아이콘
  final IconData? icon;

  /// 아이콘 위치
  final IconPosition iconPosition;

  /// 전체 너비 사용 여부
  final bool fullWidth;

  /// 테두리 반지름
  final double? borderRadius;

  /// 그림자 높이
  final double? elevation;

  /// 배경색
  final Color? backgroundColor;

  /// 전경색
  final Color? foregroundColor;

  /// 테두리 색상
  final Color? borderColor;

  /// 패딩
  final EdgeInsetsGeometry? padding;

  /// 최소 크기
  final Size? minimumSize;

  /// 최대 크기
  final Size? maximumSize;

  /// 툴팁
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 버튼 상태 결정
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    // 스타일 계산
    final buttonStyle = _getButtonStyle(context, theme, colorScheme, isEnabled);

    // 내용 위젯 생성
    final buttonChild = _buildButtonChild(context);

    // 툴팁이 있는 경우 Tooltip으로 감싸기
    Widget button = _buildButton(context, buttonStyle, buttonChild);

    if (tooltip != null && isEnabled) {
      button = Tooltip(message: tooltip!, child: button);
    }

    // 애니메이션 적용
    if (isEnabled && onPressed != null) {
      button = InteractionAnimations.tapFeedback(
        onTap: onPressed!,
        child: button,
      );
    }

    // 접근성 적용
    button = AccessibilityUtils.semanticButton(
      label: tooltip ?? '버튼',
      hint: tooltip,
      onTap: isEnabled ? onPressed : null,
      enabled: isEnabled,
      child: button,
    );

    return button;
  }

  /// 버튼 스타일 계산
  ButtonStyle _getButtonStyle(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isEnabled,
  ) {
    final sizeConfig = _getSizeConfig(context);

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (!isEnabled) {
          return colorScheme.onSurface.withValues(alpha: 0.12);
        }

        switch (variant) {
          case ButtonVariant.filled:
            return backgroundColor ?? colorScheme.primary;
          case ButtonVariant.outlined:
            return backgroundColor ?? Colors.transparent;
          case ButtonVariant.text:
            return backgroundColor ?? Colors.transparent;
        }
      }),

      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (!isEnabled) {
          return colorScheme.onSurface.withValues(alpha: 0.38);
        }

        switch (variant) {
          case ButtonVariant.filled:
            return foregroundColor ?? colorScheme.onPrimary;
          case ButtonVariant.outlined:
          case ButtonVariant.text:
            return foregroundColor ?? colorScheme.primary;
        }
      }),

      side: WidgetStateProperty.resolveWith((states) {
        if (variant == ButtonVariant.outlined) {
          return BorderSide(
            color: !isEnabled
                ? colorScheme.onSurface.withValues(alpha: 0.12)
                : borderColor ?? colorScheme.outline,
            width: 1,
          );
        }
        return BorderSide.none;
      }),

      elevation: WidgetStateProperty.resolveWith((states) {
        if (variant == ButtonVariant.filled) {
          return elevation ?? (isEnabled ? 1 : 0);
        }
        return 0;
      }),

      shadowColor: WidgetStateProperty.all(
        colorScheme.shadow.withValues(alpha: 0.1),
      ),

      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? sizeConfig.borderRadius,
          ),
        ),
      ),

      padding: WidgetStateProperty.all(padding ?? sizeConfig.padding),

      minimumSize: WidgetStateProperty.all(
        minimumSize ?? sizeConfig.minimumSize,
      ),

      maximumSize: WidgetStateProperty.all(maximumSize),

      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colorScheme.onSurface.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.hovered)) {
          return colorScheme.onSurface.withValues(alpha: 0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return colorScheme.onSurface.withValues(alpha: 0.12);
        }
        return Colors.transparent;
      }),
    );
  }

  /// 버튼 내용 위젯 생성
  Widget _buildButtonChild(BuildContext context) {
    if (isLoading) {
      return _buildLoadingChild(context);
    }

    if (icon != null) {
      return _buildIconChild(context);
    }

    return child;
  }

  /// 로딩 상태 위젯
  Widget _buildLoadingChild(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color loadingColor;
    switch (variant) {
      case ButtonVariant.filled:
        loadingColor = colorScheme.onPrimary;
        break;
      case ButtonVariant.outlined:
      case ButtonVariant.text:
        loadingColor = colorScheme.primary;
        break;
    }

    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
      ),
    );
  }

  /// 아이콘과 텍스트가 있는 위젯
  Widget _buildIconChild(BuildContext context) {
    final sizeConfig = _getSizeConfig(context);

    if (iconPosition == IconPosition.start) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: sizeConfig.iconSize),
          const SizedBox(width: 8),
          child,
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(width: 8),
          Icon(icon, size: sizeConfig.iconSize),
        ],
      );
    }
  }

  /// 실제 버튼 위젯 생성
  Widget _buildButton(
    BuildContext context,
    ButtonStyle buttonStyle,
    Widget buttonChild,
  ) {
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    switch (variant) {
      case ButtonVariant.filled:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isEnabled ? onPressed : null,
            style: buttonStyle,
            child: buttonChild,
          ),
        );
      case ButtonVariant.outlined:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isEnabled ? onPressed : null,
            style: buttonStyle,
            child: buttonChild,
          ),
        );
      case ButtonVariant.text:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: TextButton(
            onPressed: isEnabled ? onPressed : null,
            style: buttonStyle,
            child: buttonChild,
          ),
        );
    }
  }

  /// 크기별 설정 반환
  _SizeConfig _getSizeConfig(BuildContext context) {
    switch (size) {
      case ButtonSize.small:
        return const _SizeConfig(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size(64, 32),
          borderRadius: 8,
          iconSize: 16,
        );
      case ButtonSize.medium:
        return const _SizeConfig(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          minimumSize: Size(80, 40),
          borderRadius: 12,
          iconSize: 18,
        );
      case ButtonSize.large:
        return const _SizeConfig(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: Size(96, 48),
          borderRadius: 16,
          iconSize: 20,
        );
    }
  }
}

/// 버튼 스타일 변형
enum ButtonVariant { filled, outlined, text }

/// 버튼 크기
enum ButtonSize { small, medium, large }

/// 아이콘 위치
enum IconPosition { start, end }

/// 크기 설정 클래스
class _SizeConfig {
  const _SizeConfig({
    required this.padding,
    required this.minimumSize,
    required this.borderRadius,
    required this.iconSize,
  });

  final EdgeInsetsGeometry padding;
  final Size minimumSize;
  final double borderRadius;
  final double iconSize;
}

/// 편의 생성자들
extension CustomButtonConvenience on CustomButton {
  /// 작은 크기 버튼
  static CustomButton small({
    required VoidCallback? onPressed,
    required Widget child,
    ButtonVariant variant = ButtonVariant.filled,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    IconPosition iconPosition = IconPosition.start,
    bool fullWidth = false,
    String? tooltip,
  }) {
    return CustomButton(
      onPressed: onPressed,
      variant: variant,
      size: ButtonSize.small,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      iconPosition: iconPosition,
      fullWidth: fullWidth,
      tooltip: tooltip,
      child: child,
    );
  }

  /// 큰 크기 버튼
  static CustomButton large({
    required VoidCallback? onPressed,
    required Widget child,
    ButtonVariant variant = ButtonVariant.filled,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    IconPosition iconPosition = IconPosition.start,
    bool fullWidth = false,
    String? tooltip,
  }) {
    return CustomButton(
      onPressed: onPressed,
      variant: variant,
      size: ButtonSize.large,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      iconPosition: iconPosition,
      fullWidth: fullWidth,
      tooltip: tooltip,
      child: child,
    );
  }

  /// 아이콘 버튼
  static CustomButton icon({
    required VoidCallback? onPressed,
    required IconData icon,
    ButtonVariant variant = ButtonVariant.filled,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    String? tooltip,
  }) {
    return CustomButton(
      onPressed: onPressed,
      variant: variant,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      tooltip: tooltip,
      child: const SizedBox.shrink(),
    );
  }
}
