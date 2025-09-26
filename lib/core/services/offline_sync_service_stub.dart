import 'package:flutter/foundation.dart';

import 'indexed_db_service_stub.dart';

/// 오프라인 동기화를 관리하는 서비스 (웹이 아닌 플랫폼용 스텁)
class OfflineSyncService {
  // 동기화 상태
  final bool _isOnline = true;
  final bool _isSyncing = false;
  DateTime? _lastSyncTime;

  OfflineSyncService(IndexedDBService indexedDB);

  /// 온라인 상태 확인
  bool get isOnline => _isOnline;

  /// 동기화 중인지 확인
  bool get isSyncing => _isSyncing;

  /// 마지막 동기화 시간
  DateTime? get lastSyncTime => _lastSyncTime;

  /// 오프라인 동기화 서비스 초기화
  Future<void> initialize() async {
    debugPrint('🔄 오프라인 동기화 서비스 초기화 (스텁)');
  }

  /// 수동 동기화 실행
  Future<void> syncNow() async {
    debugPrint('🔄 수동 동기화 (스텁)');
  }

  /// 오프라인 큐에 작업 추가
  Future<void> addToOfflineQueue(String type, Map<String, dynamic> data) async {
    debugPrint('📋 오프라인 큐에 추가 (스텁): $type');
  }

  /// 동기화 상태 확인
  Future<Map<String, dynamic>> getSyncStatus() async {
    return {
      'isOnline': _isOnline,
      'isSyncing': _isSyncing,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
      'pendingCount': 0,
      'failedCount': 0,
      'queueItems': <String>[],
    };
  }

  /// 실패한 동기화 재시도
  Future<void> retryFailedSync() async {
    debugPrint('🔄 실패한 동기화 재시도 (스텁)');
  }

  /// 오프라인 큐 정리
  Future<void> clearOfflineQueue() async {
    debugPrint('🗑️ 오프라인 큐 정리 (스텁)');
  }

  /// 동기화 통계 정보
  Future<Map<String, dynamic>> getSyncStats() async {
    return {
      'totalItems': 0,
      'pendingItems': 0,
      'failedItems': 0,
      'itemTypes': <String, dynamic>{},
    };
  }
}
