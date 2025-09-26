// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_optimization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$backgroundOptimizationServiceHash() =>
    r'd5db5ef8ce3eea042743aacb27ac1c4292028cf8';

/// 배경 최적화 서비스 프로바이더
///
/// Copied from [backgroundOptimizationService].
@ProviderFor(backgroundOptimizationService)
final backgroundOptimizationServiceProvider =
    AutoDisposeProvider<BackgroundOptimizationService>.internal(
      backgroundOptimizationService,
      name: r'backgroundOptimizationServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$backgroundOptimizationServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BackgroundOptimizationServiceRef =
    AutoDisposeProviderRef<BackgroundOptimizationService>;
String _$backgroundOptimizationInitializationHash() =>
    r'c1d37cd4287e14482a044af5b0d9865c40e16983';

/// 배경 최적화 서비스 초기화 프로바이더
///
/// Copied from [backgroundOptimizationInitialization].
@ProviderFor(backgroundOptimizationInitialization)
final backgroundOptimizationInitializationProvider =
    AutoDisposeFutureProvider<void>.internal(
      backgroundOptimizationInitialization,
      name: r'backgroundOptimizationInitializationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$backgroundOptimizationInitializationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BackgroundOptimizationInitializationRef =
    AutoDisposeFutureProviderRef<void>;
String _$backgroundOptimizationSettingsHash() =>
    r'f7d554ca64681e3de06a185b11ac48304ec37e61';

/// 배경 최적화 설정 프로바이더
///
/// Copied from [backgroundOptimizationSettings].
@ProviderFor(backgroundOptimizationSettings)
final backgroundOptimizationSettingsProvider =
    AutoDisposeProvider<BackgroundOptimizationSettings>.internal(
      backgroundOptimizationSettings,
      name: r'backgroundOptimizationSettingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$backgroundOptimizationSettingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BackgroundOptimizationSettingsRef =
    AutoDisposeProviderRef<BackgroundOptimizationSettings>;
String _$backgroundOptimizationHistoryHash() =>
    r'9a0dd69c2fb2e4c94f56e87842ebe5bef5abdb70';

/// 배경 최적화 이력 프로바이더
///
/// Copied from [backgroundOptimizationHistory].
@ProviderFor(backgroundOptimizationHistory)
final backgroundOptimizationHistoryProvider =
    AutoDisposeProvider<List<Map<String, dynamic>>>.internal(
      backgroundOptimizationHistory,
      name: r'backgroundOptimizationHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$backgroundOptimizationHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BackgroundOptimizationHistoryRef =
    AutoDisposeProviderRef<List<Map<String, dynamic>>>;
String _$backgroundOptimizationNotifierHash() =>
    r'3d7ffd1ff9a1dee15d77ae15801fea4af7448518';

/// 배경 최적화 결과 프로바이더
///
/// Copied from [BackgroundOptimizationNotifier].
@ProviderFor(BackgroundOptimizationNotifier)
final backgroundOptimizationNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      BackgroundOptimizationNotifier,
      Map<String, dynamic>?
    >.internal(
      BackgroundOptimizationNotifier.new,
      name: r'backgroundOptimizationNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$backgroundOptimizationNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BackgroundOptimizationNotifier =
    AutoDisposeAsyncNotifier<Map<String, dynamic>?>;
String _$backgroundOptimizationSettingsNotifierHash() =>
    r'91aed9c09e6e0452f539bb2fa8a6cc99ee981bf3';

/// 배경 최적화 설정 관리 프로바이더
///
/// Copied from [BackgroundOptimizationSettingsNotifier].
@ProviderFor(BackgroundOptimizationSettingsNotifier)
final backgroundOptimizationSettingsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      BackgroundOptimizationSettingsNotifier,
      BackgroundOptimizationSettings
    >.internal(
      BackgroundOptimizationSettingsNotifier.new,
      name: r'backgroundOptimizationSettingsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$backgroundOptimizationSettingsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BackgroundOptimizationSettingsNotifier =
    AutoDisposeAsyncNotifier<BackgroundOptimizationSettings>;
String _$backgroundOptimizationCacheNotifierHash() =>
    r'1f9e645cf60b406ea0b2be04d064c4116f8e1378';

/// 배경 최적화 캐시 관리 프로바이더
///
/// Copied from [BackgroundOptimizationCacheNotifier].
@ProviderFor(BackgroundOptimizationCacheNotifier)
final backgroundOptimizationCacheNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      BackgroundOptimizationCacheNotifier,
      void
    >.internal(
      BackgroundOptimizationCacheNotifier.new,
      name: r'backgroundOptimizationCacheNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$backgroundOptimizationCacheNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BackgroundOptimizationCacheNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
