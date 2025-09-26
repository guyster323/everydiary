import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/offline_state_provider.dart';

/// 오프라인 모드 표시기
class OfflineModeIndicator extends ConsumerWidget {
  const OfflineModeIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(offlineStateProvider);

    if (offlineState.isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '오프라인 모드',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (offlineState.offlineDuration != null)
                  Text(
                    '오프라인 지속 시간: ${_formatDuration(offlineState.offlineDuration!)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
          if (offlineState.isOfflineModeForced)
            const Icon(Icons.settings, color: Colors.white70, size: 16),
        ],
      ),
    );
  }

  /// 지속 시간 포맷팅
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}일 ${duration.inHours % 24}시간';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}시간 ${duration.inMinutes % 60}분';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}분';
    } else {
      return '${duration.inSeconds}초';
    }
  }
}

/// 오프라인 모드 배너
class OfflineModeBanner extends ConsumerWidget {
  const OfflineModeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(offlineStateProvider);

    if (offlineState.isOnline) {
      return const SizedBox.shrink();
    }

    return MaterialBanner(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '오프라인 모드',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            '인터넷 연결이 없습니다. 일부 기능이 제한될 수 있습니다.',
            style: TextStyle(fontSize: 14),
          ),
          if (offlineState.offlineDuration != null) ...[
            const SizedBox(height: 4),
            Text(
              '오프라인 지속 시간: ${_formatDuration(offlineState.offlineDuration!)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          },
          child: const Text('확인'),
        ),
        if (offlineState.isOfflineModeForced)
          TextButton(
            onPressed: () {
              // 오프라인 모드 강제 해제
              ref
                  .read(offlineStateNotifierProvider.notifier)
                  .setOfflineModeForced(false);
            },
            child: const Text('오프라인 모드 해제'),
          ),
      ],
      backgroundColor: Colors.red.shade50,
      leading: Icon(Icons.wifi_off, color: Colors.red.shade600),
    );
  }

  /// 지속 시간 포맷팅
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}일 ${duration.inHours % 24}시간';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}시간 ${duration.inMinutes % 60}분';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}분';
    } else {
      return '${duration.inSeconds}초';
    }
  }
}

/// 오프라인 모드 다이얼로그
class OfflineModeDialog extends ConsumerWidget {
  const OfflineModeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(offlineStateProvider);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.red.shade600),
          const SizedBox(width: 8),
          const Text('오프라인 모드'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '인터넷 연결이 없습니다. 일부 기능이 제한될 수 있습니다.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('연결 상태', offlineState.isOnline ? '온라인' : '오프라인'),
            _buildInfoRow('연결 타입', offlineState.connectionType),
            if (offlineState.lastOnlineTime != null)
              _buildInfoRow(
                '마지막 온라인',
                _formatDateTime(offlineState.lastOnlineTime!),
              ),
            if (offlineState.lastOfflineTime != null)
              _buildInfoRow(
                '오프라인 시작',
                _formatDateTime(offlineState.lastOfflineTime!),
              ),
            if (offlineState.offlineDuration != null)
              _buildInfoRow(
                '오프라인 지속 시간',
                _formatDuration(offlineState.offlineDuration!),
              ),
            if (offlineState.isOfflineModeForced) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: Colors.orange.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '오프라인 모드가 강제로 설정되어 있습니다.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
        if (offlineState.isOfflineModeForced)
          TextButton(
            onPressed: () {
              ref
                  .read(offlineStateNotifierProvider.notifier)
                  .setOfflineModeForced(false);
              Navigator.of(context).pop();
            },
            child: const Text('오프라인 모드 해제'),
          ),
        TextButton(
          onPressed: () {
            ref
                .read(offlineStateNotifierProvider.notifier)
                .checkNetworkStatus();
            Navigator.of(context).pop();
          },
          child: const Text('연결 확인'),
        ),
      ],
    );
  }

  /// 정보 행 빌드
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// 날짜 시간 포맷팅
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 지속 시간 포맷팅
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}일 ${duration.inHours % 24}시간';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}시간 ${duration.inMinutes % 60}분';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}분';
    } else {
      return '${duration.inSeconds}초';
    }
  }
}

/// 오프라인 모드 버튼
class OfflineModeButton extends ConsumerWidget {
  const OfflineModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(offlineStateProvider);

    return IconButton(
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (context) => const OfflineModeDialog(),
        );
      },
      icon: Stack(
        children: [
          Icon(
            offlineState.isOnline ? Icons.wifi : Icons.wifi_off,
            color: offlineState.isOnline ? Colors.green : Colors.red,
          ),
          if (offlineState.isOfflineModeForced)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                child: const Icon(Icons.settings, color: Colors.white, size: 8),
              ),
            ),
        ],
      ),
    );
  }
}
