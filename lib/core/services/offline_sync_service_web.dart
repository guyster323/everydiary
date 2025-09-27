typedef IndexedDBService = Object;

typedef SyncStatus = Object;

typedef OfflineCacheState = Object;

typedef SyncEvent = Object;

typedef SyncEventListener = Object;

/// 오프라인 동기화를 관리하는 서비스 (웹 전용 Stub)
class OfflineSyncService {
  OfflineSyncService(IndexedDBService _);

  bool get isOnline => true;

  bool get isSyncing => false;

  DateTime? get lastSyncTime => null;

  Future<void> initialize() async {}

  Future<void> dispose() async {}

  Future<void> addSyncEventListener(SyncEventListener _) async {}

  Future<void> removeSyncEventListener(SyncEventListener _) async {}

  Future<void> enqueueOfflineData(Map<String, dynamic> _) async {}

  Future<void> processOfflineQueue() async {}

  Future<void> syncNow() async {}
}
