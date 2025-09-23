import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/token_refresh_service.dart';

/// 토큰 갱신 상태 표시 위젯
class TokenRefreshStatusWidget extends ConsumerWidget {
  const TokenRefreshStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshState = ref.watch(tokenRefreshStateProvider);
    final tokenStatus = ref.watch(tokenStatusProvider);

    return tokenStatus.when(
      data: (status) => _buildStatusCard(context, refreshState, status),
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    TokenRefreshState refreshState,
    TokenStatus status,
  ) {
    if (!status.hasAccessToken) {
      return const SizedBox.shrink();
    }

    Color cardColor;
    IconData icon;
    String message;

    if (refreshState.isRefreshing) {
      cardColor = Colors.blue.shade50;
      icon = Icons.refresh;
      message = '토큰을 갱신하고 있습니다...';
    } else if (status.needsRefresh) {
      cardColor = Colors.orange.shade50;
      icon = Icons.warning;
      message = '토큰 갱신이 필요합니다';
    } else if (status.isValid) {
      cardColor = Colors.green.shade50;
      icon = Icons.check_circle;
      message = '토큰이 유효합니다';
    } else {
      cardColor = Colors.red.shade50;
      icon = Icons.error;
      message = '토큰이 유효하지 않습니다';
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
                  : cardColor == Colors.orange.shade50
                  ? Colors.orange
                  : cardColor == Colors.green.shade50
                  ? Colors.green
                  : Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 12,
                  color: cardColor == Colors.blue.shade50
                      ? Colors.blue
                      : cardColor == Colors.orange.shade50
                      ? Colors.orange
                      : cardColor == Colors.green.shade50
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
            if (status.timeUntilExpiry != null)
              Text(
                _formatTimeUntilExpiry(status.timeUntilExpiry!),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimeUntilExpiry(Duration timeUntilExpiry) {
    if (timeUntilExpiry.isNegative) {
      return '만료됨';
    }

    final hours = timeUntilExpiry.inHours;
    final minutes = timeUntilExpiry.inMinutes % 60;

    if (hours > 0) {
      return '$hours시간 $minutes분 남음';
    } else {
      return '$minutes분 남음';
    }
  }
}

/// 토큰 갱신 버튼
class TokenRefreshButton extends ConsumerWidget {
  final bool showText;
  final VoidCallback? onPressed;

  const TokenRefreshButton({super.key, this.showText = true, this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshState = ref.watch(tokenRefreshStateProvider);

    return ElevatedButton.icon(
      onPressed: refreshState.isRefreshing
          ? null
          : () {
              if (onPressed != null) {
                onPressed!();
              } else {
                ref.read(tokenRefreshStateProvider.notifier).refreshToken();
              }
            },
      icon: refreshState.isRefreshing
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh),
      label: showText ? const Text('토큰 갱신') : const SizedBox.shrink(),
    );
  }
}

/// 강제 토큰 갱신 버튼
class ForceTokenRefreshButton extends ConsumerWidget {
  final bool showText;
  final VoidCallback? onPressed;

  const ForceTokenRefreshButton({
    super.key,
    this.showText = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshState = ref.watch(tokenRefreshStateProvider);

    return ElevatedButton.icon(
      onPressed: refreshState.isRefreshing
          ? null
          : () {
              if (onPressed != null) {
                onPressed!();
              } else {
                _showForceRefreshDialog(context, ref);
              }
            },
      icon: refreshState.isRefreshing
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh),
      label: showText ? const Text('강제 갱신') : const SizedBox.shrink(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade50,
        foregroundColor: Colors.orange.shade700,
        side: BorderSide(color: Colors.orange.shade200),
      ),
    );
  }

  void _showForceRefreshDialog(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('강제 토큰 갱신'),
        content: const Text(
          '토큰을 강제로 갱신하시겠습니까?\n\n'
          '이 작업은 현재 토큰이 유효하지 않을 때 사용됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              ref.read(tokenRefreshStateProvider.notifier).forceRefreshToken();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade50,
              foregroundColor: Colors.orange.shade700,
            ),
            child: const Text('갱신'),
          ),
        ],
      ),
    );
  }
}

/// 자동 토큰 갱신 토글 버튼
class AutoTokenRefreshToggle extends ConsumerWidget {
  const AutoTokenRefreshToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshState = ref.watch(tokenRefreshStateProvider);

    return SwitchListTile(
      title: const Text('자동 토큰 갱신'),
      subtitle: Text(
        refreshState.isAutoRefreshEnabled
            ? '토큰이 자동으로 갱신됩니다'
            : '토큰 갱신을 수동으로 해야 합니다',
      ),
      value: refreshState.isAutoRefreshEnabled,
      onChanged: (value) {
        ref.read(tokenRefreshStateProvider.notifier).toggleAutoRefresh();
      },
      secondary: Icon(
        refreshState.isAutoRefreshEnabled
            ? Icons.autorenew
            : Icons.autorenew_outlined,
        color: refreshState.isAutoRefreshEnabled ? Colors.green : Colors.grey,
      ),
    );
  }
}

/// 토큰 갱신 이벤트 로그 위젯
class TokenRefreshEventLog extends ConsumerWidget {
  const TokenRefreshEventLog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshEvents = ref.watch(tokenRefreshEventStreamProvider);

    return refreshEvents.when(
      data: (event) => _buildEventCard(event),
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildEventCard(TokenRefreshEvent event) {
    Color cardColor;
    IconData icon;

    switch (event.type) {
      case TokenRefreshEventType.refreshStarted:
        cardColor = Colors.blue.shade50;
        icon = Icons.refresh;
        break;
      case TokenRefreshEventType.refreshSuccess:
        cardColor = Colors.green.shade50;
        icon = Icons.check_circle;
        break;
      case TokenRefreshEventType.refreshFailed:
        cardColor = Colors.red.shade50;
        icon = Icons.error;
        break;
      case TokenRefreshEventType.refreshSkipped:
        cardColor = Colors.grey.shade50;
        icon = Icons.skip_next;
        break;
      case TokenRefreshEventType.autoRefreshEnabled:
        cardColor = Colors.green.shade50;
        icon = Icons.autorenew;
        break;
      case TokenRefreshEventType.autoRefreshDisabled:
        cardColor = Colors.orange.shade50;
        icon = Icons.autorenew_outlined;
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

  String _getEventTypeText(TokenRefreshEventType type) {
    switch (type) {
      case TokenRefreshEventType.refreshStarted:
        return '토큰 갱신 시작';
      case TokenRefreshEventType.refreshSuccess:
        return '토큰 갱신 성공';
      case TokenRefreshEventType.refreshFailed:
        return '토큰 갱신 실패';
      case TokenRefreshEventType.refreshSkipped:
        return '토큰 갱신 건너뜀';
      case TokenRefreshEventType.autoRefreshEnabled:
        return '자동 갱신 활성화';
      case TokenRefreshEventType.autoRefreshDisabled:
        return '자동 갱신 비활성화';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }
}
