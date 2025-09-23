import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../animations/loading_animations.dart';

/// 로딩 스피너 컴포넌트
/// Material Design 3 가이드라인을 따르는 다양한 로딩 인디케이터를 제공합니다.
class CustomLoading extends StatelessWidget {
  /// 로딩 타입
  final LoadingType type;

  /// 크기
  final LoadingSize size;

  /// 색상 (null이면 테마 색상 사용)
  final Color? color;

  /// 배경 색상 (overlay 타입일 때)
  final Color? backgroundColor;

  /// 불투명도 (overlay 타입일 때)
  final double opacity;

  /// 메시지 (overlay 타입일 때)
  final String? message;

  /// 메시지 스타일
  final TextStyle? messageStyle;

  /// 애니메이션 지속 시간
  final Duration duration;

  /// 스트로크 너비 (circular 타입일 때)
  final double strokeWidth;

  /// 점의 개수 (dots 타입일 때)
  final int dotCount;

  /// 점의 크기 (dots 타입일 때)
  final double dotSize;

  /// 점 사이의 간격 (dots 타입일 때)
  final double dotSpacing;

  /// 펄스 크기 (pulse 타입일 때)
  final double pulseSize;

  /// 펄스 지속 시간 (pulse 타입일 때)
  final Duration pulseDuration;

  /// 스켈레톤 라인 수 (skeleton 타입일 때)
  final int skeletonLines;

  /// 스켈레톤 라인 높이 (skeleton 타입일 때)
  final double skeletonLineHeight;

  /// 스켈레톤 라인 간격 (skeleton 타입일 때)
  final double skeletonLineSpacing;

  /// 스켈레톤 라인 너비 (skeleton 타입일 때)
  final double? skeletonLineWidth;

  /// 스켈레톤 애니메이션 지속 시간 (skeleton 타입일 때)
  final Duration skeletonDuration;

  /// 스켈레톤 기본 색상 (skeleton 타입일 때)
  final Color? skeletonBaseColor;

  /// 스켈레톤 하이라이트 색상 (skeleton 타입일 때)
  final Color? skeletonHighlightColor;

  /// 접근성 라벨
  final String? semanticLabel;

  /// 접근성 힌트
  final String? semanticHint;

  const CustomLoading({
    super.key,
    this.type = LoadingType.circular,
    this.size = LoadingSize.medium,
    this.color,
    this.backgroundColor,
    this.opacity = 0.8,
    this.message,
    this.messageStyle,
    this.duration = const Duration(milliseconds: 1200),
    this.strokeWidth = 4.0,
    this.dotCount = 3,
    this.dotSize = 8.0,
    this.dotSpacing = 4.0,
    this.pulseSize = 1.2,
    this.pulseDuration = const Duration(milliseconds: 1000),
    this.skeletonLines = 3,
    this.skeletonLineHeight = 16.0,
    this.skeletonLineSpacing = 8.0,
    this.skeletonLineWidth,
    this.skeletonDuration = const Duration(milliseconds: 1500),
    this.skeletonBaseColor,
    this.skeletonHighlightColor,
    this.semanticLabel,
    this.semanticHint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 색상 결정
    final effectiveColor = color ?? colorScheme.primary;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;

    // 크기 결정
    final effectiveSize = _getSize(size);

    Widget loadingWidget;

    switch (type) {
      case LoadingType.circular:
        loadingWidget = _buildCircularLoading(effectiveColor, effectiveSize);
        break;
      case LoadingType.linear:
        loadingWidget = _buildLinearLoading(effectiveColor, effectiveSize);
        break;
      case LoadingType.dots:
        loadingWidget = _buildDotsLoading(effectiveColor, effectiveSize);
        break;
      case LoadingType.pulse:
        loadingWidget = _buildPulseLoading(effectiveColor, effectiveSize);
        break;
      case LoadingType.skeleton:
        loadingWidget = _buildSkeletonLoading(theme, effectiveSize);
        break;
      case LoadingType.overlay:
        loadingWidget = _buildOverlayLoading(
          context,
          effectiveColor,
          effectiveBackgroundColor,
          effectiveSize,
        );
        break;
    }

    // 접근성 래핑
    return Semantics(
      label: semanticLabel ?? '로딩 중',
      hint: semanticHint ?? '콘텐츠를 불러오는 중입니다',
      child: loadingWidget,
    );
  }

  /// 원형 로딩 인디케이터
  Widget _buildCircularLoading(Color color, double size) {
    return LoadingAnimations.circular(
      size: size,
      color: color,
      strokeWidth: strokeWidth,
    );
  }

  /// 선형 로딩 인디케이터
  Widget _buildLinearLoading(Color color, double size) {
    return LoadingAnimations.linear(
      height: strokeWidth,
      color: color,
      backgroundColor: color.withValues(alpha: 0.2),
    );
  }

  /// 점 애니메이션 로딩 인디케이터
  Widget _buildDotsLoading(Color color, double size) {
    return LoadingAnimations.bouncingDots(
      size: dotSize,
      color: color,
      duration: duration,
    );
  }

  /// 펄스 애니메이션 로딩 인디케이터
  Widget _buildPulseLoading(Color color, double size) {
    return LoadingAnimations.pulse(
      size: size,
      color: color,
      duration: pulseDuration,
    );
  }

  /// 스켈레톤 로딩 인디케이터
  Widget _buildSkeletonLoading(ThemeData theme, double size) {
    return _SkeletonLoadingAnimation(
      lines: skeletonLines,
      lineHeight: skeletonLineHeight,
      lineSpacing: skeletonLineSpacing,
      lineWidth: skeletonLineWidth,
      duration: skeletonDuration,
      baseColor: skeletonBaseColor ?? theme.colorScheme.surfaceContainerHighest,
      highlightColor: skeletonHighlightColor ?? theme.colorScheme.surface,
    );
  }

  /// 오버레이 로딩 인디케이터
  Widget _buildOverlayLoading(
    BuildContext context,
    Color color,
    Color backgroundColor,
    double size,
  ) {
    return Container(
      color: backgroundColor.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCircularLoading(color, size),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: messageStyle ?? Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 크기에 따른 실제 크기 반환
  double _getSize(LoadingSize size) {
    switch (size) {
      case LoadingSize.small:
        return 24.0;
      case LoadingSize.medium:
        return 32.0;
      case LoadingSize.large:
        return 48.0;
      case LoadingSize.extraLarge:
        return 64.0;
    }
  }

  /// 오버레이 로딩 표시
  static void showOverlay(
    BuildContext context, {
    String? message,
    Color? color,
    Color? backgroundColor,
    double opacity = 0.8,
    LoadingSize size = LoadingSize.medium,
    Duration duration = const Duration(milliseconds: 1200),
    String? semanticLabel,
    String? semanticHint,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: CustomLoading(
          type: LoadingType.overlay,
          message: message,
          color: color,
          backgroundColor: backgroundColor,
          opacity: opacity,
          size: size,
          duration: duration,
          semanticLabel: semanticLabel,
          semanticHint: semanticHint,
        ),
      ),
    );
  }

  /// 오버레이 로딩 숨기기
  static void hideOverlay(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// 인라인 로딩 표시
  static Widget inline({
    LoadingType type = LoadingType.circular,
    LoadingSize size = LoadingSize.small,
    Color? color,
    Duration duration = const Duration(milliseconds: 1200),
    String? semanticLabel,
    String? semanticHint,
  }) {
    return CustomLoading(
      type: type,
      size: size,
      color: color,
      duration: duration,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
    );
  }

  /// 버튼 내부 로딩 표시
  static Widget button({
    LoadingSize size = LoadingSize.small,
    Color? color,
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    return CustomLoading(
      type: LoadingType.circular,
      size: size,
      color: color,
      duration: duration,
      strokeWidth: 2.0,
      semanticLabel: '로딩 중',
    );
  }

  /// 페이지 로딩 표시
  static Widget page({
    String? message,
    Color? color,
    LoadingSize size = LoadingSize.large,
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomLoading(
            type: LoadingType.circular,
            size: size,
            color: color,
            duration: duration,
            semanticLabel: '페이지 로딩 중',
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// 로딩 타입 열거형
enum LoadingType { circular, linear, dots, pulse, skeleton, overlay }

/// 로딩 크기 열거형
enum LoadingSize { small, medium, large, extraLarge }

/// 점 애니메이션 로딩 인디케이터
class _DotsLoadingAnimation extends StatefulWidget {
  final Color color;
  final int dotCount;
  final double dotSize;
  final double dotSpacing;
  final Duration duration;

  const _DotsLoadingAnimation({
    required this.color,
    required this.dotCount,
    required this.dotSize,
    required this.dotSpacing,
    required this.duration,
  });

  @override
  State<_DotsLoadingAnimation> createState() => _DotsLoadingAnimationState();
}

class _DotsLoadingAnimationState extends State<_DotsLoadingAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.dotCount,
      (index) => AnimationController(duration: widget.duration, vsync: this),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    _startAnimation();
  }

  void _startAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(
                right: index < widget.dotCount - 1 ? widget.dotSpacing : 0,
              ),
              child: Transform.scale(
                scale: 0.5 + (_animations[index].value * 0.5),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// 펄스 애니메이션 로딩 인디케이터
class _PulseLoadingAnimation extends StatefulWidget {
  final Color color;
  final double size;
  final double pulseSize;
  final Duration duration;

  const _PulseLoadingAnimation({
    required this.color,
    required this.size,
    required this.pulseSize,
    required this.duration,
  });

  @override
  State<_PulseLoadingAnimation> createState() => _PulseLoadingAnimationState();
}

class _PulseLoadingAnimationState extends State<_PulseLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 1.0,
      end: widget.pulseSize,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

/// 스켈레톤 로딩 인디케이터
class _SkeletonLoadingAnimation extends StatefulWidget {
  final int lines;
  final double lineHeight;
  final double lineSpacing;
  final double? lineWidth;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const _SkeletonLoadingAnimation({
    required this.lines,
    required this.lineHeight,
    required this.lineSpacing,
    required this.lineWidth,
    required this.duration,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<_SkeletonLoadingAnimation> createState() =>
      _SkeletonLoadingAnimationState();
}

class _SkeletonLoadingAnimationState extends State<_SkeletonLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(widget.lines, (index) {
            final isLastLine = index == widget.lines - 1;
            final lineWidth = isLastLine
                ? (widget.lineWidth ?? 0.6)
                : (widget.lineWidth ?? 1.0);

            return Container(
              margin: EdgeInsets.only(
                bottom: isLastLine ? 0 : widget.lineSpacing,
              ),
              child: _SkeletonLine(
                width: lineWidth,
                height: widget.lineHeight,
                baseColor: widget.baseColor,
                highlightColor: widget.highlightColor,
                animation: _animation,
              ),
            );
          }),
        );
      },
    );
  }
}

/// 스켈레톤 라인 위젯
class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  final Color baseColor;
  final Color highlightColor;
  final Animation<double> animation;

  const _SkeletonLine({
    required this.width,
    required this.height,
    required this.baseColor,
    required this.highlightColor,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * 200, // 기본 너비 200에 비례
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Positioned(
                left: animation.value * 200,
                child: Container(
                  width: 50,
                  height: height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        highlightColor,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 로딩 유틸리티 클래스
class LoadingUtils {
  /// 로딩 상태에 따른 햅틱 피드백
  static void provideHapticFeedback(LoadingState state) {
    switch (state) {
      case LoadingState.start:
        HapticFeedback.lightImpact();
        break;
      case LoadingState.complete:
        HapticFeedback.mediumImpact();
        break;
      case LoadingState.error:
        HapticFeedback.heavyImpact();
        break;
    }
  }

  /// 로딩 메시지 생성
  static String getLoadingMessage(LoadingContext context) {
    switch (context) {
      case LoadingContext.page:
        return '페이지를 불러오는 중...';
      case LoadingContext.data:
        return '데이터를 불러오는 중...';
      case LoadingContext.image:
        return '이미지를 불러오는 중...';
      case LoadingContext.video:
        return '비디오를 불러오는 중...';
      case LoadingContext.audio:
        return '오디오를 불러오는 중...';
      case LoadingContext.file:
        return '파일을 불러오는 중...';
      case LoadingContext.network:
        return '네트워크 연결 중...';
      case LoadingContext.upload:
        return '업로드 중...';
      case LoadingContext.download:
        return '다운로드 중...';
      case LoadingContext.processing:
        return '처리 중...';
      case LoadingContext.saving:
        return '저장 중...';
      case LoadingContext.deleting:
        return '삭제 중...';
      case LoadingContext.searching:
        return '검색 중...';
      case LoadingContext.filtering:
        return '필터링 중...';
      case LoadingContext.sorting:
        return '정렬 중...';
      case LoadingContext.refreshing:
        return '새로고침 중...';
      case LoadingContext.syncing:
        return '동기화 중...';
      case LoadingContext.authenticating:
        return '인증 중...';
      case LoadingContext.validating:
        return '검증 중...';
      case LoadingContext.custom:
        return '로딩 중...';
    }
  }

  /// 로딩 타입에 따른 적절한 크기 반환
  static LoadingSize getAppropriateSize(LoadingContext context) {
    switch (context) {
      case LoadingContext.page:
        return LoadingSize.large;
      case LoadingContext.data:
        return LoadingSize.medium;
      case LoadingContext.image:
        return LoadingSize.medium;
      case LoadingContext.video:
        return LoadingSize.medium;
      case LoadingContext.audio:
        return LoadingSize.small;
      case LoadingContext.file:
        return LoadingSize.medium;
      case LoadingContext.network:
        return LoadingSize.medium;
      case LoadingContext.upload:
        return LoadingSize.medium;
      case LoadingContext.download:
        return LoadingSize.medium;
      case LoadingContext.processing:
        return LoadingSize.medium;
      case LoadingContext.saving:
        return LoadingSize.small;
      case LoadingContext.deleting:
        return LoadingSize.small;
      case LoadingContext.searching:
        return LoadingSize.small;
      case LoadingContext.filtering:
        return LoadingSize.small;
      case LoadingContext.sorting:
        return LoadingSize.small;
      case LoadingContext.refreshing:
        return LoadingSize.small;
      case LoadingContext.syncing:
        return LoadingSize.medium;
      case LoadingContext.authenticating:
        return LoadingSize.medium;
      case LoadingContext.validating:
        return LoadingSize.small;
      case LoadingContext.custom:
        return LoadingSize.medium;
    }
  }

  /// 로딩 타입에 따른 적절한 타입 반환
  static LoadingType getAppropriateType(LoadingContext context) {
    switch (context) {
      case LoadingContext.page:
        return LoadingType.circular;
      case LoadingContext.data:
        return LoadingType.circular;
      case LoadingContext.image:
        return LoadingType.pulse;
      case LoadingContext.video:
        return LoadingType.pulse;
      case LoadingContext.audio:
        return LoadingType.dots;
      case LoadingContext.file:
        return LoadingType.linear;
      case LoadingContext.network:
        return LoadingType.circular;
      case LoadingContext.upload:
        return LoadingType.linear;
      case LoadingContext.download:
        return LoadingType.linear;
      case LoadingContext.processing:
        return LoadingType.circular;
      case LoadingContext.saving:
        return LoadingType.dots;
      case LoadingContext.deleting:
        return LoadingType.dots;
      case LoadingContext.searching:
        return LoadingType.dots;
      case LoadingContext.filtering:
        return LoadingType.dots;
      case LoadingContext.sorting:
        return LoadingType.dots;
      case LoadingContext.refreshing:
        return LoadingType.circular;
      case LoadingContext.syncing:
        return LoadingType.circular;
      case LoadingContext.authenticating:
        return LoadingType.circular;
      case LoadingContext.validating:
        return LoadingType.dots;
      case LoadingContext.custom:
        return LoadingType.circular;
    }
  }
}

/// 로딩 상태 열거형
enum LoadingState { start, complete, error }

/// 로딩 컨텍스트 열거형
enum LoadingContext {
  page,
  data,
  image,
  video,
  audio,
  file,
  network,
  upload,
  download,
  processing,
  saving,
  deleting,
  searching,
  filtering,
  sorting,
  refreshing,
  syncing,
  authenticating,
  validating,
  custom,
}
