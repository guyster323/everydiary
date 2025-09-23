import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../services/permission_service.dart';
import '../services/speech_recognition_service.dart';

/// 음성 인식 서비스 프로바이더
final speechRecognitionServiceProvider = Provider<SpeechRecognitionService>((
  ref,
) {
  return SpeechRecognitionService.instance;
});

/// 권한 서비스 프로바이더
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService.instance;
});

/// 음성 인식 상태 프로바이더
class SpeechRecognitionState {
  final bool isInitialized;
  final bool isListening;
  final SpeechRecognitionStatus status;
  final String currentText;
  final String finalText;
  final double confidence;
  final String? errorMessage;
  final String currentLocale;

  const SpeechRecognitionState({
    this.isInitialized = false,
    this.isListening = false,
    this.status = SpeechRecognitionStatus.uninitialized,
    this.currentText = '',
    this.finalText = '',
    this.confidence = 0.0,
    this.errorMessage,
    this.currentLocale = 'ko-KR',
  });

  SpeechRecognitionState copyWith({
    bool? isInitialized,
    bool? isListening,
    SpeechRecognitionStatus? status,
    String? currentText,
    String? finalText,
    double? confidence,
    String? errorMessage,
    String? currentLocale,
  }) {
    return SpeechRecognitionState(
      isInitialized: isInitialized ?? this.isInitialized,
      isListening: isListening ?? this.isListening,
      status: status ?? this.status,
      currentText: currentText ?? this.currentText,
      finalText: finalText ?? this.finalText,
      confidence: confidence ?? this.confidence,
      errorMessage: errorMessage,
      currentLocale: currentLocale ?? this.currentLocale,
    );
  }
}

/// 음성 인식 상태 관리 프로바이더
class SpeechRecognitionNotifier extends StateNotifier<SpeechRecognitionState> {
  final SpeechRecognitionService _speechService;
  final PermissionService _permissionService;

  SpeechRecognitionNotifier(this._speechService, this._permissionService)
    : super(const SpeechRecognitionState()) {
    _initialize();
  }

  /// 서비스 초기화
  Future<void> _initialize() async {
    try {
      final initialized = await _speechService.initialize();
      if (initialized) {
        state = state.copyWith(
          isInitialized: true,
          status: SpeechRecognitionStatus.initialized,
        );
      } else {
        state = state.copyWith(
          status: SpeechRecognitionStatus.initializationFailed,
          errorMessage: '음성 인식 서비스 초기화에 실패했습니다.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: SpeechRecognitionStatus.initializationFailed,
        errorMessage: '초기화 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 음성 인식 시작
  Future<bool> startListening({
    String? locale,
    Duration? listenDuration,
    Duration? pauseFor,
    bool? partialResults,
    bool? cancelOnError,
    stt.ListenMode? listenMode,
  }) async {
    if (!state.isInitialized) {
      await _initialize();
      if (!state.isInitialized) return false;
    }

    // 권한 확인
    final hasPermission = await _permissionService
        .isMicrophonePermissionGranted();
    if (!hasPermission) {
      state = state.copyWith(
        status: SpeechRecognitionStatus.permissionDenied,
        errorMessage: '마이크 권한이 필요합니다.',
      );
      return false;
    }

    try {
      final success = await _speechService.startListening(
        locale: locale ?? state.currentLocale,
        listenFor: listenDuration,
        pauseFor: pauseFor,
        partialResults: partialResults ?? true,
        cancelOnError: cancelOnError ?? true,
        listenMode: listenMode ?? stt.ListenMode.confirmation,
      );

      if (success) {
        state = state.copyWith(
          isListening: true,
          status: SpeechRecognitionStatus.listening,
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          status: SpeechRecognitionStatus.startFailed,
          errorMessage: '음성 인식 시작에 실패했습니다.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: SpeechRecognitionStatus.error,
        errorMessage: '음성 인식 시작 중 오류가 발생했습니다: $e',
      );
      return false;
    }
  }

  /// 음성 인식 중지
  Future<void> stopListening() async {
    try {
      await _speechService.stopListening();
      state = state.copyWith(
        isListening: false,
        status: SpeechRecognitionStatus.stopped,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: SpeechRecognitionStatus.stopFailed,
        errorMessage: '음성 인식 중지 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 음성 인식 취소
  Future<void> cancelListening() async {
    try {
      await _speechService.cancelListening();
      state = state.copyWith(
        isListening: false,
        status: SpeechRecognitionStatus.cancelled,
        currentText: '',
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: SpeechRecognitionStatus.cancelFailed,
        errorMessage: '음성 인식 취소 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 언어 설정
  void setLocale(String locale) {
    _speechService.setLocale(locale);
    state = state.copyWith(currentLocale: locale);
  }

  /// 텍스트 업데이트
  void updateText(String text, {bool isFinal = false}) {
    if (isFinal) {
      state = state.copyWith(finalText: text, currentText: '');
    } else {
      state = state.copyWith(currentText: text);
    }
  }

  /// 신뢰도 업데이트
  void updateConfidence(double confidence) {
    state = state.copyWith(confidence: confidence);
  }

  /// 상태 업데이트
  void updateStatus(SpeechRecognitionStatus status) {
    state = state.copyWith(
      status: status,
      isListening: status == SpeechRecognitionStatus.listening,
    );
  }

  /// 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 텍스트 초기화
  void clearText() {
    state = state.copyWith(currentText: '', finalText: '');
  }
}

/// 음성 인식 상태 관리 프로바이더
final speechRecognitionProvider =
    StateNotifierProvider<SpeechRecognitionNotifier, SpeechRecognitionState>((
      ref,
    ) {
      final speechService = ref.watch(speechRecognitionServiceProvider);
      final permissionService = ref.watch(permissionServiceProvider);
      return SpeechRecognitionNotifier(speechService, permissionService);
    });

/// 사용 가능한 언어 목록 프로바이더
final availableLocalesProvider = FutureProvider<List<stt.LocaleName>>((
  ref,
) async {
  final speechService = ref.watch(speechRecognitionServiceProvider);
  return await speechService.getAvailableLocales();
});

/// 마이크 권한 상태 프로바이더
final microphonePermissionProvider = FutureProvider<PermissionStatus>((
  ref,
) async {
  final permissionService = ref.watch(permissionServiceProvider);
  return await permissionService.checkMicrophonePermission();
});
