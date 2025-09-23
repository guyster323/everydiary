import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../accessibility/accessibility_service.dart';

/// 접근성 프로바이더
/// 앱의 접근성 설정을 관리하고 접근성 기능을 제공합니다.
class AccessibilityNotifier extends StateNotifier<AccessibilitySettings> {
  AccessibilityNotifier() : super(const AccessibilitySettings());

  final AccessibilityService _accessibilityService =
      AccessibilityService.instance;

  /// 접근성 서비스 초기화
  Future<void> initialize() async {
    try {
      await _accessibilityService.initialize();
      await _loadAccessibilitySettings();
      debugPrint('접근성 프로바이더 초기화 완료');
    } catch (e) {
      debugPrint('접근성 프로바이더 초기화 실패: $e');
    }
  }

  /// 고대비 모드 토글
  Future<void> toggleHighContrast() async {
    try {
      await _accessibilityService.toggleHighContrast();
      state = state.copyWith(
        highContrast: _accessibilityService.isHighContrastEnabled,
      );
      debugPrint('고대비 모드 토글: ${state.highContrast}');
    } catch (e) {
      debugPrint('고대비 모드 토글 실패: $e');
    }
  }

  /// 텍스트 음성 변환 토글
  Future<void> toggleTextToSpeech() async {
    try {
      await _accessibilityService.toggleTextToSpeech();
      state = state.copyWith(
        textToSpeech: _accessibilityService.isTextToSpeechEnabled,
      );
      debugPrint('텍스트 음성 변환 토글: ${state.textToSpeech}');
    } catch (e) {
      debugPrint('텍스트 음성 변환 토글 실패: $e');
    }
  }

  /// 큰 글씨 모드 토글
  Future<void> toggleLargeText() async {
    try {
      await _accessibilityService.toggleLargeText();
      state = state.copyWith(
        largeText: _accessibilityService.isLargeTextEnabled,
      );
      debugPrint('큰 글씨 모드 토글: ${state.largeText}');
    } catch (e) {
      debugPrint('큰 글씨 모드 토글 실패: $e');
    }
  }

  /// 화면 읽기 지원 토글
  Future<void> toggleScreenReader() async {
    try {
      await _accessibilityService.toggleScreenReader();
      state = state.copyWith(
        screenReader: _accessibilityService.isScreenReaderEnabled,
      );
      debugPrint('화면 읽기 지원 토글: ${state.screenReader}');
    } catch (e) {
      debugPrint('화면 읽기 지원 토글 실패: $e');
    }
  }

  /// 음성 명령 토글
  Future<void> toggleVoiceCommands() async {
    try {
      await _accessibilityService.toggleVoiceCommands();
      state = state.copyWith(
        voiceCommands: _accessibilityService.isVoiceCommandsEnabled,
      );
      debugPrint('음성 명령 토글: ${state.voiceCommands}');
    } catch (e) {
      debugPrint('음성 명령 토글 실패: $e');
    }
  }

  /// 키보드 탐색 토글
  Future<void> toggleKeyboardNavigation() async {
    try {
      await _accessibilityService.toggleKeyboardNavigation();
      state = state.copyWith(
        keyboardNavigation: _accessibilityService.isKeyboardNavigationEnabled,
      );
      debugPrint('키보드 탐색 토글: ${state.keyboardNavigation}');
    } catch (e) {
      debugPrint('키보드 탐색 토글 실패: $e');
    }
  }

  /// 접근성 설정 업데이트
  Future<void> updateAccessibilitySettings({
    bool? highContrast,
    bool? textToSpeech,
    bool? largeText,
    bool? screenReader,
    bool? voiceCommands,
    bool? keyboardNavigation,
  }) async {
    try {
      state = state.copyWith(
        highContrast: highContrast ?? state.highContrast,
        textToSpeech: textToSpeech ?? state.textToSpeech,
        largeText: largeText ?? state.largeText,
        screenReader: screenReader ?? state.screenReader,
        voiceCommands: voiceCommands ?? state.voiceCommands,
        keyboardNavigation: keyboardNavigation ?? state.keyboardNavigation,
      );

      // 접근성 서비스에 설정 적용
      if (highContrast != null &&
          highContrast != _accessibilityService.isHighContrastEnabled) {
        await _accessibilityService.toggleHighContrast();
      }
      if (textToSpeech != null &&
          textToSpeech != _accessibilityService.isTextToSpeechEnabled) {
        await _accessibilityService.toggleTextToSpeech();
      }
      if (largeText != null &&
          largeText != _accessibilityService.isLargeTextEnabled) {
        await _accessibilityService.toggleLargeText();
      }
      if (screenReader != null &&
          screenReader != _accessibilityService.isScreenReaderEnabled) {
        await _accessibilityService.toggleScreenReader();
      }
      if (voiceCommands != null &&
          voiceCommands != _accessibilityService.isVoiceCommandsEnabled) {
        await _accessibilityService.toggleVoiceCommands();
      }
      if (keyboardNavigation != null &&
          keyboardNavigation !=
              _accessibilityService.isKeyboardNavigationEnabled) {
        await _accessibilityService.toggleKeyboardNavigation();
      }

      await _saveAccessibilitySettings();
      debugPrint('접근성 설정 업데이트 완료');
    } catch (e) {
      debugPrint('접근성 설정 업데이트 실패: $e');
    }
  }

  /// 텍스트 음성 변환 실행
  Future<void> speak(String text) async {
    try {
      await _accessibilityService.speak(text);
      debugPrint('텍스트 음성 변환 실행: $text');
    } catch (e) {
      debugPrint('텍스트 음성 변환 실행 실패: $e');
    }
  }

  /// 접근성 알림 표시
  Future<void> announceForAccessibility(String message) async {
    try {
      await _accessibilityService.announceForAccessibility(message);
      debugPrint('접근성 알림 표시: $message');
    } catch (e) {
      debugPrint('접근성 알림 표시 실패: $e');
    }
  }

  /// 접근성 설정 저장
  Future<void> _saveAccessibilitySettings() async {
    try {
      await _accessibilityService.saveAccessibilitySettings();
      debugPrint('접근성 설정 저장 완료');
    } catch (e) {
      debugPrint('접근성 설정 저장 실패: $e');
    }
  }

  /// 접근성 설정 로드
  Future<void> _loadAccessibilitySettings() async {
    try {
      await _accessibilityService.loadAccessibilitySettings();
      state = AccessibilitySettings(
        highContrast: _accessibilityService.isHighContrastEnabled,
        textToSpeech: _accessibilityService.isTextToSpeechEnabled,
        largeText: _accessibilityService.isLargeTextEnabled,
        screenReader: _accessibilityService.isScreenReaderEnabled,
        voiceCommands: _accessibilityService.isVoiceCommandsEnabled,
        keyboardNavigation: _accessibilityService.isKeyboardNavigationEnabled,
      );
      debugPrint('접근성 설정 로드 완료');
    } catch (e) {
      debugPrint('접근성 설정 로드 실패: $e');
    }
  }

  /// 접근성 설정 초기화
  Future<void> resetAccessibilitySettings() async {
    try {
      await _accessibilityService.resetAccessibilitySettings();
      state = const AccessibilitySettings();
      debugPrint('접근성 설정 초기화 완료');
    } catch (e) {
      debugPrint('접근성 설정 초기화 실패: $e');
    }
  }

  /// 접근성 통계 가져오기
  AccessibilityStatistics getAccessibilityStatistics() {
    return _accessibilityService.getStatistics();
  }

  /// 접근성 설정 검증
  bool validateAccessibilitySettings() {
    return _accessibilityService.validateAccessibilitySettings();
  }
}

/// 접근성 설정 모델
class AccessibilitySettings {
  final bool highContrast;
  final bool textToSpeech;
  final bool largeText;
  final bool screenReader;
  final bool voiceCommands;
  final bool keyboardNavigation;

  const AccessibilitySettings({
    this.highContrast = false,
    this.textToSpeech = false,
    this.largeText = false,
    this.screenReader = false,
    this.voiceCommands = false,
    this.keyboardNavigation = false,
  });

  AccessibilitySettings copyWith({
    bool? highContrast,
    bool? textToSpeech,
    bool? largeText,
    bool? screenReader,
    bool? voiceCommands,
    bool? keyboardNavigation,
  }) {
    return AccessibilitySettings(
      highContrast: highContrast ?? this.highContrast,
      textToSpeech: textToSpeech ?? this.textToSpeech,
      largeText: largeText ?? this.largeText,
      screenReader: screenReader ?? this.screenReader,
      voiceCommands: voiceCommands ?? this.voiceCommands,
      keyboardNavigation: keyboardNavigation ?? this.keyboardNavigation,
    );
  }

  /// 활성화된 접근성 기능 수
  int get enabledFeaturesCount {
    int count = 0;
    if (highContrast) count++;
    if (textToSpeech) count++;
    if (largeText) count++;
    if (screenReader) count++;
    if (voiceCommands) count++;
    if (keyboardNavigation) count++;
    return count;
  }

  /// 접근성 점수 (0-100)
  double get accessibilityScore {
    return enabledFeaturesCount / 6.0 * 100.0;
  }

  /// 접근성 설정이 활성화되어 있는지 확인
  bool get hasAnyAccessibilityEnabled {
    return highContrast ||
        textToSpeech ||
        largeText ||
        screenReader ||
        voiceCommands ||
        keyboardNavigation;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccessibilitySettings &&
        other.highContrast == highContrast &&
        other.textToSpeech == textToSpeech &&
        other.largeText == largeText &&
        other.screenReader == screenReader &&
        other.voiceCommands == voiceCommands &&
        other.keyboardNavigation == keyboardNavigation;
  }

  @override
  int get hashCode {
    return Object.hash(
      highContrast,
      textToSpeech,
      largeText,
      screenReader,
      voiceCommands,
      keyboardNavigation,
    );
  }

  @override
  String toString() {
    return 'AccessibilitySettings('
        'highContrast: $highContrast, '
        'textToSpeech: $textToSpeech, '
        'largeText: $largeText, '
        'screenReader: $screenReader, '
        'voiceCommands: $voiceCommands, '
        'keyboardNavigation: $keyboardNavigation'
        ')';
  }
}

/// 접근성 프로바이더
final accessibilityProvider =
    StateNotifierProvider<AccessibilityNotifier, AccessibilitySettings>((ref) {
      return AccessibilityNotifier();
    });

/// 고대비 모드 프로바이더
final highContrastProvider = Provider<bool>((ref) {
  final settings = ref.watch(accessibilityProvider);
  return settings.highContrast;
});

/// 텍스트 음성 변환 프로바이더
final textToSpeechProvider = Provider<bool>((ref) {
  final settings = ref.watch(accessibilityProvider);
  return settings.textToSpeech;
});

/// 큰 글씨 모드 프로바이더
final largeTextProvider = Provider<bool>((ref) {
  final settings = ref.watch(accessibilityProvider);
  return settings.largeText;
});

/// 화면 읽기 지원 프로바이더
final screenReaderProvider = Provider<bool>((ref) {
  final settings = ref.watch(accessibilityProvider);
  return settings.screenReader;
});

/// 음성 명령 프로바이더
final voiceCommandsProvider = Provider<bool>((ref) {
  final settings = ref.watch(accessibilityProvider);
  return settings.voiceCommands;
});

/// 키보드 탐색 프로바이더
final keyboardNavigationProvider = Provider<bool>((ref) {
  final settings = ref.watch(accessibilityProvider);
  return settings.keyboardNavigation;
});

/// 접근성 점수 프로바이더
final accessibilityScoreProvider = Provider<double>((ref) {
  final settings = ref.watch(accessibilityProvider);
  return settings.accessibilityScore;
});

/// 접근성 기능 활성화 여부 프로바이더
final hasAccessibilityEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(accessibilityProvider);
  return settings.hasAnyAccessibilityEnabled;
});
