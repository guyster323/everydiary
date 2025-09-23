import 'dart:math';

import 'package:flutter/material.dart';

/// 수채화 효과를 위한 CustomPainter
class WatercolorEffectPainter extends CustomPainter {
  final String emotion;
  final double animationValue;
  final List<Color> emotionColors;

  WatercolorEffectPainter({
    required this.emotion,
    required this.animationValue,
    required this.emotionColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 안전한 색상 설정
    final safeColors = emotionColors.isNotEmpty
        ? emotionColors
        : [
            const Color(0xFFF8F9FA), // 매우 밝은 회색
            const Color(0xFFE9ECEF), // 연한 회색
            const Color(0xFFDEE2E6), // 중간 회색
          ];

    // 가운데에서 바깥으로 확산되는 주요 원형 블롭들
    for (int i = 0; i < 6; i++) {
      final angle = (i * 2 * pi) / 6; // 60도씩 회전
      final distance = (80 + 60 * i) * animationValue; // 가운데에서 점점 멀어짐

      final center = Offset(
        centerX + cos(angle) * distance,
        centerY + sin(angle) * distance,
      );

      final radius = (40 + 30 * i) * animationValue;

      // 감정 색상에서 선택
      final colorIndex = i % safeColors.length;

      // 블러 효과를 위한 여러 레이어 (가운데에서 바깥으로)
      for (int j = 0; j < 5; j++) {
        final layerAlpha = (0.08 - 0.01 * j) * animationValue;
        final layerRadius = radius - j * 6;

        if (layerRadius > 0) {
          paint.color = safeColors[colorIndex].withValues(alpha: layerAlpha);
          canvas.drawCircle(center, layerRadius, paint);
        }
      }
    }

    // 가운데 중심의 핵심 블롭
    final coreRadius = 30 * animationValue;
    for (int j = 0; j < 4; j++) {
      final layerAlpha = (0.12 - 0.02 * j) * animationValue;
      final layerRadius = coreRadius - j * 5;

      if (layerRadius > 0) {
        paint.color = safeColors[0].withValues(alpha: layerAlpha);
        canvas.drawCircle(Offset(centerX, centerY), layerRadius, paint);
      }
    }

    // 추가적인 작은 블롭들 (가운데 주변에 랜덤하게)
    for (int i = 0; i < 15; i++) {
      final random = Random(i * 37); // 시드로 일관성 유지
      final angle = random.nextDouble() * 2 * pi;
      final distance = (20 + 100 * random.nextDouble()) * animationValue;

      final center = Offset(
        centerX + cos(angle) * distance,
        centerY + sin(angle) * distance,
      );

      final radius = (15 + 25 * random.nextDouble()) * animationValue;

      final colorIndex = i % safeColors.length;
      paint.color = safeColors[colorIndex].withValues(
        alpha: 0.06 * animationValue,
      );

      canvas.drawCircle(center, radius, paint);
    }

    // 가장자리로 확산되는 미세한 블롭들
    for (int i = 0; i < 20; i++) {
      final random = Random(i * 23);
      final angle = random.nextDouble() * 2 * pi;
      final distance = (150 + 50 * random.nextDouble()) * animationValue;

      final center = Offset(
        centerX + cos(angle) * distance,
        centerY + sin(angle) * distance,
      );

      final radius = (8 + 15 * random.nextDouble()) * animationValue;

      final colorIndex = i % safeColors.length;
      paint.color = safeColors[colorIndex].withValues(
        alpha: 0.04 * animationValue,
      );

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
