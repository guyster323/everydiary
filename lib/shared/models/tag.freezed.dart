// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Tag _$TagFromJson(Map<String, dynamic> json) {
  return _Tag.fromJson(json);
}

/// @nodoc
mixin _$Tag {
  int? get id => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get usageCount => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  /// Serializes this Tag to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TagCopyWith<Tag> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TagCopyWith<$Res> {
  factory $TagCopyWith(Tag value, $Res Function(Tag) then) =
      _$TagCopyWithImpl<$Res, Tag>;
  @useResult
  $Res call({
    int? id,
    int userId,
    String name,
    String color,
    String? icon,
    String? description,
    int usageCount,
    String createdAt,
    String updatedAt,
    bool isDeleted,
  });
}

/// @nodoc
class _$TagCopyWithImpl<$Res, $Val extends Tag> implements $TagCopyWith<$Res> {
  _$TagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? name = null,
    Object? color = null,
    Object? icon = freezed,
    Object? description = freezed,
    Object? usageCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isDeleted = null,
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: freezed == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            usageCount: null == usageCount
                ? _value.usageCount
                : usageCount // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$TagImplCopyWith<$Res> implements $TagCopyWith<$Res> {
  factory _$$TagImplCopyWith(_$TagImpl value, $Res Function(_$TagImpl) then) =
      __$$TagImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    int userId,
    String name,
    String color,
    String? icon,
    String? description,
    int usageCount,
    String createdAt,
    String updatedAt,
    bool isDeleted,
  });
}

/// @nodoc
class __$$TagImplCopyWithImpl<$Res> extends _$TagCopyWithImpl<$Res, _$TagImpl>
    implements _$$TagImplCopyWith<$Res> {
  __$$TagImplCopyWithImpl(_$TagImpl _value, $Res Function(_$TagImpl) _then)
    : super(_value, _then);

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? name = null,
    Object? color = null,
    Object? icon = freezed,
    Object? description = freezed,
    Object? usageCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isDeleted = null,
  }) {
    return _then(
      _$TagImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: freezed == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        usageCount: null == usageCount
            ? _value.usageCount
            : usageCount // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$TagImpl implements _Tag {
  const _$TagImpl({
    this.id,
    required this.userId,
    required this.name,
    this.color = '#6366F1',
    this.icon,
    this.description,
    this.usageCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  factory _$TagImpl.fromJson(Map<String, dynamic> json) =>
      _$$TagImplFromJson(json);

  @override
  final int? id;
  @override
  final int userId;
  @override
  final String name;
  @override
  @JsonKey()
  final String color;
  @override
  final String? icon;
  @override
  final String? description;
  @override
  @JsonKey()
  final int usageCount;
  @override
  final String createdAt;
  @override
  final String updatedAt;
  @override
  @JsonKey()
  final bool isDeleted;

  @override
  String toString() {
    return 'Tag(id: $id, userId: $userId, name: $name, color: $color, icon: $icon, description: $description, usageCount: $usageCount, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TagImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount) &&
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
    userId,
    name,
    color,
    icon,
    description,
    usageCount,
    createdAt,
    updatedAt,
    isDeleted,
  );

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TagImplCopyWith<_$TagImpl> get copyWith =>
      __$$TagImplCopyWithImpl<_$TagImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TagImplToJson(this);
  }
}

abstract class _Tag implements Tag {
  const factory _Tag({
    final int? id,
    required final int userId,
    required final String name,
    final String color,
    final String? icon,
    final String? description,
    final int usageCount,
    required final String createdAt,
    required final String updatedAt,
    final bool isDeleted,
  }) = _$TagImpl;

  factory _Tag.fromJson(Map<String, dynamic> json) = _$TagImpl.fromJson;

  @override
  int? get id;
  @override
  int get userId;
  @override
  String get name;
  @override
  String get color;
  @override
  String? get icon;
  @override
  String? get description;
  @override
  int get usageCount;
  @override
  String get createdAt;
  @override
  String get updatedAt;
  @override
  bool get isDeleted;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TagImplCopyWith<_$TagImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateTagDto _$CreateTagDtoFromJson(Map<String, dynamic> json) {
  return _CreateTagDto.fromJson(json);
}

/// @nodoc
mixin _$CreateTagDto {
  String get name => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;

  /// Serializes this CreateTagDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateTagDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateTagDtoCopyWith<CreateTagDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateTagDtoCopyWith<$Res> {
  factory $CreateTagDtoCopyWith(
    CreateTagDto value,
    $Res Function(CreateTagDto) then,
  ) = _$CreateTagDtoCopyWithImpl<$Res, CreateTagDto>;
  @useResult
  $Res call({String name, String? color});
}

/// @nodoc
class _$CreateTagDtoCopyWithImpl<$Res, $Val extends CreateTagDto>
    implements $CreateTagDtoCopyWith<$Res> {
  _$CreateTagDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateTagDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? color = freezed}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateTagDtoImplCopyWith<$Res>
    implements $CreateTagDtoCopyWith<$Res> {
  factory _$$CreateTagDtoImplCopyWith(
    _$CreateTagDtoImpl value,
    $Res Function(_$CreateTagDtoImpl) then,
  ) = __$$CreateTagDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String? color});
}

/// @nodoc
class __$$CreateTagDtoImplCopyWithImpl<$Res>
    extends _$CreateTagDtoCopyWithImpl<$Res, _$CreateTagDtoImpl>
    implements _$$CreateTagDtoImplCopyWith<$Res> {
  __$$CreateTagDtoImplCopyWithImpl(
    _$CreateTagDtoImpl _value,
    $Res Function(_$CreateTagDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateTagDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? color = freezed}) {
    return _then(
      _$CreateTagDtoImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateTagDtoImpl implements _CreateTagDto {
  const _$CreateTagDtoImpl({required this.name, this.color});

  factory _$CreateTagDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateTagDtoImplFromJson(json);

  @override
  final String name;
  @override
  final String? color;

  @override
  String toString() {
    return 'CreateTagDto(name: $name, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateTagDtoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.color, color) || other.color == color));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, color);

  /// Create a copy of CreateTagDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateTagDtoImplCopyWith<_$CreateTagDtoImpl> get copyWith =>
      __$$CreateTagDtoImplCopyWithImpl<_$CreateTagDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateTagDtoImplToJson(this);
  }
}

abstract class _CreateTagDto implements CreateTagDto {
  const factory _CreateTagDto({
    required final String name,
    final String? color,
  }) = _$CreateTagDtoImpl;

  factory _CreateTagDto.fromJson(Map<String, dynamic> json) =
      _$CreateTagDtoImpl.fromJson;

  @override
  String get name;
  @override
  String? get color;

  /// Create a copy of CreateTagDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateTagDtoImplCopyWith<_$CreateTagDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateTagDto _$UpdateTagDtoFromJson(Map<String, dynamic> json) {
  return _UpdateTagDto.fromJson(json);
}

/// @nodoc
mixin _$UpdateTagDto {
  String? get name => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;

  /// Serializes this UpdateTagDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateTagDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateTagDtoCopyWith<UpdateTagDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateTagDtoCopyWith<$Res> {
  factory $UpdateTagDtoCopyWith(
    UpdateTagDto value,
    $Res Function(UpdateTagDto) then,
  ) = _$UpdateTagDtoCopyWithImpl<$Res, UpdateTagDto>;
  @useResult
  $Res call({String? name, String? color});
}

/// @nodoc
class _$UpdateTagDtoCopyWithImpl<$Res, $Val extends UpdateTagDto>
    implements $UpdateTagDtoCopyWith<$Res> {
  _$UpdateTagDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateTagDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = freezed, Object? color = freezed}) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpdateTagDtoImplCopyWith<$Res>
    implements $UpdateTagDtoCopyWith<$Res> {
  factory _$$UpdateTagDtoImplCopyWith(
    _$UpdateTagDtoImpl value,
    $Res Function(_$UpdateTagDtoImpl) then,
  ) = __$$UpdateTagDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? name, String? color});
}

/// @nodoc
class __$$UpdateTagDtoImplCopyWithImpl<$Res>
    extends _$UpdateTagDtoCopyWithImpl<$Res, _$UpdateTagDtoImpl>
    implements _$$UpdateTagDtoImplCopyWith<$Res> {
  __$$UpdateTagDtoImplCopyWithImpl(
    _$UpdateTagDtoImpl _value,
    $Res Function(_$UpdateTagDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateTagDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = freezed, Object? color = freezed}) {
    return _then(
      _$UpdateTagDtoImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateTagDtoImpl implements _UpdateTagDto {
  const _$UpdateTagDtoImpl({this.name, this.color});

  factory _$UpdateTagDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateTagDtoImplFromJson(json);

  @override
  final String? name;
  @override
  final String? color;

  @override
  String toString() {
    return 'UpdateTagDto(name: $name, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateTagDtoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.color, color) || other.color == color));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, color);

  /// Create a copy of UpdateTagDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateTagDtoImplCopyWith<_$UpdateTagDtoImpl> get copyWith =>
      __$$UpdateTagDtoImplCopyWithImpl<_$UpdateTagDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateTagDtoImplToJson(this);
  }
}

abstract class _UpdateTagDto implements UpdateTagDto {
  const factory _UpdateTagDto({final String? name, final String? color}) =
      _$UpdateTagDtoImpl;

  factory _UpdateTagDto.fromJson(Map<String, dynamic> json) =
      _$UpdateTagDtoImpl.fromJson;

  @override
  String? get name;
  @override
  String? get color;

  /// Create a copy of UpdateTagDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateTagDtoImplCopyWith<_$UpdateTagDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DiaryTag _$DiaryTagFromJson(Map<String, dynamic> json) {
  return _DiaryTag.fromJson(json);
}

/// @nodoc
mixin _$DiaryTag {
  int? get id => throw _privateConstructorUsedError;
  int get diaryId => throw _privateConstructorUsedError;
  int get tagId => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this DiaryTag to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiaryTag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiaryTagCopyWith<DiaryTag> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiaryTagCopyWith<$Res> {
  factory $DiaryTagCopyWith(DiaryTag value, $Res Function(DiaryTag) then) =
      _$DiaryTagCopyWithImpl<$Res, DiaryTag>;
  @useResult
  $Res call({int? id, int diaryId, int tagId, String createdAt});
}

/// @nodoc
class _$DiaryTagCopyWithImpl<$Res, $Val extends DiaryTag>
    implements $DiaryTagCopyWith<$Res> {
  _$DiaryTagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiaryTag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? diaryId = null,
    Object? tagId = null,
    Object? createdAt = null,
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
            tagId: null == tagId
                ? _value.tagId
                : tagId // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DiaryTagImplCopyWith<$Res>
    implements $DiaryTagCopyWith<$Res> {
  factory _$$DiaryTagImplCopyWith(
    _$DiaryTagImpl value,
    $Res Function(_$DiaryTagImpl) then,
  ) = __$$DiaryTagImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, int diaryId, int tagId, String createdAt});
}

/// @nodoc
class __$$DiaryTagImplCopyWithImpl<$Res>
    extends _$DiaryTagCopyWithImpl<$Res, _$DiaryTagImpl>
    implements _$$DiaryTagImplCopyWith<$Res> {
  __$$DiaryTagImplCopyWithImpl(
    _$DiaryTagImpl _value,
    $Res Function(_$DiaryTagImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiaryTag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? diaryId = null,
    Object? tagId = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$DiaryTagImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        diaryId: null == diaryId
            ? _value.diaryId
            : diaryId // ignore: cast_nullable_to_non_nullable
                  as int,
        tagId: null == tagId
            ? _value.tagId
            : tagId // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DiaryTagImpl implements _DiaryTag {
  const _$DiaryTagImpl({
    this.id,
    required this.diaryId,
    required this.tagId,
    required this.createdAt,
  });

  factory _$DiaryTagImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiaryTagImplFromJson(json);

  @override
  final int? id;
  @override
  final int diaryId;
  @override
  final int tagId;
  @override
  final String createdAt;

  @override
  String toString() {
    return 'DiaryTag(id: $id, diaryId: $diaryId, tagId: $tagId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiaryTagImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.diaryId, diaryId) || other.diaryId == diaryId) &&
            (identical(other.tagId, tagId) || other.tagId == tagId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, diaryId, tagId, createdAt);

  /// Create a copy of DiaryTag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiaryTagImplCopyWith<_$DiaryTagImpl> get copyWith =>
      __$$DiaryTagImplCopyWithImpl<_$DiaryTagImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiaryTagImplToJson(this);
  }
}

abstract class _DiaryTag implements DiaryTag {
  const factory _DiaryTag({
    final int? id,
    required final int diaryId,
    required final int tagId,
    required final String createdAt,
  }) = _$DiaryTagImpl;

  factory _DiaryTag.fromJson(Map<String, dynamic> json) =
      _$DiaryTagImpl.fromJson;

  @override
  int? get id;
  @override
  int get diaryId;
  @override
  int get tagId;
  @override
  String get createdAt;

  /// Create a copy of DiaryTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiaryTagImplCopyWith<_$DiaryTagImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateDiaryTagDto _$CreateDiaryTagDtoFromJson(Map<String, dynamic> json) {
  return _CreateDiaryTagDto.fromJson(json);
}

/// @nodoc
mixin _$CreateDiaryTagDto {
  int get diaryId => throw _privateConstructorUsedError;
  int get tagId => throw _privateConstructorUsedError;

  /// Serializes this CreateDiaryTagDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateDiaryTagDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateDiaryTagDtoCopyWith<CreateDiaryTagDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateDiaryTagDtoCopyWith<$Res> {
  factory $CreateDiaryTagDtoCopyWith(
    CreateDiaryTagDto value,
    $Res Function(CreateDiaryTagDto) then,
  ) = _$CreateDiaryTagDtoCopyWithImpl<$Res, CreateDiaryTagDto>;
  @useResult
  $Res call({int diaryId, int tagId});
}

/// @nodoc
class _$CreateDiaryTagDtoCopyWithImpl<$Res, $Val extends CreateDiaryTagDto>
    implements $CreateDiaryTagDtoCopyWith<$Res> {
  _$CreateDiaryTagDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateDiaryTagDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? diaryId = null, Object? tagId = null}) {
    return _then(
      _value.copyWith(
            diaryId: null == diaryId
                ? _value.diaryId
                : diaryId // ignore: cast_nullable_to_non_nullable
                      as int,
            tagId: null == tagId
                ? _value.tagId
                : tagId // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateDiaryTagDtoImplCopyWith<$Res>
    implements $CreateDiaryTagDtoCopyWith<$Res> {
  factory _$$CreateDiaryTagDtoImplCopyWith(
    _$CreateDiaryTagDtoImpl value,
    $Res Function(_$CreateDiaryTagDtoImpl) then,
  ) = __$$CreateDiaryTagDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int diaryId, int tagId});
}

/// @nodoc
class __$$CreateDiaryTagDtoImplCopyWithImpl<$Res>
    extends _$CreateDiaryTagDtoCopyWithImpl<$Res, _$CreateDiaryTagDtoImpl>
    implements _$$CreateDiaryTagDtoImplCopyWith<$Res> {
  __$$CreateDiaryTagDtoImplCopyWithImpl(
    _$CreateDiaryTagDtoImpl _value,
    $Res Function(_$CreateDiaryTagDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateDiaryTagDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? diaryId = null, Object? tagId = null}) {
    return _then(
      _$CreateDiaryTagDtoImpl(
        diaryId: null == diaryId
            ? _value.diaryId
            : diaryId // ignore: cast_nullable_to_non_nullable
                  as int,
        tagId: null == tagId
            ? _value.tagId
            : tagId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateDiaryTagDtoImpl implements _CreateDiaryTagDto {
  const _$CreateDiaryTagDtoImpl({required this.diaryId, required this.tagId});

  factory _$CreateDiaryTagDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateDiaryTagDtoImplFromJson(json);

  @override
  final int diaryId;
  @override
  final int tagId;

  @override
  String toString() {
    return 'CreateDiaryTagDto(diaryId: $diaryId, tagId: $tagId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateDiaryTagDtoImpl &&
            (identical(other.diaryId, diaryId) || other.diaryId == diaryId) &&
            (identical(other.tagId, tagId) || other.tagId == tagId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, diaryId, tagId);

  /// Create a copy of CreateDiaryTagDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateDiaryTagDtoImplCopyWith<_$CreateDiaryTagDtoImpl> get copyWith =>
      __$$CreateDiaryTagDtoImplCopyWithImpl<_$CreateDiaryTagDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateDiaryTagDtoImplToJson(this);
  }
}

abstract class _CreateDiaryTagDto implements CreateDiaryTagDto {
  const factory _CreateDiaryTagDto({
    required final int diaryId,
    required final int tagId,
  }) = _$CreateDiaryTagDtoImpl;

  factory _CreateDiaryTagDto.fromJson(Map<String, dynamic> json) =
      _$CreateDiaryTagDtoImpl.fromJson;

  @override
  int get diaryId;
  @override
  int get tagId;

  /// Create a copy of CreateDiaryTagDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateDiaryTagDtoImplCopyWith<_$CreateDiaryTagDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
