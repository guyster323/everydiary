import 'dart:html' as html;

import 'package:flutter/foundation.dart';

/// IndexedDB를 사용한 오프라인 데이터 저장 서비스 (웹 전용)
class IndexedDBService {
  static const String _dbName = 'EveryDiaryDB';
  static const int _dbVersion = 1;

  // 스토어 이름들
  static const String _diariesStore = 'diaries';
  static const String _settingsStore = 'settings';
  static const String _offlineQueueStore = 'offlineQueue';
  static const String _cacheStore = 'cache';

  dynamic _database;
  bool _isInitialized = false;

  /// IndexedDB 초기화
  Future<void> initialize() async {
    if (!kIsWeb) return;

    try {
      debugPrint('🗄️ IndexedDB 초기화 시작');

      final request = html.window.indexedDB!.open(_dbName, version: _dbVersion);

      request.onUpgradeNeeded.listen((html.Event event) {
        final target = event.target as dynamic;
        final db = target?.result;
        if (db != null) {
          _createStores(db);
        }
      });

      request.onSuccess.listen((html.Event event) {
        final target = event.target as dynamic;
        _database = target?.result;
        _isInitialized = true;
        debugPrint('✅ IndexedDB 초기화 완료');
      });

      request.onError.listen((html.Event event) {
        debugPrint('❌ IndexedDB 초기화 실패: $event');
      });
    } catch (e) {
      debugPrint('❌ IndexedDB 초기화 오류: $e');
    }
  }

  /// 데이터베이스 스토어 생성
  void _createStores(dynamic db) {
    try {
      // 일기 데이터 스토어
      final storeNames = db.objectStoreNames;

      if (storeNames == null || !(storeNames.contains(_diariesStore) == true)) {
        final diariesStore = db.createObjectStore(
          _diariesStore,
          keyPath: 'id',
          autoIncrement: true,
        );
        diariesStore.createIndex('date', 'date', unique: false);
        diariesStore.createIndex('title', 'title', unique: false);
        diariesStore.createIndex('createdAt', 'createdAt', unique: false);
      }

      // 설정 데이터 스토어
      if (storeNames == null ||
          !(storeNames.contains(_settingsStore) == true)) {
        db.createObjectStore(_settingsStore, keyPath: 'key');
      }

      // 오프라인 큐 스토어
      if (storeNames == null ||
          !(storeNames.contains(_offlineQueueStore) == true)) {
        final queueStore = db.createObjectStore(
          _offlineQueueStore,
          keyPath: 'id',
          autoIncrement: true,
        );
        queueStore.createIndex('type', 'type', unique: false);
        queueStore.createIndex('timestamp', 'timestamp', unique: false);
      }

      // 캐시 데이터 스토어
      if (storeNames == null || !(storeNames.contains(_cacheStore) == true)) {
        final cacheStore = db.createObjectStore(_cacheStore, keyPath: 'key');
        cacheStore.createIndex('expiry', 'expiry', unique: false);
      }
    } catch (e) {
      debugPrint('❌ 스토어 생성 실패: $e');
    }
  }

  /// 일기 데이터 저장
  Future<void> saveDiary(Map<String, dynamic> diaryData) async {
    if (!_isInitialized || _database == null) return;

    try {
      final transaction = _database!.transaction([_diariesStore], 'readwrite');
      final store = transaction.objectStore(_diariesStore);

      await store.add(diaryData);
      debugPrint('💾 일기 데이터 저장됨: ${diaryData['title']}');
    } catch (e) {
      debugPrint('❌ 일기 데이터 저장 실패: $e');
    }
  }

  /// 일기 데이터 업데이트
  Future<void> updateDiary(dynamic id, Map<String, dynamic> diaryData) async {
    if (!_isInitialized || _database == null) return;

    try {
      final transaction = _database!.transaction([_diariesStore], 'readwrite');
      final store = transaction.objectStore(_diariesStore);

      await store.put(diaryData, key: id);
      debugPrint('📝 일기 데이터 업데이트됨: ${diaryData['title']}');
    } catch (e) {
      debugPrint('❌ 일기 데이터 업데이트 실패: $e');
    }
  }

  /// 일기 데이터 삭제
  Future<void> deleteDiary(dynamic id) async {
    if (!_isInitialized || _database == null) return;

    try {
      final transaction = _database!.transaction([_diariesStore], 'readwrite');
      final store = transaction.objectStore(_diariesStore);

      await store.delete(id);
      debugPrint('🗑️ 일기 데이터 삭제됨: $id');
    } catch (e) {
      debugPrint('❌ 일기 데이터 삭제 실패: $e');
    }
  }

  /// 모든 일기 데이터 가져오기
  Future<List<Map<String, dynamic>>> getAllDiaries() async {
    if (!_isInitialized || _database == null) return [];

    try {
      final transaction = _database!.transaction([_diariesStore], 'readonly');
      final store = transaction.objectStore(_diariesStore);
      final request = store.getAll();

      final result = await request.future;
      return List<Map<String, dynamic>>.from((result as Iterable?) ?? []);
    } catch (e) {
      debugPrint('❌ 일기 데이터 가져오기 실패: $e');
      return [];
    }
  }

  /// 특정 일기 데이터 가져오기
  Future<Map<String, dynamic>?> getDiary(dynamic id) async {
    if (!_isInitialized || _database == null) return null;

    try {
      final transaction = _database!.transaction([_diariesStore], 'readonly');
      final store = transaction.objectStore(_diariesStore);
      final request = store.getObject(id);

      final result = await request.future;
      return result as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('❌ 일기 데이터 가져오기 실패: $e');
      return null;
    }
  }

  /// 설정 데이터 저장
  Future<void> saveSetting(String key, dynamic value) async {
    if (!_isInitialized || _database == null) return;

    try {
      final transaction = _database!.transaction([_settingsStore], 'readwrite');
      final store = transaction.objectStore(_settingsStore);

      await store.put({'key': key, 'value': value});
      debugPrint('⚙️ 설정 저장됨: $key');
    } catch (e) {
      debugPrint('❌ 설정 저장 실패: $e');
    }
  }

  /// 설정 데이터 가져오기
  Future<dynamic> getSetting(String key) async {
    if (!_isInitialized || _database == null) return null;

    try {
      final transaction = _database!.transaction([_settingsStore], 'readonly');
      final store = transaction.objectStore(_settingsStore);
      final request = store.getObject(key);

      final result = await request.future;
      if (result != null) {
        return (result as Map<String, dynamic>)['value'];
      }
      return null;
    } catch (e) {
      debugPrint('❌ 설정 가져오기 실패: $e');
      return null;
    }
  }

  /// 오프라인 큐에 작업 추가
  Future<void> addToOfflineQueue(String type, Map<String, dynamic> data) async {
    if (!_isInitialized || _database == null) return;

    try {
      final transaction = _database!.transaction([
        _offlineQueueStore,
      ], 'readwrite');
      final store = transaction.objectStore(_offlineQueueStore);

      final queueItem = {
        'type': type,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'retryCount': data['retryCount'] ?? 0, // 기존 재시도 카운트 보존
      };

      await store.add(queueItem);
      debugPrint('📋 오프라인 큐에 추가됨: $type');
    } catch (e) {
      debugPrint('❌ 오프라인 큐 추가 실패: $e');
    }
  }

  /// 오프라인 큐에서 작업 가져오기
  Future<List<Map<String, dynamic>>> getOfflineQueue() async {
    if (!_isInitialized || _database == null) return [];

    try {
      final transaction = _database!.transaction([
        _offlineQueueStore,
      ], 'readonly');
      final store = transaction.objectStore(_offlineQueueStore);
      final request = store.getAll();

      final result = await request.future;
      return List<Map<String, dynamic>>.from((result as Iterable?) ?? []);
    } catch (e) {
      debugPrint('❌ 오프라인 큐 가져오기 실패: $e');
      return [];
    }
  }

  /// 오프라인 큐에서 작업 제거
  Future<void> removeFromOfflineQueue(dynamic id) async {
    if (!_isInitialized || _database == null) return;

    try {
      final transaction = _database!.transaction([
        _offlineQueueStore,
      ], 'readwrite');
      final store = transaction.objectStore(_offlineQueueStore);

      await store.delete(id);
      debugPrint('🗑️ 오프라인 큐에서 제거됨: $id');
    } catch (e) {
      debugPrint('❌ 오프라인 큐 제거 실패: $e');
    }
  }

  /// 캐시 데이터 저장
  Future<void> saveCacheData(
    String key,
    dynamic data, {
    int? expiryHours,
  }) async {
    if (!_isInitialized || _database == null) return;

    try {
      final transaction = _database!.transaction([_cacheStore], 'readwrite');
      final store = transaction.objectStore(_cacheStore);

      final expiry = expiryHours != null
          ? DateTime.now()
                .add(Duration(hours: expiryHours))
                .millisecondsSinceEpoch
          : null;

      final cacheItem = {
        'key': key,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiry': expiry,
      };

      await store.put(cacheItem);
      debugPrint('💾 캐시 데이터 저장됨: $key');
    } catch (e) {
      debugPrint('❌ 캐시 데이터 저장 실패: $e');
    }
  }

  /// 캐시 데이터 가져오기
  Future<dynamic> getCacheData(String key) async {
    if (!_isInitialized || _database == null) return null;

    try {
      final transaction = _database!.transaction([_cacheStore], 'readonly');
      final store = transaction.objectStore(_cacheStore);
      final request = store.getObject(key);

      final result = await request.future;
      if (result != null) {
        final cacheItem = result as Map<String, dynamic>;
        final expiry = cacheItem['expiry'] as int?;

        // 만료 확인
        if (expiry != null && DateTime.now().millisecondsSinceEpoch > expiry) {
          await _removeCacheData(key);
          return null;
        }

        return cacheItem['data'];
      }
      return null;
    } catch (e) {
      debugPrint('❌ 캐시 데이터 가져오기 실패: $e');
      return null;
    }
  }

  /// 캐시 데이터 제거
  Future<void> _removeCacheData(String key) async {
    if (!_isInitialized || _database == null) return;

    try {
      final transaction = _database!.transaction([_cacheStore], 'readwrite');
      final store = transaction.objectStore(_cacheStore);

      await store.delete(key);
      debugPrint('🗑️ 캐시 데이터 제거됨: $key');
    } catch (e) {
      debugPrint('❌ 캐시 데이터 제거 실패: $e');
    }
  }

  /// 만료된 캐시 데이터 정리
  Future<void> cleanupExpiredCache() async {
    if (!_isInitialized || _database == null) return;

    try {
      final transaction = _database!.transaction([_cacheStore], 'readwrite');
      final store = transaction.objectStore(_cacheStore);
      final request = store.getAll();

      final result = await request.future;
      final now = DateTime.now().millisecondsSinceEpoch;

      for (final item in (result as Iterable? ?? [])) {
        final cacheItem = item as Map<String, dynamic>;
        final expiry = cacheItem['expiry'] as int?;

        if (expiry != null && now > expiry) {
          await store.delete(cacheItem['key']);
          debugPrint('🗑️ 만료된 캐시 정리됨: ${cacheItem['key']}');
        }
      }
    } catch (e) {
      debugPrint('❌ 만료된 캐시 정리 실패: $e');
    }
  }

  /// 데이터베이스 통계 정보 가져오기
  Future<Map<String, dynamic>> getDatabaseStats() async {
    if (!_isInitialized || _database == null) return {};

    try {
      final stats = <String, dynamic>{};
      final storeNames = [
        _diariesStore,
        _settingsStore,
        _offlineQueueStore,
        _cacheStore,
      ];

      for (final storeName in storeNames) {
        final transaction = _database!.transaction([storeName], 'readonly');
        final store = transaction.objectStore(storeName);
        final request = store.count();

        final count = await request.future;
        stats[storeName] = count;
      }

      return stats;
    } catch (e) {
      debugPrint('❌ 데이터베이스 통계 가져오기 실패: $e');
      return {};
    }
  }

  /// 모든 데이터 삭제
  Future<void> clearAllData() async {
    if (!_isInitialized || _database == null) return;

    try {
      final storeNames = [
        _diariesStore,
        _settingsStore,
        _offlineQueueStore,
        _cacheStore,
      ];

      for (final storeName in storeNames) {
        final transaction = _database!.transaction([storeName], 'readwrite');
        final store = transaction.objectStore(storeName);
        await store.clear();
      }

      debugPrint('🗑️ 모든 데이터 삭제됨');
    } catch (e) {
      debugPrint('❌ 모든 데이터 삭제 실패: $e');
    }
  }

  /// 캐시 데이터 저장
  Future<void> setCacheData(String key, String value) async {
    if (!_isInitialized || _database == null) return;

    try {
      final transaction = _database!.transaction([_cacheStore], 'readwrite');
      final store = transaction.objectStore(_cacheStore);

      await store.put({
        'key': key,
        'value': value,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('💾 캐시 데이터 저장됨: $key');
    } catch (e) {
      debugPrint('❌ 캐시 데이터 저장 실패: $e');
    }
  }

  /// 캐시 데이터 가져오기
  Future<String?> getCacheData(String key) async {
    if (!_isInitialized || _database == null) return null;

    try {
      final transaction = _database!.transaction([_cacheStore], 'readonly');
      final store = transaction.objectStore(_cacheStore);
      final request = store.getObject(key);

      final result = await request.future;
      if (result != null) {
        return result['value'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('❌ 캐시 데이터 가져오기 실패: $e');
      return null;
    }
  }

  /// 캐시 데이터 삭제
  Future<void> removeCacheData(String key) async {
    if (!_isInitialized || _database == null) return;

    try {
      final transaction = _database!.transaction([_cacheStore], 'readwrite');
      final store = transaction.objectStore(_cacheStore);

      await store.delete(key);
      debugPrint('🗑️ 캐시 데이터 삭제됨: $key');
    } catch (e) {
      debugPrint('❌ 캐시 데이터 삭제 실패: $e');
    }
  }

  /// 모든 캐시 키 가져오기
  Future<List<String>> getAllCacheKeys() async {
    if (!_isInitialized || _database == null) return [];

    try {
      final transaction = _database!.transaction([_cacheStore], 'readonly');
      final store = transaction.objectStore(_cacheStore);
      final request = store.getAllKeys();

      final result = await request.future;
      return List<String>.from((result as Iterable?) ?? []);
    } catch (e) {
      debugPrint('❌ 캐시 키 가져오기 실패: $e');
      return [];
    }
  }

  /// 데이터베이스 닫기
  void close() {
    _database?.close();
    _isInitialized = false;
    debugPrint('🔒 IndexedDB 닫힘');
  }
}
