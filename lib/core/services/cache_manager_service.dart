import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'cache_strategy_service.dart';
import 'indexed_db_service.dart';

/// 캐시 관리 서비스
class CacheManagerService {
  static final CacheManagerService _instance = CacheManagerService._internal();
  factory CacheManagerService() => _instance;
  CacheManagerService._internal();

  final CacheStrategyService _cacheStrategy = CacheStrategyService();
  final IndexedDBService _indexedDB = IndexedDBService();

  // 캐시 통계
  final Map<String, CacheStats> _cacheStats = {};
  final StreamController<CacheEvent> _eventController =
      StreamController<CacheEvent>.broadcast();
  Stream<CacheEvent> get eventStream => _eventController.stream;

  // 캐시 설정
  static const int _maxCacheSize = 50 * 1024 * 1024; // 50MB
  static const double _cleanupThreshold = 0.8; // 80% 사용 시 정리
  static const Duration _defaultExpiry = Duration(hours: 24);

  bool _isInitialized = false;

  /// 캐시 관리 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 캐시 관리 서비스 초기화 시작');

      // 서비스들 초기화
      await _cacheStrategy.initialize();
      await _indexedDB.initialize();

      // 캐시 통계 로드
      await _loadCacheStats();

      // 정리 작업 스케줄링
      _scheduleCleanup();

      _isInitialized = true;
      debugPrint('✅ 캐시 관리 서비스 초기화 완료');
    } catch (e) {
      debugPrint('❌ 캐시 관리 서비스 초기화 실패: $e');
    }
  }

  /// 캐시 통계 로드
  Future<void> _loadCacheStats() async {
    try {
      final stats = await _indexedDB.getCacheData('cache_stats');
      if (stats != null) {
        final Map<String, dynamic> statsMap =
            jsonDecode(stats as String) as Map<String, dynamic>;
        _cacheStats.clear();
        statsMap.forEach((String key, dynamic value) {
          _cacheStats[key] = CacheStats.fromMap(value as Map<String, dynamic>);
        });
      }
    } catch (e) {
      debugPrint('❌ 캐시 통계 로드 실패: $e');
    }
  }

  /// 캐시 통계 저장
  Future<void> _saveCacheStats() async {
    try {
      final statsMap = <String, dynamic>{};
      _cacheStats.forEach((key, value) {
        statsMap[key] = value.toMap();
      });
      await _indexedDB.setCacheData('cache_stats', jsonEncode(statsMap));
    } catch (e) {
      debugPrint('❌ 캐시 통계 저장 실패: $e');
    }
  }

  /// 캐시 항목 추가
  Future<void> addCacheItem(
    String key,
    dynamic data, {
    Duration? expiry,
    CachePriority priority = CachePriority.normal,
    String? category,
  }) async {
    try {
      final expiryTime = expiry ?? _defaultExpiry;
      final cacheItem = CacheItem(
        key: key,
        data: data,
        expiry: DateTime.now().add(expiryTime),
        priority: priority,
        category: category ?? 'default',
        createdAt: DateTime.now(),
        lastAccessed: DateTime.now(),
        accessCount: 0,
      );

      // 캐시 크기 확인 및 정리
      await _checkAndCleanup();

      // 캐시 항목 저장
      await _indexedDB.setCacheData(
        'cache_$key',
        jsonEncode(cacheItem.toMap()),
      );

      // 통계 업데이트
      _updateCacheStats(category ?? 'default', cacheItem.size);

      // 이벤트 발생
      _eventController.add(CacheEvent.added(key, category ?? 'default'));

      debugPrint('📦 캐시 항목 추가: $key');
    } catch (e) {
      debugPrint('❌ 캐시 항목 추가 실패: $e');
    }
  }

  /// 캐시 항목 가져오기
  Future<dynamic> getCacheItem(String key) async {
    try {
      final data = await _indexedDB.getCacheData('cache_$key');
      if (data == null) return null;

      final cacheItem = CacheItem.fromMap(
        jsonDecode(data as String) as Map<String, dynamic>,
      );

      // 만료 확인
      if (cacheItem.expiry.isBefore(DateTime.now())) {
        await removeCacheItem(key);
        return null;
      }

      // 접근 통계 업데이트
      cacheItem.lastAccessed = DateTime.now();
      cacheItem.accessCount++;
      await _indexedDB.setCacheData(
        'cache_$key',
        jsonEncode(cacheItem.toMap()),
      );

      // 이벤트 발생
      _eventController.add(CacheEvent.accessed(key));

      return cacheItem.data;
    } catch (e) {
      debugPrint('❌ 캐시 항목 가져오기 실패: $e');
      return null;
    }
  }

  /// 캐시 항목 제거
  Future<void> removeCacheItem(String key) async {
    try {
      await _indexedDB.removeCacheData('cache_$key');

      // 통계 업데이트
      _updateCacheStats('default', -1); // 크기는 추정치로 음수 처리

      // 이벤트 발생
      _eventController.add(CacheEvent.removed(key));

      debugPrint('🗑️ 캐시 항목 제거: $key');
    } catch (e) {
      debugPrint('❌ 캐시 항목 제거 실패: $e');
    }
  }

  /// 캐시 크기 확인 및 정리
  Future<void> _checkAndCleanup() async {
    try {
      final currentSize = await _getTotalCacheSize();
      if (currentSize > _maxCacheSize * _cleanupThreshold) {
        await _performCleanup();
      }
    } catch (e) {
      debugPrint('❌ 캐시 정리 확인 실패: $e');
    }
  }

  /// 전체 캐시 크기 계산
  Future<int> _getTotalCacheSize() async {
    try {
      int totalSize = 0;
      final keys = await _indexedDB.getAllCacheKeys();
      for (final key in keys) {
        if (key.startsWith('cache_')) {
          final data = await _indexedDB.getCacheData(key);
          if (data != null) {
            totalSize += (data as String).length;
          }
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('❌ 캐시 크기 계산 실패: $e');
      return 0;
    }
  }

  /// 캐시 정리 수행
  Future<void> _performCleanup() async {
    try {
      debugPrint('🧹 캐시 정리 시작');

      // 만료된 항목 제거
      await _removeExpiredItems();

      // 우선순위 기반 정리
      await _cleanupByPriority();

      debugPrint('✅ 캐시 정리 완료');
    } catch (e) {
      debugPrint('❌ 캐시 정리 실패: $e');
    }
  }

  /// 만료된 항목 제거
  Future<void> _removeExpiredItems() async {
    try {
      final keys = await _indexedDB.getAllCacheKeys();
      final expiredKeys = <String>[];

      for (final key in keys) {
        if (key.startsWith('cache_')) {
          final data = await _indexedDB.getCacheData(key);
          if (data != null) {
            final cacheItem = CacheItem.fromMap(
              jsonDecode(data as String) as Map<String, dynamic>,
            );
            if (cacheItem.expiry.isBefore(DateTime.now())) {
              expiredKeys.add(key);
            }
          }
        }
      }

      for (final key in expiredKeys) {
        await _indexedDB.removeCacheData(key);
      }

      debugPrint('🗑️ 만료된 캐시 항목 제거: ${expiredKeys.length}개');
    } catch (e) {
      debugPrint('❌ 만료된 항목 제거 실패: $e');
    }
  }

  /// 우선순위 기반 정리
  Future<void> _cleanupByPriority() async {
    try {
      final keys = await _indexedDB.getAllCacheKeys();
      final cacheItems = <String, CacheItem>{};

      for (final key in keys) {
        if (key.startsWith('cache_')) {
          final data = await _indexedDB.getCacheData(key);
          if (data != null) {
            final cacheItem = CacheItem.fromMap(
              jsonDecode(data as String) as Map<String, dynamic>,
            );
            cacheItems[key] = cacheItem;
          }
        }
      }

      // 우선순위 및 접근 시간 기준으로 정렬
      final sortedItems = cacheItems.entries.toList()
        ..sort((MapEntry<String, CacheItem> a, MapEntry<String, CacheItem> b) {
          final priorityCompare = a.value.priority.index.compareTo(
            b.value.priority.index,
          );
          if (priorityCompare != 0) return priorityCompare;
          return a.value.lastAccessed.compareTo(b.value.lastAccessed);
        });

      // 낮은 우선순위 항목부터 제거
      final itemsToRemove = sortedItems
          .take((sortedItems.length * 0.2).round())
          .toList();
      for (final item in itemsToRemove) {
        await _indexedDB.removeCacheData(item.key);
      }

      debugPrint('🗑️ 우선순위 기반 캐시 정리: ${itemsToRemove.length}개');
    } catch (e) {
      debugPrint('❌ 우선순위 기반 정리 실패: $e');
    }
  }

  /// 캐시 통계 업데이트
  void _updateCacheStats(String category, int sizeChange) {
    if (!_cacheStats.containsKey(category)) {
      _cacheStats[category] = CacheStats(category: category);
    }

    final stats = _cacheStats[category]!;
    stats.itemCount += sizeChange > 0 ? 1 : -1;
    stats.totalSize += sizeChange;
    stats.lastUpdated = DateTime.now();

    _saveCacheStats();
  }

  /// 정리 작업 스케줄링
  void _scheduleCleanup() {
    Timer.periodic(const Duration(hours: 1), (timer) {
      _performCleanup();
    });
  }

  /// 캐시 통계 가져오기
  Map<String, CacheStats> getCacheStats() {
    return Map.from(_cacheStats);
  }

  /// 특정 카테고리 캐시 정리
  Future<void> clearCategory(String category) async {
    try {
      final keys = await _indexedDB.getAllCacheKeys();
      final categoryKeys = <String>[];

      for (final key in keys) {
        if (key.startsWith('cache_')) {
          final data = await _indexedDB.getCacheData(key);
          if (data != null) {
            final cacheItem = CacheItem.fromMap(
              jsonDecode(data as String) as Map<String, dynamic>,
            );
            if (cacheItem.category == category) {
              categoryKeys.add(key);
            }
          }
        }
      }

      for (final key in categoryKeys) {
        await _indexedDB.removeCacheData(key);
      }

      // 통계 초기화
      if (_cacheStats.containsKey(category)) {
        _cacheStats[category] = CacheStats(category: category);
        _saveCacheStats();
      }

      debugPrint('🗑️ 카테고리 캐시 정리: $category (${categoryKeys.length}개)');
    } catch (e) {
      debugPrint('❌ 카테고리 캐시 정리 실패: $e');
    }
  }

  /// 전체 캐시 정리
  Future<void> clearAllCache() async {
    try {
      final keys = await _indexedDB.getAllCacheKeys();
      final cacheKeys = keys
          .where((String key) => key.startsWith('cache_'))
          .toList();

      for (final key in cacheKeys) {
        await _indexedDB.removeCacheData(key);
      }

      // 통계 초기화
      _cacheStats.clear();
      _saveCacheStats();

      debugPrint('🗑️ 전체 캐시 정리: ${cacheKeys.length}개');
    } catch (e) {
      debugPrint('❌ 전체 캐시 정리 실패: $e');
    }
  }

  /// 캐시 마이그레이션
  Future<void> migrateCache(String fromVersion, String toVersion) async {
    try {
      debugPrint('🔄 캐시 마이그레이션: $fromVersion -> $toVersion');

      // 기존 캐시 백업
      await _backupCache();

      // 호환되지 않는 캐시 제거
      await _removeIncompatibleCache();

      // 새 버전으로 마이그레이션
      await _migrateToNewVersion(toVersion);

      debugPrint('✅ 캐시 마이그레이션 완료');
    } catch (e) {
      debugPrint('❌ 캐시 마이그레이션 실패: $e');
    }
  }

  /// 캐시 백업
  Future<void> _backupCache() async {
    // 백업 로직 구현
  }

  /// 호환되지 않는 캐시 제거
  Future<void> _removeIncompatibleCache() async {
    // 호환성 검사 및 제거 로직 구현
  }

  /// 새 버전으로 마이그레이션
  Future<void> _migrateToNewVersion(String version) async {
    // 마이그레이션 로직 구현
  }

  /// 캐시 정리 수행 (public)
  Future<void> performCleanup() async {
    await _performCleanup();
  }

  /// 캐시 관리 서비스 정리
  void dispose() {
    _eventController.close();
    debugPrint('🗑️ 캐시 관리 서비스 정리 완료');
  }
}

/// 캐시 우선순위
enum CachePriority { low, normal, high, critical }

/// 캐시 항목
class CacheItem {
  final String key;
  final dynamic data;
  final DateTime expiry;
  final CachePriority priority;
  final String category;
  final DateTime createdAt;
  DateTime lastAccessed;
  int accessCount;

  CacheItem({
    required this.key,
    required this.data,
    required this.expiry,
    required this.priority,
    required this.category,
    required this.createdAt,
    required this.lastAccessed,
    required this.accessCount,
  });

  int get size {
    try {
      return jsonEncode(data).length;
    } catch (e) {
      return 0;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'data': data,
      'expiry': expiry.toIso8601String(),
      'priority': priority.index,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'lastAccessed': lastAccessed.toIso8601String(),
      'accessCount': accessCount,
    };
  }

  factory CacheItem.fromMap(Map<String, dynamic> map) {
    return CacheItem(
      key: map['key'] as String,
      data: map['data'],
      expiry: DateTime.parse(map['expiry'] as String),
      priority: CachePriority.values[map['priority'] as int],
      category: map['category'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastAccessed: DateTime.parse(map['lastAccessed'] as String),
      accessCount: map['accessCount'] as int,
    );
  }
}

/// 캐시 통계
class CacheStats {
  final String category;
  int itemCount;
  int totalSize;
  DateTime lastUpdated;

  CacheStats({
    required this.category,
    this.itemCount = 0,
    this.totalSize = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'itemCount': itemCount,
      'totalSize': totalSize,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory CacheStats.fromMap(Map<String, dynamic> map) {
    return CacheStats(
      category: map['category'] as String,
      itemCount: map['itemCount'] as int,
      totalSize: map['totalSize'] as int,
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }
}

/// 캐시 이벤트
abstract class CacheEvent {
  final String key;
  final DateTime timestamp;

  CacheEvent(this.key) : timestamp = DateTime.now();

  factory CacheEvent.added(String key, String category) = CacheAddedEvent;
  factory CacheEvent.removed(String key) = CacheRemovedEvent;
  factory CacheEvent.accessed(String key) = CacheAccessedEvent;
}

class CacheAddedEvent extends CacheEvent {
  final String category;
  CacheAddedEvent(super.key, this.category);
}

class CacheRemovedEvent extends CacheEvent {
  CacheRemovedEvent(super.key);
}

class CacheAccessedEvent extends CacheEvent {
  CacheAccessedEvent(super.key);
}
