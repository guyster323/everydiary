import 'package:flutter/material.dart';

import '../../../core/utils/logger.dart';
import 'emotion_analysis_service.dart';

/// 이중 감정 분석 결과
class DualEmotionAnalysisResult {
  final EmotionAnalysisResult firstHalf; // 1단계 감정 (글의 절반 이전)
  final EmotionAnalysisResult secondHalf; // 2단계 감정 (글의 절반 이후)
  final String primaryEmotion; // 전체적인 주요 감정
  final double confidence; // 전체 신뢰도

  const DualEmotionAnalysisResult({
    required this.firstHalf,
    required this.secondHalf,
    required this.primaryEmotion,
    required this.confidence,
  });

  /// 위아래 그라데이션 색상 반환
  List<Color> get verticalGradientColors {
    final topColors = EmotionColorMapper.getColorsForEmotion(
      firstHalf.primaryEmotion,
    );
    final bottomColors = EmotionColorMapper.getColorsForEmotion(
      secondHalf.primaryEmotion,
    );

    // 위쪽은 1단계 감정, 아래쪽은 2단계 감정
    return [
      topColors.first, // 위쪽 색상
      bottomColors.first, // 아래쪽 색상
    ];
  }

  /// 수채화 스타일 그라데이션 색상 (여러 색상)
  List<Color> get watercolorGradientColors {
    final topColors = EmotionColorMapper.getColorsForEmotion(
      firstHalf.primaryEmotion,
    );
    final bottomColors = EmotionColorMapper.getColorsForEmotion(
      secondHalf.primaryEmotion,
    );

    // 위쪽과 아래쪽 색상을 섞어서 자연스러운 그라데이션 생성
    return [
      topColors.first, // 위쪽 첫 번째 색상
      if (topColors.length > 1) topColors[1] else topColors.first, // 위쪽 두 번째 색상
      if (bottomColors.length > 1)
        bottomColors[1]
      else
        bottomColors.first, // 아래쪽 두 번째 색상
      bottomColors.first, // 아래쪽 첫 번째 색상
    ];
  }
}

/// 이중 감정 분석 서비스
class DualEmotionAnalysisService {
  /// 텍스트를 절반으로 나누어 각각의 감정을 분석
  static DualEmotionAnalysisResult analyzeDualEmotion(String text) {
    if (text.isEmpty) {
      return const DualEmotionAnalysisResult(
        firstHalf: EmotionAnalysisResult(
          primaryEmotion: '중립',
          confidence: 0.0,
          detectedEmotions: [],
          emotionScores: {},
        ),
        secondHalf: EmotionAnalysisResult(
          primaryEmotion: '중립',
          confidence: 0.0,
          detectedEmotions: [],
          emotionScores: {},
        ),
        primaryEmotion: '중립',
        confidence: 0.0,
      );
    }

    // 텍스트를 절반으로 나누기
    final words = text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final halfPoint = (words.length / 2).ceil();

    final firstHalfText = words.take(halfPoint).join(' ');
    final secondHalfText = words.skip(halfPoint).join(' ');

    Logger.info(
      '이중 감정 분석 - 전체: ${words.length}단어, 1단계: ${firstHalfText.split(' ').length}단어, 2단계: ${secondHalfText.split(' ').length}단어',
      tag: 'DualEmotionAnalysisService',
    );

    // 각 절반에 대해 감정 분석 수행
    final firstHalfResult = EmotionAnalysisService.analyzeEmotion(
      firstHalfText,
    );
    final secondHalfResult = EmotionAnalysisService.analyzeEmotion(
      secondHalfText,
    );

    // 전체적인 주요 감정 결정 (2단계에 더 가중치)
    String primaryEmotion;
    double confidence;

    if (secondHalfResult.confidence > firstHalfResult.confidence) {
      primaryEmotion = secondHalfResult.primaryEmotion;
      confidence = secondHalfResult.confidence;
    } else {
      primaryEmotion = firstHalfResult.primaryEmotion;
      confidence = firstHalfResult.confidence;
    }

    Logger.info(
      '이중 감정 분석 결과 - 1단계: ${firstHalfResult.primaryEmotion} (${firstHalfResult.confidence.toStringAsFixed(2)}), 2단계: ${secondHalfResult.primaryEmotion} (${secondHalfResult.confidence.toStringAsFixed(2)})',
      tag: 'DualEmotionAnalysisService',
    );

    return DualEmotionAnalysisResult(
      firstHalf: firstHalfResult,
      secondHalf: secondHalfResult,
      primaryEmotion: primaryEmotion,
      confidence: confidence,
    );
  }

  /// 감정 타입을 수채화 색상 매핑에 맞게 변환
  static String mapToWatercolorEmotionType(String emotion) {
    switch (emotion.toLowerCase()) {
      case '행복':
      case '기쁨':
      case '만족':
      case '감사':
      case '설렘':
      case '흥분':
      case '기대':
        return '기쁨';
      case '슬픔':
      case '우울':
      case '외로움':
        return '슬픔';
      case '화남':
      case '분노':
      case '짜증':
        return '분노';
      case '평온':
      case '편안':
      case '안정':
        return '평온';
      case '걱정':
      case '불안':
      case '긴장':
        return '불안';
      default:
        return '중립';
    }
  }
}

/// 감정별 색상 매핑 클래스 (수채화용)
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
    '중립': [
      const Color(0xFF808080), // 회색
      const Color(0xFFA9A9A9), // 다크그레이
      const Color(0xFFD3D3D3), // 라이트그레이
    ],
  };

  static List<Color> getColorsForEmotion(String emotion) {
    return emotionColors[emotion] ?? emotionColors['중립']!;
  }
}
