import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/cache_manager_service.dart';

part 'cache_manager_provider.g.dart';

/// 캐시 관리 서비스 프로바이더
@riverpod
CacheManagerService cacheManagerService(CacheManagerServiceRef ref) {
  return CacheManagerService();
}

/// 캐시 관리자
@riverpod
class CacheManagerNotifier extends _$CacheManagerNotifier {
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

  /// 초기화
  Future<void> _initialize() async {
    try {
      debugPrint('🔄 캐시 관리자 초기화 시작');

      final service = ref.read(cacheManagerServiceProvider);
      await service.initialize();

      // 이벤트 스트림 구독
      service.eventStream.listen(
        (CacheEvent event) {
          _handleCacheEvent(event);
        },
        onError: (Object error) {
          debugPrint('❌ 캐시 이벤트 스트림 오류: $error');
        },
      );

      // 초기 통계 로드
      await _loadStats();

      debugPrint('✅ 캐시 관리자 초기화 완료');
    } catch (e) {
      debugPrint('❌ 캐시 관리자 초기화 실패: $e');
    }
  }

  /// 캐시 이벤트 처리
  void _handleCacheEvent(CacheEvent event) {
    // 통계 업데이트
    _loadStats();
  }

  /// 통계 로드
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

  /// 캐시 항목 추가
  Future<void> addCacheItem(String key, dynamic data, {
    Duration? expiry,
    CachePriority priority = CachePriority.normal,
    String? category,
  }) async {
    try {
      final service = ref.read(cacheManagerServiceProvider);
      await service.addCacheItem(key, data,
        expiry: expiry,
        priority: priority,
        category: category,
      );
      await _loadStats();
    } catch (e) {
      debugPrint('❌ 캐시 항목 추가 실패: $e');
    }
  }

  /// 캐시 항목 가져오기
  Future<dynamic> getCacheItem(String key) async {
    try {
      final service = ref.read(cacheManagerServiceProvider);
      return await service.getCacheItem(key);
    } catch (e) {
      debugPrint('❌ 캐시 항목 가져오기 실패: $e');
      return null;
    }
  }

  /// 캐시 항목 제거
  Future<void> removeCacheItem(String key) async {
    try {
      final service = ref.read(cacheManagerServiceProvider);
      await service.removeCacheItem(key);
      await _loadStats();
    } catch (e) {
      debugPrint('❌ 캐시 항목 제거 실패: $e');
    }
  }

  /// 캐시 정리 수행
  Future<void> performCleanup() async {
    try {
      final service = ref.read(cacheManagerServiceProvider);
      await service.performCleanup();
      await _loadStats();
    } catch (e) {
      debugPrint('❌ 캐시 정리 실패: $e');
    }
  }

  /// 카테고리 캐시 정리
  Future<void> clearCategory(String category) async {
    try {
      final service = ref.read(cacheManagerServiceProvider);
      await service.clearCategory(category);
      await _loadStats();
    } catch (e) {
      debugPrint('❌ 카테고리 캐시 정리 실패: $e');
    }
  }

  /// 전체 캐시 정리
  Future<void> clearAllCache() async {
    try {
      final service = ref.read(cacheManagerServiceProvider);
      await service.clearAllCache();
      await _loadStats();
    } catch (e) {
      debugPrint('❌ 전체 캐시 정리 실패: $e');
    }
  }

  /// 캐시 마이그레이션
  Future<void> migrateCache(String fromVersion, String toVersion) async {
    try {
      final service = ref.read(cacheManagerServiceProvider);
      await service.migrateCache(fromVersion, toVersion);
      await _loadStats();
    } catch (e) {
      debugPrint('❌ 캐시 마이그레이션 실패: $e');
    }
  }

  /// 통계 새로고침
  Future<void> refreshStats() async {
    await _loadStats();
  }
}

/// 캐시 통계 프로바이더
@riverpod
Map<String, dynamic> cacheStats(CacheStatsRef ref) {
  return ref.watch(cacheManagerNotifierProvider);
}

/// 캐시 카테고리 통계 프로바이더
@riverpod
Map<String, dynamic> cacheCategoryStats(CacheCategoryStatsRef ref) {
  final service = ref.read(cacheManagerServiceProvider);
  final stats = service.getCacheStats();

  final categoryStats = <String, dynamic>{};
  for (final entry in stats.entries) {
    categoryStats[entry.key] = entry.value.toMap();
  }

  return categoryStats;
}

/// 캐시 이벤트 프로바이더
@riverpod
List<Map<String, dynamic>> cacheEvents(CacheEventsRef ref) {
  // 실제 구현에서는 이벤트 스트림을 구독하여 이벤트를 수집
  return [];
}

/// 캐시 항목 프로바이더
@riverpod
Future<dynamic> cacheItem(CacheItemRef ref, String key) async {
  final notifier = ref.read(cacheManagerNotifierProvider.notifier);
  return await notifier.getCacheItem(key);
}

/// 캐시 크기 프로바이더
@riverpod
int cacheSize(CacheSizeRef ref) {
  final stats = ref.watch(cacheStatsProvider);
  return stats['totalSize'] as int? ?? 0;
}

/// 캐시 항목 수 프로바이더
@riverpod
int cacheItemCount(CacheItemCountRef ref) {
  final stats = ref.watch(cacheStatsProvider);
  return stats['totalItems'] as int? ?? 0;
}

/// 캐시 카테고리 수 프로바이더
@riverpod
int cacheCategoryCount(CacheCategoryCountRef ref) {
  final stats = ref.watch(cacheStatsProvider);
  return stats['categories'] as int? ?? 0;
}

/// 캐시 사용률 프로바이더
@riverpod
double cacheUsageRate(CacheUsageRateRef ref) {
  final size = ref.watch(cacheSizeProvider);
  const maxSize = 50 * 1024 * 1024; // 50MB
  return (size / maxSize).clamp(0.0, 1.0);
}

/// 캐시 상태 프로바이더
@riverpod
String cacheStatus(CacheStatusRef ref) {
  final usageRate = ref.watch(cacheUsageRateProvider);

  if (usageRate < 0.5) {
    return '정상';
  } else if (usageRate < 0.8) {
    return '주의';
  } else {
    return '위험';
  }
}
