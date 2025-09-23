import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'logger_service.dart';

/// 에러 타입
enum ErrorType {
  network,
  authentication,
  validation,
  database,
  fileSystem,
  permission,
  unknown,
}

/// 에러 심각도
enum ErrorSeverity { low, medium, high, critical }

/// 앱 에러 클래스
class AppError {
  final String message;
  final ErrorType type;
  final ErrorSeverity severity;
  final String? code;
  final Map<String, dynamic>? metadata;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  const AppError({
    required this.message,
    required this.type,
    required this.severity,
    this.code,
    this.metadata,
    this.stackTrace,
    required this.timestamp,
  });

  /// 현재 시간으로 AppError 생성
  factory AppError.now({
    required String message,
    required ErrorType type,
    required ErrorSeverity severity,
    String? code,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    return AppError(
      message: message,
      type: type,
      severity: severity,
      code: code,
      metadata: metadata,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'AppError(type: $type, severity: $severity, message: $message, code: $code)';
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'type': type.name,
      'severity': severity.name,
      'code': code,
      'metadata': metadata,
      'stackTrace': stackTrace?.toString(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// 에러 핸들러 서비스
class ErrorHandlerService {
  static ErrorHandlerService? _instance;
  static ErrorHandlerService get instance =>
      _instance ??= ErrorHandlerService._();

  ErrorHandlerService._();

  final List<AppError> _recentErrors = [];
  final int _maxRecentErrors = 100;

  StreamController<AppError>? _errorStreamController;
  Stream<AppError>? _errorStream;

  /// 초기화
  void initialize() {
    _errorStreamController = StreamController<AppError>.broadcast();
    _errorStream = _errorStreamController!.stream;
  }

  /// 에러 스트림 가져오기
  Stream<AppError>? get errorStream => _errorStream;

  /// 에러 처리
  void handleError(
    Object error, {
    StackTrace? stackTrace,
    ErrorType? type,
    ErrorSeverity? severity,
    String? code,
    Map<String, dynamic>? metadata,
    String? context,
  }) {
    final appError = _createAppError(
      error,
      stackTrace: stackTrace,
      type: type,
      severity: severity,
      code: code,
      metadata: metadata,
      context: context,
    );

    _processError(appError);
  }

  /// AppError 생성
  AppError _createAppError(
    Object error, {
    StackTrace? stackTrace,
    ErrorType? type,
    ErrorSeverity? severity,
    String? code,
    Map<String, dynamic>? metadata,
    String? context,
  }) {
    String message;
    ErrorType errorType = type ?? ErrorType.unknown;
    ErrorSeverity errorSeverity = severity ?? ErrorSeverity.medium;

    // 에러 타입별 메시지 처리
    if (error is AppError) {
      return error;
    } else if (error is FormatException) {
      message = '데이터 형식이 올바르지 않습니다: ${error.message}';
      errorType = ErrorType.validation;
    } else if (error is TimeoutException) {
      message = '요청 시간이 초과되었습니다';
      errorType = ErrorType.network;
      errorSeverity = ErrorSeverity.medium;
    } else if (error is UnimplementedError) {
      message = '구현되지 않은 기능입니다: ${error.message}';
      errorType = ErrorType.unknown;
      errorSeverity = ErrorSeverity.high;
    } else if (error is UnsupportedError) {
      message = '지원되지 않는 작업입니다: ${error.message}';
      errorType = ErrorType.unknown;
      errorSeverity = ErrorSeverity.high;
    } else if (error is StateError) {
      message = '잘못된 상태입니다: ${error.message}';
      errorType = ErrorType.unknown;
      errorSeverity = ErrorSeverity.medium;
    } else if (error is ArgumentError) {
      message = '잘못된 인수입니다: ${error.message}';
      errorType = ErrorType.validation;
    } else if (error is RangeError) {
      message = '범위를 벗어난 값입니다: ${error.message}';
      errorType = ErrorType.validation;
    } else if (error is NoSuchMethodError) {
      message = '존재하지 않는 메서드입니다: ${error.toString()}';
      errorType = ErrorType.unknown;
      errorSeverity = ErrorSeverity.high;
    } else {
      message = error.toString();
    }

    // 컨텍스트 정보 추가
    if (context != null) {
      message = '[$context] $message';
    }

    return AppError(
      message: message,
      type: errorType,
      severity: errorSeverity,
      code: code,
      metadata: metadata,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );
  }

  /// 에러 처리 로직
  void _processError(AppError error) {
    // 최근 에러 목록에 추가
    _recentErrors.add(error);
    if (_recentErrors.length > _maxRecentErrors) {
      _recentErrors.removeAt(0);
    }

    // 로그 기록
    _logError(error);

    // 에러 스트림으로 전송
    _errorStreamController?.add(error);

    // 심각도에 따른 추가 처리
    switch (error.severity) {
      case ErrorSeverity.critical:
        _handleCriticalError(error);
        break;
      case ErrorSeverity.high:
        _handleHighSeverityError(error);
        break;
      case ErrorSeverity.medium:
        _handleMediumSeverityError(error);
        break;
      case ErrorSeverity.low:
        _handleLowSeverityError(error);
        break;
    }
  }

  /// 에러 로깅
  void _logError(AppError error) {
    final logger = LoggerService.instance;

    switch (error.severity) {
      case ErrorSeverity.critical:
        logger.fatal(
          error.message,
          tag: 'ErrorHandler',
          metadata: {
            'type': error.type.name,
            'code': error.code,
            ...?error.metadata,
          },
          stackTrace: error.stackTrace,
        );
        break;
      case ErrorSeverity.high:
        logger.error(
          error.message,
          tag: 'ErrorHandler',
          metadata: {
            'type': error.type.name,
            'code': error.code,
            ...?error.metadata,
          },
          stackTrace: error.stackTrace,
        );
        break;
      case ErrorSeverity.medium:
        logger.warning(
          error.message,
          tag: 'ErrorHandler',
          metadata: {
            'type': error.type.name,
            'code': error.code,
            ...?error.metadata,
          },
        );
        break;
      case ErrorSeverity.low:
        logger.info(
          error.message,
          tag: 'ErrorHandler',
          metadata: {
            'type': error.type.name,
            'code': error.code,
            ...?error.metadata,
          },
        );
        break;
    }
  }

  /// 치명적 에러 처리
  void _handleCriticalError(AppError error) {
    if (kDebugMode) {
      developer.log('CRITICAL ERROR: ${error.message}');
    }

    // 치명적 에러의 경우 앱 종료나 복구 시도
    // 실제 구현에서는 사용자에게 알림을 보내고 앱 상태를 복구
  }

  /// 높은 심각도 에러 처리
  void _handleHighSeverityError(AppError error) {
    if (kDebugMode) {
      developer.log('HIGH SEVERITY ERROR: ${error.message}');
    }

    // 높은 심각도 에러의 경우 사용자에게 알림
    // 실제 구현에서는 에러 다이얼로그나 스낵바 표시
  }

  /// 중간 심각도 에러 처리
  void _handleMediumSeverityError(AppError error) {
    if (kDebugMode) {
      developer.log('MEDIUM SEVERITY ERROR: ${error.message}');
    }

    // 중간 심각도 에러의 경우 로그만 기록
  }

  /// 낮은 심각도 에러 처리
  void _handleLowSeverityError(AppError error) {
    if (kDebugMode) {
      developer.log('LOW SEVERITY ERROR: ${error.message}');
    }

    // 낮은 심각도 에러의 경우 조용히 처리
  }

  /// 최근 에러 목록 가져오기
  List<AppError> getRecentErrors({ErrorSeverity? minSeverity}) {
    if (minSeverity == null) {
      return List.unmodifiable(_recentErrors);
    }

    return _recentErrors
        .where((error) => _isSeverityHigherOrEqual(error.severity, minSeverity))
        .toList();
  }

  /// 심각도 비교
  bool _isSeverityHigherOrEqual(
    ErrorSeverity severity,
    ErrorSeverity minSeverity,
  ) {
    const severityLevels = {
      ErrorSeverity.low: 0,
      ErrorSeverity.medium: 1,
      ErrorSeverity.high: 2,
      ErrorSeverity.critical: 3,
    };

    return severityLevels[severity]! >= severityLevels[minSeverity]!;
  }

  /// 에러 통계 가져오기
  Map<String, int> getErrorStatistics() {
    final stats = <String, int>{};

    for (final error in _recentErrors) {
      final key = '${error.type.name}_${error.severity.name}';
      stats[key] = (stats[key] ?? 0) + 1;
    }

    return stats;
  }

  /// 에러 목록 초기화
  void clearErrors() {
    _recentErrors.clear();
  }

  /// 리소스 정리
  void dispose() {
    _errorStreamController?.close();
    _recentErrors.clear();
  }
}

/// 에러 핸들링 위젯
class ErrorHandler extends StatefulWidget {
  final Widget child;
  final Widget Function(AppError error)? errorBuilder;
  final VoidCallback? onError;

  const ErrorHandler({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorHandler> createState() => _ErrorHandlerState();
}

class _ErrorHandlerState extends State<ErrorHandler> {
  StreamSubscription<AppError>? _errorSubscription;

  @override
  void initState() {
    super.initState();
    _errorSubscription = ErrorHandlerService.instance.errorStream?.listen(
      _handleError,
    );
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    super.dispose();
  }

  void _handleError(AppError error) {
    widget.onError?.call();

    if (mounted) {
      // 에러 다이얼로그 표시
      _showErrorDialog(error);
    }
  }

  void _showErrorDialog(AppError error) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getErrorTitle(error.severity)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error.message),
            if (error.code != null) ...[
              const SizedBox(height: 8),
              Text(
                '에러 코드: ${error.code}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
          if (error.severity == ErrorSeverity.critical)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 앱 재시작 로직
              },
              child: const Text('앱 재시작'),
            ),
        ],
      ),
    );
  }

  String _getErrorTitle(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.critical:
        return '치명적 오류';
      case ErrorSeverity.high:
        return '오류';
      case ErrorSeverity.medium:
        return '경고';
      case ErrorSeverity.low:
        return '알림';
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// 에러 핸들링 확장 메서드
extension ErrorHandlingExtension on Object {
  void handleError(
    Object error, {
    StackTrace? stackTrace,
    ErrorType? type,
    ErrorSeverity? severity,
    String? code,
    Map<String, dynamic>? metadata,
    String? context,
  }) {
    ErrorHandlerService.instance.handleError(
      error,
      stackTrace: stackTrace,
      type: type,
      severity: severity,
      code: code,
      metadata: metadata,
      context: context ?? runtimeType.toString(),
    );
  }
}
