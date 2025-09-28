import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 비밀 정보 관리자 클래스
class SecretsManager {
  static SecretsManager? _instance;
  static SecretsManager get instance => _instance ??= SecretsManager._();

  SecretsManager._();

  SharedPreferences? _prefs;
  Map<String, String> _secrets = {};
  String? _encryptionKey;

  /// 초기화
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadEncryptionKey();
    await _loadSecrets();
  }

  /// 암호화 키 로드 또는 생성
  Future<void> _loadEncryptionKey() async {
    _encryptionKey = _prefs?.getString('encryption_key');

    if (_encryptionKey == null) {
      // 새로운 암호화 키 생성
      _encryptionKey = _generateEncryptionKey();
      await _prefs?.setString('encryption_key', _encryptionKey!);
    }
  }

  /// 암호화 키 생성
  String _generateEncryptionKey() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode(random);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 비밀 정보 로드
  Future<void> _loadSecrets() async {
    final secretsJson = _prefs?.getString('encrypted_secrets');
    if (secretsJson != null && _encryptionKey != null) {
      try {
        final decryptedJson = _decrypt(secretsJson, _encryptionKey!);
        final decoded = jsonDecode(decryptedJson);
        _secrets = Map<String, String>.from(decoded as Map);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to load secrets: $e');
        }
        _secrets = {};
      }
    }
  }

  /// 비밀 정보 저장
  Future<void> _saveSecrets() async {
    if (_encryptionKey != null) {
      final secretsJson = jsonEncode(_secrets);
      final encryptedJson = _encrypt(secretsJson, _encryptionKey!);
      await _prefs?.setString('encrypted_secrets', encryptedJson);
    }
  }

  /// 간단한 암호화 (실제 프로덕션에서는 더 강력한 암호화 사용)
  String _encrypt(String plaintext, String key) {
    final keyBytes = utf8.encode(key);
    final plaintextBytes = utf8.encode(plaintext);

    final encrypted = <int>[];
    for (int i = 0; i < plaintextBytes.length; i++) {
      encrypted.add(plaintextBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64Encode(encrypted);
  }

  /// 간단한 복호화
  String _decrypt(String ciphertext, String key) {
    final keyBytes = utf8.encode(key);
    final encryptedBytes = base64Decode(ciphertext);

    final decrypted = <int>[];
    for (int i = 0; i < encryptedBytes.length; i++) {
      decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return utf8.decode(decrypted);
  }

  /// 비밀 정보 설정
  Future<void> setSecret(String key, String value) async {
    _secrets[key] = value;
    await _saveSecrets();
  }

  /// 비밀 정보 가져오기
  String? getSecret(String key) {
    return _secrets[key];
  }

  /// 비밀 정보 제거
  Future<void> removeSecret(String key) async {
    _secrets.remove(key);
    await _saveSecrets();
  }

  /// 모든 비밀 정보 제거
  Future<void> clearSecrets() async {
    _secrets.clear();
    await _saveSecrets();
  }

  /// 환경 변수에서 비밀 정보 로드
  Future<void> loadSecretsFromEnvironment() async {
    final secretMappings = {
      'API_KEY': 'api_key',
      'DATABASE_URL': 'database_url',
      'FIREBASE_API_KEY': 'firebase_api_key',
      'GOOGLE_MAPS_API_KEY': 'google_maps_api_key',
      'ANALYTICS_KEY': 'analytics_key',
      'CRASH_REPORTING_KEY': 'crash_reporting_key',
      'GEMINI_API_KEY': 'gemini_api_key',
      'HUGGING_FACE_API_KEY': 'hugging_face_api_key',
      'SUPABASE_URL': 'supabase_url',
      'SUPABASE_ANON_KEY': 'supabase_anon_key',
    };

    for (final entry in secretMappings.entries) {
      final value = Platform.environment[entry.key];
      if (value != null && value.isNotEmpty) {
        await setSecret(entry.value, value);
        continue;
      }

      final dartDefineValue = _readFromDartDefine(entry.key);
      if (dartDefineValue != null && dartDefineValue.isNotEmpty) {
        await setSecret(entry.value, dartDefineValue);
      }
    }
  }

  String? _readFromDartDefine(String key) {
    switch (key) {
      case 'API_KEY':
        const apiKey = String.fromEnvironment('API_KEY');
        return apiKey.isEmpty ? null : apiKey;
      case 'DATABASE_URL':
        const databaseUrl = String.fromEnvironment('DATABASE_URL');
        return databaseUrl.isEmpty ? null : databaseUrl;
      case 'FIREBASE_API_KEY':
        const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
        return firebaseApiKey.isEmpty ? null : firebaseApiKey;
      case 'GOOGLE_MAPS_API_KEY':
        const mapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
        return mapsApiKey.isEmpty ? null : mapsApiKey;
      case 'ANALYTICS_KEY':
        const analyticsKey = String.fromEnvironment('ANALYTICS_KEY');
        return analyticsKey.isEmpty ? null : analyticsKey;
      case 'CRASH_REPORTING_KEY':
        const crashReportingKey = String.fromEnvironment('CRASH_REPORTING_KEY');
        return crashReportingKey.isEmpty ? null : crashReportingKey;
      case 'GEMINI_API_KEY':
        const geminiKey = String.fromEnvironment('GEMINI_API_KEY');
        return geminiKey.isEmpty ? null : geminiKey;
      case 'HUGGING_FACE_API_KEY':
        const huggingFaceKey = String.fromEnvironment('HUGGING_FACE_API_KEY');
        return huggingFaceKey.isEmpty ? null : huggingFaceKey;
      case 'SUPABASE_URL':
        const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
        return supabaseUrl.isEmpty ? null : supabaseUrl;
      case 'SUPABASE_ANON_KEY':
        const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
        return supabaseAnonKey.isEmpty ? null : supabaseAnonKey;
    }

    return null;
  }

  /// assets에서 비밀 정보 로드 (개발용)
  Future<void> loadSecretsFromAssets() async {
    try {
      final secretsJson = await rootBundle.loadString(
        'assets/config/secrets.json',
      );
      final decoded = jsonDecode(secretsJson);
      final secrets = Map<String, dynamic>.from(decoded as Map);

      for (final entry in secrets.entries) {
        if (entry.value is String) {
          await setSecret(entry.key, entry.value as String);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load secrets from assets: $e');
      }
    }
  }

  /// API 키 가져오기
  String? getApiKey() => getSecret('api_key');

  /// 데이터베이스 URL 가져오기
  String? getDatabaseUrl() => getSecret('database_url');

  /// Firebase API 키 가져오기
  String? getFirebaseApiKey() => getSecret('firebase_api_key');

  /// Google Maps API 키 가져오기
  String? getGoogleMapsApiKey() => getSecret('google_maps_api_key');

  /// 분석 키 가져오기
  String? getAnalyticsKey() => getSecret('analytics_key');

  /// 크래시 리포팅 키 가져오기
  String? getCrashReportingKey() => getSecret('crash_reporting_key');

  /// 비밀 정보 존재 여부 확인
  bool hasSecret(String key) => _secrets.containsKey(key);

  /// 모든 비밀 정보 키 목록
  List<String> get allSecretKeys => _secrets.keys.toList();

  /// 비밀 정보 개수
  int get secretCount => _secrets.length;

  /// 비밀 정보 내보내기 (디버깅용, 실제 값은 마스킹)
  Map<String, String> exportSecretsForDebug() {
    final debugSecrets = <String, String>{};

    for (final entry in _secrets.entries) {
      final value = entry.value;
      if (value.length > 8) {
        debugSecrets[entry.key] =
            '${value.substring(0, 4)}****${value.substring(value.length - 4)}';
      } else {
        debugSecrets[entry.key] = '****';
      }
    }

    return debugSecrets;
  }

  /// 비밀 정보 검증
  bool validateSecrets() {
    final requiredSecrets = <String>{'gemini_api_key', 'hugging_face_api_key'};

    var isValid = true;

    for (final secret in requiredSecrets) {
      if (!hasSecret(secret) || getSecret(secret)?.isEmpty == true) {
        if (kDebugMode) {
          print('Missing required secret: $secret');
        }
        isValid = false;
      }
    }

    return isValid;
  }
}
