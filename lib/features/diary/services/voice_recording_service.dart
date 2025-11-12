import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// 지속적이고 누적형 음성녹음 서비스
class VoiceRecordingService {
  static final VoiceRecordingService _instance =
      VoiceRecordingService._internal();
  factory VoiceRecordingService() => _instance;
  VoiceRecordingService._internal();

  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isStopped = false; // 사용자가 직접 중지했는지 확인
  String _accumulatedText = ''; // 완전히 누적된 텍스트
  String _currentPartialText = ''; // 현재 인식 중인 부분 텍스트
  Timer? _recordingTimer;
  Timer? _restartTimer;
  int _recordingDuration = 0;
  int _sessionCount = 0; // 세션 재시작 횟수 추적
  String _currentLocale = 'ko_KR'; // 현재 언어 설정

  // 콜백 함수들
  void Function(String)? onResult;
  void Function(int)? onDuration;
  void Function()? onStatusChanged;
  void Function(String)? onError;
  void Function()? onStop;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get accumulatedText => _accumulatedText;
  String get currentPartialText => _currentPartialText;
  int get recordingDuration => _recordingDuration;
  int get sessionCount => _sessionCount;
  String get currentLocale => _currentLocale;

  /// 언어 설정
  void setLocale(String locale) {
    _currentLocale = locale;
    debugPrint('🎤 음성인식 언어 설정: $locale');
  }

  /// 음성인식 초기화
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // 마이크 권한 요청
      final micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        debugPrint('🎤 마이크 권한이 거부되었습니다.');
        onError?.call('마이크 권한이 필요합니다.');
        return false;
      }

      // 음성인식 초기화
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          debugPrint('🎤 음성인식 오류: ${error.errorMsg}');
          _handleSpeechError(error.errorMsg);
        },
        onStatus: (status) {
          debugPrint('🎤 음성인식 상태: $status');
          _handleStatusChange(status);
        },
      );

      if (_isInitialized) {
        debugPrint('🎤 음성인식 서비스 초기화 완료');
      }

      return _isInitialized;
    } catch (e) {
      debugPrint('🎤 음성인식 초기화 실패: $e');
      onError?.call('음성인식 초기화에 실패했습니다: $e');
      return false;
    }
  }

  /// 지속적인 음성녹음 시작
  Future<bool> startContinuousListening({
    required void Function(String) onResult,
    required void Function(int) onDuration,
    void Function()? onStatusChanged,
    void Function(String)? onError,
    void Function()? onStop,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    if (_isListening) {
      debugPrint('🎤 이미 녹음 중입니다.');
      return false;
    }

    try {
      // 콜백 함수 설정
      this.onResult = onResult;
      this.onDuration = onDuration;
      this.onStatusChanged = onStatusChanged;
      this.onError = onError;
      this.onStop = onStop;

      // 상태 초기화
      _isListening = true;
      _isStopped = false;
      _accumulatedText = '';
      _currentPartialText = '';
      _recordingDuration = 0;
      _sessionCount = 0;

      debugPrint('🎤 지속적인 음성녹음 시작');

      // 녹음 시간 타이머 시작
      _startRecordingTimer();

      // 첫 번째 리스닝 세션 시작
      return await _startListeningSession();
    } catch (e) {
      debugPrint('🎤 음성녹음 시작 실패: $e');
      _isListening = false;
      onError?.call('음성녹음 시작에 실패했습니다: $e');
      return false;
    }
  }

  /// 개별 리스닝 세션 시작
  Future<bool> _startListeningSession() async {
    if (!_isListening || _isStopped) return false;

    try {
      _sessionCount++;
      debugPrint('🎤 리스닝 세션 #$_sessionCount 시작');

      await _speechToText.listen(
        onResult: (result) {
          _handleSpeechResult(result);
        },
        localeId: _currentLocale,
        listenFor: const Duration(minutes: 10), // 매우 긴 시간 설정
        pauseFor: const Duration(seconds: 3), // 짧은 일시정지 허용
      );

      onStatusChanged?.call();
      return true;
    } catch (e) {
      debugPrint('🎤 리스닝 세션 시작 실패: $e');

      // 재시도 로직
      if (_isListening && !_isStopped) {
        _scheduleRestart('세션 시작 실패로 인한 재시작');
      }

      return false;
    }
  }

  /// 음성 인식 결과 처리
  void _handleSpeechResult(dynamic result) {
    if (!_isListening || _isStopped) return;

    final recognizedWords = result.recognizedWords as String;

    if (recognizedWords.isNotEmpty) {
      _currentPartialText = recognizedWords;

      // 현재까지의 전체 텍스트 생성
      final String fullText = _buildFullText();

      debugPrint('🎤 인식 결과 (final: ${result.finalResult}): $recognizedWords');
      debugPrint('🎤 전체 텍스트: $fullText');

      // 콜백으로 결과 전달
      onResult?.call(fullText);

      // 최종 결과인 경우 누적 텍스트에 추가
      if ((result.finalResult as bool) && recognizedWords.trim().isNotEmpty) {
        _addToAccumulatedText(recognizedWords);
        _currentPartialText = ''; // 부분 텍스트 초기화

        debugPrint('🎤 누적 텍스트에 추가됨: $_accumulatedText');

        // 자동으로 다음 세션 준비 (매우 짧은 딜레이)
        _scheduleRestart(
          '최종 결과 처리 후 자동 재시작',
          const Duration(milliseconds: 100),
        );
      }
    }
  }

  /// 누적 텍스트에 새로운 내용 추가
  void _addToAccumulatedText(String newText) {
    if (newText.trim().isEmpty) return;

    if (_accumulatedText.isEmpty) {
      _accumulatedText = newText.trim();
    } else {
      // 기존 텍스트가 문장 끝으로 끝나면 줄바꿈, 아니면 공백
      if (_accumulatedText.endsWith('.') ||
          _accumulatedText.endsWith('!') ||
          _accumulatedText.endsWith('?') ||
          _accumulatedText.endsWith('다') ||
          _accumulatedText.endsWith('요')) {
        _accumulatedText = '$_accumulatedText\n${newText.trim()}';
      } else {
        _accumulatedText = '$_accumulatedText ${newText.trim()}';
      }
    }
  }

  /// 현재까지의 전체 텍스트 생성 (누적 + 현재 부분)
  String _buildFullText() {
    if (_accumulatedText.isEmpty) {
      return _currentPartialText;
    }

    if (_currentPartialText.isEmpty) {
      return _accumulatedText;
    }

    // 누적 텍스트와 현재 부분 텍스트 결합
    if (_accumulatedText.endsWith('.') ||
        _accumulatedText.endsWith('!') ||
        _accumulatedText.endsWith('?') ||
        _accumulatedText.endsWith('다') ||
        _accumulatedText.endsWith('요')) {
      return '$_accumulatedText\n$_currentPartialText';
    } else {
      return '$_accumulatedText $_currentPartialText';
    }
  }

  /// 상태 변화 처리
  void _handleStatusChange(String status) {
    debugPrint('🎤 상태 변화: $status');

    switch (status) {
      case 'done':
      case 'notListening':
        if (_isListening && !_isStopped) {
          debugPrint('🎤 음성인식이 자동으로 중단됨, 재시작 준비');
          _scheduleRestart('자동 중단으로 인한 재시작');
        }
        break;

      case 'listening':
        debugPrint('🎤 음성인식 활성화됨');
        break;

      default:
        break;
    }

    onStatusChanged?.call();
  }

  /// 음성인식 오류 처리
  void _handleSpeechError(String errorMsg) {
    debugPrint('🎤 음성인식 오류: $errorMsg');

    // 특정 오류들은 재시작으로 해결 시도
    if (errorMsg.contains('error_no_match') ||
        errorMsg.contains('error_speech_timeout')) {
      if (_isListening && !_isStopped) {
        debugPrint('🎤 일시적 오류로 판단, 재시작 시도');
        _scheduleRestart('오류로 인한 재시작: $errorMsg');
      }
    } else if (errorMsg.contains('error_busy')) {
      // 리소스 사용 중 오류 - 잠시 대기 후 재시작
      if (_isListening && !_isStopped) {
        debugPrint('🎤 리소스 사용 중, 대기 후 재시작');
        _scheduleRestart('리소스 충돌로 인한 재시작', const Duration(milliseconds: 500));
      }
    } else {
      // 심각한 오류는 사용자에게 알림
      onError?.call(errorMsg);
    }
  }

  /// 재시작 스케줄링
  void _scheduleRestart(
    String reason, [
    Duration delay = const Duration(milliseconds: 200),
  ]) {
    if (!_isListening || _isStopped) return;

    debugPrint('🎤 재시작 스케줄링: $reason (지연: ${delay.inMilliseconds}ms)');

    _restartTimer?.cancel();
    _restartTimer = Timer(delay, () {
      if (_isListening && !_isStopped) {
        _restartListeningSession();
      }
    });
  }

  /// 리스닝 세션 재시작
  Future<void> _restartListeningSession() async {
    if (!_isListening || _isStopped) return;

    try {
      debugPrint('🎤 리스닝 세션 재시작 중...');

      // 현재 세션 정리
      await _speechToText.stop();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // 새 세션 시작
      if (_isListening && !_isStopped) {
        await _startListeningSession();
      }
    } catch (e) {
      debugPrint('🎤 리스닝 세션 재시작 실패: $e');

      // 재시작도 실패하면 잠시 대기 후 다시 시도
      if (_isListening && !_isStopped) {
        _scheduleRestart('재시작 실패로 인한 재시도', const Duration(seconds: 1));
      }
    }
  }

  /// 녹음 시간 타이머 시작
  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isListening && !_isStopped) {
        _recordingDuration++;
        onDuration?.call(_recordingDuration);
      } else {
        timer.cancel();
      }
    });
  }

  /// 음성녹음 완전히 중지 (사용자 요청)
  Future<void> stopListening() async {
    debugPrint('🎤 사용자 요청으로 음성녹음 중지');

    _isStopped = true;
    _isListening = false;

    // 모든 타이머 정리
    _recordingTimer?.cancel();
    _restartTimer?.cancel();

    try {
      // 음성인식 중지
      await _speechToText.stop();
      await _speechToText.cancel();
    } catch (e) {
      debugPrint('🎤 음성인식 중지 중 오류: $e');
    }

    // 최종 결과 처리
    final String finalText = _buildFullText();
    if (finalText.isNotEmpty) {
      onResult?.call(finalText);
    }

    debugPrint('🎤 음성녹음 완전히 중지됨');
    debugPrint('🎤 최종 누적 텍스트: $_accumulatedText');
    debugPrint('🎤 총 세션 수: $_sessionCount');
    debugPrint('🎤 총 녹음 시간: $_recordingDuration초');

    onStop?.call();
  }

  /// 현재까지의 전체 텍스트 반환
  String getFullText() {
    return _buildFullText();
  }

  /// 서비스 정리
  void dispose() {
    debugPrint('🎤 음성녹음 서비스 정리');

    _recordingTimer?.cancel();
    _restartTimer?.cancel();

    try {
      _speechToText.cancel();
    } catch (e) {
      debugPrint('🎤 음성인식 취소 중 오류: $e');
    }

    _isListening = false;
    _isStopped = true;
    _accumulatedText = '';
    _currentPartialText = '';
    _recordingDuration = 0;
    _sessionCount = 0;
  }

  /// 디버깅용 상태 정보
  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized,
      'isListening': _isListening,
      'isStopped': _isStopped,
      'accumulatedText': _accumulatedText,
      'currentPartialText': _currentPartialText,
      'recordingDuration': _recordingDuration,
      'sessionCount': _sessionCount,
    };
  }
}
