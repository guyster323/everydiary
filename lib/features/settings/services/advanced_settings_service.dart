import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/services/local_storage_service.dart';
import '../models/settings_enums.dart';
import '../models/settings_model.dart';

/// 고급 설정 서비스
/// LocalStorageService를 사용하여 고급 설정 저장 기능을 제공합니다.
class AdvancedSettingsService {
  static const String _settingsKey = 'advanced_app_settings';
  static const String _settingsVersionKey = 'settings_version';
  static const String _settingsBackupKey = 'settings_backup';
  static const String _settingsHistoryKey = 'settings_history';

  final LocalStorageService _storage = LocalStorageService.instance;

  /// 설정 저장
  Future<bool> saveSettings(SettingsModel settings) async {
    try {
      // 현재 설정을 백업으로 저장
      await _backupCurrentSettings();

      // 설정 히스토리에 추가
      await _addToHistory(settings);

      // 새 설정 저장
      final success = await _storage.setJson(_settingsKey, settings.toJson());

      if (success) {
        // 버전 정보 업데이트
        await _storage.setString(_settingsVersionKey, '1.0.0');
        debugPrint('설정 저장 성공');
      }

      return success;
    } catch (e) {
      debugPrint('설정 저장 실패: $e');
      return false;
    }
  }

  /// 설정 로드
  Future<SettingsModel> loadSettings() async {
    try {
      final settingsJson = await _storage.getJson(_settingsKey);

      if (settingsJson == null) {
        debugPrint('설정이 없어서 기본값 반환');
        return const SettingsModel();
      }

      return SettingsModel.fromJson(settingsJson);
    } catch (e) {
      debugPrint('설정 로드 실패: $e');
      return const SettingsModel();
    }
  }

  /// 특정 설정 값 저장
  Future<bool> saveSettingValue<T>(String key, T value) async {
    try {
      final currentSettings = await loadSettings();
      final updatedSettings = _updateSettingValue(currentSettings, key, value);
      return await saveSettings(updatedSettings);
    } catch (e) {
      debugPrint('설정 값 저장 실패: $e');
      return false;
    }
  }

  /// 특정 설정 값 로드
  Future<T?> getSettingValue<T>(String key) async {
    try {
      final settings = await loadSettings();
      return _getSettingValue(settings, key) as T?;
    } catch (e) {
      debugPrint('설정 값 로드 실패: $e');
      return null;
    }
  }

  /// 설정 백업
  Future<bool> backupSettings() async {
    try {
      final settings = await loadSettings();
      final backup = {
        'settings': settings.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
        'version': await _storage.getString(_settingsVersionKey) ?? '1.0.0',
      };

      return await _storage.setJson(_settingsBackupKey, backup);
    } catch (e) {
      debugPrint('설정 백업 실패: $e');
      return false;
    }
  }

  /// 설정 복원
  Future<bool> restoreSettings() async {
    try {
      final backup = await _storage.getJson(_settingsBackupKey);

      if (backup == null) {
        debugPrint('백업이 없습니다');
        return false;
      }

      final settingsJson = backup['settings'] as Map<String, dynamic>;
      final settings = SettingsModel.fromJson(settingsJson);

      return await saveSettings(settings);
    } catch (e) {
      debugPrint('설정 복원 실패: $e');
      return false;
    }
  }

  /// 설정 초기화
  Future<bool> resetSettings() async {
    try {
      // 현재 설정을 백업으로 저장
      await _backupCurrentSettings();

      // 기본 설정으로 초기화
      const defaultSettings = SettingsModel();
      return await saveSettings(defaultSettings);
    } catch (e) {
      debugPrint('설정 초기화 실패: $e');
      return false;
    }
  }

  /// 설정 내보내기 (JSON 문자열)
  Future<String?> exportSettings() async {
    try {
      final settings = await loadSettings();
      final exportData = {
        'settings': settings.toJson(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': await _storage.getString(_settingsVersionKey) ?? '1.0.0',
        'app': 'EveryDiary',
      };

      return jsonEncode(exportData);
    } catch (e) {
      debugPrint('설정 내보내기 실패: $e');
      return null;
    }
  }

  /// 설정 가져오기 (JSON 문자열에서)
  Future<bool> importSettings(String settingsJson) async {
    try {
      final importData = jsonDecode(settingsJson) as Map<String, dynamic>;

      // 버전 호환성 확인
      final version = importData['version'] as String?;
      if (version != null && !_isVersionCompatible(version)) {
        debugPrint('호환되지 않는 버전: $version');
        return false;
      }

      final settingsMap = importData['settings'] as Map<String, dynamic>;
      final settings = SettingsModel.fromJson(settingsMap);

      return await saveSettings(settings);
    } catch (e) {
      debugPrint('설정 가져오기 실패: $e');
      return false;
    }
  }

  /// 설정 히스토리 가져오기
  Future<List<SettingsHistoryEntry>> getSettingsHistory() async {
    try {
      final history = await _storage.getComplexData<List<dynamic>>(
        _settingsHistoryKey,
      );

      if (history == null) return [];

      return history.map((entry) {
        final map = entry as Map<String, dynamic>;
        return SettingsHistoryEntry.fromJson(map);
      }).toList();
    } catch (e) {
      debugPrint('설정 히스토리 로드 실패: $e');
      return [];
    }
  }

  /// 설정 히스토리에서 복원
  Future<bool> restoreFromHistory(String historyId) async {
    try {
      final history = await getSettingsHistory();
      final entry = history.firstWhere(
        (entry) => entry.id == historyId,
        orElse: () => throw Exception('히스토리 항목을 찾을 수 없습니다'),
      );

      return await saveSettings(entry.settings);
    } catch (e) {
      debugPrint('히스토리에서 복원 실패: $e');
      return false;
    }
  }

  /// 설정 히스토리 정리
  Future<int> cleanupHistory({int maxEntries = 10}) async {
    try {
      final history = await getSettingsHistory();

      if (history.length <= maxEntries) return 0;

      // 오래된 항목들 제거
      final sortedHistory = List<SettingsHistoryEntry>.from(history)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final keepHistory = sortedHistory.take(maxEntries).toList();
      final cleanedHistory = keepHistory
          .map((entry) => entry.toJson())
          .toList();

      await _storage.setComplexData(_settingsHistoryKey, cleanedHistory);

      return history.length - keepHistory.length;
    } catch (e) {
      debugPrint('히스토리 정리 실패: $e');
      return 0;
    }
  }

  /// 설정 검증
  Future<bool> validateSettings() async {
    try {
      final settings = await loadSettings();
      return _validateSettingsModel(settings);
    } catch (e) {
      debugPrint('설정 검증 실패: $e');
      return false;
    }
  }

  /// 설정 통계
  Future<SettingsStatistics> getSettingsStatistics() async {
    try {
      final history = await getSettingsHistory();
      final storageStatus = await _storage.getStorageStatus();

      return SettingsStatistics(
        totalChanges: history.length,
        lastModified: history.isNotEmpty ? history.first.timestamp : null,
        storageSize: storageStatus.totalSize,
        isValid: await validateSettings(),
      );
    } catch (e) {
      debugPrint('설정 통계 생성 실패: $e');
      return const SettingsStatistics();
    }
  }

  /// 현재 설정 백업
  Future<void> _backupCurrentSettings() async {
    try {
      final currentSettings = await loadSettings();
      final backup = {
        'settings': currentSettings.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _storage.setJson('${_settingsBackupKey}_current', backup);
    } catch (e) {
      debugPrint('현재 설정 백업 실패: $e');
    }
  }

  /// 히스토리에 추가
  Future<void> _addToHistory(SettingsModel settings) async {
    try {
      final history = await getSettingsHistory();

      final entry = SettingsHistoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        settings: settings,
        timestamp: DateTime.now(),
        description: '설정 변경',
      );

      history.insert(0, entry);

      // 최대 20개 항목만 유지
      if (history.length > 20) {
        history.removeRange(20, history.length);
      }

      final historyJson = history.map((entry) => entry.toJson()).toList();
      await _storage.setComplexData(_settingsHistoryKey, historyJson);
    } catch (e) {
      debugPrint('히스토리 추가 실패: $e');
    }
  }

  /// 설정 값 업데이트
  SettingsModel _updateSettingValue(
    SettingsModel settings,
    String key,
    dynamic value,
  ) {
    switch (key) {
      case 'themeMode':
        return settings.copyWith(themeMode: value as ThemeMode);
      case 'fontSize':
        return settings.copyWith(fontSize: value as FontSize);
      case 'language':
        return settings.copyWith(language: value as Language);
      case 'dailyReminder':
        return settings.copyWith(dailyReminder: value as bool);
      case 'reminderTime':
        return settings.copyWith(reminderTime: value as TimeOfDay);
      case 'highContrast':
        return settings.copyWith(highContrast: value as bool);
      case 'textToSpeech':
        return settings.copyWith(textToSpeech: value as bool);
      case 'autoSave':
        return settings.copyWith(autoSave: value as bool);
      case 'autoSaveInterval':
        return settings.copyWith(autoSaveInterval: value as int);
      case 'showStatistics':
        return settings.copyWith(showStatistics: value as bool);
      case 'enableAnalytics':
        return settings.copyWith(enableAnalytics: value as bool);
      case 'enableCrashReporting':
        return settings.copyWith(enableCrashReporting: value as bool);
      default:
        return settings;
    }
  }

  /// 설정 값 가져오기
  dynamic _getSettingValue(SettingsModel settings, String key) {
    switch (key) {
      case 'themeMode':
        return settings.themeMode;
      case 'fontSize':
        return settings.fontSize;
      case 'language':
        return settings.language;
      case 'dailyReminder':
        return settings.dailyReminder;
      case 'reminderTime':
        return settings.reminderTime;
      case 'highContrast':
        return settings.highContrast;
      case 'textToSpeech':
        return settings.textToSpeech;
      case 'autoSave':
        return settings.autoSave;
      case 'autoSaveInterval':
        return settings.autoSaveInterval;
      case 'showStatistics':
        return settings.showStatistics;
      case 'enableAnalytics':
        return settings.enableAnalytics;
      case 'enableCrashReporting':
        return settings.enableCrashReporting;
      default:
        return null;
    }
  }

  /// 버전 호환성 확인
  bool _isVersionCompatible(String version) {
    // 간단한 버전 호환성 확인
    const currentVersion = '1.0.0';
    return version == currentVersion;
  }

  /// 설정 모델 검증
  bool _validateSettingsModel(SettingsModel settings) {
    // 기본적인 설정 검증
    if (settings.autoSaveInterval < 1 || settings.autoSaveInterval > 60) {
      return false;
    }

    return true;
  }
}

/// 설정 히스토리 항목
class SettingsHistoryEntry {
  final String id;
  final SettingsModel settings;
  final DateTime timestamp;
  final String description;

  const SettingsHistoryEntry({
    required this.id,
    required this.settings,
    required this.timestamp,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'settings': settings.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }

  factory SettingsHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SettingsHistoryEntry(
      id: json['id'] as String,
      settings: SettingsModel.fromJson(
        json['settings'] as Map<String, dynamic>,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String,
    );
  }
}

/// 설정 통계
class SettingsStatistics {
  final int totalChanges;
  final DateTime? lastModified;
  final int storageSize;
  final bool isValid;

  const SettingsStatistics({
    this.totalChanges = 0,
    this.lastModified,
    this.storageSize = 0,
    this.isValid = true,
  });

  String get formattedStorageSize {
    if (storageSize < 1024) {
      return '$storageSize B';
    } else if (storageSize < 1024 * 1024) {
      return '${(storageSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(storageSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
