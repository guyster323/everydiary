import 'package:flutter/foundation.dart';

import 'config.dart';

/// 구성 서비스 클래스
///
/// 앱 시작 시 모든 구성 시스템을 초기화하고 관리합니다.
class ConfigService {
  static ConfigService? _instance;
  static ConfigService get instance => _instance ??= ConfigService._();

  ConfigService._();

  bool _isInitialized = false;

  /// 초기화 상태 확인
  bool get isInitialized => _isInitialized;

  /// 구성 시스템 초기화
  Future<void> initialize({
    Environment? environment,
    bool loadSecretsFromAssets = true,
    bool loadSecretsFromEnvironment = true,
  }) async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('ConfigService is already initialized');
      }
      return;
    }

    try {
      // 1. 환경 설정
      if (environment != null) {
        EnvironmentConfig.setEnvironment(environment);
      }

      // 2. 구성 관리자 초기화
      await ConfigManager.instance.initialize();

      // 3. 비밀 정보 관리자 초기화
      await SecretsManager.instance.initialize();

      // 4. 비밀 정보 로드 (플랫폼별 처리)
      if (loadSecretsFromEnvironment && !kIsWeb) {
        try {
          await SecretsManager.instance.loadSecretsFromEnvironment();
        } catch (e) {
          if (kDebugMode) {
            print('Failed to load secrets from environment: $e');
          }
        }
      }

      if (loadSecretsFromAssets && !kIsWeb) {
        try {
          await SecretsManager.instance.loadSecretsFromAssets();
        } catch (e) {
          if (kDebugMode) {
            print('Failed to load secrets from assets: $e');
          }
        }
      }

      // 5. 기능 플래그 시스템 초기화
      FeatureFlagManager.instance.registerDefaultFlags();

      // 6. 비밀 정보 검증
      if (!SecretsManager.instance.validateSecrets()) {
        if (kDebugMode) {
          print('Warning: Some required secrets are missing');
        }
      }

      // 7. 기능 플래그 검증
      if (!FeatureFlagManager.instance.validateFlags()) {
        if (kDebugMode) {
          print('Warning: Some feature flags have invalid configuration');
        }
      }

      _isInitialized = true;

      if (kDebugMode) {
        print('ConfigService initialized successfully');
        print('Environment: ${EnvironmentConfig.environmentName}');
        print('App Name: ${ConfigManager.instance.config.appName}');
        print('API Base URL: ${ConfigManager.instance.apiBaseUrl}');
        print(
          'Feature Flags: ${FeatureFlagManager.instance.getEnabledFlags()}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize ConfigService: $e');
      }
      rethrow;
    }
  }

  /// 구성 시스템 재초기화
  Future<void> reinitialize({
    Environment? environment,
    bool loadSecretsFromAssets = true,
    bool loadSecretsFromEnvironment = true,
  }) async {
    _isInitialized = false;
    await initialize(
      environment: environment,
      loadSecretsFromAssets: loadSecretsFromAssets,
      loadSecretsFromEnvironment: loadSecretsFromEnvironment,
    );
  }

  /// 구성 시스템 정리
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      // 기능 플래그 매니저 정리
      FeatureFlagManager.instance.dispose();

      // 런타임 구성 스트림 정리
      RuntimeConfigStream.instance.dispose();

      _isInitialized = false;

      if (kDebugMode) {
        print('ConfigService disposed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing ConfigService: $e');
      }
    }
  }

  /// 구성 상태 확인
  Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'environment': EnvironmentConfig.environmentName,
      'appConfig': ConfigManager.instance.config.toString(),
      'secretsCount': SecretsManager.instance.secretCount,
      'featureFlagsCount': FeatureFlagManager.instance
          .getFlagStatistics()['total_flags'],
      'runtimeConfigCount': ConfigManager.instance.allRuntimeConfig.length,
    };
  }

  /// 구성 내보내기 (디버깅용)
  Map<String, dynamic> exportConfig() {
    if (!_isInitialized) {
      return {'error': 'ConfigService not initialized'};
    }

    return {
      'status': getStatus(),
      'appConfig': ConfigManager.instance.exportConfig(),
      'secrets': SecretsManager.instance.exportSecretsForDebug(),
      'featureFlags': FeatureFlagManager.instance.exportFlagsForDebug(),
      'runtimeConfig': ConfigManager.instance.allRuntimeConfig,
      'changeHistory': RuntimeConfigManager.instance.exportChangeHistory(),
    };
  }

  /// 구성 검증
  bool validateConfig() {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('ConfigService not initialized');
      }
      return false;
    }

    try {
      // 비밀 정보 검증
      if (!SecretsManager.instance.validateSecrets()) {
        if (kDebugMode) {
          print('Secrets validation failed');
        }
        return false;
      }

      // 기능 플래그 검증
      if (!FeatureFlagManager.instance.validateFlags()) {
        if (kDebugMode) {
          print('Feature flags validation failed');
        }
        return false;
      }

      // 구성 관리자 검증
      final config = ConfigManager.instance.config;
      if (config.apiBaseUrl.isEmpty) {
        if (kDebugMode) {
          print('API base URL is empty');
        }
        return false;
      }

      if (config.appName.isEmpty) {
        if (kDebugMode) {
          print('App name is empty');
        }
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Config validation error: $e');
      }
      return false;
    }
  }

  /// 구성 리셋 (기본값으로)
  Future<void> resetToDefaults() async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('ConfigService not initialized');
      }
      return;
    }

    try {
      // 런타임 구성 리셋
      await ConfigManager.instance.resetToDefaults();

      // 런타임 구성 변경 리셋
      await RuntimeConfigManager.instance.resetAllRuntimeConfig();

      if (kDebugMode) {
        print('Config reset to defaults successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting config: $e');
      }
      rethrow;
    }
  }
}
