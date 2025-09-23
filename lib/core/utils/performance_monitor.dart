import 'dart:async';

import '../config/config.dart';
import 'logger.dart';

/// 성능 모니터링 클래스
class PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<Duration>> _measurements = {};

  /// 성능 측정 시작
  static void startTimer(String operation) {
    if (!FeatureFlagManager.instance.isFeatureEnabled(
      'enablePerformanceMonitoring',
    )) {
      return;
    }

    _timers[operation] = Stopwatch()..start();
    Logger.debug('⏱️ Started timer for: $operation');
  }

  /// 성능 측정 종료
  static void endTimer(String operation) {
    if (!FeatureFlagManager.instance.isFeatureEnabled(
      'enablePerformanceMonitoring',
    )) {
      return;
    }

    final timer = _timers.remove(operation);
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsed;

      // 측정값 저장
      _measurements.putIfAbsent(operation, () => []).add(duration);

      // 로그 출력
      Logger.performance('$operation: ${duration.inMilliseconds}ms');

      // 느린 작업 경고
      if (duration.inMilliseconds > 1000) {
        Logger.warning(
          '🐌 Slow operation detected: $operation took ${duration.inMilliseconds}ms',
        );
      }
    }
  }

  /// 특정 작업의 평균 시간 계산
  static Duration? getAverageTime(String operation) {
    final measurements = _measurements[operation];
    if (measurements == null || measurements.isEmpty) return null;

    final totalMs = measurements.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );
    return Duration(milliseconds: totalMs ~/ measurements.length);
  }

  /// 모든 측정값 초기화
  static void clearMeasurements() {
    _measurements.clear();
    _timers.clear();
    Logger.debug('🧹 Performance measurements cleared');
  }

  /// 성능 리포트 생성
  static Map<String, dynamic> generateReport() {
    final report = <String, dynamic>{};

    for (final entry in _measurements.entries) {
      final operation = entry.key;
      final measurements = entry.value;

      if (measurements.isNotEmpty) {
        final totalMs = measurements.fold<int>(
          0,
          (sum, duration) => sum + duration.inMilliseconds,
        );
        final averageMs = totalMs ~/ measurements.length;
        final minMs = measurements
            .map((d) => d.inMilliseconds)
            .reduce((a, b) => a < b ? a : b);
        final maxMs = measurements
            .map((d) => d.inMilliseconds)
            .reduce((a, b) => a > b ? a : b);

        report[operation] = {
          'count': measurements.length,
          'average_ms': averageMs,
          'min_ms': minMs,
          'max_ms': maxMs,
          'total_ms': totalMs,
        };
      }
    }

    return report;
  }

  /// 성능 리포트 출력
  static void printReport() {
    if (!FeatureFlagManager.instance.isFeatureEnabled(
      'enablePerformanceMonitoring',
    )) {
      return;
    }

    final report = generateReport();
    if (report.isEmpty) {
      Logger.info('📊 No performance data available');
      return;
    }

    Logger.info('📊 Performance Report:');
    report.forEach((operation, data) {
      Logger.info(
        '  $operation: ${data['count']} calls, avg: ${data['average_ms']}ms, min: ${data['min_ms']}ms, max: ${data['max_ms']}ms',
      );
    });
  }
}

/// 성능 측정을 위한 믹스인
mixin PerformanceMixin {
  /// 특정 작업의 성능을 측정하는 헬퍼 메서드
  Future<T> measureOperation<T>(
    String operation,
    Future<T> Function() task,
  ) async {
    PerformanceMonitor.startTimer(operation);
    try {
      final result = await task();
      return result;
    } finally {
      PerformanceMonitor.endTimer(operation);
    }
  }

  /// 동기 작업의 성능을 측정하는 헬퍼 메서드
  T measureSyncOperation<T>(String operation, T Function() task) {
    PerformanceMonitor.startTimer(operation);
    try {
      final result = task();
      return result;
    } finally {
      PerformanceMonitor.endTimer(operation);
    }
  }
}
