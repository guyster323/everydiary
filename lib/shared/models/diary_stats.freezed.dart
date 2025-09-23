// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diary_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DiaryStats _$DiaryStatsFromJson(Map<String, dynamic> json) {
  return _DiaryStats.fromJson(json);
}

/// @nodoc
mixin _$DiaryStats {
  int? get id => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  int get entriesCount => throw _privateConstructorUsedError;
  int get totalWords => throw _privateConstructorUsedError;
  int get totalReadingTime => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this DiaryStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiaryStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiaryStatsCopyWith<DiaryStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiaryStatsCopyWith<$Res> {
  factory $DiaryStatsCopyWith(
    DiaryStats value,
    $Res Function(DiaryStats) then,
  ) = _$DiaryStatsCopyWithImpl<$Res, DiaryStats>;
  @useResult
  $Res call({
    int? id,
    int userId,
    String date,
    int entriesCount,
    int totalWords,
    int totalReadingTime,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class _$DiaryStatsCopyWithImpl<$Res, $Val extends DiaryStats>
    implements $DiaryStatsCopyWith<$Res> {
  _$DiaryStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiaryStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? date = null,
    Object? entriesCount = null,
    Object? totalWords = null,
    Object? totalReadingTime = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            entriesCount: null == entriesCount
                ? _value.entriesCount
                : entriesCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalWords: null == totalWords
                ? _value.totalWords
                : totalWords // ignore: cast_nullable_to_non_nullable
                      as int,
            totalReadingTime: null == totalReadingTime
                ? _value.totalReadingTime
                : totalReadingTime // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DiaryStatsImplCopyWith<$Res>
    implements $DiaryStatsCopyWith<$Res> {
  factory _$$DiaryStatsImplCopyWith(
    _$DiaryStatsImpl value,
    $Res Function(_$DiaryStatsImpl) then,
  ) = __$$DiaryStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    int userId,
    String date,
    int entriesCount,
    int totalWords,
    int totalReadingTime,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class __$$DiaryStatsImplCopyWithImpl<$Res>
    extends _$DiaryStatsCopyWithImpl<$Res, _$DiaryStatsImpl>
    implements _$$DiaryStatsImplCopyWith<$Res> {
  __$$DiaryStatsImplCopyWithImpl(
    _$DiaryStatsImpl _value,
    $Res Function(_$DiaryStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiaryStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? date = null,
    Object? entriesCount = null,
    Object? totalWords = null,
    Object? totalReadingTime = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$DiaryStatsImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        entriesCount: null == entriesCount
            ? _value.entriesCount
            : entriesCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalWords: null == totalWords
            ? _value.totalWords
            : totalWords // ignore: cast_nullable_to_non_nullable
                  as int,
        totalReadingTime: null == totalReadingTime
            ? _value.totalReadingTime
            : totalReadingTime // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DiaryStatsImpl implements _DiaryStats {
  const _$DiaryStatsImpl({
    this.id,
    required this.userId,
    required this.date,
    this.entriesCount = 0,
    this.totalWords = 0,
    this.totalReadingTime = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$DiaryStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiaryStatsImplFromJson(json);

  @override
  final int? id;
  @override
  final int userId;
  @override
  final String date;
  @override
  @JsonKey()
  final int entriesCount;
  @override
  @JsonKey()
  final int totalWords;
  @override
  @JsonKey()
  final int totalReadingTime;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'DiaryStats(id: $id, userId: $userId, date: $date, entriesCount: $entriesCount, totalWords: $totalWords, totalReadingTime: $totalReadingTime, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiaryStatsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.entriesCount, entriesCount) ||
                other.entriesCount == entriesCount) &&
            (identical(other.totalWords, totalWords) ||
                other.totalWords == totalWords) &&
            (identical(other.totalReadingTime, totalReadingTime) ||
                other.totalReadingTime == totalReadingTime) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    date,
    entriesCount,
    totalWords,
    totalReadingTime,
    createdAt,
    updatedAt,
  );

  /// Create a copy of DiaryStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiaryStatsImplCopyWith<_$DiaryStatsImpl> get copyWith =>
      __$$DiaryStatsImplCopyWithImpl<_$DiaryStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiaryStatsImplToJson(this);
  }
}

abstract class _DiaryStats implements DiaryStats {
  const factory _DiaryStats({
    final int? id,
    required final int userId,
    required final String date,
    final int entriesCount,
    final int totalWords,
    final int totalReadingTime,
    required final String createdAt,
    required final String updatedAt,
  }) = _$DiaryStatsImpl;

  factory _DiaryStats.fromJson(Map<String, dynamic> json) =
      _$DiaryStatsImpl.fromJson;

  @override
  int? get id;
  @override
  int get userId;
  @override
  String get date;
  @override
  int get entriesCount;
  @override
  int get totalWords;
  @override
  int get totalReadingTime;
  @override
  String get createdAt;
  @override
  String get updatedAt;

  /// Create a copy of DiaryStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiaryStatsImplCopyWith<_$DiaryStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateDiaryStatsDto _$CreateDiaryStatsDtoFromJson(Map<String, dynamic> json) {
  return _CreateDiaryStatsDto.fromJson(json);
}

/// @nodoc
mixin _$CreateDiaryStatsDto {
  int get userId => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  int get entriesCount => throw _privateConstructorUsedError;
  int get totalWords => throw _privateConstructorUsedError;
  int get totalReadingTime => throw _privateConstructorUsedError;

  /// Serializes this CreateDiaryStatsDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateDiaryStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateDiaryStatsDtoCopyWith<CreateDiaryStatsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateDiaryStatsDtoCopyWith<$Res> {
  factory $CreateDiaryStatsDtoCopyWith(
    CreateDiaryStatsDto value,
    $Res Function(CreateDiaryStatsDto) then,
  ) = _$CreateDiaryStatsDtoCopyWithImpl<$Res, CreateDiaryStatsDto>;
  @useResult
  $Res call({
    int userId,
    String date,
    int entriesCount,
    int totalWords,
    int totalReadingTime,
  });
}

/// @nodoc
class _$CreateDiaryStatsDtoCopyWithImpl<$Res, $Val extends CreateDiaryStatsDto>
    implements $CreateDiaryStatsDtoCopyWith<$Res> {
  _$CreateDiaryStatsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateDiaryStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? date = null,
    Object? entriesCount = null,
    Object? totalWords = null,
    Object? totalReadingTime = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            entriesCount: null == entriesCount
                ? _value.entriesCount
                : entriesCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalWords: null == totalWords
                ? _value.totalWords
                : totalWords // ignore: cast_nullable_to_non_nullable
                      as int,
            totalReadingTime: null == totalReadingTime
                ? _value.totalReadingTime
                : totalReadingTime // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateDiaryStatsDtoImplCopyWith<$Res>
    implements $CreateDiaryStatsDtoCopyWith<$Res> {
  factory _$$CreateDiaryStatsDtoImplCopyWith(
    _$CreateDiaryStatsDtoImpl value,
    $Res Function(_$CreateDiaryStatsDtoImpl) then,
  ) = __$$CreateDiaryStatsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int userId,
    String date,
    int entriesCount,
    int totalWords,
    int totalReadingTime,
  });
}

/// @nodoc
class __$$CreateDiaryStatsDtoImplCopyWithImpl<$Res>
    extends _$CreateDiaryStatsDtoCopyWithImpl<$Res, _$CreateDiaryStatsDtoImpl>
    implements _$$CreateDiaryStatsDtoImplCopyWith<$Res> {
  __$$CreateDiaryStatsDtoImplCopyWithImpl(
    _$CreateDiaryStatsDtoImpl _value,
    $Res Function(_$CreateDiaryStatsDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateDiaryStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? date = null,
    Object? entriesCount = null,
    Object? totalWords = null,
    Object? totalReadingTime = null,
  }) {
    return _then(
      _$CreateDiaryStatsDtoImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        entriesCount: null == entriesCount
            ? _value.entriesCount
            : entriesCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalWords: null == totalWords
            ? _value.totalWords
            : totalWords // ignore: cast_nullable_to_non_nullable
                  as int,
        totalReadingTime: null == totalReadingTime
            ? _value.totalReadingTime
            : totalReadingTime // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateDiaryStatsDtoImpl implements _CreateDiaryStatsDto {
  const _$CreateDiaryStatsDtoImpl({
    required this.userId,
    required this.date,
    this.entriesCount = 0,
    this.totalWords = 0,
    this.totalReadingTime = 0,
  });

  factory _$CreateDiaryStatsDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateDiaryStatsDtoImplFromJson(json);

  @override
  final int userId;
  @override
  final String date;
  @override
  @JsonKey()
  final int entriesCount;
  @override
  @JsonKey()
  final int totalWords;
  @override
  @JsonKey()
  final int totalReadingTime;

  @override
  String toString() {
    return 'CreateDiaryStatsDto(userId: $userId, date: $date, entriesCount: $entriesCount, totalWords: $totalWords, totalReadingTime: $totalReadingTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateDiaryStatsDtoImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.entriesCount, entriesCount) ||
                other.entriesCount == entriesCount) &&
            (identical(other.totalWords, totalWords) ||
                other.totalWords == totalWords) &&
            (identical(other.totalReadingTime, totalReadingTime) ||
                other.totalReadingTime == totalReadingTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    date,
    entriesCount,
    totalWords,
    totalReadingTime,
  );

  /// Create a copy of CreateDiaryStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateDiaryStatsDtoImplCopyWith<_$CreateDiaryStatsDtoImpl> get copyWith =>
      __$$CreateDiaryStatsDtoImplCopyWithImpl<_$CreateDiaryStatsDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateDiaryStatsDtoImplToJson(this);
  }
}

abstract class _CreateDiaryStatsDto implements CreateDiaryStatsDto {
  const factory _CreateDiaryStatsDto({
    required final int userId,
    required final String date,
    final int entriesCount,
    final int totalWords,
    final int totalReadingTime,
  }) = _$CreateDiaryStatsDtoImpl;

  factory _CreateDiaryStatsDto.fromJson(Map<String, dynamic> json) =
      _$CreateDiaryStatsDtoImpl.fromJson;

  @override
  int get userId;
  @override
  String get date;
  @override
  int get entriesCount;
  @override
  int get totalWords;
  @override
  int get totalReadingTime;

  /// Create a copy of CreateDiaryStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateDiaryStatsDtoImplCopyWith<_$CreateDiaryStatsDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateDiaryStatsDto _$UpdateDiaryStatsDtoFromJson(Map<String, dynamic> json) {
  return _UpdateDiaryStatsDto.fromJson(json);
}

/// @nodoc
mixin _$UpdateDiaryStatsDto {
  int? get entriesCount => throw _privateConstructorUsedError;
  int? get totalWords => throw _privateConstructorUsedError;
  int? get totalReadingTime => throw _privateConstructorUsedError;

  /// Serializes this UpdateDiaryStatsDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateDiaryStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateDiaryStatsDtoCopyWith<UpdateDiaryStatsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateDiaryStatsDtoCopyWith<$Res> {
  factory $UpdateDiaryStatsDtoCopyWith(
    UpdateDiaryStatsDto value,
    $Res Function(UpdateDiaryStatsDto) then,
  ) = _$UpdateDiaryStatsDtoCopyWithImpl<$Res, UpdateDiaryStatsDto>;
  @useResult
  $Res call({int? entriesCount, int? totalWords, int? totalReadingTime});
}

/// @nodoc
class _$UpdateDiaryStatsDtoCopyWithImpl<$Res, $Val extends UpdateDiaryStatsDto>
    implements $UpdateDiaryStatsDtoCopyWith<$Res> {
  _$UpdateDiaryStatsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateDiaryStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entriesCount = freezed,
    Object? totalWords = freezed,
    Object? totalReadingTime = freezed,
  }) {
    return _then(
      _value.copyWith(
            entriesCount: freezed == entriesCount
                ? _value.entriesCount
                : entriesCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            totalWords: freezed == totalWords
                ? _value.totalWords
                : totalWords // ignore: cast_nullable_to_non_nullable
                      as int?,
            totalReadingTime: freezed == totalReadingTime
                ? _value.totalReadingTime
                : totalReadingTime // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpdateDiaryStatsDtoImplCopyWith<$Res>
    implements $UpdateDiaryStatsDtoCopyWith<$Res> {
  factory _$$UpdateDiaryStatsDtoImplCopyWith(
    _$UpdateDiaryStatsDtoImpl value,
    $Res Function(_$UpdateDiaryStatsDtoImpl) then,
  ) = __$$UpdateDiaryStatsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? entriesCount, int? totalWords, int? totalReadingTime});
}

/// @nodoc
class __$$UpdateDiaryStatsDtoImplCopyWithImpl<$Res>
    extends _$UpdateDiaryStatsDtoCopyWithImpl<$Res, _$UpdateDiaryStatsDtoImpl>
    implements _$$UpdateDiaryStatsDtoImplCopyWith<$Res> {
  __$$UpdateDiaryStatsDtoImplCopyWithImpl(
    _$UpdateDiaryStatsDtoImpl _value,
    $Res Function(_$UpdateDiaryStatsDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateDiaryStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entriesCount = freezed,
    Object? totalWords = freezed,
    Object? totalReadingTime = freezed,
  }) {
    return _then(
      _$UpdateDiaryStatsDtoImpl(
        entriesCount: freezed == entriesCount
            ? _value.entriesCount
            : entriesCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        totalWords: freezed == totalWords
            ? _value.totalWords
            : totalWords // ignore: cast_nullable_to_non_nullable
                  as int?,
        totalReadingTime: freezed == totalReadingTime
            ? _value.totalReadingTime
            : totalReadingTime // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateDiaryStatsDtoImpl implements _UpdateDiaryStatsDto {
  const _$UpdateDiaryStatsDtoImpl({
    this.entriesCount,
    this.totalWords,
    this.totalReadingTime,
  });

  factory _$UpdateDiaryStatsDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateDiaryStatsDtoImplFromJson(json);

  @override
  final int? entriesCount;
  @override
  final int? totalWords;
  @override
  final int? totalReadingTime;

  @override
  String toString() {
    return 'UpdateDiaryStatsDto(entriesCount: $entriesCount, totalWords: $totalWords, totalReadingTime: $totalReadingTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateDiaryStatsDtoImpl &&
            (identical(other.entriesCount, entriesCount) ||
                other.entriesCount == entriesCount) &&
            (identical(other.totalWords, totalWords) ||
                other.totalWords == totalWords) &&
            (identical(other.totalReadingTime, totalReadingTime) ||
                other.totalReadingTime == totalReadingTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, entriesCount, totalWords, totalReadingTime);

  /// Create a copy of UpdateDiaryStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateDiaryStatsDtoImplCopyWith<_$UpdateDiaryStatsDtoImpl> get copyWith =>
      __$$UpdateDiaryStatsDtoImplCopyWithImpl<_$UpdateDiaryStatsDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateDiaryStatsDtoImplToJson(this);
  }
}

abstract class _UpdateDiaryStatsDto implements UpdateDiaryStatsDto {
  const factory _UpdateDiaryStatsDto({
    final int? entriesCount,
    final int? totalWords,
    final int? totalReadingTime,
  }) = _$UpdateDiaryStatsDtoImpl;

  factory _UpdateDiaryStatsDto.fromJson(Map<String, dynamic> json) =
      _$UpdateDiaryStatsDtoImpl.fromJson;

  @override
  int? get entriesCount;
  @override
  int? get totalWords;
  @override
  int? get totalReadingTime;

  /// Create a copy of UpdateDiaryStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateDiaryStatsDtoImplCopyWith<_$UpdateDiaryStatsDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
