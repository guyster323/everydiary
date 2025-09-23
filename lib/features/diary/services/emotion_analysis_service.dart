import 'package:flutter/material.dart';

import '../../../core/utils/logger.dart';

/// 감정 분석 결과
class EmotionAnalysisResult {
  final String primaryEmotion;
  final double confidence;
  final List<String> detectedEmotions;
  final Map<String, double> emotionScores;

  const EmotionAnalysisResult({
    required this.primaryEmotion,
    required this.confidence,
    required this.detectedEmotions,
    required this.emotionScores,
  });

  /// 감정에 따른 색상 반환 (매우 밝고 온화한 색상)
  Color get emotionColor {
    switch (primaryEmotion.toLowerCase()) {
      case '행복':
      case '기쁨':
      case '만족':
      case '감사':
        return const Color(0xFFC8E6C9); // 매우 밝은 연두색
      case '슬픔':
      case '우울':
      case '외로움':
        return const Color(0xFFBBDEFB); // 매우 밝은 하늘색
      case '화남':
      case '분노':
      case '짜증':
        return const Color(0xFFFFCCBC); // 매우 밝은 주황색
      case '평온':
      case '편안':
      case '안정':
        return const Color(0xFFC8E6C9); // 매우 밝은 민트색
      case '설렘':
      case '흥분':
      case '기대':
        return const Color(0xFFE1BEE7); // 매우 밝은 라벤더색
      case '걱정':
      case '불안':
      case '긴장':
        return const Color(0xFFD1C4E9); // 매우 밝은 보라색
      case '피곤':
      case '지침':
        return const Color(0xFFD7CCC8); // 매우 밝은 회색
      case '실망':
      case '후회':
        return const Color(0xFFFFE0B2); // 매우 밝은 오렌지색
      case '중립':
      default:
        return const Color(0xFFFCE4EC); // 매우 밝은 핑크색
    }
  }

  /// 감정에 따른 그라데이션 색상 반환 (상단, 하단)
  List<Color> get gradientColors {
    final baseColor = emotionColor;

    // 감정의 강도에 따라 색상 조정
    final intensity = confidence;

    // 상단 색상 (더 진한 색)
    final topColor = Color.fromRGBO(
      ((baseColor.r * 255.0) * (0.7 + intensity * 0.3)).round(),
      ((baseColor.g * 255.0) * (0.7 + intensity * 0.3)).round(),
      ((baseColor.b * 255.0) * (0.7 + intensity * 0.3)).round(),
      1.0,
    );

    // 하단 색상 (더 밝은 색)
    final bottomColor = Color.fromRGBO(
      ((baseColor.r * 255.0) * (0.9 + intensity * 0.1)).round(),
      ((baseColor.g * 255.0) * (0.9 + intensity * 0.1)).round(),
      ((baseColor.b * 255.0) * (0.9 + intensity * 0.1)).round(),
      0.8,
    );

    return [topColor, bottomColor];
  }

  /// 앱 전체 배경용 수채화 느낌의 부드러운 색상 (첨부 팔레트 기반)
  List<Color> get watercolorBackgroundColors {
    // 첨부된 색상 팔레트를 기반으로 한 감정별 색상 설정
    switch (primaryEmotion.toLowerCase()) {
      case '행복':
      case '기쁨':
      case '만족':
      case '감사':
        return [
          const Color(0xFFFFD700), // 골드
          const Color(0xFFFFA500), // 오렌지
          const Color(0xFFFF69B4), // 핫핑크
        ];
      case '슬픔':
      case '우울':
      case '외로움':
        return [
          const Color(0xFF4169E1), // 로열블루
          const Color(0xFF6A5ACD), // 슬레이트블루
          const Color(0xFF483D8B), // 다크슬레이트블루
        ];
      case '화남':
      case '분노':
      case '짜증':
        return [
          const Color(0xFFDC143C), // 크림슨
          const Color(0xFFFF4500), // 오렌지레드
          const Color(0xFF8B0000), // 다크레드
        ];
      case '평온':
      case '편안':
      case '안정':
        return [
          const Color(0xFF00FA9A), // 미디엄스프링그린
          const Color(0xFF40E0D0), // 터쿠오이즈
          const Color(0xFF98FB98), // 페일그린
        ];
      case '설렘':
      case '흥분':
      case '기대':
        return [
          const Color(0xFFF0C27B), // 주황빛 노란색 (Energy)
          const Color(0xFFF5E6A8), // 옅은 노란색 (Hope)
          const Color(0xFFFFD700), // 골드
        ];
      case '걱정':
      case '불안':
      case '긴장':
        return [
          const Color(0xFF9370DB), // 미디엄퍼플
          const Color(0xFFDDA0DD), // 플럼
          const Color(0xFF8B008B), // 다크마젠타
        ];
      case '피곤':
      case '지침':
        return [
          const Color(0xFFC8D8C8).withValues(alpha: 0.4), // 연한 녹색-회색 (Neutral)
          const Color(0xFFB8E6B8).withValues(alpha: 0.3), // 연한 녹색 (Nature)
        ];
      case '실망':
      case '후회':
        return [
          const Color(0xFFB5A7C0).withValues(alpha: 0.4), // 차분한 보라색 (Nostalgia)
          const Color(
            0xFF9B8AA0,
          ).withValues(alpha: 0.3), // 차분한 보라색/회색 (Mystery)
        ];
      case '사랑':
      case '애정':
        return [
          const Color(0xFFF5B7C8).withValues(alpha: 0.4), // 부드러운 핑크색 (Love)
          const Color(0xFFFFB3D9).withValues(alpha: 0.3), // 밝은 핑크색 (Inspire)
        ];
      case '창의':
      case '영감':
        return [
          const Color(0xFFFFB3D9).withValues(alpha: 0.4), // 밝은 핑크색 (Inspire)
          const Color(0xFFD8C5E0).withValues(alpha: 0.3), // 연한 라벤더색 (Elegance)
        ];
      case '우아':
      case '고상':
        return [
          const Color(0xFFD8C5E0).withValues(alpha: 0.4), // 연한 라벤더색 (Elegance)
          const Color(0xFFB5A7C0).withValues(alpha: 0.3), // 차분한 보라색 (Nostalgia)
        ];
      case '자연':
      case '평화':
        return [
          const Color(0xFFB8E6B8).withValues(alpha: 0.4), // 연한 녹색 (Nature)
          const Color(0xFFA8CCCC).withValues(alpha: 0.3), // 청록색/민트색 (Focus)
        ];
      case '따뜻함':
      case '온화':
        return [
          const Color(
            0xFFF2D7A7,
          ).withValues(alpha: 0.4), // 옅은 주황색/복숭아색 (Warmth)
          const Color(0xFFFFE5B4).withValues(alpha: 0.3), // 밝은 노란색 (Joy)
        ];
      case '중립':
      default:
        return [
          const Color(0xFFC8D8C8).withValues(alpha: 0.4), // 연한 녹색-회색 (Neutral)
          const Color(0xFFB8E6F0).withValues(alpha: 0.3), // 밝은 하늘색 (Calm)
        ];
    }
  }

  /// 감정 변화에 따른 그라데이션 색상 반환 (애니메이션용)
  List<Color> get animatedGradientColors {
    final baseColors = watercolorBackgroundColors;
    final intensity = confidence;

    // 감정 강도에 따라 색상 조정
    return baseColors.map<Color>((Color color) {
      return Color.fromRGBO(
        ((color.r * 255.0) * (0.8 + intensity * 0.2)).round(),
        ((color.g * 255.0) * (0.8 + intensity * 0.2)).round(),
        ((color.b * 255.0) * (0.8 + intensity * 0.2)).round(),
        color.a * (0.6 + intensity * 0.4), // 투명도도 감정 강도에 따라 조정
      );
    }).toList();
  }
}

/// 감정 분석 서비스
class EmotionAnalysisService {
  static const Map<String, List<String>> _emotionKeywords = {
    '행복': [
      '행복', '기쁨', '즐거움', '만족', '감사', '뿌듯', '신남', '좋아', '좋다', '웃음', '미소',
      '기쁘다', '즐겁다', '만족스럽다', '감사하다', '뿌듯하다', '신나다', '좋아하다',
      '기뻤다', '즐거웠다', '만족스러웠다', '감사했다', '뿌듯했다', '신났다', '좋아했다',
      '기뻐했다', '즐거워했다', '만족했다', '감사했다', '뿌듯했다', '신났다', '좋았다',
      '기뻐', '즐거워', '만족해', '감사해', '뿌듯해', '신나', '좋아',
      // English keywords
      'happy',
      'joy',
      'glad',
      'pleased',
      'satisfied',
      'grateful',
      'proud',
      'excited',
      'good',
      'great',
      'wonderful',
      'amazing',
      'fantastic',
      'smile',
      'laugh',
      'cheerful',
      'delighted',
      'thrilled',
      'elated',
      'blissful',
      'content',
      'optimistic',
      'positive',
    ],
    '슬픔': [
      '슬픔', '우울', '외로움', '눈물', '울음', '아픔', '괴로움',
      '슬프다', '우울하다', '외롭다', '아프다', '괴롭다', '눈물나다', '울다',
      // English keywords
      'sad',
      'sorrow',
      'grief',
      'melancholy',
      'depressed',
      'lonely',
      'tears',
      'cry',
      'hurt',
      'pain',
      'anguish',
      'miserable',
      'unhappy',
      'gloomy',
      'blue',
      'down',
      'heartbroken',
      'devastated',
      'despair',
      'hopeless',
      'weep',
      'sob',
      'mourn',
    ],
    '화남': [
      '화남', '분노', '짜증', '열받음',
      '화나다', '분노하다', '짜증나다', '열받다', '빡쳐', '빡치다', '화가나다', '성나다',
      // English keywords
      'angry',
      'mad',
      'furious',
      'rage',
      'irritated',
      'annoyed',
      'frustrated',
      'upset',
      'fuming',
      'livid',
      'outraged',
      'indignant',
      'resentful',
      'hostile',
      'aggressive',
      'enraged',
      'incensed',
      'wrathful',
      'irate',
      'cross',
      'vexed',
      'exasperated',
    ],
    '평온': [
      '평온', '편안', '안정', '차분', '고요',
      '평온하다', '편안하다', '안정적이다', '차분하다', '고요하다', '평화롭다', '여유롭다',
      // English keywords
      'calm',
      'peaceful',
      'serene',
      'tranquil',
      'relaxed',
      'comfortable',
      'stable',
      'quiet',
      'still',
      'gentle',
      'mild',
      'soft',
      'soothing',
      'restful',
      'placid',
      'composed',
      'collected',
      'balanced',
      'centered',
      'zen',
      'meditative',
      'chill',
    ],
    '설렘': [
      '설렘', '흥분', '기대', '두근거림',
      '설레다', '흥분하다', '기대하다', '두근거리다', '떨리다', '신나다', '기대된다',
      // English keywords
      'excited',
      'thrilled',
      'eager',
      'anticipating',
      'nervous',
      'anxious',
      'pumped',
      'enthusiastic',
      'elated',
      'ecstatic',
      'overjoyed',
      'delighted',
      'exhilarated',
      'buzzing', 'wired', 'amped', 'psyched', 'stoked', 'fired up', 'ready',
    ],
    '걱정': [
      '걱정', '불안', '긴장', '초조',
      '걱정하다', '불안하다', '긴장하다', '초조하다', '조마조마하다', '불안정하다', '걱정스럽다',
      // English keywords
      'worried',
      'anxious',
      'nervous',
      'concerned',
      'uneasy',
      'troubled',
      'distressed',
      'apprehensive',
      'fearful',
      'tense',
      'stressed',
      'agitated',
      'restless',
      'jittery',
      'fretful',
      'edgy',
      'on edge',
      'uptight',
      'panicky',
      'fidgety',
      'unsettled',
    ],
    '피곤': [
      '피곤', '지침', '힘듦', '피곤하다', '지치다', '힘들다', '피로하다', '지쳐있다', '힘들어하다',
      // English keywords
      'tired', 'exhausted', 'fatigued', 'weary', 'drained', 'worn out', 'spent',
      'lethargic', 'sluggish', 'drowsy', 'sleepy', 'beat', 'bushed', 'pooped',
      'knackered',
      'zonked',
      'dead tired',
      'wiped out',
      'run down',
      'burned out',
    ],
    '실망': [
      '실망', '후회', '아쉬움', '실망하다', '후회하다', '아쉽다', '실망스럽다', '후회스럽다', '아쉽다',
      // English keywords
      'disappointed',
      'disappointed',
      'regret',
      'disappointed',
      'let down',
      'disheartened',
      'discouraged',
      'dejected',
      'crestfallen',
      'downcast',
      'disillusioned',
      'frustrated',
      'displeased',
      'dissatisfied',
      'unhappy',
      'sad',
      'blue',
      'gloomy',
      'melancholy',
    ],
  };

  /// 텍스트에서 감정을 분석합니다
  static EmotionAnalysisResult analyzeEmotion(String text) {
    if (text.isEmpty) {
      return const EmotionAnalysisResult(
        primaryEmotion: '중립',
        confidence: 0.0,
        detectedEmotions: [],
        emotionScores: {},
      );
    }

    final words = _extractWords(text);
    final emotionScores = <String, double>{};
    final detectedEmotions = <String>[];

    // 텍스트를 문장별로 분할 (마지막 감정에 가중치를 주기 위해)
    final sentences = text
        .split(RegExp(r'[.!?]\s*'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    // 각 감정별로 키워드 매칭 점수 계산
    for (final emotion in _emotionKeywords.keys) {
      double score = 0.0;
      final keywords = _emotionKeywords[emotion]!;

      // 전체 텍스트에서 기본 점수 계산
      for (final word in words) {
        for (final keyword in keywords) {
          // 정확한 매칭 (더 높은 점수)
          if (word.toLowerCase() == keyword.toLowerCase()) {
            score += 2.0;
          }
          // 부분 매칭 (낮은 점수)
          else if (word.toLowerCase().contains(keyword.toLowerCase()) ||
              keyword.toLowerCase().contains(word.toLowerCase())) {
            score += 1.0;
          }
        }
      }

      // 문장별로 가중치 적용 (마지막 문장에 더 높은 가중치)
      for (int i = 0; i < sentences.length; i++) {
        final sentence = sentences[i].toLowerCase();
        final weight = i == sentences.length - 1
            ? 3.0 // 마지막 문장에 3배 가중치 (감정의 최종 상태 반영)
            : 1.0;

        for (final keyword in keywords) {
          if (sentence.contains(keyword.toLowerCase())) {
            score += 1.5 * weight; // 문장 내 키워드 매칭에 가중치 적용
          }
        }
      }

      // 부정적 감정 키워드에 대한 추가 가중치 (복합 감정 고려)
      if (emotion == '슬픔' || emotion == '화남' || emotion == '실망') {
        // 부정적 감정이 더 강하게 반영되도록 가중치 적용
        score *= 1.3;
      }

      // 반복된 감정 단어에 대한 보너스 점수
      final emotionWordCount = words
          .where(
            (word) =>
                keywords.any((keyword) => word.contains(keyword.toLowerCase())),
          )
          .length;

      if (emotionWordCount > 1) {
        score += emotionWordCount * 0.7; // 반복된 감정 단어에 보너스 증가
      }

      if (score > 0) {
        emotionScores[emotion] = score;
        detectedEmotions.add(emotion);
      }
    }

    // 가장 높은 점수의 감정을 주요 감정으로 선택
    String primaryEmotion = '중립';
    double confidence = 0.0;

    if (emotionScores.isNotEmpty) {
      final sortedEmotions = emotionScores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      primaryEmotion = sortedEmotions.first.key;
      final maxScore = sortedEmotions.first.value;
      final totalScore = emotionScores.values.fold(
        0.0,
        (sum, score) => sum + score,
      );

      // 신뢰도 계산 (최고 점수 / 전체 점수) - 복합 감정 고려
      confidence = totalScore > 0
          ? (maxScore / totalScore) *
                1.5 // 신뢰도 증가
          : 0.0;

      // 복합 감정 고려: 상위 2개 감정의 점수가 비슷하면 복합 감정으로 판단
      if (sortedEmotions.length >= 2) {
        final secondScore = sortedEmotions[1].value;
        final scoreRatio = secondScore / maxScore;

        // 두 번째 감정이 첫 번째 감정의 70% 이상이면 복합 감정
        if (scoreRatio >= 0.7) {
          // 부정적 감정이 포함된 경우 더 높은 신뢰도 부여
          if (sortedEmotions[0].key == '슬픔' ||
              sortedEmotions[0].key == '화남' ||
              sortedEmotions[0].key == '실망' ||
              sortedEmotions[1].key == '슬픔' ||
              sortedEmotions[1].key == '화남' ||
              sortedEmotions[1].key == '실망') {
            confidence *= 1.2; // 복합 부정 감정에 더 높은 신뢰도
          }
        }
      }

      // 최소 신뢰도 설정 (더 낮은 임계값으로 민감하게 반응)
      if (confidence < 0.15) {
        primaryEmotion = '중립';
        confidence = 0.0;
      }
    }

    Logger.info(
      '감정 분석 결과: $primaryEmotion (신뢰도: ${(confidence * 100).toStringAsFixed(1)}%) - 문장 수: ${sentences.length}',
      tag: 'EmotionAnalysisService',
    );

    return EmotionAnalysisResult(
      primaryEmotion: primaryEmotion,
      confidence: confidence,
      detectedEmotions: detectedEmotions,
      emotionScores: emotionScores,
    );
  }

  /// 텍스트에서 단어를 추출합니다
  static List<String> _extractWords(String text) {
    // 한글, 영문, 숫자만 추출하고 소문자로 변환
    final words = text
        .replaceAll(RegExp(r'[^\w\s가-힣]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word.toLowerCase())
        .toList();

    return words;
  }

  /// 감정 변화를 분석합니다 (텍스트를 문장별로 나누어 분석)
  static List<EmotionAnalysisResult> analyzeEmotionProgression(String text) {
    if (text.isEmpty) {
      return [];
    }

    // 문장별로 나누기 (간단한 구분자 사용)
    final sentences = text
        .split(RegExp(r'[.!?]\s*'))
        .where((sentence) => sentence.trim().isNotEmpty)
        .toList();

    final results = <EmotionAnalysisResult>[];

    for (final sentence in sentences) {
      final result = analyzeEmotion(sentence.trim());
      results.add(result);
    }

    return results;
  }

  /// 감정 변화에 따른 그라데이션 색상 생성
  static List<Color> generateEmotionGradient(
    List<EmotionAnalysisResult> progression,
  ) {
    if (progression.isEmpty) {
      return [const Color(0xFF9E9E9E), const Color(0xFFE0E0E0)];
    }

    if (progression.length == 1) {
      return progression.first.gradientColors;
    }

    // 시작과 끝 감정의 색상으로 그라데이션 생성
    final startEmotion = progression.first;
    final endEmotion = progression.last;

    return [startEmotion.emotionColor, endEmotion.emotionColor];
  }

  /// 감지된 키워드 추출 메서드
  static List<String> getDetectedKeywords(String text, String primaryEmotion) {
    final keywords = _emotionKeywords[primaryEmotion] ?? [];
    final words = _extractWords(text);
    final detectedKeywords = <String>[];

    for (final word in words) {
      for (final keyword in keywords) {
        if (word.toLowerCase().contains(keyword.toLowerCase()) ||
            keyword.toLowerCase().contains(word.toLowerCase())) {
          if (!detectedKeywords.contains(keyword)) {
            detectedKeywords.add(keyword);
          }
        }
      }
    }

    // 최대 3개까지만 반환
    return detectedKeywords.take(3).toList();
  }
}
