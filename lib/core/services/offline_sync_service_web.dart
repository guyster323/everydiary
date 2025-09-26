import 'dart:html' as html;

import 'package:flutter/foundation.dart';

import 'background_sync_api_service.dart';
import 'indexed_db_service_web.dart';

/// 오프라인 동기화를 관리하는 서비스 (웹 전용)
class OfflineSyncService {
  final IndexedDBService _indexedDB;

  // 동기화 설정
  static const int _maxRetryCount = 3;
  static const int _syncBatchSize = 10;

  // 동기화 상태
  bool _isOnline = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  OfflineSyncService(this._indexedDB);

  /// 온라인 상태 확인
  bool get isOnline => _isOnline;

  /// 동기화 중인지 확인
  bool get isSyncing => _isSyncing;

  /// 마지막 동기화 시간
  DateTime? get lastSyncTime => _lastSyncTime;

  /// 오프라인 동기화 서비스 초기화
  Future<void> initialize() async {
    if (!kIsWeb) return;

    try {
      debugPrint('🔄 오프라인 동기화 서비스 초기화 시작');

      // 네트워크 상태 리스너 설정
      _setupNetworkStatusListener();

      // 백그라운드 동기화 등록
      await _registerBackgroundSync();

      // 오프라인 큐 처리
      await _processOfflineQueue();

      debugPrint('✅ 오프라인 동기화 서비스 초기화 완료');
    } catch (e) {
      debugPrint('❌ 오프라인 동기화 서비스 초기화 실패: $e');
    }
  }

  /// 네트워크 상태 리스너 설정
  void _setupNetworkStatusListener() {
    if (!kIsWeb) return;

    // 초기 온라인 상태 설정
    _isOnline = html.window.navigator.onLine ?? true;

    // 온라인/오프라인 이벤트 리스너 설정
    html.window.addEventListener('online', (event) {
      _isOnline = true;
      debugPrint('🌐 네트워크 상태 변경: 온라인');

      if (!_isSyncing) {
        // 온라인으로 복구되면 즉시 동기화 시도
        _triggerSync();
      }
    });

    html.window.addEventListener('offline', (event) {
      _isOnline = false;
      debugPrint('🌐 네트워크 상태 변경: 오프라인');
    });
  }

  /// 백그라운드 동기화 등록
  Future<void> _registerBackgroundSync() async {
    if (!kIsWeb) return;

    try {
      final registration = await html.window.navigator.serviceWorker?.ready;
      if (registration != null) {
        await registration.sync?.register('background-sync');
        debugPrint('📋 백그라운드 동기화 등록됨');
      }
    } catch (e) {
      debugPrint('❌ 백그라운드 동기화 등록 실패: $e');
    }
  }

  /// 오프라인 큐 처리
  Future<void> _processOfflineQueue() async {
    if (!_isOnline || _isSyncing) return;

    try {
      _isSyncing = true;
      debugPrint('🔄 오프라인 큐 처리 시작');

      final queueItems = await _indexedDB.getOfflineQueue();
      final batch = queueItems.take(_syncBatchSize).toList();

      for (final item in batch) {
        try {
          await _processQueueItem(item);
          await _indexedDB.removeFromOfflineQueue(item['id']);
          debugPrint('✅ 큐 아이템 처리 완료: ${item['type']}');
        } catch (e) {
          debugPrint('❌ 큐 아이템 처리 실패: ${item['type']} - $e');
          await _handleQueueItemError(item, e);
        }
      }

      _lastSyncTime = DateTime.now();
      debugPrint('✅ 오프라인 큐 처리 완료: ${batch.length}개 아이템');
    } catch (e) {
      debugPrint('❌ 오프라인 큐 처리 실패: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// 큐 아이템 처리
  Future<void> _processQueueItem(Map<String, dynamic> item) async {
    final type = item['type'] as String;
    final data = item['data'] as Map<String, dynamic>;

    switch (type) {
      case 'diary_create':
        await _syncDiaryCreate(data);
        break;
      case 'diary_update':
        await _syncDiaryUpdate(data);
        break;
      case 'diary_delete':
        await _syncDiaryDelete(data);
        break;
      case 'settings_update':
        await _syncSettingsUpdate(data);
        break;
      default:
        debugPrint('⚠️ 알 수 없는 큐 아이템 타입: $type');
    }
  }

  /// 일기 생성 동기화
  Future<void> _syncDiaryCreate(Map<String, dynamic> data) async {
    try {
      debugPrint('📝 일기 생성 동기화: ${data['title']}');

      // 네트워크 연결 확인
      final isConnected =
          await BackgroundSyncApiService.checkNetworkConnection();
      if (!isConnected) {
        throw Exception('네트워크 연결이 없습니다');
      }

      // API 호출
      final response = await BackgroundSyncApiService.createDiary(data);

      if (BackgroundSyncApiService.validateApiResponse(response)) {
        debugPrint('✅ 일기 생성 동기화 성공: ${response['id']}');
      } else {
        throw Exception('API 응답이 유효하지 않습니다');
      }
    } catch (e) {
      debugPrint('❌ 일기 생성 동기화 실패: $e');
      rethrow;
    }
  }

  /// 일기 업데이트 동기화
  Future<void> _syncDiaryUpdate(Map<String, dynamic> data) async {
    try {
      debugPrint('📝 일기 업데이트 동기화: ${data['title']}');

      // 네트워크 연결 확인
      final isConnected =
          await BackgroundSyncApiService.checkNetworkConnection();
      if (!isConnected) {
        throw Exception('네트워크 연결이 없습니다');
      }

      // API 호출
      final response = await BackgroundSyncApiService.updateDiary(
        data['id'] as String,
        data,
      );

      if (BackgroundSyncApiService.validateApiResponse(response)) {
        debugPrint('✅ 일기 업데이트 동기화 성공: ${response['id']}');
      } else {
        throw Exception('API 응답이 유효하지 않습니다');
      }
    } catch (e) {
      debugPrint('❌ 일기 업데이트 동기화 실패: $e');
      rethrow;
    }
  }

  /// 일기 삭제 동기화
  Future<void> _syncDiaryDelete(Map<String, dynamic> data) async {
    try {
      debugPrint('🗑️ 일기 삭제 동기화: ${data['id']}');

      // 네트워크 연결 확인
      final isConnected =
          await BackgroundSyncApiService.checkNetworkConnection();
      if (!isConnected) {
        throw Exception('네트워크 연결이 없습니다');
      }

      // API 호출
      final response = await BackgroundSyncApiService.deleteDiary(
        data['id'] as String,
      );

      if (BackgroundSyncApiService.validateApiResponse(response)) {
        debugPrint('✅ 일기 삭제 동기화 성공: ${response['id']}');
      } else {
        throw Exception('API 응답이 유효하지 않습니다');
      }
    } catch (e) {
      debugPrint('❌ 일기 삭제 동기화 실패: $e');
      rethrow;
    }
  }

  /// 설정 업데이트 동기화
  Future<void> _syncSettingsUpdate(Map<String, dynamic> data) async {
    try {
      debugPrint('⚙️ 설정 업데이트 동기화: ${data['key']}');

      // 네트워크 연결 확인
      final isConnected =
          await BackgroundSyncApiService.checkNetworkConnection();
      if (!isConnected) {
        throw Exception('네트워크 연결이 없습니다');
      }

      // API 호출
      final response = await BackgroundSyncApiService.updateSettings(
        data['key'] as String,
        data['value'],
      );

      if (BackgroundSyncApiService.validateApiResponse(response)) {
        debugPrint('✅ 설정 업데이트 동기화 성공: ${response['key']}');
      } else {
        throw Exception('API 응답이 유효하지 않습니다');
      }
    } catch (e) {
      debugPrint('❌ 설정 업데이트 동기화 실패: $e');
      rethrow;
    }
  }

  /// 큐 아이템 오류 처리
  Future<void> _handleQueueItemError(
    Map<String, dynamic> item,
    dynamic error,
  ) async {
    final retryCount = (item['retryCount'] as int?) ?? 0;

    if (retryCount < _maxRetryCount) {
      // 재시도 카운트 증가 후 큐에 다시 추가
      final updatedItem = Map<String, dynamic>.from(item);
      updatedItem['retryCount'] = retryCount + 1;

      // 기존 아이템 제거 후 업데이트된 아이템 추가
      await _indexedDB.removeFromOfflineQueue(item['id']);
      await _indexedDB.addToOfflineQueue(
        updatedItem['type'] as String,
        updatedItem['data'] as Map<String, dynamic>,
      );

      debugPrint(
        '🔄 재시도 예약됨: ${item['type']} (${retryCount + 1}/$_maxRetryCount)',
      );
    } else {
      // 최대 재시도 횟수 초과 시 실패 처리
      await _indexedDB.removeFromOfflineQueue(item['id']);
      debugPrint('❌ 최대 재시도 횟수 초과: ${item['type']}');
    }
  }

  /// 동기화 트리거
  Future<void> _triggerSync() async {
    if (!_isOnline || _isSyncing) return;

    try {
      debugPrint('🔄 동기화 트리거됨');
      await _processOfflineQueue();
    } catch (e) {
      debugPrint('❌ 동기화 트리거 실패: $e');
    }
  }

  /// 수동 동기화 실행
  Future<void> syncNow() async {
    if (_isSyncing) {
      debugPrint('⚠️ 이미 동기화 중입니다');
      return;
    }

    try {
      debugPrint('🔄 수동 동기화 시작');
      await _processOfflineQueue();
      debugPrint('✅ 수동 동기화 완료');
    } catch (e) {
      debugPrint('❌ 수동 동기화 실패: $e');
      rethrow;
    }
  }

  /// 오프라인 큐에 작업 추가
  Future<void> addToOfflineQueue(String type, Map<String, dynamic> data) async {
    try {
      await _indexedDB.addToOfflineQueue(type, data);
      debugPrint('📋 오프라인 큐에 추가됨: $type');

      // 온라인 상태라면 즉시 동기화 시도
      if (_isOnline && !_isSyncing) {
        _triggerSync();
      }
    } catch (e) {
      debugPrint('❌ 오프라인 큐 추가 실패: $e');
    }
  }

  /// 동기화 상태 확인
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final queueItems = await _indexedDB.getOfflineQueue();
      final pendingCount = queueItems.length;
      final failedCount = queueItems
          .where(
            (item) => ((item['retryCount'] as int?) ?? 0) >= _maxRetryCount,
          )
          .length;

      return {
        'isOnline': _isOnline,
        'isSyncing': _isSyncing,
        'lastSyncTime': _lastSyncTime?.toIso8601String(),
        'pendingCount': pendingCount,
        'failedCount': failedCount,
        'queueItems': queueItems,
      };
    } catch (e) {
      debugPrint('❌ 동기화 상태 확인 실패: $e');
      return {};
    }
  }

  /// 실패한 동기화 재시도
  Future<void> retryFailedSync() async {
    try {
      debugPrint('🔄 실패한 동기화 재시도 시작');

      final queueItems = await _indexedDB.getOfflineQueue();
      final failedItems = queueItems
          .where(
            (item) => ((item['retryCount'] as int?) ?? 0) >= _maxRetryCount,
          )
          .toList();

      for (final item in failedItems) {
        // 재시도 카운트 리셋 후 큐에 다시 추가
        final resetItem = Map<String, dynamic>.from(item);
        resetItem['retryCount'] = 0;

        // 기존 아이템 제거 후 재시도 카운트가 리셋된 아이템 추가
        await _indexedDB.removeFromOfflineQueue(item['id']);
        await _indexedDB.addToOfflineQueue(
          resetItem['type'] as String,
          resetItem['data'] as Map<String, dynamic>,
        );
      }

      // 동기화 재시도
      await _triggerSync();

      debugPrint('✅ 실패한 동기화 재시도 완료: ${failedItems.length}개 아이템');
    } catch (e) {
      debugPrint('❌ 실패한 동기화 재시도 실패: $e');
    }
  }

  /// 오프라인 큐 정리
  Future<void> clearOfflineQueue() async {
    try {
      final queueItems = await _indexedDB.getOfflineQueue();

      for (final item in queueItems) {
        await _indexedDB.removeFromOfflineQueue(item['id']);
      }

      debugPrint('🗑️ 오프라인 큐 정리 완료: ${queueItems.length}개 아이템');
    } catch (e) {
      debugPrint('❌ 오프라인 큐 정리 실패: $e');
    }
  }

  /// 동기화 통계 정보
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final queueItems = await _indexedDB.getOfflineQueue();
      final stats = <String, dynamic>{
        'totalItems': queueItems.length,
        'pendingItems': queueItems
            .where(
              (item) => ((item['retryCount'] as int?) ?? 0) < _maxRetryCount,
            )
            .length,
        'failedItems': queueItems
            .where(
              (item) => ((item['retryCount'] as int?) ?? 0) >= _maxRetryCount,
            )
            .length,
        'itemTypes': <String, int>{},
      };

      // 타입별 통계
      for (final item in queueItems) {
        final type = item['type'] as String;
        stats['itemTypes'][type] = (stats['itemTypes'][type] as int? ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      debugPrint('❌ 동기화 통계 가져오기 실패: $e');
      return {};
    }
  }
}
