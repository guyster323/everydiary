import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 텍스트 분석 결과 모델
class TextAnalysisResult {
  final String emotion;
  final double emotionScore;
  final List<String> keywords;
  final String topic;
  final String mood;
  final String summary;
  final DateTime analyzedAt;

  const TextAnalysisResult({
    required this.emotion,
    required this.emotionScore,
    required this.keywords,
    required this.topic,
    required this.mood,
    required this.summary,
    required this.analyzedAt,
  });

  Map<String, dynamic> toJson() => {
    'emotion': emotion,
    'emotion_score': emotionScore,
    'keywords': keywords,
    'topic': topic,
    'mood': mood,
    'summary': summary,
    'analyzed_at': analyzedAt.toIso8601String(),
  };

  factory TextAnalysisResult.fromJson(Map<String, dynamic> json) {
    return TextAnalysisResult(
      emotion: json['emotion'] as String,
      emotionScore: (json['emotion_score'] as num).toDouble(),
      keywords: List<String>.from(json['keywords'] as List),
      topic: json['topic'] as String,
      mood: json['mood'] as String,
      summary: json['summary'] as String,
      analyzedAt: DateTime.parse(json['analyzed_at'] as String),
    );
  }
}

/// 텍스트 분석 서비스
/// 일기 내용에서 감정, 키워드, 주제를 분석하여 이미지 생성에 활용할 데이터를 추출합니다.
class TextAnalysisService {
  static final TextAnalysisService _instance = TextAnalysisService._internal();
  factory TextAnalysisService() => _instance;
  TextAnalysisService._internal();

  static const String _cacheVersion = 'v2';

  bool _isInitialized = false;
  final Map<String, TextAnalysisResult> _cache = {};
  final List<Map<String, dynamic>> _analysisHistory = [];

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 텍스트 분석 서비스 초기화 시작');

      // 캐시된 분석 결과 로드
      await _loadCache();

      // 분석 이력 로드
      await _loadAnalysisHistory();

      _isInitialized = true;
      debugPrint('✅ 텍스트 분석 서비스 초기화 완료');
    } catch (e) {
      debugPrint('❌ 텍스트 분석 서비스 초기화 실패: $e');
    }
  }

  /// 텍스트 분석 (기본 알고리즘)
  Future<TextAnalysisResult?> analyzeText(String text) async {
    if (!_isInitialized) {
      debugPrint('❌ 텍스트 분석 서비스가 초기화되지 않았습니다.');
      return null;
    }

    if (text.trim().isEmpty) {
      debugPrint('❌ 분석할 텍스트가 비어있습니다.');
      return null;
    }

    try {
      debugPrint('📝 텍스트 분석 시작');

      // 캐시 확인
      final cacheKey = _generateCacheKey(text);
      if (_cache.containsKey(cacheKey)) {
        debugPrint('📋 캐시된 분석 결과 사용');
        return _cache[cacheKey];
      }

      // 기본 텍스트 분석 알고리즘
      final result = await _performBasicAnalysis(text);

      if (result != null) {
        // 캐시에 저장
        _cache[cacheKey] = result;
        await _saveCache();

        // 분석 이력에 추가
        _analysisHistory.add({
          'text': text,
          'result': result.toJson(),
          'timestamp': DateTime.now().toIso8601String(),
        });
        await _saveAnalysisHistory();

        debugPrint('✅ 텍스트 분석 완료');
      }

      return result;
    } catch (e) {
      debugPrint('❌ 텍스트 분석 실패: $e');
      return null;
    }
  }

  /// 기본 텍스트 분석 알고리즘
  Future<TextAnalysisResult?> _performBasicAnalysis(String text) async {
    try {
      // 감정 분석 (간단한 키워드 기반)
      final emotionData = _analyzeEmotion(text);

      // 키워드 추출
      final keywords = _extractKeywords(text);

      // 주제 분류
      final topic = _classifyTopic(text, keywords);

      // 기분 분석
      final mood = _analyzeMood(
        text,
        emotionData['emotion'] as String,
        dominantSignal: emotionData['dominant'] as String?,
      );

      // 요약 생성
      final summary = _generateSummary(text);

      return TextAnalysisResult(
        emotion: emotionData['emotion'] as String,
        emotionScore: emotionData['score'] as double,
        keywords: keywords,
        topic: topic,
        mood: mood,
        summary: summary,
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ 기본 텍스트 분석 실패: $e');
      return null;
    }
  }

  /// 감정 분석 (키워드 기반)
  Map<String, dynamic> _analyzeEmotion(String text) {
    final lowerText = text.toLowerCase();

    const positiveWeights = <String, double>{
      '행복': 1.4,
      '행복하': 1.4,
      '행복한': 1.4,
      '좋았': 1.1,
      '좋다': 1.0,
      '기쁘': 1.2,
      '즐거': 1.2,
      '사랑': 1.1,
      '감사': 1.1,
      '만족': 1.0,
      '편안': 0.9,
      '평온': 0.9,
      '안심': 1.1,
      '미소': 1.0,
      '웃음': 1.0,
    };

    const negativeWeights = <String, double>{
      '걱정': 2.2,
      '걱정이': 2.2,
      '걱정되': 2.2,
      '불안': 2.3,
      '슬프': 1.6,
      '우울': 1.6,
      '힘들': 1.2,
      '짜증': 1.1,
      '화나': 1.2,
      '실망': 1.1,
      '두려': 1.8,
      '긴장': 1.5,
      '스트레스': 1.5,
      '외롭': 1.5,
      '괴롭': 1.6,
    };

    const neutralWeights = <String, double>{
      '일상': 0.6,
      '평범': 0.6,
      '보통': 0.6,
      '그냥': 0.6,
      '그저': 0.6,
      '단순': 0.6,
      '일반': 0.6,
      '평소': 0.6,
    };

    double scoreFor(Map<String, double> weights) {
      double score = 0;
      for (final entry in weights.entries) {
        if (lowerText.contains(entry.key)) {
          score += entry.value;
        }
      }
      return score;
    }

    final positiveScore = scoreFor(positiveWeights);
    final negativeScore = scoreFor(negativeWeights);
    final neutralScore = scoreFor(neutralWeights);

    final totalScore = positiveScore + negativeScore + neutralScore;

    String? dominantNegative;
    if (lowerText.contains('걱정') || lowerText.contains('불안')) {
      dominantNegative = '걱정';
    } else if (lowerText.contains('슬프') || lowerText.contains('슬픔')) {
      dominantNegative = '슬픔';
    } else if (lowerText.contains('우울')) {
      dominantNegative = '우울';
    } else if (lowerText.contains('화나') || lowerText.contains('분노')) {
      dominantNegative = '분노';
    } else if (lowerText.contains('외롭') || lowerText.contains('허전')) {
      dominantNegative = '외로움';
    }

    String? dominantPositive;
    if (lowerText.contains('행복')) {
      dominantPositive = '행복';
    } else if (lowerText.contains('기쁘') || lowerText.contains('기쁜')) {
      dominantPositive = '기쁨';
    } else if (lowerText.contains('사랑')) {
      dominantPositive = '사랑';
    } else if (lowerText.contains('감사') || lowerText.contains('고마')) {
      dominantPositive = '감사';
    } else if (lowerText.contains('만족')) {
      dominantPositive = '만족';
    } else if (lowerText.contains('편안') || lowerText.contains('평온')) {
      dominantPositive = '평온';
    }

    final hasWorry = dominantNegative == '걱정';

    if (totalScore == 0) {
      return {'emotion': '중립', 'score': 0.0, 'dominant': null};
    }

    if (hasWorry && negativeScore > 0) {
      return {
        'emotion': '걱정',
        'score': (negativeScore / totalScore).clamp(0.0, 1.0),
        'dominant': '걱정',
      };
    }

    if (negativeScore > 0 && negativeScore >= positiveScore * 0.8) {
      return {
        'emotion': dominantNegative ?? '우울',
        'score': (negativeScore / totalScore).clamp(0.0, 1.0),
        'dominant': dominantNegative,
      };
    }

    if (positiveScore > 0 && positiveScore >= negativeScore * 1.2) {
      return {
        'emotion': dominantPositive ?? '기쁨',
        'score': (positiveScore / totalScore).clamp(0.0, 1.0),
        'dominant': dominantPositive,
      };
    }

    if (positiveScore > 0 && negativeScore > 0) {
      final dominant = dominantNegative ?? dominantPositive ?? '복합';
      return {
        'emotion': dominant,
        'score': ((positiveScore + negativeScore) / totalScore).clamp(0.0, 1.0),
        'dominant': dominantNegative ?? dominantPositive,
      };
    }

    if (positiveScore > 0) {
      return {
        'emotion': dominantPositive ?? '기쁨',
        'score': (positiveScore / totalScore).clamp(0.0, 1.0),
        'dominant': dominantPositive,
      };
    }

    if (negativeScore > 0) {
      return {
        'emotion': dominantNegative ?? '우울',
        'score': (negativeScore / totalScore).clamp(0.0, 1.0),
        'dominant': dominantNegative,
      };
    }

    return {
      'emotion': '평온',
      'score': (neutralScore / totalScore).clamp(0.0, 1.0),
      'dominant': null,
    };
  }

  /// 키워드 추출
  List<String> _extractKeywords(String text) {
    // 간단한 키워드 추출 (실제로는 더 정교한 NLP 알고리즘 사용)
    final words = text
        .replaceAll(RegExp(r'[^\w\s가-힣]'), ' ') // 특수문자 제거
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 1) // 1글자 단어 제외
        .toList();

    // 빈도수 계산
    final wordCount = <String, int>{};
    for (final word in words) {
      wordCount[word] = (wordCount[word] ?? 0) + 1;
    }

    // 상위 키워드 선택 (최대 5개)
    final sortedWords = wordCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedWords.take(5).map((entry) => entry.key).toList();
  }

  /// 주제 분류
  String _classifyTopic(String text, List<String> keywords) {
    final lowerText = text.toLowerCase();

    // 여행 관련 키워드
    if (lowerText.contains('여행') ||
        lowerText.contains('여행') ||
        lowerText.contains('휴가') ||
        lowerText.contains('휴가') ||
        lowerText.contains('관광') ||
        lowerText.contains('관광') ||
        lowerText.contains('여행지') ||
        lowerText.contains('여행지')) {
      return '여행';
    }

    // 일상 관련 키워드
    if (lowerText.contains('일상') ||
        lowerText.contains('일상') ||
        lowerText.contains('평범') ||
        lowerText.contains('평범') ||
        lowerText.contains('보통') ||
        lowerText.contains('보통')) {
      return '일상';
    }

    // 감정 관련 키워드
    if (lowerText.contains('감정') ||
        lowerText.contains('감정') ||
        lowerText.contains('기분') ||
        lowerText.contains('기분') ||
        lowerText.contains('마음') ||
        lowerText.contains('마음')) {
      return '감정';
    }

    // 음식 관련 키워드
    if (lowerText.contains('음식') ||
        lowerText.contains('음식') ||
        lowerText.contains('먹') ||
        lowerText.contains('먹') ||
        lowerText.contains('식사') ||
        lowerText.contains('식사')) {
      return '음식';
    }

    // 운동 관련 키워드
    if (lowerText.contains('운동') ||
        lowerText.contains('운동') ||
        lowerText.contains('헬스') ||
        lowerText.contains('헬스') ||
        lowerText.contains('달리기') ||
        lowerText.contains('달리기')) {
      return '운동';
    }

    // 기본값
    return '일반';
  }

  /// 기분 분석
  String _analyzeMood(String text, String emotion, {String? dominantSignal}) {
    final lowerText = text.toLowerCase();

    String resolvedEmotion = emotion;
    if (emotion == '복합' && dominantSignal != null) {
      resolvedEmotion = dominantSignal;
    }

    switch (resolvedEmotion) {
      case '걱정':
      case '불안':
        return '걱정';
      case '슬픔':
        return '슬픔';
      case '우울':
      case '외로움':
        return '우울';
      case '분노':
        return '분노';
      case '사랑':
        return '사랑';
      case '감사':
      case '만족':
      case '행복':
      case '기쁨':
        return '기쁨';
      case '평온':
        return '평온';
    }

    if (lowerText.contains('걱정') || lowerText.contains('불안')) {
      return '걱정';
    }
    if (lowerText.contains('슬프')) {
      return '슬픔';
    }
    if (lowerText.contains('우울')) {
      return '우울';
    }
    if (lowerText.contains('행복') || lowerText.contains('기쁘')) {
      return '기쁨';
    }
    return '평온';
  }

  /// 요약 생성
  String _generateSummary(String text) {
    final normalized = text.replaceAll('\n', ' ').trim();
    if (normalized.isEmpty) {
      return '';
    }

    final sentenceRegex = RegExp(r'.*?(다\.|요\.|\. |\.|!|\?)');
    final match = sentenceRegex.firstMatch(normalized);
    if (match != null) {
      final sentence = match.group(0)!.trim();
      return sentence.endsWith('.') ? sentence : sentence;
    }

    if (normalized.length <= 80) {
      return normalized;
    }

    return '${normalized.substring(0, 80)}...';
  }

  /// 캐시 키 생성
  String _generateCacheKey(String text) {
    return '$_cacheVersion-${text.hashCode}';
  }

  /// 캐시 로드
  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString('text_analysis_cache');

      if (cacheJson != null) {
        final cacheData = jsonDecode(cacheJson) as Map<String, dynamic>;
        _cache.clear();

        for (final entry in cacheData.entries) {
          final resultData = entry.value as Map<String, dynamic>;
          _cache[entry.key] = TextAnalysisResult.fromJson(resultData);
        }
      }
    } catch (e) {
      debugPrint('❌ 캐시 로드 실패: $e');
    }
  }

  /// 캐시 저장
  Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = <String, dynamic>{};

      for (final entry in _cache.entries) {
        cacheData[entry.key] = entry.value.toJson();
      }

      await prefs.setString('text_analysis_cache', jsonEncode(cacheData));
    } catch (e) {
      debugPrint('❌ 캐시 저장 실패: $e');
    }
  }

  /// 분석 이력 로드
  Future<void> _loadAnalysisHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('text_analysis_history');

      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List<dynamic>;
        _analysisHistory.clear();
        _analysisHistory.addAll(
          historyList.map((item) => item as Map<String, dynamic>),
        );
      }
    } catch (e) {
      debugPrint('❌ 분석 이력 로드 실패: $e');
    }
  }

  /// 분석 이력 저장
  Future<void> _saveAnalysisHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'text_analysis_history',
        jsonEncode(_analysisHistory),
      );
    } catch (e) {
      debugPrint('❌ 분석 이력 저장 실패: $e');
    }
  }

  /// 캐시된 분석 결과 가져오기
  TextAnalysisResult? getCachedResult(String text) {
    final cacheKey = _generateCacheKey(text);
    return _cache[cacheKey];
  }

  /// 분석 이력 가져오기
  List<Map<String, dynamic>> getAnalysisHistory() {
    return List.from(_analysisHistory);
  }

  /// 캐시 초기화
  Future<void> clearCache() async {
    try {
      _cache.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('text_analysis_cache');
      debugPrint('✅ 텍스트 분석 캐시 초기화 완료');
    } catch (e) {
      debugPrint('❌ 캐시 초기화 실패: $e');
    }
  }

  /// 분석 이력 초기화
  Future<void> clearHistory() async {
    try {
      _analysisHistory.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('text_analysis_history');
      debugPrint('✅ 텍스트 분석 이력 초기화 완료');
    } catch (e) {
      debugPrint('❌ 이력 초기화 실패: $e');
    }
  }

  /// 서비스 정리
  void dispose() {
    _cache.clear();
    _analysisHistory.clear();
    _isInitialized = false;
    debugPrint('🗑️ 텍스트 분석 서비스 정리 완료');
  }
}
