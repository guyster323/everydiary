// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openai_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$openaiServiceHash() => r'192c35953c054315850addbb4482a305c803540c';

/// OpenAI 서비스 프로바이더
///
/// Copied from [openaiService].
@ProviderFor(openaiService)
final openaiServiceProvider = AutoDisposeProvider<OpenAIService>.internal(
  openaiService,
  name: r'openaiServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$openaiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OpenaiServiceRef = AutoDisposeProviderRef<OpenAIService>;
String _$openaiInitializationHash() =>
    r'03ba44e88aa58d686c13bfce67c06d81d4defcb8';

/// OpenAI 서비스 초기화 프로바이더
///
/// Copied from [openaiInitialization].
@ProviderFor(openaiInitialization)
final openaiInitializationProvider = AutoDisposeFutureProvider<void>.internal(
  openaiInitialization,
  name: r'openaiInitializationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$openaiInitializationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OpenaiInitializationRef = AutoDisposeFutureProviderRef<void>;
String _$openaiHasApiKeyHash() => r'28b1af6806c723b02e6eb282260a21506b75a08b';

/// OpenAI API 키 상태 프로바이더
///
/// Copied from [openaiHasApiKey].
@ProviderFor(openaiHasApiKey)
final openaiHasApiKeyProvider = AutoDisposeProvider<bool>.internal(
  openaiHasApiKey,
  name: r'openaiHasApiKeyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$openaiHasApiKeyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OpenaiHasApiKeyRef = AutoDisposeProviderRef<bool>;
String _$openaiIsInitializedHash() =>
    r'eee21093ac93c335869ab9b39d1ca9fedd603390';

/// OpenAI 초기화 상태 프로바이더
///
/// Copied from [openaiIsInitialized].
@ProviderFor(openaiIsInitialized)
final openaiIsInitializedProvider = AutoDisposeProvider<bool>.internal(
  openaiIsInitialized,
  name: r'openaiIsInitializedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$openaiIsInitializedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OpenaiIsInitializedRef = AutoDisposeProviderRef<bool>;
String _$openaiApiUsageStatsHash() =>
    r'34d423494bc7b7c15ed712364336da3af8ca84c5';

/// OpenAI API 사용량 통계 프로바이더
///
/// Copied from [openaiApiUsageStats].
@ProviderFor(openaiApiUsageStats)
final openaiApiUsageStatsProvider =
    AutoDisposeProvider<Map<String, dynamic>>.internal(
      openaiApiUsageStats,
      name: r'openaiApiUsageStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$openaiApiUsageStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OpenaiApiUsageStatsRef = AutoDisposeProviderRef<Map<String, dynamic>>;
String _$openAIImageGenerationNotifierHash() =>
    r'acbff898c971013800dc281e30c12b047384fade';

/// OpenAI 이미지 생성 프로바이더
///
/// Copied from [OpenAIImageGenerationNotifier].
@ProviderFor(OpenAIImageGenerationNotifier)
final openAIImageGenerationNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      OpenAIImageGenerationNotifier,
      Map<String, dynamic>?
    >.internal(
      OpenAIImageGenerationNotifier.new,
      name: r'openAIImageGenerationNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$openAIImageGenerationNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OpenAIImageGenerationNotifier =
    AutoDisposeAsyncNotifier<Map<String, dynamic>?>;
String _$openAITextAnalysisNotifierHash() =>
    r'38e55cdcbe3e13cf55d8c75c4d50c0562cc792ea';

/// OpenAI 텍스트 분석 프로바이더
///
/// Copied from [OpenAITextAnalysisNotifier].
@ProviderFor(OpenAITextAnalysisNotifier)
final openAITextAnalysisNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      OpenAITextAnalysisNotifier,
      Map<String, dynamic>?
    >.internal(
      OpenAITextAnalysisNotifier.new,
      name: r'openAITextAnalysisNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$openAITextAnalysisNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OpenAITextAnalysisNotifier =
    AutoDisposeAsyncNotifier<Map<String, dynamic>?>;
String _$openAIPromptOptimizationNotifierHash() =>
    r'36d6e353fbf64bffcd8dcb4c7d29229f5695fe2d';

/// OpenAI 프롬프트 최적화 프로바이더
///
/// Copied from [OpenAIPromptOptimizationNotifier].
@ProviderFor(OpenAIPromptOptimizationNotifier)
final openAIPromptOptimizationNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      OpenAIPromptOptimizationNotifier,
      String?
    >.internal(
      OpenAIPromptOptimizationNotifier.new,
      name: r'openAIPromptOptimizationNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$openAIPromptOptimizationNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OpenAIPromptOptimizationNotifier = AutoDisposeAsyncNotifier<String?>;
String _$openAIApiKeyNotifierHash() =>
    r'97a02c156dc7338539c8e5afb480b6ad5f9e4102';

/// OpenAI API 키 설정 프로바이더
///
/// Copied from [OpenAIApiKeyNotifier].
@ProviderFor(OpenAIApiKeyNotifier)
final openAIApiKeyNotifierProvider =
    AutoDisposeAsyncNotifierProvider<OpenAIApiKeyNotifier, bool>.internal(
      OpenAIApiKeyNotifier.new,
      name: r'openAIApiKeyNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$openAIApiKeyNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OpenAIApiKeyNotifier = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
