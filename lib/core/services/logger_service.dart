import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 로그 레벨
enum LogLevel {
  debug(0, 'DEBUG'),
  info(1, 'INFO'),
  warning(2, 'WARNING'),
  error(3, 'ERROR'),
  fatal(4, 'FATAL');

  const LogLevel(this.level, this.name);
  final int level;
  final String name;
}

/// 로그 엔트리
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final Map<String, dynamic>? metadata;
  final StackTrace? stackTrace;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.metadata,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'message': message,
      'tag': tag,
      'metadata': metadata,
      'stackTrace': stackTrace?.toString(),
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('[${timestamp.toIso8601String()}] ');
    buffer.write('[${level.name}] ');
    if (tag != null) buffer.write('[$tag] ');
    buffer.write(message);

    if (metadata != null && metadata!.isNotEmpty) {
      buffer.write(' | Metadata: ${jsonEncode(metadata)}');
    }

    if (stackTrace != null) {
      buffer.write('\nStackTrace: $stackTrace');
    }

    return buffer.toString();
  }
}

/// 로거 서비스
class LoggerService {
  static LoggerService? _instance;
  static LoggerService get instance => _instance ??= LoggerService._();

  LoggerService._();

  static const String _logLevelKey = 'log_level';
  static const String _maxLogFileSizeKey = 'max_log_file_size';
  static const String _maxLogFilesKey = 'max_log_files';

  LogLevel _currentLevel = LogLevel.info;
  int _maxLogFileSize = 5 * 1024 * 1024; // 5MB
  int _maxLogFiles = 5;

  final List<LogEntry> _inMemoryLogs = [];
  final int _maxInMemoryLogs = 1000;

  StreamController<LogEntry>? _logStreamController;
  Stream<LogEntry>? _logStream;

  /// 초기화
  Future<void> initialize() async {
    await _loadSettings();
    _logStreamController = StreamController<LogEntry>.broadcast();
    _logStream = _logStreamController!.stream;
  }

  /// 설정 로드
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final levelIndex = prefs.getInt(_logLevelKey) ?? LogLevel.info.level;
      _currentLevel = LogLevel.values.firstWhere(
        (level) => level.level == levelIndex,
        orElse: () => LogLevel.info,
      );
      _maxLogFileSize = prefs.getInt(_maxLogFileSizeKey) ?? 5 * 1024 * 1024;
      _maxLogFiles = prefs.getInt(_maxLogFilesKey) ?? 5;
    } catch (e) {
      // 설정 로드 실패 시 기본값 사용
      _currentLevel = LogLevel.info;
      _maxLogFileSize = 5 * 1024 * 1024;
      _maxLogFiles = 5;
    }
  }

  /// 로그 레벨 설정
  Future<void> setLogLevel(LogLevel level) async {
    _currentLevel = level;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_logLevelKey, level.level);
    } catch (e) {
      // 설정 저장 실패는 무시
    }
  }

  /// 로그 레벨 가져오기
  LogLevel get logLevel => _currentLevel;

  /// 로그 스트림 가져오기
  Stream<LogEntry>? get logStream => _logStream;

  /// 디버그 로그
  void debug(String message, {String? tag, Map<String, dynamic>? metadata}) {
    _log(LogLevel.debug, message, tag: tag, metadata: metadata);
  }

  /// 정보 로그
  void info(String message, {String? tag, Map<String, dynamic>? metadata}) {
    _log(LogLevel.info, message, tag: tag, metadata: metadata);
  }

  /// 경고 로그
  void warning(String message, {String? tag, Map<String, dynamic>? metadata}) {
    _log(LogLevel.warning, message, tag: tag, metadata: metadata);
  }

  /// 에러 로그
  void error(
    String message, {
    String? tag,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      metadata: metadata,
      stackTrace: stackTrace,
    );
  }

  /// 치명적 에러 로그
  void fatal(
    String message, {
    String? tag,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.fatal,
      message,
      tag: tag,
      metadata: metadata,
      stackTrace: stackTrace,
    );
  }

  /// 로그 기록
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  }) {
    // 로그 레벨 체크
    if (level.level < _currentLevel.level) {
      return;
    }

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: tag,
      metadata: metadata,
      stackTrace: stackTrace,
    );

    // 메모리에 로그 저장
    _inMemoryLogs.add(entry);
    if (_inMemoryLogs.length > _maxInMemoryLogs) {
      _inMemoryLogs.removeAt(0);
    }

    // 스트림으로 로그 전송
    _logStreamController?.add(entry);

    // 개발 모드에서 콘솔 출력
    if (kDebugMode) {
      _printToConsole(entry);
    }

    // 파일에 로그 저장 (백그라운드)
    _saveToFile(entry);
  }

  /// 콘솔에 로그 출력
  void _printToConsole(LogEntry entry) {
    switch (entry.level) {
      case LogLevel.debug:
        developer.log(
          entry.message,
          name: entry.tag ?? 'DEBUG',
          level: 500,
          time: entry.timestamp,
        );
        break;
      case LogLevel.info:
        developer.log(
          entry.message,
          name: entry.tag ?? 'INFO',
          level: 800,
          time: entry.timestamp,
        );
        break;
      case LogLevel.warning:
        developer.log(
          entry.message,
          name: entry.tag ?? 'WARNING',
          level: 900,
          time: entry.timestamp,
        );
        break;
      case LogLevel.error:
        developer.log(
          entry.message,
          name: entry.tag ?? 'ERROR',
          level: 1000,
          time: entry.timestamp,
          error: entry.metadata?['error'],
          stackTrace: entry.stackTrace,
        );
        break;
      case LogLevel.fatal:
        developer.log(
          entry.message,
          name: entry.tag ?? 'FATAL',
          level: 1200,
          time: entry.timestamp,
          error: entry.metadata?['error'],
          stackTrace: entry.stackTrace,
        );
        break;
    }
  }

  /// 파일에 로그 저장
  Future<void> _saveToFile(LogEntry entry) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/logs/app.log');

      // 로그 디렉토리 생성
      await logFile.parent.create(recursive: true);

      // 로그 파일 크기 체크
      if (await logFile.exists()) {
        final fileSize = await logFile.length();
        if (fileSize > _maxLogFileSize) {
          await _rotateLogFiles(logFile);
        }
      }

      // 로그 추가
      await logFile.writeAsString(
        '${entry.toString()}\n',
        mode: FileMode.append,
      );
    } catch (e) {
      // 파일 저장 실패는 무시 (무한 루프 방지)
      if (kDebugMode) {
        developer.log('Failed to save log to file: $e');
      }
    }
  }

  /// 로그 파일 로테이션
  Future<void> _rotateLogFiles(File currentLogFile) async {
    try {
      final directory = currentLogFile.parent;

      // 기존 로그 파일들 이름 변경
      for (int i = _maxLogFiles - 1; i > 0; i--) {
        final oldFile = File('${directory.path}/app.log.$i');
        final newFile = File('${directory.path}/app.log.${i + 1}');

        if (await oldFile.exists()) {
          if (i == _maxLogFiles - 1) {
            // 가장 오래된 파일 삭제
            await oldFile.delete();
          } else {
            await oldFile.rename(newFile.path);
          }
        }
      }

      // 현재 로그 파일을 .1로 변경
      final rotatedFile = File('${directory.path}/app.log.1');
      await currentLogFile.rename(rotatedFile.path);
    } catch (e) {
      // 로그 로테이션 실패 시 현재 파일 삭제
      try {
        await currentLogFile.delete();
      } catch (_) {
        // 삭제 실패는 무시
      }
    }
  }

  /// 메모리의 로그 가져오기
  List<LogEntry> getInMemoryLogs({LogLevel? minLevel}) {
    if (minLevel == null) {
      return List.unmodifiable(_inMemoryLogs);
    }

    return _inMemoryLogs
        .where((log) => log.level.level >= minLevel.level)
        .toList();
  }

  /// 로그 파일에서 로그 읽기
  Future<List<LogEntry>> getLogsFromFile({
    int? limit,
    LogLevel? minLevel,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/logs/app.log');

      if (!await logFile.exists()) {
        return [];
      }

      final content = await logFile.readAsString();
      final lines = content
          .split('\n')
          .where((line) => line.isNotEmpty)
          .toList();

      final logs = <LogEntry>[];
      for (final line in lines.reversed) {
        if (limit != null && logs.length >= limit) break;

        try {
          final log = _parseLogLine(line);
          if (log != null &&
              (minLevel == null || log.level.level >= minLevel.level)) {
            logs.add(log);
          }
        } catch (e) {
          // 파싱 실패한 라인은 무시
        }
      }

      return logs.reversed.toList();
    } catch (e) {
      return [];
    }
  }

  /// 로그 라인 파싱
  LogEntry? _parseLogLine(String line) {
    try {
      // 간단한 파싱 (실제로는 더 정교한 파싱이 필요할 수 있음)
      final parts = line.split('] ');
      if (parts.length < 3) return null;

      final timestampStr = parts[0].substring(1);
      final levelStr = parts[1].substring(1);
      final message = parts.sublist(2).join('] ');

      final timestamp = DateTime.parse(timestampStr);
      final level = LogLevel.values.firstWhere(
        (l) => l.name == levelStr,
        orElse: () => LogLevel.info,
      );

      return LogEntry(timestamp: timestamp, level: level, message: message);
    } catch (e) {
      return null;
    }
  }

  /// 로그 파일 삭제
  Future<void> clearLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');

      if (await logDir.exists()) {
        await logDir.delete(recursive: true);
      }

      _inMemoryLogs.clear();
    } catch (e) {
      // 로그 삭제 실패는 무시
    }
  }

  /// 리소스 정리
  void dispose() {
    _logStreamController?.close();
    _inMemoryLogs.clear();
  }
}

/// 로거 확장 메서드
extension LoggerExtension on Object {
  void logDebug(String message, {String? tag, Map<String, dynamic>? metadata}) {
    LoggerService.instance.debug(
      message,
      tag: tag ?? runtimeType.toString(),
      metadata: metadata,
    );
  }

  void logInfo(String message, {String? tag, Map<String, dynamic>? metadata}) {
    LoggerService.instance.info(
      message,
      tag: tag ?? runtimeType.toString(),
      metadata: metadata,
    );
  }

  void logWarning(
    String message, {
    String? tag,
    Map<String, dynamic>? metadata,
  }) {
    LoggerService.instance.warning(
      message,
      tag: tag ?? runtimeType.toString(),
      metadata: metadata,
    );
  }

  void logError(
    String message, {
    String? tag,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) {
    LoggerService.instance.error(
      message,
      tag: tag ?? runtimeType.toString(),
      metadata: metadata,
      stackTrace: stackTrace,
    );
  }

  void logFatal(
    String message, {
    String? tag,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) {
    LoggerService.instance.fatal(
      message,
      tag: tag ?? runtimeType.toString(),
      metadata: metadata,
      stackTrace: stackTrace,
    );
  }
}

