import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/offline_cache_provider.dart';

/// 백그라운드 동기화 상태를 표시하는 위젯
class BackgroundSyncIndicator extends ConsumerWidget {
  const BackgroundSyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineCache = ref.watch(offlineCacheProvider);
    final syncStatus = offlineCache.syncStatus;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(syncStatus),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getBorderColor(syncStatus), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSyncIcon(syncStatus),
          const SizedBox(width: 8),
          _buildSyncText(syncStatus, offlineCache),
          if (syncStatus == SyncStatus.syncing) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 16,
              height: 16,
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

  Widget _buildSyncIcon(SyncStatus status) {
    IconData iconData;
    Color iconColor;

    switch (status) {
      case SyncStatus.syncing:
        iconData = Icons.sync;
        iconColor = Colors.white;
        break;
      case SyncStatus.pending:
        iconData = Icons.sync_problem;
        iconColor = Colors.orange;
        break;
      case SyncStatus.failed:
        iconData = Icons.sync_disabled;
        iconColor = Colors.red;
        break;
      case SyncStatus.completed:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case SyncStatus.idle:
        iconData = Icons.cloud_done;
        iconColor = Colors.blue;
        break;
    }

    return Icon(iconData, size: 16, color: iconColor);
  }

  Widget _buildSyncText(SyncStatus status, OfflineCacheState cache) {
    String text;
    Color textColor;

    switch (status) {
      case SyncStatus.syncing:
        text = '동기화 중...';
        textColor = Colors.white;
        break;
      case SyncStatus.pending:
        text = '${cache.pendingCount}개 대기 중';
        textColor = Colors.orange;
        break;
      case SyncStatus.failed:
        text = '${cache.failedCount}개 실패';
        textColor = Colors.red;
        break;
      case SyncStatus.completed:
        text = '동기화 완료';
        textColor = Colors.green;
        break;
      case SyncStatus.idle:
        text = '온라인';
        textColor = Colors.blue;
        break;
    }

    return Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Color _getBackgroundColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.pending:
        return Colors.orange.withOpacity(0.1);
      case SyncStatus.failed:
        return Colors.red.withOpacity(0.1);
      case SyncStatus.completed:
        return Colors.green.withOpacity(0.1);
      case SyncStatus.idle:
        return Colors.blue.withOpacity(0.1);
    }
  }

  Color _getBorderColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.pending:
        return Colors.orange;
      case SyncStatus.failed:
        return Colors.red;
      case SyncStatus.completed:
        return Colors.green;
      case SyncStatus.idle:
        return Colors.blue;
    }
  }
}

/// 백그라운드 동기화 상세 정보 다이얼로그
class BackgroundSyncDialog extends ConsumerWidget {
  const BackgroundSyncDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineCache = ref.watch(offlineCacheProvider);
    final syncStatus = offlineCache.syncStatus;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.sync, color: Colors.blue),
          SizedBox(width: 8),
          Text('백그라운드 동기화'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusRow('동기화 상태', _getStatusText(syncStatus)),
            _buildStatusRow('대기 중인 작업', '${offlineCache.pendingCount}개'),
            _buildStatusRow('실패한 작업', '${offlineCache.failedCount}개'),
            if (offlineCache.lastSyncTime != null)
              _buildStatusRow(
                '마지막 동기화',
                _formatDateTime(offlineCache.lastSyncTime!),
              ),
            const SizedBox(height: 16),
            _buildSyncStats(offlineCache),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
        if (offlineCache.failedCount > 0)
          ElevatedButton(
            onPressed: () {
              ref.read(offlineCacheNotifierProvider.notifier).retryFailedSync();
              Navigator.of(context).pop();
            },
            child: const Text('재시도'),
          ),
        ElevatedButton(
          onPressed: () {
            ref.read(offlineCacheNotifierProvider.notifier).syncNow();
            Navigator.of(context).pop();
          },
          child: const Text('동기화'),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value) {
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

  Widget _buildSyncStats(OfflineCacheState cache) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '동기화 통계',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        _buildStatItem('총 작업', '${cache.totalCount}개'),
        _buildStatItem('성공', '${cache.successCount}개'),
        _buildStatItem('실패', '${cache.failedCount}개'),
        _buildStatItem('대기 중', '${cache.pendingCount}개'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return '동기화 중';
      case SyncStatus.pending:
        return '대기 중';
      case SyncStatus.failed:
        return '실패';
      case SyncStatus.completed:
        return '완료';
      case SyncStatus.idle:
        return '유휴';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// 백그라운드 동기화 버튼
class BackgroundSyncButton extends ConsumerWidget {
  const BackgroundSyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineCache = ref.watch(offlineCacheProvider);

    return Stack(
      children: [
        IconButton(
          onPressed: () => _showSyncDialog(context, ref),
          icon: const Icon(Icons.sync),
          tooltip: '백그라운드 동기화',
        ),
        if (offlineCache.pendingCount > 0 || offlineCache.failedCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '${offlineCache.pendingCount + offlineCache.failedCount}',
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
    );
  }

  void _showSyncDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => const BackgroundSyncDialog(),
    );
  }
}
