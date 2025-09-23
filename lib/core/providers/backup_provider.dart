import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/services/profile_service.dart';
import '../../features/settings/services/preferences_service.dart';
import '../services/backup_service.dart';
import '../services/local_storage_service.dart';

/// 백업 서비스 프로바이더
final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(
    localStorageService: ref.watch(localStorageServiceProvider),
    preferencesService: ref.watch(preferencesServiceProvider),
    profileService: ref.watch(profileServiceProvider),
  );
});

/// 로컬 스토리지 서비스 프로바이더
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService.instance;
});

/// 설정 서비스 프로바이더
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

/// 프로필 서비스 프로바이더
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

/// 백업 목록 프로바이더
final backupListProvider = FutureProvider<List<BackupInfo>>((ref) async {
  final backupService = ref.watch(backupServiceProvider);
  return await backupService.getAvailableBackups();
});

/// 자동 백업 설정 프로바이더
final autoBackupSettingsProvider = FutureProvider<AutoBackupSettings>((
  ref,
) async {
  final backupService = ref.watch(backupServiceProvider);
  return await backupService.getAutoBackupSettings();
});

/// 백업 상태 프로바이더
class BackupState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const BackupState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  BackupState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return BackupState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

/// 백업 상태 관리 프로바이더
class BackupStateNotifier extends StateNotifier<BackupState> {
  final BackupService _backupService;

  BackupStateNotifier(this._backupService) : super(const BackupState());

  /// 백업 생성
  Future<BackupResult> createBackup({
    String? customName,
    bool includeSettings = true,
    bool includeProfile = true,
    bool includeDiaryData = true,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _backupService.createBackup(
        customName: customName,
        includeSettings: includeSettings,
        includeProfile: includeProfile,
        includeDiaryData: includeDiaryData,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          successMessage: '백업이 성공적으로 생성되었습니다.',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.errorMessage ?? '백업 생성에 실패했습니다.',
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '백업 생성 중 오류가 발생했습니다: $e',
      );
      return BackupResult.error('백업 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 백업 복원
  Future<RestoreResult> restoreFromBackup(String backupFilePath) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _backupService.restoreFromBackup(backupFilePath);

      if (result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          successMessage: '복원이 성공적으로 완료되었습니다.',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.errorMessage ?? '복원에 실패했습니다.',
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '복원 중 오류가 발생했습니다: $e',
      );
      return RestoreResult.error('복원 중 오류가 발생했습니다: $e');
    }
  }

  /// 백업 삭제
  Future<bool> deleteBackup(String backupFilePath) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _backupService.deleteBackup(backupFilePath);

      if (success) {
        state = state.copyWith(
          isLoading: false,
          successMessage: '백업이 삭제되었습니다.',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '백업 삭제에 실패했습니다.',
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '백업 삭제 중 오류가 발생했습니다: $e',
      );
      return false;
    }
  }

  /// 자동 백업 설정 업데이트
  Future<void> updateAutoBackupSettings({
    required bool enabled,
    int? intervalDays,
    int? maxBackups,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _backupService.setAutoBackup(
        enabled: enabled,
        intervalDays: intervalDays,
        maxBackups: maxBackups,
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: '자동 백업 설정이 업데이트되었습니다.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '자동 백업 설정 업데이트 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 메시지 초기화
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

/// 백업 상태 관리 프로바이더
final backupStateProvider =
    StateNotifierProvider<BackupStateNotifier, BackupState>((ref) {
      final backupService = ref.watch(backupServiceProvider);
      return BackupStateNotifier(backupService);
    });
