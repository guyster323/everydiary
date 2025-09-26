import 'dart:async';

import 'package:everydiary/core/services/offline_image_manager_service.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'offline_image_manager_provider.g.dart';

/// 오프라인 이미지 관리 서비스 프로바이더
@riverpod
OfflineImageManagerService offlineImageManagerService(
  OfflineImageManagerServiceRef ref,
) {
  final service = OfflineImageManagerService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// 오프라인 이미지 관리 서비스 초기화 프로바이더
@riverpod
Future<void> offlineImageManagerInitialization(
  OfflineImageManagerInitializationRef ref,
) async {
  final service = ref.read(offlineImageManagerServiceProvider);
  await service.initialize();
}

/// 네트워크 상태 프로바이더
@riverpod
NetworkStatus networkStatus(NetworkStatusRef ref) {
  final service = ref.read(offlineImageManagerServiceProvider);
  return service.currentNetworkStatus;
}

/// 네트워크 상태 스트림 프로바이더
@riverpod
Stream<NetworkStatus> networkStatusStream(NetworkStatusStreamRef ref) {
  final service = ref.read(offlineImageManagerServiceProvider);
  return service.networkStatusStream;
}

/// 오프라인 이미지 목록 프로바이더
@riverpod
List<OfflineImageInfo> offlineImages(OfflineImagesRef ref) {
  final service = ref.read(offlineImageManagerServiceProvider);
  return service.allOfflineImages;
}

/// 기본 이미지 목록 프로바이더
@riverpod
List<OfflineImageInfo> defaultImages(DefaultImagesRef ref) {
  final service = ref.read(offlineImageManagerServiceProvider);
  return service.allDefaultImages;
}

/// 오프라인 이미지 관리 프로바이더
@riverpod
class OfflineImageManagerNotifier extends _$OfflineImageManagerNotifier {
  @override
  Future<List<OfflineImageInfo>> build() async {
    final service = ref.read(offlineImageManagerServiceProvider);
    return service.allOfflineImages;
  }

  /// 오프라인 이미지 저장
  Future<void> saveOfflineImage({
    required String imageUrl,
    required String category,
    required String style,
    required String emotion,
    required String topic,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(offlineImageManagerServiceProvider);
      final imageId = await service.saveOfflineImage(
        imageUrl: imageUrl,
        category: category,
        style: style,
        emotion: emotion,
        topic: topic,
        metadata: metadata,
      );

      if (imageId != null) {
        final updatedImages = service.allOfflineImages;
        state = AsyncValue.data(updatedImages);
        debugPrint('✅ 오프라인 이미지 저장 완료: $imageId');
      } else {
        state = AsyncValue.error('오프라인 이미지 저장에 실패했습니다.', StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 오프라인 이미지 저장 실패: $e');
    }
  }

  /// 오프라인 이미지 가져오기
  Future<OfflineImageInfo?> getOfflineImage(String imageId) async {
    try {
      final service = ref.read(offlineImageManagerServiceProvider);
      final imageInfo = await service.getOfflineImage(imageId);

      if (imageInfo != null) {
        // 이미지 목록 새로고침
        final updatedImages = service.allOfflineImages;
        state = AsyncValue.data(updatedImages);
        debugPrint('✅ 오프라인 이미지 가져오기 완료: $imageId');
      }

      return imageInfo;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 오프라인 이미지 가져오기 실패: $e');
      return null;
    }
  }

  /// 사용하지 않는 이미지 정리
  Future<void> cleanupUnusedImages() async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(offlineImageManagerServiceProvider);
      await service.cleanupUnusedImages();

      final updatedImages = service.allOfflineImages;
      state = AsyncValue.data(updatedImages);
      debugPrint('✅ 사용하지 않는 이미지 정리 완료');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 사용하지 않는 이미지 정리 실패: $e');
    }
  }
}

/// 카테고리별 이미지 프로바이더
@riverpod
List<OfflineImageInfo> imagesByCategory(
  ImagesByCategoryRef ref,
  String category,
) {
  final service = ref.read(offlineImageManagerServiceProvider);
  return service.getImagesByCategory(category);
}

/// 스타일별 이미지 프로바이더
@riverpod
List<OfflineImageInfo> imagesByStyle(ImagesByStyleRef ref, String style) {
  final service = ref.read(offlineImageManagerServiceProvider);
  return service.getImagesByStyle(style);
}

/// 감정별 이미지 프로바이더
@riverpod
List<OfflineImageInfo> imagesByEmotion(ImagesByEmotionRef ref, String emotion) {
  final service = ref.read(offlineImageManagerServiceProvider);
  return service.getImagesByEmotion(emotion);
}

/// 주제별 이미지 프로바이더
@riverpod
List<OfflineImageInfo> imagesByTopic(ImagesByTopicRef ref, String topic) {
  final service = ref.read(offlineImageManagerServiceProvider);
  return service.getImagesByTopic(topic);
}

/// 저장소 통계 프로바이더
@riverpod
class StorageStatsNotifier extends _$StorageStatsNotifier {
  @override
  Future<Map<String, dynamic>> build() async {
    final service = ref.read(offlineImageManagerServiceProvider);
    return await service.getStorageStats();
  }

  /// 저장소 통계 새로고침
  Future<void> refreshStats() async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(offlineImageManagerServiceProvider);
      final stats = await service.getStorageStats();

      state = AsyncValue.data(stats);
      debugPrint('✅ 저장소 통계 새로고침 완료');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 저장소 통계 새로고침 실패: $e');
    }
  }

  /// 저장소 경고 확인
  Future<bool> checkStorageWarning() async {
    try {
      final service = ref.read(offlineImageManagerServiceProvider);
      return await service.checkStorageWarning();
    } catch (e) {
      debugPrint('❌ 저장소 경고 확인 실패: $e');
      return false;
    }
  }
}

/// 오프라인 모드 상태 프로바이더
@riverpod
bool isOfflineMode(IsOfflineModeRef ref) {
  final networkStatus = ref.watch(networkStatusProvider);
  return networkStatus == NetworkStatus.offline;
}

/// 온라인 모드 상태 프로바이더
@riverpod
bool isOnlineMode(IsOnlineModeRef ref) {
  final networkStatus = ref.watch(networkStatusProvider);
  return networkStatus == NetworkStatus.online;
}

/// 네트워크 상태 표시명 프로바이더
@riverpod
String networkStatusDisplayName(NetworkStatusDisplayNameRef ref) {
  final networkStatus = ref.watch(networkStatusProvider);
  return networkStatus.displayName;
}

/// 오프라인 이미지 개수 프로바이더
@riverpod
int offlineImageCount(OfflineImageCountRef ref) {
  final images = ref.watch(offlineImagesProvider);
  return images.length;
}

/// 기본 이미지 개수 프로바이더
@riverpod
int defaultImageCount(DefaultImageCountRef ref) {
  final images = ref.watch(defaultImagesProvider);
  return images.length;
}

/// 총 이미지 개수 프로바이더
@riverpod
int totalImageCount(TotalImageCountRef ref) {
  final offlineCount = ref.watch(offlineImageCountProvider);
  final defaultCount = ref.watch(defaultImageCountProvider);
  return offlineCount + defaultCount;
}
