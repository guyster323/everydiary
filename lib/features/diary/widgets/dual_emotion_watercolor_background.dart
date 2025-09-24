import 'dart:math';

import 'package:flutter/material.dart';

import '../services/dual_emotion_analysis_service.dart';

/// 이중 감정 수채화 효과를 위한 CustomPainter
class DualEmotionWatercolorPainter extends CustomPainter {
  final DualEmotionAnalysisResult emotionResult;
  final double animationValue;

  DualEmotionWatercolorPainter({
    required this.emotionResult,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 위쪽 색상 (1단계 감정)
    final topColors = EmotionColorMapper.getColorsForEmotion(
      DualEmotionAnalysisService.mapToWatercolorEmotionType(
        emotionResult.firstHalf.primaryEmotion,
      ),
    );

    // 아래쪽 색상 (2단계 감정)
    final bottomColors = EmotionColorMapper.getColorsForEmotion(
      DualEmotionAnalysisService.mapToWatercolorEmotionType(
        emotionResult.secondHalf.primaryEmotion,
      ),
    );

    // 위쪽 영역에 수채화 효과 (1단계 감정)
    _paintWatercolorBlobs(
      canvas,
      paint,
      size,
      topColors,
      const Rect.fromLTWH(0, 0, 1, 0.5), // 위쪽 절반
    );

    // 아래쪽 영역에 수채화 효과 (2단계 감정)
    _paintWatercolorBlobs(
      canvas,
      paint,
      size,
      bottomColors,
      const Rect.fromLTWH(0, 0.5, 1, 0.5), // 아래쪽 절반
    );
  }

  void _paintWatercolorBlobs(
    Canvas canvas,
    Paint paint,
    Size size,
    List<Color> colors,
    Rect area,
  ) {
    final areaHeight = size.height * area.height;
    final areaTop = size.height * area.top;
    final areaWidth = size.width * area.width;
    final areaLeft = size.width * area.left;

    // 여러 개의 원형 블롭으로 수채화 효과 생성
    for (int i = 0; i < 4; i++) {
      final center = Offset(
        areaLeft + areaWidth * (0.2 + 0.6 * i / 3) * animationValue,
        areaTop + areaHeight * (0.2 + 0.6 * sin(i * 1.5)) * animationValue,
      );

      final radius = (30 + 20 * i) * animationValue;

      paint.color = colors[i % colors.length].withValues(alpha: 0.25);

      // 블러 효과를 위한 여러 레이어
      for (int j = 0; j < 3; j++) {
        paint.color = paint.color.withValues(alpha: 0.08 + 0.05 * j);
        canvas.drawCircle(center, radius - j * 3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 이중 감정 수채화 그라데이션 배경 위젯
class DualEmotionWatercolorBackground extends StatefulWidget {
  final DualEmotionAnalysisResult emotionResult;
  final Widget child;
  final Duration animationDuration;

  const DualEmotionWatercolorBackground({
    super.key,
    required this.emotionResult,
    required this.child,
    this.animationDuration = const Duration(seconds: 8),
  });

  @override
  State<DualEmotionWatercolorBackground> createState() =>
      _DualEmotionWatercolorBackgroundState();
}

class _DualEmotionWatercolorBackgroundState
    extends State<DualEmotionWatercolorBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _colorTransitionController;
  late Animation<double> _colorTransitionAnimation;

  // 이전 감정 결과 저장
  DualEmotionAnalysisResult? _previousEmotionResult;

  // 감정 변화 감지를 위한 상태
  String _lastEmotionKey = '';
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();

    // 수채화 효과 애니메이션
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 색상 전환 애니메이션 (8초에 걸쳐 부드럽게 변화)
    _colorTransitionController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _colorTransitionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _colorTransitionController,
        curve: Curves.easeInOut,
      ),
    );

    // 초기 감정 키 설정
    _lastEmotionKey = _getEmotionKey(widget.emotionResult);

    _animationController.forward();
    _colorTransitionController.forward();
  }

  @override
  void didUpdateWidget(DualEmotionWatercolorBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 감정 변화 감지 - 핵심 개선 부분
    final newEmotionKey = _getEmotionKey(widget.emotionResult);

    if (_lastEmotionKey != newEmotionKey && !_isTransitioning) {
      debugPrint('🎨 감정 변화 감지: $_lastEmotionKey → $newEmotionKey');

      // 이전 감정 결과 저장
      _previousEmotionResult = oldWidget.emotionResult;
      _lastEmotionKey = newEmotionKey;
      _isTransitioning = true;

      // 색상 전환 애니메이션만 재시작 (8초간 부드럽게)
      _colorTransitionController.reset();
      _colorTransitionController.forward().then((_) {
        if (mounted) {
          _isTransitioning = false;
        }
      });

      debugPrint('🎨 8초간 부드러운 색상 전환 시작');
    } else if (_lastEmotionKey == newEmotionKey) {
      // 같은 감정이면 애니메이션 재시작하지 않음
      debugPrint('🎨 동일한 감정 - 애니메이션 유지: $newEmotionKey');
    }
  }

  /// 감정 결과를 고유 키로 변환 (감정 변화 감지용)
  String _getEmotionKey(DualEmotionAnalysisResult emotionResult) {
    return '${emotionResult.firstHalf.primaryEmotion}_${emotionResult.secondHalf.primaryEmotion}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animation, _colorTransitionAnimation]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(gradient: _buildDualEmotionGradient()),
          child: CustomPaint(
            painter: DualEmotionWatercolorPainter(
              emotionResult: widget.emotionResult,
              animationValue: _animation.value,
            ),
            child: widget.child,
          ),
        );
      },
    );
  }

  Gradient _buildDualEmotionGradient() {
    // 현재 감정 색상
    final currentFirstHalfColors = EmotionColorMapper.getColorsForEmotion(
      DualEmotionAnalysisService.mapToWatercolorEmotionType(
        widget.emotionResult.firstHalf.primaryEmotion,
      ),
    );
    final currentSecondHalfColors = EmotionColorMapper.getColorsForEmotion(
      DualEmotionAnalysisService.mapToWatercolorEmotionType(
        widget.emotionResult.secondHalf.primaryEmotion,
      ),
    );

    // 이전 감정 색상 (있는 경우)
    List<Color>? previousFirstHalfColors;
    List<Color>? previousSecondHalfColors;

    if (_previousEmotionResult != null && _isTransitioning) {
      previousFirstHalfColors = EmotionColorMapper.getColorsForEmotion(
        DualEmotionAnalysisService.mapToWatercolorEmotionType(
          _previousEmotionResult!.firstHalf.primaryEmotion,
        ),
      );
      previousSecondHalfColors = EmotionColorMapper.getColorsForEmotion(
        DualEmotionAnalysisService.mapToWatercolorEmotionType(
          _previousEmotionResult!.secondHalf.primaryEmotion,
        ),
      );
    }

    // 애니메이션 값에 따른 부드러운 전환
    final animationValue = _colorTransitionAnimation.value;

    // 스므르듯한 전환을 위한 easing 함수 적용
    final easedValue = _easeInOutCubic(animationValue);

    // 위아래 그라데이션 생성
    final colors = <Color>[];
    final stops = <double>[];

    if (_previousEmotionResult != null &&
        previousFirstHalfColors != null &&
        previousSecondHalfColors != null &&
        _isTransitioning) {
      // 감정 전환 중: 이전 감정에서 현재 감정으로 부드럽게 전환

      // 위쪽 색상: 이전 → 현재 (A10 → A5 방식)
      final topColor1 = Color.lerp(
        previousFirstHalfColors.first.withValues(alpha: 0.7), // A10
        currentFirstHalfColors.first.withValues(alpha: 0.35), // A5
        easedValue,
      )!;

      final topColor2 = Color.lerp(
        previousFirstHalfColors.length > 1
            ? previousFirstHalfColors[1].withValues(alpha: 0.5)
            : previousFirstHalfColors.first.withValues(alpha: 0.5),
        currentFirstHalfColors.length > 1
            ? currentFirstHalfColors[1].withValues(alpha: 0.25)
            : currentFirstHalfColors.first.withValues(alpha: 0.25),
        easedValue,
      )!;

      // 아래쪽 색상: 이전 → 현재 (B5 → B10 방식)
      final bottomColor1 = Color.lerp(
        previousSecondHalfColors.length > 1
            ? previousSecondHalfColors[1].withValues(alpha: 0.25)
            : previousSecondHalfColors.first.withValues(alpha: 0.25), // B5
        currentSecondHalfColors.length > 1
            ? currentSecondHalfColors[1].withValues(alpha: 0.5)
            : currentSecondHalfColors.first.withValues(alpha: 0.5),
        easedValue,
      )!;

      final bottomColor2 = Color.lerp(
        previousSecondHalfColors.first.withValues(alpha: 0.35), // B5
        currentSecondHalfColors.first.withValues(alpha: 0.7), // B10
        easedValue,
      )!;

      colors.addAll([topColor1, topColor2, bottomColor1, bottomColor2]);

      debugPrint('🎨 전환 진행률: ${(easedValue * 100).toStringAsFixed(1)}%');
    } else {
      // 전환이 없거나 완료된 경우: 현재 감정 색상 사용
      final topColor1 = currentFirstHalfColors.first.withValues(alpha: 0.7);
      final topColor2 = currentFirstHalfColors.length > 1
          ? currentFirstHalfColors[1].withValues(alpha: 0.5)
          : currentFirstHalfColors.first.withValues(alpha: 0.5);
      final bottomColor1 = currentSecondHalfColors.length > 1
          ? currentSecondHalfColors[1].withValues(alpha: 0.5)
          : currentSecondHalfColors.first.withValues(alpha: 0.5);
      final bottomColor2 = currentSecondHalfColors.first.withValues(alpha: 0.7);

      colors.addAll([topColor1, topColor2, bottomColor1, bottomColor2]);
    }

    stops.addAll([0.0, 0.3, 0.7, 1.0]);

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
      stops: stops,
    );
  }

  /// 부드러운 easing 함수 (스며드는 느낌을 위해)
  double _easeInOutCubic(double t) {
    if (t < 0.5) {
      return 4 * t * t * t;
    } else {
      return 1 - pow(-2 * t + 2, 3) / 2;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _colorTransitionController.dispose();
    super.dispose();
  }
}
