import 'dart:async';

import 'package:flutter/foundation.dart';

import 'network_status_service.dart';

/// 오프라인 상태 관리자
class OfflineStateManager {
  static final OfflineStateManager _instance = OfflineStateManager._internal();
  factory OfflineStateManager() => _instance;
  OfflineStateManager._internal();

  final NetworkStatusService _networkService = NetworkStatusService();

  // 상태 관리
  bool _isInitialized = false;
  bool _isOfflineMode = false;
  bool _isOfflineModeForced = false;
  DateTime? _lastOnlineTime;
  DateTime? _lastOfflineTime;

  // 상태 스트림
  final StreamController<OfflineState> _stateController =
      StreamController<OfflineState>.broadcast();
  Stream<OfflineState> get stateStream => _stateController.stream;

  // 현재 상태
  OfflineState get currentState => _buildCurrentState();

  // 네트워크 상태 구독
  StreamSubscription<bool>? _networkSubscription;

  /// 오프라인 상태 관리자 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 오프라인 상태 관리자 초기화 시작');

      // 네트워크 서비스 초기화
      await _networkService.initialize();

      // 네트워크 상태 구독
      _networkSubscription = _networkService.networkStatusStream.listen(
        _handleNetworkStatusChange,
        onError: (Object error) {
          debugPrint('❌ 네트워크 상태 구독 오류: $error');
        },
      );

      _isInitialized = true;
      debugPrint('✅ 오프라인 상태 관리자 초기화 완료');
    } catch (e) {
      debugPrint('❌ 오프라인 상태 관리자 초기화 실패: $e');
    }
  }

  /// 네트워크 상태 변경 처리
  void _handleNetworkStatusChange(bool isOnline) {
    try {
      final wasOffline = _isOfflineMode;
      _isOfflineMode = !isOnline;

      if (isOnline) {
        _lastOnlineTime = DateTime.now();
      } else {
        _lastOfflineTime = DateTime.now();
      }

      // 상태 변경 알림
      _stateController.add(_buildCurrentState());

      // 오프라인 모드 진입/해제 로그
      if (!wasOffline && _isOfflineMode) {
        debugPrint('📱 오프라인 모드 진입');
        _onOfflineModeEntered();
      } else if (wasOffline && !_isOfflineMode) {
        debugPrint('🌐 온라인 모드 복귀');
        _onOnlineModeRestored();
      }
    } catch (e) {
      debugPrint('❌ 네트워크 상태 변경 처리 실패: $e');
    }
  }

  /// 오프라인 모드 진입 처리
  void _onOfflineModeEntered() {
    // 오프라인 모드 진입 시 필요한 작업들
    // 예: 캐시 활성화, 동기화 큐 활성화 등
  }

  /// 온라인 모드 복귀 처리
  void _onOnlineModeRestored() {
    // 온라인 모드 복귀 시 필요한 작업들
    // 예: 자동 동기화 시작, 캐시 업데이트 등
  }

  /// 현재 상태 빌드
  OfflineState _buildCurrentState() {
    return OfflineState(
      isOnline: !_isOfflineMode,
      isOfflineMode: _isOfflineMode,
      isOfflineModeForced: _isOfflineModeForced,
      lastOnlineTime: _lastOnlineTime,
      lastOfflineTime: _lastOfflineTime,
      networkInfo: _networkService.getNetworkInfo(),
    );
  }

  /// 오프라인 모드 강제 설정
  void setOfflineModeForced(bool forced) {
    _isOfflineModeForced = forced;
    _stateController.add(_buildCurrentState());

    debugPrint('🔧 오프라인 모드 강제 설정: $forced');
  }

  /// 수동으로 네트워크 상태 확인
  Future<bool> checkNetworkStatus() async {
    try {
      return await _networkService.checkNetworkStatus();
    } catch (e) {
      debugPrint('❌ 수동 네트워크 상태 확인 실패: $e');
      return false;
    }
  }

  /// 오프라인 상태 정보 가져오기
  Map<String, dynamic> getOfflineStateInfo() {
    return {
      'isOnline': !_isOfflineMode,
      'isOfflineMode': _isOfflineMode,
      'isOfflineModeForced': _isOfflineModeForced,
      'lastOnlineTime': _lastOnlineTime?.toIso8601String(),
      'lastOfflineTime': _lastOfflineTime?.toIso8601String(),
      'networkInfo': _networkService.getNetworkInfo(),
      'offlineDuration': _getOfflineDuration(),
    };
  }

  /// 오프라인 지속 시간 계산
  Duration? _getOfflineDuration() {
    if (_lastOfflineTime == null || !_isOfflineMode) return null;
    return DateTime.now().difference(_lastOfflineTime!);
  }

  /// 오프라인 상태 관리자 정리
  void dispose() {
    _networkSubscription?.cancel();
    _stateController.close();
    _networkService.dispose();
    debugPrint('🗑️ 오프라인 상태 관리자 정리 완료');
  }
}

/// 오프라인 상태 정보
class OfflineState {
  final bool isOnline;
  final bool isOfflineMode;
  final bool isOfflineModeForced;
  final DateTime? lastOnlineTime;
  final DateTime? lastOfflineTime;
  final Map<String, dynamic> networkInfo;

  const OfflineState({
    required this.isOnline,
    required this.isOfflineMode,
    required this.isOfflineModeForced,
    this.lastOnlineTime,
    this.lastOfflineTime,
    required this.networkInfo,
  });

  /// 오프라인 지속 시간
  Duration? get offlineDuration {
    if (lastOfflineTime == null || isOnline) return null;
    return DateTime.now().difference(lastOfflineTime!);
  }

  /// 온라인 지속 시간
  Duration? get onlineDuration {
    if (lastOnlineTime == null || !isOnline) return null;
    return DateTime.now().difference(lastOnlineTime!);
  }

  /// 네트워크 연결 타입
  String get connectionType {
    return networkInfo['connectionType'] as String? ?? 'unknown';
  }

  /// 상태 요약
  Map<String, dynamic> toMap() {
    return {
      'isOnline': isOnline,
      'isOfflineMode': isOfflineMode,
      'isOfflineModeForced': isOfflineModeForced,
      'lastOnlineTime': lastOnlineTime?.toIso8601String(),
      'lastOfflineTime': lastOfflineTime?.toIso8601String(),
      'offlineDuration': offlineDuration?.inSeconds,
      'onlineDuration': onlineDuration?.inSeconds,
      'connectionType': connectionType,
      'networkInfo': networkInfo,
    };
  }

  @override
  String toString() {
    return 'OfflineState(isOnline: $isOnline, isOfflineMode: $isOfflineMode, connectionType: $connectionType)';
  }
}
