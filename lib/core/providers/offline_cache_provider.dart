import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/cache_strategy_service.dart';
import '../services/indexed_db_service.dart';
import '../services/offline_sync_service.dart';

/// 동기화 상태 열거형
enum SyncStatus { idle, syncing, pending, failed, completed }

/// 오프라인 캐시 상태
class OfflineCacheState {
  final bool isInitialized;
  final bool isOnline;
  final bool isSyncing;
  final SyncStatus syncStatus;
  final DateTime? lastSyncTime;
  final int pendingCount;
  final int failedCount;
  final int totalCount;
  final int successCount;
  final Map<String, dynamic> cacheStats;
  final Map<String, dynamic> syncStats;

  const OfflineCacheState({
    this.isInitialized = false,
    this.isOnline = true,
    this.isSyncing = false,
    this.syncStatus = SyncStatus.idle,
    this.lastSyncTime,
    this.pendingCount = 0,
    this.failedCount = 0,
    this.totalCount = 0,
    this.successCount = 0,
    this.cacheStats = const {},
    this.syncStats = const {},
  });

  OfflineCacheState copyWith({
    bool? isInitialized,
    bool? isOnline,
    bool? isSyncing,
    SyncStatus? syncStatus,
    DateTime? lastSyncTime,
    int? pendingCount,
    int? failedCount,
    int? totalCount,
    int? successCount,
    Map<String, dynamic>? cacheStats,
    Map<String, dynamic>? syncStats,
  }) {
    return OfflineCacheState(
      isInitialized: isInitialized ?? this.isInitialized,
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      pendingCount: pendingCount ?? this.pendingCount,
      failedCount: failedCount ?? this.failedCount,
      totalCount: totalCount ?? this.totalCount,
      successCount: successCount ?? this.successCount,
      cacheStats: cacheStats ?? this.cacheStats,
      syncStats: syncStats ?? this.syncStats,
    );
  }
}

final offlineCacheNotifierProvider =
    AutoDisposeNotifierProvider<OfflineCacheNotifier, OfflineCacheState>(
      OfflineCacheNotifier.new,
    );

/// 오프라인 캐시 서비스 프로바이더
CacheStrategyService cacheStrategyService(Ref ref) {
  return CacheStrategyService();
}

final cacheStrategyServiceProvider = AutoDisposeProvider<CacheStrategyService>(
  cacheStrategyService,
);

/// IndexedDB 서비스 프로바이더
IndexedDBService indexedDBService(Ref ref) {
  return IndexedDBService();
}

final indexedDBServiceProvider = AutoDisposeProvider<IndexedDBService>(
  indexedDBService,
);

/// 오프라인 동기화 서비스 프로바이더
OfflineSyncService offlineSyncService(Ref ref) {
  final indexedDB = ref.read(indexedDBServiceProvider);
  return OfflineSyncService(indexedDB);
}

final offlineSyncServiceProvider = AutoDisposeProvider<OfflineSyncService>(
  offlineSyncService,
);

/// 오프라인 캐시 상태 관리자
class OfflineCacheNotifier extends AutoDisposeNotifier<OfflineCacheState> {
  @override
  OfflineCacheState build() {
    _initialize();
    return const OfflineCacheState();
  }

  /// 초기화
  Future<void> _initialize() async {
    try {
      debugPrint('🔄 오프라인 캐시 초기화 시작');

      // 서비스들 초기화
      final cacheStrategy = ref.read(cacheStrategyServiceProvider);
      final indexedDB = ref.read(indexedDBServiceProvider);
      final syncService = ref.read(offlineSyncServiceProvider);

      await cacheStrategy.initialize();
      await indexedDB.initialize();
      await syncService.initialize();

      // 초기 상태 업데이트
      await _updateState();

      debugPrint('✅ 오프라인 캐시 초기화 완료');
    } catch (e) {
      debugPrint('❌ 오프라인 캐시 초기화 실패: $e');
    }
  }

  /// 상태 업데이트
  Future<void> _updateState() async {
    try {
      final syncService = ref.read(offlineSyncServiceProvider);
      final cacheStrategy = ref.read(cacheStrategyServiceProvider);

      // 동기화 상태 가져오기
      final syncStatus = await syncService.getSyncStatus();
      final cacheStats = await cacheStrategy.getCacheStats();
      final syncStats = await syncService.getSyncStats();

      // 동기화 상태 결정
      SyncStatus newSyncStatus = SyncStatus.idle;
      if (syncStatus['isSyncing'] == true) {
        newSyncStatus = SyncStatus.syncing;
      } else if ((syncStatus['pendingCount'] as int? ?? 0) > 0) {
        newSyncStatus = SyncStatus.pending;
      } else if ((syncStatus['failedCount'] as int? ?? 0) > 0) {
        newSyncStatus = SyncStatus.failed;
      } else if (syncStatus['lastSyncTime'] != null) {
        newSyncStatus = SyncStatus.completed;
      }

      state = state.copyWith(
        isInitialized: true,
        isOnline: syncStatus['isOnline'] as bool? ?? true,
        isSyncing: syncStatus['isSyncing'] as bool? ?? false,
        syncStatus: newSyncStatus,
        lastSyncTime: syncStatus['lastSyncTime'] != null
            ? DateTime.parse(syncStatus['lastSyncTime'] as String)
            : null,
        pendingCount: syncStatus['pendingCount'] as int? ?? 0,
        failedCount: syncStatus['failedCount'] as int? ?? 0,
        totalCount:
            (syncStatus['pendingCount'] as int? ?? 0) +
            (syncStatus['failedCount'] as int? ?? 0),
        successCount:
            (syncStatus['totalItems'] as int? ?? 0) -
            (syncStatus['pendingCount'] as int? ?? 0) -
            (syncStatus['failedCount'] as int? ?? 0),
        cacheStats: cacheStats,
        syncStats: syncStats,
      );
    } catch (e) {
      debugPrint('❌ 상태 업데이트 실패: $e');
    }
  }

  /// 수동 동기화 실행
  Future<void> syncNow() async {
    try {
      // 동기화 시작 상태로 업데이트
      state = state.copyWith(syncStatus: SyncStatus.syncing, isSyncing: true);

      final syncService = ref.read(offlineSyncServiceProvider);
      await syncService.syncNow();

      // 동기화 완료 후 상태 업데이트
      await _updateState();
    } catch (e) {
      debugPrint('❌ 수동 동기화 실패: $e');
      // 동기화 실패 상태로 업데이트
      state = state.copyWith(syncStatus: SyncStatus.failed, isSyncing: false);
    }
  }

  /// 오프라인 큐에 작업 추가
  Future<void> addToOfflineQueue(String type, Map<String, dynamic> data) async {
    try {
      final syncService = ref.read(offlineSyncServiceProvider);
      await syncService.addToOfflineQueue(type, data);
      await _updateState();
    } catch (e) {
      debugPrint('❌ 오프라인 큐 추가 실패: $e');
    }
  }

  /// 실패한 동기화 재시도
  Future<void> retryFailedSync() async {
    try {
      final syncService = ref.read(offlineSyncServiceProvider);
      await syncService.retryFailedSync();
      await _updateState();
    } catch (e) {
      debugPrint('❌ 실패한 동기화 재시도 실패: $e');
    }
  }

  /// 오프라인 큐 정리
  Future<void> clearOfflineQueue() async {
    try {
      final syncService = ref.read(offlineSyncServiceProvider);
      await syncService.clearOfflineQueue();
      await _updateState();
    } catch (e) {
      debugPrint('❌ 오프라인 큐 정리 실패: $e');
    }
  }

  /// 모든 캐시 삭제
  Future<void> clearAllCaches() async {
    try {
      final cacheStrategy = ref.read(cacheStrategyServiceProvider);
      final indexedDB = ref.read(indexedDBServiceProvider);

      await cacheStrategy.clearAllCaches();
      await indexedDB.clearAllData();

      await _updateState();
    } catch (e) {
      debugPrint('❌ 모든 캐시 삭제 실패: $e');
    }
  }

  /// 상태 새로고침
  Future<void> refresh() async {
    await _updateState();
  }
}

/// 오프라인 캐시 프로바이더
final offlineCacheProvider = AutoDisposeProvider<OfflineCacheState>(
  (ref) => ref.watch(offlineCacheNotifierProvider),
);

/// 오프라인 캐시 초기화 프로바이더
final offlineCacheInitializationProvider = FutureProvider<void>((ref) async {
  final notifier = ref.read(offlineCacheNotifierProvider.notifier);
  await notifier._initialize();
});

/// 온라인 상태 프로바이더
final onlineStatusProvider = AutoDisposeProvider<bool>((ref) {
  final cache = ref.watch(offlineCacheProvider);
  return cache.isOnline;
});

/// 동기화 상태 프로바이더
final syncStatusProvider = AutoDisposeProvider<SyncStatus>((ref) {
  final cache = ref.watch(offlineCacheProvider);
  return cache.syncStatus;
});

/// 오프라인 큐 상태 프로바이더
final offlineQueueStatusProvider = AutoDisposeProvider<Map<String, int>>((ref) {
  final cache = ref.watch(offlineCacheProvider);
  return {'pending': cache.pendingCount, 'failed': cache.failedCount};
});
