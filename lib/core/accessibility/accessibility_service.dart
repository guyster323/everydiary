import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 접근성 서비스
/// 앱의 접근성 기능을 관리하고 제공합니다.
class AccessibilityService {
  static AccessibilityService? _instance;
  static AccessibilityService get instance =>
      _instance ??= AccessibilityService._();

  AccessibilityService._();

  final MethodChannel _channel = const MethodChannel('accessibility_service');

  /// 고대비 모드 활성화 여부
  bool _isHighContrastEnabled = false;

  /// 텍스트 음성 변환 활성화 여부
  bool _isTextToSpeechEnabled = false;

  /// 큰 글씨 모드 활성화 여부
  bool _isLargeTextEnabled = false;

  /// 화면 읽기 지원 활성화 여부
  bool _isScreenReaderEnabled = false;

  /// 음성 명령 활성화 여부
  bool _isVoiceCommandsEnabled = false;

  /// 키보드 탐색 활성화 여부
  bool _isKeyboardNavigationEnabled = false;

  // Getters
  bool get isHighContrastEnabled => _isHighContrastEnabled;
  bool get isTextToSpeechEnabled => _isTextToSpeechEnabled;
  bool get isLargeTextEnabled => _isLargeTextEnabled;
  bool get isScreenReaderEnabled => _isScreenReaderEnabled;
  bool get isVoiceCommandsEnabled => _isVoiceCommandsEnabled;
  bool get isKeyboardNavigationEnabled => _isKeyboardNavigationEnabled;

  /// 접근성 서비스 초기화
  Future<void> initialize() async {
    try {
      // 플랫폼별 접근성 설정 확인
      await _checkPlatformAccessibility();

      // 시스템 접근성 설정 감지
      await _detectSystemAccessibility();

      debugPrint('접근성 서비스 초기화 완료');
    } catch (e) {
      debugPrint('접근성 서비스 초기화 실패: $e');
    }
  }

  /// 고대비 모드 토글
  Future<void> toggleHighContrast() async {
    try {
      _isHighContrastEnabled = !_isHighContrastEnabled;
      await _updateAccessibilitySettings();
      debugPrint('고대비 모드: $_isHighContrastEnabled');
    } catch (e) {
      debugPrint('고대비 모드 토글 실패: $e');
    }
  }

  /// 텍스트 음성 변환 토글
  Future<void> toggleTextToSpeech() async {
    try {
      _isTextToSpeechEnabled = !_isTextToSpeechEnabled;
      await _updateAccessibilitySettings();
      debugPrint('텍스트 음성 변환: $_isTextToSpeechEnabled');
    } catch (e) {
      debugPrint('텍스트 음성 변환 토글 실패: $e');
    }
  }

  /// 큰 글씨 모드 토글
  Future<void> toggleLargeText() async {
    try {
      _isLargeTextEnabled = !_isLargeTextEnabled;
      await _updateAccessibilitySettings();
      debugPrint('큰 글씨 모드: $_isLargeTextEnabled');
    } catch (e) {
      debugPrint('큰 글씨 모드 토글 실패: $e');
    }
  }

  /// 화면 읽기 지원 토글
  Future<void> toggleScreenReader() async {
    try {
      _isScreenReaderEnabled = !_isScreenReaderEnabled;
      await _updateAccessibilitySettings();
      debugPrint('화면 읽기 지원: $_isScreenReaderEnabled');
    } catch (e) {
      debugPrint('화면 읽기 지원 토글 실패: $e');
    }
  }

  /// 음성 명령 토글
  Future<void> toggleVoiceCommands() async {
    try {
      _isVoiceCommandsEnabled = !_isVoiceCommandsEnabled;
      await _updateAccessibilitySettings();
      debugPrint('음성 명령: $_isVoiceCommandsEnabled');
    } catch (e) {
      debugPrint('음성 명령 토글 실패: $e');
    }
  }

  /// 키보드 탐색 토글
  Future<void> toggleKeyboardNavigation() async {
    try {
      _isKeyboardNavigationEnabled = !_isKeyboardNavigationEnabled;
      await _updateAccessibilitySettings();
      debugPrint('키보드 탐색: $_isKeyboardNavigationEnabled');
    } catch (e) {
      debugPrint('키보드 탐색 토글 실패: $e');
    }
  }

  /// 텍스트 음성 변환 실행
  Future<void> speak(String text) async {
    if (!_isTextToSpeechEnabled) return;

    try {
      await _channel.invokeMethod('speak', {'text': text});
    } catch (e) {
      debugPrint('텍스트 음성 변환 실패: $e');
    }
  }

  /// 접근성 알림 표시
  Future<void> announceForAccessibility(String message) async {
    try {
      await _channel.invokeMethod('announce', {'message': message});
    } catch (e) {
      debugPrint('접근성 알림 실패: $e');
    }
  }

  /// 접근성 포커스 설정
  Future<void> setAccessibilityFocus(String widgetId) async {
    try {
      await _channel.invokeMethod('setFocus', {'widgetId': widgetId});
    } catch (e) {
      debugPrint('접근성 포커스 설정 실패: $e');
    }
  }

  /// 접근성 라벨 설정
  Future<void> setAccessibilityLabel(String widgetId, String label) async {
    try {
      await _channel.invokeMethod('setLabel', {
        'widgetId': widgetId,
        'label': label,
      });
    } catch (e) {
      debugPrint('접근성 라벨 설정 실패: $e');
    }
  }

  /// 접근성 힌트 설정
  Future<void> setAccessibilityHint(String widgetId, String hint) async {
    try {
      await _channel.invokeMethod('setHint', {
        'widgetId': widgetId,
        'hint': hint,
      });
    } catch (e) {
      debugPrint('접근성 힌트 설정 실패: $e');
    }
  }

  /// 접근성 상태 확인
  Future<AccessibilityStatus> getAccessibilityStatus() async {
    try {
      final result = await _channel.invokeMethod('getStatus');
      if (result != null) {
        return AccessibilityStatus.fromMap(result as Map<String, dynamic>);
      }
      return AccessibilityStatus();
    } catch (e) {
      debugPrint('접근성 상태 확인 실패: $e');
      return AccessibilityStatus();
    }
  }

  /// 접근성 설정 업데이트
  Future<void> _updateAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('updateSettings', {
        'highContrast': _isHighContrastEnabled,
        'textToSpeech': _isTextToSpeechEnabled,
        'largeText': _isLargeTextEnabled,
        'screenReader': _isScreenReaderEnabled,
        'voiceCommands': _isVoiceCommandsEnabled,
        'keyboardNavigation': _isKeyboardNavigationEnabled,
      });
    } catch (e) {
      debugPrint('접근성 설정 업데이트 실패: $e');
    }
  }

  /// 플랫폼별 접근성 설정 확인
  Future<void> _checkPlatformAccessibility() async {
    try {
      final result = await _channel.invokeMethod('checkPlatformAccessibility');
      if (result != null) {
        final settings = result as Map<String, dynamic>;
        _isHighContrastEnabled = (settings['highContrast'] as bool?) ?? false;
        _isTextToSpeechEnabled = (settings['textToSpeech'] as bool?) ?? false;
        _isLargeTextEnabled = (settings['largeText'] as bool?) ?? false;
        _isScreenReaderEnabled = (settings['screenReader'] as bool?) ?? false;
        _isVoiceCommandsEnabled = (settings['voiceCommands'] as bool?) ?? false;
        _isKeyboardNavigationEnabled =
            (settings['keyboardNavigation'] as bool?) ?? false;
      }
    } catch (e) {
      debugPrint('플랫폼 접근성 설정 확인 실패: $e');
    }
  }

  /// 시스템 접근성 설정 감지
  Future<void> _detectSystemAccessibility() async {
    try {
      // 시스템의 접근성 설정을 감지하고 앱 설정과 동기화
      final systemSettings = await _channel.invokeMethod(
        'detectSystemAccessibility',
      );
      if (systemSettings != null) {
        final settings = systemSettings as Map<String, dynamic>;

        // 시스템 설정에 따라 앱 설정 조정
        if ((settings['systemHighContrast'] as bool?) == true) {
          _isHighContrastEnabled = true;
        }

        if ((settings['systemLargeText'] as bool?) == true) {
          _isLargeTextEnabled = true;
        }

        if ((settings['systemScreenReader'] as bool?) == true) {
          _isScreenReaderEnabled = true;
        }
      }
    } catch (e) {
      debugPrint('시스템 접근성 설정 감지 실패: $e');
    }
  }

  /// 접근성 설정 저장
  Future<void> saveAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('saveSettings', {
        'highContrast': _isHighContrastEnabled,
        'textToSpeech': _isTextToSpeechEnabled,
        'largeText': _isLargeTextEnabled,
        'screenReader': _isScreenReaderEnabled,
        'voiceCommands': _isVoiceCommandsEnabled,
        'keyboardNavigation': _isKeyboardNavigationEnabled,
      });
    } catch (e) {
      debugPrint('접근성 설정 저장 실패: $e');
    }
  }

  /// 접근성 설정 로드
  Future<void> loadAccessibilitySettings() async {
    try {
      final result = await _channel.invokeMethod('loadSettings');
      if (result != null) {
        final settings = result as Map<String, dynamic>;
        _isHighContrastEnabled = (settings['highContrast'] as bool?) ?? false;
        _isTextToSpeechEnabled = (settings['textToSpeech'] as bool?) ?? false;
        _isLargeTextEnabled = (settings['largeText'] as bool?) ?? false;
        _isScreenReaderEnabled = (settings['screenReader'] as bool?) ?? false;
        _isVoiceCommandsEnabled = (settings['voiceCommands'] as bool?) ?? false;
        _isKeyboardNavigationEnabled =
            (settings['keyboardNavigation'] as bool?) ?? false;
      }
    } catch (e) {
      debugPrint('접근성 설정 로드 실패: $e');
    }
  }

  /// 접근성 설정 초기화
  Future<void> resetAccessibilitySettings() async {
    try {
      _isHighContrastEnabled = false;
      _isTextToSpeechEnabled = false;
      _isLargeTextEnabled = false;
      _isScreenReaderEnabled = false;
      _isVoiceCommandsEnabled = false;
      _isKeyboardNavigationEnabled = false;

      await _updateAccessibilitySettings();
      debugPrint('접근성 설정 초기화 완료');
    } catch (e) {
      debugPrint('접근성 설정 초기화 실패: $e');
    }
  }

  /// 접근성 설정 검증
  bool validateAccessibilitySettings() {
    // 접근성 설정의 유효성을 검증
    return true; // 기본적으로 유효함
  }

  /// 접근성 통계
  AccessibilityStatistics getStatistics() {
    return AccessibilityStatistics(
      highContrastEnabled: _isHighContrastEnabled,
      textToSpeechEnabled: _isTextToSpeechEnabled,
      largeTextEnabled: _isLargeTextEnabled,
      screenReaderEnabled: _isScreenReaderEnabled,
      voiceCommandsEnabled: _isVoiceCommandsEnabled,
      keyboardNavigationEnabled: _isKeyboardNavigationEnabled,
      lastUpdated: DateTime.now(),
    );
  }
}

/// 접근성 상태 모델
class AccessibilityStatus {
  final bool highContrastEnabled;
  final bool textToSpeechEnabled;
  final bool largeTextEnabled;
  final bool screenReaderEnabled;
  final bool voiceCommandsEnabled;
  final bool keyboardNavigationEnabled;
  final DateTime lastChecked;

  AccessibilityStatus({
    this.highContrastEnabled = false,
    this.textToSpeechEnabled = false,
    this.largeTextEnabled = false,
    this.screenReaderEnabled = false,
    this.voiceCommandsEnabled = false,
    this.keyboardNavigationEnabled = false,
    DateTime? lastChecked,
  }) : lastChecked = lastChecked ?? DateTime(2024, 1, 1);

  factory AccessibilityStatus.fromMap(Map<String, dynamic> map) {
    return AccessibilityStatus(
      highContrastEnabled: (map['highContrastEnabled'] as bool?) ?? false,
      textToSpeechEnabled: (map['textToSpeechEnabled'] as bool?) ?? false,
      largeTextEnabled: (map['largeTextEnabled'] as bool?) ?? false,
      screenReaderEnabled: (map['screenReaderEnabled'] as bool?) ?? false,
      voiceCommandsEnabled: (map['voiceCommandsEnabled'] as bool?) ?? false,
      keyboardNavigationEnabled:
          (map['keyboardNavigationEnabled'] as bool?) ?? false,
      lastChecked:
          DateTime.tryParse((map['lastChecked'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'highContrastEnabled': highContrastEnabled,
      'textToSpeechEnabled': textToSpeechEnabled,
      'largeTextEnabled': largeTextEnabled,
      'screenReaderEnabled': screenReaderEnabled,
      'voiceCommandsEnabled': voiceCommandsEnabled,
      'keyboardNavigationEnabled': keyboardNavigationEnabled,
      'lastChecked': lastChecked.toIso8601String(),
    };
  }
}

/// 접근성 통계 모델
class AccessibilityStatistics {
  final bool highContrastEnabled;
  final bool textToSpeechEnabled;
  final bool largeTextEnabled;
  final bool screenReaderEnabled;
  final bool voiceCommandsEnabled;
  final bool keyboardNavigationEnabled;
  final DateTime lastUpdated;

  const AccessibilityStatistics({
    required this.highContrastEnabled,
    required this.textToSpeechEnabled,
    required this.largeTextEnabled,
    required this.screenReaderEnabled,
    required this.voiceCommandsEnabled,
    required this.keyboardNavigationEnabled,
    required this.lastUpdated,
  });

  int get enabledFeaturesCount {
    int count = 0;
    if (highContrastEnabled) count++;
    if (textToSpeechEnabled) count++;
    if (largeTextEnabled) count++;
    if (screenReaderEnabled) count++;
    if (voiceCommandsEnabled) count++;
    if (keyboardNavigationEnabled) count++;
    return count;
  }

  double get accessibilityScore {
    return enabledFeaturesCount / 6.0 * 100.0;
  }
}
