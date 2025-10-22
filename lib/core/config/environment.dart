/// 환경 타입 열거형
enum Environment { development, staging, production }

/// 환경별 구성 관리 클래스
class EnvironmentConfig {
  static Environment _currentEnvironment = Environment.production;

  /// 현재 환경 설정
  static Environment get current => _currentEnvironment;

  /// 환경 설정
  static void setEnvironment(Environment environment) {
    _currentEnvironment = environment;
  }

  /// 개발 환경인지 확인
  static bool get isDevelopment =>
      _currentEnvironment == Environment.development;

  /// 스테이징 환경인지 확인
  static bool get isStaging => _currentEnvironment == Environment.staging;

  /// 프로덕션 환경인지 확인
  static bool get isProduction => _currentEnvironment == Environment.production;

  /// 디버그 모드인지 확인
  static bool get isDebug => isDevelopment || isStaging;

  /// 환경 이름 반환
  static String get environmentName {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'development';
      case Environment.staging:
        return 'staging';
      case Environment.production:
        return 'production';
    }
  }
}
