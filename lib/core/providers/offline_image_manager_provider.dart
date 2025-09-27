import 'package:everydiary/core/services/offline_image_manager_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final offlineImageManagerServiceProvider =
    AutoDisposeProvider<OfflineImageManagerService>((ref) {
      final service = OfflineImageManagerService();
      ref.onDispose(service.dispose);
      return service;
    });

final offlineImageManagerInitializationProvider =
    AutoDisposeFutureProvider<void>((ref) async {
      final service = ref.read(offlineImageManagerServiceProvider);
      await service.initialize();
    });

final networkStatusProvider = Provider.autoDispose<NetworkStatus>((ref) {
  final service = ref.read(offlineImageManagerServiceProvider);
  return service.currentNetworkStatus;
});

final networkStatusStreamProvider = AutoDisposeStreamProvider<NetworkStatus>((
  ref,
) {
  final service = ref.read(offlineImageManagerServiceProvider);
  return service.networkStatusStream;
});

final offlineImagesProvider = Provider.autoDispose<List<OfflineImageInfo>>((
  ref,
) {
  final service = ref.read(offlineImageManagerServiceProvider);
  return service.allOfflineImages;
});

final defaultImagesProvider = Provider.autoDispose<List<OfflineImageInfo>>((
  ref,
) {
  final service = ref.read(offlineImageManagerServiceProvider);
  return service.allDefaultImages;
});

class OfflineImageManagerNotifier
    extends AutoDisposeAsyncNotifier<List<OfflineImageInfo>> {
  @override
  Future<List<OfflineImageInfo>> build() async {
    final service = ref.read(offlineImageManagerServiceProvider);
    return service.allOfflineImages;
  }

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
        state = AsyncValue.data(service.allOfflineImages);
        debugPrint('✅ 오프라인 이미지 저장 완료: $imageId');
      } else {
        state = AsyncValue.error('오프라인 이미지 저장에 실패했습니다.', StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 오프라인 이미지 저장 실패: $e');
    }
  }

  Future<OfflineImageInfo?> getOfflineImage(String imageId) async {
    try {
      final service = ref.read(offlineImageManagerServiceProvider);
      final imageInfo = await service.getOfflineImage(imageId);

      if (imageInfo != null) {
        state = AsyncValue.data(service.allOfflineImages);
        debugPrint('✅ 오프라인 이미지 가져오기 완료: $imageId');
      }

      return imageInfo;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 오프라인 이미지 가져오기 실패: $e');
      return null;
    }
  }

  Future<void> cleanupUnusedImages() async {
    try {
      state = const AsyncValue.loading();

      final service = ref.read(offlineImageManagerServiceProvider);
      await service.cleanupUnusedImages();

      state = AsyncValue.data(service.allOfflineImages);
      debugPrint('✅ 사용하지 않는 이미지 정리 완료');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('❌ 사용하지 않는 이미지 정리 실패: $e');
    }
  }
}

final offlineImageManagerNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      OfflineImageManagerNotifier,
      List<OfflineImageInfo>
    >(OfflineImageManagerNotifier.new);

final imagesByCategoryProvider = Provider.autoDispose
    .family<List<OfflineImageInfo>, String>((ref, category) {
      final service = ref.read(offlineImageManagerServiceProvider);
      return service.getImagesByCategory(category);
    });

final imagesByStyleProvider = Provider.autoDispose
    .family<List<OfflineImageInfo>, String>((ref, style) {
      final service = ref.read(offlineImageManagerServiceProvider);
      return service.getImagesByStyle(style);
    });

final imagesByEmotionProvider = Provider.autoDispose
    .family<List<OfflineImageInfo>, String>((ref, emotion) {
      final service = ref.read(offlineImageManagerServiceProvider);
      return service.getImagesByEmotion(emotion);
    });

final imagesByTopicProvider = Provider.autoDispose
    .family<List<OfflineImageInfo>, String>((ref, topic) {
      final service = ref.read(offlineImageManagerServiceProvider);
      return service.getImagesByTopic(topic);
    });

class StorageStatsNotifier
    extends AutoDisposeAsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    final service = ref.read(offlineImageManagerServiceProvider);
    return service.getStorageStats();
  }

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

final storageStatsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      StorageStatsNotifier,
      Map<String, dynamic>
    >(StorageStatsNotifier.new);

final isOfflineModeProvider = Provider.autoDispose<bool>((ref) {
  final networkStatus = ref.watch(networkStatusProvider);
  return networkStatus == NetworkStatus.offline;
});

final isOnlineModeProvider = Provider.autoDispose<bool>((ref) {
  final networkStatus = ref.watch(networkStatusProvider);
  return networkStatus == NetworkStatus.online;
});

final networkStatusDisplayNameProvider = Provider.autoDispose<String>((ref) {
  final networkStatus = ref.watch(networkStatusProvider);
  return networkStatus.displayName;
});

final offlineImageCountProvider = Provider.autoDispose<int>((ref) {
  final images = ref.watch(offlineImagesProvider);
  return images.length;
});

final defaultImageCountProvider = Provider.autoDispose<int>((ref) {
  final images = ref.watch(defaultImagesProvider);
  return images.length;
});

final totalImageCountProvider = Provider.autoDispose<int>((ref) {
  final offlineCount = ref.watch(offlineImageCountProvider);
  final defaultCount = ref.watch(defaultImageCountProvider);
  return offlineCount + defaultCount;
});
