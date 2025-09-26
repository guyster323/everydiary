import 'dart:async';

import 'package:everydiary/core/services/text_analysis_service.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'text_analysis_provider.g.dart';

/// 텍스트 분석 서비스 프로바이더
@riverpod
TextAnalysisService textAnalysisService(TextAnalysisServiceRef ref) {
  final service = TextAnalysisService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// 텍스트 분석 서비스 초기화 프로바이더
@riverpod
Future<void> textAnalysisInitialization(
  TextAnalysisInitializationRef ref,
) async {
  final service = ref.read(textAnalysisServiceProvider);
  await service.initialize();
}

/// 텍스트 분석 결과 프로바이더
@riverpod
class TextAnalysisNotifier extends _$TextAnalysisNotifier {
  @override
  Future<TextAnalysisResult?> build() async {
    return null;
  }

  /// 텍스트 분석
  Future<void> analyzeText(String text) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(textAnalysisServiceProvider);
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

  /// 캐시된 결과 가져오기
  void getCachedResult(String text) {
    try {
      final service = ref.read(textAnalysisServiceProvider);
      final cachedResult = service.getCachedResult(text);

      if (cachedResult != null) {
        state = AsyncValue.data(cachedResult);
        debugPrint('📋 캐시된 분석 결과 사용');
      } else {
        state = const AsyncValue.data(null);
        debugPrint('❌ 캐시된 결과 없음');
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 캐시된 결과 가져오기 실패: $e');
    }
  }

  /// 분석 상태 초기화
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// 텍스트 분석 이력 프로바이더
@riverpod
List<Map<String, dynamic>> textAnalysisHistory(TextAnalysisHistoryRef ref) {
  final service = ref.read(textAnalysisServiceProvider);
  return service.getAnalysisHistory();
}

/// 텍스트 분석 캐시 관리 프로바이더
@riverpod
class TextAnalysisCacheNotifier extends _$TextAnalysisCacheNotifier {
  @override
  Future<void> build() async {
    // 초기화 시 아무것도 하지 않음
  }

  /// 캐시 초기화
  Future<void> clearCache() async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(textAnalysisServiceProvider);
      await service.clearCache();

      state = const AsyncValue.data(null);
      debugPrint('✅ 텍스트 분석 캐시 초기화 완료');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 캐시 초기화 실패: $e');
    }
  }

  /// 분석 이력 초기화
  Future<void> clearHistory() async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(textAnalysisServiceProvider);
      await service.clearHistory();

      state = const AsyncValue.data(null);
      debugPrint('✅ 텍스트 분석 이력 초기화 완료');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 이력 초기화 실패: $e');
    }
  }
}
