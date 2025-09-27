import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cache_manager_provider.dart';
import '../services/android_cache_service.dart';

/// 캐시 정보 표시 위젯
class CacheInfoWidget extends ConsumerWidget {
  const CacheInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheStats = ref.watch(cacheManagerNotifierProvider);

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
                  '캐시 정보',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _clearCache(context, ref),
                  icon: const Icon(Icons.clear_all, color: Colors.red),
                  tooltip: '캐시 정리',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCacheStats(context, cacheStats),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheStats(BuildContext context, Map<String, dynamic> stats) {
    final totalSize = stats['totalSize'] as int? ?? 0;
    final itemCount = stats['itemCount'] as int? ?? 0;
    final hitRate = stats['hitRate'] as double? ?? 0.0;
    final lastCleanup = stats['lastCleanup'] as String? ?? '없음';

    return Column(
      children: [
        _buildInfoRow('총 크기', _formatBytes(totalSize)),
        _buildInfoRow('항목 수', '$itemCount개'),
        _buildInfoRow('히트율', '${(hitRate * 100).toStringAsFixed(1)}%'),
        _buildInfoRow('마지막 정리', _formatDate(lastCleanup)),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: totalSize / (100 * 1024 * 1024), // 100MB 기준
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            totalSize > 50 * 1024 * 1024 ? Colors.red : Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '사용량: ${_formatBytes(totalSize)} / 100MB',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

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

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _clearCache(BuildContext context, WidgetRef ref) async {
    try {
      final cacheService = AndroidCacheService();
      await cacheService.clearAllCache();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('캐시가 정리되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('캐시 정리 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
