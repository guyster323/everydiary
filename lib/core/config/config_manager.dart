import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_config.dart';
import 'environment.dart';

/// 구성 관리자 클래스
class ConfigManager {
  static ConfigManager? _instance;
  static ConfigManager get instance => _instance ??= ConfigManager._();

  ConfigManager._();

  AppConfig? _appConfig;
  SharedPreferences? _prefs;
  Map<String, dynamic> _runtimeConfig = {};

  /// 초기화
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadRuntimeConfig();
  }

  /// 앱 구성 가져오기
  AppConfig get config {
    _appConfig ??= AppConfig.fromEnvironment(EnvironmentConfig.current);
    return _appConfig!;
  }

  /// 런타임 구성 로드
  void _loadRuntimeConfig() {
    final configJson = _prefs?.getString('runtime_config');
    if (configJson != null) {
      try {
        final decoded = jsonDecode(configJson);
        _runtimeConfig = Map<String, dynamic>.from(decoded as Map);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to load runtime config: $e');
        }
        _runtimeConfig = {};
      }
    }
  }

  /// 런타임 구성 저장
  Future<void> _saveRuntimeConfig() async {
    final configJson = jsonEncode(_runtimeConfig);
    await _prefs?.setString('runtime_config', configJson);
  }

  /// 런타임 구성 값 가져오기
  T? getRuntimeValue<T>(String key, {T? defaultValue}) {
    final value = _runtimeConfig[key];
    if (value == null) return defaultValue;

    try {
      return value as T;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cast runtime config value for key $key: $e');
      }
      return defaultValue;
    }
  }

  /// 런타임 구성 값 설정
  Future<void> setRuntimeValue<T>(String key, T value) async {
    _runtimeConfig[key] = value;
    await _saveRuntimeConfig();
  }

  /// 런타임 구성 값 제거
  Future<void> removeRuntimeValue(String key) async {
    _runtimeConfig.remove(key);
    await _saveRuntimeConfig();
  }

  /// 런타임 구성 초기화
  Future<void> clearRuntimeConfig() async {
    _runtimeConfig.clear();
    await _saveRuntimeConfig();
  }

  /// 기능 플래그 가져오기 (런타임 오버라이드 지원)
  bool isFeatureEnabled(String featureName) {
    // 런타임 구성에서 먼저 확인
    final runtimeValue = getRuntimeValue<bool>(featureName);
    if (runtimeValue != null) {
      return runtimeValue;
    }

    // 기본 구성에서 확인
    return config.isFeatureEnabled(featureName);
  }

  /// 기능 플래그 설정 (런타임)
  Future<void> setFeatureFlag(String featureName, bool enabled) async {
    await setRuntimeValue(featureName, enabled);
  }

  /// API 기본 URL 가져오기 (런타임 오버라이드 지원)
  String get apiBaseUrl {
    return getRuntimeValue<String>('api_base_url') ?? config.apiBaseUrl;
  }

  /// API 기본 URL 설정 (런타임)
  Future<void> setApiBaseUrl(String url) async {
    await setRuntimeValue('api_base_url', url);
  }

  /// 로깅 활성화 여부 가져오기 (런타임 오버라이드 지원)
  bool get enableLogging {
    return getRuntimeValue<bool>('enable_logging') ?? config.enableLogging;
  }

  /// 로깅 활성화 설정 (런타임)
  Future<void> setEnableLogging(bool enabled) async {
    await setRuntimeValue('enable_logging', enabled);
  }

  /// 분석 활성화 여부 가져오기 (런타임 오버라이드 지원)
  bool get enableAnalytics {
    return getRuntimeValue<bool>('enable_analytics') ?? config.enableAnalytics;
  }

  /// 분석 활성화 설정 (런타임)
  Future<void> setEnableAnalytics(bool enabled) async {
    await setRuntimeValue('enable_analytics', enabled);
  }

  /// 최대 일기 항목 수 가져오기 (런타임 오버라이드 지원)
  int get maxDiaryEntries {
    return getRuntimeValue<int>('max_diary_entries') ?? config.maxDiaryEntries;
  }

  /// 최대 일기 항목 수 설정 (런타임)
  Future<void> setMaxDiaryEntries(int maxEntries) async {
    await setRuntimeValue('max_diary_entries', maxEntries);
  }

  /// 최대 이미지 크기 가져오기 (런타임 오버라이드 지원)
  int get maxImageSize {
    return getRuntimeValue<int>('max_image_size') ?? config.maxImageSize;
  }

  /// 최대 이미지 크기 설정 (런타임)
  Future<void> setMaxImageSize(int maxSize) async {
    await setRuntimeValue('max_image_size', maxSize);
  }

  /// 환경 변수에서 값 가져오기
  String? getEnvironmentVariable(String key) {
    return Platform.environment[key];
  }

  /// 환경 변수 설정 (런타임에서만)
  Future<void> setEnvironmentVariable(String key, String value) async {
    await setRuntimeValue('env_$key', value);
  }

  /// 환경 변수 가져오기 (런타임 오버라이드 지원)
  String? getEnvironmentValue(String key) {
    // 런타임 구성에서 먼저 확인
    final runtimeValue = getRuntimeValue<String>('env_$key');
    if (runtimeValue != null) {
      return runtimeValue;
    }

    // 시스템 환경 변수에서 확인
    return getEnvironmentVariable(key);
  }

  /// 모든 런타임 구성 가져오기
  Map<String, dynamic> get allRuntimeConfig => Map.unmodifiable(_runtimeConfig);

  /// 구성 리셋 (기본값으로)
  Future<void> resetToDefaults() async {
    await clearRuntimeConfig();
    _appConfig = AppConfig.fromEnvironment(EnvironmentConfig.current);
  }

  /// 구성 내보내기 (디버깅용)
  Map<String, dynamic> exportConfig() {
    return {
      'environment': EnvironmentConfig.environmentName,
      'app_config': {
        'app_name': config.appName,
        'app_version': config.appVersion,
        'build_number': config.buildNumber,
        'api_base_url': config.apiBaseUrl,
        'api_timeout': config.apiTimeout.inSeconds,
        'enable_logging': config.enableLogging,
        'enable_analytics': config.enableAnalytics,
        'enable_crash_reporting': config.enableCrashReporting,
        'database_version': config.databaseVersion,
        'max_diary_entries': config.maxDiaryEntries,
        'max_image_size': config.maxImageSize,
        'supported_image_formats': config.supportedImageFormats,
        'feature_flags': config.featureFlags,
      },
      'runtime_config': _runtimeConfig,
      'environment_variables': Platform.environment,
    };
  }
}
