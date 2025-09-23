// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mood_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MoodStats _$MoodStatsFromJson(Map<String, dynamic> json) {
  return _MoodStats.fromJson(json);
}

/// @nodoc
mixin _$MoodStats {
  int? get id => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  String get mood => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this MoodStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MoodStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MoodStatsCopyWith<MoodStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MoodStatsCopyWith<$Res> {
  factory $MoodStatsCopyWith(MoodStats value, $Res Function(MoodStats) then) =
      _$MoodStatsCopyWithImpl<$Res, MoodStats>;
  @useResult
  $Res call({
    int? id,
    int userId,
    String mood,
    String date,
    int count,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class _$MoodStatsCopyWithImpl<$Res, $Val extends MoodStats>
    implements $MoodStatsCopyWith<$Res> {
  _$MoodStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MoodStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? mood = null,
    Object? date = null,
    Object? count = null,
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
            mood: null == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
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
abstract class _$$MoodStatsImplCopyWith<$Res>
    implements $MoodStatsCopyWith<$Res> {
  factory _$$MoodStatsImplCopyWith(
    _$MoodStatsImpl value,
    $Res Function(_$MoodStatsImpl) then,
  ) = __$$MoodStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    int userId,
    String mood,
    String date,
    int count,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class __$$MoodStatsImplCopyWithImpl<$Res>
    extends _$MoodStatsCopyWithImpl<$Res, _$MoodStatsImpl>
    implements _$$MoodStatsImplCopyWith<$Res> {
  __$$MoodStatsImplCopyWithImpl(
    _$MoodStatsImpl _value,
    $Res Function(_$MoodStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MoodStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? mood = null,
    Object? date = null,
    Object? count = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$MoodStatsImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        mood: null == mood
            ? _value.mood
            : mood // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
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
class _$MoodStatsImpl implements _MoodStats {
  const _$MoodStatsImpl({
    this.id,
    required this.userId,
    required this.mood,
    required this.date,
    this.count = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$MoodStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MoodStatsImplFromJson(json);

  @override
  final int? id;
  @override
  final int userId;
  @override
  final String mood;
  @override
  final String date;
  @override
  @JsonKey()
  final int count;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'MoodStats(id: $id, userId: $userId, mood: $mood, date: $date, count: $count, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MoodStatsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.count, count) || other.count == count) &&
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
    mood,
    date,
    count,
    createdAt,
    updatedAt,
  );

  /// Create a copy of MoodStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MoodStatsImplCopyWith<_$MoodStatsImpl> get copyWith =>
      __$$MoodStatsImplCopyWithImpl<_$MoodStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MoodStatsImplToJson(this);
  }
}

abstract class _MoodStats implements MoodStats {
  const factory _MoodStats({
    final int? id,
    required final int userId,
    required final String mood,
    required final String date,
    final int count,
    required final String createdAt,
    required final String updatedAt,
  }) = _$MoodStatsImpl;

  factory _MoodStats.fromJson(Map<String, dynamic> json) =
      _$MoodStatsImpl.fromJson;

  @override
  int? get id;
  @override
  int get userId;
  @override
  String get mood;
  @override
  String get date;
  @override
  int get count;
  @override
  String get createdAt;
  @override
  String get updatedAt;

  /// Create a copy of MoodStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MoodStatsImplCopyWith<_$MoodStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateMoodStatsDto _$CreateMoodStatsDtoFromJson(Map<String, dynamic> json) {
  return _CreateMoodStatsDto.fromJson(json);
}

/// @nodoc
mixin _$CreateMoodStatsDto {
  int get userId => throw _privateConstructorUsedError;
  String get mood => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Serializes this CreateMoodStatsDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateMoodStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateMoodStatsDtoCopyWith<CreateMoodStatsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateMoodStatsDtoCopyWith<$Res> {
  factory $CreateMoodStatsDtoCopyWith(
    CreateMoodStatsDto value,
    $Res Function(CreateMoodStatsDto) then,
  ) = _$CreateMoodStatsDtoCopyWithImpl<$Res, CreateMoodStatsDto>;
  @useResult
  $Res call({int userId, String mood, String date, int count});
}

/// @nodoc
class _$CreateMoodStatsDtoCopyWithImpl<$Res, $Val extends CreateMoodStatsDto>
    implements $CreateMoodStatsDtoCopyWith<$Res> {
  _$CreateMoodStatsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateMoodStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? mood = null,
    Object? date = null,
    Object? count = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            mood: null == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateMoodStatsDtoImplCopyWith<$Res>
    implements $CreateMoodStatsDtoCopyWith<$Res> {
  factory _$$CreateMoodStatsDtoImplCopyWith(
    _$CreateMoodStatsDtoImpl value,
    $Res Function(_$CreateMoodStatsDtoImpl) then,
  ) = __$$CreateMoodStatsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int userId, String mood, String date, int count});
}

/// @nodoc
class __$$CreateMoodStatsDtoImplCopyWithImpl<$Res>
    extends _$CreateMoodStatsDtoCopyWithImpl<$Res, _$CreateMoodStatsDtoImpl>
    implements _$$CreateMoodStatsDtoImplCopyWith<$Res> {
  __$$CreateMoodStatsDtoImplCopyWithImpl(
    _$CreateMoodStatsDtoImpl _value,
    $Res Function(_$CreateMoodStatsDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateMoodStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? mood = null,
    Object? date = null,
    Object? count = null,
  }) {
    return _then(
      _$CreateMoodStatsDtoImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        mood: null == mood
            ? _value.mood
            : mood // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateMoodStatsDtoImpl implements _CreateMoodStatsDto {
  const _$CreateMoodStatsDtoImpl({
    required this.userId,
    required this.mood,
    required this.date,
    this.count = 1,
  });

  factory _$CreateMoodStatsDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateMoodStatsDtoImplFromJson(json);

  @override
  final int userId;
  @override
  final String mood;
  @override
  final String date;
  @override
  @JsonKey()
  final int count;

  @override
  String toString() {
    return 'CreateMoodStatsDto(userId: $userId, mood: $mood, date: $date, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateMoodStatsDtoImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, mood, date, count);

  /// Create a copy of CreateMoodStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateMoodStatsDtoImplCopyWith<_$CreateMoodStatsDtoImpl> get copyWith =>
      __$$CreateMoodStatsDtoImplCopyWithImpl<_$CreateMoodStatsDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateMoodStatsDtoImplToJson(this);
  }
}

abstract class _CreateMoodStatsDto implements CreateMoodStatsDto {
  const factory _CreateMoodStatsDto({
    required final int userId,
    required final String mood,
    required final String date,
    final int count,
  }) = _$CreateMoodStatsDtoImpl;

  factory _CreateMoodStatsDto.fromJson(Map<String, dynamic> json) =
      _$CreateMoodStatsDtoImpl.fromJson;

  @override
  int get userId;
  @override
  String get mood;
  @override
  String get date;
  @override
  int get count;

  /// Create a copy of CreateMoodStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateMoodStatsDtoImplCopyWith<_$CreateMoodStatsDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateMoodStatsDto _$UpdateMoodStatsDtoFromJson(Map<String, dynamic> json) {
  return _UpdateMoodStatsDto.fromJson(json);
}

/// @nodoc
mixin _$UpdateMoodStatsDto {
  String? get mood => throw _privateConstructorUsedError;
  String? get date => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;

  /// Serializes this UpdateMoodStatsDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateMoodStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateMoodStatsDtoCopyWith<UpdateMoodStatsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateMoodStatsDtoCopyWith<$Res> {
  factory $UpdateMoodStatsDtoCopyWith(
    UpdateMoodStatsDto value,
    $Res Function(UpdateMoodStatsDto) then,
  ) = _$UpdateMoodStatsDtoCopyWithImpl<$Res, UpdateMoodStatsDto>;
  @useResult
  $Res call({String? mood, String? date, int? count});
}

/// @nodoc
class _$UpdateMoodStatsDtoCopyWithImpl<$Res, $Val extends UpdateMoodStatsDto>
    implements $UpdateMoodStatsDtoCopyWith<$Res> {
  _$UpdateMoodStatsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateMoodStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mood = freezed,
    Object? date = freezed,
    Object? count = freezed,
  }) {
    return _then(
      _value.copyWith(
            mood: freezed == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                      as String?,
            date: freezed == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String?,
            count: freezed == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpdateMoodStatsDtoImplCopyWith<$Res>
    implements $UpdateMoodStatsDtoCopyWith<$Res> {
  factory _$$UpdateMoodStatsDtoImplCopyWith(
    _$UpdateMoodStatsDtoImpl value,
    $Res Function(_$UpdateMoodStatsDtoImpl) then,
  ) = __$$UpdateMoodStatsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? mood, String? date, int? count});
}

/// @nodoc
class __$$UpdateMoodStatsDtoImplCopyWithImpl<$Res>
    extends _$UpdateMoodStatsDtoCopyWithImpl<$Res, _$UpdateMoodStatsDtoImpl>
    implements _$$UpdateMoodStatsDtoImplCopyWith<$Res> {
  __$$UpdateMoodStatsDtoImplCopyWithImpl(
    _$UpdateMoodStatsDtoImpl _value,
    $Res Function(_$UpdateMoodStatsDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateMoodStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mood = freezed,
    Object? date = freezed,
    Object? count = freezed,
  }) {
    return _then(
      _$UpdateMoodStatsDtoImpl(
        mood: freezed == mood
            ? _value.mood
            : mood // ignore: cast_nullable_to_non_nullable
                  as String?,
        date: freezed == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String?,
        count: freezed == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateMoodStatsDtoImpl implements _UpdateMoodStatsDto {
  const _$UpdateMoodStatsDtoImpl({this.mood, this.date, this.count});

  factory _$UpdateMoodStatsDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateMoodStatsDtoImplFromJson(json);

  @override
  final String? mood;
  @override
  final String? date;
  @override
  final int? count;

  @override
  String toString() {
    return 'UpdateMoodStatsDto(mood: $mood, date: $date, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateMoodStatsDtoImpl &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, mood, date, count);

  /// Create a copy of UpdateMoodStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateMoodStatsDtoImplCopyWith<_$UpdateMoodStatsDtoImpl> get copyWith =>
      __$$UpdateMoodStatsDtoImplCopyWithImpl<_$UpdateMoodStatsDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateMoodStatsDtoImplToJson(this);
  }
}

abstract class _UpdateMoodStatsDto implements UpdateMoodStatsDto {
  const factory _UpdateMoodStatsDto({
    final String? mood,
    final String? date,
    final int? count,
  }) = _$UpdateMoodStatsDtoImpl;

  factory _UpdateMoodStatsDto.fromJson(Map<String, dynamic> json) =
      _$UpdateMoodStatsDtoImpl.fromJson;

  @override
  String? get mood;
  @override
  String? get date;
  @override
  int? get count;

  /// Create a copy of UpdateMoodStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateMoodStatsDtoImplCopyWith<_$UpdateMoodStatsDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
