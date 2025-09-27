import 'package:everydiary/core/services/background_optimization_service.dart';
import 'package:everydiary/core/services/image_generation_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final backgroundOptimizationServiceProvider =
    AutoDisposeProvider<BackgroundOptimizationService>((ref) {
      final service = BackgroundOptimizationService();
      ref.onDispose(service.dispose);
      return service;
    });

final backgroundOptimizationInitializationProvider =
    AutoDisposeFutureProvider<void>((ref) async {
      final service = ref.read(backgroundOptimizationServiceProvider);
      await service.initialize();
    });

class BackgroundOptimizationNotifier
    extends AutoDisposeAsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, dynamic>?> build() async => null;

  Future<void> optimizeBackground(
    ImageGenerationResult imageResult,
    Size screenSize,
  ) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(backgroundOptimizationServiceProvider);
      final result = await service.optimizeBackground(imageResult, screenSize);

      if (result != null) {
        state = AsyncValue.data(result);
        debugPrint('✅ 배경 이미지 최적화 완료');
      } else {
        state = AsyncValue.error('배경 이미지 최적화에 실패했습니다.', StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 배경 이미지 최적화 실패: $e');
    }
  }

  void getCachedOptimization(
    ImageGenerationResult imageResult,
    Size screenSize,
  ) {
    try {
      final service = ref.read(backgroundOptimizationServiceProvider);
      final cachedResult = service.getCachedOptimization(
        imageResult,
        screenSize,
      );

      if (cachedResult != null) {
        state = AsyncValue.data(cachedResult);
        debugPrint('📋 캐시된 배경 최적화 결과 사용');
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

final backgroundOptimizationNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      BackgroundOptimizationNotifier,
      Map<String, dynamic>?
    >(BackgroundOptimizationNotifier.new);

final backgroundOptimizationSettingsProvider =
    AutoDisposeProvider<BackgroundOptimizationSettings>((ref) {
      final service = ref.read(backgroundOptimizationServiceProvider);
      return service.currentSettings;
    });

class BackgroundOptimizationSettingsNotifier
    extends AutoDisposeAsyncNotifier<BackgroundOptimizationSettings> {
  @override
  Future<BackgroundOptimizationSettings> build() async {
    final service = ref.read(backgroundOptimizationServiceProvider);
    return service.currentSettings;
  }

  Future<void> updateSettings(
    BackgroundOptimizationSettings newSettings,
  ) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(backgroundOptimizationServiceProvider);
      await service.updateSettings(newSettings);

      state = AsyncValue.data(newSettings);
      debugPrint('✅ 배경 최적화 설정 업데이트 완료');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 설정 업데이트 실패: $e');
    }
  }

  Future<void> updateBlurRadius(double blurRadius) async {
    try {
      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(blurRadius: blurRadius);
      await updateSettings(newSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 블러 반경 업데이트 실패: $e');
    }
  }

  Future<void> updateBrightness(double brightness) async {
    try {
      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(brightness: brightness);
      await updateSettings(newSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 밝기 업데이트 실패: $e');
    }
  }

  Future<void> updateContrast(double contrast) async {
    try {
      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(contrast: contrast);
      await updateSettings(newSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 대비 업데이트 실패: $e');
    }
  }

  Future<void> updateSaturation(double saturation) async {
    try {
      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(saturation: saturation);
      await updateSettings(newSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 포화도 업데이트 실패: $e');
    }
  }

  Future<void> updateOverlayColor(Color overlayColor) async {
    try {
      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(overlayColor: overlayColor);
      await updateSettings(newSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 오버레이 색상 업데이트 실패: $e');
    }
  }

  Future<void> updateOverlayOpacity(double overlayOpacity) async {
    try {
      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(
        overlayOpacity: overlayOpacity,
      );
      await updateSettings(newSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 오버레이 투명도 업데이트 실패: $e');
    }
  }

  Future<void> toggleAutoContrast() async {
    try {
      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(
        enableAutoContrast: !currentSettings.enableAutoContrast,
      );
      await updateSettings(newSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 자동 대비 조정 토글 실패: $e');
    }
  }

  Future<void> toggleTextReadability() async {
    try {
      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(
        enableTextReadability: !currentSettings.enableTextReadability,
      );
      await updateSettings(newSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 텍스트 가독성 토글 실패: $e');
    }
  }
}

final backgroundOptimizationSettingsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      BackgroundOptimizationSettingsNotifier,
      BackgroundOptimizationSettings
    >(BackgroundOptimizationSettingsNotifier.new);

final backgroundOptimizationHistoryProvider =
    AutoDisposeProvider<List<Map<String, dynamic>>>((ref) {
      final service = ref.read(backgroundOptimizationServiceProvider);
      return service.getOptimizationHistory();
    });

class BackgroundOptimizationCacheNotifier
    extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> clearCache() async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(backgroundOptimizationServiceProvider);
      await service.clearCache();

      state = const AsyncValue.data(null);
      debugPrint('✅ 배경 최적화 캐시 초기화 완료');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 캐시 초기화 실패: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(backgroundOptimizationServiceProvider);
      await service.clearHistory();

      state = const AsyncValue.data(null);
      debugPrint('✅ 배경 최적화 이력 초기화 완료');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 이력 초기화 실패: $e');
    }
  }
}

final backgroundOptimizationCacheNotifierProvider =
    AutoDisposeAsyncNotifierProvider<BackgroundOptimizationCacheNotifier, void>(
      BackgroundOptimizationCacheNotifier.new,
    );
