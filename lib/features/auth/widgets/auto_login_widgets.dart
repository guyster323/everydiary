import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/auto_login_service.dart';

/// 자동 로그인 상태 표시 위젯
class AutoLoginStatusWidget extends ConsumerWidget {
  const AutoLoginStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoLoginState = ref.watch(autoLoginStateProvider);
    final autoLoginStatus = ref.watch(autoLoginStatusProvider);

    return autoLoginStatus.when(
      data: (status) => _buildStatusCard(context, autoLoginState, status),
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    AutoLoginState autoLoginState,
    AutoLoginStatus status,
  ) {
    if (autoLoginState.isAttemptingAutoLogin) {
      return Card(
        color: Colors.blue.shade50,
        child: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '자동 로그인을 시도하고 있습니다...',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!status.isRememberMeEnabled && !status.isAutoLoginEnabled) {
      return const SizedBox.shrink();
    }

    Color cardColor;
    IconData icon;
    String message;

    if (status.canAutoLogin) {
      cardColor = Colors.green.shade50;
      icon = Icons.check_circle;
      message = '자동 로그인이 활성화되어 있습니다';
    } else if (status.isRememberMeEnabled) {
      cardColor = Colors.orange.shade50;
      icon = Icons.warning;
      message = '로그인 상태 유지가 활성화되어 있지만 자동 로그인을 사용할 수 없습니다';
    } else {
      cardColor = Colors.grey.shade50;
      icon = Icons.info;
      message = '로그인 상태 유지가 비활성화되어 있습니다';
    }

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: cardColor == Colors.green.shade50
                  ? Colors.green
                  : cardColor == Colors.orange.shade50
                  ? Colors.orange
                  : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 12,
                  color: cardColor == Colors.green.shade50
                      ? Colors.green
                      : cardColor == Colors.orange.shade50
                      ? Colors.orange
                      : Colors.grey,
                ),
              ),
            ),
            if (status.lastLoginEmail != null)
              Text(
                status.lastLoginEmail!,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

/// 로그인 상태 유지 토글
class RememberMeToggle extends ConsumerWidget {
  const RememberMeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoLoginState = ref.watch(autoLoginStateProvider);

    return SwitchListTile(
      title: const Text('로그인 상태 유지'),
      subtitle: Text(
        autoLoginState.isRememberMeEnabled
            ? '앱을 다시 열 때 자동으로 로그인됩니다'
            : '앱을 다시 열 때 로그인해야 합니다',
      ),
      value: autoLoginState.isRememberMeEnabled,
      onChanged: (value) {
        ref.read(autoLoginStateProvider.notifier).setRememberMe(value);
      },
      secondary: Icon(
        autoLoginState.isRememberMeEnabled
            ? Icons.remember_me
            : Icons.remember_me_outlined,
        color: autoLoginState.isRememberMeEnabled ? Colors.green : Colors.grey,
      ),
    );
  }
}

/// 자동 로그인 토글
class AutoLoginToggle extends ConsumerWidget {
  const AutoLoginToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoLoginState = ref.watch(autoLoginStateProvider);

    return SwitchListTile(
      title: const Text('자동 로그인'),
      subtitle: Text(
        autoLoginState.isAutoLoginEnabled
            ? '앱 시작 시 자동으로 로그인을 시도합니다'
            : '앱 시작 시 자동 로그인을 시도하지 않습니다',
      ),
      value: autoLoginState.isAutoLoginEnabled,
      onChanged: autoLoginState.isRememberMeEnabled
          ? (value) {
              ref
                  .read(autoLoginStateProvider.notifier)
                  .setAutoLoginEnabled(value);
            }
          : null,
      secondary: Icon(
        autoLoginState.isAutoLoginEnabled ? Icons.login : Icons.login_outlined,
        color: autoLoginState.isAutoLoginEnabled ? Colors.green : Colors.grey,
      ),
    );
  }
}

/// 자동 로그인 시도 버튼
class AutoLoginButton extends ConsumerWidget {
  final bool showText;
  final VoidCallback? onPressed;

  const AutoLoginButton({super.key, this.showText = true, this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoLoginState = ref.watch(autoLoginStateProvider);

    return ElevatedButton.icon(
      onPressed: autoLoginState.isAttemptingAutoLogin
          ? null
          : () {
              if (onPressed != null) {
                onPressed!();
              } else {
                _showAutoLoginDialog(context, ref);
              }
            },
      icon: autoLoginState.isAttemptingAutoLogin
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.login),
      label: showText ? const Text('자동 로그인') : const SizedBox.shrink(),
    );
  }

  void _showAutoLoginDialog(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('자동 로그인'),
        content: const Text('저장된 로그인 정보로 자동 로그인을 시도하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              ref.read(autoLoginStateProvider.notifier).attemptAutoLogin();
            },
            child: const Text('로그인'),
          ),
        ],
      ),
    );
  }
}

/// 자동 로그인 설정 초기화 버튼
class ClearAutoLoginSettingsButton extends ConsumerWidget {
  final bool showText;

  const ClearAutoLoginSettingsButton({super.key, this.showText = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () => _showClearSettingsDialog(context, ref),
      icon: const Icon(Icons.clear_all),
      label: showText ? const Text('설정 초기화') : const SizedBox.shrink(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red.shade700,
        side: BorderSide(color: Colors.red.shade200),
      ),
    );
  }

  void _showClearSettingsDialog(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('자동 로그인 설정 초기화'),
        content: const Text(
          '모든 자동 로그인 설정을 초기화하시겠습니까?\n\n'
          '이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              _clearSettings(ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  void _clearSettings(WidgetRef ref) {
    // 자동 로그인 서비스에서 설정 초기화
    // 이 기능은 AutoLoginService에 추가해야 함
    ref.read(autoLoginStateProvider.notifier).setRememberMe(false);
    ref.read(autoLoginStateProvider.notifier).setAutoLoginEnabled(false);
  }
}

/// 자동 로그인 이벤트 로그 위젯
class AutoLoginEventLog extends ConsumerWidget {
  const AutoLoginEventLog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoLoginEvents = ref.watch(autoLoginEventStreamProvider);

    return autoLoginEvents.when(
      data: (event) => _buildEventCard(event),
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildEventCard(AutoLoginEvent event) {
    Color cardColor;
    IconData icon;

    switch (event.type) {
      case AutoLoginEventType.autoLoginStarted:
        cardColor = Colors.blue.shade50;
        icon = Icons.login;
        break;
      case AutoLoginEventType.autoLoginSuccess:
        cardColor = Colors.green.shade50;
        icon = Icons.check_circle;
        break;
      case AutoLoginEventType.autoLoginFailed:
        cardColor = Colors.red.shade50;
        icon = Icons.error;
        break;
      case AutoLoginEventType.autoLoginSkipped:
        cardColor = Colors.grey.shade50;
        icon = Icons.skip_next;
        break;
      case AutoLoginEventType.rememberMeEnabled:
        cardColor = Colors.green.shade50;
        icon = Icons.remember_me;
        break;
      case AutoLoginEventType.rememberMeDisabled:
        cardColor = Colors.orange.shade50;
        icon = Icons.remember_me_outlined;
        break;
    }

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: cardColor == Colors.blue.shade50
                  ? Colors.blue
                  : cardColor == Colors.green.shade50
                  ? Colors.green
                  : cardColor == Colors.red.shade50
                  ? Colors.red
                  : cardColor == Colors.orange.shade50
                  ? Colors.orange
                  : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.message ?? _getEventTypeText(event.type),
                    style: TextStyle(
                      fontSize: 12,
                      color: cardColor == Colors.blue.shade50
                          ? Colors.blue
                          : cardColor == Colors.green.shade50
                          ? Colors.green
                          : cardColor == Colors.red.shade50
                          ? Colors.red
                          : cardColor == Colors.orange.shade50
                          ? Colors.orange
                          : Colors.grey,
                    ),
                  ),
                  Text(
                    _formatTimestamp(event.timestamp),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEventTypeText(AutoLoginEventType type) {
    switch (type) {
      case AutoLoginEventType.autoLoginStarted:
        return '자동 로그인 시작';
      case AutoLoginEventType.autoLoginSuccess:
        return '자동 로그인 성공';
      case AutoLoginEventType.autoLoginFailed:
        return '자동 로그인 실패';
      case AutoLoginEventType.autoLoginSkipped:
        return '자동 로그인 건너뜀';
      case AutoLoginEventType.rememberMeEnabled:
        return '로그인 상태 유지 활성화';
      case AutoLoginEventType.rememberMeDisabled:
        return '로그인 상태 유지 비활성화';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }
}
