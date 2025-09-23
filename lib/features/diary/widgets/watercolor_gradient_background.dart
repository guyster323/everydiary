import 'dart:math';

import 'package:flutter/material.dart';

/// 감정별 색상 매핑 클래스
class EmotionColorMapper {
  static Map<String, List<Color>> emotionColors = {
    '기쁨': [
      const Color(0xFFFFD700), // 골드
      const Color(0xFFFFA500), // 오렌지
      const Color(0xFFFF69B4), // 핫핑크
    ],
    '슬픔': [
      const Color(0xFF4169E1), // 로열블루
      const Color(0xFF6A5ACD), // 슬레이트블루
      const Color(0xFF483D8B), // 다크슬레이트블루
    ],
    '분노': [
      const Color(0xFFDC143C), // 크림슨
      const Color(0xFFFF4500), // 오렌지레드
      const Color(0xFF8B0000), // 다크레드
    ],
    '평온': [
      const Color(0xFF00FA9A), // 미디엄스프링그린
      const Color(0xFF40E0D0), // 터쿠오이즈
      const Color(0xFF98FB98), // 페일그린
    ],
    '불안': [
      const Color(0xFF9370DB), // 미디엄퍼플
      const Color(0xFFDDA0DD), // 플럼
      const Color(0xFF8B008B), // 다크마젠타
    ],
    '행복': [
      const Color(0xFFFFD700), // 골드
      const Color(0xFFFFA500), // 오렌지
      const Color(0xFFFF69B4), // 핫핑크
    ],
    '우울': [
      const Color(0xFF4169E1), // 로열블루
      const Color(0xFF6A5ACD), // 슬레이트블루
      const Color(0xFF483D8B), // 다크슬레이트블루
    ],
    '화남': [
      const Color(0xFFDC143C), // 크림슨
      const Color(0xFFFF4500), // 오렌지레드
      const Color(0xFF8B0000), // 다크레드
    ],
    '편안': [
      const Color(0xFF00FA9A), // 미디엄스프링그린
      const Color(0xFF40E0D0), // 터쿠오이즈
      const Color(0xFF98FB98), // 페일그린
    ],
    '걱정': [
      const Color(0xFF9370DB), // 미디엄퍼플
      const Color(0xFFDDA0DD), // 플럼
      const Color(0xFF8B008B), // 다크마젠타
    ],
  };

  static List<Color> getColorsForEmotion(String emotion) {
    return emotionColors[emotion] ??
        [
          const Color(0xFF808080), // 회색 (중립)
          const Color(0xFFA9A9A9), // 다크그레이
          const Color(0xFFD3D3D3), // 라이트그레이
        ];
  }
}

/// 수채화 효과를 위한 CustomPainter
class WatercolorEffectPainter extends CustomPainter {
  final String emotion;
  final double animationValue;

  WatercolorEffectPainter({
    required this.emotion,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final List<Color> colors = EmotionColorMapper.getColorsForEmotion(emotion);

    // 여러 개의 원형 블롭으로 수채화 효과 생성
    for (int i = 0; i < 5; i++) {
      final center = Offset(
        size.width * (0.2 + 0.6 * i / 4) * animationValue,
        size.height * (0.3 + 0.4 * sin(i * 2)),
      );

      final radius = (50 + 30 * i) * animationValue;

      paint.color = colors[i % colors.length].withValues(alpha: 0.3);

      // 블러 효과를 위한 여러 레이어
      for (int j = 0; j < 3; j++) {
        paint.color = paint.color.withValues(alpha: 0.1 + 0.1 * j);
        canvas.drawCircle(center, radius - j * 5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 수채화 그라데이션 배경 위젯
class WatercolorGradientBackground extends StatefulWidget {
  final String emotion;
  final Widget child;
  final Duration animationDuration;

  const WatercolorGradientBackground({
    super.key,
    required this.emotion,
    required this.child,
    this.animationDuration = const Duration(seconds: 8),
  });

  @override
  State<WatercolorGradientBackground> createState() =>
      _WatercolorGradientBackgroundState();
}

class _WatercolorGradientBackgroundState
    extends State<WatercolorGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(WatercolorGradientBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emotion != widget.emotion) {
      // 감정이 변경되면 애니메이션을 다시 시작
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(gradient: _buildWatercolorGradient()),
          child: CustomPaint(
            painter: WatercolorEffectPainter(
              emotion: widget.emotion,
              animationValue: _animation.value,
            ),
            child: widget.child,
          ),
        );
      },
    );
  }

  Gradient _buildWatercolorGradient() {
    final List<Color> colors = EmotionColorMapper.getColorsForEmotion(
      widget.emotion,
    );

    return RadialGradient(
      center: Alignment.topLeft,
      radius: 1.5,
      colors: colors.map((color) => color.withValues(alpha: 0.6)).toList(),
      stops: const [0.0, 0.5, 1.0],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
