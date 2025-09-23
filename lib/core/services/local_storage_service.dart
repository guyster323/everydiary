import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 로컬 저장소 서비스
/// SharedPreferences와 파일 시스템을 통한 고급 로컬 저장 기능을 제공합니다.
class LocalStorageService {
  static LocalStorageService? _instance;
  static LocalStorageService get instance =>
      _instance ??= LocalStorageService._();

  LocalStorageService._();

  SharedPreferences? _prefs;

  /// SharedPreferences 초기화
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 기본 저장 메서드들
  Future<bool> setString(String key, String value) async {
    await initialize();
    return await _prefs!.setString(key, value);
  }

  Future<String?> getString(String key) async {
    await initialize();
    return _prefs!.getString(key);
  }

  Future<bool> setInt(String key, int value) async {
    await initialize();
    return await _prefs!.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    await initialize();
    return _prefs!.getInt(key);
  }

  Future<bool> setBool(String key, bool value) async {
    await initialize();
    return await _prefs!.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    await initialize();
    return _prefs!.getBool(key);
  }

  Future<bool> setDouble(String key, double value) async {
    await initialize();
    return await _prefs!.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    await initialize();
    return _prefs!.getDouble(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    await initialize();
    return await _prefs!.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    await initialize();
    return _prefs!.getStringList(key);
  }

  /// JSON 객체 저장/로드
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      debugPrint('JSON 저장 실패: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    try {
      final jsonString = await getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('JSON 로드 실패: $e');
      return null;
    }
  }

  /// 복합 데이터 저장/로드
  Future<bool> setComplexData(String key, dynamic data) async {
    try {
      if (data is Map || data is List) {
        return await setJson(key, {'data': data});
      } else {
        return await setString(key, data.toString());
      }
    } catch (e) {
      debugPrint('복합 데이터 저장 실패: $e');
      return false;
    }
  }

  Future<T?> getComplexData<T>(String key) async {
    try {
      final json = await getJson(key);
      if (json == null) return null;
      return json['data'] as T?;
    } catch (e) {
      debugPrint('복합 데이터 로드 실패: $e');
      return null;
    }
  }

  /// 키 존재 여부 확인
  Future<bool> containsKey(String key) async {
    await initialize();
    return _prefs!.containsKey(key);
  }

  /// 키 제거
  Future<bool> remove(String key) async {
    await initialize();
    return await _prefs!.remove(key);
  }

  /// 모든 키 제거
  Future<bool> clear() async {
    await initialize();
    return await _prefs!.clear();
  }

  /// 모든 키 목록 가져오기
  Future<Set<String>> getKeys() async {
    await initialize();
    return _prefs!.getKeys();
  }

  /// 저장소 크기 확인 (바이트)
  Future<int> getStorageSize() async {
    await initialize();
    int totalSize = 0;

    for (final key in _prefs!.getKeys()) {
      final value = _prefs!.get(key);
      if (value is String) {
        totalSize += value.length;
      } else if (value is List<String>) {
        totalSize += value.join().length;
      }
    }

    return totalSize;
  }

  /// JSON 데이터 저장
  Future<bool> saveJson(String key, Map<String, dynamic> data) async {
    await initialize();
    final jsonString = jsonEncode(data);
    return await _prefs!.setString(key, jsonString);
  }

  /// JSON 데이터 로드
  Future<Map<String, dynamic>?> loadJson(String key) async {
    await initialize();
    final jsonString = _prefs!.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  /// 파일 시스템 저장
  Future<File> saveToFile(String fileName, String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    return file;
  }

  /// 파일에서 로드
  Future<String?> loadFromFile(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      debugPrint('파일 로드 실패: $e');
      return null;
    }
  }

  /// 파일 삭제
  Future<bool> deleteFile(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('파일 삭제 실패: $e');
      return false;
    }
  }

  /// 파일 존재 여부 확인
  Future<bool> fileExists(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      return await file.exists();
    } catch (e) {
      debugPrint('파일 존재 확인 실패: $e');
      return false;
    }
  }

  /// 백업 생성
  Future<Map<String, dynamic>> createBackup() async {
    await initialize();

    final backup = <String, dynamic>{};

    for (final key in _prefs!.getKeys()) {
      final value = _prefs!.get(key);
      backup[key] = value;
    }

    return {
      'data': backup,
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  /// 백업 복원
  Future<bool> restoreBackup(Map<String, dynamic> backup) async {
    try {
      await initialize();

      final data = backup['data'] as Map<String, dynamic>?;
      if (data == null) return false;

      // 기존 데이터 백업
      final currentBackup = await createBackup();

      try {
        // 새 데이터로 교체
        await clear();

        for (final entry in data.entries) {
          final key = entry.key;
          final value = entry.value;

          if (value is String) {
            await setString(key, value);
          } else if (value is int) {
            await setInt(key, value);
          } else if (value is bool) {
            await setBool(key, value);
          } else if (value is double) {
            await setDouble(key, value);
          } else if (value is List<String>) {
            await setStringList(key, value);
          }
        }

        return true;
      } catch (e) {
        // 복원 실패 시 이전 데이터로 롤백
        await restoreBackup(currentBackup);
        rethrow;
      }
    } catch (e) {
      debugPrint('백업 복원 실패: $e');
      return false;
    }
  }

  /// 저장소 상태 확인
  Future<StorageStatus> getStorageStatus() async {
    await initialize();

    final keys = _prefs!.getKeys();
    final size = await getStorageSize();

    return StorageStatus(
      totalKeys: keys.length,
      totalSize: size,
      lastModified: DateTime.now(),
      isHealthy: true,
    );
  }

  /// 저장소 정리 (사용하지 않는 키 제거)
  Future<int> cleanupStorage(List<String> validKeys) async {
    await initialize();

    final allKeys = _prefs!.getKeys();
    final keysToRemove = allKeys.where((key) => !validKeys.contains(key));

    int removedCount = 0;
    for (final key in keysToRemove) {
      if (await remove(key)) {
        removedCount++;
      }
    }

    return removedCount;
  }

  /// 암호화된 저장 (간단한 Base64 인코딩)
  Future<bool> setEncrypted(String key, String value) async {
    try {
      final encoded = base64Encode(utf8.encode(value));
      return await setString('encrypted_$key', encoded);
    } catch (e) {
      debugPrint('암호화 저장 실패: $e');
      return false;
    }
  }

  /// 암호화된 로드
  Future<String?> getEncrypted(String key) async {
    try {
      final encoded = await getString('encrypted_$key');
      if (encoded == null) return null;

      final decoded = utf8.decode(base64Decode(encoded));
      return decoded;
    } catch (e) {
      debugPrint('암호화 로드 실패: $e');
      return null;
    }
  }

  /// 설정 마이그레이션
  Future<bool> migrateSettings(String oldKey, String newKey) async {
    try {
      final oldValue = await getString(oldKey);
      if (oldValue != null) {
        await setString(newKey, oldValue);
        await remove(oldKey);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('설정 마이그레이션 실패: $e');
      return false;
    }
  }
}

/// 저장소 상태 모델
class StorageStatus {
  final int totalKeys;
  final int totalSize;
  final DateTime lastModified;
  final bool isHealthy;

  const StorageStatus({
    required this.totalKeys,
    required this.totalSize,
    required this.lastModified,
    required this.isHealthy,
  });

  String get formattedSize {
    if (totalSize < 1024) {
      return '$totalSize B';
    } else if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
