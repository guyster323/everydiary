// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$oCRServiceHash() => r'2c807e7a905f62f63761be9b16bf93f9435916e3';

/// OCR 서비스 프로바이더
///
/// Copied from [OCRService].
@ProviderFor(OCRService)
final oCRServiceProvider =
    AutoDisposeNotifierProvider<OCRService, OCRService>.internal(
      OCRService.new,
      name: r'oCRServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$oCRServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OCRService = AutoDisposeNotifier<OCRService>;
String _$oCRResultStateHash() => r'b63e2148e82233ecf304907a42ace3d3a1a62600';

/// OCR 결과 상태 관리 프로바이더
///
/// Copied from [OCRResultState].
@ProviderFor(OCRResultState)
final oCRResultStateProvider =
    AutoDisposeNotifierProvider<OCRResultState, OCRResult?>.internal(
      OCRResultState.new,
      name: r'oCRResultStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$oCRResultStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OCRResultState = AutoDisposeNotifier<OCRResult?>;
String _$oCRProcessingStateHash() =>
    r'489cd532c21c06a30f652f94c9ba43e3e2eaa89d';

/// OCR 처리 상태 프로바이더
///
/// Copied from [OCRProcessingState].
@ProviderFor(OCRProcessingState)
final oCRProcessingStateProvider =
    AutoDisposeNotifierProvider<OCRProcessingState, bool>.internal(
      OCRProcessingState.new,
      name: r'oCRProcessingStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$oCRProcessingStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OCRProcessingState = AutoDisposeNotifier<bool>;
String _$oCRSettingsHash() => r'abde57c1ffeb956890824403570460454289fc9d';

/// OCR 설정 프로바이더
///
/// Copied from [OCRSettings].
@ProviderFor(OCRSettings)
final oCRSettingsProvider =
    AutoDisposeNotifierProvider<OCRSettings, OCRConfig>.internal(
      OCRSettings.new,
      name: r'oCRSettingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$oCRSettingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OCRSettings = AutoDisposeNotifier<OCRConfig>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
