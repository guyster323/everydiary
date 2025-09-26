// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_cache_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cacheStrategyServiceHash() =>
    r'e1b1e0ba42d0a1f301933b6952452f90f880a5b2';

/// 오프라인 캐시 서비스 프로바이더
///
/// Copied from [cacheStrategyService].
@ProviderFor(cacheStrategyService)
final cacheStrategyServiceProvider =
    AutoDisposeProvider<CacheStrategyService>.internal(
      cacheStrategyService,
      name: r'cacheStrategyServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cacheStrategyServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CacheStrategyServiceRef = AutoDisposeProviderRef<CacheStrategyService>;
String _$indexedDBServiceHash() => r'b64fa2cd966b590072bb393eaa4581b34e820f42';

/// IndexedDB 서비스 프로바이더
///
/// Copied from [indexedDBService].
@ProviderFor(indexedDBService)
final indexedDBServiceProvider = AutoDisposeProvider<IndexedDBService>.internal(
  indexedDBService,
  name: r'indexedDBServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$indexedDBServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IndexedDBServiceRef = AutoDisposeProviderRef<IndexedDBService>;
String _$offlineSyncServiceHash() =>
    r'01b47d722fa7cc118b6ae090d87a2a45d1a2c936';

/// 오프라인 동기화 서비스 프로바이더
///
/// Copied from [offlineSyncService].
@ProviderFor(offlineSyncService)
final offlineSyncServiceProvider =
    AutoDisposeProvider<OfflineSyncService>.internal(
      offlineSyncService,
      name: r'offlineSyncServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$offlineSyncServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfflineSyncServiceRef = AutoDisposeProviderRef<OfflineSyncService>;
String _$offlineCacheHash() => r'5d856f8f72c065e67d987834cd3ff80bcfa36362';

/// 오프라인 캐시 프로바이더
///
/// Copied from [offlineCache].
@ProviderFor(offlineCache)
final offlineCacheProvider = AutoDisposeProvider<OfflineCacheState>.internal(
  offlineCache,
  name: r'offlineCacheProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$offlineCacheHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfflineCacheRef = AutoDisposeProviderRef<OfflineCacheState>;
String _$offlineCacheInitializationHash() =>
    r'910c25bdafed673e46f5b397935df71675974bb0';

/// 오프라인 캐시 초기화 프로바이더
///
/// Copied from [offlineCacheInitialization].
@ProviderFor(offlineCacheInitialization)
final offlineCacheInitializationProvider =
    AutoDisposeFutureProvider<void>.internal(
      offlineCacheInitialization,
      name: r'offlineCacheInitializationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$offlineCacheInitializationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfflineCacheInitializationRef = AutoDisposeFutureProviderRef<void>;
String _$onlineStatusHash() => r'3364f4ddc84839b0a876f6b689e141abaaa65b92';

/// 온라인 상태 프로바이더
///
/// Copied from [onlineStatus].
@ProviderFor(onlineStatus)
final onlineStatusProvider = AutoDisposeProvider<bool>.internal(
  onlineStatus,
  name: r'onlineStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onlineStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnlineStatusRef = AutoDisposeProviderRef<bool>;
String _$syncStatusHash() => r'8166f3a7e290fef5e308ae5e9adfb65cfe74a17e';

/// 동기화 상태 프로바이더
///
/// Copied from [syncStatus].
@ProviderFor(syncStatus)
final syncStatusProvider = AutoDisposeProvider<SyncStatus>.internal(
  syncStatus,
  name: r'syncStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncStatusRef = AutoDisposeProviderRef<SyncStatus>;
String _$offlineQueueStatusHash() =>
    r'92c149dbf8ab20fba26b28828b56aae3a5992e57';

/// 오프라인 큐 상태 프로바이더
///
/// Copied from [offlineQueueStatus].
@ProviderFor(offlineQueueStatus)
final offlineQueueStatusProvider =
    AutoDisposeProvider<Map<String, int>>.internal(
      offlineQueueStatus,
      name: r'offlineQueueStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$offlineQueueStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfflineQueueStatusRef = AutoDisposeProviderRef<Map<String, int>>;
String _$offlineCacheNotifierHash() =>
    r'7b6c82821996777ca6a534473dad13ba617ac7b7';

/// 오프라인 캐시 상태 관리자
///
/// Copied from [OfflineCacheNotifier].
@ProviderFor(OfflineCacheNotifier)
final offlineCacheNotifierProvider =
    AutoDisposeNotifierProvider<
      OfflineCacheNotifier,
      OfflineCacheState
    >.internal(
      OfflineCacheNotifier.new,
      name: r'offlineCacheNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$offlineCacheNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OfflineCacheNotifier = AutoDisposeNotifier<OfflineCacheState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
