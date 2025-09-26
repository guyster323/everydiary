// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_image_manager_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$offlineImageManagerServiceHash() =>
    r'38a2274aee70e34bae3d3082afbd3225582b3215';

/// 오프라인 이미지 관리 서비스 프로바이더
///
/// Copied from [offlineImageManagerService].
@ProviderFor(offlineImageManagerService)
final offlineImageManagerServiceProvider =
    AutoDisposeProvider<OfflineImageManagerService>.internal(
      offlineImageManagerService,
      name: r'offlineImageManagerServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$offlineImageManagerServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfflineImageManagerServiceRef =
    AutoDisposeProviderRef<OfflineImageManagerService>;
String _$offlineImageManagerInitializationHash() =>
    r'32fe60ccfdac8caec4caca71be9a89979702b783';

/// 오프라인 이미지 관리 서비스 초기화 프로바이더
///
/// Copied from [offlineImageManagerInitialization].
@ProviderFor(offlineImageManagerInitialization)
final offlineImageManagerInitializationProvider =
    AutoDisposeFutureProvider<void>.internal(
      offlineImageManagerInitialization,
      name: r'offlineImageManagerInitializationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$offlineImageManagerInitializationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfflineImageManagerInitializationRef =
    AutoDisposeFutureProviderRef<void>;
String _$networkStatusHash() => r'19241e44a8e952c8858d2e18ee02bb18da469526';

/// 네트워크 상태 프로바이더
///
/// Copied from [networkStatus].
@ProviderFor(networkStatus)
final networkStatusProvider = AutoDisposeProvider<NetworkStatus>.internal(
  networkStatus,
  name: r'networkStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$networkStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NetworkStatusRef = AutoDisposeProviderRef<NetworkStatus>;
String _$networkStatusStreamHash() =>
    r'c98409c5fda228cce01a96fe16cf21dde0111ede';

/// 네트워크 상태 스트림 프로바이더
///
/// Copied from [networkStatusStream].
@ProviderFor(networkStatusStream)
final networkStatusStreamProvider =
    AutoDisposeStreamProvider<NetworkStatus>.internal(
      networkStatusStream,
      name: r'networkStatusStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$networkStatusStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NetworkStatusStreamRef = AutoDisposeStreamProviderRef<NetworkStatus>;
String _$offlineImagesHash() => r'a0d5ca2bf83b1e0edf74fd042efa9b96ba055df4';

/// 오프라인 이미지 목록 프로바이더
///
/// Copied from [offlineImages].
@ProviderFor(offlineImages)
final offlineImagesProvider =
    AutoDisposeProvider<List<OfflineImageInfo>>.internal(
      offlineImages,
      name: r'offlineImagesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$offlineImagesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfflineImagesRef = AutoDisposeProviderRef<List<OfflineImageInfo>>;
String _$defaultImagesHash() => r'090debe9ce80745a3ec09456a12b5e526c63e784';

/// 기본 이미지 목록 프로바이더
///
/// Copied from [defaultImages].
@ProviderFor(defaultImages)
final defaultImagesProvider =
    AutoDisposeProvider<List<OfflineImageInfo>>.internal(
      defaultImages,
      name: r'defaultImagesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$defaultImagesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DefaultImagesRef = AutoDisposeProviderRef<List<OfflineImageInfo>>;
String _$imagesByCategoryHash() => r'889ef91e00a7f4a01b894957b030b5e710a5b853';

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

/// 카테고리별 이미지 프로바이더
///
/// Copied from [imagesByCategory].
@ProviderFor(imagesByCategory)
const imagesByCategoryProvider = ImagesByCategoryFamily();

/// 카테고리별 이미지 프로바이더
///
/// Copied from [imagesByCategory].
class ImagesByCategoryFamily extends Family<List<OfflineImageInfo>> {
  /// 카테고리별 이미지 프로바이더
  ///
  /// Copied from [imagesByCategory].
  const ImagesByCategoryFamily();

  /// 카테고리별 이미지 프로바이더
  ///
  /// Copied from [imagesByCategory].
  ImagesByCategoryProvider call(String category) {
    return ImagesByCategoryProvider(category);
  }

  @override
  ImagesByCategoryProvider getProviderOverride(
    covariant ImagesByCategoryProvider provider,
  ) {
    return call(provider.category);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'imagesByCategoryProvider';
}

/// 카테고리별 이미지 프로바이더
///
/// Copied from [imagesByCategory].
class ImagesByCategoryProvider
    extends AutoDisposeProvider<List<OfflineImageInfo>> {
  /// 카테고리별 이미지 프로바이더
  ///
  /// Copied from [imagesByCategory].
  ImagesByCategoryProvider(String category)
    : this._internal(
        (ref) => imagesByCategory(ref as ImagesByCategoryRef, category),
        from: imagesByCategoryProvider,
        name: r'imagesByCategoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$imagesByCategoryHash,
        dependencies: ImagesByCategoryFamily._dependencies,
        allTransitiveDependencies:
            ImagesByCategoryFamily._allTransitiveDependencies,
        category: category,
      );

  ImagesByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
  }) : super.internal();

  final String category;

  @override
  Override overrideWith(
    List<OfflineImageInfo> Function(ImagesByCategoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ImagesByCategoryProvider._internal(
        (ref) => create(ref as ImagesByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<OfflineImageInfo>> createElement() {
    return _ImagesByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ImagesByCategoryProvider && other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ImagesByCategoryRef on AutoDisposeProviderRef<List<OfflineImageInfo>> {
  /// The parameter `category` of this provider.
  String get category;
}

class _ImagesByCategoryProviderElement
    extends AutoDisposeProviderElement<List<OfflineImageInfo>>
    with ImagesByCategoryRef {
  _ImagesByCategoryProviderElement(super.provider);

  @override
  String get category => (origin as ImagesByCategoryProvider).category;
}

String _$imagesByStyleHash() => r'7638f5bf4e5e580e3b9b0aa21494c0877377e77e';

/// 스타일별 이미지 프로바이더
///
/// Copied from [imagesByStyle].
@ProviderFor(imagesByStyle)
const imagesByStyleProvider = ImagesByStyleFamily();

/// 스타일별 이미지 프로바이더
///
/// Copied from [imagesByStyle].
class ImagesByStyleFamily extends Family<List<OfflineImageInfo>> {
  /// 스타일별 이미지 프로바이더
  ///
  /// Copied from [imagesByStyle].
  const ImagesByStyleFamily();

  /// 스타일별 이미지 프로바이더
  ///
  /// Copied from [imagesByStyle].
  ImagesByStyleProvider call(String style) {
    return ImagesByStyleProvider(style);
  }

  @override
  ImagesByStyleProvider getProviderOverride(
    covariant ImagesByStyleProvider provider,
  ) {
    return call(provider.style);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'imagesByStyleProvider';
}

/// 스타일별 이미지 프로바이더
///
/// Copied from [imagesByStyle].
class ImagesByStyleProvider
    extends AutoDisposeProvider<List<OfflineImageInfo>> {
  /// 스타일별 이미지 프로바이더
  ///
  /// Copied from [imagesByStyle].
  ImagesByStyleProvider(String style)
    : this._internal(
        (ref) => imagesByStyle(ref as ImagesByStyleRef, style),
        from: imagesByStyleProvider,
        name: r'imagesByStyleProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$imagesByStyleHash,
        dependencies: ImagesByStyleFamily._dependencies,
        allTransitiveDependencies:
            ImagesByStyleFamily._allTransitiveDependencies,
        style: style,
      );

  ImagesByStyleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.style,
  }) : super.internal();

  final String style;

  @override
  Override overrideWith(
    List<OfflineImageInfo> Function(ImagesByStyleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ImagesByStyleProvider._internal(
        (ref) => create(ref as ImagesByStyleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        style: style,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<OfflineImageInfo>> createElement() {
    return _ImagesByStyleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ImagesByStyleProvider && other.style == style;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, style.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ImagesByStyleRef on AutoDisposeProviderRef<List<OfflineImageInfo>> {
  /// The parameter `style` of this provider.
  String get style;
}

class _ImagesByStyleProviderElement
    extends AutoDisposeProviderElement<List<OfflineImageInfo>>
    with ImagesByStyleRef {
  _ImagesByStyleProviderElement(super.provider);

  @override
  String get style => (origin as ImagesByStyleProvider).style;
}

String _$imagesByEmotionHash() => r'8768f65d68166dab5557430b6e43b6afc09c2f42';

/// 감정별 이미지 프로바이더
///
/// Copied from [imagesByEmotion].
@ProviderFor(imagesByEmotion)
const imagesByEmotionProvider = ImagesByEmotionFamily();

/// 감정별 이미지 프로바이더
///
/// Copied from [imagesByEmotion].
class ImagesByEmotionFamily extends Family<List<OfflineImageInfo>> {
  /// 감정별 이미지 프로바이더
  ///
  /// Copied from [imagesByEmotion].
  const ImagesByEmotionFamily();

  /// 감정별 이미지 프로바이더
  ///
  /// Copied from [imagesByEmotion].
  ImagesByEmotionProvider call(String emotion) {
    return ImagesByEmotionProvider(emotion);
  }

  @override
  ImagesByEmotionProvider getProviderOverride(
    covariant ImagesByEmotionProvider provider,
  ) {
    return call(provider.emotion);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'imagesByEmotionProvider';
}

/// 감정별 이미지 프로바이더
///
/// Copied from [imagesByEmotion].
class ImagesByEmotionProvider
    extends AutoDisposeProvider<List<OfflineImageInfo>> {
  /// 감정별 이미지 프로바이더
  ///
  /// Copied from [imagesByEmotion].
  ImagesByEmotionProvider(String emotion)
    : this._internal(
        (ref) => imagesByEmotion(ref as ImagesByEmotionRef, emotion),
        from: imagesByEmotionProvider,
        name: r'imagesByEmotionProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$imagesByEmotionHash,
        dependencies: ImagesByEmotionFamily._dependencies,
        allTransitiveDependencies:
            ImagesByEmotionFamily._allTransitiveDependencies,
        emotion: emotion,
      );

  ImagesByEmotionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.emotion,
  }) : super.internal();

  final String emotion;

  @override
  Override overrideWith(
    List<OfflineImageInfo> Function(ImagesByEmotionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ImagesByEmotionProvider._internal(
        (ref) => create(ref as ImagesByEmotionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        emotion: emotion,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<OfflineImageInfo>> createElement() {
    return _ImagesByEmotionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ImagesByEmotionProvider && other.emotion == emotion;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, emotion.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ImagesByEmotionRef on AutoDisposeProviderRef<List<OfflineImageInfo>> {
  /// The parameter `emotion` of this provider.
  String get emotion;
}

class _ImagesByEmotionProviderElement
    extends AutoDisposeProviderElement<List<OfflineImageInfo>>
    with ImagesByEmotionRef {
  _ImagesByEmotionProviderElement(super.provider);

  @override
  String get emotion => (origin as ImagesByEmotionProvider).emotion;
}

String _$imagesByTopicHash() => r'594360a100d48baf0ccac5846f234244f94449c5';

/// 주제별 이미지 프로바이더
///
/// Copied from [imagesByTopic].
@ProviderFor(imagesByTopic)
const imagesByTopicProvider = ImagesByTopicFamily();

/// 주제별 이미지 프로바이더
///
/// Copied from [imagesByTopic].
class ImagesByTopicFamily extends Family<List<OfflineImageInfo>> {
  /// 주제별 이미지 프로바이더
  ///
  /// Copied from [imagesByTopic].
  const ImagesByTopicFamily();

  /// 주제별 이미지 프로바이더
  ///
  /// Copied from [imagesByTopic].
  ImagesByTopicProvider call(String topic) {
    return ImagesByTopicProvider(topic);
  }

  @override
  ImagesByTopicProvider getProviderOverride(
    covariant ImagesByTopicProvider provider,
  ) {
    return call(provider.topic);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'imagesByTopicProvider';
}

/// 주제별 이미지 프로바이더
///
/// Copied from [imagesByTopic].
class ImagesByTopicProvider
    extends AutoDisposeProvider<List<OfflineImageInfo>> {
  /// 주제별 이미지 프로바이더
  ///
  /// Copied from [imagesByTopic].
  ImagesByTopicProvider(String topic)
    : this._internal(
        (ref) => imagesByTopic(ref as ImagesByTopicRef, topic),
        from: imagesByTopicProvider,
        name: r'imagesByTopicProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$imagesByTopicHash,
        dependencies: ImagesByTopicFamily._dependencies,
        allTransitiveDependencies:
            ImagesByTopicFamily._allTransitiveDependencies,
        topic: topic,
      );

  ImagesByTopicProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.topic,
  }) : super.internal();

  final String topic;

  @override
  Override overrideWith(
    List<OfflineImageInfo> Function(ImagesByTopicRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ImagesByTopicProvider._internal(
        (ref) => create(ref as ImagesByTopicRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        topic: topic,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<OfflineImageInfo>> createElement() {
    return _ImagesByTopicProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ImagesByTopicProvider && other.topic == topic;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, topic.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ImagesByTopicRef on AutoDisposeProviderRef<List<OfflineImageInfo>> {
  /// The parameter `topic` of this provider.
  String get topic;
}

class _ImagesByTopicProviderElement
    extends AutoDisposeProviderElement<List<OfflineImageInfo>>
    with ImagesByTopicRef {
  _ImagesByTopicProviderElement(super.provider);

  @override
  String get topic => (origin as ImagesByTopicProvider).topic;
}

String _$isOfflineModeHash() => r'04cc5af86fb53e47fc82720aec212bff82000d12';

/// 오프라인 모드 상태 프로바이더
///
/// Copied from [isOfflineMode].
@ProviderFor(isOfflineMode)
final isOfflineModeProvider = AutoDisposeProvider<bool>.internal(
  isOfflineMode,
  name: r'isOfflineModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isOfflineModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsOfflineModeRef = AutoDisposeProviderRef<bool>;
String _$isOnlineModeHash() => r'489bae0c43ddf83a1a4b49d477a7b9669229f4fc';

/// 온라인 모드 상태 프로바이더
///
/// Copied from [isOnlineMode].
@ProviderFor(isOnlineMode)
final isOnlineModeProvider = AutoDisposeProvider<bool>.internal(
  isOnlineMode,
  name: r'isOnlineModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isOnlineModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsOnlineModeRef = AutoDisposeProviderRef<bool>;
String _$networkStatusDisplayNameHash() =>
    r'ae6063b2afdc43563b11efa1e29c23be2bd2a2fe';

/// 네트워크 상태 표시명 프로바이더
///
/// Copied from [networkStatusDisplayName].
@ProviderFor(networkStatusDisplayName)
final networkStatusDisplayNameProvider = AutoDisposeProvider<String>.internal(
  networkStatusDisplayName,
  name: r'networkStatusDisplayNameProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$networkStatusDisplayNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NetworkStatusDisplayNameRef = AutoDisposeProviderRef<String>;
String _$offlineImageCountHash() => r'97ed10aa1a87799d58389821e77bce58fc7385f1';

/// 오프라인 이미지 개수 프로바이더
///
/// Copied from [offlineImageCount].
@ProviderFor(offlineImageCount)
final offlineImageCountProvider = AutoDisposeProvider<int>.internal(
  offlineImageCount,
  name: r'offlineImageCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$offlineImageCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfflineImageCountRef = AutoDisposeProviderRef<int>;
String _$defaultImageCountHash() => r'99a427a7a214b1736491f47cb189d804c96847e9';

/// 기본 이미지 개수 프로바이더
///
/// Copied from [defaultImageCount].
@ProviderFor(defaultImageCount)
final defaultImageCountProvider = AutoDisposeProvider<int>.internal(
  defaultImageCount,
  name: r'defaultImageCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$defaultImageCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DefaultImageCountRef = AutoDisposeProviderRef<int>;
String _$totalImageCountHash() => r'01d68afc9e1030be09a98b2a35a52861a6fbbe0f';

/// 총 이미지 개수 프로바이더
///
/// Copied from [totalImageCount].
@ProviderFor(totalImageCount)
final totalImageCountProvider = AutoDisposeProvider<int>.internal(
  totalImageCount,
  name: r'totalImageCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalImageCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalImageCountRef = AutoDisposeProviderRef<int>;
String _$offlineImageManagerNotifierHash() =>
    r'9a72b00a039931ca805a298849f1f357b214a106';

/// 오프라인 이미지 관리 프로바이더
///
/// Copied from [OfflineImageManagerNotifier].
@ProviderFor(OfflineImageManagerNotifier)
final offlineImageManagerNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      OfflineImageManagerNotifier,
      List<OfflineImageInfo>
    >.internal(
      OfflineImageManagerNotifier.new,
      name: r'offlineImageManagerNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$offlineImageManagerNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OfflineImageManagerNotifier =
    AutoDisposeAsyncNotifier<List<OfflineImageInfo>>;
String _$storageStatsNotifierHash() =>
    r'9120b543422bc0a35eaa103dfe431420f99c7ce4';

/// 저장소 통계 프로바이더
///
/// Copied from [StorageStatsNotifier].
@ProviderFor(StorageStatsNotifier)
final storageStatsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      StorageStatsNotifier,
      Map<String, dynamic>
    >.internal(
      StorageStatsNotifier.new,
      name: r'storageStatsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$storageStatsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StorageStatsNotifier = AutoDisposeAsyncNotifier<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
