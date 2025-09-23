// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diary_memory.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DiaryMemory _$DiaryMemoryFromJson(Map<String, dynamic> json) {
  return _DiaryMemory.fromJson(json);
}

/// @nodoc
mixin _$DiaryMemory {
  String get id => throw _privateConstructorUsedError;
  String get diaryId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get originalDate => throw _privateConstructorUsedError;
  MemoryReason get reason => throw _privateConstructorUsedError;
  double get relevance => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  bool get isViewed => throw _privateConstructorUsedError;
  bool get isBookmarked => throw _privateConstructorUsedError;
  DateTime? get lastViewedAt => throw _privateConstructorUsedError;

  /// Serializes this DiaryMemory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiaryMemory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiaryMemoryCopyWith<DiaryMemory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiaryMemoryCopyWith<$Res> {
  factory $DiaryMemoryCopyWith(
    DiaryMemory value,
    $Res Function(DiaryMemory) then,
  ) = _$DiaryMemoryCopyWithImpl<$Res, DiaryMemory>;
  @useResult
  $Res call({
    String id,
    String diaryId,
    String title,
    String content,
    DateTime createdAt,
    DateTime originalDate,
    MemoryReason reason,
    double relevance,
    List<String> tags,
    String? imageUrl,
    String? location,
    bool isViewed,
    bool isBookmarked,
    DateTime? lastViewedAt,
  });

  $MemoryReasonCopyWith<$Res> get reason;
}

/// @nodoc
class _$DiaryMemoryCopyWithImpl<$Res, $Val extends DiaryMemory>
    implements $DiaryMemoryCopyWith<$Res> {
  _$DiaryMemoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiaryMemory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? diaryId = null,
    Object? title = null,
    Object? content = null,
    Object? createdAt = null,
    Object? originalDate = null,
    Object? reason = null,
    Object? relevance = null,
    Object? tags = null,
    Object? imageUrl = freezed,
    Object? location = freezed,
    Object? isViewed = null,
    Object? isBookmarked = null,
    Object? lastViewedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            diaryId: null == diaryId
                ? _value.diaryId
                : diaryId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            originalDate: null == originalDate
                ? _value.originalDate
                : originalDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as MemoryReason,
            relevance: null == relevance
                ? _value.relevance
                : relevance // ignore: cast_nullable_to_non_nullable
                      as double,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            isViewed: null == isViewed
                ? _value.isViewed
                : isViewed // ignore: cast_nullable_to_non_nullable
                      as bool,
            isBookmarked: null == isBookmarked
                ? _value.isBookmarked
                : isBookmarked // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastViewedAt: freezed == lastViewedAt
                ? _value.lastViewedAt
                : lastViewedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of DiaryMemory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MemoryReasonCopyWith<$Res> get reason {
    return $MemoryReasonCopyWith<$Res>(_value.reason, (value) {
      return _then(_value.copyWith(reason: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DiaryMemoryImplCopyWith<$Res>
    implements $DiaryMemoryCopyWith<$Res> {
  factory _$$DiaryMemoryImplCopyWith(
    _$DiaryMemoryImpl value,
    $Res Function(_$DiaryMemoryImpl) then,
  ) = __$$DiaryMemoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String diaryId,
    String title,
    String content,
    DateTime createdAt,
    DateTime originalDate,
    MemoryReason reason,
    double relevance,
    List<String> tags,
    String? imageUrl,
    String? location,
    bool isViewed,
    bool isBookmarked,
    DateTime? lastViewedAt,
  });

  @override
  $MemoryReasonCopyWith<$Res> get reason;
}

/// @nodoc
class __$$DiaryMemoryImplCopyWithImpl<$Res>
    extends _$DiaryMemoryCopyWithImpl<$Res, _$DiaryMemoryImpl>
    implements _$$DiaryMemoryImplCopyWith<$Res> {
  __$$DiaryMemoryImplCopyWithImpl(
    _$DiaryMemoryImpl _value,
    $Res Function(_$DiaryMemoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiaryMemory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? diaryId = null,
    Object? title = null,
    Object? content = null,
    Object? createdAt = null,
    Object? originalDate = null,
    Object? reason = null,
    Object? relevance = null,
    Object? tags = null,
    Object? imageUrl = freezed,
    Object? location = freezed,
    Object? isViewed = null,
    Object? isBookmarked = null,
    Object? lastViewedAt = freezed,
  }) {
    return _then(
      _$DiaryMemoryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        diaryId: null == diaryId
            ? _value.diaryId
            : diaryId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        originalDate: null == originalDate
            ? _value.originalDate
            : originalDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as MemoryReason,
        relevance: null == relevance
            ? _value.relevance
            : relevance // ignore: cast_nullable_to_non_nullable
                  as double,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        isViewed: null == isViewed
            ? _value.isViewed
            : isViewed // ignore: cast_nullable_to_non_nullable
                  as bool,
        isBookmarked: null == isBookmarked
            ? _value.isBookmarked
            : isBookmarked // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastViewedAt: freezed == lastViewedAt
            ? _value.lastViewedAt
            : lastViewedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DiaryMemoryImpl implements _DiaryMemory {
  const _$DiaryMemoryImpl({
    required this.id,
    required this.diaryId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.originalDate,
    required this.reason,
    required this.relevance,
    required final List<String> tags,
    this.imageUrl,
    this.location,
    this.isViewed = false,
    this.isBookmarked = false,
    this.lastViewedAt,
  }) : _tags = tags;

  factory _$DiaryMemoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiaryMemoryImplFromJson(json);

  @override
  final String id;
  @override
  final String diaryId;
  @override
  final String title;
  @override
  final String content;
  @override
  final DateTime createdAt;
  @override
  final DateTime originalDate;
  @override
  final MemoryReason reason;
  @override
  final double relevance;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String? imageUrl;
  @override
  final String? location;
  @override
  @JsonKey()
  final bool isViewed;
  @override
  @JsonKey()
  final bool isBookmarked;
  @override
  final DateTime? lastViewedAt;

  @override
  String toString() {
    return 'DiaryMemory(id: $id, diaryId: $diaryId, title: $title, content: $content, createdAt: $createdAt, originalDate: $originalDate, reason: $reason, relevance: $relevance, tags: $tags, imageUrl: $imageUrl, location: $location, isViewed: $isViewed, isBookmarked: $isBookmarked, lastViewedAt: $lastViewedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiaryMemoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.diaryId, diaryId) || other.diaryId == diaryId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.originalDate, originalDate) ||
                other.originalDate == originalDate) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.relevance, relevance) ||
                other.relevance == relevance) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.isViewed, isViewed) ||
                other.isViewed == isViewed) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked) &&
            (identical(other.lastViewedAt, lastViewedAt) ||
                other.lastViewedAt == lastViewedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    diaryId,
    title,
    content,
    createdAt,
    originalDate,
    reason,
    relevance,
    const DeepCollectionEquality().hash(_tags),
    imageUrl,
    location,
    isViewed,
    isBookmarked,
    lastViewedAt,
  );

  /// Create a copy of DiaryMemory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiaryMemoryImplCopyWith<_$DiaryMemoryImpl> get copyWith =>
      __$$DiaryMemoryImplCopyWithImpl<_$DiaryMemoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiaryMemoryImplToJson(this);
  }
}

abstract class _DiaryMemory implements DiaryMemory {
  const factory _DiaryMemory({
    required final String id,
    required final String diaryId,
    required final String title,
    required final String content,
    required final DateTime createdAt,
    required final DateTime originalDate,
    required final MemoryReason reason,
    required final double relevance,
    required final List<String> tags,
    final String? imageUrl,
    final String? location,
    final bool isViewed,
    final bool isBookmarked,
    final DateTime? lastViewedAt,
  }) = _$DiaryMemoryImpl;

  factory _DiaryMemory.fromJson(Map<String, dynamic> json) =
      _$DiaryMemoryImpl.fromJson;

  @override
  String get id;
  @override
  String get diaryId;
  @override
  String get title;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  DateTime get originalDate;
  @override
  MemoryReason get reason;
  @override
  double get relevance;
  @override
  List<String> get tags;
  @override
  String? get imageUrl;
  @override
  String? get location;
  @override
  bool get isViewed;
  @override
  bool get isBookmarked;
  @override
  DateTime? get lastViewedAt;

  /// Create a copy of DiaryMemory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiaryMemoryImplCopyWith<_$DiaryMemoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MemoryReason _$MemoryReasonFromJson(Map<String, dynamic> json) {
  return _MemoryReason.fromJson(json);
}

/// @nodoc
mixin _$MemoryReason {
  MemoryType get type => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get displayText => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this MemoryReason to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemoryReason
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemoryReasonCopyWith<MemoryReason> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemoryReasonCopyWith<$Res> {
  factory $MemoryReasonCopyWith(
    MemoryReason value,
    $Res Function(MemoryReason) then,
  ) = _$MemoryReasonCopyWithImpl<$Res, MemoryReason>;
  @useResult
  $Res call({
    MemoryType type,
    String description,
    String displayText,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$MemoryReasonCopyWithImpl<$Res, $Val extends MemoryReason>
    implements $MemoryReasonCopyWith<$Res> {
  _$MemoryReasonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemoryReason
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? description = null,
    Object? displayText = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MemoryType,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            displayText: null == displayText
                ? _value.displayText
                : displayText // ignore: cast_nullable_to_non_nullable
                      as String,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MemoryReasonImplCopyWith<$Res>
    implements $MemoryReasonCopyWith<$Res> {
  factory _$$MemoryReasonImplCopyWith(
    _$MemoryReasonImpl value,
    $Res Function(_$MemoryReasonImpl) then,
  ) = __$$MemoryReasonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    MemoryType type,
    String description,
    String displayText,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$MemoryReasonImplCopyWithImpl<$Res>
    extends _$MemoryReasonCopyWithImpl<$Res, _$MemoryReasonImpl>
    implements _$$MemoryReasonImplCopyWith<$Res> {
  __$$MemoryReasonImplCopyWithImpl(
    _$MemoryReasonImpl _value,
    $Res Function(_$MemoryReasonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MemoryReason
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? description = null,
    Object? displayText = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$MemoryReasonImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MemoryType,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        displayText: null == displayText
            ? _value.displayText
            : displayText // ignore: cast_nullable_to_non_nullable
                  as String,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MemoryReasonImpl implements _MemoryReason {
  const _$MemoryReasonImpl({
    required this.type,
    required this.description,
    required this.displayText,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$MemoryReasonImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemoryReasonImplFromJson(json);

  @override
  final MemoryType type;
  @override
  final String description;
  @override
  final String displayText;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'MemoryReason(type: $type, description: $description, displayText: $displayText, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemoryReasonImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.displayText, displayText) ||
                other.displayText == displayText) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    description,
    displayText,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of MemoryReason
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemoryReasonImplCopyWith<_$MemoryReasonImpl> get copyWith =>
      __$$MemoryReasonImplCopyWithImpl<_$MemoryReasonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemoryReasonImplToJson(this);
  }
}

abstract class _MemoryReason implements MemoryReason {
  const factory _MemoryReason({
    required final MemoryType type,
    required final String description,
    required final String displayText,
    final Map<String, dynamic>? metadata,
  }) = _$MemoryReasonImpl;

  factory _MemoryReason.fromJson(Map<String, dynamic> json) =
      _$MemoryReasonImpl.fromJson;

  @override
  MemoryType get type;
  @override
  String get description;
  @override
  String get displayText;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of MemoryReason
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemoryReasonImplCopyWith<_$MemoryReasonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MemoryResult _$MemoryResultFromJson(Map<String, dynamic> json) {
  return _MemoryResult.fromJson(json);
}

/// @nodoc
mixin _$MemoryResult {
  List<DiaryMemory> get memories => throw _privateConstructorUsedError;
  DateTime get generatedAt => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  int get filteredCount => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this MemoryResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemoryResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemoryResultCopyWith<MemoryResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemoryResultCopyWith<$Res> {
  factory $MemoryResultCopyWith(
    MemoryResult value,
    $Res Function(MemoryResult) then,
  ) = _$MemoryResultCopyWithImpl<$Res, MemoryResult>;
  @useResult
  $Res call({
    List<DiaryMemory> memories,
    DateTime generatedAt,
    String userId,
    int totalCount,
    int filteredCount,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$MemoryResultCopyWithImpl<$Res, $Val extends MemoryResult>
    implements $MemoryResultCopyWith<$Res> {
  _$MemoryResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemoryResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memories = null,
    Object? generatedAt = null,
    Object? userId = null,
    Object? totalCount = null,
    Object? filteredCount = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            memories: null == memories
                ? _value.memories
                : memories // ignore: cast_nullable_to_non_nullable
                      as List<DiaryMemory>,
            generatedAt: null == generatedAt
                ? _value.generatedAt
                : generatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            totalCount: null == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                      as int,
            filteredCount: null == filteredCount
                ? _value.filteredCount
                : filteredCount // ignore: cast_nullable_to_non_nullable
                      as int,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MemoryResultImplCopyWith<$Res>
    implements $MemoryResultCopyWith<$Res> {
  factory _$$MemoryResultImplCopyWith(
    _$MemoryResultImpl value,
    $Res Function(_$MemoryResultImpl) then,
  ) = __$$MemoryResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<DiaryMemory> memories,
    DateTime generatedAt,
    String userId,
    int totalCount,
    int filteredCount,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$MemoryResultImplCopyWithImpl<$Res>
    extends _$MemoryResultCopyWithImpl<$Res, _$MemoryResultImpl>
    implements _$$MemoryResultImplCopyWith<$Res> {
  __$$MemoryResultImplCopyWithImpl(
    _$MemoryResultImpl _value,
    $Res Function(_$MemoryResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MemoryResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memories = null,
    Object? generatedAt = null,
    Object? userId = null,
    Object? totalCount = null,
    Object? filteredCount = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$MemoryResultImpl(
        memories: null == memories
            ? _value._memories
            : memories // ignore: cast_nullable_to_non_nullable
                  as List<DiaryMemory>,
        generatedAt: null == generatedAt
            ? _value.generatedAt
            : generatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        totalCount: null == totalCount
            ? _value.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int,
        filteredCount: null == filteredCount
            ? _value.filteredCount
            : filteredCount // ignore: cast_nullable_to_non_nullable
                  as int,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MemoryResultImpl implements _MemoryResult {
  const _$MemoryResultImpl({
    required final List<DiaryMemory> memories,
    required this.generatedAt,
    required this.userId,
    this.totalCount = 0,
    this.filteredCount = 0,
    final Map<String, dynamic>? metadata,
  }) : _memories = memories,
       _metadata = metadata;

  factory _$MemoryResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemoryResultImplFromJson(json);

  final List<DiaryMemory> _memories;
  @override
  List<DiaryMemory> get memories {
    if (_memories is EqualUnmodifiableListView) return _memories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_memories);
  }

  @override
  final DateTime generatedAt;
  @override
  final String userId;
  @override
  @JsonKey()
  final int totalCount;
  @override
  @JsonKey()
  final int filteredCount;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'MemoryResult(memories: $memories, generatedAt: $generatedAt, userId: $userId, totalCount: $totalCount, filteredCount: $filteredCount, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemoryResultImpl &&
            const DeepCollectionEquality().equals(other._memories, _memories) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.filteredCount, filteredCount) ||
                other.filteredCount == filteredCount) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_memories),
    generatedAt,
    userId,
    totalCount,
    filteredCount,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of MemoryResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemoryResultImplCopyWith<_$MemoryResultImpl> get copyWith =>
      __$$MemoryResultImplCopyWithImpl<_$MemoryResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemoryResultImplToJson(this);
  }
}

abstract class _MemoryResult implements MemoryResult {
  const factory _MemoryResult({
    required final List<DiaryMemory> memories,
    required final DateTime generatedAt,
    required final String userId,
    final int totalCount,
    final int filteredCount,
    final Map<String, dynamic>? metadata,
  }) = _$MemoryResultImpl;

  factory _MemoryResult.fromJson(Map<String, dynamic> json) =
      _$MemoryResultImpl.fromJson;

  @override
  List<DiaryMemory> get memories;
  @override
  DateTime get generatedAt;
  @override
  String get userId;
  @override
  int get totalCount;
  @override
  int get filteredCount;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of MemoryResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemoryResultImplCopyWith<_$MemoryResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MemoryStats _$MemoryStatsFromJson(Map<String, dynamic> json) {
  return _MemoryStats.fromJson(json);
}

/// @nodoc
mixin _$MemoryStats {
  String get userId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  Map<MemoryType, int> get typeCounts => throw _privateConstructorUsedError;
  double get averageRelevance => throw _privateConstructorUsedError;
  int get totalMemories => throw _privateConstructorUsedError;
  int get viewedCount => throw _privateConstructorUsedError;
  int get bookmarkedCount => throw _privateConstructorUsedError;
  double get engagementRate => throw _privateConstructorUsedError;

  /// Serializes this MemoryStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemoryStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemoryStatsCopyWith<MemoryStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemoryStatsCopyWith<$Res> {
  factory $MemoryStatsCopyWith(
    MemoryStats value,
    $Res Function(MemoryStats) then,
  ) = _$MemoryStatsCopyWithImpl<$Res, MemoryStats>;
  @useResult
  $Res call({
    String userId,
    DateTime date,
    Map<MemoryType, int> typeCounts,
    double averageRelevance,
    int totalMemories,
    int viewedCount,
    int bookmarkedCount,
    double engagementRate,
  });
}

/// @nodoc
class _$MemoryStatsCopyWithImpl<$Res, $Val extends MemoryStats>
    implements $MemoryStatsCopyWith<$Res> {
  _$MemoryStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemoryStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? date = null,
    Object? typeCounts = null,
    Object? averageRelevance = null,
    Object? totalMemories = null,
    Object? viewedCount = null,
    Object? bookmarkedCount = null,
    Object? engagementRate = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            typeCounts: null == typeCounts
                ? _value.typeCounts
                : typeCounts // ignore: cast_nullable_to_non_nullable
                      as Map<MemoryType, int>,
            averageRelevance: null == averageRelevance
                ? _value.averageRelevance
                : averageRelevance // ignore: cast_nullable_to_non_nullable
                      as double,
            totalMemories: null == totalMemories
                ? _value.totalMemories
                : totalMemories // ignore: cast_nullable_to_non_nullable
                      as int,
            viewedCount: null == viewedCount
                ? _value.viewedCount
                : viewedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            bookmarkedCount: null == bookmarkedCount
                ? _value.bookmarkedCount
                : bookmarkedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            engagementRate: null == engagementRate
                ? _value.engagementRate
                : engagementRate // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MemoryStatsImplCopyWith<$Res>
    implements $MemoryStatsCopyWith<$Res> {
  factory _$$MemoryStatsImplCopyWith(
    _$MemoryStatsImpl value,
    $Res Function(_$MemoryStatsImpl) then,
  ) = __$$MemoryStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    DateTime date,
    Map<MemoryType, int> typeCounts,
    double averageRelevance,
    int totalMemories,
    int viewedCount,
    int bookmarkedCount,
    double engagementRate,
  });
}

/// @nodoc
class __$$MemoryStatsImplCopyWithImpl<$Res>
    extends _$MemoryStatsCopyWithImpl<$Res, _$MemoryStatsImpl>
    implements _$$MemoryStatsImplCopyWith<$Res> {
  __$$MemoryStatsImplCopyWithImpl(
    _$MemoryStatsImpl _value,
    $Res Function(_$MemoryStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MemoryStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? date = null,
    Object? typeCounts = null,
    Object? averageRelevance = null,
    Object? totalMemories = null,
    Object? viewedCount = null,
    Object? bookmarkedCount = null,
    Object? engagementRate = null,
  }) {
    return _then(
      _$MemoryStatsImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        typeCounts: null == typeCounts
            ? _value._typeCounts
            : typeCounts // ignore: cast_nullable_to_non_nullable
                  as Map<MemoryType, int>,
        averageRelevance: null == averageRelevance
            ? _value.averageRelevance
            : averageRelevance // ignore: cast_nullable_to_non_nullable
                  as double,
        totalMemories: null == totalMemories
            ? _value.totalMemories
            : totalMemories // ignore: cast_nullable_to_non_nullable
                  as int,
        viewedCount: null == viewedCount
            ? _value.viewedCount
            : viewedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        bookmarkedCount: null == bookmarkedCount
            ? _value.bookmarkedCount
            : bookmarkedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        engagementRate: null == engagementRate
            ? _value.engagementRate
            : engagementRate // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MemoryStatsImpl implements _MemoryStats {
  const _$MemoryStatsImpl({
    required this.userId,
    required this.date,
    required final Map<MemoryType, int> typeCounts,
    required this.averageRelevance,
    required this.totalMemories,
    required this.viewedCount,
    required this.bookmarkedCount,
    required this.engagementRate,
  }) : _typeCounts = typeCounts;

  factory _$MemoryStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemoryStatsImplFromJson(json);

  @override
  final String userId;
  @override
  final DateTime date;
  final Map<MemoryType, int> _typeCounts;
  @override
  Map<MemoryType, int> get typeCounts {
    if (_typeCounts is EqualUnmodifiableMapView) return _typeCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_typeCounts);
  }

  @override
  final double averageRelevance;
  @override
  final int totalMemories;
  @override
  final int viewedCount;
  @override
  final int bookmarkedCount;
  @override
  final double engagementRate;

  @override
  String toString() {
    return 'MemoryStats(userId: $userId, date: $date, typeCounts: $typeCounts, averageRelevance: $averageRelevance, totalMemories: $totalMemories, viewedCount: $viewedCount, bookmarkedCount: $bookmarkedCount, engagementRate: $engagementRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemoryStatsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(
              other._typeCounts,
              _typeCounts,
            ) &&
            (identical(other.averageRelevance, averageRelevance) ||
                other.averageRelevance == averageRelevance) &&
            (identical(other.totalMemories, totalMemories) ||
                other.totalMemories == totalMemories) &&
            (identical(other.viewedCount, viewedCount) ||
                other.viewedCount == viewedCount) &&
            (identical(other.bookmarkedCount, bookmarkedCount) ||
                other.bookmarkedCount == bookmarkedCount) &&
            (identical(other.engagementRate, engagementRate) ||
                other.engagementRate == engagementRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    date,
    const DeepCollectionEquality().hash(_typeCounts),
    averageRelevance,
    totalMemories,
    viewedCount,
    bookmarkedCount,
    engagementRate,
  );

  /// Create a copy of MemoryStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemoryStatsImplCopyWith<_$MemoryStatsImpl> get copyWith =>
      __$$MemoryStatsImplCopyWithImpl<_$MemoryStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemoryStatsImplToJson(this);
  }
}

abstract class _MemoryStats implements MemoryStats {
  const factory _MemoryStats({
    required final String userId,
    required final DateTime date,
    required final Map<MemoryType, int> typeCounts,
    required final double averageRelevance,
    required final int totalMemories,
    required final int viewedCount,
    required final int bookmarkedCount,
    required final double engagementRate,
  }) = _$MemoryStatsImpl;

  factory _MemoryStats.fromJson(Map<String, dynamic> json) =
      _$MemoryStatsImpl.fromJson;

  @override
  String get userId;
  @override
  DateTime get date;
  @override
  Map<MemoryType, int> get typeCounts;
  @override
  double get averageRelevance;
  @override
  int get totalMemories;
  @override
  int get viewedCount;
  @override
  int get bookmarkedCount;
  @override
  double get engagementRate;

  /// Create a copy of MemoryStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemoryStatsImplCopyWith<_$MemoryStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
