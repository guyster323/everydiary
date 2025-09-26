import 'dart:async';

import 'package:everydiary/core/services/image_generation_service.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_generation_provider.g.dart';

/// 이미지 생성 서비스 프로바이더
@riverpod
ImageGenerationService imageGenerationService(ImageGenerationServiceRef ref) {
  final service = ImageGenerationService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// 이미지 생성 서비스 초기화 프로바이더
@riverpod
Future<void> imageGenerationInitialization(
  ImageGenerationInitializationRef ref,
) async {
  final service = ref.read(imageGenerationServiceProvider);
  await service.initialize();
}

/// 이미지 생성 결과 프로바이더
@riverpod
class ImageGenerationNotifier extends _$ImageGenerationNotifier {
  @override
  Future<ImageGenerationResult?> build() async {
    return null;
  }

  /// 텍스트에서 이미지 생성
  Future<void> generateImageFromText(String text) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(imageGenerationServiceProvider);
      final result = await service.generateImageFromText(text);

      if (result != null) {
        state = AsyncValue.data(result);
        debugPrint('✅ 이미지 생성 완료');
      } else {
        state = AsyncValue.error('이미지 생성에 실패했습니다.', StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 이미지 생성 실패: $e');
    }
  }

  /// 캐시된 결과 가져오기
  void getCachedResult(String text) {
    try {
      final service = ref.read(imageGenerationServiceProvider);
      final cachedResult = service.getCachedResult(text);

      if (cachedResult != null) {
        state = AsyncValue.data(cachedResult);
        debugPrint('📋 캐시된 이미지 생성 결과 사용');
      } else {
        state = const AsyncValue.data(null);
        debugPrint('❌ 캐시된 결과 없음');
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 캐시된 결과 가져오기 실패: $e');
    }
  }

  /// 생성 상태 초기화
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// 이미지 생성 이력 프로바이더
@riverpod
List<Map<String, dynamic>> imageGenerationHistory(
  ImageGenerationHistoryRef ref,
) {
  final service = ref.read(imageGenerationServiceProvider);
  return service.getGenerationHistory();
}

/// 이미지 생성 캐시 관리 프로바이더
@riverpod
class ImageGenerationCacheNotifier extends _$ImageGenerationCacheNotifier {
  @override
  Future<void> build() async {
    // 초기화 시 아무것도 하지 않음
  }

  /// 캐시 초기화
  Future<void> clearCache() async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(imageGenerationServiceProvider);
      await service.clearCache();

      state = const AsyncValue.data(null);
      debugPrint('✅ 이미지 생성 캐시 초기화 완료');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 캐시 초기화 실패: $e');
    }
  }

  /// 생성 이력 초기화
  Future<void> clearHistory() async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(imageGenerationServiceProvider);
      await service.clearHistory();

      state = const AsyncValue.data(null);
      debugPrint('✅ 이미지 생성 이력 초기화 완료');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 이력 초기화 실패: $e');
    }
  }
}
