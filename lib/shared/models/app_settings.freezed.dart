// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) {
  return _AppSettings.fromJson(json);
}

/// @nodoc
mixin _$AppSettings {
  int? get id => throw _privateConstructorUsedError;
  String get key => throw _privateConstructorUsedError;
  String? get value => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
    AppSettings value,
    $Res Function(AppSettings) then,
  ) = _$AppSettingsCopyWithImpl<$Res, AppSettings>;
  @useResult
  $Res call({
    int? id,
    String key,
    String? value,
    String type,
    String? description,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res, $Val extends AppSettings>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? key = null,
    Object? value = freezed,
    Object? type = null,
    Object? description = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
            value: freezed == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
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
abstract class _$$AppSettingsImplCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$$AppSettingsImplCopyWith(
    _$AppSettingsImpl value,
    $Res Function(_$AppSettingsImpl) then,
  ) = __$$AppSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String key,
    String? value,
    String type,
    String? description,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class __$$AppSettingsImplCopyWithImpl<$Res>
    extends _$AppSettingsCopyWithImpl<$Res, _$AppSettingsImpl>
    implements _$$AppSettingsImplCopyWith<$Res> {
  __$$AppSettingsImplCopyWithImpl(
    _$AppSettingsImpl _value,
    $Res Function(_$AppSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? key = null,
    Object? value = freezed,
    Object? type = null,
    Object? description = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$AppSettingsImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        value: freezed == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
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
class _$AppSettingsImpl implements _AppSettings {
  const _$AppSettingsImpl({
    this.id,
    required this.key,
    this.value,
    required this.type,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$AppSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingsImplFromJson(json);

  @override
  final int? id;
  @override
  final String key;
  @override
  final String? value;
  @override
  final String type;
  @override
  final String? description;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'AppSettings(id: $id, key: $key, value: $value, type: $type, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
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
    key,
    value,
    type,
    description,
    createdAt,
    updatedAt,
  );

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      __$$AppSettingsImplCopyWithImpl<_$AppSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingsImplToJson(this);
  }
}

abstract class _AppSettings implements AppSettings {
  const factory _AppSettings({
    final int? id,
    required final String key,
    final String? value,
    required final String type,
    final String? description,
    required final String createdAt,
    required final String updatedAt,
  }) = _$AppSettingsImpl;

  factory _AppSettings.fromJson(Map<String, dynamic> json) =
      _$AppSettingsImpl.fromJson;

  @override
  int? get id;
  @override
  String get key;
  @override
  String? get value;
  @override
  String get type;
  @override
  String? get description;
  @override
  String get createdAt;
  @override
  String get updatedAt;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateAppSettingsDto _$CreateAppSettingsDtoFromJson(Map<String, dynamic> json) {
  return _CreateAppSettingsDto.fromJson(json);
}

/// @nodoc
mixin _$CreateAppSettingsDto {
  String get key => throw _privateConstructorUsedError;
  String? get value => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this CreateAppSettingsDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateAppSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateAppSettingsDtoCopyWith<CreateAppSettingsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateAppSettingsDtoCopyWith<$Res> {
  factory $CreateAppSettingsDtoCopyWith(
    CreateAppSettingsDto value,
    $Res Function(CreateAppSettingsDto) then,
  ) = _$CreateAppSettingsDtoCopyWithImpl<$Res, CreateAppSettingsDto>;
  @useResult
  $Res call({String key, String? value, String type, String? description});
}

/// @nodoc
class _$CreateAppSettingsDtoCopyWithImpl<
  $Res,
  $Val extends CreateAppSettingsDto
>
    implements $CreateAppSettingsDtoCopyWith<$Res> {
  _$CreateAppSettingsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateAppSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? value = freezed,
    Object? type = null,
    Object? description = freezed,
  }) {
    return _then(
      _value.copyWith(
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
            value: freezed == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateAppSettingsDtoImplCopyWith<$Res>
    implements $CreateAppSettingsDtoCopyWith<$Res> {
  factory _$$CreateAppSettingsDtoImplCopyWith(
    _$CreateAppSettingsDtoImpl value,
    $Res Function(_$CreateAppSettingsDtoImpl) then,
  ) = __$$CreateAppSettingsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, String? value, String type, String? description});
}

/// @nodoc
class __$$CreateAppSettingsDtoImplCopyWithImpl<$Res>
    extends _$CreateAppSettingsDtoCopyWithImpl<$Res, _$CreateAppSettingsDtoImpl>
    implements _$$CreateAppSettingsDtoImplCopyWith<$Res> {
  __$$CreateAppSettingsDtoImplCopyWithImpl(
    _$CreateAppSettingsDtoImpl _value,
    $Res Function(_$CreateAppSettingsDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateAppSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? value = freezed,
    Object? type = null,
    Object? description = freezed,
  }) {
    return _then(
      _$CreateAppSettingsDtoImpl(
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        value: freezed == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateAppSettingsDtoImpl implements _CreateAppSettingsDto {
  const _$CreateAppSettingsDtoImpl({
    required this.key,
    this.value,
    required this.type,
    this.description,
  });

  factory _$CreateAppSettingsDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateAppSettingsDtoImplFromJson(json);

  @override
  final String key;
  @override
  final String? value;
  @override
  final String type;
  @override
  final String? description;

  @override
  String toString() {
    return 'CreateAppSettingsDto(key: $key, value: $value, type: $type, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateAppSettingsDtoImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key, value, type, description);

  /// Create a copy of CreateAppSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateAppSettingsDtoImplCopyWith<_$CreateAppSettingsDtoImpl>
  get copyWith =>
      __$$CreateAppSettingsDtoImplCopyWithImpl<_$CreateAppSettingsDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateAppSettingsDtoImplToJson(this);
  }
}

abstract class _CreateAppSettingsDto implements CreateAppSettingsDto {
  const factory _CreateAppSettingsDto({
    required final String key,
    final String? value,
    required final String type,
    final String? description,
  }) = _$CreateAppSettingsDtoImpl;

  factory _CreateAppSettingsDto.fromJson(Map<String, dynamic> json) =
      _$CreateAppSettingsDtoImpl.fromJson;

  @override
  String get key;
  @override
  String? get value;
  @override
  String get type;
  @override
  String? get description;

  /// Create a copy of CreateAppSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateAppSettingsDtoImplCopyWith<_$CreateAppSettingsDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

UpdateAppSettingsDto _$UpdateAppSettingsDtoFromJson(Map<String, dynamic> json) {
  return _UpdateAppSettingsDto.fromJson(json);
}

/// @nodoc
mixin _$UpdateAppSettingsDto {
  String? get value => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this UpdateAppSettingsDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateAppSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateAppSettingsDtoCopyWith<UpdateAppSettingsDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateAppSettingsDtoCopyWith<$Res> {
  factory $UpdateAppSettingsDtoCopyWith(
    UpdateAppSettingsDto value,
    $Res Function(UpdateAppSettingsDto) then,
  ) = _$UpdateAppSettingsDtoCopyWithImpl<$Res, UpdateAppSettingsDto>;
  @useResult
  $Res call({String? value, String? type, String? description});
}

/// @nodoc
class _$UpdateAppSettingsDtoCopyWithImpl<
  $Res,
  $Val extends UpdateAppSettingsDto
>
    implements $UpdateAppSettingsDtoCopyWith<$Res> {
  _$UpdateAppSettingsDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateAppSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = freezed,
    Object? type = freezed,
    Object? description = freezed,
  }) {
    return _then(
      _value.copyWith(
            value: freezed == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpdateAppSettingsDtoImplCopyWith<$Res>
    implements $UpdateAppSettingsDtoCopyWith<$Res> {
  factory _$$UpdateAppSettingsDtoImplCopyWith(
    _$UpdateAppSettingsDtoImpl value,
    $Res Function(_$UpdateAppSettingsDtoImpl) then,
  ) = __$$UpdateAppSettingsDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? value, String? type, String? description});
}

/// @nodoc
class __$$UpdateAppSettingsDtoImplCopyWithImpl<$Res>
    extends _$UpdateAppSettingsDtoCopyWithImpl<$Res, _$UpdateAppSettingsDtoImpl>
    implements _$$UpdateAppSettingsDtoImplCopyWith<$Res> {
  __$$UpdateAppSettingsDtoImplCopyWithImpl(
    _$UpdateAppSettingsDtoImpl _value,
    $Res Function(_$UpdateAppSettingsDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateAppSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = freezed,
    Object? type = freezed,
    Object? description = freezed,
  }) {
    return _then(
      _$UpdateAppSettingsDtoImpl(
        value: freezed == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateAppSettingsDtoImpl implements _UpdateAppSettingsDto {
  const _$UpdateAppSettingsDtoImpl({this.value, this.type, this.description});

  factory _$UpdateAppSettingsDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateAppSettingsDtoImplFromJson(json);

  @override
  final String? value;
  @override
  final String? type;
  @override
  final String? description;

  @override
  String toString() {
    return 'UpdateAppSettingsDto(value: $value, type: $type, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateAppSettingsDtoImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, value, type, description);

  /// Create a copy of UpdateAppSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateAppSettingsDtoImplCopyWith<_$UpdateAppSettingsDtoImpl>
  get copyWith =>
      __$$UpdateAppSettingsDtoImplCopyWithImpl<_$UpdateAppSettingsDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateAppSettingsDtoImplToJson(this);
  }
}

abstract class _UpdateAppSettingsDto implements UpdateAppSettingsDto {
  const factory _UpdateAppSettingsDto({
    final String? value,
    final String? type,
    final String? description,
  }) = _$UpdateAppSettingsDtoImpl;

  factory _UpdateAppSettingsDto.fromJson(Map<String, dynamic> json) =
      _$UpdateAppSettingsDtoImpl.fromJson;

  @override
  String? get value;
  @override
  String? get type;
  @override
  String? get description;

  /// Create a copy of UpdateAppSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateAppSettingsDtoImplCopyWith<_$UpdateAppSettingsDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}
