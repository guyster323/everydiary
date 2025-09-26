import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// 네트워크 상태 감지 서비스
class NetworkStatusService {
  static final NetworkStatusService _instance =
      NetworkStatusService._internal();
  factory NetworkStatusService() => _instance;
  NetworkStatusService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // 네트워크 상태 스트림
  final StreamController<bool> _networkStatusController =
      StreamController<bool>.broadcast();
  Stream<bool> get networkStatusStream => _networkStatusController.stream;

  // 현재 네트워크 상태
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  // 마지막 연결 상태
  ConnectivityResult? _lastConnectivityResult;
  ConnectivityResult? get lastConnectivityResult => _lastConnectivityResult;

  /// 네트워크 상태 서비스 초기화
  Future<void> initialize() async {
    try {
      debugPrint('🌐 네트워크 상태 서비스 초기화 시작');

      // 초기 연결 상태 확인
      await _checkInitialConnectivity();

      // 연결 상태 변경 감지 시작
      _startConnectivityMonitoring();

      debugPrint('✅ 네트워크 상태 서비스 초기화 완료');
    } catch (e) {
      debugPrint('❌ 네트워크 상태 서비스 초기화 실패: $e');
    }
  }

  /// 초기 연결 상태 확인
  Future<void> _checkInitialConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      await _updateNetworkStatus(connectivityResults);
    } catch (e) {
      debugPrint('❌ 초기 연결 상태 확인 실패: $e');
      // 오류 시 온라인으로 가정
      _updateOnlineStatus(true);
    }
  }

  /// 연결 상태 모니터링 시작
  void _startConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateNetworkStatus,
      onError: (Object error) {
        debugPrint('❌ 연결 상태 모니터링 오류: $error');
      },
    );
  }

  /// 네트워크 상태 업데이트
  Future<void> _updateNetworkStatus(List<ConnectivityResult> results) async {
    try {
      final isConnected = await _isActuallyConnected(results);
      _lastConnectivityResult = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;

      if (_isOnline != isConnected) {
        _isOnline = isConnected;
        _updateOnlineStatus(isConnected);

        debugPrint('🌐 네트워크 상태 변경: ${isConnected ? "온라인" : "오프라인"}');
      }
    } catch (e) {
      debugPrint('❌ 네트워크 상태 업데이트 실패: $e');
    }
  }

  /// 실제 연결 상태 확인
  Future<bool> _isActuallyConnected(List<ConnectivityResult> results) async {
    try {
      // 연결 결과가 없으면 오프라인
      if (results.isEmpty) return false;

      // none 결과가 있으면 오프라인
      if (results.contains(ConnectivityResult.none)) return false;

      // 웹 환경에서는 connectivity_plus만으로 충분
      if (kIsWeb) {
        return results.any((result) => result != ConnectivityResult.none);
      }

      // 모바일 환경에서는 실제 연결 테스트
      if (Platform.isAndroid || Platform.isIOS) {
        return await _testActualConnection();
      }

      // 기타 플랫폼
      return results.any((result) => result != ConnectivityResult.none);
    } catch (e) {
      debugPrint('❌ 실제 연결 상태 확인 실패: $e');
      return false;
    }
  }

  /// 실제 연결 테스트 (모바일용)
  Future<bool> _testActualConnection() async {
    try {
      // 간단한 연결 테스트를 위해 Google DNS에 핑
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 온라인 상태 업데이트
  void _updateOnlineStatus(bool isOnline) {
    _networkStatusController.add(isOnline);
  }

  /// 수동으로 네트워크 상태 확인
  Future<bool> checkNetworkStatus() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final isConnected = await _isActuallyConnected(connectivityResults);

      if (_isOnline != isConnected) {
        _isOnline = isConnected;
        _updateOnlineStatus(isConnected);
      }

      return isConnected;
    } catch (e) {
      debugPrint('❌ 수동 네트워크 상태 확인 실패: $e');
      return false;
    }
  }

  /// 네트워크 상태 정보 가져오기
  Map<String, dynamic> getNetworkInfo() {
    return {
      'isOnline': _isOnline,
      'lastConnectivityResult': _lastConnectivityResult?.toString(),
      'connectionType': _getConnectionTypeString(),
    };
  }

  /// 연결 타입 문자열 반환
  String _getConnectionTypeString() {
    if (_lastConnectivityResult == null) return 'unknown';

    switch (_lastConnectivityResult!) {
      case ConnectivityResult.wifi:
        return 'wifi';
      case ConnectivityResult.mobile:
        return 'mobile';
      case ConnectivityResult.ethernet:
        return 'ethernet';
      case ConnectivityResult.bluetooth:
        return 'bluetooth';
      case ConnectivityResult.vpn:
        return 'vpn';
      case ConnectivityResult.other:
        return 'other';
      case ConnectivityResult.none:
        return 'none';
    }
  }

  /// 네트워크 상태 서비스 정리
  void dispose() {
    _connectivitySubscription?.cancel();
    _networkStatusController.close();
    debugPrint('🗑️ 네트워크 상태 서비스 정리 완료');
  }
}
