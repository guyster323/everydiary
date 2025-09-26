// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_analysis_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$textAnalysisServiceHash() =>
    r'827b33536f87d5bfcb7f080e589cd742815d54ae';

/// 텍스트 분석 서비스 프로바이더
///
/// Copied from [textAnalysisService].
@ProviderFor(textAnalysisService)
final textAnalysisServiceProvider =
    AutoDisposeProvider<TextAnalysisService>.internal(
      textAnalysisService,
      name: r'textAnalysisServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$textAnalysisServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TextAnalysisServiceRef = AutoDisposeProviderRef<TextAnalysisService>;
String _$textAnalysisInitializationHash() =>
    r'8ab3effdf1eec0de45f51c195838e349d06ee5a2';

/// 텍스트 분석 서비스 초기화 프로바이더
///
/// Copied from [textAnalysisInitialization].
@ProviderFor(textAnalysisInitialization)
final textAnalysisInitializationProvider =
    AutoDisposeFutureProvider<void>.internal(
      textAnalysisInitialization,
      name: r'textAnalysisInitializationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$textAnalysisInitializationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TextAnalysisInitializationRef = AutoDisposeFutureProviderRef<void>;
String _$textAnalysisHistoryHash() =>
    r'89d261bf348dfbc417330d3dcfa43aed5910e4db';

/// 텍스트 분석 이력 프로바이더
///
/// Copied from [textAnalysisHistory].
@ProviderFor(textAnalysisHistory)
final textAnalysisHistoryProvider =
    AutoDisposeProvider<List<Map<String, dynamic>>>.internal(
      textAnalysisHistory,
      name: r'textAnalysisHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$textAnalysisHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TextAnalysisHistoryRef =
    AutoDisposeProviderRef<List<Map<String, dynamic>>>;
String _$textAnalysisNotifierHash() =>
    r'7de4167215b70c103fde38dfc068057d6bb7746e';

/// 텍스트 분석 결과 프로바이더
///
/// Copied from [TextAnalysisNotifier].
@ProviderFor(TextAnalysisNotifier)
final textAnalysisNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      TextAnalysisNotifier,
      TextAnalysisResult?
    >.internal(
      TextAnalysisNotifier.new,
      name: r'textAnalysisNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$textAnalysisNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TextAnalysisNotifier = AutoDisposeAsyncNotifier<TextAnalysisResult?>;
String _$textAnalysisCacheNotifierHash() =>
    r'a9be07139e97801535a80ab0a80d11187c45481b';

/// 텍스트 분석 캐시 관리 프로바이더
///
/// Copied from [TextAnalysisCacheNotifier].
@ProviderFor(TextAnalysisCacheNotifier)
final textAnalysisCacheNotifierProvider =
    AutoDisposeAsyncNotifierProvider<TextAnalysisCacheNotifier, void>.internal(
      TextAnalysisCacheNotifier.new,
      name: r'textAnalysisCacheNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$textAnalysisCacheNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TextAnalysisCacheNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
