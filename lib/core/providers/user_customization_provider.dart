import 'dart:async';

import 'package:everydiary/core/services/user_customization_service.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_customization_provider.g.dart';

/// 사용자 커스터마이징 서비스 프로바이더
@riverpod
UserCustomizationService userCustomizationService(
  UserCustomizationServiceRef ref,
) {
  final service = UserCustomizationService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// 사용자 커스터마이징 서비스 초기화 프로바이더
@riverpod
Future<void> userCustomizationInitialization(
  UserCustomizationInitializationRef ref,
) async {
  final service = ref.read(userCustomizationServiceProvider);
  await service.initialize();
}

/// 사용자 커스터마이징 설정 프로바이더
@riverpod
UserCustomizationSettings userCustomizationSettings(
  UserCustomizationSettingsRef ref,
) {
  final service = ref.read(userCustomizationServiceProvider);
  return service.currentSettings;
}

/// 사용자 커스터마이징 설정 관리 프로바이더
@riverpod
class UserCustomizationSettingsNotifier
    extends _$UserCustomizationSettingsNotifier {
  @override
  Future<UserCustomizationSettings> build() async {
    final service = ref.read(userCustomizationServiceProvider);
    return service.currentSettings;
  }

  /// 설정 업데이트
  Future<void> updateSettings(UserCustomizationSettings newSettings) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(userCustomizationServiceProvider);
      await service.updateSettings(newSettings);

      state = AsyncValue.data(newSettings);
      debugPrint('✅ 사용자 커스터마이징 설정 업데이트 완료');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 설정 업데이트 실패: $e');
    }
  }

  /// 스타일 업데이트
  Future<void> updateStyle(ImageStyle style) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(userCustomizationServiceProvider);
      await service.updateStyle(style);

      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(preferredStyle: style);
      state = AsyncValue.data(newSettings);
      debugPrint('✅ 이미지 스타일 업데이트: ${style.displayName}');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 스타일 업데이트 실패: $e');
    }
  }

  /// 밝기 업데이트
  Future<void> updateBrightness(double brightness) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(userCustomizationServiceProvider);
      await service.updateBrightness(brightness);

      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(brightness: brightness);
      state = AsyncValue.data(newSettings);
      debugPrint('✅ 밝기 업데이트: $brightness');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 밝기 업데이트 실패: $e');
    }
  }

  /// 대비 업데이트
  Future<void> updateContrast(double contrast) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(userCustomizationServiceProvider);
      await service.updateContrast(contrast);

      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(contrast: contrast);
      state = AsyncValue.data(newSettings);
      debugPrint('✅ 대비 업데이트: $contrast');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 대비 업데이트 실패: $e');
    }
  }

  /// 포화도 업데이트
  Future<void> updateSaturation(double saturation) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(userCustomizationServiceProvider);
      await service.updateSaturation(saturation);

      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(saturation: saturation);
      state = AsyncValue.data(newSettings);
      debugPrint('✅ 포화도 업데이트: $saturation');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 포화도 업데이트 실패: $e');
    }
  }

  /// 블러 반경 업데이트
  Future<void> updateBlurRadius(double blurRadius) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(userCustomizationServiceProvider);
      await service.updateBlurRadius(blurRadius);

      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(blurRadius: blurRadius);
      state = AsyncValue.data(newSettings);
      debugPrint('✅ 블러 반경 업데이트: $blurRadius');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 블러 반경 업데이트 실패: $e');
    }
  }

  /// 오버레이 색상 업데이트
  Future<void> updateOverlayColor(Color overlayColor) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(userCustomizationServiceProvider);
      await service.updateOverlayColor(overlayColor);

      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(overlayColor: overlayColor);
      state = AsyncValue.data(newSettings);
      debugPrint('✅ 오버레이 색상 업데이트: ${overlayColor.value}');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 오버레이 색상 업데이트 실패: $e');
    }
  }

  /// 오버레이 투명도 업데이트
  Future<void> updateOverlayOpacity(double overlayOpacity) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(userCustomizationServiceProvider);
      await service.updateOverlayOpacity(overlayOpacity);

      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(
        overlayOpacity: overlayOpacity,
      );
      state = AsyncValue.data(newSettings);
      debugPrint('✅ 오버레이 투명도 업데이트: $overlayOpacity');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 오버레이 투명도 업데이트 실패: $e');
    }
  }

  /// 자동 최적화 토글
  Future<void> toggleAutoOptimization() async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(userCustomizationServiceProvider);
      await service.toggleAutoOptimization();

      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(
        enableAutoOptimization: !currentSettings.enableAutoOptimization,
      );
      state = AsyncValue.data(newSettings);
      debugPrint('✅ 자동 최적화 토글: ${newSettings.enableAutoOptimization}');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 자동 최적화 토글 실패: $e');
    }
  }

  /// 스타일 프리셋 토글
  Future<void> toggleStylePresets() async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(userCustomizationServiceProvider);
      await service.toggleStylePresets();

      final currentSettings = await future;
      final newSettings = currentSettings.copyWith(
        enableStylePresets: !currentSettings.enableStylePresets,
      );
      state = AsyncValue.data(newSettings);
      debugPrint('✅ 스타일 프리셋 토글: ${newSettings.enableStylePresets}');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 스타일 프리셋 토글 실패: $e');
    }
  }
}

/// 즐겨찾기 스타일 관리 프로바이더
@riverpod
class FavoriteStylesNotifier extends _$FavoriteStylesNotifier {
  @override
  Future<List<String>> build() async {
    final service = ref.read(userCustomizationServiceProvider);
    return service.currentSettings.favoriteStyles;
  }

  /// 즐겨찾기 스타일 추가
  Future<void> addFavoriteStyle(String styleName) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(userCustomizationServiceProvider);
      await service.addFavoriteStyle(styleName);

      final currentFavorites = await future;
      if (!currentFavorites.contains(styleName)) {
        final newFavorites = List<String>.from(currentFavorites)
          ..add(styleName);
        state = AsyncValue.data(newFavorites);
        debugPrint('✅ 즐겨찾기 스타일 추가: $styleName');
      } else {
        state = AsyncValue.data(currentFavorites);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 즐겨찾기 스타일 추가 실패: $e');
    }
  }

  /// 즐겨찾기 스타일 제거
  Future<void> removeFavoriteStyle(String styleName) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(userCustomizationServiceProvider);
      await service.removeFavoriteStyle(styleName);

      final currentFavorites = await future;
      if (currentFavorites.contains(styleName)) {
        final newFavorites = List<String>.from(currentFavorites)
          ..remove(styleName);
        state = AsyncValue.data(newFavorites);
        debugPrint('✅ 즐겨찾기 스타일 제거: $styleName');
      } else {
        state = AsyncValue.data(currentFavorites);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 즐겨찾기 스타일 제거 실패: $e');
    }
  }
}

/// 커스텀 프리셋 관리 프로바이더
@riverpod
class CustomPresetsNotifier extends _$CustomPresetsNotifier {
  @override
  Future<Map<String, dynamic>> build() async {
    final service = ref.read(userCustomizationServiceProvider);
    return service.currentSettings.customPresets;
  }

  /// 커스텀 프리셋 저장
  Future<void> saveCustomPreset(
    String presetName,
    Map<String, dynamic> preset,
  ) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(userCustomizationServiceProvider);
      await service.saveCustomPreset(presetName, preset);

      final currentPresets = await future;
      final newPresets = Map<String, dynamic>.from(currentPresets);
      newPresets[presetName] = {
        ...preset,
        'created_at': DateTime.now().toIso8601String(),
      };
      state = AsyncValue.data(newPresets);
      debugPrint('✅ 커스텀 프리셋 저장: $presetName');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 커스텀 프리셋 저장 실패: $e');
    }
  }

  /// 커스텀 프리셋 삭제
  Future<void> deleteCustomPreset(String presetName) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(userCustomizationServiceProvider);
      await service.deleteCustomPreset(presetName);

      final currentPresets = await future;
      final newPresets = Map<String, dynamic>.from(currentPresets);
      newPresets.remove(presetName);
      state = AsyncValue.data(newPresets);
      debugPrint('✅ 커스텀 프리셋 삭제: $presetName');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 커스텀 프리셋 삭제 실패: $e');
    }
  }

  /// 커스텀 프리셋 적용
  Future<void> applyCustomPreset(String presetName) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(userCustomizationServiceProvider);
      await service.applyCustomPreset(presetName);

      // 설정이 변경되었으므로 설정 프로바이더를 무효화
      ref.invalidate(userCustomizationSettingsNotifierProvider);

      state = const AsyncValue.data({});
      debugPrint('✅ 커스텀 프리셋 적용: $presetName');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 커스텀 프리셋 적용 실패: $e');
    }
  }
}

/// 기본 프리셋 프로바이더
@riverpod
List<Map<String, dynamic>> defaultPresets(DefaultPresetsRef ref) {
  final service = ref.read(userCustomizationServiceProvider);
  return service.getDefaultPresets();
}

/// 사용자 커스터마이징 이력 프로바이더
@riverpod
List<Map<String, dynamic>> userCustomizationHistory(
  UserCustomizationHistoryRef ref,
) {
  final service = ref.read(userCustomizationServiceProvider);
  return service.getCustomizationHistory();
}

/// 사용자 커스터마이징 캐시 관리 프로바이더
@riverpod
class UserCustomizationCacheNotifier extends _$UserCustomizationCacheNotifier {
  @override
  Future<void> build() async {
    // 초기화 시 아무것도 하지 않음
  }

  /// 커스터마이징 이력 초기화
  Future<void> clearHistory() async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(userCustomizationServiceProvider);
      await service.clearHistory();

      state = const AsyncValue.data(null);
      debugPrint('✅ 사용자 커스터마이징 이력 초기화 완료');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 이력 초기화 실패: $e');
    }
  }
}
