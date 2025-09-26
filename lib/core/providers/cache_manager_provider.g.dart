// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_manager_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cacheManagerServiceHash() =>
    r'b3cf80d8b4ecec33929d0b1f2d016d34d690a4e0';

/// 캐시 관리 서비스 프로바이더
///
/// Copied from [cacheManagerService].
@ProviderFor(cacheManagerService)
final cacheManagerServiceProvider =
    AutoDisposeProvider<CacheManagerService>.internal(
      cacheManagerService,
      name: r'cacheManagerServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cacheManagerServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CacheManagerServiceRef = AutoDisposeProviderRef<CacheManagerService>;
String _$cacheStatsHash() => r'ebcdda9854eb033485bc90abb9af76c1cdb3aa0a';

/// 캐시 통계 프로바이더
///
/// Copied from [cacheStats].
@ProviderFor(cacheStats)
final cacheStatsProvider = AutoDisposeProvider<Map<String, dynamic>>.internal(
  cacheStats,
  name: r'cacheStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cacheStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CacheStatsRef = AutoDisposeProviderRef<Map<String, dynamic>>;
String _$cacheCategoryStatsHash() =>
    r'b56bef47a81c0986441484853287dc9b5d026943';

/// 캐시 카테고리 통계 프로바이더
///
/// Copied from [cacheCategoryStats].
@ProviderFor(cacheCategoryStats)
final cacheCategoryStatsProvider =
    AutoDisposeProvider<Map<String, dynamic>>.internal(
      cacheCategoryStats,
      name: r'cacheCategoryStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cacheCategoryStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CacheCategoryStatsRef = AutoDisposeProviderRef<Map<String, dynamic>>;
String _$cacheEventsHash() => r'100ccf38753f65086f6171be94f16f9423fe8714';

/// 캐시 이벤트 프로바이더
///
/// Copied from [cacheEvents].
@ProviderFor(cacheEvents)
final cacheEventsProvider =
    AutoDisposeProvider<List<Map<String, dynamic>>>.internal(
      cacheEvents,
      name: r'cacheEventsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cacheEventsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CacheEventsRef = AutoDisposeProviderRef<List<Map<String, dynamic>>>;
String _$cacheItemHash() => r'8490dce435ff3eca5025766f9bd8019cd465d031';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 캐시 항목 프로바이더
///
/// Copied from [cacheItem].
@ProviderFor(cacheItem)
const cacheItemProvider = CacheItemFamily();

/// 캐시 항목 프로바이더
///
/// Copied from [cacheItem].
class CacheItemFamily extends Family<AsyncValue<dynamic>> {
  /// 캐시 항목 프로바이더
  ///
  /// Copied from [cacheItem].
  const CacheItemFamily();

  /// 캐시 항목 프로바이더
  ///
  /// Copied from [cacheItem].
  CacheItemProvider call(String key) {
    return CacheItemProvider(key);
  }

  @override
  CacheItemProvider getProviderOverride(covariant CacheItemProvider provider) {
    return call(provider.key);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cacheItemProvider';
}

/// 캐시 항목 프로바이더
///
/// Copied from [cacheItem].
class CacheItemProvider extends AutoDisposeFutureProvider<dynamic> {
  /// 캐시 항목 프로바이더
  ///
  /// Copied from [cacheItem].
  CacheItemProvider(String key)
    : this._internal(
        (ref) => cacheItem(ref as CacheItemRef, key),
        from: cacheItemProvider,
        name: r'cacheItemProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cacheItemHash,
        dependencies: CacheItemFamily._dependencies,
        allTransitiveDependencies: CacheItemFamily._allTransitiveDependencies,
        key: key,
      );

  CacheItemProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.key,
  }) : super.internal();

  final String key;

  @override
  Override overrideWith(
    FutureOr<dynamic> Function(CacheItemRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CacheItemProvider._internal(
        (ref) => create(ref as CacheItemRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        key: key,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<dynamic> createElement() {
    return _CacheItemProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CacheItemProvider && other.key == key;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, key.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CacheItemRef on AutoDisposeFutureProviderRef<dynamic> {
  /// The parameter `key` of this provider.
  String get key;
}

class _CacheItemProviderElement
    extends AutoDisposeFutureProviderElement<dynamic>
    with CacheItemRef {
  _CacheItemProviderElement(super.provider);

  @override
  String get key => (origin as CacheItemProvider).key;
}

String _$cacheSizeHash() => r'ab8a1a908eabd99e6817f0db48e18e895a6b0cf6';

/// 캐시 크기 프로바이더
///
/// Copied from [cacheSize].
@ProviderFor(cacheSize)
final cacheSizeProvider = AutoDisposeProvider<int>.internal(
  cacheSize,
  name: r'cacheSizeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cacheSizeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CacheSizeRef = AutoDisposeProviderRef<int>;
String _$cacheItemCountHash() => r'25e46a8c82c2d2fee450e1b0e1026af08be2b9e0';

/// 캐시 항목 수 프로바이더
///
/// Copied from [cacheItemCount].
@ProviderFor(cacheItemCount)
final cacheItemCountProvider = AutoDisposeProvider<int>.internal(
  cacheItemCount,
  name: r'cacheItemCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cacheItemCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CacheItemCountRef = AutoDisposeProviderRef<int>;
String _$cacheCategoryCountHash() =>
    r'489092e779ca28120fac526c54969062ff727e7a';

/// 캐시 카테고리 수 프로바이더
///
/// Copied from [cacheCategoryCount].
@ProviderFor(cacheCategoryCount)
final cacheCategoryCountProvider = AutoDisposeProvider<int>.internal(
  cacheCategoryCount,
  name: r'cacheCategoryCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cacheCategoryCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CacheCategoryCountRef = AutoDisposeProviderRef<int>;
String _$cacheUsageRateHash() => r'743eb36fffaf4e9c9bb83561c6dadb9c8a83f190';

/// 캐시 사용률 프로바이더
///
/// Copied from [cacheUsageRate].
@ProviderFor(cacheUsageRate)
final cacheUsageRateProvider = AutoDisposeProvider<double>.internal(
  cacheUsageRate,
  name: r'cacheUsageRateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cacheUsageRateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CacheUsageRateRef = AutoDisposeProviderRef<double>;
String _$cacheStatusHash() => r'24f51bb8382bdd04b3c4ce9160a9c280952f3647';

/// 캐시 상태 프로바이더
///
/// Copied from [cacheStatus].
@ProviderFor(cacheStatus)
final cacheStatusProvider = AutoDisposeProvider<String>.internal(
  cacheStatus,
  name: r'cacheStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cacheStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CacheStatusRef = AutoDisposeProviderRef<String>;
String _$cacheManagerNotifierHash() =>
    r'f3c23bcaf735303576dccf47433d76eb46115805';

/// 캐시 관리자
///
/// Copied from [CacheManagerNotifier].
@ProviderFor(CacheManagerNotifier)
final cacheManagerNotifierProvider =
    AutoDisposeNotifierProvider<
      CacheManagerNotifier,
      Map<String, dynamic>
    >.internal(
      CacheManagerNotifier.new,
      name: r'cacheManagerNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cacheManagerNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CacheManagerNotifier = AutoDisposeNotifier<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
