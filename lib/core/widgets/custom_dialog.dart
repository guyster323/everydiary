import 'package:flutter/material.dart';

/// 다이얼로그 크기 옵션
enum DialogSize { small, medium, large, fullScreen }

/// 다이얼로그 타입 옵션
enum DialogType { alert, confirm, info, warning, error, success, custom }

/// 커스텀 다이얼로그 컴포넌트
/// Material Design 3 기반으로 다양한 스타일과 기능을 지원합니다.
class CustomDialog extends StatelessWidget {
  /// 다이얼로그 제목
  final String? title;

  /// 다이얼로그 내용
  final Widget? content;

  /// 다이얼로그 내용 텍스트 (content가 null일 때 사용)
  final String? contentText;

  /// 다이얼로그 타입
  final DialogType type;

  /// 다이얼로그 크기
  final DialogSize size;

  /// 액션 버튼들
  final List<Widget>? actions;

  /// 닫기 가능 여부
  final bool barrierDismissible;

  /// 배경색
  final Color? backgroundColor;

  /// 모서리 반경
  final double borderRadius;

  /// 그림자 높이
  final double elevation;

  /// 최대 너비
  final double? maxWidth;

  /// 최대 높이
  final double? maxHeight;

  /// 애니메이션
  final Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  )?
  transitionBuilder;

  const CustomDialog({
    super.key,
    this.title,
    this.content,
    this.contentText,
    this.type = DialogType.custom,
    this.size = DialogSize.medium,
    this.actions,
    this.barrierDismissible = true,
    this.backgroundColor,
    this.borderRadius = 16.0,
    this.elevation = 8.0,
    this.maxWidth,
    this.maxHeight,
    this.transitionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 다이얼로그 내용 구성
    final dialogContent = _buildDialogContent(theme, colorScheme);

    // 크기에 따른 제약 조건 설정
    final constraints = _getConstraints();

    return Dialog(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ConstrainedBox(constraints: constraints, child: dialogContent),
    );
  }

  /// 다이얼로그 내용 구성
  Widget _buildDialogContent(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 아이콘 (타입에 따라)
        if (type != DialogType.custom) ...[
          const SizedBox(height: 24),
          _buildTypeIcon(colorScheme),
          const SizedBox(height: 16),
        ],

        // 제목
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              title!,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 내용
        if (content != null || contentText != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child:
                content ??
                Text(
                  contentText!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
          ),
          const SizedBox(height: 24),
        ],

        // 액션 버튼들
        if (actions != null && actions!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  /// 타입에 따른 아이콘 구성
  Widget _buildTypeIcon(ColorScheme colorScheme) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case DialogType.alert:
        iconData = Icons.warning_amber_rounded;
        iconColor = Colors.orange;
        break;
      case DialogType.confirm:
        iconData = Icons.help_outline_rounded;
        iconColor = colorScheme.primary;
        break;
      case DialogType.info:
        iconData = Icons.info_outline_rounded;
        iconColor = colorScheme.primary;
        break;
      case DialogType.warning:
        iconData = Icons.warning_amber_rounded;
        iconColor = Colors.orange;
        break;
      case DialogType.error:
        iconData = Icons.error_outline_rounded;
        iconColor = colorScheme.error;
        break;
      case DialogType.success:
        iconData = Icons.check_circle_outline_rounded;
        iconColor = Colors.green;
        break;
      case DialogType.custom:
        iconData = Icons.info_outline_rounded;
        iconColor = colorScheme.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, size: 32, color: iconColor),
    );
  }

  /// 크기에 따른 제약 조건 반환
  BoxConstraints _getConstraints() {
    switch (size) {
      case DialogSize.small:
        return BoxConstraints(
          maxWidth: maxWidth ?? 300,
          maxHeight: maxHeight ?? 200,
        );
      case DialogSize.medium:
        return BoxConstraints(
          maxWidth: maxWidth ?? 400,
          maxHeight: maxHeight ?? 300,
        );
      case DialogSize.large:
        return BoxConstraints(
          maxWidth: maxWidth ?? 500,
          maxHeight: maxHeight ?? 400,
        );
      case DialogSize.fullScreen:
        return BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
          maxHeight: maxHeight ?? double.infinity,
        );
    }
  }

  /// 다이얼로그 표시
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? content,
    String? contentText,
    DialogType type = DialogType.custom,
    DialogSize size = DialogSize.medium,
    List<Widget>? actions,
    bool barrierDismissible = true,
    Color? backgroundColor,
    double borderRadius = 16.0,
    double elevation = 8.0,
    double? maxWidth,
    double? maxHeight,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transitionBuilder,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        title: title,
        content: content,
        contentText: contentText,
        type: type,
        size: size,
        actions: actions,
        barrierDismissible: barrierDismissible,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        elevation: elevation,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        transitionBuilder: transitionBuilder,
      ),
    );
  }
}

/// 알림 다이얼로그
class AlertDialog extends StatelessWidget {
  /// 제목
  final String? title;

  /// 내용
  final String? content;

  /// 확인 버튼 텍스트
  final String confirmText;

  /// 확인 버튼 콜백
  final VoidCallback? onConfirm;

  /// 다이얼로그 크기
  final DialogSize size;

  const AlertDialog({
    super.key,
    this.title,
    this.content,
    this.confirmText = '확인',
    this.onConfirm,
    this.size = DialogSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: title,
      contentText: content,
      type: DialogType.alert,
      size: size,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// 알림 다이얼로그 표시
  static Future<void> show({
    required BuildContext context,
    String? title,
    String? content,
    String confirmText = '확인',
    VoidCallback? onConfirm,
    DialogSize size = DialogSize.medium,
  }) {
    return CustomDialog.show(
      context: context,
      title: title,
      contentText: content,
      type: DialogType.alert,
      size: size,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}

/// 확인 다이얼로그
class ConfirmDialog extends StatelessWidget {
  /// 제목
  final String? title;

  /// 내용
  final String? content;

  /// 취소 버튼 텍스트
  final String cancelText;

  /// 확인 버튼 텍스트
  final String confirmText;

  /// 취소 버튼 콜백
  final VoidCallback? onCancel;

  /// 확인 버튼 콜백
  final VoidCallback? onConfirm;

  /// 다이얼로그 크기
  final DialogSize size;

  const ConfirmDialog({
    super.key,
    this.title,
    this.content,
    this.cancelText = '취소',
    this.confirmText = '확인',
    this.onCancel,
    this.onConfirm,
    this.size = DialogSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: title,
      contentText: content,
      type: DialogType.confirm,
      size: size,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// 확인 다이얼로그 표시
  static Future<bool?> show({
    required BuildContext context,
    String? title,
    String? content,
    String cancelText = '취소',
    String confirmText = '확인',
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
    DialogSize size = DialogSize.medium,
  }) {
    return CustomDialog.show<bool>(
      context: context,
      title: title,
      contentText: content,
      type: DialogType.confirm,
      size: size,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}

/// 정보 다이얼로그
class InfoDialog extends StatelessWidget {
  /// 제목
  final String? title;

  /// 내용
  final String? content;

  /// 확인 버튼 텍스트
  final String confirmText;

  /// 확인 버튼 콜백
  final VoidCallback? onConfirm;

  /// 다이얼로그 크기
  final DialogSize size;

  const InfoDialog({
    super.key,
    this.title,
    this.content,
    this.confirmText = '확인',
    this.onConfirm,
    this.size = DialogSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: title,
      contentText: content,
      type: DialogType.info,
      size: size,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// 정보 다이얼로그 표시
  static Future<void> show({
    required BuildContext context,
    String? title,
    String? content,
    String confirmText = '확인',
    VoidCallback? onConfirm,
    DialogSize size = DialogSize.medium,
  }) {
    return CustomDialog.show(
      context: context,
      title: title,
      contentText: content,
      type: DialogType.info,
      size: size,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}

/// 에러 다이얼로그
class ErrorDialog extends StatelessWidget {
  /// 제목
  final String? title;

  /// 내용
  final String? content;

  /// 확인 버튼 텍스트
  final String confirmText;

  /// 확인 버튼 콜백
  final VoidCallback? onConfirm;

  /// 다이얼로그 크기
  final DialogSize size;

  const ErrorDialog({
    super.key,
    this.title,
    this.content,
    this.confirmText = '확인',
    this.onConfirm,
    this.size = DialogSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: title ?? '오류',
      contentText: content,
      type: DialogType.error,
      size: size,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// 에러 다이얼로그 표시
  static Future<void> show({
    required BuildContext context,
    String? title,
    String? content,
    String confirmText = '확인',
    VoidCallback? onConfirm,
    DialogSize size = DialogSize.medium,
  }) {
    return CustomDialog.show(
      context: context,
      title: title ?? '오류',
      contentText: content,
      type: DialogType.error,
      size: size,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}

/// 성공 다이얼로그
class SuccessDialog extends StatelessWidget {
  /// 제목
  final String? title;

  /// 내용
  final String? content;

  /// 확인 버튼 텍스트
  final String confirmText;

  /// 확인 버튼 콜백
  final VoidCallback? onConfirm;

  /// 다이얼로그 크기
  final DialogSize size;

  const SuccessDialog({
    super.key,
    this.title,
    this.content,
    this.confirmText = '확인',
    this.onConfirm,
    this.size = DialogSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: title ?? '성공',
      contentText: content,
      type: DialogType.success,
      size: size,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// 성공 다이얼로그 표시
  static Future<void> show({
    required BuildContext context,
    String? title,
    String? content,
    String confirmText = '확인',
    VoidCallback? onConfirm,
    DialogSize size = DialogSize.medium,
  }) {
    return CustomDialog.show(
      context: context,
      title: title ?? '성공',
      contentText: content,
      type: DialogType.success,
      size: size,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}

/// 로딩 다이얼로그
class LoadingDialog extends StatelessWidget {
  /// 메시지
  final String? message;

  /// 다이얼로그 크기
  final DialogSize size;

  const LoadingDialog({super.key, this.message, this.size = DialogSize.small});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomDialog(
      size: size,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// 로딩 다이얼로그 표시
  static Future<void> show({
    required BuildContext context,
    String? message,
    DialogSize size = DialogSize.small,
  }) {
    return CustomDialog.show(
      context: context,
      content: LoadingDialog(message: message, size: size),
      barrierDismissible: false,
    );
  }
}

/// 바텀 시트 다이얼로그
class BottomSheetDialog extends StatelessWidget {
  /// 제목
  final String? title;

  /// 내용
  final Widget? content;

  /// 액션 버튼들
  final List<Widget>? actions;

  /// 배경색
  final Color? backgroundColor;

  /// 모서리 반경
  final double borderRadius;

  /// 최대 높이
  final double? maxHeight;

  const BottomSheetDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.backgroundColor,
    this.borderRadius = 16.0,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 제목
          if (title != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                title!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 내용
          if (content != null) ...[
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: content!,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 액션 버튼들
          if (actions != null && actions!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  /// 바텀 시트 다이얼로그 표시
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? content,
    List<Widget>? actions,
    Color? backgroundColor,
    double borderRadius = 16.0,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BottomSheetDialog(
        title: title,
        content: content,
        actions: actions,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        maxHeight: maxHeight,
      ),
    );
  }
}
