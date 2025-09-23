import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/profile/models/profile_model.dart';
import '../../features/profile/services/profile_service.dart';
import '../../features/settings/models/settings_model.dart';
import '../../features/settings/services/preferences_service.dart';
import '../../shared/services/database_service.dart';
import '../utils/logger.dart';
import 'local_storage_service.dart';

/// 백업 서비스 클래스
/// 사용자 데이터의 백업 및 복원 기능을 제공합니다.
class BackupService {
  static const String _backupFolderName = 'everydiary_backups';
  static const String _backupFileExtension = '.json';

  final LocalStorageService _localStorageService;
  final PreferencesService _preferencesService;
  final ProfileService _profileService;

  BackupService({
    required LocalStorageService localStorageService,
    required PreferencesService preferencesService,
    required ProfileService profileService,
  }) : _localStorageService = localStorageService,
       _preferencesService = preferencesService,
       _profileService = profileService;

  /// 전체 데이터 백업 생성
  Future<BackupResult> createBackup({
    String? customName,
    bool includeSettings = true,
    bool includeProfile = true,
    bool includeDiaryData = true,
  }) async {
    try {
      final timestamp = DateTime.now();
      final backupName =
          customName ?? 'backup_${timestamp.millisecondsSinceEpoch}';

      final backupData = <String, dynamic>{
        'metadata': {
          'name': backupName,
          'createdAt': timestamp.toIso8601String(),
          'version': '1.0.0',
          'includes': {
            'settings': includeSettings,
            'profile': includeProfile,
            'diaryData': includeDiaryData,
          },
        },
      };

      // 설정 데이터 백업
      if (includeSettings) {
        final settings = await _preferencesService.loadSettings();
        backupData['settings'] = settings.toJson();
      }

      // 프로필 데이터 백업
      if (includeProfile) {
        final profile = await _profileService.loadProfile();
        backupData['profile'] = profile.toJson();
      }

      // 일기 데이터 백업 (향후 구현)
      if (includeDiaryData) {
        backupData['diaryData'] = await _backupDiaryData();
      }

      // 백업 파일 저장
      final backupFile = await _saveBackupFile(backupName, backupData);

      // 백업 메타데이터 저장
      await _saveBackupMetadata(backupName, timestamp, backupFile.path);

      return BackupResult.success(
        backupName: backupName,
        filePath: backupFile.path,
        size: await backupFile.length(),
        createdAt: timestamp,
      );
    } catch (e) {
      return BackupResult.error('백업 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 백업 파일에서 데이터 복원
  Future<RestoreResult> restoreFromBackup(String backupFilePath) async {
    try {
      final file = File(backupFilePath);
      if (!await file.exists()) {
        return RestoreResult.error('백업 파일을 찾을 수 없습니다.');
      }

      final content = await file.readAsString();
      final backupData = jsonDecode(content) as Map<String, dynamic>;

      // 백업 데이터 검증
      if (!backupData.containsKey('metadata')) {
        return RestoreResult.error('유효하지 않은 백업 파일입니다.');
      }

      final metadata = backupData['metadata'] as Map<String, dynamic>;
      final includes = metadata['includes'] as Map<String, dynamic>;

      // 설정 데이터 복원
      if (includes['settings'] == true && backupData.containsKey('settings')) {
        final settingsData = backupData['settings'] as Map<String, dynamic>;
        final settings = SettingsModel.fromJson(settingsData);
        await _preferencesService.saveSettings(settings);
      }

      // 프로필 데이터 복원
      if (includes['profile'] == true && backupData.containsKey('profile')) {
        final profileData = backupData['profile'] as Map<String, dynamic>;
        final profile = ProfileModel.fromJson(profileData);
        await _profileService.saveProfile(profile);
      }

      // 일기 데이터 복원 (향후 구현)
      if (includes['diaryData'] == true &&
          backupData.containsKey('diaryData')) {
        await _restoreDiaryData(backupData['diaryData']);
      }

      return RestoreResult.success(
        restoredAt: DateTime.now(),
        backupName: metadata['name'] as String,
        backupCreatedAt: DateTime.parse(metadata['createdAt'] as String),
      );
    } catch (e) {
      return RestoreResult.error('복원 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용 가능한 백업 목록 조회
  Future<List<BackupInfo>> getAvailableBackups() async {
    try {
      final backupDir = await _getBackupDirectory();
      if (!await backupDir.exists()) {
        return [];
      }

      final files = await backupDir.list().toList();
      final backupFiles = files
          .where(
            (file) => file is File && file.path.endsWith(_backupFileExtension),
          )
          .cast<File>()
          .toList();

      final backups = <BackupInfo>[];
      for (final file in backupFiles) {
        try {
          final content = await file.readAsString();
          final backupData = jsonDecode(content) as Map<String, dynamic>;
          final metadata = backupData['metadata'] as Map<String, dynamic>;

          backups.add(
            BackupInfo(
              name: metadata['name'] as String,
              filePath: file.path,
              createdAt: DateTime.parse(metadata['createdAt'] as String),
              size: await file.length(),
              includes: metadata['includes'] as Map<String, dynamic>,
            ),
          );
        } catch (e) {
          // 손상된 백업 파일은 건너뛰기
          continue;
        }
      }

      // 생성일 기준으로 정렬 (최신순)
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return backups;
    } catch (e) {
      return [];
    }
  }

  /// 백업 파일 삭제
  Future<bool> deleteBackup(String backupFilePath) async {
    try {
      final file = File(backupFilePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 자동 백업 설정
  Future<void> setAutoBackup({
    required bool enabled,
    int? intervalDays,
    int? maxBackups,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_backup_enabled', enabled);
    if (intervalDays != null) {
      await prefs.setInt('auto_backup_interval_days', intervalDays);
    }
    if (maxBackups != null) {
      await prefs.setInt('auto_backup_max_count', maxBackups);
    }
  }

  /// 자동 백업 설정 조회
  Future<AutoBackupSettings> getAutoBackupSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return AutoBackupSettings(
      enabled: prefs.getBool('auto_backup_enabled') ?? false,
      intervalDays: prefs.getInt('auto_backup_interval_days') ?? 7,
      maxBackups: prefs.getInt('auto_backup_max_count') ?? 5,
    );
  }

  /// 자동 백업 실행 (앱 시작 시 호출)
  Future<void> performAutoBackupIfNeeded() async {
    final settings = await getAutoBackupSettings();
    if (!settings.enabled) return;

    final lastBackup = await _getLastBackupTime();
    if (lastBackup == null) {
      // 첫 백업
      await createBackup(customName: 'auto_backup_initial');
      return;
    }

    final daysSinceLastBackup = DateTime.now().difference(lastBackup).inDays;
    if (daysSinceLastBackup >= settings.intervalDays) {
      await createBackup(
        customName: 'auto_backup_${DateTime.now().millisecondsSinceEpoch}',
      );
      await _cleanupOldBackups(settings.maxBackups);
    }
  }

  /// 백업 디렉토리 경로 조회
  Future<Directory> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(path.join(appDir.path, _backupFolderName));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// 백업 파일 저장
  Future<File> _saveBackupFile(String name, Map<String, dynamic> data) async {
    final backupDir = await _getBackupDirectory();
    final fileName = '$name$_backupFileExtension';
    final file = File(path.join(backupDir.path, fileName));
    await file.writeAsString(jsonEncode(data));
    return file;
  }

  /// 백업 메타데이터 저장
  Future<void> _saveBackupMetadata(
    String name,
    DateTime createdAt,
    String filePath,
  ) async {
    final metadata = {
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'filePath': filePath,
    };
    await _localStorageService.saveJson('backup_$name', metadata);
  }

  /// 마지막 백업 시간 조회
  Future<DateTime?> _getLastBackupTime() async {
    final backups = await getAvailableBackups();
    if (backups.isEmpty) return null;
    return backups.first.createdAt;
  }

  /// 오래된 백업 파일 정리
  Future<void> _cleanupOldBackups(int maxBackups) async {
    final backups = await getAvailableBackups();
    if (backups.length <= maxBackups) return;

    final backupsToDelete = backups.skip(maxBackups).toList();
    for (final backup in backupsToDelete) {
      await deleteBackup(backup.filePath);
    }
  }

  /// 일기 데이터 백업
  Future<Map<String, dynamic>> _backupDiaryData() async {
    try {
      // 일기 데이터를 JSON 형태로 백업
      final databaseService = DatabaseService();
      final db = await databaseService.database;
      final diaryEntries = await db.query('diary_entries');

      return {
        'diary_entries': diaryEntries,
        'backup_date': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
    } catch (e) {
      Logger.error('일기 데이터 백업 실패', tag: 'BackupService', error: e);
      return <String, dynamic>{};
    }
  }

  /// 일기 데이터 복원
  Future<void> _restoreDiaryData(dynamic diaryData) async {
    try {
      if (diaryData is Map<String, dynamic> &&
          diaryData.containsKey('diary_entries')) {
        final databaseService = DatabaseService();
        final db = await databaseService.database;

        // 기존 일기 데이터 삭제 (선택적)
        // await db.delete('diary_entries');

        // 백업된 일기 데이터 복원
        final diaryEntries = diaryData['diary_entries'] as List<dynamic>;
        for (final entry in diaryEntries) {
          await db.insert('diary_entries', entry as Map<String, dynamic>);
        }

        Logger.info(
          '일기 데이터 복원 완료: ${diaryEntries.length}개 항목',
          tag: 'BackupService',
        );
      }
    } catch (e) {
      Logger.error('일기 데이터 복원 실패', tag: 'BackupService', error: e);
    }
  }
}

/// 백업 결과 클래스
class BackupResult {
  final bool isSuccess;
  final String? errorMessage;
  final String? backupName;
  final String? filePath;
  final int? size;
  final DateTime? createdAt;

  BackupResult._({
    required this.isSuccess,
    this.errorMessage,
    this.backupName,
    this.filePath,
    this.size,
    this.createdAt,
  });

  factory BackupResult.success({
    required String backupName,
    required String filePath,
    required int size,
    required DateTime createdAt,
  }) {
    return BackupResult._(
      isSuccess: true,
      backupName: backupName,
      filePath: filePath,
      size: size,
      createdAt: createdAt,
    );
  }

  factory BackupResult.error(String message) {
    return BackupResult._(isSuccess: false, errorMessage: message);
  }
}

/// 복원 결과 클래스
class RestoreResult {
  final bool isSuccess;
  final String? errorMessage;
  final DateTime? restoredAt;
  final String? backupName;
  final DateTime? backupCreatedAt;

  RestoreResult._({
    required this.isSuccess,
    this.errorMessage,
    this.restoredAt,
    this.backupName,
    this.backupCreatedAt,
  });

  factory RestoreResult.success({
    required DateTime restoredAt,
    required String backupName,
    required DateTime backupCreatedAt,
  }) {
    return RestoreResult._(
      isSuccess: true,
      restoredAt: restoredAt,
      backupName: backupName,
      backupCreatedAt: backupCreatedAt,
    );
  }

  factory RestoreResult.error(String message) {
    return RestoreResult._(isSuccess: false, errorMessage: message);
  }
}

/// 백업 정보 클래스
class BackupInfo {
  final String name;
  final String filePath;
  final DateTime createdAt;
  final int size;
  final Map<String, dynamic> includes;

  const BackupInfo({
    required this.name,
    required this.filePath,
    required this.createdAt,
    required this.size,
    required this.includes,
  });

  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get formattedDate {
    return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
  }
}

/// 자동 백업 설정 클래스
class AutoBackupSettings {
  final bool enabled;
  final int intervalDays;
  final int maxBackups;

  const AutoBackupSettings({
    required this.enabled,
    required this.intervalDays,
    required this.maxBackups,
  });
}
