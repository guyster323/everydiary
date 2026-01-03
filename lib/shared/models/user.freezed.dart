// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  int? get id => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get birthDate => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String get timezone => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  String get theme => throw _privateConstructorUsedError;
  bool get notificationEnabled => throw _privateConstructorUsedError;
  String get notificationTime => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;
  String? get lastLoginAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError; // 인증 관련 필드
  bool get isEmailVerified => throw _privateConstructorUsedError;
  List<String> get roles => throw _privateConstructorUsedError;
  String? get passwordHash => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    int? id,
    String? email,
    String name,
    String? avatarUrl,
    String? bio,
    String? birthDate,
    String? gender,
    String timezone,
    String language,
    String theme,
    bool notificationEnabled,
    String notificationTime,
    String createdAt,
    String updatedAt,
    String? lastLoginAt,
    bool isDeleted,
    bool isEmailVerified,
    List<String> roles,
    String? passwordHash,
  });
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? email = freezed,
    Object? name = null,
    Object? avatarUrl = freezed,
    Object? bio = freezed,
    Object? birthDate = freezed,
    Object? gender = freezed,
    Object? timezone = null,
    Object? language = null,
    Object? theme = null,
    Object? notificationEnabled = null,
    Object? notificationTime = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastLoginAt = freezed,
    Object? isDeleted = null,
    Object? isEmailVerified = null,
    Object? roles = null,
    Object? passwordHash = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            birthDate: freezed == birthDate
                ? _value.birthDate
                : birthDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String?,
            timezone: null == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                      as String,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
            theme: null == theme
                ? _value.theme
                : theme // ignore: cast_nullable_to_non_nullable
                      as String,
            notificationEnabled: null == notificationEnabled
                ? _value.notificationEnabled
                : notificationEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            notificationTime: null == notificationTime
                ? _value.notificationTime
                : notificationTime // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String,
            lastLoginAt: freezed == lastLoginAt
                ? _value.lastLoginAt
                : lastLoginAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            isDeleted: null == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            isEmailVerified: null == isEmailVerified
                ? _value.isEmailVerified
                : isEmailVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            roles: null == roles
                ? _value.roles
                : roles // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            passwordHash: freezed == passwordHash
                ? _value.passwordHash
                : passwordHash // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String? email,
    String name,
    String? avatarUrl,
    String? bio,
    String? birthDate,
    String? gender,
    String timezone,
    String language,
    String theme,
    bool notificationEnabled,
    String notificationTime,
    String createdAt,
    String updatedAt,
    String? lastLoginAt,
    bool isDeleted,
    bool isEmailVerified,
    List<String> roles,
    String? passwordHash,
  });
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? email = freezed,
    Object? name = null,
    Object? avatarUrl = freezed,
    Object? bio = freezed,
    Object? birthDate = freezed,
    Object? gender = freezed,
    Object? timezone = null,
    Object? language = null,
    Object? theme = null,
    Object? notificationEnabled = null,
    Object? notificationTime = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastLoginAt = freezed,
    Object? isDeleted = null,
    Object? isEmailVerified = null,
    Object? roles = null,
    Object? passwordHash = freezed,
  }) {
    return _then(
      _$UserImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        birthDate: freezed == birthDate
            ? _value.birthDate
            : birthDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String?,
        timezone: null == timezone
            ? _value.timezone
            : timezone // ignore: cast_nullable_to_non_nullable
                  as String,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
        theme: null == theme
            ? _value.theme
            : theme // ignore: cast_nullable_to_non_nullable
                  as String,
        notificationEnabled: null == notificationEnabled
            ? _value.notificationEnabled
            : notificationEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        notificationTime: null == notificationTime
            ? _value.notificationTime
            : notificationTime // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String,
        lastLoginAt: freezed == lastLoginAt
            ? _value.lastLoginAt
            : lastLoginAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        isDeleted: null == isDeleted
            ? _value.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        isEmailVerified: null == isEmailVerified
            ? _value.isEmailVerified
            : isEmailVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        roles: null == roles
            ? _value._roles
            : roles // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        passwordHash: freezed == passwordHash
            ? _value.passwordHash
            : passwordHash // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl({
    this.id,
    this.email,
    required this.name,
    this.avatarUrl,
    this.bio,
    this.birthDate,
    this.gender,
    this.timezone = 'Asia/Seoul',
    this.language = 'ko',
    this.theme = 'system',
    this.notificationEnabled = true,
    this.notificationTime = '21:00',
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.isDeleted = false,
    this.isEmailVerified = false,
    final List<String> roles = const [],
    this.passwordHash,
  }) : _roles = roles;

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final int? id;
  @override
  final String? email;
  @override
  final String name;
  @override
  final String? avatarUrl;
  @override
  final String? bio;
  @override
  final String? birthDate;
  @override
  final String? gender;
  @override
  @JsonKey()
  final String timezone;
  @override
  @JsonKey()
  final String language;
  @override
  @JsonKey()
  final String theme;
  @override
  @JsonKey()
  final bool notificationEnabled;
  @override
  @JsonKey()
  final String notificationTime;
  @override
  final String createdAt;
  @override
  final String updatedAt;
  @override
  final String? lastLoginAt;
  @override
  @JsonKey()
  final bool isDeleted;
  // 인증 관련 필드
  @override
  @JsonKey()
  final bool isEmailVerified;
  final List<String> _roles;
  @override
  @JsonKey()
  List<String> get roles {
    if (_roles is EqualUnmodifiableListView) return _roles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_roles);
  }

  @override
  final String? passwordHash;

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, avatarUrl: $avatarUrl, bio: $bio, birthDate: $birthDate, gender: $gender, timezone: $timezone, language: $language, theme: $theme, notificationEnabled: $notificationEnabled, notificationTime: $notificationTime, createdAt: $createdAt, updatedAt: $updatedAt, lastLoginAt: $lastLoginAt, isDeleted: $isDeleted, isEmailVerified: $isEmailVerified, roles: $roles, passwordHash: $passwordHash)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.notificationEnabled, notificationEnabled) ||
                other.notificationEnabled == notificationEnabled) &&
            (identical(other.notificationTime, notificationTime) ||
                other.notificationTime == notificationTime) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.isEmailVerified, isEmailVerified) ||
                other.isEmailVerified == isEmailVerified) &&
            const DeepCollectionEquality().equals(other._roles, _roles) &&
            (identical(other.passwordHash, passwordHash) ||
                other.passwordHash == passwordHash));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    email,
    name,
    avatarUrl,
    bio,
    birthDate,
    gender,
    timezone,
    language,
    theme,
    notificationEnabled,
    notificationTime,
    createdAt,
    updatedAt,
    lastLoginAt,
    isDeleted,
    isEmailVerified,
    const DeepCollectionEquality().hash(_roles),
    passwordHash,
  ]);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User implements User {
  const factory _User({
    final int? id,
    final String? email,
    required final String name,
    final String? avatarUrl,
    final String? bio,
    final String? birthDate,
    final String? gender,
    final String timezone,
    final String language,
    final String theme,
    final bool notificationEnabled,
    final String notificationTime,
    required final String createdAt,
    required final String updatedAt,
    final String? lastLoginAt,
    final bool isDeleted,
    final bool isEmailVerified,
    final List<String> roles,
    final String? passwordHash,
  }) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  int? get id;
  @override
  String? get email;
  @override
  String get name;
  @override
  String? get avatarUrl;
  @override
  String? get bio;
  @override
  String? get birthDate;
  @override
  String? get gender;
  @override
  String get timezone;
  @override
  String get language;
  @override
  String get theme;
  @override
  bool get notificationEnabled;
  @override
  String get notificationTime;
  @override
  String get createdAt;
  @override
  String get updatedAt;
  @override
  String? get lastLoginAt;
  @override
  bool get isDeleted; // 인증 관련 필드
  @override
  bool get isEmailVerified;
  @override
  List<String> get roles;
  @override
  String? get passwordHash;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateUserDto _$CreateUserDtoFromJson(Map<String, dynamic> json) {
  return _CreateUserDto.fromJson(json);
}

/// @nodoc
mixin _$CreateUserDto {
  String? get email => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this CreateUserDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateUserDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateUserDtoCopyWith<CreateUserDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateUserDtoCopyWith<$Res> {
  factory $CreateUserDtoCopyWith(
    CreateUserDto value,
    $Res Function(CreateUserDto) then,
  ) = _$CreateUserDtoCopyWithImpl<$Res, CreateUserDto>;
  @useResult
  $Res call({String? email, String name});
}

/// @nodoc
class _$CreateUserDtoCopyWithImpl<$Res, $Val extends CreateUserDto>
    implements $CreateUserDtoCopyWith<$Res> {
  _$CreateUserDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateUserDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = freezed, Object? name = null}) {
    return _then(
      _value.copyWith(
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateUserDtoImplCopyWith<$Res>
    implements $CreateUserDtoCopyWith<$Res> {
  factory _$$CreateUserDtoImplCopyWith(
    _$CreateUserDtoImpl value,
    $Res Function(_$CreateUserDtoImpl) then,
  ) = __$$CreateUserDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? email, String name});
}

/// @nodoc
class __$$CreateUserDtoImplCopyWithImpl<$Res>
    extends _$CreateUserDtoCopyWithImpl<$Res, _$CreateUserDtoImpl>
    implements _$$CreateUserDtoImplCopyWith<$Res> {
  __$$CreateUserDtoImplCopyWithImpl(
    _$CreateUserDtoImpl _value,
    $Res Function(_$CreateUserDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateUserDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = freezed, Object? name = null}) {
    return _then(
      _$CreateUserDtoImpl(
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateUserDtoImpl implements _CreateUserDto {
  const _$CreateUserDtoImpl({this.email, required this.name});

  factory _$CreateUserDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateUserDtoImplFromJson(json);

  @override
  final String? email;
  @override
  final String name;

  @override
  String toString() {
    return 'CreateUserDto(email: $email, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateUserDtoImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, name);

  /// Create a copy of CreateUserDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateUserDtoImplCopyWith<_$CreateUserDtoImpl> get copyWith =>
      __$$CreateUserDtoImplCopyWithImpl<_$CreateUserDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateUserDtoImplToJson(this);
  }
}

abstract class _CreateUserDto implements CreateUserDto {
  const factory _CreateUserDto({
    final String? email,
    required final String name,
  }) = _$CreateUserDtoImpl;

  factory _CreateUserDto.fromJson(Map<String, dynamic> json) =
      _$CreateUserDtoImpl.fromJson;

  @override
  String? get email;
  @override
  String get name;

  /// Create a copy of CreateUserDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateUserDtoImplCopyWith<_$CreateUserDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateUserDto _$UpdateUserDtoFromJson(Map<String, dynamic> json) {
  return _UpdateUserDto.fromJson(json);
}

/// @nodoc
mixin _$UpdateUserDto {
  String? get email => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;

  /// Serializes this UpdateUserDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateUserDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateUserDtoCopyWith<UpdateUserDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateUserDtoCopyWith<$Res> {
  factory $UpdateUserDtoCopyWith(
    UpdateUserDto value,
    $Res Function(UpdateUserDto) then,
  ) = _$UpdateUserDtoCopyWithImpl<$Res, UpdateUserDto>;
  @useResult
  $Res call({String? email, String? name});
}

/// @nodoc
class _$UpdateUserDtoCopyWithImpl<$Res, $Val extends UpdateUserDto>
    implements $UpdateUserDtoCopyWith<$Res> {
  _$UpdateUserDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateUserDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = freezed, Object? name = freezed}) {
    return _then(
      _value.copyWith(
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpdateUserDtoImplCopyWith<$Res>
    implements $UpdateUserDtoCopyWith<$Res> {
  factory _$$UpdateUserDtoImplCopyWith(
    _$UpdateUserDtoImpl value,
    $Res Function(_$UpdateUserDtoImpl) then,
  ) = __$$UpdateUserDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? email, String? name});
}

/// @nodoc
class __$$UpdateUserDtoImplCopyWithImpl<$Res>
    extends _$UpdateUserDtoCopyWithImpl<$Res, _$UpdateUserDtoImpl>
    implements _$$UpdateUserDtoImplCopyWith<$Res> {
  __$$UpdateUserDtoImplCopyWithImpl(
    _$UpdateUserDtoImpl _value,
    $Res Function(_$UpdateUserDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateUserDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = freezed, Object? name = freezed}) {
    return _then(
      _$UpdateUserDtoImpl(
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateUserDtoImpl implements _UpdateUserDto {
  const _$UpdateUserDtoImpl({this.email, this.name});

  factory _$UpdateUserDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateUserDtoImplFromJson(json);

  @override
  final String? email;
  @override
  final String? name;

  @override
  String toString() {
    return 'UpdateUserDto(email: $email, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateUserDtoImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, name);

  /// Create a copy of UpdateUserDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateUserDtoImplCopyWith<_$UpdateUserDtoImpl> get copyWith =>
      __$$UpdateUserDtoImplCopyWithImpl<_$UpdateUserDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateUserDtoImplToJson(this);
  }
}

abstract class _UpdateUserDto implements UpdateUserDto {
  const factory _UpdateUserDto({final String? email, final String? name}) =
      _$UpdateUserDtoImpl;

  factory _UpdateUserDto.fromJson(Map<String, dynamic> json) =
      _$UpdateUserDtoImpl.fromJson;

  @override
  String? get email;
  @override
  String? get name;

  /// Create a copy of UpdateUserDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateUserDtoImplCopyWith<_$UpdateUserDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
