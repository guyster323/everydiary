import 'package:everydiary/core/services/text_analysis_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final textAnalysisServiceProvider = AutoDisposeProvider<TextAnalysisService>((
  ref,
) {
  final service = TextAnalysisService();
  ref.onDispose(service.dispose);
  return service;
});

final textAnalysisInitializationProvider = AutoDisposeFutureProvider<void>((
  ref,
) async {
  final service = ref.read(textAnalysisServiceProvider);
  await service.initialize();
});

class TextAnalysisNotifier
    extends AutoDisposeAsyncNotifier<TextAnalysisResult?> {
  @override
  Future<TextAnalysisResult?> build() async => null;

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

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final textAnalysisNotifierProvider =
    AutoDisposeAsyncNotifierProvider<TextAnalysisNotifier, TextAnalysisResult?>(
      TextAnalysisNotifier.new,
    );

final textAnalysisHistoryProvider =
    AutoDisposeProvider<List<Map<String, dynamic>>>((ref) {
      final service = ref.read(textAnalysisServiceProvider);
      return service.getAnalysisHistory();
    });

class TextAnalysisCacheNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

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

final textAnalysisCacheNotifierProvider =
    AutoDisposeAsyncNotifierProvider<TextAnalysisCacheNotifier, void>(
      TextAnalysisCacheNotifier.new,
    );
