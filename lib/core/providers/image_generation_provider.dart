import 'dart:async';

import 'package:everydiary/core/providers/generation_count_provider.dart';
import 'package:everydiary/core/services/image_generation_service.dart';
import 'package:everydiary/shared/services/ad_service.dart';
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

      // 생성 횟수 확인 (service에서 실제 소비하므로 여기서는 확인만)
      final countState = ref.read(generationCountProvider);
      if (countState.remainingCount <= 0) {
        state = AsyncError('생성 횟수가 부족합니다.', StackTrace.current);
        debugPrint('❌ 이미지 생성 횟수 부족');
        return;
      }

      // 횟수 소비는 ImageGenerationService에서 처리 (중복 소비 방지)
      final service = ref.read(imageGenerationServiceProvider);
      final result = await service.generateImageFromText(text);

      if (result != null) {
        state = AsyncData(result);
        debugPrint('✅ 이미지 생성 완료');
        // 횟수 갱신
        await ref.read(generationCountServiceProvider).reload();
      } else {
        state = AsyncError('이미지 생성에 실패했습니다.', StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      debugPrint('❌ 이미지 생성 실패: $e');
    }
  }

  /// 광고 지원과 함께 텍스트에서 이미지 생성
  /// 횟수가 0일 경우 광고를 먼저 재생하고, 성공 시 이미지 생성
  Future<void> generateImageWithAdSupport(String text) async {
    try {
      state = const AsyncLoading();

      // 생성 횟수 확인
      final countState = ref.read(generationCountProvider);

      // 횟수가 0이면 광고 재생
      if (countState.remainingCount <= 0) {
        debugPrint('🎬 횟수 부족 - 광고 재생 시도');

        // 광고 로드
        await AdService.instance.loadRewardedAd();

        // 광고 재생
        final adResult = await AdService.instance.showRewardedAd();

        if (adResult) {
          // 광고 시청 완료 - 2회 추가
          debugPrint('✅ 광고 시청 완료 - 2회 추가');
          await ref.read(generationCountServiceProvider).addGenerations(2);
        } else {
          // 광고 시청 실패
          debugPrint('❌ 광고 시청 실패 또는 취소');
          state = AsyncError('광고 시청이 필요합니다.', StackTrace.current);
          return;
        }
      }

      // 이미지 생성 (횟수 소비는 service에서 처리)
      final service = ref.read(imageGenerationServiceProvider);
      final result = await service.generateImageFromText(text);

      if (result != null) {
        state = AsyncData(result);
        debugPrint('✅ 이미지 생성 완료');
        // 횟수 갱신
        await ref.read(generationCountServiceProvider).reload();
      } else {
        state = AsyncError('이미지 생성에 실패했습니다.', StackTrace.current);
      }
    } catch (e, stackTrace) {
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
