import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Android 네이티브 캐시 관리 서비스
/// PWA Service Worker 캐싱을 대체하는 Android 네이티브 캐시 구현
class AndroidCacheService {
  static final AndroidCacheService _instance = AndroidCacheService._internal();
  factory AndroidCacheService() => _instance;
  AndroidCacheService._internal();

  static const String _cacheMetadataKey = 'cache_metadata';
  static const String _cacheStatsKey = 'cache_stats';

  bool _isInitialized = false;
  Directory? _cacheDirectory;

  // 캐시 설정
  static const int _maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int _maxCacheAge = 7 * 24 * 60 * 60 * 1000; // 7일 (밀리초)

  // 이벤트 스트림
  final StreamController<Map<String, dynamic>> _cacheEventController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get cacheEventStream =>
      _cacheEventController.stream;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔧 Android Cache Service 초기화 시작...');

      // 캐시 디렉토리 설정
      _cacheDirectory = await getApplicationCacheDirectory();
      await _cacheDirectory!.create(recursive: true);

      // 캐시 정리 (오래된 항목 제거)
      await _cleanupExpiredCache();

      // 캐시 크기 확인 및 정리
      await _manageCacheSize();

      _isInitialized = true;
      debugPrint('✅ Android Cache Service 초기화 완료');
    } catch (e) {
      debugPrint('❌ Android Cache Service 초기화 실패: $e');
    }
  }

  /// 캐시 항목 저장
  Future<bool> setCache(String key, dynamic value, {Duration? ttl}) async {
    try {
      final cacheItem = {
        'key': key,
        'value': value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'ttl': ttl?.inMilliseconds ?? _maxCacheAge,
        'size': _calculateSize(value),
      };

      // 메모리 캐시에 저장
      final file = File('${_cacheDirectory!.path}/$key.json');
      await file.writeAsString(jsonEncode(cacheItem));

      // 메타데이터 업데이트
      await _updateCacheMetadata(key, cacheItem);

      debugPrint('💾 캐시 저장됨: $key');

      // 이벤트 스트림에 캐시 저장 이벤트 추가
      _cacheEventController.add({
        'type': 'cache_set',
        'key': key,
        'size': cacheItem['size'],
        'timestamp': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('❌ 캐시 저장 실패: $e');
      return false;
    }
  }

  /// 캐시 항목 조회
  Future<T?> getCache<T>(String key) async {
    try {
      final file = File('${_cacheDirectory!.path}/$key.json');

      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString();
      final cacheItem = jsonDecode(content) as Map<String, dynamic>;

      // TTL 확인
      final timestamp = cacheItem['timestamp'] as int;
      final ttl = cacheItem['ttl'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - timestamp > ttl) {
        await _removeCache(key);
        return null;
      }

      debugPrint('📖 캐시 조회됨: $key');
      return cacheItem['value'] as T?;
    } catch (e) {
      debugPrint('❌ 캐시 조회 실패: $e');
      return null;
    }
  }

  /// 캐시 항목 제거
  Future<bool> removeCache(String key) async {
    try {
      await _removeCache(key);
      debugPrint('🗑️ 캐시 제거됨: $key');
      return true;
    } catch (e) {
      debugPrint('❌ 캐시 제거 실패: $e');
      return false;
    }
  }

  /// 캐시 항목 제거 (내부 메서드)
  Future<void> _removeCache(String key) async {
    final file = File('${_cacheDirectory!.path}/$key.json');
    if (await file.exists()) {
      await file.delete();
    }
    await _removeCacheMetadata(key);
  }

  /// 모든 캐시 제거
  Future<void> clearAllCache() async {
    try {
      if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
        await _cacheDirectory!.delete(recursive: true);
        await _cacheDirectory!.create(recursive: true);
      }

      // 메타데이터 초기화
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheMetadataKey);
      await prefs.remove(_cacheStatsKey);

      debugPrint('🗑️ 모든 캐시가 제거됨');

      // 이벤트 스트림에 캐시 정리 이벤트 추가
      _cacheEventController.add({
        'type': 'cache_cleared',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ 캐시 정리 실패: $e');
    }
  }

  /// 캐시 통계 조회
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stats = prefs.getString(_cacheStatsKey);

      if (stats != null) {
        return jsonDecode(stats) as Map<String, dynamic>;
      }

      return {
        'totalSize': 0,
        'itemCount': 0,
        'hitRate': 0.0,
        'lastCleanup': null,
      };
    } catch (e) {
      debugPrint('❌ 캐시 통계 조회 실패: $e');
      return {};
    }
  }

  /// 캐시 크기 계산
  int _calculateSize(dynamic value) {
    try {
      final jsonString = jsonEncode(value);
      return utf8.encode(jsonString).length;
    } catch (e) {
      return 0;
    }
  }

  /// 캐시 메타데이터 업데이트
  Future<void> _updateCacheMetadata(
    String key,
    Map<String, dynamic> item,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadata = prefs.getString(_cacheMetadataKey);

      Map<String, dynamic> metadataMap = {};
      if (metadata != null) {
        metadataMap = jsonDecode(metadata) as Map<String, dynamic>;
      }

      metadataMap[key] = {
        'timestamp': item['timestamp'],
        'ttl': item['ttl'],
        'size': item['size'],
      };

      await prefs.setString(_cacheMetadataKey, jsonEncode(metadataMap));

      // 통계 업데이트
      await _updateCacheStats();
    } catch (e) {
      debugPrint('❌ 캐시 메타데이터 업데이트 실패: $e');
    }
  }

  /// 캐시 메타데이터에서 항목 제거
  Future<void> _removeCacheMetadata(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadata = prefs.getString(_cacheMetadataKey);

      if (metadata != null) {
        final metadataMap = jsonDecode(metadata) as Map<String, dynamic>;
        metadataMap.remove(key);
        await prefs.setString(_cacheMetadataKey, jsonEncode(metadataMap));
      }

      // 통계 업데이트
      await _updateCacheStats();
    } catch (e) {
      debugPrint('❌ 캐시 메타데이터 제거 실패: $e');
    }
  }

  /// 캐시 통계 업데이트
  Future<void> _updateCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadata = prefs.getString(_cacheMetadataKey);

      if (metadata != null) {
        final metadataMap = jsonDecode(metadata) as Map<String, dynamic>;

        int totalSize = 0;
        final int itemCount = metadataMap.length;

        for (final item in metadataMap.values) {
          totalSize += item['size'] as int;
        }

        // 히트율 계산: 캐시 히트 수 / 전체 요청 수
        final hitCount = prefs.getInt('${_cacheStatsKey}_hits') ?? 0;
        final totalRequests = prefs.getInt('${_cacheStatsKey}_requests') ?? 1;
        final hitRate = totalRequests > 0 ? hitCount / totalRequests : 0.0;

        final stats = {
          'totalSize': totalSize,
          'itemCount': itemCount,
          'hitRate': hitRate,
          'lastCleanup': DateTime.now().toIso8601String(),
        };

        await prefs.setString(_cacheStatsKey, jsonEncode(stats));
      }
    } catch (e) {
      debugPrint('❌ 캐시 통계 업데이트 실패: $e');
    }
  }

  /// 만료된 캐시 정리
  Future<void> _cleanupExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadata = prefs.getString(_cacheMetadataKey);

      if (metadata != null) {
        final metadataMap = jsonDecode(metadata) as Map<String, dynamic>;
        final now = DateTime.now().millisecondsSinceEpoch;

        final keysToRemove = <String>[];

        for (final entry in metadataMap.entries) {
          final key = entry.key;
          final item = entry.value as Map<String, dynamic>;
          final timestamp = item['timestamp'] as int;
          final ttl = item['ttl'] as int;

          if (now - timestamp > ttl) {
            keysToRemove.add(key);
          }
        }

        for (final key in keysToRemove) {
          await _removeCache(key);
        }

        if (keysToRemove.isNotEmpty) {
          debugPrint('🗑️ 만료된 캐시 ${keysToRemove.length}개 정리됨');
        }
      }
    } catch (e) {
      debugPrint('❌ 만료된 캐시 정리 실패: $e');
    }
  }

  /// 캐시 크기 관리
  Future<void> _manageCacheSize() async {
    try {
      final stats = await getCacheStats();
      final totalSize = stats['totalSize'] as int? ?? 0;

      if (totalSize > _maxCacheSize) {
        debugPrint(
          '⚠️ 캐시 크기 초과: ${totalSize / 1024 / 1024}MB / ${_maxCacheSize / 1024 / 1024}MB',
        );

        // 오래된 항목부터 제거
        await _removeOldestCacheItems();
      }
    } catch (e) {
      debugPrint('❌ 캐시 크기 관리 실패: $e');
    }
  }

  /// 가장 오래된 캐시 항목 제거
  Future<void> _removeOldestCacheItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadata = prefs.getString(_cacheMetadataKey);

      if (metadata != null) {
        final metadataMap = jsonDecode(metadata) as Map<String, dynamic>;

        // 타임스탬프 기준으로 정렬
        final sortedEntries = metadataMap.entries.toList()
          ..sort(
            (a, b) => (a.value['timestamp'] as int).compareTo(
              b.value['timestamp'] as int,
            ),
          );

        // 가장 오래된 항목들 제거 (총 크기의 20% 정도)
        final targetRemovalCount = (sortedEntries.length * 0.2).ceil();

        for (
          int i = 0;
          i < targetRemovalCount && i < sortedEntries.length;
          i++
        ) {
          await _removeCache(sortedEntries[i].key);
        }

        debugPrint('🗑️ 오래된 캐시 $targetRemovalCount개 제거됨');
      }
    } catch (e) {
      debugPrint('❌ 오래된 캐시 제거 실패: $e');
    }
  }

  /// 서비스 정리
  Future<void> dispose() async {
    await _cacheEventController.close();
  }
}
