import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import 'accessibility_service.dart';

/// 접근성 지원 위젯들
/// 앱의 접근성을 향상시키는 다양한 위젯들을 제공합니다.

/// 접근성 버튼
/// 접근성 기능을 지원하는 버튼 위젯입니다.
class AccessibilityButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? semanticLabel;
  final String? tooltip;
  final bool enabled;
  final ButtonStyle? style;

  const AccessibilityButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.semanticLabel,
    this.tooltip,
    this.enabled = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? text,
      hint: tooltip,
      button: true,
      enabled: enabled,
      child: Tooltip(
        message: tooltip ?? text,
        child: ElevatedButton.icon(
          onPressed: enabled ? onPressed : null,
          icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
          label: Text(text),
          style: style,
        ),
      ),
    );
  }
}

/// 접근성 텍스트 필드
/// 접근성 기능을 지원하는 텍스트 필드 위젯입니다.
class AccessibilityTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? semanticLabel;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;

  const AccessibilityTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.semanticLabel,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? label,
      hint: hint,
      textField: true,
      enabled: enabled,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helperText,
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

/// 접근성 스위치
/// 접근성 기능을 지원하는 스위치 위젯입니다.
class AccessibilitySwitch extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;
  final bool enabled;

  const AccessibilitySwitch({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.semanticLabel,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? title,
      hint: subtitle,
      toggled: value,
      enabled: enabled,
      child: SwitchListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}

/// 접근성 카드
/// 접근성 기능을 지원하는 카드 위젯입니다.
class AccessibilityCard extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const AccessibilityCard({
    super.key,
    required this.child,
    this.semanticLabel,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: Card(
        margin: margin,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 접근성 리스트 타일
/// 접근성 기능을 지원하는 리스트 타일 위젯입니다.
class AccessibilityListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool enabled;

  const AccessibilityListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? title,
      hint: subtitle,
      button: onTap != null,
      enabled: enabled,
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        leading: leading,
        trailing: trailing,
        onTap: enabled ? onTap : null,
      ),
    );
  }
}

/// 접근성 이미지
/// 접근성 기능을 지원하는 이미지 위젯입니다.
class AccessibilityImage extends StatelessWidget {
  final String imageUrl;
  final String? semanticLabel;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AccessibilityImage({
    super.key,
    required this.imageUrl,
    this.semanticLabel,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? const CircularProgressIndicator();
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? const Icon(Icons.error);
        },
      ),
    );
  }
}

/// 접근성 앱바
/// 접근성 기능을 지원하는 앱바 위젯입니다.
class AccessibilityAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final String? semanticLabel;
  final bool automaticallyImplyLeading;

  const AccessibilityAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.semanticLabel,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? title,
      header: true,
      child: AppBar(
        title: Text(title),
        actions: actions,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 접근성 스낵바
/// 접근성 기능을 지원하는 스낵바 위젯입니다.
class AccessibilitySnackBar extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final Color? backgroundColor;
  final Color? textColor;

  const AccessibilitySnackBar({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.duration = const Duration(seconds: 4),
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: message,
      liveRegion: true,
      child: SnackBar(
        content: Text(message),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(label: actionLabel!, onPressed: onAction!)
            : null,
        duration: duration,
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// 접근성 다이얼로그
/// 접근성 기능을 지원하는 다이얼로그 위젯입니다.
class AccessibilityDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final String? semanticLabel;
  final bool barrierDismissible;

  const AccessibilityDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.semanticLabel,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? title,
      child: AlertDialog(
        title: Text(title),
        content: content,
        actions: actions,
      ),
    );
  }
}

/// 접근성 로딩 인디케이터
/// 접근성 기능을 지원하는 로딩 인디케이터 위젯입니다.
class AccessibilityLoadingIndicator extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const AccessibilityLoadingIndicator({
    super.key,
    this.message,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Semantics(
      label: message ?? localizations.translate('loading'),
      liveRegion: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size ?? 40,
              height: size ?? 40,
              child: CircularProgressIndicator(color: color, strokeWidth: 3),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message!, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

/// 접근성 에러 위젯
/// 접근성 기능을 지원하는 에러 위젯입니다.
class AccessibilityErrorWidget extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  const AccessibilityErrorWidget({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: message,
      liveRegion: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// 접근성 헬퍼 함수들
class AccessibilityHelper {
  /// 접근성 알림 표시
  static void announceForAccessibility(BuildContext context, String message) {
    final accessibilityService = AccessibilityService.instance;
    accessibilityService.announceForAccessibility(message);
  }

  /// 접근성 포커스 설정
  static void setAccessibilityFocus(BuildContext context, String widgetId) {
    final accessibilityService = AccessibilityService.instance;
    accessibilityService.setAccessibilityFocus(widgetId);
  }

  /// 접근성 라벨 설정
  static void setAccessibilityLabel(
    BuildContext context,
    String widgetId,
    String label,
  ) {
    final accessibilityService = AccessibilityService.instance;
    accessibilityService.setAccessibilityLabel(widgetId, label);
  }

  /// 접근성 힌트 설정
  static void setAccessibilityHint(
    BuildContext context,
    String widgetId,
    String hint,
  ) {
    final accessibilityService = AccessibilityService.instance;
    accessibilityService.setAccessibilityHint(widgetId, hint);
  }

  /// 접근성 스낵바 표시
  static void showAccessibilitySnackBar(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final snackBar = SnackBar(
      content: Text(message),
      action: actionLabel != null && onAction != null
          ? SnackBarAction(label: actionLabel, onPressed: onAction)
          : null,
      duration: duration,
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// 접근성 다이얼로그 표시
  static void showAccessibilityDialog(
    BuildContext context,
    String title,
    Widget content, {
    List<Widget>? actions,
    String? semanticLabel,
    bool barrierDismissible = true,
  }) {
    final dialog = AccessibilityDialog(
      title: title,
      content: content,
      actions: actions,
      semanticLabel: semanticLabel,
      barrierDismissible: barrierDismissible,
    );

    showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => dialog,
    );
  }
}
