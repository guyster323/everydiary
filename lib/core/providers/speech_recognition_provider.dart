import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../features/settings/models/settings_enums.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../services/permission_service.dart';
import '../services/speech_recognition_service.dart';
import 'localization_provider.dart';

/// 음성 인식에서 사용할 수 있는 로케일 옵션
class SpeechLocaleOption {
  const SpeechLocaleOption({required this.code, required this.label});

  final String code;
  final String label;
}

const List<SpeechLocaleOption> kSpeechLocaleOptions = <SpeechLocaleOption>[
  SpeechLocaleOption(code: 'ko-KR', label: '한국어'),
  SpeechLocaleOption(code: 'en-US', label: 'English'),
  SpeechLocaleOption(code: 'ja-JP', label: '日本語'),
  SpeechLocaleOption(code: 'zh-CN', label: '中文'),
];

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

/// UI에서 사용할 로케일 옵션 제공
final speechLocaleOptionsProvider = Provider<List<SpeechLocaleOption>>((ref) {
  return kSpeechLocaleOptions;
});

/// 앱 설정 언어를 기반으로 음성 인식 Default locale 가져오기
String getDefaultSpeechLocaleFromAppLanguage(Language language) {
  switch (language) {
    case Language.korean:
      return 'ko-KR';
    case Language.english:
      return 'en-US';
    case Language.japanese:
      return 'ja-JP';
    case Language.chineseSimplified:
    case Language.chineseTraditional:
      return 'zh-CN';
  }
}

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
    required this.currentLocale,
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
  final Ref _ref;

  SpeechRecognitionNotifier(this._speechService, this._permissionService, this._ref)
    : super(SpeechRecognitionState(
        currentLocale: _getInitialLocale(_ref),
      )) {
    _initialize();
  }

  static String _getInitialLocale(Ref ref) {
    try {
      final settings = ref.read(settingsProvider);
      return getDefaultSpeechLocaleFromAppLanguage(settings.language);
    } catch (e) {
      return 'ko-KR'; // Fallback
    }
  }

  /// 서비스 초기화
  Future<void> _initialize() async {
    try {
      final initialized = await _speechService.initialize();
      if (initialized) {
        _speechService.setLocale(state.currentLocale);
        state = state.copyWith(
          isInitialized: true,
          status: SpeechRecognitionStatus.initialized,
        );
      } else {
        final l10n = _ref.read(localizationProvider);
        state = state.copyWith(
          status: SpeechRecognitionStatus.initializationFailed,
          errorMessage: l10n.get('speech_init_failed'),
        );
      }
    } catch (e) {
      final l10n = _ref.read(localizationProvider);
      state = state.copyWith(
        status: SpeechRecognitionStatus.initializationFailed,
        errorMessage: '${l10n.get('speech_init_error')}: $e',
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
      final l10n = _ref.read(localizationProvider);
      state = state.copyWith(
        status: SpeechRecognitionStatus.permissionDenied,
        errorMessage: l10n.get('speech_permission_required'),
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
        final l10n = _ref.read(localizationProvider);
        state = state.copyWith(
          status: SpeechRecognitionStatus.startFailed,
          errorMessage: l10n.get('speech_start_failed'),
        );
        return false;
      }
    } catch (e) {
      final l10n = _ref.read(localizationProvider);
      state = state.copyWith(
        status: SpeechRecognitionStatus.error,
        errorMessage: '${l10n.get('speech_start_error')}: $e',
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
      final l10n = _ref.read(localizationProvider);
      state = state.copyWith(
        status: SpeechRecognitionStatus.stopFailed,
        errorMessage: '${l10n.get('speech_stop_error')}: $e',
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
      final l10n = _ref.read(localizationProvider);
      state = state.copyWith(
        status: SpeechRecognitionStatus.cancelFailed,
        errorMessage: '${l10n.get('speech_cancel_error')}: $e',
      );
    }
  }

  /// 언어 설정
  void setLocale(String locale) {
    _speechService.setLocale(locale);
    state = state.copyWith(currentLocale: locale);
  }

  /// 선택 가능한 언어 중 하나를 설정
  void setLocaleOption(SpeechLocaleOption option) {
    setLocale(option.code);
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
      return SpeechRecognitionNotifier(speechService, permissionService, ref);
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
