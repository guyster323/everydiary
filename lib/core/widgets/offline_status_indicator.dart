import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/offline_cache_provider.dart';

/// 오프라인 상태 표시 위젯
class OfflineStatusIndicator extends ConsumerWidget {
  const OfflineStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineStatus = ref.watch(onlineStatusProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final queueStatus = ref.watch(offlineQueueStatusProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(onlineStatus, syncStatus, queueStatus),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(onlineStatus, syncStatus),
          const SizedBox(width: 8),
          _buildStatusText(onlineStatus, syncStatus, queueStatus),
          if (syncStatus == SyncStatus.syncing) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 상태에 따른 색상 반환
  Color _getStatusColor(
    bool isOnline,
    SyncStatus syncStatus,
    Map<String, int> queueStatus,
  ) {
    if (!isOnline) {
      return Colors.red;
    } else if (syncStatus == SyncStatus.syncing) {
      return Colors.blue;
    } else if (queueStatus['pending']! > 0 || queueStatus['failed']! > 0) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  /// 상태 아이콘 빌드
  Widget _buildStatusIcon(bool isOnline, SyncStatus syncStatus) {
    if (!isOnline) {
      return const Icon(Icons.wifi_off, color: Colors.white, size: 16);
    } else if (syncStatus == SyncStatus.syncing) {
      return const Icon(Icons.sync, color: Colors.white, size: 16);
    } else {
      return const Icon(Icons.wifi, color: Colors.white, size: 16);
    }
  }

  /// 상태 텍스트 빌드
  Widget _buildStatusText(
    bool isOnline,
    SyncStatus syncStatus,
    Map<String, int> queueStatus,
  ) {
    String text;

    if (!isOnline) {
      text = '오프라인';
    } else if (syncStatus == SyncStatus.syncing) {
      text = '동기화 중...';
    } else if (queueStatus['pending']! > 0) {
      text = '${queueStatus['pending']}개 대기 중';
    } else if (queueStatus['failed']! > 0) {
      text = '${queueStatus['failed']}개 실패';
    } else {
      text = '온라인';
    }

    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// 오프라인 상태 상세 정보 다이얼로그
class OfflineStatusDialog extends ConsumerWidget {
  const OfflineStatusDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cache = ref.watch(offlineCacheProvider);
    final notifier = ref.read(offlineCacheNotifierProvider.notifier);

    return AlertDialog(
      title: const Text('오프라인 상태'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusRow('연결 상태', cache.isOnline ? '온라인' : '오프라인'),
            _buildStatusRow('동기화 상태', cache.isSyncing ? '동기화 중' : '대기 중'),
            if (cache.lastSyncTime != null)
              _buildStatusRow('마지막 동기화', _formatDateTime(cache.lastSyncTime!)),
            _buildStatusRow('대기 중인 작업', '${cache.pendingCount}개'),
            _buildStatusRow('실패한 작업', '${cache.failedCount}개'),
            const SizedBox(height: 16),
            const Text('캐시 통계', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._buildCacheStats(cache.cacheStats),
            const SizedBox(height: 16),
            const Text('동기화 통계', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._buildSyncStats(cache.syncStats),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
        if (cache.failedCount > 0)
          TextButton(
            onPressed: () {
              notifier.retryFailedSync();
              Navigator.of(context).pop();
            },
            child: const Text('재시도'),
          ),
        TextButton(
          onPressed: () {
            notifier.syncNow();
            Navigator.of(context).pop();
          },
          child: const Text('동기화'),
        ),
      ],
    );
  }

  /// 상태 행 빌드
  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  /// 캐시 통계 빌드
  List<Widget> _buildCacheStats(Map<String, dynamic> stats) {
    if (stats.isEmpty) {
      return [const Text('통계 정보 없음')];
    }

    return stats.entries.map((entry) {
      final cacheName = entry.key;
      final data = entry.value as Map<String, dynamic>;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(cacheName),
            Text('${data['count']}개 (${data['sizeMB']}MB)'),
          ],
        ),
      );
    }).toList();
  }

  /// 동기화 통계 빌드
  List<Widget> _buildSyncStats(Map<String, dynamic> stats) {
    if (stats.isEmpty) {
      return [const Text('통계 정보 없음')];
    }

    return [
      _buildStatusRow('총 작업', '${stats['totalItems']}개'),
      _buildStatusRow('대기 중', '${stats['pendingItems']}개'),
      _buildStatusRow('실패', '${stats['failedItems']}개'),
    ];
  }

  /// 날짜 시간 포맷팅
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// 오프라인 상태 표시 버튼
class OfflineStatusButton extends ConsumerWidget {
  const OfflineStatusButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cache = ref.watch(offlineCacheProvider);
    final queueStatus = ref.watch(offlineQueueStatusProvider);

    return IconButton(
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (context) => const OfflineStatusDialog(),
        );
      },
      icon: Stack(
        children: [
          Icon(
            cache.isOnline ? Icons.wifi : Icons.wifi_off,
            color: cache.isOnline ? Colors.green : Colors.red,
          ),
          if (queueStatus['pending']! > 0 || queueStatus['failed']! > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '${queueStatus['pending']! + queueStatus['failed']!}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
