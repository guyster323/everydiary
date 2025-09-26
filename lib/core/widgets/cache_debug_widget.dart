import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cache_manager_provider.dart';

/// 캐시 디버그 위젯
class CacheDebugWidget extends ConsumerWidget {
  const CacheDebugWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheStats = ref.watch(cacheStatsProvider);
    final cacheManager = ref.read(cacheManagerNotifierProvider.notifier);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storage, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  '캐시 디버그 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showCacheDetails(context, ref),
                  icon: const Icon(Icons.info_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatsGrid(cacheStats),
            const SizedBox(height: 16),
            _buildActionButtons(context, cacheManager),
          ],
        ),
      ),
    );
  }

  /// 통계 그리드 빌드
  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      children: [
        _buildStatCard('총 항목', '${stats['totalItems'] ?? 0}개', Icons.inventory),
        _buildStatCard('총 크기', _formatBytes((stats['totalSize'] as int?) ?? 0), Icons.storage),
        _buildStatCard('카테고리', '${stats['categories'] ?? 0}개', Icons.category),
        _buildStatCard('마지막 정리', _formatDateTime(stats['lastCleanup']), Icons.cleaning_services),
      ],
    );
  }

  /// 통계 카드 빌드
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue.shade600, size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 액션 버튼들 빌드
  Widget _buildActionButtons(BuildContext context, dynamic cacheManager) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: () => cacheManager.performCleanup(),
          icon: const Icon(Icons.cleaning_services, size: 16),
          label: const Text('정리'),
        ),
        ElevatedButton.icon(
          onPressed: () => _showClearCacheDialog(context, cacheManager),
          icon: const Icon(Icons.delete_forever, size: 16),
          label: const Text('전체 삭제'),
        ),
        ElevatedButton.icon(
          onPressed: () => cacheManager.refreshStats(),
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('새로고침'),
        ),
        ElevatedButton.icon(
          onPressed: () => _showCacheMigration(context, cacheManager),
          icon: const Icon(Icons.upgrade, size: 16),
          label: const Text('마이그레이션'),
        ),
      ],
    );
  }

  /// 캐시 상세 정보 다이얼로그
  void _showCacheDetails(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => const CacheDetailsDialog(),
    );
  }

  /// 캐시 삭제 확인 다이얼로그
  void _showClearCacheDialog(BuildContext context, dynamic cacheManager) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('캐시 삭제'),
        content: const Text('모든 캐시를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              cacheManager.clearAllCache();
              Navigator.of(context).pop();
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  /// 캐시 마이그레이션 다이얼로그
  void _showCacheMigration(BuildContext context, dynamic cacheManager) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('캐시 마이그레이션'),
        content: const Text('캐시를 새 버전으로 마이그레이션하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              cacheManager.migrateCache('1.0.0', '2.0.0');
              Navigator.of(context).pop();
            },
            child: const Text('마이그레이션'),
          ),
        ],
      ),
    );
  }

  /// 바이트 포맷팅
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 날짜 시간 포맷팅
  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return '없음';
    if (dateTime is String) {
      final dt = DateTime.tryParse(dateTime);
      if (dt != null) {
        return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }
    return '알 수 없음';
  }
}

/// 캐시 상세 정보 다이얼로그
class CacheDetailsDialog extends ConsumerWidget {
  const CacheDetailsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheStats = ref.watch(cacheStatsProvider);
    final categoryStats = ref.watch(cacheCategoryStatsProvider);

    return AlertDialog(
      title: const Text('캐시 상세 정보'),
      content: SizedBox(
        width: 400,
        height: 300,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('전체 통계'),
              _buildStatRow('총 항목 수', '${cacheStats['totalItems'] ?? 0}개'),
              _buildStatRow('총 크기', _formatBytes((cacheStats['totalSize'] as int?) ?? 0)),
              _buildStatRow('카테고리 수', '${cacheStats['categories'] ?? 0}개'),
              _buildStatRow('마지막 정리', _formatDateTime(cacheStats['lastCleanup'])),
              const SizedBox(height: 16),
              _buildSectionTitle('카테고리별 통계'),
              ...categoryStats.entries.map((MapEntry<String, dynamic> entry) {
                final category = entry.key;
                final stats = entry.value as Map<String, dynamic>;
                return _buildCategoryCard(category, stats);
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }

  /// 섹션 제목 빌드
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 통계 행 빌드
  Widget _buildStatRow(String label, String value) {
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

  /// 카테고리 카드 빌드
  Widget _buildCategoryCard(String category, Map<String, dynamic> stats) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('항목: ${stats['itemCount'] ?? 0}개'),
                Text('크기: ${_formatBytes((stats['totalSize'] as int?) ?? 0)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 바이트 포맷팅
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 날짜 시간 포맷팅
  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return '없음';
    if (dateTime is String) {
      final dt = DateTime.tryParse(dateTime);
      if (dt != null) {
        return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }
    return '알 수 없음';
  }
}

/// 캐시 모니터링 위젯
class CacheMonitoringWidget extends ConsumerWidget {
  const CacheMonitoringWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheEvents = ref.watch(cacheEventsProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '캐시 이벤트 모니터링',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: cacheEvents.length,
                itemBuilder: (context, index) {
                  final event = cacheEvents[index];
                  return _buildEventItem(event);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 이벤트 아이템 빌드
  Widget _buildEventItem(Map<String, dynamic> event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            _getEventIcon(event['type'] as String),
            size: 16,
            color: _getEventColor(event['type'] as String),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${event['type']}: ${event['key']}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Text(
            _formatTime(event['timestamp']),
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 이벤트 아이콘 가져오기
  IconData _getEventIcon(String type) {
    switch (type) {
      case 'added':
        return Icons.add_circle;
      case 'removed':
        return Icons.remove_circle;
      case 'accessed':
        return Icons.touch_app;
      default:
        return Icons.info;
    }
  }

  /// 이벤트 색상 가져오기
  Color _getEventColor(String type) {
    switch (type) {
      case 'added':
        return Colors.green;
      case 'removed':
        return Colors.red;
      case 'accessed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// 시간 포맷팅
  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    if (timestamp is String) {
      final dt = DateTime.tryParse(timestamp);
      if (dt != null) {
        return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }
    return '';
  }
}
