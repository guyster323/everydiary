import 'dart:developer' as developer;

/// 로깅 유틸리티 클래스
/// 개발 환경에서는 상세한 로그를, 프로덕션에서는 에러만 로그
class Logger {
  static const bool _isDebugMode = true; // 실제로는 kDebugMode 사용

  /// 디버그 로그
  static void debug(String message, {String? tag}) {
    if (_isDebugMode) {
      developer.log(
        message,
        name: tag ?? 'DEBUG',
        level: 800, // DEBUG level
      );
    }
  }

  /// 정보 로그
  static void info(String message, {String? tag}) {
    if (_isDebugMode) {
      developer.log(
        message,
        name: tag ?? 'INFO',
        level: 700, // INFO level
      );
    }
  }

  /// 경고 로그
  static void warning(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? 'WARNING',
      level: 900, // WARNING level
    );
  }

  /// 에러 로그
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? 'ERROR',
      level: 1000, // ERROR level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 성공 로그
  static void success(String message, {String? tag}) {
    if (_isDebugMode) {
      developer.log(
        message,
        name: tag ?? 'SUCCESS',
        level: 700, // INFO level
      );
    }
  }

  /// 성능 로그
  static void performance(String message, {String? tag}) {
    if (_isDebugMode) {
      developer.log(
        message,
        name: tag ?? 'PERFORMANCE',
        level: 600, // DEBUG level
      );
    }
  }

  /// 네트워크 로그
  static void network(String message, {String? tag}) {
    if (_isDebugMode) {
      developer.log(
        message,
        name: tag ?? 'NETWORK',
        level: 700, // INFO level
      );
    }
  }

  /// 데이터베이스 로그
  static void database(String message, {String? tag}) {
    if (_isDebugMode) {
      developer.log(
        message,
        name: tag ?? 'DATABASE',
        level: 700, // INFO level
      );
    }
  }

  /// 사용자 액션 로그
  static void userAction(String message, {String? tag}) {
    if (_isDebugMode) {
      developer.log(
        message,
        name: tag ?? 'USER_ACTION',
        level: 700, // INFO level
      );
    }
  }
}
