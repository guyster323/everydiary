import 'dart:async';

import 'package:everydiary/core/services/openai_service.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'openai_provider.g.dart';

/// OpenAI 서비스 프로바이더
@riverpod
OpenAIService openaiService(OpenaiServiceRef ref) {
  final service = OpenAIService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// OpenAI 서비스 초기화 프로바이더
@riverpod
Future<void> openaiInitialization(OpenaiInitializationRef ref) async {
  final service = ref.read(openaiServiceProvider);
  await service.initialize();
}

/// OpenAI API 키 상태 프로바이더
@riverpod
bool openaiHasApiKey(OpenaiHasApiKeyRef ref) {
  final service = ref.read(openaiServiceProvider);
  return service.hasApiKey;
}

/// OpenAI 초기화 상태 프로바이더
@riverpod
bool openaiIsInitialized(OpenaiIsInitializedRef ref) {
  final service = ref.read(openaiServiceProvider);
  return service.isInitialized;
}

/// OpenAI API 사용량 통계 프로바이더
@riverpod
Map<String, dynamic> openaiApiUsageStats(OpenaiApiUsageStatsRef ref) {
  final service = ref.read(openaiServiceProvider);
  return service.getApiUsageStats();
}

/// OpenAI 이미지 생성 프로바이더
@riverpod
class OpenAIImageGenerationNotifier extends _$OpenAIImageGenerationNotifier {
  @override
  Future<Map<String, dynamic>?> build() async {
    return null;
  }

  /// 이미지 생성
  Future<void> generateImage({
    required String prompt,
    String model = 'dall-e-3',
    String size = '1024x1024',
    String quality = 'standard',
    String style = 'vivid',
    int n = 1,
  }) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(openaiServiceProvider);
      final response = await service.generateImage(
        prompt: prompt,
        model: model,
        size: size,
        quality: quality,
        style: style,
        n: n,
      );

      if (response != null) {
        state = AsyncValue.data(response);
        debugPrint('✅ 이미지 생성 완료');
      } else {
        state = AsyncValue.error('이미지 생성에 실패했습니다.', StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 이미지 생성 실패: $e');
    }
  }

  /// 이미지 생성 상태 초기화
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// OpenAI 텍스트 분석 프로바이더
@riverpod
class OpenAITextAnalysisNotifier extends _$OpenAITextAnalysisNotifier {
  @override
  Future<Map<String, dynamic>?> build() async {
    return null;
  }

  /// 텍스트 분석
  Future<void> analyzeText(String text) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(openaiServiceProvider);
      final result = await service.analyzeText(text);

      if (result != null) {
        state = AsyncValue.data(result);
        debugPrint('✅ 텍스트 분석 완료');
      } else {
        state = AsyncValue.error('텍스트 분석에 실패했습니다.', StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 텍스트 분석 실패: $e');
    }
  }

  /// 텍스트 분석 상태 초기화
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// OpenAI 프롬프트 최적화 프로바이더
@riverpod
class OpenAIPromptOptimizationNotifier
    extends _$OpenAIPromptOptimizationNotifier {
  @override
  Future<String?> build() async {
    return null;
  }

  /// 프롬프트 최적화
  Future<void> optimizePrompt({
    required String originalPrompt,
    required String emotion,
    required String topic,
    required List<String> keywords,
    String style = 'vivid',
  }) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(openaiServiceProvider);
      final optimizedPrompt = await service.optimizeImagePrompt(
        originalPrompt: originalPrompt,
        emotion: emotion,
        topic: topic,
        keywords: keywords,
        style: style,
      );

      if (optimizedPrompt != null) {
        state = AsyncValue.data(optimizedPrompt);
        debugPrint('✅ 프롬프트 최적화 완료');
      } else {
        state = AsyncValue.error('프롬프트 최적화에 실패했습니다.', StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 프롬프트 최적화 실패: $e');
    }
  }

  /// 프롬프트 최적화 상태 초기화
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// OpenAI API 키 설정 프로바이더
@riverpod
class OpenAIApiKeyNotifier extends _$OpenAIApiKeyNotifier {
  @override
  Future<bool> build() async {
    final service = ref.read(openaiServiceProvider);
    return service.hasApiKey;
  }

  /// API 키 설정
  Future<void> setApiKey(String apiKey) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(openaiServiceProvider);
      final success = await service.setApiKey(apiKey);

      if (success) {
        state = const AsyncValue.data(true);
        debugPrint('✅ API 키 설정 완료');
      } else {
        state = AsyncValue.error('API 키 설정에 실패했습니다.', StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ API 키 설정 실패: $e');
    }
  }

  /// API 키 제거
  Future<void> removeApiKey() async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(openaiServiceProvider);
      await service.setApiKey('');

      state = const AsyncValue.data(false);
      debugPrint('✅ API 키 제거 완료');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ API 키 제거 실패: $e');
    }
  }
}
