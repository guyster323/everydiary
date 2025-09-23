import 'package:flutter/material.dart';

/// 애니메이션 성능 최적화 유틸리티
/// RepaintBoundary와 기타 성능 최적화 기법을 제공합니다.
class PerformanceOptimization {
  /// RepaintBoundary로 위젯을 감싸서 리페인트 최적화
  static Widget repaintBoundary({required Widget child, String? debugLabel}) {
    return RepaintBoundary(child: child);
  }

  /// 복잡한 애니메이션을 위한 RepaintBoundary
  static Widget complexAnimationBoundary({
    required Widget child,
    String? debugLabel,
  }) {
    return RepaintBoundary(child: child);
  }

  /// 리스트 아이템을 위한 RepaintBoundary
  static Widget listItemBoundary({required Widget child, String? debugLabel}) {
    return RepaintBoundary(child: child);
  }

  /// 카드 위젯을 위한 RepaintBoundary
  static Widget cardBoundary({required Widget child, String? debugLabel}) {
    return RepaintBoundary(child: child);
  }

  /// 이미지를 위한 RepaintBoundary
  static Widget imageBoundary({required Widget child, String? debugLabel}) {
    return RepaintBoundary(child: child);
  }

  /// 텍스트를 위한 RepaintBoundary
  static Widget textBoundary({required Widget child, String? debugLabel}) {
    return RepaintBoundary(child: child);
  }

  /// 버튼을 위한 RepaintBoundary
  static Widget buttonBoundary({required Widget child, String? debugLabel}) {
    return RepaintBoundary(child: child);
  }

  /// 아이콘을 위한 RepaintBoundary
  static Widget iconBoundary({required Widget child, String? debugLabel}) {
    return RepaintBoundary(child: child);
  }

  /// 커스텀 페인터를 위한 RepaintBoundary
  static Widget customPainterBoundary({
    required Widget child,
    String? debugLabel,
  }) {
    return RepaintBoundary(child: child);
  }

  /// 애니메이션 성능 모니터링
  static Widget performanceMonitor({
    required Widget child,
    String? debugLabel,
    bool enableLogging = false,
  }) {
    return _PerformanceMonitor(
      debugLabel: debugLabel,
      enableLogging: enableLogging,
      child: child,
    );
  }

  /// 메모리 사용량 최적화를 위한 위젯
  static Widget memoryOptimized({
    required Widget child,
    bool disposeWhenNotVisible = true,
  }) {
    return _MemoryOptimizedWidget(
      disposeWhenNotVisible: disposeWhenNotVisible,
      child: child,
    );
  }

  /// 애니메이션 프레임 드롭 감지
  static Widget frameDropDetector({
    required Widget child,
    VoidCallback? onFrameDrop,
    double threshold = 16.67, // 60fps 기준
  }) {
    return _FrameDropDetector(
      onFrameDrop: onFrameDrop,
      threshold: threshold,
      child: child,
    );
  }

  /// 애니메이션 성능 통계
  static Widget performanceStats({
    required Widget child,
    bool showStats = false,
  }) {
    return _PerformanceStats(showStats: showStats, child: child);
  }
}

/// 성능 모니터링 위젯
class _PerformanceMonitor extends StatefulWidget {
  const _PerformanceMonitor({
    required this.child,
    this.debugLabel,
    this.enableLogging = false,
  });

  final Widget child;
  final String? debugLabel;
  final bool enableLogging;

  @override
  State<_PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<_PerformanceMonitor>
    with WidgetsBindingObserver {
  int _buildCount = 0;
  Duration _totalBuildTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.enableLogging) {
      debugPrint(
        'PerformanceMonitor [${widget.debugLabel}]: App state changed to $state',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final startTime = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final endTime = DateTime.now();
      final buildTime = endTime.difference(startTime);

      _buildCount++;
      _totalBuildTime += buildTime;

      if (widget.enableLogging) {
        debugPrint(
          'PerformanceMonitor [${widget.debugLabel}]: '
          'Build #$_buildCount took ${buildTime.inMicroseconds}μs '
          '(avg: ${(_totalBuildTime.inMicroseconds / _buildCount).round()}μs)',
        );
      }
    });

    return widget.child;
  }
}

/// 메모리 최적화 위젯
class _MemoryOptimizedWidget extends StatefulWidget {
  const _MemoryOptimizedWidget({
    required this.child,
    this.disposeWhenNotVisible = true,
  });

  final Widget child;
  final bool disposeWhenNotVisible;

  @override
  State<_MemoryOptimizedWidget> createState() => _MemoryOptimizedWidgetState();
}

class _MemoryOptimizedWidgetState extends State<_MemoryOptimizedWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => !widget.disposeWhenNotVisible;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// 프레임 드롭 감지 위젯
class _FrameDropDetector extends StatefulWidget {
  const _FrameDropDetector({
    required this.child,
    this.onFrameDrop,
    this.threshold = 16.67,
  });

  final Widget child;
  final VoidCallback? onFrameDrop;
  final double threshold;

  @override
  State<_FrameDropDetector> createState() => _FrameDropDetectorState();
}

class _FrameDropDetectorState extends State<_FrameDropDetector>
    with WidgetsBindingObserver {
  DateTime? _lastFrameTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameTime = now
          .difference(_lastFrameTime!)
          .inMilliseconds
          .toDouble();
      if (frameTime > widget.threshold) {
        widget.onFrameDrop?.call();
        debugPrint(
          'FrameDropDetector: Frame drop detected (${frameTime}ms > ${widget.threshold}ms)',
        );
      }
    }
    _lastFrameTime = now;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// 성능 통계 위젯
class _PerformanceStats extends StatefulWidget {
  const _PerformanceStats({required this.child, this.showStats = false});

  final Widget child;
  final bool showStats;

  @override
  State<_PerformanceStats> createState() => _PerformanceStatsState();
}

class _PerformanceStatsState extends State<_PerformanceStats> {
  int _buildCount = 0;
  Duration _totalBuildTime = Duration.zero;

  @override
  Widget build(BuildContext context) {
    final startTime = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final endTime = DateTime.now();
      final buildTime = endTime.difference(startTime);

      _buildCount++;
      _totalBuildTime += buildTime;

      if (widget.showStats) {
        debugPrint(
          'PerformanceStats: '
          'Build #$_buildCount took ${buildTime.inMicroseconds}μs '
          '(avg: ${(_totalBuildTime.inMicroseconds / _buildCount).round()}μs)',
        );
      }
    });

    return Stack(
      children: [
        widget.child,
        if (widget.showStats)
          Positioned(
            top: 50,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Builds: $_buildCount',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    'Avg: ${(_totalBuildTime.inMicroseconds / _buildCount).round()}μs',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// 애니메이션 성능 최적화 팁
class AnimationPerformanceTips {
  /// 성능 최적화 팁 목록
  static const List<String> tips = [
    'RepaintBoundary를 사용하여 불필요한 리페인트를 방지하세요.',
    '복잡한 애니메이션은 별도의 RepaintBoundary로 감싸세요.',
    '애니메이션 컨트롤러를 적절히 dispose하세요.',
    '불필요한 setState 호출을 피하세요.',
    'AnimatedBuilder를 사용하여 애니메이션 범위를 제한하세요.',
    'Transform 위젯을 사용하여 GPU 가속을 활용하세요.',
    'Opacity 대신 AnimatedOpacity를 사용하세요.',
    '복잡한 계산은 애니메이션 외부에서 수행하세요.',
    '메모리 누수를 방지하기 위해 리스너를 적절히 제거하세요.',
    '프로덕션에서는 불필요한 디버그 로그를 제거하세요.',
  ];

  /// 성능 최적화 체크리스트
  static const List<String> checklist = [
    'RepaintBoundary 사용',
    '애니메이션 컨트롤러 dispose',
    '불필요한 setState 제거',
    'AnimatedBuilder 사용',
    'Transform 위젯 사용',
    '메모리 누수 방지',
    '프레임 드롭 모니터링',
    '성능 프로파일링',
  ];

  /// 성능 최적화 가이드
  static Widget performanceGuide() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '애니메이션 성능 최적화 가이드',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '성능 최적화 팁:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $tip', style: const TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '체크리스트:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...checklist.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('☐ $item', style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
