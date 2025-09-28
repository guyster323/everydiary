import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:everydiary/core/config/api_keys.dart';
import 'package:everydiary/core/constants/app_constants.dart';
import 'package:everydiary/core/services/text_analysis_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
  final String? localImagePath;

  ImageGenerationResult({
    required this.imageUrl,
    required this.prompt,
    required this.style,
    required this.topic,
    required this.emotion,
    required this.generatedAt,
    Map<String, dynamic>? metadata,
    this.localImagePath,
  }) : metadata = Map<String, dynamic>.unmodifiable(
         metadata ?? <String, dynamic>{},
       );

  Map<String, dynamic> toJson() {
    final data = {
      'image_url': imageUrl,
      'prompt': prompt,
      'style': style,
      'topic': topic,
      'emotion': emotion,
      'generated_at': generatedAt.toIso8601String(),
      'metadata': metadata,
    };
    if (localImagePath != null) {
      data['local_image_path'] = localImagePath!;
    }
    return data;
  }

  factory ImageGenerationResult.fromJson(Map<String, dynamic> json) {
    final Object? metadataJson = json['metadata'];
    final Map<String, dynamic> metadataMap = switch (metadataJson) {
      final Map<String, dynamic> explicitMap => Map<String, dynamic>.from(
        explicitMap,
      ),
      final Map<dynamic, dynamic> dynamicMap => dynamicMap.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      final String metadataString => _parseMetadataString(metadataString),
      _ => <String, dynamic>{},
    };
    return ImageGenerationResult(
      imageUrl: json['image_url'] as String,
      prompt: json['prompt'] as String,
      style: json['style'] as String,
      topic: json['topic'] as String,
      emotion: json['emotion'] as String,
      generatedAt: DateTime.parse(json['generated_at'] as String),
      metadata: metadataMap,
      localImagePath: json['local_image_path'] as String?,
    );
  }
}

Map<String, dynamic> _parseMetadataString(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return Map<String, dynamic>.from(decoded);
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
  } catch (_) {}
  return <String, dynamic>{};
}

/// 이미지 생성 서비스
/// 텍스트 분석 결과를 바탕으로 최적화된 프롬프트를 구성하고 이미지를 생성합니다.
class ImageGenerationService {
  static final ImageGenerationService _instance =
      ImageGenerationService._internal();
  factory ImageGenerationService() => _instance;
  ImageGenerationService._internal();

  static const String _cacheVersion = 'v2';

  static const int _dailyGenerationLimit = 50;

  bool _isInitialized = false;
  final Map<String, ImageGenerationResult> _cache = {};
  final List<Map<String, dynamic>> _generationHistory = [];

  // 의존성 서비스들
  late TextAnalysisService _textAnalysisService;

  Future<bool> get canGenerateTodayAsync => _canGenerateToday();

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 이미지 생성 서비스 초기화 시작');

      // 의존성 서비스 초기화
      _textAnalysisService = TextAnalysisService();
      await _textAnalysisService.initialize();

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

  Future<bool> _canGenerateToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = _todayUsageKey;
      final currentUsage = prefs.getInt(todayKey) ?? 0;
      return currentUsage < _dailyGenerationLimit;
    } catch (e) {
      debugPrint('❌ 사용량 확인 실패: $e');
      return true;
    }
  }

  Future<void> _recordGenerationUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = _todayUsageKey;
      final currentUsage = prefs.getInt(todayKey) ?? 0;
      await prefs.setInt(todayKey, currentUsage + 1);

      final keys = prefs
          .getKeys()
          .where((key) => key.startsWith('image_generation_usage_'))
          .toList();
      for (final key in keys) {
        if (key != todayKey) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('❌ 사용량 기록 실패: $e');
    }
  }

  String get _todayUsageKey {
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month}-${now.day}';
    return 'image_generation_usage_$dateKey';
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

    if (!await _canGenerateToday()) {
      debugPrint(
        '⚠️ 이미지 생성 일일 제한($_dailyGenerationLimit건)을 초과했습니다. 24시간 후 다시 시도해주세요.',
      );
      return null;
    }

    try {
      debugPrint('🎨 텍스트에서 이미지 생성 시작');

      final analysisResult = await _textAnalysisService.analyzeText(text);
      if (analysisResult == null) {
        debugPrint('❌ 텍스트 분석 실패');
        return null;
      }

      final cacheKey = _generateCacheKey(
        '$text|${analysisResult.topic}|${analysisResult.mood}',
      );
      if (_cache.containsKey(cacheKey)) {
        debugPrint('📋 캐시된 이미지 생성 결과 사용');
        return _cache[cacheKey];
      }

      final prompt = await _generateOptimizedPrompt(analysisResult, text);
      if (prompt == null) {
        debugPrint('❌ 프롬프트 생성 실패');
        return null;
      }

      final generationResult = await _generateImageWithFallback(prompt);
      if (generationResult == null) {
        debugPrint('❌ 이미지 생성 실패 (Gemini/Hugging Face 둘 다 실패)');
        return null;
      }

      final dynamic base64PayloadDynamic = generationResult['image_base64'];
      final String? base64Payload = base64PayloadDynamic is String
          ? base64PayloadDynamic
          : null;
      if (base64Payload == null || base64Payload.isEmpty) {
        debugPrint('❌ 이미지 생성 결과에 Base64 데이터가 없습니다.');
        return null;
      }

      final savedImagePath = await _saveBase64Image(base64Payload);
      final generationMetadata = <String, dynamic>{
        'analysis_result': analysisResult.toJson(),
        'original_text': text,
        'generation_service': generationResult['service'],
        'generation_time': DateTime.now().toIso8601String(),
      };
      final result = ImageGenerationResult(
        imageUrl: savedImagePath ?? generationResult['image_url'] as String,
        prompt: prompt,
        style: analysisResult.mood,
        topic: analysisResult.topic,
        emotion: analysisResult.emotion,
        generatedAt: DateTime.now(),
        metadata: generationMetadata,
        localImagePath: savedImagePath,
      );

      _cache[cacheKey] = result;
      await _saveCache();
      await _recordGenerationUsage();

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

  Future<Map<String, String>?> _generateImageWithFallback(String prompt) async {
    final geminiResult = await _generateImageWithGemini(prompt);
    if (geminiResult != null) {
      return {
        'service': 'Gemini',
        'image_base64': geminiResult,
        'image_url': 'gemini-inline-data',
      };
    }

    debugPrint('ℹ️ Gemini 이미지 생성에 실패하여 Hugging Face로 폴백합니다.');

    final huggingFaceResult = await _generateImageWithHuggingFace(prompt);
    if (huggingFaceResult != null) {
      return {
        'service': 'HuggingFace',
        'image_base64': huggingFaceResult,
        'image_url': 'huggingface-generated',
      };
    }

    return null;
  }

  Future<String?> _generateImageWithGemini(String prompt) async {
    final apiKey = ApiKeys.geminiApiKey;
    debugPrint(
      '🔑 Gemini API 키 상태: ${apiKey.isNotEmpty ? "설정됨 (${apiKey.substring(0, 10)}...)" : "설정되지 않음"}',
    );

    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      debugPrint('⚠️ Gemini API 키가 설정되지 않았습니다.');
      return null;
    }

    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-preview-image-generation:generateContent?key=${ApiKeys.geminiApiKey}',
      );

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': '이미지를 생성해주세요: $prompt'},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
            'responseModalities': ['TEXT', 'IMAGE'],
          },
          'safetySettings': [
            {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_NONE'},
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_NONE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_NONE',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_NONE',
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final firstCandidate = candidates.first as Map<String, dynamic>;
          final content = firstCandidate['content'] as Map<String, dynamic>?;
          if (content != null) {
            final parts = content['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              for (final part in parts) {
                final partMap = part as Map<String, dynamic>;
                final inlineData =
                    partMap['inlineData'] as Map<String, dynamic>?;
                if (inlineData != null) {
                  final data = inlineData['data'] as String?;
                  if (data != null && data.isNotEmpty) {
                    debugPrint('✅ Gemini 이미지 생성 성공');
                    return data;
                  }
                }

                final text = partMap['text'] as String?;
                if (text != null && text.isNotEmpty) {
                  debugPrint('ℹ️ Gemini가 텍스트 설명만 반환했습니다: $text');
                }
              }
            }
          }
        }
        debugPrint('❌ Gemini 응답에 이미지 데이터가 없습니다: ${response.body}');
        return null;
      }

      debugPrint('❌ Gemini 이미지 생성 실패: ${response.statusCode} ${response.body}');
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Gemini 이미지 생성 중 예외 발생: $e\n$stackTrace');
      return null;
    }
  }

  Future<String?> _generateImageWithHuggingFace(String prompt) async {
    final apiKey = ApiKeys.huggingFaceApiKey;
    debugPrint(
      '🔑 Hugging Face API 키 상태: ${apiKey.isNotEmpty ? "설정됨 (${apiKey.substring(0, 10)}...)" : "설정되지 않음"}',
    );

    if (apiKey.isEmpty || apiKey == 'YOUR_HUGGING_FACE_API_KEY_HERE') {
      debugPrint('⚠️ Hugging Face API 키가 설정되지 않았습니다.');
      return null;
    }

    // 엔드포인트 검증
    const endpoint = AppConstants.huggingFaceEndpoint;
    if (!endpoint.startsWith('https://api-inference.huggingface.co')) {
      debugPrint('❌ 잘못된 Hugging Face 엔드포인트: $endpoint');
      return null;
    }

    // 재시도 로직 (최대 3회)
    for (int attempt = 1; attempt <= AppConstants.maxRetryAttempts; attempt++) {
      try {
        debugPrint(
          '🎨 Hugging Face 이미지 생성 시도 $attempt/${AppConstants.maxRetryAttempts}: $prompt',
        );

        final uri = Uri.parse(endpoint);
        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${ApiKeys.huggingFaceApiKey}',
          },
          body: jsonEncode({
            'inputs': prompt,
            'parameters': {
              'negative_prompt':
                  'blurry, low quality, distorted, disfigured, text, watermark',
              'num_inference_steps': 25,
              'guidance_scale': 7.5,
            },
          }),
        );

        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          if (bytes.isNotEmpty) {
            debugPrint('✅ Hugging Face 이미지 생성 성공');
            return base64Encode(bytes);
          }
          debugPrint('❌ Hugging Face 응답에 이미지 데이터가 없습니다.');
          return null;
        } else if (response.statusCode == 401) {
          debugPrint('❌ Hugging Face 인증 실패: API 키를 확인해주세요');
          return null;
        } else if (response.statusCode == 429) {
          // Rate limit - 지수 백오프로 재시도
          final waitTime = Duration(seconds: attempt * 2);
          debugPrint('⏳ Rate limit 도달, ${waitTime.inSeconds}초 후 재시도...');
          await Future<void>.delayed(waitTime);
          continue;
        } else if (response.statusCode == 500) {
          // 서버 오류 - 재시도
          final waitTime = Duration(seconds: attempt);
          debugPrint('⏳ 서버 오류, ${waitTime.inSeconds}초 후 재시도...');
          await Future<void>.delayed(waitTime);
          continue;
        }

        debugPrint(
          '❌ Hugging Face 이미지 생성 실패: ${response.statusCode} ${response.body}',
        );
        return null;
      } catch (e) {
        debugPrint(
          '❌ Hugging Face 이미지 생성 중 예외 발생 (시도 $attempt/${AppConstants.maxRetryAttempts}): $e',
        );
        if (attempt == AppConstants.maxRetryAttempts) {
          return null;
        }
        // 네트워크 오류 시 재시도
        await Future<void>.delayed(Duration(seconds: attempt));
      }
    }

    return null;
  }

  Future<String?> _saveBase64Image(String base64Data) async {
    try {
      final normalized = base64.normalize(
        base64Data.replaceAll(RegExp(r'\s+'), ''),
      );
      final bytes = base64Decode(normalized);
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(p.join(directory.path, 'generated_images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
        debugPrint('📁 생성된 이미지 디렉토리 생성: ${imagesDir.path}');
      }

      final fileName =
          'diary_generated_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(p.join(imagesDir.path, fileName));
      await file.writeAsBytes(bytes, flush: true);

      debugPrint('✅ 생성된 이미지 저장: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('❌ 이미지 저장 실패: $e');
      return null;
    }
  }

  Future<String?> _generateOptimizedPrompt(
    TextAnalysisResult analysis,
    String originalText,
  ) async {
    try {
      final summarySentence = _buildOneSentenceSummary(analysis, originalText);
      final moodDescription = _getMoodDescription(analysis.mood);
      final topicDescription = _getTopicDescription(analysis.topic);
      final keywords = analysis.keywords.take(3).join(', ');

      final buffer = StringBuffer()
        ..write('$summarySentence ')
        ..write('$moodDescription 분위기의 수채화 일러스트로 표현해 주세요.');

      if (topicDescription.isNotEmpty) {
        buffer.write(' 장면의 초점은 $topicDescription 입니다.');
      }

      if (keywords.isNotEmpty) {
        buffer.write(' 참고 키워드: $keywords.');
      }

      return buffer.toString();
    } catch (e) {
      debugPrint('❌ 프롬프트 생성 실패: $e');
      return null;
    }
  }

  String _getMoodDescription(String mood) {
    switch (mood) {
      case '사랑':
        return '따뜻하고 로맨틱한';
      case '성취감':
        return '성취감이 느껴지는';
      case '유쾌함':
        return '유쾌하고 밝은';
      case '기쁨':
        return '기쁨이 가득한';
      case '슬픔':
        return '잔잔한 슬픔이 감도는';
      case '분노':
        return '강렬하고 극적인';
      case '걱정':
        return '걱정이 묻어나는';
      case '우울':
        return '차분하고 사색적인';
      case '평온':
        return '평온하고 편안한';
      default:
        return '잔잔하고 성찰적인';
    }
  }

  String _getTopicDescription(String topic) {
    switch (topic) {
      case '여행':
        return '여행지 풍경';
      case '음식':
        return '맛있는 음식 장면';
      case '운동':
        return '활기찬 운동 모습';
      case '감정':
        return '감정을 표현한 인물';
      case '일상':
        return '아늑한 일상 풍경';
      default:
        return '일기 속 장면';
    }
  }

  String _buildOneSentenceSummary(
    TextAnalysisResult analysis,
    String originalText,
  ) {
    final summaryCandidate = analysis.summary.trim();
    if (summaryCandidate.isNotEmpty) {
      return _ensureSentence(summaryCandidate);
    }

    final normalized = originalText.replaceAll('\n', ' ').trim();
    if (normalized.isEmpty) {
      return '오늘의 감정을 담은 순간입니다.';
    }

    final sentenceRegex = RegExp(r'.*?(다\.|요\.|\. |\.|!|\?)');
    final match = sentenceRegex.firstMatch(normalized);
    final candidate = match != null ? match.group(0)!.trim() : normalized;
    return _ensureSentence(candidate);
  }

  String _ensureSentence(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return '오늘의 감정을 담은 순간입니다.';
    }

    if (trimmed.endsWith('.') ||
        trimmed.endsWith('!') ||
        trimmed.endsWith('?') ||
        trimmed.endsWith('다') ||
        trimmed.endsWith('다.') ||
        trimmed.endsWith('요') ||
        trimmed.endsWith('요.')) {
      return trimmed;
    }

    return '$trimmed.';
  }

  /// 캐시 키 생성
  String _generateCacheKey(String text) {
    return '$_cacheVersion-${text.hashCode}';
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

      // 사용량 키 초기화 (하루 단위로 재설정)
      final todayKey = _todayUsageKey;
      final keys = prefs
          .getKeys()
          .where((key) => key.startsWith('image_generation_usage_'))
          .toList();
      for (final key in keys) {
        if (key != todayKey) {
          await prefs.remove(key);
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
