import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Android 네이티브 백그라운드 동기화 서비스
/// PWA Service Worker를 대체하는 Android 네이티브 구현
class AndroidBackgroundSyncService {
  static final AndroidBackgroundSyncService _instance =
      AndroidBackgroundSyncService._internal();
  factory AndroidBackgroundSyncService() => _instance;
  AndroidBackgroundSyncService._internal();

  static const String _offlineQueueKey = 'offline_queue';

  bool _isInitialized = false;
  bool _isOnline = true;

  // 이벤트 스트림
  final StreamController<bool> _networkStatusController =
      StreamController<bool>.broadcast();
  Stream<bool> get networkStatusStream => _networkStatusController.stream;

  final StreamController<Map<String, dynamic>> _syncEventController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get syncEventStream =>
      _syncEventController.stream;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔧 Android Background Sync Service 초기화 시작...');

      // 네트워크 상태 감지 설정
      await _setupNetworkStatusListener();

      // 주기적 동기화 작업 시작 (타이머 기반)
      _startPeriodicSync();

      _isInitialized = true;
      debugPrint('✅ Android Background Sync Service 초기화 완료');
    } catch (e) {
      debugPrint('❌ Android Background Sync Service 초기화 실패: $e');
    }
  }

  /// 네트워크 상태 감지 설정
  Future<void> _setupNetworkStatusListener() async {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final wasOnline = _isOnline;
      _isOnline =
          results.isNotEmpty && results.first != ConnectivityResult.none;

      if (wasOnline != _isOnline) {
        _networkStatusController.add(_isOnline);

        if (_isOnline) {
          debugPrint('🌐 네트워크 연결됨 - 백그라운드 동기화 시작');
          _triggerBackgroundSync();
        } else {
          debugPrint('📴 네트워크 연결 끊어짐 - 오프라인 모드');
        }
      }
    });
  }

  /// 주기적 동기화 작업 시작 (타이머 기반)
  void _startPeriodicSync() {
    Timer.periodic(const Duration(minutes: 15), (timer) {
      if (_isOnline) {
        _processOfflineQueue();
      }
    });
    debugPrint('🔄 주기적 동기화 타이머 시작됨 (15분마다)');
  }

  /// 백그라운드 동기화 트리거
  Future<void> _triggerBackgroundSync() async {
    if (!_isOnline) return;

    try {
      await _processOfflineQueue();
      debugPrint('🔄 즉시 동기화 실행됨');
    } catch (e) {
      debugPrint('❌ 백그라운드 동기화 실패: $e');
    }
  }

  /// 오프라인 큐에 작업 추가
  Future<void> addToOfflineQueue(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingQueue = prefs.getStringList(_offlineQueueKey) ?? [];

      final queueItem = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'retryCount': 0,
      };

      existingQueue.add(jsonEncode(queueItem));
      await prefs.setStringList(_offlineQueueKey, existingQueue);

      debugPrint('📝 오프라인 큐에 작업 추가됨');

      // 네트워크가 연결되어 있으면 즉시 동기화 시도
      if (_isOnline) {
        _triggerBackgroundSync();
      }
    } catch (e) {
      debugPrint('❌ 오프라인 큐 추가 실패: $e');
    }
  }

  /// 오프라인 큐에서 작업 가져오기
  Future<List<Map<String, dynamic>>> getOfflineQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueData = prefs.getStringList(_offlineQueueKey) ?? [];

      return queueData
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('❌ 오프라인 큐 조회 실패: $e');
      return [];
    }
  }

  /// 오프라인 큐에서 작업 제거
  Future<void> removeFromOfflineQueue(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingQueue = prefs.getStringList(_offlineQueueKey) ?? [];

      final updatedQueue = existingQueue.where((item) {
        final data = jsonDecode(item) as Map<String, dynamic>;
        return data['id'].toString() != id;
      }).toList();

      await prefs.setStringList(_offlineQueueKey, updatedQueue);
      debugPrint('🗑️ 오프라인 큐에서 작업 제거됨: $id');
    } catch (e) {
      debugPrint('❌ 오프라인 큐 제거 실패: $e');
    }
  }

  /// 오프라인 큐 전체 삭제
  Future<void> clearOfflineQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_offlineQueueKey);
      debugPrint('🗑️ 오프라인 큐 전체 삭제됨');
    } catch (e) {
      debugPrint('❌ 오프라인 큐 삭제 실패: $e');
    }
  }

  /// 오프라인 큐 처리
  Future<void> _processOfflineQueue() async {
    try {
      final queue = await getOfflineQueue();

      for (final item in queue) {
        await _processOfflineItem(item);
        await removeFromOfflineQueue(item['id'].toString());
      }

      debugPrint('✅ 오프라인 큐 처리 완료');
    } catch (e) {
      debugPrint('❌ 오프라인 큐 처리 실패: $e');
    }
  }

  /// 오프라인 아이템 처리
  Future<void> _processOfflineItem(Map<String, dynamic> item) async {
    final dynamic dataRaw = item['data'];
    if (dataRaw is! Map<String, dynamic>) {
      debugPrint('⚠️ 알 수 없는 오프라인 아이템 형식: $item');
      return;
    }

    final data = Map<String, dynamic>.from(dataRaw);
    final retryCount = (item['retryCount'] as int?) ?? 0;

    try {
      // 실제 동기화 로직 구현 (API 호출 등)
      debugPrint('📤 오프라인 아이템 동기화: ${data['type']}');

      // 여기에 실제 API 호출 로직을 구현
      // 예: Supabase, Firebase, REST API 등
    } catch (e) {
      debugPrint('❌ 오프라인 아이템 처리 실패: $e');

      // 재시도 로직
      if (retryCount < 3) {
        final updatedItem = Map<String, dynamic>.from(item);
        updatedItem['retryCount'] = retryCount + 1;

        // 재시도를 위해 큐에 다시 추가
        final service = AndroidBackgroundSyncService();
        await service.addToOfflineQueue(data);
      }
    }
  }

  /// 동기화 상태 확인
  bool get isOnline => _isOnline;
  bool get isInitialized => _isInitialized;

  /// 서비스 정리
  Future<void> dispose() async {
    await _networkStatusController.close();
    await _syncEventController.close();
  }
}
