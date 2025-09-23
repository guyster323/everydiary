import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// 네트워크 연결 상태
enum NetworkStatus { connected, disconnected, unknown }

/// 네트워크 연결 타입
enum NetworkType { wifi, mobile, ethernet, bluetooth, vpn, other, none }

/// 네트워크 모니터링 서비스
/// 네트워크 연결 상태를 실시간으로 모니터링하고 상태 변화를 알림
class NetworkMonitorService extends ChangeNotifier {
  static final NetworkMonitorService _instance =
      NetworkMonitorService._internal();

  factory NetworkMonitorService() => _instance;

  NetworkMonitorService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  NetworkStatus _status = NetworkStatus.unknown;
  NetworkType _type = NetworkType.none;
  bool _isOnline = false;

  // 네트워크 상태 체크 간격
  static const Duration _checkInterval = Duration(seconds: 5);
  Timer? _checkTimer;

  NetworkStatus get status => _status;
  NetworkType get type => _type;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  /// 서비스 초기화
  Future<void> initialize() async {
    debugPrint('NetworkMonitorService 초기화 시작');

    // 초기 네트워크 상태 확인
    await _checkNetworkStatus();

    // 네트워크 상태 변화 리스너 등록
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (Object error) {
        debugPrint('네트워크 상태 모니터링 오류: $error');
      },
    );

    // 주기적 네트워크 상태 체크 시작
    _startPeriodicCheck();

    debugPrint('NetworkMonitorService 초기화 완료 - 상태: $_status, 온라인: $_isOnline');
  }

  /// 서비스 종료
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _checkTimer?.cancel();
    super.dispose();
  }

  /// 네트워크 상태 변화 처리
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    debugPrint('네트워크 상태 변화 감지: $results');
    _updateNetworkStatus(results);
  }

  /// 주기적 네트워크 상태 체크 시작
  void _startPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(_checkInterval, (_) async {
      await _checkNetworkStatus();
    });
  }

  /// 네트워크 상태 확인
  Future<void> _checkNetworkStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateNetworkStatus(results);

      // 실제 인터넷 연결 확인 (ping 테스트)
      await _verifyInternetConnection();
    } catch (e) {
      debugPrint('네트워크 상태 확인 실패: $e');
      _setOfflineStatus();
    }
  }

  /// 네트워크 상태 업데이트
  void _updateNetworkStatus(List<ConnectivityResult> results) {
    final previousStatus = _status;
    final previousType = _type;
    final previousOnline = _isOnline;

    if (results.isEmpty) {
      _setOfflineStatus();
    } else {
      final result = results.first;
      _type = _mapConnectivityResultToNetworkType(result);
      _status = NetworkStatus.connected;
      _isOnline = true;
    }

    // 상태 변화가 있을 때만 알림
    if (previousStatus != _status ||
        previousType != _type ||
        previousOnline != _isOnline) {
      debugPrint('네트워크 상태 업데이트: $_status, 타입: $_type, 온라인: $_isOnline');
      notifyListeners();
    }
  }

  /// 오프라인 상태 설정
  void _setOfflineStatus() {
    _status = NetworkStatus.disconnected;
    _type = NetworkType.none;
    _isOnline = false;
  }

  /// ConnectivityResult를 NetworkType으로 매핑
  NetworkType _mapConnectivityResultToNetworkType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return NetworkType.wifi;
      case ConnectivityResult.mobile:
        return NetworkType.mobile;
      case ConnectivityResult.ethernet:
        return NetworkType.ethernet;
      case ConnectivityResult.bluetooth:
        return NetworkType.bluetooth;
      case ConnectivityResult.vpn:
        return NetworkType.vpn;
      case ConnectivityResult.other:
        return NetworkType.other;
      case ConnectivityResult.none:
        return NetworkType.none;
    }
  }

  /// 실제 인터넷 연결 확인 (ping 테스트)
  Future<void> _verifyInternetConnection() async {
    try {
      // Google DNS에 ping 테스트
      final result = await InternetAddress.lookup('8.8.8.8');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // 실제로는 연결되어 있지만 ConnectivityResult가 none인 경우
        if (_status == NetworkStatus.disconnected) {
          _status = NetworkStatus.connected;
          _isOnline = true;
          notifyListeners();
        }
      }
    } catch (e) {
      // 인터넷 연결이 실제로 없는 경우
      if (_status == NetworkStatus.connected) {
        _setOfflineStatus();
        notifyListeners();
      }
    }
  }

  /// 수동으로 네트워크 상태 새로고침
  Future<void> refresh() async {
    await _checkNetworkStatus();
  }

  /// 네트워크 타입별 속도 추정
  double getEstimatedSpeed() {
    switch (_type) {
      case NetworkType.wifi:
        return 50.0; // Mbps
      case NetworkType.mobile:
        return 10.0; // Mbps
      case NetworkType.ethernet:
        return 100.0; // Mbps
      case NetworkType.bluetooth:
        return 1.0; // Mbps
      case NetworkType.vpn:
        return 5.0; // Mbps
      case NetworkType.other:
        return 2.0; // Mbps
      case NetworkType.none:
        return 0.0; // Mbps
    }
  }

  /// 음성 인식에 적합한 네트워크 상태인지 확인
  bool get isSuitableForSpeechRecognition {
    if (!_isOnline) return false;

    // 오프라인 모드에서는 항상 적합
    return true;
  }

  /// 실시간 음성 인식에 적합한 네트워크 상태인지 확인
  bool get isSuitableForRealTimeSpeechRecognition {
    if (!_isOnline) return false;

    // 실시간 처리를 위해서는 안정적인 연결이 필요
    return _type == NetworkType.wifi || _type == NetworkType.ethernet;
  }
}
