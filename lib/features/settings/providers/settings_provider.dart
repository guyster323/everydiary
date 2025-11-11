import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/settings_enums.dart';
import '../models/settings_model.dart';
import '../services/preferences_service.dart';

/// 설정 프로바이더
/// 앱의 설정 상태를 관리하는 Riverpod 프로바이더입니다.
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsModel>(
  (ref) => SettingsNotifier(),
);

/// 설정 상태 관리자
/// 사용자 설정을 관리하고 SharedPreferences에 저장/로드하는 클래스입니다.
class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier() : super(const SettingsModel()) {
    _loadSettings();
  }

  final PreferencesService _preferencesService = PreferencesService();

  /// 설정 로드
  Future<void> _loadSettings() async {
    try {
      final settings = await _preferencesService.loadSettings();
      state = settings;
      debugPrint('설정 로드 성공: ${settings.language}');
    } catch (e) {
      // 설정 로드 실패 시 기본값 사용
      debugPrint('설정 로드 실패: $e');
      debugPrint('기본 설정으로 초기화합니다.');
    }
  }

  /// 설정 새로고침 (외부에서 호출 가능)
  Future<void> refreshSettings() async {
    await _loadSettings();
  }

  /// 설정 업데이트 (외부에서 호출 가능)
  Future<void> updateSettings(SettingsModel newSettings) async {
    state = newSettings;
    await _saveSettings();
  }

  /// 설정 저장
  Future<void> _saveSettings() async {
    try {
      await _preferencesService.saveSettings(state);
    } catch (e) {
      debugPrint('설정 저장 실패: $e');
    }
  }

  /// 테마 모드 설정
  void setThemeMode(ThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
    _saveSettings();
  }

  /// 폰트 크기 설정
  void setFontSize(FontSize fontSize) {
    state = state.copyWith(fontSize: fontSize);
    _saveSettings();
  }

  /// 언어 설정
  void setLanguage(Language language) {
    state = state.copyWith(language: language);
    _saveSettings();
  }

  /// 일일 알림 설정
  void setDailyReminder(bool enabled) {
    state = state.copyWith(dailyReminder: enabled);
    _saveSettings();
  }

  /// 알림 시간 설정
  void setReminderTime(TimeOfDay time) {
    state = state.copyWith(reminderTime: time);
    _saveSettings();
  }

  /// 고대비 모드 설정
  void setHighContrast(bool enabled) {
    state = state.copyWith(highContrast: enabled);
    _saveSettings();
  }

  /// 텍스트 읽기 설정
  void setTextToSpeech(bool enabled) {
    state = state.copyWith(textToSpeech: enabled);
    _saveSettings();
  }

  /// 자동 저장 설정
  void setAutoSave(bool enabled) {
    state = state.copyWith(autoSave: enabled);
    _saveSettings();
  }

  /// 자동 저장 간격 설정
  void setAutoSaveInterval(int interval) {
    state = state.copyWith(autoSaveInterval: interval);
    _saveSettings();
  }

  /// 통계 표시 설정
  void setShowStatistics(bool enabled) {
    state = state.copyWith(showStatistics: enabled);
    _saveSettings();
  }

  /// 분석 데이터 수집 설정
  void setEnableAnalytics(bool enabled) {
    state = state.copyWith(enableAnalytics: enabled);
    _saveSettings();
  }

  /// 크래시 리포팅 설정
  void setEnableCrashReporting(bool enabled) {
    state = state.copyWith(enableCrashReporting: enabled);
    _saveSettings();
  }

  /// 설정 초기화
  void resetSettings() {
    state = const SettingsModel();
    _saveSettings();
  }

  /// 특정 설정만 초기화
  void resetSpecificSetting(String settingKey) {
    switch (settingKey) {
      case 'theme':
        state = state.copyWith(themeMode: ThemeMode.system);
        break;
      case 'fontSize':
        state = state.copyWith(fontSize: FontSize.medium);
        break;
      case 'language':
        state = state.copyWith(language: Language.korean);
        break;
      case 'notifications':
        state = state.copyWith(
          dailyReminder: false,
          reminderTime: const TimeOfDay(hour: 20, minute: 0),
        );
        break;
      case 'accessibility':
        state = state.copyWith(highContrast: false, textToSpeech: false);
        break;
    }
    _saveSettings();
  }
}

/// 폰트 크기별 실제 크기 값
double getFontSizeValue(FontSize fontSize) {
  switch (fontSize) {
    case FontSize.small:
      return 12.0;
    case FontSize.medium:
      return 14.0;
    case FontSize.large:
      return 16.0;
    case FontSize.extraLarge:
      return 18.0;
  }
}

/// 언어별 로케일 정보
Locale getLocaleFromLanguage(Language language) {
  switch (language) {
    case Language.korean:
      return const Locale('ko', 'KR');
    case Language.english:
      return const Locale('en', 'US');
    case Language.japanese:
      return const Locale('ja', 'JP');
    case Language.chineseSimplified:
      return const Locale('zh', 'CN');
    case Language.chineseTraditional:
      return const Locale('zh', 'TW');
  }
}

/// 언어별 표시 이름
String getLanguageDisplayName(Language language) {
  switch (language) {
    case Language.korean:
      return '한국어';
    case Language.english:
      return 'English';
    case Language.japanese:
      return '日本語';
    case Language.chineseSimplified:
      return '简体中文';
    case Language.chineseTraditional:
      return '繁體中文';
  }
}
