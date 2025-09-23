import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings_model.dart';

/// 설정 저장 서비스
/// SharedPreferences를 사용하여 사용자 설정을 저장하고 불러오는 서비스입니다.
class PreferencesService {
  static const String _settingsKey = 'app_settings';

  /// 설정 저장
  Future<void> saveSettings(SettingsModel settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = settings.toJson();

      final settingsString = jsonEncode(settingsJson);
      await prefs.setString(_settingsKey, settingsString);
    } catch (e) {
      throw Exception('설정 저장 실패: $e');
    }
  }

  /// 설정 로드
  Future<SettingsModel> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsString = prefs.getString(_settingsKey);

      if (settingsString == null) {
        return const SettingsModel();
      }

      final settingsJson = jsonDecode(settingsString) as Map<String, dynamic>;
      return SettingsModel.fromJson(settingsJson);
    } catch (e) {
      throw Exception('설정 로드 실패: $e');
    }
  }

  /// 특정 설정 값 저장
  Future<void> saveSettingValue(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      } else {
        // 복잡한 객체는 JSON으로 변환
        await prefs.setString(key, jsonEncode(value));
      }
    } catch (e) {
      throw Exception('설정 값 저장 실패: $e');
    }
  }

  /// 특정 설정 값 로드
  Future<T?> loadSettingValue<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (T == String) {
        return prefs.getString(key) as T?;
      } else if (T == int) {
        return prefs.getInt(key) as T?;
      } else if (T == double) {
        return prefs.getDouble(key) as T?;
      } else if (T == bool) {
        return prefs.getBool(key) as T?;
      } else if (T == List<String>) {
        return prefs.getStringList(key) as T?;
      } else {
        // 복잡한 객체는 JSON에서 변환
        final jsonString = prefs.getString(key);
        if (jsonString != null) {
          return jsonDecode(jsonString) as T?;
        }
      }

      return null;
    } catch (e) {
      throw Exception('설정 값 로드 실패: $e');
    }
  }

  /// 설정 초기화
  Future<void> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_settingsKey);
    } catch (e) {
      throw Exception('설정 초기화 실패: $e');
    }
  }

  /// 모든 설정 삭제
  Future<void> clearAllSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('모든 설정 삭제 실패: $e');
    }
  }

  /// 설정 백업 (JSON 문자열로)
  Future<String> backupSettings() async {
    try {
      final settings = await loadSettings();
      return jsonEncode(settings.toJson());
    } catch (e) {
      throw Exception('설정 백업 실패: $e');
    }
  }

  /// 설정 복원 (JSON 문자열에서)
  Future<void> restoreSettings(String settingsJson) async {
    try {
      final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
      final settings = SettingsModel.fromJson(settingsMap);
      await saveSettings(settings);
    } catch (e) {
      throw Exception('설정 복원 실패: $e');
    }
  }

  /// 설정 존재 여부 확인
  Future<bool> hasSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_settingsKey);
    } catch (e) {
      return false;
    }
  }

  /// 설정 크기 확인 (바이트)
  Future<int> getSettingsSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsString = prefs.getString(_settingsKey);
      return settingsString?.length ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// 설정 초기화
  Future<void> resetSettings() async {
    await clearAllSettings();
  }

  /// 설정 검증
  bool validateSettings(SettingsModel settings) {
    // 기본적인 설정 검증 로직
    return true; // 현재는 모든 설정이 유효하다고 가정
  }
}
