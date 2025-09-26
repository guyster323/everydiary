import 'dart:async';
import 'dart:convert';

import 'package:everydiary/core/services/openai_service.dart';
import 'package:everydiary/core/services/text_analysis_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 이미지 생성 결과 모델
class ImageGenerationResult {
  final String imageUrl;
  final String prompt;
  final String style;
  final String topic;
  final String emotion;
  final DateTime generatedAt;
  final Map<String, dynamic> metadata;

  const ImageGenerationResult({
    required this.imageUrl,
    required this.prompt,
    required this.style,
    required this.topic,
    required this.emotion,
    required this.generatedAt,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'image_url': imageUrl,
    'prompt': prompt,
    'style': style,
    'topic': topic,
    'emotion': emotion,
    'generated_at': generatedAt.toIso8601String(),
    'metadata': metadata,
  };

  factory ImageGenerationResult.fromJson(Map<String, dynamic> json) {
    return ImageGenerationResult(
      imageUrl: json['image_url'] as String,
      prompt: json['prompt'] as String,
      style: json['style'] as String,
      topic: json['topic'] as String,
      emotion: json['emotion'] as String,
      generatedAt: DateTime.parse(json['generated_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }
}

/// 이미지 생성 서비스
/// 텍스트 분석 결과를 바탕으로 최적화된 프롬프트를 구성하고 이미지를 생성합니다.
class ImageGenerationService {
  static final ImageGenerationService _instance =
      ImageGenerationService._internal();
  factory ImageGenerationService() => _instance;
  ImageGenerationService._internal();

  bool _isInitialized = false;
  final Map<String, ImageGenerationResult> _cache = {};
  final List<Map<String, dynamic>> _generationHistory = [];

  // 의존성 서비스들
  late TextAnalysisService _textAnalysisService;
  late OpenAIService _openAIService;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 이미지 생성 서비스 초기화 시작');

      // 의존성 서비스 초기화
      _textAnalysisService = TextAnalysisService();
      _openAIService = OpenAIService();

      await _textAnalysisService.initialize();
      await _openAIService.initialize();

      // 캐시된 생성 결과 로드
      await _loadCache();

      // 생성 이력 로드
      await _loadGenerationHistory();

      _isInitialized = true;
      debugPrint('✅ 이미지 생성 서비스 초기화 완료');
    } catch (e) {
      debugPrint('❌ 이미지 생성 서비스 초기화 실패: $e');
    }
  }

  /// 텍스트에서 이미지 생성
  Future<ImageGenerationResult?> generateImageFromText(String text) async {
    if (!_isInitialized) {
      debugPrint('❌ 이미지 생성 서비스가 초기화되지 않았습니다.');
      return null;
    }

    if (text.trim().isEmpty) {
      debugPrint('❌ 분석할 텍스트가 비어있습니다.');
      return null;
    }

    try {
      debugPrint('🎨 텍스트에서 이미지 생성 시작');

      // 캐시 확인
      final cacheKey = _generateCacheKey(text);
      if (_cache.containsKey(cacheKey)) {
        debugPrint('📋 캐시된 이미지 생성 결과 사용');
        return _cache[cacheKey];
      }

      // 1단계: 텍스트 분석
      final analysisResult = await _textAnalysisService.analyzeText(text);
      if (analysisResult == null) {
        debugPrint('❌ 텍스트 분석 실패');
        return null;
      }

      // 2단계: 프롬프트 생성
      final prompt = await _generateOptimizedPrompt(analysisResult);
      if (prompt == null) {
        debugPrint('❌ 프롬프트 생성 실패');
        return null;
      }

      // 3단계: 이미지 생성
      final imageResult = await _generateImage(prompt, analysisResult);
      if (imageResult == null) {
        debugPrint('❌ 이미지 생성 실패');
        return null;
      }

      // 4단계: 결과 캐싱 및 이력 저장
      final result = ImageGenerationResult(
        imageUrl: imageResult['data'][0]['url'] as String,
        prompt: prompt,
        style: _determineStyle(analysisResult),
        topic: analysisResult.topic,
        emotion: analysisResult.emotion,
        generatedAt: DateTime.now(),
        metadata: {
          'analysis_result': analysisResult.toJson(),
          'original_text': text,
          'generation_time': DateTime.now().toIso8601String(),
        },
      );

      // 캐시에 저장
      _cache[cacheKey] = result;
      await _saveCache();

      // 생성 이력에 추가
      _generationHistory.add({
        'text': text,
        'result': result.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      await _saveGenerationHistory();

      debugPrint('✅ 이미지 생성 완료');
      return result;
    } catch (e) {
      debugPrint('❌ 이미지 생성 실패: $e');
      return null;
    }
  }

  /// 분석 결과에서 최적화된 프롬프트 생성
  Future<String?> _generateOptimizedPrompt(TextAnalysisResult analysis) async {
    try {
      debugPrint('🎯 프롬프트 최적화 시작');

      // 기본 프롬프트 템플릿 생성
      final basePrompt = _createBasePrompt(analysis);

      // OpenAI를 통한 프롬프트 최적화
      final optimizedPrompt = await _openAIService.optimizeImagePrompt(
        originalPrompt: basePrompt,
        emotion: analysis.emotion,
        topic: analysis.topic,
        keywords: analysis.keywords,
        style: _determineStyle(analysis),
      );

      return optimizedPrompt ?? basePrompt;
    } catch (e) {
      debugPrint('❌ 프롬프트 최적화 실패: $e');
      return _createBasePrompt(analysis);
    }
  }

  /// 기본 프롬프트 생성
  String _createBasePrompt(TextAnalysisResult analysis) {
    final style = _determineStyle(analysis);
    final mood = _getMoodDescription(analysis.mood);
    final topic = _getTopicDescription(analysis.topic);
    final keywords = analysis.keywords.take(3).join(', ');

    return 'A $style $topic image with $mood mood, featuring $keywords, high quality, detailed, beautiful composition';
  }

  /// 스타일 결정
  String _determineStyle(TextAnalysisResult analysis) {
    switch (analysis.topic) {
      case '여행':
        return 'photorealistic travel photography';
      case '음식':
        return 'food photography with warm lighting';
      case '운동':
        return 'dynamic sports photography';
      case '감정':
        return 'artistic emotional illustration';
      case '일상':
        return 'lifestyle photography';
      default:
        return 'artistic illustration';
    }
  }

  /// 기분 설명 생성
  String _getMoodDescription(String mood) {
    switch (mood) {
      case '사랑':
        return 'warm and romantic';
      case '성취감':
        return 'triumphant and proud';
      case '유쾌함':
        return 'cheerful and bright';
      case '기쁨':
        return 'joyful and happy';
      case '슬픔':
        return 'melancholic and soft';
      case '분노':
        return 'intense and dramatic';
      case '걱정':
        return 'contemplative and gentle';
      case '우울':
        return 'calm and introspective';
      case '평온':
        return 'peaceful and serene';
      default:
        return 'neutral and balanced';
    }
  }

  /// 주제 설명 생성
  String _getTopicDescription(String topic) {
    switch (topic) {
      case '여행':
        return 'travel destination landscape';
      case '음식':
        return 'delicious food scene';
      case '운동':
        return 'active lifestyle scene';
      case '감정':
        return 'emotional expression scene';
      case '일상':
        return 'daily life moment';
      default:
        return 'general scene';
    }
  }

  /// 이미지 생성 (OpenAI DALL-E)
  Future<Map<String, dynamic>?> _generateImage(
    String prompt,
    TextAnalysisResult analysis,
  ) async {
    try {
      debugPrint('🎨 DALL-E 이미지 생성 시작');

      final result = await _openAIService.generateImage(
        prompt: prompt,
        model: 'dall-e-3',
        size: '1024x1024',
        quality: 'standard',
        style: 'vivid',
        n: 1,
      );

      if (result != null) {
        debugPrint('✅ DALL-E 이미지 생성 완료');
        return result;
      } else {
        debugPrint('❌ DALL-E 이미지 생성 실패');
        return null;
      }
    } catch (e) {
      debugPrint('❌ 이미지 생성 실패: $e');
      return null;
    }
  }

  /// 캐시 키 생성
  String _generateCacheKey(String text) {
    return text.hashCode.toString();
  }

  /// 캐시 로드
  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString('image_generation_cache');

      if (cacheJson != null) {
        final cacheData = jsonDecode(cacheJson) as Map<String, dynamic>;
        _cache.clear();

        for (final entry in cacheData.entries) {
          final resultData = entry.value as Map<String, dynamic>;
          _cache[entry.key] = ImageGenerationResult.fromJson(resultData);
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

      await prefs.setString('image_generation_cache', jsonEncode(cacheData));
    } catch (e) {
      debugPrint('❌ 캐시 저장 실패: $e');
    }
  }

  /// 생성 이력 로드
  Future<void> _loadGenerationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('image_generation_history');

      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List<dynamic>;
        _generationHistory.clear();
        _generationHistory.addAll(
          historyList.map((item) => item as Map<String, dynamic>),
        );
      }
    } catch (e) {
      debugPrint('❌ 생성 이력 로드 실패: $e');
    }
  }

  /// 생성 이력 저장
  Future<void> _saveGenerationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'image_generation_history',
        jsonEncode(_generationHistory),
      );
    } catch (e) {
      debugPrint('❌ 생성 이력 저장 실패: $e');
    }
  }

  /// 캐시된 생성 결과 가져오기
  ImageGenerationResult? getCachedResult(String text) {
    final cacheKey = _generateCacheKey(text);
    return _cache[cacheKey];
  }

  /// 생성 이력 가져오기
  List<Map<String, dynamic>> getGenerationHistory() {
    return List.from(_generationHistory);
  }

  /// 캐시 초기화
  Future<void> clearCache() async {
    try {
      _cache.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('image_generation_cache');
      debugPrint('✅ 이미지 생성 캐시 초기화 완료');
    } catch (e) {
      debugPrint('❌ 캐시 초기화 실패: $e');
    }
  }

  /// 생성 이력 초기화
  Future<void> clearHistory() async {
    try {
      _generationHistory.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('image_generation_history');
      debugPrint('✅ 이미지 생성 이력 초기화 완료');
    } catch (e) {
      debugPrint('❌ 이력 초기화 실패: $e');
    }
  }

  /// 서비스 정리
  void dispose() {
    _cache.clear();
    _generationHistory.clear();
    _isInitialized = false;
    debugPrint('🗑️ 이미지 생성 서비스 정리 완료');
  }
}
