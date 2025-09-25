import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../services/dual_emotion_analysis_service.dart';

/// 개선된 수채화 번지기 효과를 위한 CustomPainter
class WatercolorBleedPainter extends CustomPainter {
  final DualEmotionAnalysisResult emotionResult;
  final double animationValue;
  final double bleedIntensity;

  WatercolorBleedPainter({
    required this.emotionResult,
    required this.animationValue,
    this.bleedIntensity = 1.0,
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

    // 수채화 번지기 효과 생성
    _paintWatercolorBleed(canvas, paint, size, topColors, bottomColors);
  }

  void _paintWatercolorBleed(
    Canvas canvas,
    Paint paint,
    Size size,
    List<Color> topColors,
    List<Color> bottomColors,
  ) {
    // 다중 레이어로 번지기 효과 구현
    _paintBleedLayer(canvas, paint, size, topColors, 0.0, 0.4, 8);
    _paintBleedLayer(canvas, paint, size, bottomColors, 0.6, 1.0, 8);

    // 중간 혼합 영역
    _paintBlendingArea(canvas, paint, size, topColors, bottomColors);
  }

  void _paintBleedLayer(
    Canvas canvas,
    Paint paint,
    Size size,
    List<Color> colors,
    double startY,
    double endY,
    int blobCount,
  ) {
    final areaHeight = size.height * (endY - startY);
    final areaTop = size.height * startY;

    // 여러 개의 블롭으로 불규칙한 번지기 효과
    for (int i = 0; i < blobCount; i++) {
      final centerX = size.width * (0.1 + 0.8 * Random(i).nextDouble());
      final centerY = areaTop + areaHeight * Random(i + 100).nextDouble();

      final baseRadius =
          (40 + 30 * Random(i + 200).nextDouble()) *
          animationValue *
          bleedIntensity;
      final color = colors[i % colors.length];

      // 다중 레이어 블러 효과로 번지기 구현
      _paintBleedBlob(
        canvas,
        paint,
        Offset(centerX, centerY),
        baseRadius,
        color,
      );
    }
  }

  void _paintBleedBlob(
    Canvas canvas,
    Paint paint,
    Offset center,
    double radius,
    Color color,
  ) {
    // 5단계 레이어로 자연스러운 번지기 효과
    const layers = 5;
    for (int layer = 0; layer < layers; layer++) {
      final layerRadius = radius * (1.0 + layer * 0.3);
      final layerAlpha = (0.15 - layer * 0.02) * bleedIntensity;

      paint.color = color.withValues(alpha: layerAlpha);

      // 불규칙한 형태를 위한 다중 원
      final blobCount = 3 + layer;
      for (int blob = 0; blob < blobCount; blob++) {
        final angle = (2 * pi * blob / blobCount) + (layer * pi / 6);
        final offset = Offset(
          center.dx + cos(angle) * layerRadius * 0.3,
          center.dy + sin(angle) * layerRadius * 0.2,
        );

        canvas.drawCircle(
          offset,
          layerRadius * (0.8 + Random(blob).nextDouble() * 0.4),
          paint,
        );
      }
    }

    // 중심부 강조
    paint.color = color.withValues(alpha: 0.25 * bleedIntensity);
    canvas.drawCircle(center, radius * 0.6, paint);
  }

  void _paintBlendingArea(
    Canvas canvas,
    Paint paint,
    Size size,
    List<Color> topColors,
    List<Color> bottomColors,
  ) {
    // 중간 영역에서 색상 혼합
    final blendArea = Rect.fromLTWH(
      0,
      size.height * 0.35,
      size.width,
      size.height * 0.3,
    );

    final topColor = topColors.first;
    final bottomColor = bottomColors.first;

    // 그라데이션 혼합
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        topColor.withValues(alpha: 0.2 * bleedIntensity),
        Color.lerp(
          topColor,
          bottomColor,
          0.5,
        )!.withValues(alpha: 0.3 * bleedIntensity),
        bottomColor.withValues(alpha: 0.2 * bleedIntensity),
      ],
    );

    paint.shader = gradient.createShader(blendArea);
    canvas.drawRect(blendArea, paint);
    paint.shader = null;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 개선된 이중 감정 수채화 번지기 배경 위젯
class ImprovedDualEmotionWatercolorBackground extends StatefulWidget {
  final DualEmotionAnalysisResult emotionResult;
  final Widget child;
  final Duration animationDuration;

  const ImprovedDualEmotionWatercolorBackground({
    super.key,
    required this.emotionResult,
    required this.child,
    this.animationDuration = const Duration(seconds: 8),
  });

  @override
  State<ImprovedDualEmotionWatercolorBackground> createState() =>
      _ImprovedDualEmotionWatercolorBackgroundState();
}

class _ImprovedDualEmotionWatercolorBackgroundState
    extends State<ImprovedDualEmotionWatercolorBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _colorTransitionController;
  late Animation<double> _colorTransitionAnimation;
  late AnimationController _bleedController;
  late Animation<double> _bleedAnimation;

  // 이전 감정 결과 저장
  DualEmotionAnalysisResult? _previousEmotionResult;

  // 감정 변화 감지를 위한 상태
  String _lastEmotionKey = '';
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();

    // 메인 수채화 효과 애니메이션
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    // 색상 전환 애니메이션 (8초에 걸쳐 부드럽게 변화)
    _colorTransitionController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _colorTransitionAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _colorTransitionController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // 번지기 효과 애니메이션
    _bleedController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );
    _bleedAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bleedController, curve: Curves.easeOutSine),
    );

    // 초기 감정 키 설정
    _lastEmotionKey = _getEmotionKey(widget.emotionResult);

    // 애니메이션 시작
    _animationController.forward();
    _colorTransitionController.forward();
    _bleedController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(ImprovedDualEmotionWatercolorBackground oldWidget) {
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

      debugPrint('🎨 8초간 부드러운 수채화 번지기 전환 시작');
    }
  }

  /// 감정 결과를 고유 키로 변환 (감정 변화 감지용)
  String _getEmotionKey(DualEmotionAnalysisResult emotionResult) {
    return '${emotionResult.firstHalf.primaryEmotion}_${emotionResult.secondHalf.primaryEmotion}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _animation,
        _colorTransitionAnimation,
        _bleedAnimation,
      ]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(gradient: _buildImprovedGradient()),
          child: CustomPaint(
            painter: WatercolorBleedPainter(
              emotionResult: widget.emotionResult,
              animationValue: _animation.value,
              bleedIntensity: 0.8 + _bleedAnimation.value * 0.4,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }

  /// 개선된 그라데이션 생성
  Gradient _buildImprovedGradient() {
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

    // 부드러운 전환을 위한 easing 함수 적용
    final easedValue = _easeInOutCubic(_colorTransitionAnimation.value);

    // 색상 배열 생성
    final colors = <Color>[];
    final stops = <double>[];

    if (_previousEmotionResult != null &&
        previousFirstHalfColors != null &&
        previousSecondHalfColors != null &&
        _isTransitioning) {
      // 전환 중: 다층 그라데이션으로 자연스러운 번지기 효과

      // 상단 영역 (3단계 그라데이션)
      colors.add(
        Color.lerp(
          previousFirstHalfColors.first.withValues(alpha: 0.6),
          currentFirstHalfColors.first.withValues(alpha: 0.6),
          easedValue,
        )!,
      );

      colors.add(
        Color.lerp(
          previousFirstHalfColors.length > 1
              ? previousFirstHalfColors[1].withValues(alpha: 0.4)
              : previousFirstHalfColors.first.withValues(alpha: 0.4),
          currentFirstHalfColors.length > 1
              ? currentFirstHalfColors[1].withValues(alpha: 0.4)
              : currentFirstHalfColors.first.withValues(alpha: 0.4),
          easedValue,
        )!,
      );

      // 중간 혼합 영역
      final blendColor = Color.lerp(
        Color.lerp(
          previousFirstHalfColors.first,
          previousSecondHalfColors.first,
          0.5,
        )!.withValues(alpha: 0.2),
        Color.lerp(
          currentFirstHalfColors.first,
          currentSecondHalfColors.first,
          0.5,
        )!.withValues(alpha: 0.2),
        easedValue,
      )!;
      colors.add(blendColor);

      // 하단 영역 (3단계 그라데이션)
      colors.add(
        Color.lerp(
          previousSecondHalfColors.length > 1
              ? previousSecondHalfColors[1].withValues(alpha: 0.4)
              : previousSecondHalfColors.first.withValues(alpha: 0.4),
          currentSecondHalfColors.length > 1
              ? currentSecondHalfColors[1].withValues(alpha: 0.4)
              : currentSecondHalfColors.first.withValues(alpha: 0.4),
          easedValue,
        )!,
      );

      colors.add(
        Color.lerp(
          previousSecondHalfColors.first.withValues(alpha: 0.6),
          currentSecondHalfColors.first.withValues(alpha: 0.6),
          easedValue,
        )!,
      );

      stops.addAll([0.0, 0.2, 0.5, 0.8, 1.0]);
    } else {
      // 정적 상태: 현재 감정의 다층 그라데이션
      colors.addAll([
        currentFirstHalfColors.first.withValues(alpha: 0.6),
        if (currentFirstHalfColors.length > 1)
          currentFirstHalfColors[1].withValues(alpha: 0.4)
        else
          currentFirstHalfColors.first.withValues(alpha: 0.4),
        Color.lerp(
          currentFirstHalfColors.first,
          currentSecondHalfColors.first,
          0.5,
        )!.withValues(alpha: 0.2),
        if (currentSecondHalfColors.length > 1)
          currentSecondHalfColors[1].withValues(alpha: 0.4)
        else
          currentSecondHalfColors.first.withValues(alpha: 0.4),
        currentSecondHalfColors.first.withValues(alpha: 0.6),
      ]);

      stops.addAll([0.0, 0.2, 0.5, 0.8, 1.0]);
    }

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
      stops: stops,
    );
  }

  /// 부드러운 easing 함수 (수채화 번지는 느낌)
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
    _bleedController.dispose();
    super.dispose();
  }
}

