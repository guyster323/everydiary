import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// 음성 인식 서비스
/// 음성을 텍스트로 변환하는 기능을 제공합니다.
class SpeechRecognitionService {
  static SpeechRecognitionService? _instance;
  static SpeechRecognitionService get instance =>
      _instance ??= SpeechRecognitionService._();

  SpeechRecognitionService._();

  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _currentLocale = 'ko-KR';

  // 스트림 컨트롤러
  final StreamController<SpeechRecognitionResultWrapper> _resultController =
      StreamController<SpeechRecognitionResultWrapper>.broadcast();
  final StreamController<SpeechRecognitionStatus> _statusController =
      StreamController<SpeechRecognitionStatus>.broadcast();

  // 스트림 getter
  Stream<SpeechRecognitionResultWrapper> get resultStream =>
      _resultController.stream;
  Stream<SpeechRecognitionStatus> get statusStream => _statusController.stream;

  /// 서비스 초기화
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // 마이크 권한 확인
      final hasPermission = await _checkMicrophonePermission();
      if (!hasPermission) {
        _statusController.add(SpeechRecognitionStatus.permissionDenied);
        return false;
      }

      // SpeechToText 초기화
      final available = await _speechToText.initialize(
        onError: (errorNotification) => _onError(errorNotification),
        onStatus: (status) => _onStatus(status),
        debugLogging: kDebugMode,
      );

      if (available) {
        _isInitialized = true;
        _statusController.add(SpeechRecognitionStatus.initialized);
        return true;
      } else {
        _statusController.add(SpeechRecognitionStatus.initializationFailed);
        return false;
      }
    } catch (e) {
      debugPrint('Speech recognition initialization error: $e');
      _statusController.add(SpeechRecognitionStatus.initializationFailed);
      return false;
    }
  }

  /// 마이크 권한 확인 및 요청
  Future<bool> _checkMicrophonePermission() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      // 설정으로 이동하도록 안내
      _statusController.add(
        SpeechRecognitionStatus.permissionPermanentlyDenied,
      );
      return false;
    }

    return false;
  }

  /// 음성 인식 시작
  Future<bool> startListening({
    String? locale,
    Duration? listenFor,
    Duration? pauseFor,
    bool partialResults = true,
    bool cancelOnError = true,
    stt.ListenMode listenMode = stt.ListenMode.confirmation,
    void Function(double)? onSoundLevelChange,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    if (_isListening) {
      await stopListening();
    }

    try {
      await _speechToText.listen(
        onResult: (result) => _onResult(result),
        localeId: locale ?? _currentLocale,
        listenFor: listenFor,
        pauseFor: pauseFor,
        // ignore: deprecated_member_use
        partialResults: partialResults,
        // ignore: deprecated_member_use
        cancelOnError: cancelOnError,
        // ignore: deprecated_member_use
        listenMode: listenMode,
        onSoundLevelChange: onSoundLevelChange,
      );

      _isListening = true;
      _statusController.add(SpeechRecognitionStatus.listening);
      return true;
    } catch (e) {
      debugPrint('Start listening error: $e');
      _statusController.add(SpeechRecognitionStatus.startFailed);
      return false;
    }
  }

  /// 음성 인식 중지
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.stop();
      _isListening = false;
      _statusController.add(SpeechRecognitionStatus.stopped);
    } catch (e) {
      debugPrint('Stop listening error: $e');
      _statusController.add(SpeechRecognitionStatus.stopFailed);
    }
  }

  /// 음성 인식 취소
  Future<void> cancelListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.cancel();
      _isListening = false;
      _statusController.add(SpeechRecognitionStatus.cancelled);
    } catch (e) {
      debugPrint('Cancel listening error: $e');
      _statusController.add(SpeechRecognitionStatus.cancelFailed);
    }
  }

  /// 사용 가능한 언어 목록 조회
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }

    return _speechToText.locales();
  }

  /// 현재 언어 설정
  void setLocale(String locale) {
    _currentLocale = locale;
  }

  /// 현재 언어 조회
  String get currentLocale => _currentLocale;

  /// 음성 인식 상태 조회
  bool get isListening => _isListening;

  /// 초기화 상태 조회
  bool get isInitialized => _isInitialized;

  /// 음성 인식 결과 콜백
  void _onResult(dynamic result) {
    final wrappedResult = SpeechRecognitionResultWrapper.fromSpeechResult(
      result,
    );
    _resultController.add(wrappedResult);

    if (result.finalResult == true) {
      _isListening = false;
      _statusController.add(SpeechRecognitionStatus.completed);
    }
  }

  /// 음성 인식 상태 콜백
  void _onStatus(String status) {
    switch (status) {
      case 'listening':
        _statusController.add(SpeechRecognitionStatus.listening);
        break;
      case 'notListening':
        if (_isListening) {
          _isListening = false;
          _statusController.add(SpeechRecognitionStatus.stopped);
        }
        break;
      case 'done':
        _isListening = false;
        _statusController.add(SpeechRecognitionStatus.completed);
        break;
      case 'error':
        _isListening = false;
        _statusController.add(SpeechRecognitionStatus.error);
        break;
    }
  }

  /// 오류 콜백
  void _onError(dynamic error) {
    final errorMessage = error?.errorMsg ?? error.toString();
    debugPrint('Speech recognition error: $errorMessage');

    _isListening = false;
    _statusController.add(SpeechRecognitionStatus.error);

    // 에러 타입별 처리
    final message = errorMessage.toString();
    if (message.contains('timeout')) {
      debugPrint(
        'Speech recognition timeout - consider increasing listen duration',
      );
    } else if (message.contains('network')) {
      debugPrint('Network error - check internet connection');
    } else if (message.contains('permission')) {
      debugPrint('Permission error - microphone access denied');
    }
  }

  /// 서비스 정리
  void dispose() {
    _resultController.close();
    _statusController.close();
    _speechToText.cancel();
  }
}

/// 음성 인식 결과 래퍼 클래스
class SpeechRecognitionResultWrapper {
  final String recognizedWords;
  final bool finalResult;
  final double confidence;
  final List<dynamic> alternates;

  const SpeechRecognitionResultWrapper({
    required this.recognizedWords,
    required this.finalResult,
    required this.confidence,
    required this.alternates,
  });

  factory SpeechRecognitionResultWrapper.fromSpeechResult(
    dynamic speechResult,
  ) {
    return SpeechRecognitionResultWrapper(
      recognizedWords: (speechResult?.recognizedWords ?? '').toString(),
      finalResult: (speechResult?.finalResult ?? false) as bool,
      confidence:
          double.tryParse(speechResult?.confidence?.toString() ?? '0.0') ?? 0.0,
      alternates: (speechResult?.alternates as List<dynamic>?) ?? <dynamic>[],
    );
  }

  bool get isFinal => finalResult;
}

/// 음성 인식 상태 열거형
enum SpeechRecognitionStatus {
  uninitialized,
  initialized,
  initializationFailed,
  permissionDenied,
  permissionPermanentlyDenied,
  listening,
  stopped,
  completed,
  cancelled,
  error,
  startFailed,
  stopFailed,
  cancelFailed,
}

/// 음성 인식 설정 클래스
class SpeechRecognitionConfig {
  final String locale;
  final Duration? listenFor;
  final Duration? pauseFor;
  final bool partialResults;
  final bool onSoundLevelChange;
  final bool cancelOnError;
  final stt.ListenMode listenMode;

  const SpeechRecognitionConfig({
    this.locale = 'ko-KR',
    this.listenFor,
    this.pauseFor,
    this.partialResults = true,
    this.onSoundLevelChange = false,
    this.cancelOnError = true,
    this.listenMode = stt.ListenMode.confirmation,
  });
}
