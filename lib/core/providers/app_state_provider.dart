import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/models/profile_model.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../features/settings/models/settings_enums.dart';
import '../../features/settings/models/settings_model.dart';
import '../../features/settings/providers/settings_provider.dart';

/// 앱 전체 상태 관리 프로바이더
/// 설정과 프로필을 통합하여 관리하는 최상위 프로바이더입니다.

/// 앱 테마 모드 프로바이더
final appThemeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.themeMode;
});

/// 앱 폰트 크기 프로바이더
final appFontSizeProvider = Provider<FontSize>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.fontSize;
});

/// 앱 언어 프로바이더
final appLanguageProvider = Provider<Language>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.language;
});

/// 앱 접근성 설정 프로바이더
final appAccessibilityProvider = Provider<AccessibilitySettings>((ref) {
  final settings = ref.watch(settingsProvider);
  return AccessibilitySettings(
    highContrast: settings.highContrast,
    textToSpeech: settings.textToSpeech,
  );
});

/// 앱 데이터 설정 프로바이더
final appDataSettingsProvider = Provider<DataSettings>((ref) {
  final settings = ref.watch(settingsProvider);
  return DataSettings(
    autoSave: settings.autoSave,
    autoSaveInterval: settings.autoSaveInterval,
    showStatistics: settings.showStatistics,
    enableAnalytics: settings.enableAnalytics,
    enableCrashReporting: settings.enableCrashReporting,
  );
});

/// 앱 알림 설정 프로바이더
final appNotificationProvider = Provider<NotificationSettings>((ref) {
  final settings = ref.watch(settingsProvider);
  return NotificationSettings(
    dailyReminder: settings.dailyReminder,
    reminderTime: settings.reminderTime,
  );
});

/// 앱 전체 상태 모델
class AppState {
  final SettingsModel settings;
  final ProfileModel profile;
  final bool isLoading;
  final String? error;

  const AppState({
    required this.settings,
    required this.profile,
    this.isLoading = false,
    this.error,
  });

  AppState copyWith({
    SettingsModel? settings,
    ProfileModel? profile,
    bool? isLoading,
    String? error,
  }) {
    return AppState(
      settings: settings ?? this.settings,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 앱 전체 상태 프로바이더
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(ref),
);

/// 앱 상태 관리자
class AppStateNotifier extends StateNotifier<AppState> {
  final Ref ref;

  AppStateNotifier(this.ref)
    : super(
        const AppState(settings: SettingsModel(), profile: ProfileModel()),
      ) {
    _initialize();
  }

  /// 앱 상태 초기화
  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true);

      // 설정과 프로필을 병렬로 로드
      await Future.wait([_loadSettings(), _loadProfile()]);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 설정 로드
  Future<void> _loadSettings() async {
    try {
      await ref.read(settingsProvider.notifier).refreshSettings();
      final settings = ref.read(settingsProvider);
      state = state.copyWith(settings: settings);
    } catch (e) {
      debugPrint('설정 로드 실패: $e');
    }
  }

  /// 프로필 로드
  Future<void> _loadProfile() async {
    try {
      await ref.read(profileProvider.notifier).refreshProfile();
      final profile = ref.read(profileProvider);
      state = state.copyWith(profile: profile);
    } catch (e) {
      debugPrint('프로필 로드 실패: $e');
    }
  }

  /// 앱 상태 새로고침
  Future<void> refresh() async {
    await _initialize();
  }

  /// 설정 업데이트
  Future<void> updateSettings(SettingsModel newSettings) async {
    try {
      await ref.read(settingsProvider.notifier).updateSettings(newSettings);
      state = state.copyWith(settings: newSettings);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 프로필 업데이트
  Future<void> updateProfile(ProfileModel newProfile) async {
    try {
      await ref.read(profileProvider.notifier).updateProfile(newProfile);
      state = state.copyWith(profile: newProfile);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 테마 모드 변경
  Future<void> changeThemeMode(ThemeMode themeMode) async {
    final newSettings = state.settings.copyWith(themeMode: themeMode);
    await updateSettings(newSettings);
  }

  /// 폰트 크기 변경
  Future<void> changeFontSize(FontSize fontSize) async {
    final newSettings = state.settings.copyWith(fontSize: fontSize);
    await updateSettings(newSettings);
  }

  /// 언어 변경
  Future<void> changeLanguage(Language language) async {
    final newSettings = state.settings.copyWith(language: language);
    await updateSettings(newSettings);
  }

  /// 일일 알림 설정 변경
  Future<void> toggleDailyReminder(bool enabled) async {
    final newSettings = state.settings.copyWith(dailyReminder: enabled);
    await updateSettings(newSettings);
  }

  /// 알림 시간 변경
  Future<void> changeReminderTime(TimeOfDay time) async {
    final newSettings = state.settings.copyWith(reminderTime: time);
    await updateSettings(newSettings);
  }

  /// 접근성 설정 변경
  Future<void> updateAccessibilitySettings({
    bool? highContrast,
    bool? textToSpeech,
  }) async {
    final newSettings = state.settings.copyWith(
      highContrast: highContrast ?? state.settings.highContrast,
      textToSpeech: textToSpeech ?? state.settings.textToSpeech,
    );
    await updateSettings(newSettings);
  }

  /// 데이터 설정 변경
  Future<void> updateDataSettings({
    bool? autoSave,
    int? autoSaveInterval,
    bool? showStatistics,
    bool? enableAnalytics,
    bool? enableCrashReporting,
  }) async {
    final newSettings = state.settings.copyWith(
      autoSave: autoSave ?? state.settings.autoSave,
      autoSaveInterval: autoSaveInterval ?? state.settings.autoSaveInterval,
      showStatistics: showStatistics ?? state.settings.showStatistics,
      enableAnalytics: enableAnalytics ?? state.settings.enableAnalytics,
      enableCrashReporting:
          enableCrashReporting ?? state.settings.enableCrashReporting,
    );
    await updateSettings(newSettings);
  }

  /// 프로필 이미지 업데이트
  Future<void> updateProfileImage(String imagePath) async {
    try {
      await ref.read(profileProvider.notifier).updateProfileImage(imagePath);
      final profile = ref.read(profileProvider);
      state = state.copyWith(profile: profile);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 프로필 이미지 제거
  Future<void> removeProfileImage() async {
    try {
      await ref.read(profileProvider.notifier).removeProfileImage();
      final profile = ref.read(profileProvider);
      state = state.copyWith(profile: profile);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 접근성 설정 모델
class AccessibilitySettings {
  final bool highContrast;
  final bool textToSpeech;

  const AccessibilitySettings({
    required this.highContrast,
    required this.textToSpeech,
  });
}

/// 데이터 설정 모델
class DataSettings {
  final bool autoSave;
  final int autoSaveInterval;
  final bool showStatistics;
  final bool enableAnalytics;
  final bool enableCrashReporting;

  const DataSettings({
    required this.autoSave,
    required this.autoSaveInterval,
    required this.showStatistics,
    required this.enableAnalytics,
    required this.enableCrashReporting,
  });
}

/// 알림 설정 모델
class NotificationSettings {
  final bool dailyReminder;
  final TimeOfDay reminderTime;

  const NotificationSettings({
    required this.dailyReminder,
    required this.reminderTime,
  });
}
