import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'network_monitor_service.dart';
import 'speech_recognition_service.dart';

/// 오프라인 음성 인식 모드
enum OfflineSpeechMode {
  online, // 온라인 모드 (기본)
  offline, // 오프라인 모드
  hybrid, // 하이브리드 모드 (온라인 우선, 오프라인 대체)
}

/// 오프라인 음성 인식 결과
class OfflineSpeechResult {
  final String text;
  final double confidence;
  final DateTime timestamp;
  final bool isOffline;

  const OfflineSpeechResult({
    required this.text,
    required this.confidence,
    required this.timestamp,
    required this.isOffline,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'confidence': confidence,
    'timestamp': timestamp.toIso8601String(),
    'isOffline': isOffline,
  };

  factory OfflineSpeechResult.fromJson(Map<String, dynamic> json) {
    return OfflineSpeechResult(
      text: json['text'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isOffline: json['isOffline'] as bool,
    );
  }
}

/// 오프라인 음성 인식 서비스
/// 오프라인 환경에서 제한적인 음성 인식 기능을 제공
class OfflineSpeechService extends ChangeNotifier {
  static final OfflineSpeechService _instance =
      OfflineSpeechService._internal();

  factory OfflineSpeechService() => _instance;

  OfflineSpeechService._internal();

  final NetworkMonitorService _networkMonitor = NetworkMonitorService();
  final SpeechRecognitionService _speechService =
      SpeechRecognitionService.instance;

  OfflineSpeechMode _mode = OfflineSpeechMode.hybrid;
  bool _isInitialized = false;

  // 오프라인 인식 결과 캐시
  final List<OfflineSpeechResult> _resultCache = [];
  static const int _maxCacheSize = 100;

  // 오프라인 모드 제한사항
  static const List<String> _offlineLimitations = [
    '인터넷 연결이 필요합니다',
    '제한된 언어 지원 (한국어, 영어)',
    '낮은 인식 정확도',
    '실시간 처리가 제한됩니다',
    '복잡한 문장 인식이 어려울 수 있습니다',
  ];

  OfflineSpeechMode get mode => _mode;
  bool get isInitialized => _isInitialized;
  List<String> get limitations => List.unmodifiable(_offlineLimitations);
  List<OfflineSpeechResult> get resultCache => List.unmodifiable(_resultCache);

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('OfflineSpeechService 초기화 시작');

    // 네트워크 모니터 초기화
    await _networkMonitor.initialize();

    // 캐시된 결과 로드
    await _loadResultCache();

    // 네트워크 상태 변화 리스너 등록
    _networkMonitor.addListener(_onNetworkStatusChanged);

    _isInitialized = true;
    debugPrint('OfflineSpeechService 초기화 완료 - 모드: $_mode');
  }

  /// 서비스 종료
  @override
  void dispose() {
    _networkMonitor.removeListener(_onNetworkStatusChanged);
    super.dispose();
  }

  /// 네트워크 상태 변화 처리
  void _onNetworkStatusChanged() {
    debugPrint('네트워크 상태 변화 - 온라인: ${_networkMonitor.isOnline}');

    // 하이브리드 모드에서는 네트워크 상태에 따라 자동 전환
    if (_mode == OfflineSpeechMode.hybrid) {
      if (_networkMonitor.isOnline) {
        debugPrint('온라인 모드로 자동 전환');
      } else {
        debugPrint('오프라인 모드로 자동 전환');
      }
    }

    notifyListeners();
  }

  /// 음성 인식 모드 설정
  Future<void> setMode(OfflineSpeechMode mode) async {
    if (_mode == mode) return;

    _mode = mode;
    debugPrint('음성 인식 모드 변경: $mode');

    // 설정 저장
    await _saveMode();

    notifyListeners();
  }

  /// 음성 인식 시작
  Future<bool> startListening({
    Duration? listenFor,
    String? locale,
    Map<String, dynamic>? options,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // 현재 모드에 따른 처리
    switch (_mode) {
      case OfflineSpeechMode.online:
        return await _startOnlineListening(listenFor, locale, options);
      case OfflineSpeechMode.offline:
        return await _startOfflineListening(listenFor, locale, options);
      case OfflineSpeechMode.hybrid:
        if (_networkMonitor.isOnline) {
          return await _startOnlineListening(listenFor, locale, options);
        } else {
          return await _startOfflineListening(listenFor, locale, options);
        }
    }
  }

  /// 온라인 음성 인식 시작
  Future<bool> _startOnlineListening(
    Duration? listenFor,
    String? locale,
    Map<String, dynamic>? options,
  ) async {
    debugPrint('온라인 음성 인식 시작');

    try {
      return await _speechService.startListening(
        listenFor: listenFor,
        locale: locale,
      );
    } catch (e) {
      debugPrint('온라인 음성 인식 시작 실패: $e');

      // 하이브리드 모드에서는 오프라인으로 대체
      if (_mode == OfflineSpeechMode.hybrid) {
        debugPrint('오프라인 모드로 대체 시도');
        return await _startOfflineListening(listenFor, locale, options);
      }

      return false;
    }
  }

  /// 오프라인 음성 인식 시작
  Future<bool> _startOfflineListening(
    Duration? listenFor,
    String? locale,
    Map<String, dynamic>? options,
  ) async {
    debugPrint('오프라인 음성 인식 시작');

    // 오프라인 모드에서는 제한된 기능만 제공
    // 실제 구현에서는 로컬 음성 인식 엔진을 사용해야 함

    // 현재는 시뮬레이션으로 처리
    await _simulateOfflineRecognition();

    return true;
  }

  /// 오프라인 음성 인식 시뮬레이션
  Future<void> _simulateOfflineRecognition() async {
    // 실제 구현에서는 로컬 음성 인식 엔진을 사용
    // 현재는 캐시된 결과나 기본 응답을 반환

    final result = OfflineSpeechResult(
      text: '오프라인 모드에서는 제한된 음성 인식이 지원됩니다.',
      confidence: 0.5,
      timestamp: DateTime.now(),
      isOffline: true,
    );

    _addToCache(result);

    // 결과를 스트림으로 전송 (실제로는 SpeechRecognitionService의 내부 스트림을 사용)
    // 현재는 시뮬레이션이므로 실제 구현에서는 적절한 방법으로 결과를 전송해야 함
  }

  /// 음성 인식 중지
  Future<void> stopListening() async {
    await _speechService.stopListening();
  }

  /// 음성 인식 취소
  Future<void> cancelListening() async {
    await _speechService.cancelListening();
  }

  /// 결과를 캐시에 추가
  void _addToCache(OfflineSpeechResult result) {
    _resultCache.insert(0, result);

    // 캐시 크기 제한
    if (_resultCache.length > _maxCacheSize) {
      _resultCache.removeRange(_maxCacheSize, _resultCache.length);
    }

    // 캐시 저장
    _saveResultCache();
  }

  /// 캐시된 결과 로드
  Future<void> _loadResultCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString('offline_speech_cache');

      if (cacheJson != null) {
        final List<dynamic> cacheList = jsonDecode(cacheJson) as List<dynamic>;
        _resultCache.clear();
        _resultCache.addAll(
          cacheList.map(
            (json) =>
                OfflineSpeechResult.fromJson(json as Map<String, dynamic>),
          ),
        );
        debugPrint('오프라인 음성 인식 캐시 로드 완료: ${_resultCache.length}개');
      }
    } catch (e) {
      debugPrint('캐시 로드 실패: $e');
    }
  }

  /// 캐시 저장
  Future<void> _saveResultCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = jsonEncode(
        _resultCache.map((result) => result.toJson()).toList(),
      );
      await prefs.setString('offline_speech_cache', cacheJson);
    } catch (e) {
      debugPrint('캐시 저장 실패: $e');
    }
  }

  /// 모드 설정 저장
  Future<void> _saveMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('offline_speech_mode', _mode.name);
    } catch (e) {
      debugPrint('모드 설정 저장 실패: $e');
    }
  }

  /// 캐시 클리어
  Future<void> clearCache() async {
    _resultCache.clear();
    await _saveResultCache();
    notifyListeners();
  }

  /// 현재 모드에 따른 제한사항 메시지 반환
  String getLimitationMessage() {
    if (_mode == OfflineSpeechMode.offline ||
        (_mode == OfflineSpeechMode.hybrid && !_networkMonitor.isOnline)) {
      return '오프라인 모드: ${_offlineLimitations.join(', ')}';
    }
    return '온라인 모드: 모든 기능 사용 가능';
  }

  /// 현재 모드에 따른 상태 메시지 반환
  String getStatusMessage() {
    switch (_mode) {
      case OfflineSpeechMode.online:
        return _networkMonitor.isOnline ? '온라인 모드 (안정적)' : '온라인 모드 (연결 없음)';
      case OfflineSpeechMode.offline:
        return '오프라인 모드 (제한적)';
      case OfflineSpeechMode.hybrid:
        return _networkMonitor.isOnline ? '하이브리드 모드 (온라인)' : '하이브리드 모드 (오프라인)';
    }
  }
}
