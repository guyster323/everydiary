import 'dart:async';

import 'package:flutter/foundation.dart';

/// 성능 메트릭
class PerformanceMetrics {
  final double cpuUsage;
  final int memoryUsage;
  final double batteryLevel;
  final Duration processingTime;
  final int recognitionCount;
  final DateTime timestamp;

  const PerformanceMetrics({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.batteryLevel,
    required this.processingTime,
    required this.recognitionCount,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'cpuUsage': cpuUsage,
    'memoryUsage': memoryUsage,
    'batteryLevel': batteryLevel,
    'processingTime': processingTime.inMilliseconds,
    'recognitionCount': recognitionCount,
    'timestamp': timestamp.toIso8601String(),
  };

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      cpuUsage: (json['cpuUsage'] as num).toDouble(),
      memoryUsage: json['memoryUsage'] as int,
      batteryLevel: (json['batteryLevel'] as num).toDouble(),
      processingTime: Duration(milliseconds: json['processingTime'] as int),
      recognitionCount: json['recognitionCount'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// 성능 최적화 설정
class PerformanceConfig {
  final int maxMemoryUsage; // MB
  final double maxCpuUsage; // 0.0 - 1.0
  final double minBatteryLevel; // 0.0 - 1.0
  final Duration maxProcessingTime;
  final bool enableBackgroundProcessing;
  final bool enableMemoryOptimization;
  final bool enableBatteryOptimization;

  const PerformanceConfig({
    this.maxMemoryUsage = 100,
    this.maxCpuUsage = 0.8,
    this.minBatteryLevel = 0.2,
    this.maxProcessingTime = const Duration(seconds: 5),
    this.enableBackgroundProcessing = true,
    this.enableMemoryOptimization = true,
    this.enableBatteryOptimization = true,
  });
}

/// 음성 인식 성능 최적화 서비스
class SpeechPerformanceOptimizer {
  static final SpeechPerformanceOptimizer _instance =
      SpeechPerformanceOptimizer._internal();

  factory SpeechPerformanceOptimizer() => _instance;

  SpeechPerformanceOptimizer._internal();

  final List<PerformanceMetrics> _metricsHistory = [];
  final StreamController<PerformanceMetrics> _metricsController =
      StreamController<PerformanceMetrics>.broadcast();

  PerformanceConfig _config = const PerformanceConfig();
  Timer? _monitoringTimer;
  bool _isMonitoring = false;

  // 성능 임계값
  static const int _maxHistorySize = 100;
  static const Duration _monitoringInterval = Duration(seconds: 2);

  // 메모리 최적화를 위한 캐시 관리
  final Map<String, dynamic> _cache = {};
  static const int _maxCacheSize = 50;

  PerformanceConfig get config => _config;
  bool get isMonitoring => _isMonitoring;
  List<PerformanceMetrics> get metricsHistory =>
      List.unmodifiable(_metricsHistory);
  Stream<PerformanceMetrics> get metricsStream => _metricsController.stream;

  /// 성능 모니터링 시작
  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    debugPrint('SpeechPerformanceOptimizer 모니터링 시작');
    _isMonitoring = true;

    _monitoringTimer = Timer.periodic(_monitoringInterval, (_) async {
      await _collectMetrics();
    });
  }

  /// 성능 모니터링 중지
  void stopMonitoring() {
    if (!_isMonitoring) return;

    debugPrint('SpeechPerformanceOptimizer 모니터링 중지');
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  /// 성능 메트릭 수집
  Future<void> _collectMetrics() async {
    try {
      final metrics = await _gatherSystemMetrics();
      _addMetrics(metrics);
      _checkPerformanceThresholds(metrics);
    } catch (e) {
      debugPrint('성능 메트릭 수집 실패: $e');
    }
  }

  /// 시스템 메트릭 수집
  Future<PerformanceMetrics> _gatherSystemMetrics() async {
    final stopwatch = Stopwatch()..start();

    // CPU 사용률 (시뮬레이션)
    final cpuUsage = await _getCpuUsage();

    // 메모리 사용량 (시뮬레이션)
    final memoryUsage = await _getMemoryUsage();

    // 배터리 레벨 (시뮬레이션)
    final batteryLevel = await _getBatteryLevel();

    stopwatch.stop();

    return PerformanceMetrics(
      cpuUsage: cpuUsage,
      memoryUsage: memoryUsage,
      batteryLevel: batteryLevel,
      processingTime: stopwatch.elapsed,
      recognitionCount: _metricsHistory.length,
      timestamp: DateTime.now(),
    );
  }

  /// CPU 사용률 가져오기 (시뮬레이션)
  Future<double> _getCpuUsage() async {
    // 실제 구현에서는 시스템 API를 사용
    // 현재는 시뮬레이션으로 0.1 ~ 0.9 사이의 랜덤 값 반환
    return 0.1 + (DateTime.now().millisecond % 800) / 1000;
  }

  /// 메모리 사용량 가져오기 (시뮬레이션)
  Future<int> _getMemoryUsage() async {
    // 실제 구현에서는 시스템 API를 사용
    // 현재는 시뮬레이션으로 50 ~ 200 MB 사이의 랜덤 값 반환
    return 50 + (DateTime.now().millisecond % 150);
  }

  /// 배터리 레벨 가져오기 (시뮬레이션)
  Future<double> _getBatteryLevel() async {
    // 실제 구현에서는 배터리 API를 사용
    // 현재는 시뮬레이션으로 0.1 ~ 1.0 사이의 랜덤 값 반환
    return 0.1 + (DateTime.now().millisecond % 900) / 1000;
  }

  /// 메트릭 추가
  void _addMetrics(PerformanceMetrics metrics) {
    _metricsHistory.insert(0, metrics);

    // 히스토리 크기 제한
    if (_metricsHistory.length > _maxHistorySize) {
      _metricsHistory.removeRange(_maxHistorySize, _metricsHistory.length);
    }

    _metricsController.add(metrics);
  }

  /// 성능 임계값 확인
  void _checkPerformanceThresholds(PerformanceMetrics metrics) {
    final warnings = <String>[];

    if (metrics.memoryUsage > _config.maxMemoryUsage) {
      warnings.add('메모리 사용량이 높습니다: ${metrics.memoryUsage}MB');
    }

    if (metrics.cpuUsage > _config.maxCpuUsage) {
      warnings.add('CPU 사용률이 높습니다: ${(metrics.cpuUsage * 100).toInt()}%');
    }

    if (metrics.batteryLevel < _config.minBatteryLevel) {
      warnings.add('배터리 레벨이 낮습니다: ${(metrics.batteryLevel * 100).toInt()}%');
    }

    if (metrics.processingTime > _config.maxProcessingTime) {
      warnings.add(
        '처리 시간이 오래 걸립니다: ${metrics.processingTime.inMilliseconds}ms',
      );
    }

    if (warnings.isNotEmpty) {
      debugPrint('성능 경고: ${warnings.join(', ')}');
      _optimizePerformance();
    }
  }

  /// 성능 최적화 실행
  void _optimizePerformance() {
    debugPrint('성능 최적화 실행');

    if (_config.enableMemoryOptimization) {
      _optimizeMemory();
    }

    if (_config.enableBatteryOptimization) {
      _optimizeBattery();
    }
  }

  /// 메모리 최적화
  void _optimizeMemory() {
    // 캐시 정리
    if (_cache.length > _maxCacheSize) {
      final keysToRemove = _cache.keys
          .take(_cache.length - _maxCacheSize)
          .toList();
      for (final key in keysToRemove) {
        _cache.remove(key);
      }
      debugPrint('메모리 최적화: 캐시 ${keysToRemove.length}개 항목 제거');
    }

    // 가비지 컬렉션 강제 실행 (개발 모드에서만)
    if (kDebugMode) {
      // Flutter에서는 직접 가비지 컬렉션을 호출할 수 없음
      debugPrint('메모리 최적화: 가비지 컬렉션 권장');
    }
  }

  /// 배터리 최적화
  void _optimizeBattery() {
    // 배터리 레벨이 낮을 때 성능 모니터링 간격 증가
    if (_metricsHistory.isNotEmpty) {
      final latestMetrics = _metricsHistory.first;
      if (latestMetrics.batteryLevel < 0.3) {
        debugPrint('배터리 최적화: 모니터링 간격 증가 권장');
        // 실제로는 모니터링 간격을 조정할 수 있음
      }
    }
  }

  /// 백그라운드 처리 최적화
  Future<T> processInBackground<T>(
    Future<T> Function() task,
    String taskName,
  ) async {
    if (!_config.enableBackgroundProcessing) {
      return await task();
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Isolate를 사용한 백그라운드 처리
      final result = await compute(_runTaskInIsolate, taskName);
      stopwatch.stop();

      debugPrint('백그라운드 처리 완료: $taskName (${stopwatch.elapsedMilliseconds}ms)');
      return result as T;
    } catch (e) {
      debugPrint('백그라운드 처리 실패: $taskName - $e');
      // 백그라운드 처리 실패 시 메인 스레드에서 실행
      return await task();
    }
  }

  /// Isolate에서 실행할 정적 메서드
  static Future<dynamic> _runTaskInIsolate(String taskName) async {
    // 실제 구현에서는 특정 작업을 Isolate에서 실행
    // 현재는 시뮬레이션
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return 'Task completed: $taskName';
  }

  /// 캐시 관리
  void setCache(String key, dynamic value) {
    _cache[key] = value;

    // 캐시 크기 제한
    if (_cache.length > _maxCacheSize) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }
  }

  T? getCache<T>(String key) {
    return _cache[key] as T?;
  }

  void clearCache() {
    _cache.clear();
    debugPrint('성능 최적화 캐시 클리어');
  }

  /// 설정 업데이트
  void updateConfig(PerformanceConfig newConfig) {
    _config = newConfig;
    debugPrint('성능 최적화 설정 업데이트');
  }

  /// 성능 통계 반환
  Map<String, dynamic> getPerformanceStats() {
    if (_metricsHistory.isEmpty) {
      return {'message': '수집된 메트릭이 없습니다'};
    }

    final latest = _metricsHistory.first;
    final avgCpu =
        _metricsHistory.map((m) => m.cpuUsage).reduce((a, b) => a + b) /
        _metricsHistory.length;
    final avgMemory =
        _metricsHistory.map((m) => m.memoryUsage).reduce((a, b) => a + b) /
        _metricsHistory.length;
    final avgBattery =
        _metricsHistory.map((m) => m.batteryLevel).reduce((a, b) => a + b) /
        _metricsHistory.length;

    return {
      'totalMetrics': _metricsHistory.length,
      'latestCpuUsage': latest.cpuUsage,
      'averageCpuUsage': avgCpu,
      'latestMemoryUsage': latest.memoryUsage,
      'averageMemoryUsage': avgMemory,
      'latestBatteryLevel': latest.batteryLevel,
      'averageBatteryLevel': avgBattery,
      'cacheSize': _cache.length,
      'isMonitoring': _isMonitoring,
    };
  }

  /// 서비스 종료
  void dispose() {
    stopMonitoring();
    _metricsController.close();
    _cache.clear();
  }
}
