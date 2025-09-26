import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// OpenAI API 연동 서비스
/// DALL-E 이미지 생성 및 텍스트 분석 기능을 제공합니다.
class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  factory OpenAIService() => _instance;
  OpenAIService._internal();

  String? _apiKey;
  bool _isInitialized = false;
  final String _baseUrl = 'https://api.openai.com/v1';

  // API 사용량 모니터링
  int _apiCallCount = 0;
  DateTime? _lastApiCall;
  final List<Map<String, dynamic>> _apiCallHistory = [];

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 OpenAI 서비스 초기화 시작');

      // API 키 로드
      await _loadApiKey();

      if (_apiKey == null || _apiKey!.isEmpty) {
        debugPrint('⚠️ OpenAI API 키가 설정되지 않았습니다.');
        return;
      }

      // API 사용량 이력 로드
      await _loadApiCallHistory();

      _isInitialized = true;
      debugPrint('✅ OpenAI 서비스 초기화 완료');
    } catch (e) {
      debugPrint('❌ OpenAI 서비스 초기화 실패: $e');
    }
  }

  /// API 키 로드
  Future<void> _loadApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _apiKey = prefs.getString('openai_api_key');
    } catch (e) {
      debugPrint('❌ API 키 로드 실패: $e');
    }
  }

  /// API 키 설정
  Future<bool> setApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('openai_api_key', apiKey);
      _apiKey = apiKey;

      debugPrint('✅ OpenAI API 키 설정 완료');
      return true;
    } catch (e) {
      debugPrint('❌ API 키 설정 실패: $e');
      return false;
    }
  }

  /// API 키 확인
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  /// 초기화 상태 확인
  bool get isInitialized => _isInitialized && _apiKey != null;

  /// DALL-E 이미지 생성
  Future<Map<String, dynamic>?> generateImage({
    required String prompt,
    String model = 'dall-e-3',
    String size = '1024x1024',
    String quality = 'standard',
    String style = 'vivid',
    int n = 1,
  }) async {
    if (!isInitialized) {
      debugPrint('❌ OpenAI 서비스가 초기화되지 않았습니다.');
      return null;
    }

    try {
      debugPrint('🎨 DALL-E 이미지 생성 시작: $prompt');

      final requestBody = {
        'model': model,
        'prompt': prompt,
        'size': size,
        'quality': quality,
        'style': style,
        'n': n,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/images/generations'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        // API 사용량 추적
        _trackApiCall('image_generation', {
          'model': model,
          'size': size,
          'quality': quality,
          'style': style,
          'n': n,
          'prompt_length': prompt.length,
        });

        debugPrint('✅ DALL-E 이미지 생성 완료');
        return responseData;
      } else {
        debugPrint(
          '❌ DALL-E 이미지 생성 실패: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('❌ DALL-E 이미지 생성 실패: $e');
      return null;
    }
  }

  /// 텍스트 분석 (감정, 키워드, 주제)
  Future<Map<String, dynamic>?> analyzeText(String text) async {
    if (!isInitialized) {
      debugPrint('❌ OpenAI 서비스가 초기화되지 않았습니다.');
      return null;
    }

    try {
      debugPrint('📝 텍스트 분석 시작');

      final prompt =
          '''
다음 일기 내용을 분석해주세요:

"$text"

다음 형식으로 JSON 응답해주세요:
{
  "emotion": "긍정/부정/중립",
  "emotion_score": 0.0-1.0,
  "keywords": ["키워드1", "키워드2", "키워드3"],
  "topic": "주제",
  "mood": "기분",
  "summary": "요약"
}
''';

      final requestBody = {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 500,
        'temperature': 0.3,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        if (responseData['choices'] != null &&
            (responseData['choices'] as List).isNotEmpty) {
          final choice =
              (responseData['choices'] as List).first as Map<String, dynamic>;
          final message = choice['message'] as Map<String, dynamic>;
          final content = message['content'] as String?;

          if (content != null) {
            // JSON 파싱 시도
            try {
              final jsonData = jsonDecode(content) as Map<String, dynamic>;

              // API 사용량 추적
              _trackApiCall('text_analysis', {
                'text_length': text.length,
                'model': 'gpt-3.5-turbo',
              });

              debugPrint('✅ 텍스트 분석 완료');
              return jsonData;
            } catch (e) {
              debugPrint('❌ JSON 파싱 실패: $e');
              return null;
            }
          }
        }
      } else {
        debugPrint('❌ 텍스트 분석 실패: ${response.statusCode} - ${response.body}');
      }

      return null;
    } catch (e) {
      debugPrint('❌ 텍스트 분석 실패: $e');
      return null;
    }
  }

  /// 이미지 프롬프트 최적화
  Future<String?> optimizeImagePrompt({
    required String originalPrompt,
    required String emotion,
    required String topic,
    required List<String> keywords,
    String style = 'vivid',
  }) async {
    if (!isInitialized) {
      debugPrint('❌ OpenAI 서비스가 초기화되지 않았습니다.');
      return null;
    }

    try {
      debugPrint('🎯 이미지 프롬프트 최적화 시작');

      final prompt =
          '''
다음 정보를 바탕으로 DALL-E용 이미지 프롬프트를 최적화해주세요:

원본 프롬프트: "$originalPrompt"
감정: $emotion
주제: $topic
키워드: ${keywords.join(', ')}

요구사항:
1. 영어로 작성
2. 구체적이고 시각적인 설명
3. 아름답고 감성적인 표현
4. 100자 이내
5. DALL-E가 이해하기 쉬운 형식

최적화된 프롬프트만 응답해주세요.
''';

      final requestBody = {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 200,
        'temperature': 0.7,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        if (responseData['choices'] != null &&
            (responseData['choices'] as List).isNotEmpty) {
          final choice =
              (responseData['choices'] as List).first as Map<String, dynamic>;
          final message = choice['message'] as Map<String, dynamic>;
          final optimizedPrompt = message['content'] as String?;

          if (optimizedPrompt != null && optimizedPrompt.trim().isNotEmpty) {
            // API 사용량 추적
            _trackApiCall('prompt_optimization', {
              'original_length': originalPrompt.length,
              'model': 'gpt-3.5-turbo',
            });

            debugPrint('✅ 이미지 프롬프트 최적화 완료');
            return optimizedPrompt.trim();
          }
        }
      } else {
        debugPrint(
          '❌ 이미지 프롬프트 최적화 실패: ${response.statusCode} - ${response.body}',
        );
      }

      return null;
    } catch (e) {
      debugPrint('❌ 이미지 프롬프트 최적화 실패: $e');
      return null;
    }
  }

  /// API 사용량 추적
  void _trackApiCall(String operation, Map<String, dynamic> metadata) {
    _apiCallCount++;
    _lastApiCall = DateTime.now();

    final callData = {
      'timestamp': DateTime.now().toIso8601String(),
      'operation': operation,
      'metadata': metadata,
    };

    _apiCallHistory.add(callData);

    // 이력이 너무 많아지면 오래된 것부터 삭제
    if (_apiCallHistory.length > 100) {
      _apiCallHistory.removeAt(0);
    }

    // 비동기로 저장
    _saveApiCallHistory();
  }

  /// API 사용량 이력 로드
  Future<void> _loadApiCallHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('openai_api_call_history');

      if (historyJson != null) {
        final List<dynamic> historyList =
            jsonDecode(historyJson) as List<dynamic>;
        _apiCallHistory.clear();
        _apiCallHistory.addAll(
          historyList.map((item) => item as Map<String, dynamic>),
        );
      }
    } catch (e) {
      debugPrint('❌ API 사용량 이력 로드 실패: $e');
    }
  }

  /// API 사용량 이력 저장
  Future<void> _saveApiCallHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'openai_api_call_history',
        jsonEncode(_apiCallHistory),
      );
    } catch (e) {
      debugPrint('❌ API 사용량 이력 저장 실패: $e');
    }
  }

  /// API 사용량 통계
  Map<String, dynamic> getApiUsageStats() {
    return {
      'totalCalls': _apiCallCount,
      'lastCall': _lastApiCall?.toIso8601String(),
      'callHistory': _apiCallHistory,
      'isInitialized': _isInitialized,
      'hasApiKey': hasApiKey,
    };
  }

  /// API 사용량 이력 초기화
  Future<void> clearApiCallHistory() async {
    try {
      _apiCallHistory.clear();
      _apiCallCount = 0;
      _lastApiCall = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('openai_api_call_history');

      debugPrint('✅ API 사용량 이력 초기화 완료');
    } catch (e) {
      debugPrint('❌ API 사용량 이력 초기화 실패: $e');
    }
  }

  /// 서비스 정리
  void dispose() {
    _apiKey = null;
    _isInitialized = false;
    debugPrint('🗑️ OpenAI 서비스 정리 완료');
  }
}
