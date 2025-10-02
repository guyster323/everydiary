// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'thumbnail_batch_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ThumbnailBatchJob _$ThumbnailBatchJobFromJson(Map<String, dynamic> json) {
  return _ThumbnailBatchJob.fromJson(json);
}

/// @nodoc
mixin _$ThumbnailBatchJob {
  int? get id => throw _privateConstructorUsedError;
  int get diaryId => throw _privateConstructorUsedError;
  ThumbnailBatchJobType get jobType => throw _privateConstructorUsedError;
  ThumbnailBatchJobStatus get status => throw _privateConstructorUsedError;
  Map<String, dynamic>? get payload => throw _privateConstructorUsedError;
  int get retryCount => throw _privateConstructorUsedError;
  String? get lastError => throw _privateConstructorUsedError;
  DateTime get scheduledAt => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  /// Serializes this ThumbnailBatchJob to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ThumbnailBatchJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ThumbnailBatchJobCopyWith<ThumbnailBatchJob> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThumbnailBatchJobCopyWith<$Res> {
  factory $ThumbnailBatchJobCopyWith(
    ThumbnailBatchJob value,
    $Res Function(ThumbnailBatchJob) then,
  ) = _$ThumbnailBatchJobCopyWithImpl<$Res, ThumbnailBatchJob>;
  @useResult
  $Res call({
    int? id,
    int diaryId,
    ThumbnailBatchJobType jobType,
    ThumbnailBatchJobStatus status,
    Map<String, dynamic>? payload,
    int retryCount,
    String? lastError,
    DateTime scheduledAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isDeleted,
  });
}

/// @nodoc
class _$ThumbnailBatchJobCopyWithImpl<$Res, $Val extends ThumbnailBatchJob>
    implements $ThumbnailBatchJobCopyWith<$Res> {
  _$ThumbnailBatchJobCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ThumbnailBatchJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? diaryId = null,
    Object? jobType = null,
    Object? status = null,
    Object? payload = freezed,
    Object? retryCount = null,
    Object? lastError = freezed,
    Object? scheduledAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            diaryId: null == diaryId
                ? _value.diaryId
                : diaryId // ignore: cast_nullable_to_non_nullable
                      as int,
            jobType: null == jobType
                ? _value.jobType
                : jobType // ignore: cast_nullable_to_non_nullable
                      as ThumbnailBatchJobType,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ThumbnailBatchJobStatus,
            payload: freezed == payload
                ? _value.payload
                : payload // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            retryCount: null == retryCount
                ? _value.retryCount
                : retryCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastError: freezed == lastError
                ? _value.lastError
                : lastError // ignore: cast_nullable_to_non_nullable
                      as String?,
            scheduledAt: null == scheduledAt
                ? _value.scheduledAt
                : scheduledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isDeleted: null == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ThumbnailBatchJobImplCopyWith<$Res>
    implements $ThumbnailBatchJobCopyWith<$Res> {
  factory _$$ThumbnailBatchJobImplCopyWith(
    _$ThumbnailBatchJobImpl value,
    $Res Function(_$ThumbnailBatchJobImpl) then,
  ) = __$$ThumbnailBatchJobImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    int diaryId,
    ThumbnailBatchJobType jobType,
    ThumbnailBatchJobStatus status,
    Map<String, dynamic>? payload,
    int retryCount,
    String? lastError,
    DateTime scheduledAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isDeleted,
  });
}

/// @nodoc
class __$$ThumbnailBatchJobImplCopyWithImpl<$Res>
    extends _$ThumbnailBatchJobCopyWithImpl<$Res, _$ThumbnailBatchJobImpl>
    implements _$$ThumbnailBatchJobImplCopyWith<$Res> {
  __$$ThumbnailBatchJobImplCopyWithImpl(
    _$ThumbnailBatchJobImpl _value,
    $Res Function(_$ThumbnailBatchJobImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ThumbnailBatchJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? diaryId = null,
    Object? jobType = null,
    Object? status = null,
    Object? payload = freezed,
    Object? retryCount = null,
    Object? lastError = freezed,
    Object? scheduledAt = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? isDeleted = null,
  }) {
    return _then(
      _$ThumbnailBatchJobImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        diaryId: null == diaryId
            ? _value.diaryId
            : diaryId // ignore: cast_nullable_to_non_nullable
                  as int,
        jobType: null == jobType
            ? _value.jobType
            : jobType // ignore: cast_nullable_to_non_nullable
                  as ThumbnailBatchJobType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ThumbnailBatchJobStatus,
        payload: freezed == payload
            ? _value._payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        retryCount: null == retryCount
            ? _value.retryCount
            : retryCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastError: freezed == lastError
            ? _value.lastError
            : lastError // ignore: cast_nullable_to_non_nullable
                  as String?,
        scheduledAt: null == scheduledAt
            ? _value.scheduledAt
            : scheduledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isDeleted: null == isDeleted
            ? _value.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ThumbnailBatchJobImpl implements _ThumbnailBatchJob {
  const _$ThumbnailBatchJobImpl({
    this.id,
    required this.diaryId,
    this.jobType = ThumbnailBatchJobType.regenerate,
    this.status = ThumbnailBatchJobStatus.pending,
    final Map<String, dynamic>? payload,
    this.retryCount = 0,
    this.lastError,
    required this.scheduledAt,
    this.startedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  }) : _payload = payload;

  factory _$ThumbnailBatchJobImpl.fromJson(Map<String, dynamic> json) =>
      _$$ThumbnailBatchJobImplFromJson(json);

  @override
  final int? id;
  @override
  final int diaryId;
  @override
  @JsonKey()
  final ThumbnailBatchJobType jobType;
  @override
  @JsonKey()
  final ThumbnailBatchJobStatus status;
  final Map<String, dynamic>? _payload;
  @override
  Map<String, dynamic>? get payload {
    final value = _payload;
    if (value == null) return null;
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final int retryCount;
  @override
  final String? lastError;
  @override
  final DateTime scheduledAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool isDeleted;

  @override
  String toString() {
    return 'ThumbnailBatchJob(id: $id, diaryId: $diaryId, jobType: $jobType, status: $status, payload: $payload, retryCount: $retryCount, lastError: $lastError, scheduledAt: $scheduledAt, startedAt: $startedAt, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThumbnailBatchJobImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.diaryId, diaryId) || other.diaryId == diaryId) &&
            (identical(other.jobType, jobType) || other.jobType == jobType) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.lastError, lastError) ||
                other.lastError == lastError) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    diaryId,
    jobType,
    status,
    const DeepCollectionEquality().hash(_payload),
    retryCount,
    lastError,
    scheduledAt,
    startedAt,
    completedAt,
    createdAt,
    updatedAt,
    isDeleted,
  );

  /// Create a copy of ThumbnailBatchJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ThumbnailBatchJobImplCopyWith<_$ThumbnailBatchJobImpl> get copyWith =>
      __$$ThumbnailBatchJobImplCopyWithImpl<_$ThumbnailBatchJobImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ThumbnailBatchJobImplToJson(this);
  }
}

abstract class _ThumbnailBatchJob implements ThumbnailBatchJob {
  const factory _ThumbnailBatchJob({
    final int? id,
    required final int diaryId,
    final ThumbnailBatchJobType jobType,
    final ThumbnailBatchJobStatus status,
    final Map<String, dynamic>? payload,
    final int retryCount,
    final String? lastError,
    required final DateTime scheduledAt,
    final DateTime? startedAt,
    final DateTime? completedAt,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final bool isDeleted,
  }) = _$ThumbnailBatchJobImpl;

  factory _ThumbnailBatchJob.fromJson(Map<String, dynamic> json) =
      _$ThumbnailBatchJobImpl.fromJson;

  @override
  int? get id;
  @override
  int get diaryId;
  @override
  ThumbnailBatchJobType get jobType;
  @override
  ThumbnailBatchJobStatus get status;
  @override
  Map<String, dynamic>? get payload;
  @override
  int get retryCount;
  @override
  String? get lastError;
  @override
  DateTime get scheduledAt;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  bool get isDeleted;

  /// Create a copy of ThumbnailBatchJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ThumbnailBatchJobImplCopyWith<_$ThumbnailBatchJobImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
