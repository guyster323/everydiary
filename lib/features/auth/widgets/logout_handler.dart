import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/logout_service.dart';

/// 로그아웃 처리 위젯
class LogoutHandler extends ConsumerStatefulWidget {
  final Widget child;
  final String? redirectRoute;
  final VoidCallback? onLogout;

  const LogoutHandler({
    super.key,
    required this.child,
    this.redirectRoute,
    this.onLogout,
  });

  @override
  ConsumerState<LogoutHandler> createState() => _LogoutHandlerState();
}

class _LogoutHandlerState extends ConsumerState<LogoutHandler> {
  StreamSubscription<LogoutEvent>? _logoutSubscription;

  @override
  void initState() {
    super.initState();
    _setupLogoutListener();
  }

  void _setupLogoutListener() {
    final logoutService = ref.read(logoutServiceProvider);

    _logoutSubscription = logoutService.logoutStream.listen(
      (event) {
        _handleLogoutEvent(event);
      },
      onError: (dynamic error) {
        _handleLogoutError(error);
      },
    );
  }

  void _handleLogoutEvent(LogoutEvent event) {
    if (!mounted) return;

    // 로그아웃 콜백 실행
    widget.onLogout?.call();

    // 리다이렉트 처리
    if (widget.redirectRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            widget.redirectRoute!,
            (route) => false,
          );
        }
      });
    } else {
      // 기본 로그인 화면으로 리다이렉트
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      });
    }

    // 로그아웃 이벤트에 따른 추가 처리
    _showLogoutMessage(event);
  }

  void _handleLogoutError(dynamic error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('로그아웃 처리 중 오류가 발생했습니다: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showLogoutMessage(LogoutEvent event) {
    if (!mounted) return;

    String message;
    Color backgroundColor;

    switch (event.type) {
      case LogoutEventType.userInitiated:
        message = '로그아웃되었습니다.';
        backgroundColor = Colors.blue;
        break;
      case LogoutEventType.tokenExpired:
        message = '세션이 만료되어 로그아웃되었습니다.';
        backgroundColor = Colors.orange;
        break;
      case LogoutEventType.securityBreach:
        message = '보안상의 이유로 로그아웃되었습니다.';
        backgroundColor = Colors.red;
        break;
      case LogoutEventType.accountLocked:
        message = '계정이 잠겨 로그아웃되었습니다.';
        backgroundColor = Colors.red;
        break;
      case LogoutEventType.serverError:
        message = '서버 오류로 인해 로그아웃되었습니다.';
        backgroundColor = Colors.red;
        break;
      case LogoutEventType.networkError:
        message = '네트워크 오류로 인해 로그아웃되었습니다.';
        backgroundColor = Colors.orange;
        break;
    }

    // 사용자 정의 메시지가 있으면 사용
    if (event.reason != null) {
      message = event.reason!;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _logoutSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// 로그아웃 확인 다이얼로그
class LogoutConfirmationDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const LogoutConfirmationDialog({
    super.key,
    this.title,
    this.message,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? '로그아웃'),
      content: Text(message ?? '정말 로그아웃하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('로그아웃'),
        ),
      ],
    );
  }
}

/// 로그아웃 버튼
class LogoutButton extends ConsumerWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool showConfirmation;
  final String? confirmationTitle;
  final String? confirmationMessage;

  const LogoutButton({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.showConfirmation = true,
    this.confirmationTitle,
    this.confirmationMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoutState = ref.watch(logoutStateProvider);

    return ElevatedButton.icon(
      onPressed: logoutState.isLoggingOut ? null : () => _handleLogout(context, ref),
      icon: logoutState.isLoggingOut
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon ?? Icons.logout),
      label: Text(text ?? '로그아웃'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.red,
        backgroundColor: Colors.red.shade50,
        side: BorderSide(color: Colors.red.shade200),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    if (onPressed != null) {
      onPressed!();
      return;
    }

    if (showConfirmation) {
      showDialog<bool>(
        context: context,
        builder: (context) => LogoutConfirmationDialog(
          title: confirmationTitle,
          message: confirmationMessage,
          onConfirm: () => _performLogout(ref),
        ),
      );
    } else {
      _performLogout(ref);
    }
  }

  void _performLogout(WidgetRef ref) {
    final logoutNotifier = ref.read(logoutStateProvider.notifier);
    logoutNotifier.logoutUser();
  }
}

/// 강제 로그아웃 버튼
class ForceLogoutButton extends ConsumerWidget {
  final String? text;
  final IconData? icon;
  final String? reason;

  const ForceLogoutButton({
    super.key,
    this.text,
    this.icon,
    this.reason,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoutState = ref.watch(logoutStateProvider);

    return ElevatedButton.icon(
      onPressed: logoutState.isLoggingOut ? null : () => _handleForceLogout(context, ref),
      icon: logoutState.isLoggingOut
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon ?? Icons.logout),
      label: Text(text ?? '모든 디바이스에서 로그아웃'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.red,
        backgroundColor: Colors.red.shade50,
        side: BorderSide(color: Colors.red.shade200),
      ),
    );
  }

  void _handleForceLogout(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('강제 로그아웃'),
        content: const Text('모든 디바이스에서 로그아웃됩니다. 정말 진행하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performForceLogout(ref);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _performForceLogout(WidgetRef ref) {
    final logoutNotifier = ref.read(logoutStateProvider.notifier);
    logoutNotifier.forceLogout(reason: reason);
  }
}

/// 로그아웃 상태 표시 위젯
class LogoutStatusWidget extends ConsumerWidget {
  const LogoutStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoutState = ref.watch(logoutStateProvider);

    if (logoutState.isLoggingOut) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('로그아웃 중...'),
            ],
          ),
        ),
      );
    }

    if (logoutState.error != null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  logoutState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              IconButton(
                onPressed: () {
                  ref.read(logoutStateProvider.notifier).clearError();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      );
    }

    if (logoutState.lastEvent != null) {
      return Card(
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.info, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '마지막 로그아웃: ${_formatLogoutEvent(logoutState.lastEvent!)}',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _formatLogoutEvent(LogoutEvent event) {
    final time = event.timestamp.toString().substring(0, 19);
    return '$time (${_getEventTypeText(event.type)})';
  }

  String _getEventTypeText(LogoutEventType type) {
    switch (type) {
      case LogoutEventType.userInitiated:
        return '사용자 요청';
      case LogoutEventType.tokenExpired:
        return '토큰 만료';
      case LogoutEventType.securityBreach:
        return '보안 위반';
      case LogoutEventType.accountLocked:
        return '계정 잠금';
      case LogoutEventType.serverError:
        return '서버 오류';
      case LogoutEventType.networkError:
        return '네트워크 오류';
    }
  }
}
