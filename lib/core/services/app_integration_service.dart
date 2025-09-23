import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/models/profile_model.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../features/profile/services/profile_service.dart';
import '../../features/settings/models/settings_enums.dart';
import '../../features/settings/models/settings_model.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../features/settings/services/preferences_service.dart';

/// 앱 통합 서비스
/// 설정과 프로필을 통합하여 관리하는 서비스입니다.
class AppIntegrationService {
  final PreferencesService _preferencesService = PreferencesService();
  final ProfileService _profileService = ProfileService();

  /// 앱 초기화
  /// 앱 시작 시 설정과 프로필을 로드하고 동기화합니다.
  Future<void> initializeApp(WidgetRef ref) async {
    try {
      // 설정과 프로필을 병렬로 로드
      await Future.wait([_loadAndSyncSettings(ref), _loadAndSyncProfile(ref)]);

      // 설정과 프로필 간의 동기화
      await _syncSettingsWithProfile(ref);
    } catch (e) {
      debugPrint('앱 초기화 실패: $e');
      rethrow;
    }
  }

  /// 설정 로드 및 동기화
  Future<void> _loadAndSyncSettings(WidgetRef ref) async {
    try {
      await ref.read(settingsProvider.notifier).refreshSettings();
    } catch (e) {
      debugPrint('설정 로드 실패: $e');
    }
  }

  /// 프로필 로드 및 동기화
  Future<void> _loadAndSyncProfile(WidgetRef ref) async {
    try {
      await ref.read(profileProvider.notifier).refreshProfile();
    } catch (e) {
      debugPrint('프로필 로드 실패: $e');
    }
  }

  /// 설정과 프로필 간 동기화
  Future<void> _syncSettingsWithProfile(WidgetRef ref) async {
    try {
      final settings = ref.read(settingsProvider);
      final profile = ref.read(profileProvider);

      // 프로필의 언어 설정을 설정의 언어와 동기화
      if (profile.language != settings.language.name) {
        final updatedProfile = profile.copyWith(
          language: settings.language.name,
          updatedAt: DateTime.now(),
        );
        await ref.read(profileProvider.notifier).updateProfile(updatedProfile);
      }

      // 프로필의 타임존을 설정에서 가져오기 (향후 구현)
      // 현재는 기본값 사용
    } catch (e) {
      debugPrint('설정-프로필 동기화 실패: $e');
    }
  }

  /// 설정 변경 시 프로필 동기화
  Future<void> onSettingsChanged(
    WidgetRef ref,
    SettingsModel oldSettings,
    SettingsModel newSettings,
  ) async {
    try {
      final profile = ref.read(profileProvider);

      // 언어 변경 시 프로필 동기화
      if (oldSettings.language != newSettings.language) {
        final updatedProfile = profile.copyWith(
          language: newSettings.language.name,
          updatedAt: DateTime.now(),
        );
        await ref.read(profileProvider.notifier).updateProfile(updatedProfile);
      }

      // 타임존 변경 시 프로필 동기화 (향후 구현)
      // if (oldSettings.timezone != newSettings.timezone) {
      //   final updatedProfile = profile.copyWith(
      //     timezone: newSettings.timezone,
      //     updatedAt: DateTime.now(),
      //   );
      //   await ref.read(profileProvider.notifier).updateProfile(updatedProfile);
      // }
    } catch (e) {
      debugPrint('설정 변경 시 프로필 동기화 실패: $e');
    }
  }

  /// 프로필 변경 시 설정 동기화
  Future<void> onProfileChanged(
    WidgetRef ref,
    ProfileModel oldProfile,
    ProfileModel newProfile,
  ) async {
    try {
      final settings = ref.read(settingsProvider);

      // 프로필 언어 변경 시 설정 동기화
      if (oldProfile.language != newProfile.language) {
        final language = Language.values.firstWhere(
          (Language lang) => lang.name == newProfile.language,
          orElse: () => Language.korean,
        );
        final updatedSettings = settings.copyWith(language: language);
        await ref
            .read(settingsProvider.notifier)
            .updateSettings(updatedSettings);
      }
    } catch (e) {
      debugPrint('프로필 변경 시 설정 동기화 실패: $e');
    }
  }

  /// 앱 데이터 백업
  Future<Map<String, dynamic>> backupAppData() async {
    try {
      final settingsBackup = await _preferencesService.backupSettings();
      final profileBackup = await _profileService.backupProfile();

      return {
        'settings': settingsBackup,
        'profile': profileBackup,
        'backupDate': DateTime.now().toIso8601String(),
        'version': '1.0.0', // 앱 버전
      };
    } catch (e) {
      throw Exception('앱 데이터 백업 실패: $e');
    }
  }

  /// 앱 데이터 복원
  Future<void> restoreAppData(Map<String, dynamic> backupData) async {
    try {
      if (backupData['settings'] != null) {
        await _preferencesService.restoreSettings(
          backupData['settings'] as String,
        );
      }

      if (backupData['profile'] != null) {
        await _profileService.restoreProfile(backupData['profile'] as String);
      }
    } catch (e) {
      throw Exception('앱 데이터 복원 실패: $e');
    }
  }

  /// 앱 데이터 초기화
  Future<void> resetAppData() async {
    try {
      await Future.wait([
        _preferencesService.resetSettings(),
        _profileService.resetProfile(),
      ]);
    } catch (e) {
      throw Exception('앱 데이터 초기화 실패: $e');
    }
  }

  /// 앱 데이터 크기 확인
  Future<int> getAppDataSize() async {
    try {
      final settingsSize = await _preferencesService.getSettingsSize();
      final profileSize = await _profileService.getProfileSize();
      return settingsSize + profileSize;
    } catch (e) {
      return 0;
    }
  }

  /// 앱 데이터 검증
  Future<bool> validateAppData() async {
    try {
      final settings = await _preferencesService.loadSettings();
      final profile = await _profileService.loadProfile();

      // 설정 검증
      if (!_preferencesService.validateSettings(settings)) {
        return false;
      }

      // 프로필 검증
      if (!_profileService.validateProfile(profile)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 앱 상태 모니터링
  Future<AppHealthStatus> getAppHealthStatus() async {
    try {
      final dataSize = await getAppDataSize();
      final isValid = await validateAppData();
      final hasSettings = await _preferencesService.hasSettings();
      final hasProfile = await _profileService.hasProfile();

      return AppHealthStatus(
        dataSize: dataSize,
        isValid: isValid,
        hasSettings: hasSettings,
        hasProfile: hasProfile,
        lastChecked: DateTime.now(),
      );
    } catch (e) {
      return AppHealthStatus(
        dataSize: 0,
        isValid: false,
        hasSettings: false,
        hasProfile: false,
        lastChecked: DateTime.now(),
        error: e.toString(),
      );
    }
  }
}

/// 앱 상태 모니터링 모델
class AppHealthStatus {
  final int dataSize;
  final bool isValid;
  final bool hasSettings;
  final bool hasProfile;
  final DateTime lastChecked;
  final String? error;

  const AppHealthStatus({
    required this.dataSize,
    required this.isValid,
    required this.hasSettings,
    required this.hasProfile,
    required this.lastChecked,
    this.error,
  });

  bool get isHealthy => isValid && hasSettings && hasProfile && error == null;
}

/// 앱 통합 서비스 프로바이더
final appIntegrationServiceProvider = Provider<AppIntegrationService>((ref) {
  return AppIntegrationService();
});
