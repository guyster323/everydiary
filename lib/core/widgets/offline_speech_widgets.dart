import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/network_monitor_service.dart';
import '../services/offline_speech_service.dart';

/// 오프라인 음성 인식 상태 위젯
class OfflineSpeechStatusWidget extends ConsumerWidget {
  const OfflineSpeechStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineService = OfflineSpeechService();
    final networkMonitor = NetworkMonitorService();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(offlineService.mode, networkMonitor.isOnline),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(
            offlineService.mode,
            networkMonitor.isOnline,
          ).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(offlineService.mode, networkMonitor.isOnline),
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            offlineService.getStatusMessage(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OfflineSpeechMode mode, bool isOnline) {
    switch (mode) {
      case OfflineSpeechMode.online:
        return isOnline ? Colors.green : Colors.red;
      case OfflineSpeechMode.offline:
        return Colors.orange;
      case OfflineSpeechMode.hybrid:
        return isOnline ? Colors.blue : Colors.orange;
    }
  }

  IconData _getStatusIcon(OfflineSpeechMode mode, bool isOnline) {
    switch (mode) {
      case OfflineSpeechMode.online:
        return isOnline ? Icons.wifi : Icons.wifi_off;
      case OfflineSpeechMode.offline:
        return Icons.offline_bolt;
      case OfflineSpeechMode.hybrid:
        return isOnline ? Icons.wifi : Icons.offline_bolt;
    }
  }
}

/// 오프라인 음성 인식 모드 선택 위젯
class OfflineSpeechModeSelector extends ConsumerStatefulWidget {
  const OfflineSpeechModeSelector({super.key});

  @override
  ConsumerState<OfflineSpeechModeSelector> createState() =>
      _OfflineSpeechModeSelectorState();
}

class _OfflineSpeechModeSelectorState
    extends ConsumerState<OfflineSpeechModeSelector> {
  final OfflineSpeechService _offlineService = OfflineSpeechService();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '음성 인식 모드',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...OfflineSpeechMode.values.map((mode) => _buildModeOption(mode)),
            const SizedBox(height: 12),
            _buildLimitationInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption(OfflineSpeechMode mode) {
    final networkMonitor = NetworkMonitorService();

    return RadioListTile<OfflineSpeechMode>(
      title: Text(_getModeTitle(mode)),
      subtitle: Text(_getModeDescription(mode, networkMonitor.isOnline)),
      value: mode,
      // ignore: deprecated_member_use
      groupValue: _offlineService.mode,
      // ignore: deprecated_member_use
      onChanged: (OfflineSpeechMode? value) async {
        if (value != null) {
          await _offlineService.setMode(value);
          setState(() {});
        }
      },
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }

  String _getModeTitle(OfflineSpeechMode mode) {
    switch (mode) {
      case OfflineSpeechMode.online:
        return '온라인 모드';
      case OfflineSpeechMode.offline:
        return '오프라인 모드';
      case OfflineSpeechMode.hybrid:
        return '하이브리드 모드';
    }
  }

  String _getModeDescription(OfflineSpeechMode mode, bool isOnline) {
    switch (mode) {
      case OfflineSpeechMode.online:
        return isOnline ? '인터넷 연결을 통한 고품질 음성 인식' : '인터넷 연결이 필요합니다';
      case OfflineSpeechMode.offline:
        return '인터넷 없이 제한적인 음성 인식';
      case OfflineSpeechMode.hybrid:
        return '온라인 우선, 오프라인 대체 모드';
    }
  }

  Widget _buildLimitationInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                '현재 모드 제한사항',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _offlineService.getLimitationMessage(),
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// 오프라인 음성 인식 결과 위젯
class OfflineSpeechResultWidget extends ConsumerWidget {
  const OfflineSpeechResultWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineService = OfflineSpeechService();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 인식 결과',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await offlineService.clearCache();
                  },
                  child: const Text('캐시 삭제'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (offlineService.resultCache.isEmpty)
              const Center(
                child: Text(
                  '인식 결과가 없습니다',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...offlineService.resultCache
                  .take(5)
                  .map((result) => _buildResultItem(result)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(OfflineSpeechResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: result.isOffline
            ? Colors.orange.withValues(alpha: 0.1)
            : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: result.isOffline
              ? Colors.orange.withValues(alpha: 0.3)
              : Colors.green.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.isOffline ? Icons.offline_bolt : Icons.wifi,
                size: 14,
                color: result.isOffline ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 6),
              Text(
                result.isOffline ? '오프라인' : '온라인',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: result.isOffline ? Colors.orange : Colors.green,
                ),
              ),
              const Spacer(),
              Text(
                '${(result.confidence * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 11,
                  color: result.confidence > 0.7 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            result.text,
            style: const TextStyle(fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(result.timestamp),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }
}

/// 네트워크 상태 표시 위젯
class NetworkStatusWidget extends ConsumerWidget {
  const NetworkStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkMonitor = NetworkMonitorService();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: networkMonitor.isOnline ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            networkMonitor.isOnline ? Icons.wifi : Icons.wifi_off,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            networkMonitor.isOnline ? '온라인' : '오프라인',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
