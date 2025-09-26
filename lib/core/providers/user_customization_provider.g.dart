// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_customization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userCustomizationServiceHash() =>
    r'8c0a6f285664eff31406b28fc5c4099e46bedeaf';

/// 사용자 커스터마이징 서비스 프로바이더
///
/// Copied from [userCustomizationService].
@ProviderFor(userCustomizationService)
final userCustomizationServiceProvider =
    AutoDisposeProvider<UserCustomizationService>.internal(
      userCustomizationService,
      name: r'userCustomizationServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userCustomizationServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserCustomizationServiceRef =
    AutoDisposeProviderRef<UserCustomizationService>;
String _$userCustomizationInitializationHash() =>
    r'2c8921d3c17cc74b70097dd9cd1139abeb8c9d80';

/// 사용자 커스터마이징 서비스 초기화 프로바이더
///
/// Copied from [userCustomizationInitialization].
@ProviderFor(userCustomizationInitialization)
final userCustomizationInitializationProvider =
    AutoDisposeFutureProvider<void>.internal(
      userCustomizationInitialization,
      name: r'userCustomizationInitializationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userCustomizationInitializationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserCustomizationInitializationRef = AutoDisposeFutureProviderRef<void>;
String _$userCustomizationSettingsHash() =>
    r'5ed257f81b104775a57a9ea9c993141acedf835c';

/// 사용자 커스터마이징 설정 프로바이더
///
/// Copied from [userCustomizationSettings].
@ProviderFor(userCustomizationSettings)
final userCustomizationSettingsProvider =
    AutoDisposeProvider<UserCustomizationSettings>.internal(
      userCustomizationSettings,
      name: r'userCustomizationSettingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userCustomizationSettingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserCustomizationSettingsRef =
    AutoDisposeProviderRef<UserCustomizationSettings>;
String _$defaultPresetsHash() => r'fc21de95ad9a01fc1735059de40d2703564dad7a';

/// 기본 프리셋 프로바이더
///
/// Copied from [defaultPresets].
@ProviderFor(defaultPresets)
final defaultPresetsProvider =
    AutoDisposeProvider<List<Map<String, dynamic>>>.internal(
      defaultPresets,
      name: r'defaultPresetsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$defaultPresetsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DefaultPresetsRef = AutoDisposeProviderRef<List<Map<String, dynamic>>>;
String _$userCustomizationHistoryHash() =>
    r'aab5f771f9752e9b4955c8bb2b2631ed72a853a9';

/// 사용자 커스터마이징 이력 프로바이더
///
/// Copied from [userCustomizationHistory].
@ProviderFor(userCustomizationHistory)
final userCustomizationHistoryProvider =
    AutoDisposeProvider<List<Map<String, dynamic>>>.internal(
      userCustomizationHistory,
      name: r'userCustomizationHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userCustomizationHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserCustomizationHistoryRef =
    AutoDisposeProviderRef<List<Map<String, dynamic>>>;
String _$userCustomizationSettingsNotifierHash() =>
    r'cc4c7a2d5431cf52498b965ade3895997635d3cc';

/// 사용자 커스터마이징 설정 관리 프로바이더
///
/// Copied from [UserCustomizationSettingsNotifier].
@ProviderFor(UserCustomizationSettingsNotifier)
final userCustomizationSettingsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      UserCustomizationSettingsNotifier,
      UserCustomizationSettings
    >.internal(
      UserCustomizationSettingsNotifier.new,
      name: r'userCustomizationSettingsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userCustomizationSettingsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UserCustomizationSettingsNotifier =
    AutoDisposeAsyncNotifier<UserCustomizationSettings>;
String _$favoriteStylesNotifierHash() =>
    r'80ce8b89a805a175281041be2ef44cd94e3ae240';

/// 즐겨찾기 스타일 관리 프로바이더
///
/// Copied from [FavoriteStylesNotifier].
@ProviderFor(FavoriteStylesNotifier)
final favoriteStylesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      FavoriteStylesNotifier,
      List<String>
    >.internal(
      FavoriteStylesNotifier.new,
      name: r'favoriteStylesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$favoriteStylesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FavoriteStylesNotifier = AutoDisposeAsyncNotifier<List<String>>;
String _$customPresetsNotifierHash() =>
    r'a954ffd6af5c5f372efd119e04d768cb2eeee0ff';

/// 커스텀 프리셋 관리 프로바이더
///
/// Copied from [CustomPresetsNotifier].
@ProviderFor(CustomPresetsNotifier)
final customPresetsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      CustomPresetsNotifier,
      Map<String, dynamic>
    >.internal(
      CustomPresetsNotifier.new,
      name: r'customPresetsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$customPresetsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CustomPresetsNotifier =
    AutoDisposeAsyncNotifier<Map<String, dynamic>>;
String _$userCustomizationCacheNotifierHash() =>
    r'1932c09c37d99e321c8d2074c58cba97c43ad905';

/// 사용자 커스터마이징 캐시 관리 프로바이더
///
/// Copied from [UserCustomizationCacheNotifier].
@ProviderFor(UserCustomizationCacheNotifier)
final userCustomizationCacheNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      UserCustomizationCacheNotifier,
      void
    >.internal(
      UserCustomizationCacheNotifier.new,
      name: r'userCustomizationCacheNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userCustomizationCacheNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UserCustomizationCacheNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
