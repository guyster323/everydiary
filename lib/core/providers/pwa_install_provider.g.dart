// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pwa_install_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pwaInstallServiceHash() => r'19f2c744b1f302e4c8ae48230060d6384c7ab129';

/// PWA 설치 서비스 프로바이더
///
/// Copied from [pwaInstallService].
@ProviderFor(pwaInstallService)
final pwaInstallServiceProvider =
    AutoDisposeProvider<PWAInstallService>.internal(
      pwaInstallService,
      name: r'pwaInstallServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pwaInstallServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PwaInstallServiceRef = AutoDisposeProviderRef<PWAInstallService>;
String _$pWAInstallStateHash() => r'c7f2ede2251475e8e7ab3bea0e0483ece850950e';

/// PWA 설치 상태 프로바이더
///
/// Copied from [PWAInstallState].
@ProviderFor(PWAInstallState)
final pWAInstallStateProvider =
    AutoDisposeNotifierProvider<PWAInstallState, PWAInstallStateData>.internal(
      PWAInstallState.new,
      name: r'pWAInstallStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pWAInstallStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PWAInstallState = AutoDisposeNotifier<PWAInstallStateData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
