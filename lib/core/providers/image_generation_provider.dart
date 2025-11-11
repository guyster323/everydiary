import 'dart:async';

import 'package:everydiary/core/providers/generation_count_provider.dart';
import 'package:everydiary/core/services/image_generation_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 이미지 생성 서비스 프로바이더
final imageGenerationServiceProvider =
    Provider.autoDispose<ImageGenerationService>((ref) {
      final service = ImageGenerationService();
      ref.onDispose(service.dispose);
      return service;
    });

/// 이미지 생성 서비스 초기화 프로바이더
final imageGenerationInitializationProvider = FutureProvider.autoDispose<void>((
  ref,
) async {
  final service = ref.read(imageGenerationServiceProvider);
  await service.initialize();
});

/// 이미지 생성 결과 노티파이어
class ImageGenerationNotifier
    extends AutoDisposeAsyncNotifier<ImageGenerationResult?> {
  @override
  Future<ImageGenerationResult?> build() async {
    return null;
  }

  /// 텍스트에서 이미지 생성
  Future<void> generateImageFromText(String text) async {
    try {
      state = const AsyncLoading();

      // 생성 횟수 확인
      final countState = ref.read(generationCountProvider);
      if (countState.remainingCount <= 0) {
        state = AsyncError('생성 횟수가 부족합니다.', StackTrace.current);
        debugPrint('❌ 이미지 생성 횟수 부족');
        return;
      }

      // 횟수 소비
      final consumed = await ref
          .read(generationCountServiceProvider)
          .consumeGeneration();

      if (!consumed) {
        state = AsyncError('생성 횟수 차감에 실패했습니다.', StackTrace.current);
        debugPrint('❌ 생성 횟수 차감 실패');
        return;
      }

      final service = ref.read(imageGenerationServiceProvider);
      final result = await service.generateImageFromText(text);

      if (result != null) {
        state = AsyncData(result);
        debugPrint('✅ 이미지 생성 완료');
      } else {
        // 생성 실패 시 횟수 복구
        await ref.read(generationCountServiceProvider).addGenerations(1);
        state = AsyncError('이미지 생성에 실패했습니다.', StackTrace.current);
      }
    } catch (e, stackTrace) {
      // 오류 발생 시 횟수 복구
      try {
        await ref.read(generationCountServiceProvider).addGenerations(1);
      } catch (_) {}
      state = AsyncError(e, stackTrace);
      debugPrint('❌ 이미지 생성 실패: $e');
    }
  }

  /// 캐시된 결과 가져오기
  void getCachedResult(String text) {
    try {
      final service = ref.read(imageGenerationServiceProvider);
      final cachedResult = service.getCachedResult(text);

      if (cachedResult != null) {
        state = AsyncData(cachedResult);
        debugPrint('📋 캐시된 이미지 생성 결과 사용');
      } else {
        state = const AsyncData(null);
        debugPrint('❌ 캐시된 결과 없음');
      }
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      debugPrint('❌ 캐시된 결과 가져오기 실패: $e');
    }
  }

  /// 생성 상태 초기화
  void reset() {
    state = const AsyncData(null);
  }
}

final imageGenerationNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      ImageGenerationNotifier,
      ImageGenerationResult?
    >(ImageGenerationNotifier.new);

/// 이미지 생성 이력 프로바이더
final imageGenerationHistoryProvider =
    Provider.autoDispose<List<Map<String, dynamic>>>((ref) {
      final service = ref.read(imageGenerationServiceProvider);
      return service.getGenerationHistory();
    });

/// 이미지 생성 캐시 관리 노티파이어
class ImageGenerationCacheNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// 캐시 초기화
  Future<void> clearCache() async {
    try {
      state = const AsyncLoading();

      final service = ref.read(imageGenerationServiceProvider);
      await service.clearCache();

      state = const AsyncData(null);
      debugPrint('✅ 이미지 생성 캐시 초기화 완료');
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      debugPrint('❌ 캐시 초기화 실패: $e');
    }
  }

  /// 생성 이력 초기화
  Future<void> clearHistory() async {
    try {
      state = const AsyncLoading();

      final service = ref.read(imageGenerationServiceProvider);
      await service.clearHistory();

      state = const AsyncData(null);
      debugPrint('✅ 이미지 생성 이력 초기화 완료');
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      debugPrint('❌ 이력 초기화 실패: $e');
    }
  }
}

final imageGenerationCacheNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ImageGenerationCacheNotifier, void>(
      ImageGenerationCacheNotifier.new,
    );
