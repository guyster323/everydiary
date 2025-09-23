import 'dart:async';
import 'dart:io';

import 'package:sqflite/sqflite.dart';

/// 데이터베이스 연결 상태 모니터링 서비스
class DatabaseConnectionMonitor {
  final Database _database;
  Timer? _healthCheckTimer;
  bool _isConnected = false;
  DateTime? _lastHealthCheck;
  int _connectionRetryCount = 0;
  static const int _maxRetryCount = 3;
  static const Duration _healthCheckInterval = Duration(minutes: 5);
  static const Duration _retryDelay = Duration(seconds: 2);

  // 연결 상태 스트림 컨트롤러
  final StreamController<DatabaseConnectionStatus> _statusController =
      StreamController<DatabaseConnectionStatus>.broadcast();

  DatabaseConnectionMonitor(this._database);

  /// 연결 상태 스트림
  Stream<DatabaseConnectionStatus> get statusStream => _statusController.stream;

  /// 현재 연결 상태
  bool get isConnected => _isConnected;

  /// 마지막 헬스 체크 시간
  DateTime? get lastHealthCheck => _lastHealthCheck;

  /// 연결 재시도 횟수
  int get connectionRetryCount => _connectionRetryCount;

  /// 모니터링 시작
  void startMonitoring() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(_healthCheckInterval, (_) {
      _performHealthCheck();
    });

    // 초기 헬스 체크 실행
    _performHealthCheck();
  }

  /// 모니터링 중지
  void stopMonitoring() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
  }

  /// 헬스 체크 수행
  Future<void> _performHealthCheck() async {
    try {
      _lastHealthCheck = DateTime.now();

      // 간단한 쿼리로 연결 상태 확인
      await _database.rawQuery('SELECT 1');

      if (!_isConnected) {
        _isConnected = true;
        _connectionRetryCount = 0;
        _statusController.add(DatabaseConnectionStatus.connected);
      }
    } catch (e) {
      _isConnected = false;
      _connectionRetryCount++;

      _statusController.add(DatabaseConnectionStatus.disconnected);

      // 재시도 로직
      if (_connectionRetryCount <= _maxRetryCount) {
        await Future<void>.delayed(_retryDelay);
        _performHealthCheck();
      } else {
        _statusController.add(DatabaseConnectionStatus.failed);
      }
    }
  }

  /// 수동 연결 테스트
  Future<DatabaseConnectionTestResult> testConnection() async {
    final stopwatch = Stopwatch()..start();

    try {
      // 연결 테스트 쿼리
      await _database.rawQuery('SELECT 1');

      // 성능 테스트 쿼리
      await _database.rawQuery('SELECT COUNT(*) FROM sqlite_master');

      stopwatch.stop();

      return DatabaseConnectionTestResult(
        isConnected: true,
        responseTime: stopwatch.elapsedMilliseconds,
        error: null,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      stopwatch.stop();

      return DatabaseConnectionTestResult(
        isConnected: false,
        responseTime: stopwatch.elapsedMilliseconds,
        error: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }

  /// 데이터베이스 파일 상태 확인
  Future<DatabaseFileStatus> checkDatabaseFileStatus() async {
    try {
      // 데이터베이스 파일 경로 가져오기
      final path = _database.path;
      final file = File(path);

      if (!await file.exists()) {
        return DatabaseFileStatus(
          exists: false,
          size: 0,
          lastModified: null,
          isReadable: false,
          isWritable: false,
        );
      }

      final stat = await file.stat();

      return DatabaseFileStatus(
        exists: true,
        size: stat.size,
        lastModified: stat.modified,
        isReadable: true, // File.canRead()는 Flutter에서 지원하지 않음
        isWritable: true, // File.canWrite()는 Flutter에서 지원하지 않음
      );
    } catch (e) {
      return DatabaseFileStatus(
        exists: false,
        size: 0,
        lastModified: null,
        isReadable: false,
        isWritable: false,
        error: e.toString(),
      );
    }
  }

  /// 데이터베이스 무결성 검사
  Future<DatabaseIntegrityResult> checkIntegrity() async {
    try {
      // PRAGMA integrity_check 실행
      final result = await _database.rawQuery('PRAGMA integrity_check');
      final integrityStatus = result.first['integrity_check'] as String;

      final isIntegrityOk = integrityStatus == 'ok';

      return DatabaseIntegrityResult(
        isIntegrityOk: isIntegrityOk,
        status: integrityStatus,
        timestamp: DateTime.now(),
        error: isIntegrityOk ? null : integrityStatus,
      );
    } catch (e) {
      return DatabaseIntegrityResult(
        isIntegrityOk: false,
        status: 'error',
        timestamp: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// 데이터베이스 최적화 상태 확인
  Future<DatabaseOptimizationStatus> checkOptimizationStatus() async {
    try {
      // 테이블 정보 조회
      final tables = await _database.rawQuery('''
        SELECT name FROM sqlite_master
        WHERE type = 'table'
        AND name NOT LIKE 'sqlite_%'
      ''');

      // 인덱스 정보 조회
      final indexes = await _database.rawQuery('''
        SELECT name FROM sqlite_master
        WHERE type = 'index'
        AND name NOT LIKE 'sqlite_%'
      ''');

      // 데이터베이스 페이지 수 조회
      final pageCount = await _database.rawQuery('PRAGMA page_count');
      final pageSize = await _database.rawQuery('PRAGMA page_size');

      return DatabaseOptimizationStatus(
        tableCount: tables.length,
        indexCount: indexes.length,
        pageCount: pageCount.first['page_count'] as int,
        pageSize: pageSize.first['page_size'] as int,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return DatabaseOptimizationStatus(
        tableCount: 0,
        indexCount: 0,
        pageCount: 0,
        pageSize: 0,
        timestamp: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// 종합 상태 리포트 생성
  Future<DatabaseStatusReport> generateStatusReport() async {
    final connectionTest = await testConnection();
    final fileStatus = await checkDatabaseFileStatus();
    final integrityResult = await checkIntegrity();
    final optimizationStatus = await checkOptimizationStatus();

    return DatabaseStatusReport(
      connectionTest: connectionTest,
      fileStatus: fileStatus,
      integrityResult: integrityResult,
      optimizationStatus: optimizationStatus,
      isMonitoring: _healthCheckTimer?.isActive ?? false,
      retryCount: _connectionRetryCount,
      lastHealthCheck: _lastHealthCheck,
      timestamp: DateTime.now(),
    );
  }

  /// 리소스 정리
  void dispose() {
    stopMonitoring();
    _statusController.close();
  }
}

/// 데이터베이스 연결 상태 열거형
enum DatabaseConnectionStatus { connected, disconnected, failed, reconnecting }

/// 데이터베이스 연결 테스트 결과
class DatabaseConnectionTestResult {
  final bool isConnected;
  final int responseTime;
  final String? error;
  final DateTime timestamp;

  DatabaseConnectionTestResult({
    required this.isConnected,
    required this.responseTime,
    required this.error,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'isConnected': isConnected,
    'responseTime': responseTime,
    'error': error,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// 데이터베이스 파일 상태
class DatabaseFileStatus {
  final bool exists;
  final int size;
  final DateTime? lastModified;
  final bool isReadable;
  final bool isWritable;
  final String? error;

  DatabaseFileStatus({
    required this.exists,
    required this.size,
    required this.lastModified,
    required this.isReadable,
    required this.isWritable,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'exists': exists,
    'size': size,
    'lastModified': lastModified?.toIso8601String(),
    'isReadable': isReadable,
    'isWritable': isWritable,
    'error': error,
  };
}

/// 데이터베이스 무결성 검사 결과
class DatabaseIntegrityResult {
  final bool isIntegrityOk;
  final String status;
  final DateTime timestamp;
  final String? error;

  DatabaseIntegrityResult({
    required this.isIntegrityOk,
    required this.status,
    required this.timestamp,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'isIntegrityOk': isIntegrityOk,
    'status': status,
    'timestamp': timestamp.toIso8601String(),
    'error': error,
  };
}

/// 데이터베이스 최적화 상태
class DatabaseOptimizationStatus {
  final int tableCount;
  final int indexCount;
  final int pageCount;
  final int pageSize;
  final DateTime timestamp;
  final String? error;

  DatabaseOptimizationStatus({
    required this.tableCount,
    required this.indexCount,
    required this.pageCount,
    required this.pageSize,
    required this.timestamp,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'tableCount': tableCount,
    'indexCount': indexCount,
    'pageCount': pageCount,
    'pageSize': pageSize,
    'timestamp': timestamp.toIso8601String(),
    'error': error,
  };
}

/// 데이터베이스 종합 상태 리포트
class DatabaseStatusReport {
  final DatabaseConnectionTestResult connectionTest;
  final DatabaseFileStatus fileStatus;
  final DatabaseIntegrityResult integrityResult;
  final DatabaseOptimizationStatus optimizationStatus;
  final bool isMonitoring;
  final int retryCount;
  final DateTime? lastHealthCheck;
  final DateTime timestamp;

  DatabaseStatusReport({
    required this.connectionTest,
    required this.fileStatus,
    required this.integrityResult,
    required this.optimizationStatus,
    required this.isMonitoring,
    required this.retryCount,
    required this.lastHealthCheck,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'connectionTest': connectionTest.toJson(),
    'fileStatus': fileStatus.toJson(),
    'integrityResult': integrityResult.toJson(),
    'optimizationStatus': optimizationStatus.toJson(),
    'isMonitoring': isMonitoring,
    'retryCount': retryCount,
    'lastHealthCheck': lastHealthCheck?.toIso8601String(),
    'timestamp': timestamp.toIso8601String(),
  };
}
