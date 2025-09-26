import 'dart:async';

import 'package:everydiary/core/services/background_optimization_service.dart';
import 'package:everydiary/core/services/image_generation_service.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'background_optimization_provider.g.dart';

/// 배경 최적화 서비스 프로바이더
@riverpod
BackgroundOptimizationService backgroundOptimizationService(
  BackgroundOptimizationServiceRef ref,
) {
  final service = BackgroundOptimizationService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// 배경 최적화 서비스 초기화 프로바이더
@riverpod
Future<void> backgroundOptimizationInitialization(
  BackgroundOptimizationInitializationRef ref,
) async {
  final service = ref.read(backgroundOptimizationServiceProvider);
  await service.initialize();
}

/// 배경 최적화 결과 프로바이더
@riverpod
class BackgroundOptimizationNotifier extends _$BackgroundOptimizationNotifier {
  @override
  Future<Map<String, dynamic>?> build() async {
    return null;
  }

  /// 배경 이미지 최적화
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

  /// 캐시된 최적화 결과 가져오기
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

  /// 최적화 상태 초기화
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// 배경 최적화 설정 프로바이더
@riverpod
BackgroundOptimizationSettings backgroundOptimizationSettings(
  BackgroundOptimizationSettingsRef ref,
) {
  final service = ref.read(backgroundOptimizationServiceProvider);
  return service.currentSettings;
}

/// 배경 최적화 설정 관리 프로바이더
@riverpod
class BackgroundOptimizationSettingsNotifier
    extends _$BackgroundOptimizationSettingsNotifier {
  @override
  Future<BackgroundOptimizationSettings> build() async {
    final service = ref.read(backgroundOptimizationServiceProvider);
    return service.currentSettings;
  }

  /// 설정 업데이트
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

  /// 블러 반경 업데이트
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

  /// 밝기 업데이트
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

  /// 대비 업데이트
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

  /// 포화도 업데이트
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

  /// 오버레이 색상 업데이트
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

  /// 오버레이 투명도 업데이트
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

  /// 자동 대비 조정 토글
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

  /// 텍스트 가독성 토글
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

/// 배경 최적화 이력 프로바이더
@riverpod
List<Map<String, dynamic>> backgroundOptimizationHistory(
  BackgroundOptimizationHistoryRef ref,
) {
  final service = ref.read(backgroundOptimizationServiceProvider);
  return service.getOptimizationHistory();
}

/// 배경 최적화 캐시 관리 프로바이더
@riverpod
class BackgroundOptimizationCacheNotifier
    extends _$BackgroundOptimizationCacheNotifier {
  @override
  Future<void> build() async {
    // 초기화 시 아무것도 하지 않음
  }

  /// 캐시 초기화
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

  /// 최적화 이력 초기화
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
