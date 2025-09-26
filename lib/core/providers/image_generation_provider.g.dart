// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_generation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imageGenerationServiceHash() =>
    r'08196bf69ee00578a6ac7c0edc83f0c75a6b3f28';

/// 이미지 생성 서비스 프로바이더
///
/// Copied from [imageGenerationService].
@ProviderFor(imageGenerationService)
final imageGenerationServiceProvider =
    AutoDisposeProvider<ImageGenerationService>.internal(
      imageGenerationService,
      name: r'imageGenerationServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$imageGenerationServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ImageGenerationServiceRef =
    AutoDisposeProviderRef<ImageGenerationService>;
String _$imageGenerationInitializationHash() =>
    r'b98a7633ad65de4b2e9648ad4418852ae7c4ca42';

/// 이미지 생성 서비스 초기화 프로바이더
///
/// Copied from [imageGenerationInitialization].
@ProviderFor(imageGenerationInitialization)
final imageGenerationInitializationProvider =
    AutoDisposeFutureProvider<void>.internal(
      imageGenerationInitialization,
      name: r'imageGenerationInitializationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$imageGenerationInitializationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ImageGenerationInitializationRef = AutoDisposeFutureProviderRef<void>;
String _$imageGenerationHistoryHash() =>
    r'f701334a600714adec0f8b016470341773f2fbbf';

/// 이미지 생성 이력 프로바이더
///
/// Copied from [imageGenerationHistory].
@ProviderFor(imageGenerationHistory)
final imageGenerationHistoryProvider =
    AutoDisposeProvider<List<Map<String, dynamic>>>.internal(
      imageGenerationHistory,
      name: r'imageGenerationHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$imageGenerationHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ImageGenerationHistoryRef =
    AutoDisposeProviderRef<List<Map<String, dynamic>>>;
String _$imageGenerationNotifierHash() =>
    r'efc750588122171f2726f3e370a694e3622dca76';

/// 이미지 생성 결과 프로바이더
///
/// Copied from [ImageGenerationNotifier].
@ProviderFor(ImageGenerationNotifier)
final imageGenerationNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      ImageGenerationNotifier,
      ImageGenerationResult?
    >.internal(
      ImageGenerationNotifier.new,
      name: r'imageGenerationNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$imageGenerationNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ImageGenerationNotifier =
    AutoDisposeAsyncNotifier<ImageGenerationResult?>;
String _$imageGenerationCacheNotifierHash() =>
    r'b07a84f87bacbdd18012e0b61242c671019ec35f';

/// 이미지 생성 캐시 관리 프로바이더
///
/// Copied from [ImageGenerationCacheNotifier].
@ProviderFor(ImageGenerationCacheNotifier)
final imageGenerationCacheNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      ImageGenerationCacheNotifier,
      void
    >.internal(
      ImageGenerationCacheNotifier.new,
      name: r'imageGenerationCacheNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$imageGenerationCacheNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ImageGenerationCacheNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
