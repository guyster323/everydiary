import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 성능 모니터링 및 최적화 유틸리티
class PerformanceUtils {
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<Duration>> _measurements = {};

  /// 성능 측정 시작
  static void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }

  /// 성능 측정 종료
  static Duration endTimer(String name) {
    final timer = _timers.remove(name);
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsed;

      // 측정값 저장
      _measurements.putIfAbsent(name, () => []).add(duration);

      // 개발 모드에서 로그 출력
      if (kDebugMode) {
        developer.log('Performance: $name took ${duration.inMilliseconds}ms');
      }

      return duration;
    }
    return Duration.zero;
  }

  /// 평균 성능 측정값 가져오기
  static Duration getAverageTime(String name) {
    final measurements = _measurements[name];
    if (measurements == null || measurements.isEmpty) {
      return Duration.zero;
    }

    final total = measurements.fold<Duration>(
      Duration.zero,
      (sum, duration) => sum + duration,
    );

    return Duration(microseconds: total.inMicroseconds ~/ measurements.length);
  }

  /// 성능 측정값 초기화
  static void clearMeasurements() {
    _timers.clear();
    _measurements.clear();
  }

  /// 메모리 사용량 모니터링
  static void logMemoryUsage(String context) {
    if (kDebugMode) {
      // Flutter의 메모리 정보는 제한적이므로 간단한 로그만 출력
      developer.log('Memory check at: $context');
    }
  }

  /// 이미지 최적화 설정
  static ImageProvider optimizeImageProvider(String imageUrl) {
    return NetworkImage(
      imageUrl,
      headers: const {'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8'},
    );
  }

  /// 리스트 성능 최적화를 위한 키 생성
  static String generateListKey(dynamic item, int index) {
    if (item is Map && item.containsKey('id')) {
      return 'item_${item['id']}';
    } else if (item is String) {
      return 'item_${item.hashCode}';
    } else {
      return 'item_${index}_${item.hashCode}';
    }
  }

  /// 위젯 빌드 최적화를 위한 메모이제이션
  static Widget memoizedBuilder<T>(T value, Widget Function(T) builder) {
    return _MemoizedWidget<T>(value: value, builder: builder);
  }

  /// 디바운스 함수
  static Timer? debounce(String key, Duration delay, VoidCallback callback) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(delay, callback);
    return _debounceTimers[key];
  }

  static final Map<String, Timer> _debounceTimers = {};

  /// 스로틀 함수
  static bool throttle(String key, Duration delay) {
    final now = DateTime.now();
    final lastCall = _throttleTimestamps[key];

    if (lastCall == null || now.difference(lastCall) >= delay) {
      _throttleTimestamps[key] = now;
      return true;
    }

    return false;
  }

  static final Map<String, DateTime> _throttleTimestamps = {};

  /// 네트워크 요청 최적화
  static Map<String, String> getOptimizedHeaders() {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Accept-Encoding': 'gzip, deflate',
      'Connection': 'keep-alive',
    };
  }

  /// 캐시 최적화 설정
  static Duration getCacheDuration(String type) {
    switch (type) {
      case 'user_profile':
        return const Duration(hours: 1);
      case 'diary_entries':
        return const Duration(minutes: 30);
      case 'images':
        return const Duration(days: 7);
      case 'api_responses':
        return const Duration(minutes: 5);
      default:
        return const Duration(minutes: 15);
    }
  }

  /// 배터리 최적화를 위한 백그라운드 작업 관리
  static void scheduleBackgroundTask(
    String name,
    Future<void> Function() task, {
    Duration delay = Duration.zero,
  }) {
    Timer(delay, () async {
      try {
        await task();
      } catch (e) {
        if (kDebugMode) {
          developer.log('Background task $name failed: $e');
        }
      }
    });
  }

  /// 메모리 누수 방지를 위한 정리 작업
  static void cleanup() {
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _throttleTimestamps.clear();
    clearMeasurements();
  }
}

/// 메모이제이션을 위한 위젯
class _MemoizedWidget<T> extends StatefulWidget {
  final T value;
  final Widget Function(T) builder;

  const _MemoizedWidget({required this.value, required this.builder});

  @override
  State<_MemoizedWidget<T>> createState() => _MemoizedWidgetState<T>();
}

class _MemoizedWidgetState<T> extends State<_MemoizedWidget<T>> {
  T? _lastValue;
  Widget? _lastWidget;

  @override
  Widget build(BuildContext context) {
    if (_lastValue != widget.value) {
      _lastValue = widget.value;
      _lastWidget = widget.builder(widget.value);
    }
    return _lastWidget!;
  }
}

/// 성능 모니터링 위젯
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final String name;

  const PerformanceMonitor({
    super.key,
    required this.child,
    required this.name,
  });

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  @override
  void initState() {
    super.initState();
    PerformanceUtils.startTimer('${widget.name}_build');
  }

  @override
  void dispose() {
    PerformanceUtils.endTimer('${widget.name}_build');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// 지연 로딩 위젯
class LazyLoadWidget extends StatefulWidget {
  final Widget Function() builder;
  final Duration delay;
  final Widget? placeholder;

  const LazyLoadWidget({
    super.key,
    required this.builder,
    this.delay = const Duration(milliseconds: 100),
    this.placeholder,
  });

  @override
  State<LazyLoadWidget> createState() => _LazyLoadWidgetState();
}

class _LazyLoadWidgetState extends State<LazyLoadWidget> {
  Widget? _content;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  void _loadContent() async {
    await Future<void>.delayed(widget.delay);
    if (mounted) {
      setState(() {
        _content = widget.builder();
        _isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _content != null) {
      return _content!;
    }

    return widget.placeholder ?? const SizedBox.shrink();
  }
}

/// 가상화된 리스트 위젯
class VirtualizedList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double? itemHeight;
  final EdgeInsets? padding;

  const VirtualizedList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.itemHeight,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemExtent: itemHeight,
      itemBuilder: (context, index) {
        return PerformanceMonitor(
          name: 'list_item_$index',
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

/// 이미지 최적화 위젯
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Image(
      image: PerformanceUtils.optimizeImageProvider(imageUrl),
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? const CircularProgressIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(Icons.broken_image);
      },
    );
  }
}
