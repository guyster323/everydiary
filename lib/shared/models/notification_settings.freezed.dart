// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NotificationSettings _$NotificationSettingsFromJson(Map<String, dynamic> json) {
  return _NotificationSettings.fromJson(json);
}

/// @nodoc
mixin _$NotificationSettings {
  int? get id => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  String? get time => throw _privateConstructorUsedError;
  String? get days => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationSettingsCopyWith<NotificationSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationSettingsCopyWith<$Res> {
  factory $NotificationSettingsCopyWith(
    NotificationSettings value,
    $Res Function(NotificationSettings) then,
  ) = _$NotificationSettingsCopyWithImpl<$Res, NotificationSettings>;
  @useResult
  $Res call({
    int? id,
    int userId,
    String type,
    bool enabled,
    String? time,
    String? days,
    String? message,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class _$NotificationSettingsCopyWithImpl<
  $Res,
  $Val extends NotificationSettings
>
    implements $NotificationSettingsCopyWith<$Res> {
  _$NotificationSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? type = null,
    Object? enabled = null,
    Object? time = freezed,
    Object? days = freezed,
    Object? message = freezed,
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
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            time: freezed == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String?,
            days: freezed == days
                ? _value.days
                : days // ignore: cast_nullable_to_non_nullable
                      as String?,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$NotificationSettingsImplCopyWith<$Res>
    implements $NotificationSettingsCopyWith<$Res> {
  factory _$$NotificationSettingsImplCopyWith(
    _$NotificationSettingsImpl value,
    $Res Function(_$NotificationSettingsImpl) then,
  ) = __$$NotificationSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    int userId,
    String type,
    bool enabled,
    String? time,
    String? days,
    String? message,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class __$$NotificationSettingsImplCopyWithImpl<$Res>
    extends _$NotificationSettingsCopyWithImpl<$Res, _$NotificationSettingsImpl>
    implements _$$NotificationSettingsImplCopyWith<$Res> {
  __$$NotificationSettingsImplCopyWithImpl(
    _$NotificationSettingsImpl _value,
    $Res Function(_$NotificationSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? type = null,
    Object? enabled = null,
    Object? time = freezed,
    Object? days = freezed,
    Object? message = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$NotificationSettingsImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        time: freezed == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String?,
        days: freezed == days
            ? _value.days
            : days // ignore: cast_nullable_to_non_nullable
                  as String?,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$NotificationSettingsImpl implements _NotificationSettings {
  const _$NotificationSettingsImpl({
    this.id,
    required this.userId,
    required this.type,
    this.enabled = true,
    this.time,
    this.days,
    this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$NotificationSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationSettingsImplFromJson(json);

  @override
  final int? id;
  @override
  final int userId;
  @override
  final String type;
  @override
  @JsonKey()
  final bool enabled;
  @override
  final String? time;
  @override
  final String? days;
  @override
  final String? message;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'NotificationSettings(id: $id, userId: $userId, type: $type, enabled: $enabled, time: $time, days: $days, message: $message, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationSettingsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.days, days) || other.days == days) &&
            (identical(other.message, message) || other.message == message) &&
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
    type,
    enabled,
    time,
    days,
    message,
    createdAt,
    updatedAt,
  );

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
  get copyWith =>
      __$$NotificationSettingsImplCopyWithImpl<_$NotificationSettingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationSettingsImplToJson(this);
  }
}

abstract class _NotificationSettings implements NotificationSettings {
  const factory _NotificationSettings({
    final int? id,
    required final int userId,
    required final String type,
    final bool enabled,
    final String? time,
    final String? days,
    final String? message,
    required final String createdAt,
    required final String updatedAt,
  }) = _$NotificationSettingsImpl;

  factory _NotificationSettings.fromJson(Map<String, dynamic> json) =
      _$NotificationSettingsImpl.fromJson;

  @override
  int? get id;
  @override
  int get userId;
  @override
  String get type;
  @override
  bool get enabled;
  @override
  String? get time;
  @override
  String? get days;
  @override
  String? get message;
  @override
  String get createdAt;
  @override
  String get updatedAt;

  /// Create a copy of NotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CreateNotificationSettingsDto _$CreateNotificationSettingsDtoFromJson(
  Map<String, dynamic> json,
) {
  return _CreateNotificationSettingsDto.fromJson(json);
}

/// @nodoc
mixin _$CreateNotificationSettingsDto {
  int get userId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  String? get time => throw _privateConstructorUsedError;
  String? get days => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  /// Serializes this CreateNotificationSettingsDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateNotificationSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateNotificationSettingsDtoCopyWith<CreateNotificationSettingsDto>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateNotificationSettingsDtoCopyWith<$Res> {
  factory $CreateNotificationSettingsDtoCopyWith(
    CreateNotificationSettingsDto value,
    $Res Function(CreateNotificationSettingsDto) then,
  ) =
      _$CreateNotificationSettingsDtoCopyWithImpl<
        $Res,
        CreateNotificationSettingsDto
      >;
  @useResult
  $Res call({
    int userId,
    String type,
    bool enabled,
    String? time,
    String? days,
    String? message,
  });
}

/// @nodoc
class _$CreateNotificationSettingsDtoCopyWithImpl<
  $Res,
  $Val extends CreateNotificationSettingsDto
>
    implements $CreateNotificationSettingsDtoCopyWith<$Res> {
  _$CreateNotificationSettingsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateNotificationSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? type = null,
    Object? enabled = null,
    Object? time = freezed,
    Object? days = freezed,
    Object? message = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            time: freezed == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String?,
            days: freezed == days
                ? _value.days
                : days // ignore: cast_nullable_to_non_nullable
                      as String?,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateNotificationSettingsDtoImplCopyWith<$Res>
    implements $CreateNotificationSettingsDtoCopyWith<$Res> {
  factory _$$CreateNotificationSettingsDtoImplCopyWith(
    _$CreateNotificationSettingsDtoImpl value,
    $Res Function(_$CreateNotificationSettingsDtoImpl) then,
  ) = __$$CreateNotificationSettingsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int userId,
    String type,
    bool enabled,
    String? time,
    String? days,
    String? message,
  });
}

/// @nodoc
class __$$CreateNotificationSettingsDtoImplCopyWithImpl<$Res>
    extends
        _$CreateNotificationSettingsDtoCopyWithImpl<
          $Res,
          _$CreateNotificationSettingsDtoImpl
        >
    implements _$$CreateNotificationSettingsDtoImplCopyWith<$Res> {
  __$$CreateNotificationSettingsDtoImplCopyWithImpl(
    _$CreateNotificationSettingsDtoImpl _value,
    $Res Function(_$CreateNotificationSettingsDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateNotificationSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? type = null,
    Object? enabled = null,
    Object? time = freezed,
    Object? days = freezed,
    Object? message = freezed,
  }) {
    return _then(
      _$CreateNotificationSettingsDtoImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        time: freezed == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String?,
        days: freezed == days
            ? _value.days
            : days // ignore: cast_nullable_to_non_nullable
                  as String?,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateNotificationSettingsDtoImpl
    implements _CreateNotificationSettingsDto {
  const _$CreateNotificationSettingsDtoImpl({
    required this.userId,
    required this.type,
    this.enabled = true,
    this.time,
    this.days,
    this.message,
  });

  factory _$CreateNotificationSettingsDtoImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CreateNotificationSettingsDtoImplFromJson(json);

  @override
  final int userId;
  @override
  final String type;
  @override
  @JsonKey()
  final bool enabled;
  @override
  final String? time;
  @override
  final String? days;
  @override
  final String? message;

  @override
  String toString() {
    return 'CreateNotificationSettingsDto(userId: $userId, type: $type, enabled: $enabled, time: $time, days: $days, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateNotificationSettingsDtoImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.days, days) || other.days == days) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, type, enabled, time, days, message);

  /// Create a copy of CreateNotificationSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateNotificationSettingsDtoImplCopyWith<
    _$CreateNotificationSettingsDtoImpl
  >
  get copyWith =>
      __$$CreateNotificationSettingsDtoImplCopyWithImpl<
        _$CreateNotificationSettingsDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateNotificationSettingsDtoImplToJson(this);
  }
}

abstract class _CreateNotificationSettingsDto
    implements CreateNotificationSettingsDto {
  const factory _CreateNotificationSettingsDto({
    required final int userId,
    required final String type,
    final bool enabled,
    final String? time,
    final String? days,
    final String? message,
  }) = _$CreateNotificationSettingsDtoImpl;

  factory _CreateNotificationSettingsDto.fromJson(Map<String, dynamic> json) =
      _$CreateNotificationSettingsDtoImpl.fromJson;

  @override
  int get userId;
  @override
  String get type;
  @override
  bool get enabled;
  @override
  String? get time;
  @override
  String? get days;
  @override
  String? get message;

  /// Create a copy of CreateNotificationSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateNotificationSettingsDtoImplCopyWith<
    _$CreateNotificationSettingsDtoImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

UpdateNotificationSettingsDto _$UpdateNotificationSettingsDtoFromJson(
  Map<String, dynamic> json,
) {
  return _UpdateNotificationSettingsDto.fromJson(json);
}

/// @nodoc
mixin _$UpdateNotificationSettingsDto {
  String? get type => throw _privateConstructorUsedError;
  bool? get enabled => throw _privateConstructorUsedError;
  String? get time => throw _privateConstructorUsedError;
  String? get days => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  /// Serializes this UpdateNotificationSettingsDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateNotificationSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateNotificationSettingsDtoCopyWith<UpdateNotificationSettingsDto>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateNotificationSettingsDtoCopyWith<$Res> {
  factory $UpdateNotificationSettingsDtoCopyWith(
    UpdateNotificationSettingsDto value,
    $Res Function(UpdateNotificationSettingsDto) then,
  ) =
      _$UpdateNotificationSettingsDtoCopyWithImpl<
        $Res,
        UpdateNotificationSettingsDto
      >;
  @useResult
  $Res call({
    String? type,
    bool? enabled,
    String? time,
    String? days,
    String? message,
  });
}

/// @nodoc
class _$UpdateNotificationSettingsDtoCopyWithImpl<
  $Res,
  $Val extends UpdateNotificationSettingsDto
>
    implements $UpdateNotificationSettingsDtoCopyWith<$Res> {
  _$UpdateNotificationSettingsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateNotificationSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
    Object? enabled = freezed,
    Object? time = freezed,
    Object? days = freezed,
    Object? message = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
            enabled: freezed == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool?,
            time: freezed == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String?,
            days: freezed == days
                ? _value.days
                : days // ignore: cast_nullable_to_non_nullable
                      as String?,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpdateNotificationSettingsDtoImplCopyWith<$Res>
    implements $UpdateNotificationSettingsDtoCopyWith<$Res> {
  factory _$$UpdateNotificationSettingsDtoImplCopyWith(
    _$UpdateNotificationSettingsDtoImpl value,
    $Res Function(_$UpdateNotificationSettingsDtoImpl) then,
  ) = __$$UpdateNotificationSettingsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? type,
    bool? enabled,
    String? time,
    String? days,
    String? message,
  });
}

/// @nodoc
class __$$UpdateNotificationSettingsDtoImplCopyWithImpl<$Res>
    extends
        _$UpdateNotificationSettingsDtoCopyWithImpl<
          $Res,
          _$UpdateNotificationSettingsDtoImpl
        >
    implements _$$UpdateNotificationSettingsDtoImplCopyWith<$Res> {
  __$$UpdateNotificationSettingsDtoImplCopyWithImpl(
    _$UpdateNotificationSettingsDtoImpl _value,
    $Res Function(_$UpdateNotificationSettingsDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateNotificationSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
    Object? enabled = freezed,
    Object? time = freezed,
    Object? days = freezed,
    Object? message = freezed,
  }) {
    return _then(
      _$UpdateNotificationSettingsDtoImpl(
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        enabled: freezed == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool?,
        time: freezed == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String?,
        days: freezed == days
            ? _value.days
            : days // ignore: cast_nullable_to_non_nullable
                  as String?,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateNotificationSettingsDtoImpl
    implements _UpdateNotificationSettingsDto {
  const _$UpdateNotificationSettingsDtoImpl({
    this.type,
    this.enabled,
    this.time,
    this.days,
    this.message,
  });

  factory _$UpdateNotificationSettingsDtoImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$UpdateNotificationSettingsDtoImplFromJson(json);

  @override
  final String? type;
  @override
  final bool? enabled;
  @override
  final String? time;
  @override
  final String? days;
  @override
  final String? message;

  @override
  String toString() {
    return 'UpdateNotificationSettingsDto(type: $type, enabled: $enabled, time: $time, days: $days, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateNotificationSettingsDtoImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.days, days) || other.days == days) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, enabled, time, days, message);

  /// Create a copy of UpdateNotificationSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateNotificationSettingsDtoImplCopyWith<
    _$UpdateNotificationSettingsDtoImpl
  >
  get copyWith =>
      __$$UpdateNotificationSettingsDtoImplCopyWithImpl<
        _$UpdateNotificationSettingsDtoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateNotificationSettingsDtoImplToJson(this);
  }
}

abstract class _UpdateNotificationSettingsDto
    implements UpdateNotificationSettingsDto {
  const factory _UpdateNotificationSettingsDto({
    final String? type,
    final bool? enabled,
    final String? time,
    final String? days,
    final String? message,
  }) = _$UpdateNotificationSettingsDtoImpl;

  factory _UpdateNotificationSettingsDto.fromJson(Map<String, dynamic> json) =
      _$UpdateNotificationSettingsDtoImpl.fromJson;

  @override
  String? get type;
  @override
  bool? get enabled;
  @override
  String? get time;
  @override
  String? get days;
  @override
  String? get message;

  /// Create a copy of UpdateNotificationSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateNotificationSettingsDtoImplCopyWith<
    _$UpdateNotificationSettingsDtoImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
