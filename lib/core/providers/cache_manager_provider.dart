import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/cache_manager_service.dart';

final cacheManagerServiceProvider = AutoDisposeProvider<CacheManagerService>((
  ref,
) {
  final service = CacheManagerService();
  ref.onDispose(service.dispose);
  return service;
});

class CacheManagerNotifier extends AutoDisposeNotifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() {
    _initialize();
    return {
      'totalItems': 0,
      'totalSize': 0,
      'categories': 0,
      'lastCleanup': null,
    };
  }

  Future<void> _initialize() async {
    try {
      debugPrint('🔄 캐시 관리자 초기화 시작');

      final service = ref.read(cacheManagerServiceProvider);
      await service.initialize();

      service.eventStream.listen(
        (CacheEvent event) {
          _handleCacheEvent(event);
        },
        onError: (Object error) {
          debugPrint('❌ 캐시 이벤트 스트림 오류: $error');
        },
      );

      await _loadStats();

      debugPrint('✅ 캐시 관리자 초기화 완료');
    } catch (e) {
      debugPrint('❌ 캐시 관리자 초기화 실패: $e');
    }
  }

  void _handleCacheEvent(CacheEvent event) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final service = ref.read(cacheManagerServiceProvider);
      final stats = service.getCacheStats();

      int totalItems = 0;
      int totalSize = 0;
      final int categories = stats.length;
      DateTime? lastCleanup;

      for (final stat in stats.values) {
        totalItems += stat.itemCount;
        totalSize += stat.totalSize;
        if (lastCleanup == null || stat.lastUpdated.isAfter(lastCleanup)) {
          lastCleanup = stat.lastUpdated;
        }
      }

      state = {
        'totalItems': totalItems,
        'totalSize': totalSize,
        'categories': categories,
        'lastCleanup': lastCleanup?.toIso8601String(),
      };
    } catch (e) {
      debugPrint('❌ 통계 로드 실패: $e');
    }
  }

  Future<void> addCacheItem(
    String key,
    dynamic data, {
    Duration? expiry,
    CachePriority priority = CachePriority.normal,
    String? category,
  }) async {
    try {
      final service = ref.read(cacheManagerServiceProvider);
      await service.addCacheItem(
        key,
        data,
        expiry: expiry,
        priority: priority,
        category: category,
      );
      await _loadStats();
    } catch (e) {
      debugPrint('❌ 캐시 항목 추가 실패: $e');
    }
  }

  Future<dynamic> getCacheItem(String key) async {
    try {
      final service = ref.read(cacheManagerServiceProvider);
      return await service.getCacheItem(key);
    } catch (e) {
      debugPrint('❌ 캐시 항목 가져오기 실패: $e');
      return null;
    }
  }

  Future<void> removeCacheItem(String key) async {
    try {
      final service = ref.read(cacheManagerServiceProvider);
      await service.removeCacheItem(key);
      await _loadStats();
    } catch (e) {
      debugPrint('❌ 캐시 항목 제거 실패: $e');
    }
  }

  Future<void> performCleanup() async {
    try {
      final service = ref.read(cacheManagerServiceProvider);
      await service.performCleanup();
      await _loadStats();
    } catch (e) {
      debugPrint('❌ 캐시 정리 실패: $e');
    }
  }

  Future<void> clearCategory(String category) async {
    try {
      final service = ref.read(cacheManagerServiceProvider);
      await service.clearCategory(category);
      await _loadStats();
    } catch (e) {
      debugPrint('❌ 카테고리 캐시 정리 실패: $e');
    }
  }

  Future<void> clearAllCache() async {
    try {
      final service = ref.read(cacheManagerServiceProvider);
      await service.clearAllCache();
      await _loadStats();
    } catch (e) {
      debugPrint('❌ 전체 캐시 정리 실패: $e');
    }
  }

  Future<void> migrateCache(String fromVersion, String toVersion) async {
    try {
      final service = ref.read(cacheManagerServiceProvider);
      await service.migrateCache(fromVersion, toVersion);
      await _loadStats();
    } catch (e) {
      debugPrint('❌ 캐시 마이그레이션 실패: $e');
    }
  }

  Future<void> refreshStats() async {
    await _loadStats();
  }
}

final cacheManagerNotifierProvider =
    AutoDisposeNotifierProvider<CacheManagerNotifier, Map<String, dynamic>>(
      CacheManagerNotifier.new,
    );

final cacheStatsProvider = AutoDisposeProvider<Map<String, dynamic>>((ref) {
  return ref.watch(cacheManagerNotifierProvider);
});

final cacheCategoryStatsProvider = AutoDisposeProvider<Map<String, dynamic>>((
  ref,
) {
  final service = ref.read(cacheManagerServiceProvider);
  final stats = service.getCacheStats();

  final categoryStats = <String, dynamic>{};
  for (final entry in stats.entries) {
    categoryStats[entry.key] = entry.value.toMap();
  }

  return categoryStats;
});

final cacheCategoryProvider = AutoDisposeProvider.family<CacheStats, String>((
  ref,
  category,
) {
  final service = ref.read(cacheManagerServiceProvider);
  return service.getCategoryStats(category);
});
