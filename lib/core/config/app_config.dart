import 'package:flutter/foundation.dart';

import 'environment.dart';

/// 앱 구성 데이터 클래스
@immutable
class AppConfig {
  const AppConfig({
    required this.appName,
    required this.appVersion,
    required this.buildNumber,
    required this.apiBaseUrl,
    required this.apiTimeout,
    required this.enableLogging,
    required this.enableAnalytics,
    required this.enableCrashReporting,
    required this.databaseVersion,
    required this.maxDiaryEntries,
    required this.maxImageSize,
    required this.supportedImageFormats,
    required this.featureFlags,
  });

  final String appName;
  final String appVersion;
  final String buildNumber;
  final String apiBaseUrl;
  final Duration apiTimeout;
  final bool enableLogging;
  final bool enableAnalytics;
  final bool enableCrashReporting;
  final int databaseVersion;
  final int maxDiaryEntries;
  final int maxImageSize;
  final List<String> supportedImageFormats;
  final Map<String, bool> featureFlags;

  /// 환경별 구성 팩토리
  factory AppConfig.fromEnvironment(Environment environment) {
    switch (environment) {
      case Environment.development:
        return AppConfig.development();
      case Environment.staging:
        return AppConfig.staging();
      case Environment.production:
        return AppConfig.production();
    }
  }

  /// 개발 환경 구성
  factory AppConfig.development() {
    return const AppConfig(
      appName: 'EveryDiary Dev',
      appVersion: '1.0.1',
      buildNumber: '2',
      apiBaseUrl: 'https://api-dev.everydiary.com',
      apiTimeout: Duration(seconds: 30),
      enableLogging: true,
      enableAnalytics: false,
      enableCrashReporting: false,
      databaseVersion: 1,
      maxDiaryEntries: 1000,
      maxImageSize: 10 * 1024 * 1024, // 10MB
      supportedImageFormats: ['jpg', 'jpeg', 'png', 'gif'],
      featureFlags: {
        'enableVoiceInput': true,
        'enableImageRecognition': true,
        'enableCloudSync': false,
        'enablePremiumFeatures': true,
        'enableBetaFeatures': true,
        'enableDebugMenu': true,
      },
    );
  }

  /// 스테이징 환경 구성
  factory AppConfig.staging() {
    return const AppConfig(
      appName: 'EveryDiary Staging',
      appVersion: '1.0.1',
      buildNumber: '2',
      apiBaseUrl: 'https://api-staging.everydiary.com',
      apiTimeout: Duration(seconds: 20),
      enableLogging: true,
      enableAnalytics: true,
      enableCrashReporting: true,
      databaseVersion: 1,
      maxDiaryEntries: 5000,
      maxImageSize: 5 * 1024 * 1024, // 5MB
      supportedImageFormats: ['jpg', 'jpeg', 'png'],
      featureFlags: {
        'enableVoiceInput': true,
        'enableImageRecognition': true,
        'enableCloudSync': true,
        'enablePremiumFeatures': true,
        'enableBetaFeatures': false,
        'enableDebugMenu': false,
      },
    );
  }

  /// 프로덕션 환경 구성
  factory AppConfig.production() {
    return const AppConfig(
      appName: 'EveryDiary',
      appVersion: '1.0.1',
      buildNumber: '2',
      apiBaseUrl: 'https://api.everydiary.com',
      apiTimeout: Duration(seconds: 15),
      enableLogging: false,
      enableAnalytics: true,
      enableCrashReporting: true,
      databaseVersion: 1,
      maxDiaryEntries: 10000,
      maxImageSize: 5 * 1024 * 1024, // 5MB
      supportedImageFormats: ['jpg', 'jpeg', 'png'],
      featureFlags: {
        'enableVoiceInput': true,
        'enableImageRecognition': true,
        'enableCloudSync': true,
        'enablePremiumFeatures': true,
        'enableBetaFeatures': false,
        'enableDebugMenu': false,
      },
    );
  }

  /// 기능 플래그 확인
  bool isFeatureEnabled(String featureName) {
    return featureFlags[featureName] ?? false;
  }

  /// 복사본 생성 (일부 필드 변경)
  AppConfig copyWith({
    String? appName,
    String? appVersion,
    String? buildNumber,
    String? apiBaseUrl,
    Duration? apiTimeout,
    bool? enableLogging,
    bool? enableAnalytics,
    bool? enableCrashReporting,
    int? databaseVersion,
    int? maxDiaryEntries,
    int? maxImageSize,
    List<String>? supportedImageFormats,
    Map<String, bool>? featureFlags,
  }) {
    return AppConfig(
      appName: appName ?? this.appName,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      apiTimeout: apiTimeout ?? this.apiTimeout,
      enableLogging: enableLogging ?? this.enableLogging,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
      databaseVersion: databaseVersion ?? this.databaseVersion,
      maxDiaryEntries: maxDiaryEntries ?? this.maxDiaryEntries,
      maxImageSize: maxImageSize ?? this.maxImageSize,
      supportedImageFormats:
          supportedImageFormats ?? this.supportedImageFormats,
      featureFlags: featureFlags ?? this.featureFlags,
    );
  }

  @override
  String toString() {
    return 'AppConfig('
        'appName: $appName, '
        'appVersion: $appVersion, '
        'buildNumber: $buildNumber, '
        'apiBaseUrl: $apiBaseUrl, '
        'enableLogging: $enableLogging, '
        'enableAnalytics: $enableAnalytics, '
        'enableCrashReporting: $enableCrashReporting, '
        'databaseVersion: $databaseVersion, '
        'maxDiaryEntries: $maxDiaryEntries, '
        'maxImageSize: $maxImageSize, '
        'supportedImageFormats: $supportedImageFormats, '
        'featureFlags: $featureFlags'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppConfig &&
        other.appName == appName &&
        other.appVersion == appVersion &&
        other.buildNumber == buildNumber &&
        other.apiBaseUrl == apiBaseUrl &&
        other.apiTimeout == apiTimeout &&
        other.enableLogging == enableLogging &&
        other.enableAnalytics == enableAnalytics &&
        other.enableCrashReporting == enableCrashReporting &&
        other.databaseVersion == databaseVersion &&
        other.maxDiaryEntries == maxDiaryEntries &&
        other.maxImageSize == maxImageSize &&
        other.supportedImageFormats == supportedImageFormats &&
        other.featureFlags == featureFlags;
  }

  @override
  int get hashCode {
    return Object.hash(
      appName,
      appVersion,
      buildNumber,
      apiBaseUrl,
      apiTimeout,
      enableLogging,
      enableAnalytics,
      enableCrashReporting,
      databaseVersion,
      maxDiaryEntries,
      maxImageSize,
      supportedImageFormats,
      featureFlags,
    );
  }
}
