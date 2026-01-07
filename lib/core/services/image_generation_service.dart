import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:everydiary/core/config/api_keys.dart';
import 'package:everydiary/core/constants/app_constants.dart';
import 'package:everydiary/core/services/text_analysis_service.dart';
import 'package:everydiary/core/services/user_customization_service.dart';
import 'package:everydiary/shared/services/ad_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Generation count management constants
const String _generationCountKey = 'remaining_generations';

const List<String> _baseNegativePromptTokens = <String>[
  'blurry',
  'low quality',
  'distorted',
  'disfigured',
  'grainy',
  'text',
  'words',
  'letters',
  'typography',
  'captions',
  'subtitles',
  'logos',
  'watermark',
  'signature',
  'overlay text',
  'poster text',
  'korean text',
  'english text',
];

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
  final String? negativePrompt;

  ImageGenerationResult({
    required this.imageUrl,
    required this.prompt,
    required this.style,
    required this.topic,
    required this.emotion,
    required this.generatedAt,
    Map<String, dynamic>? metadata,
    this.localImagePath,
    this.negativePrompt,
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
    if (negativePrompt != null) {
      data['negative_prompt'] = negativePrompt!;
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
      negativePrompt: json['negative_prompt'] as String?,
    );
  }
}

class ImagePromptPayload {
  const ImagePromptPayload({
    required this.positivePrompt,
    required this.guidelines,
    required this.negativePrompt,
  });

  final String positivePrompt;
  final List<String> guidelines;
  final String negativePrompt;

  String get huggingFacePrompt {
    if (guidelines.isEmpty) {
      return positivePrompt.trim();
    }
    final buffer = StringBuffer(positivePrompt.trim());
    for (final guideline in guidelines) {
      buffer
        ..write(' ')
        ..write(guideline.trim());
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String get geminiPrompt {
    final buffer = StringBuffer()
      ..writeln('일기 전체 맥락을 반영하여 다음 지침을 따른 이미지를 생성하세요.')
      ..writeln(positivePrompt.trim());

    if (guidelines.isNotEmpty) {
      buffer.writeln();
      for (final guideline in guidelines) {
        buffer.writeln('- ${guideline.trim()}');
      }
    }

    if (negativePrompt.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('제외해야 할 요소: ${negativePrompt.trim()}');
    }

    return buffer.toString().trim();
  }

  Map<String, dynamic> toMetadata() => {
    'positive_prompt': positivePrompt,
    if (guidelines.isNotEmpty) 'guidelines': guidelines,
    'negative_prompt': negativePrompt,
  };
}

class ImageGenerationHints {
  const ImageGenerationHints({
    this.title,
    this.mood,
    this.weather,
    this.location,
    this.date,
    this.timeOfDay,
    this.tags = const <String>[],
  });

  final String? title;
  final String? mood;
  final String? weather;
  final String? location;
  final DateTime? date;
  final String? timeOfDay;
  final List<String> tags;

  bool get hasContext {
    return (title != null && title!.trim().isNotEmpty) ||
        (mood != null && mood!.trim().isNotEmpty) ||
        (weather != null && weather!.trim().isNotEmpty) ||
        (location != null && location!.trim().isNotEmpty) ||
        date != null ||
        (timeOfDay != null && timeOfDay!.trim().isNotEmpty) ||
        tags.isNotEmpty;
  }

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (mood != null) 'mood': mood,
    if (weather != null) 'weather': weather,
    if (location != null) 'location': location,
    if (date != null) 'date': date!.toIso8601String(),
    if (timeOfDay != null) 'timeOfDay': timeOfDay,
    if (tags.isNotEmpty) 'tags': tags,
  };

  String signature() {
    final buffer = StringBuffer();
    if (title != null && title!.trim().isNotEmpty) {
      buffer.write(title!.trim());
      buffer.write('|');
    }
    if (mood != null && mood!.trim().isNotEmpty) {
      buffer.write(mood!.trim());
      buffer.write('|');
    }
    if (weather != null && weather!.trim().isNotEmpty) {
      buffer.write(weather!.trim());
      buffer.write('|');
    }
    if (location != null && location!.trim().isNotEmpty) {
      buffer.write(location!.trim());
      buffer.write('|');
    }
    if (date != null) {
      buffer.write(date!.toIso8601String());
      buffer.write('|');
    }
    if (timeOfDay != null && timeOfDay!.trim().isNotEmpty) {
      buffer.write(timeOfDay!.trim());
      buffer.write('|');
    }
    if (tags.isNotEmpty) {
      buffer.write(tags.join(','));
    }
    return buffer.toString();
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

  static const String _cacheVersion = 'v3';

  static const int _dailyGenerationLimit = 50;

  bool _isInitialized = false;
  final Map<String, ImageGenerationResult> _cache = {};
  final List<Map<String, dynamic>> _generationHistory = [];

  // 의존성 서비스들
  late TextAnalysisService _textAnalysisService;
  late UserCustomizationService _userCustomizationService;

  Future<bool> get canGenerateTodayAsync => _canGenerateToday();

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 이미지 생성 서비스 초기화 시작');

      // 의존성 서비스 초기화
      _textAnalysisService = TextAnalysisService();
      await _textAnalysisService.initialize();

      _userCustomizationService = UserCustomizationService();
      await _userCustomizationService.initialize();

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
  Future<ImageGenerationResult?> generateImageFromText(
    String text, {
    ImageGenerationHints? hints,
  }) async {
    if (!_isInitialized) {
      debugPrint('❌ 이미지 생성 서비스가 초기화되지 않았습니다.');
      return null;
    }

    if (text.trim().isEmpty) {
      debugPrint('❌ 분석할 텍스트가 비어있습니다.');
      return null;
    }

    // Check generation count
    final prefs = await SharedPreferences.getInstance();
    var remainingCount = prefs.getInt(_generationCountKey) ?? 3;

    debugPrint('🔵 [ImageGenService] generateImageFromText 호출: remainingCount=$remainingCount');

    // 횟수가 0이면 광고 재생
    if (remainingCount <= 0) {
      debugPrint('🎬 횟수 부족 - 광고 재생 시도');

      try {
        // 광고 로드
        await AdService.instance.loadRewardedAd();

        // 광고 재생
        final adResult = await AdService.instance.showRewardedAd();

        if (adResult) {
          // 광고 시청 완료 - 2회 추가
          debugPrint('✅ 광고 시청 완료 - 2회 추가');
          await prefs.setInt(_generationCountKey, 2);
          remainingCount = 2;
          debugPrint('🔵 [ImageGenService] 광고 보상으로 횟수 추가: 0 → 2');
        } else {
          // 광고 시청 실패 또는 취소
          debugPrint('❌ 광고 시청 실패 또는 취소');
          return null;
        }
      } catch (e) {
        debugPrint('❌ 광고 재생 중 오류 발생: $e');
        return null;
      }
    }

    // 현재 횟수 재확인 (광고로 인해 변경되었을 수 있음)
    final currentCount = prefs.getInt(_generationCountKey) ?? 3;

    // Consume generation count
    final newCount = currentCount - 1;
    await prefs.setInt(_generationCountKey, newCount);
    debugPrint('🔵 [ImageGenService] 횟수 차감: $currentCount → $newCount');

    if (!await _canGenerateToday()) {
      debugPrint(
        '⚠️ 이미지 생성 일일 제한($_dailyGenerationLimit건)을 초과했습니다. 24시간 후 다시 시도해주세요.',
      );
      // Rollback count on daily limit error
      await prefs.setInt(_generationCountKey, currentCount);
      debugPrint('🔵 [ImageGenService] 일일 제한으로 횟수 복구: $newCount → $currentCount');
      return null;
    }

    try {
      debugPrint('🎨 텍스트에서 이미지 생성 시작');

      final analysisResult = await _textAnalysisService.analyzeText(text);
      if (analysisResult == null) {
        debugPrint('❌ 텍스트 분석 실패');
        return null;
      }

      final cacheKey = _generateCacheKey(text, analysisResult, hints);
      if (_cache.containsKey(cacheKey)) {
        debugPrint('📋 캐시된 이미지 생성 결과 사용');
        return _cache[cacheKey];
      }

      final promptPayload = await _buildPromptPayload(
        analysisResult,
        text,
        hints,
      );
      if (promptPayload == null) {
        debugPrint('❌ 프롬프트 생성 실패');
        return null;
      }

      final manualKeywords =
          _userCustomizationService.currentSettings.manualKeywords;
      debugPrint('🎯 Positive Prompt: ${promptPayload.positivePrompt}');
      if (promptPayload.guidelines.isNotEmpty) {
        debugPrint('📐 Guidelines: ${promptPayload.guidelines.join(' / ')}');
      }
      if (manualKeywords.isNotEmpty) {
        debugPrint('🔑 사용자 키워드: ${manualKeywords.join(', ')}');
      }
      if (promptPayload.negativePrompt.trim().isNotEmpty) {
        debugPrint('🚫 Negative Prompt: ${promptPayload.negativePrompt}');
      }

      final generationResult = await _generateImageWithFallback(promptPayload);
      if (generationResult == null) {
        debugPrint('❌ 이미지 생성 실패 (Gemini 2.5 Flash Image 실패)');
        // Rollback count on generation failure
        await prefs.setInt(_generationCountKey, currentCount);
        debugPrint('🔵 [ImageGenService] 생성 실패로 횟수 복구: $newCount → $currentCount');
        return null;
      }

      final dynamic base64PayloadDynamic = generationResult['image_base64'];
      final String? base64Payload = base64PayloadDynamic is String
          ? base64PayloadDynamic
          : null;
      if (base64Payload == null || base64Payload.isEmpty) {
        debugPrint('❌ 이미지 생성 결과에 Base64 데이터가 없습니다.');
        // Rollback count on missing base64 data
        await prefs.setInt(_generationCountKey, currentCount);
        debugPrint('🔵 [ImageGenService] Base64 데이터 없어서 횟수 복구: $newCount → $currentCount');
        return null;
      }

      final savedImagePath = await _saveBase64Image(base64Payload);
      final generationMetadata = <String, dynamic>{
        'analysis_result': analysisResult.toJson(),
        'original_text': text,
        'generation_service': generationResult['service'],
        'generation_time': DateTime.now().toIso8601String(),
        if (hints != null && hints.hasContext) 'context': hints.toJson(),
        'prompt_payload': promptPayload.toMetadata(),
      };
      final result = ImageGenerationResult(
        imageUrl: savedImagePath ?? generationResult['image_url'] as String,
        prompt: promptPayload.huggingFacePrompt,
        style: analysisResult.mood,
        topic: analysisResult.topic,
        emotion: analysisResult.emotion,
        generatedAt: DateTime.now(),
        metadata: generationMetadata,
        localImagePath: savedImagePath,
        negativePrompt: promptPayload.negativePrompt,
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

  Future<Map<String, String>?> _generateImageWithFallback(
    ImagePromptPayload prompt,
  ) async {
    // Gemini 2.5 Flash Image로 이미지 생성
    if (AppConstants.enableGemini) {
      final geminiResult = await _generateImageWithGemini(prompt);
      if (geminiResult != null) {
        return {
          'service': 'Gemini',
          'image_base64': geminiResult,
          'image_url': 'gemini-inline-data',
        };
      }

      debugPrint('❌ Gemini 2.5 Flash Image 생성에 실패했습니다.');
    } else {
      debugPrint('⚠️ Gemini가 비활성화되어 있습니다.');
    }

    return null;
  }

  Future<String?> _generateImageWithGemini(ImagePromptPayload prompt) async {
    final apiKey = ApiKeys.geminiApiKey;
    debugPrint(
      '🔑 Gemini 2.5 Flash Image API 키 상태: ${apiKey.isNotEmpty ? "설정됨 (${apiKey.substring(0, 10)}...)" : "설정되지 않음"}',
    );

    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      debugPrint('⚠️ Gemini API 키가 설정되지 않았습니다.');
      return null;
    }

    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent?key=${ApiKeys.geminiApiKey}',
      );

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Generate an image: ${prompt.geminiPrompt}'},
              ],
            },
          ],
          'generationConfig': {
            'responseModalities': ['IMAGE', 'TEXT'],
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Gemini 2.5 Flash Image 응답 형식: candidates 배열
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
                  final imageData = inlineData['data'] as String?;
                  if (imageData != null && imageData.isNotEmpty) {
                    debugPrint('✅ Gemini 2.5 Flash Image 이미지 생성 성공');
                    return imageData;
                  }
                }
              }
            }
          }
        }

        debugPrint('❌ Gemini 2.5 Flash Image 응답에 이미지 데이터가 없습니다: ${response.body}');
        return null;
      }

      debugPrint('❌ Gemini 2.5 Flash Image 이미지 생성 실패: ${response.statusCode} ${response.body}');
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Gemini 2.5 Flash Image 이미지 생성 중 예외 발생: $e\n$stackTrace');
      return null;
    }
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

  Future<ImagePromptPayload?> _buildPromptPayload(
    TextAnalysisResult analysis,
    String originalText,
    ImageGenerationHints? hints,
  ) async {
    try {
      final summarySentence = _buildOneSentenceSummary(analysis, originalText);
      final moodDescription = _getMoodDescription(analysis.mood);
      // topicDescription is available for future use if needed
      final keywords = analysis.keywords.take(3).join(', ');

      final preferredStyle =
          _userCustomizationService.currentSettings.preferredStyle;
      final styleDescription = _getStyleDescription(preferredStyle);
      final stylePrompt = preferredStyle.promptSuffix;

      final buffer = StringBuffer()
        ..write('$summarySentence ')
        ..write('$moodDescription 분위기의 $styleDescription로 표현해 주세요. ')
        ..write('스타일 가이드: $stylePrompt.');

      final detailSegments = <String>[];

      if (hints != null) {
        if (hints.title != null && hints.title!.trim().isNotEmpty) {
          detailSegments.add('일기 제목은 "${hints.title!.trim()}"');
        }

        if (hints.date != null) {
          final formattedDate = DateFormat(
            'yyyy년 M월 d일 (E)',
            'ko_KR',
          ).format(hints.date!);
          detailSegments.add('$formattedDate의 기억');

          if (hints.timeOfDay == null || hints.timeOfDay!.trim().isEmpty) {
            detailSegments.add('${_describeTimeOfDay(hints.date!)} 분위기');
          }
        }

        if (hints.timeOfDay != null && hints.timeOfDay!.trim().isNotEmpty) {
          detailSegments.add('${hints.timeOfDay!.trim()}의 분위기');
        }

        if (hints.location != null && hints.location!.trim().isNotEmpty) {
          detailSegments.add('장소는 ${hints.location!.trim()}');
        }

        if (hints.weather != null && hints.weather!.trim().isNotEmpty) {
          detailSegments.add('날씨는 ${hints.weather!.trim()}');
        }

        if (hints.mood != null && hints.mood!.trim().isNotEmpty) {
          detailSegments.add('감정은 ${hints.mood!.trim()}');
        }

        if (hints.tags.isNotEmpty) {
          detailSegments.add('관련 태그: ${hints.tags.join(', ')}');
        }
      }

      // Topic description은 일기 내용과 무관하게 추가되므로 제거
      // if (topicDescription.isNotEmpty) {
      //   buffer.write(' 장면의 초점은 $topicDescription 입니다.');
      // }

      if (keywords.isNotEmpty) {
        buffer.write(' 참고 키워드: $keywords.');
      }

      final manualKeywords =
          _userCustomizationService.currentSettings.manualKeywords;
      if (manualKeywords.isNotEmpty) {
        final keywordStatement = manualKeywords.join(', ');
        buffer.write(' 사용자 지정 키워드: $keywordStatement.');
      }

      if (detailSegments.isNotEmpty) {
        buffer.write(' 추가 정보: ${detailSegments.join(', ')}.');
      }

      final guidelineSentences = <String>[
        '전체 장면에서 텍스트나 문자를 포함하지 마세요.',
        '사람의 얼굴이나 신체는 자연스럽고 왜곡 없이 표현하세요.',
        '일기의 감정과 분위기에 맞는 배경을 충분히 묘사하세요.',
        '전경과 배경의 조화로운 구성을 유지하세요.',
      ];

      if (analysis.topic == '일상') {
        guidelineSentences.add('평범한 일상 공간의 디테일을 담아주세요.');
      }

      if (analysis.emotion.toLowerCase().contains('슬픔')) {
        guidelineSentences.add('차분하고 위로가 느껴지는 분위기로 구성하세요.');
      }

      final negativeTokens = <String>{
        ..._baseNegativePromptTokens,
        'low resolution',
        'nsfw',
        'nudity',
        'gore',
        'extra limbs',
        'floating text',
        'handwriting',
        'poster design',
      };

      if (preferredStyle == ImageStyle.realistic) {
        negativeTokens.addAll(<String>{'cartoon', 'anime', 'cel shaded'});
      }

      final negativePrompt = negativeTokens.join(', ');

      return ImagePromptPayload(
        positivePrompt: buffer.toString(),
        guidelines: guidelineSentences,
        negativePrompt: negativePrompt,
      );
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

  String _getStyleDescription(ImageStyle style) {
    switch (style) {
      case ImageStyle.chibi:
        return '3등신 만화 캐릭터 일러스트';
      case ImageStyle.cute:
        return '귀엽고 사랑스러운 일러스트';
      case ImageStyle.pixelGame:
        return '레트로 픽셀 아트 게임 캐릭터 스타일';
      case ImageStyle.realistic:
        return '사실적 일러스트';
      case ImageStyle.cartoon:
        return '만화풍 일러스트';
      case ImageStyle.watercolor:
        return '수채화 질감의 일러스트';
      case ImageStyle.oil:
        return '유화 질감의 일러스트';
      case ImageStyle.sketch:
        return '연필 스케치 스타일 일러스트';
      case ImageStyle.digital:
        return '디지털 아트 스타일 일러스트';
      case ImageStyle.vintage:
        return '빈티지 톤 일러스트';
      case ImageStyle.modern:
        return '모던 미니멀리즘 일러스트';
      case ImageStyle.santaTogether:
        return '산타클로스와 함께하는 따뜻한 크리스마스 일러스트';
      case ImageStyle.childDraw:
        return '어린이가 그린 듯한 크레용 그림';
      case ImageStyle.figure:
        return '고품질 애니메 피규어 스타일';
    }
  }

  String _describeTimeOfDay(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour >= 5 && hour < 11) {
      return '아침';
    }
    if (hour >= 11 && hour < 15) {
      return '낮';
    }
    if (hour >= 15 && hour < 19) {
      return '저녁';
    }
    return '밤';
  }

  bool _listsShareElement(List<String> a, List<String> b) {
    if (a.isEmpty || b.isEmpty) {
      return true;
    }
    final setB = b.map((item) => item.toLowerCase()).toSet();
    for (final element in a) {
      if (setB.contains(element.toLowerCase())) {
        return true;
      }
    }
    return false;
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
  String _generateCacheKey(
    String originalText,
    TextAnalysisResult analysis,
    ImageGenerationHints? hints,
  ) {
    final customization = _userCustomizationService.currentSettings;
    final manualKeywords = List<String>.from(customization.manualKeywords)
      ..sort();

    final components = <String>[
      _cacheVersion,
      originalText.hashCode.toString(),
      analysis.topic.hashCode.toString(),
      analysis.mood.hashCode.toString(),
      customization.preferredStyle.name,
      customization.enableAutoOptimization.toString(),
      customization.enableStylePresets.toString(),
      _formatDouble(customization.brightness),
      _formatDouble(customization.contrast),
      _formatDouble(customization.saturation),
      _formatDouble(customization.blurRadius),
      customization.overlayColor.toARGB32().toString(),
      _formatDouble(customization.overlayOpacity),
    ];

    if (manualKeywords.isNotEmpty) {
      components.add(manualKeywords.join('|').hashCode.toString());
    }

    if (hints != null && hints.hasContext) {
      components.add(hints.signature().hashCode.toString());
    }

    return components.join('-');
  }

  String _formatDouble(num value) => value.toStringAsFixed(3);

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
  ImageGenerationResult? getCachedResult(
    String text, {
    ImageGenerationHints? hints,
  }) {
    if (hints != null && hints.hasContext) {
      final cachedAnalysis = _textAnalysisService.getCachedResult(text);
      if (cachedAnalysis != null) {
        final key = _generateCacheKey(text, cachedAnalysis, hints);
        final cached = _cache[key];
        if (cached != null) {
          return cached;
        }
      }
    }

    for (final result in _cache.values) {
      final meta = result.metadata;
      final originalText = meta['original_text'];
      if (originalText == text) {
        if (hints == null || !hints.hasContext) {
          return result;
        }

        final Object? storedContext = meta['context'];
        if (storedContext is Map<String, dynamic>) {
          final storedTags = storedContext['tags'];
          final storedMood = storedContext['mood'];
          final storedWeather = storedContext['weather'];
          final storedLocation = storedContext['location'];

          final matchesMood = storedMood == null || storedMood == hints.mood;
          final matchesWeather =
              storedWeather == null || storedWeather == hints.weather;
          final matchesLocation =
              storedLocation == null || storedLocation == hints.location;
          final matchesTags = storedTags is List
              ? _listsShareElement(
                  storedTags.map((e) => e.toString()).toList(),
                  hints.tags,
                )
              : true;

          if (matchesMood && matchesWeather && matchesLocation && matchesTags) {
            return result;
          }
        }
      }
    }

    return null;
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
