// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Attachment _$AttachmentFromJson(Map<String, dynamic> json) {
  return _Attachment.fromJson(json);
}

/// @nodoc
mixin _$Attachment {
  int? get id => throw _privateConstructorUsedError;
  int get diaryId => throw _privateConstructorUsedError;
  String get filePath => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String get fileType => throw _privateConstructorUsedError;
  int? get fileSize => throw _privateConstructorUsedError;
  String? get mimeType => throw _privateConstructorUsedError;
  String? get thumbnailPath => throw _privateConstructorUsedError;
  int? get width => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError;
  int? get duration => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  /// Serializes this Attachment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Attachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttachmentCopyWith<Attachment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttachmentCopyWith<$Res> {
  factory $AttachmentCopyWith(
    Attachment value,
    $Res Function(Attachment) then,
  ) = _$AttachmentCopyWithImpl<$Res, Attachment>;
  @useResult
  $Res call({
    int? id,
    int diaryId,
    String filePath,
    String fileName,
    String fileType,
    int? fileSize,
    String? mimeType,
    String? thumbnailPath,
    int? width,
    int? height,
    int? duration,
    String createdAt,
    String updatedAt,
    bool isDeleted,
  });
}

/// @nodoc
class _$AttachmentCopyWithImpl<$Res, $Val extends Attachment>
    implements $AttachmentCopyWith<$Res> {
  _$AttachmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Attachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? diaryId = null,
    Object? filePath = null,
    Object? fileName = null,
    Object? fileType = null,
    Object? fileSize = freezed,
    Object? mimeType = freezed,
    Object? thumbnailPath = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? duration = freezed,
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
            diaryId: null == diaryId
                ? _value.diaryId
                : diaryId // ignore: cast_nullable_to_non_nullable
                      as int,
            filePath: null == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String,
            fileName: null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String,
            fileType: null == fileType
                ? _value.fileType
                : fileType // ignore: cast_nullable_to_non_nullable
                      as String,
            fileSize: freezed == fileSize
                ? _value.fileSize
                : fileSize // ignore: cast_nullable_to_non_nullable
                      as int?,
            mimeType: freezed == mimeType
                ? _value.mimeType
                : mimeType // ignore: cast_nullable_to_non_nullable
                      as String?,
            thumbnailPath: freezed == thumbnailPath
                ? _value.thumbnailPath
                : thumbnailPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            width: freezed == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as int?,
            height: freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as int?,
            duration: freezed == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int?,
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
abstract class _$$AttachmentImplCopyWith<$Res>
    implements $AttachmentCopyWith<$Res> {
  factory _$$AttachmentImplCopyWith(
    _$AttachmentImpl value,
    $Res Function(_$AttachmentImpl) then,
  ) = __$$AttachmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    int diaryId,
    String filePath,
    String fileName,
    String fileType,
    int? fileSize,
    String? mimeType,
    String? thumbnailPath,
    int? width,
    int? height,
    int? duration,
    String createdAt,
    String updatedAt,
    bool isDeleted,
  });
}

/// @nodoc
class __$$AttachmentImplCopyWithImpl<$Res>
    extends _$AttachmentCopyWithImpl<$Res, _$AttachmentImpl>
    implements _$$AttachmentImplCopyWith<$Res> {
  __$$AttachmentImplCopyWithImpl(
    _$AttachmentImpl _value,
    $Res Function(_$AttachmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Attachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? diaryId = null,
    Object? filePath = null,
    Object? fileName = null,
    Object? fileType = null,
    Object? fileSize = freezed,
    Object? mimeType = freezed,
    Object? thumbnailPath = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? duration = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isDeleted = null,
  }) {
    return _then(
      _$AttachmentImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        diaryId: null == diaryId
            ? _value.diaryId
            : diaryId // ignore: cast_nullable_to_non_nullable
                  as int,
        filePath: null == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String,
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        fileType: null == fileType
            ? _value.fileType
            : fileType // ignore: cast_nullable_to_non_nullable
                  as String,
        fileSize: freezed == fileSize
            ? _value.fileSize
            : fileSize // ignore: cast_nullable_to_non_nullable
                  as int?,
        mimeType: freezed == mimeType
            ? _value.mimeType
            : mimeType // ignore: cast_nullable_to_non_nullable
                  as String?,
        thumbnailPath: freezed == thumbnailPath
            ? _value.thumbnailPath
            : thumbnailPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        width: freezed == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as int?,
        height: freezed == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int?,
        duration: freezed == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int?,
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
class _$AttachmentImpl implements _Attachment {
  const _$AttachmentImpl({
    this.id,
    required this.diaryId,
    required this.filePath,
    required this.fileName,
    required this.fileType,
    this.fileSize,
    this.mimeType,
    this.thumbnailPath,
    this.width,
    this.height,
    this.duration,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  factory _$AttachmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttachmentImplFromJson(json);

  @override
  final int? id;
  @override
  final int diaryId;
  @override
  final String filePath;
  @override
  final String fileName;
  @override
  final String fileType;
  @override
  final int? fileSize;
  @override
  final String? mimeType;
  @override
  final String? thumbnailPath;
  @override
  final int? width;
  @override
  final int? height;
  @override
  final int? duration;
  @override
  final String createdAt;
  @override
  final String updatedAt;
  @override
  @JsonKey()
  final bool isDeleted;

  @override
  String toString() {
    return 'Attachment(id: $id, diaryId: $diaryId, filePath: $filePath, fileName: $fileName, fileType: $fileType, fileSize: $fileSize, mimeType: $mimeType, thumbnailPath: $thumbnailPath, width: $width, height: $height, duration: $duration, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttachmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.diaryId, diaryId) || other.diaryId == diaryId) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileType, fileType) ||
                other.fileType == fileType) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.thumbnailPath, thumbnailPath) ||
                other.thumbnailPath == thumbnailPath) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
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
    filePath,
    fileName,
    fileType,
    fileSize,
    mimeType,
    thumbnailPath,
    width,
    height,
    duration,
    createdAt,
    updatedAt,
    isDeleted,
  );

  /// Create a copy of Attachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttachmentImplCopyWith<_$AttachmentImpl> get copyWith =>
      __$$AttachmentImplCopyWithImpl<_$AttachmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttachmentImplToJson(this);
  }
}

abstract class _Attachment implements Attachment {
  const factory _Attachment({
    final int? id,
    required final int diaryId,
    required final String filePath,
    required final String fileName,
    required final String fileType,
    final int? fileSize,
    final String? mimeType,
    final String? thumbnailPath,
    final int? width,
    final int? height,
    final int? duration,
    required final String createdAt,
    required final String updatedAt,
    final bool isDeleted,
  }) = _$AttachmentImpl;

  factory _Attachment.fromJson(Map<String, dynamic> json) =
      _$AttachmentImpl.fromJson;

  @override
  int? get id;
  @override
  int get diaryId;
  @override
  String get filePath;
  @override
  String get fileName;
  @override
  String get fileType;
  @override
  int? get fileSize;
  @override
  String? get mimeType;
  @override
  String? get thumbnailPath;
  @override
  int? get width;
  @override
  int? get height;
  @override
  int? get duration;
  @override
  String get createdAt;
  @override
  String get updatedAt;
  @override
  bool get isDeleted;

  /// Create a copy of Attachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttachmentImplCopyWith<_$AttachmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateAttachmentDto _$CreateAttachmentDtoFromJson(Map<String, dynamic> json) {
  return _CreateAttachmentDto.fromJson(json);
}

/// @nodoc
mixin _$CreateAttachmentDto {
  int get diaryId => throw _privateConstructorUsedError;
  String get filePath => throw _privateConstructorUsedError;
  String get fileType => throw _privateConstructorUsedError;
  int? get fileSize => throw _privateConstructorUsedError;

  /// Serializes this CreateAttachmentDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateAttachmentDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateAttachmentDtoCopyWith<CreateAttachmentDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateAttachmentDtoCopyWith<$Res> {
  factory $CreateAttachmentDtoCopyWith(
    CreateAttachmentDto value,
    $Res Function(CreateAttachmentDto) then,
  ) = _$CreateAttachmentDtoCopyWithImpl<$Res, CreateAttachmentDto>;
  @useResult
  $Res call({int diaryId, String filePath, String fileType, int? fileSize});
}

/// @nodoc
class _$CreateAttachmentDtoCopyWithImpl<$Res, $Val extends CreateAttachmentDto>
    implements $CreateAttachmentDtoCopyWith<$Res> {
  _$CreateAttachmentDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateAttachmentDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? diaryId = null,
    Object? filePath = null,
    Object? fileType = null,
    Object? fileSize = freezed,
  }) {
    return _then(
      _value.copyWith(
            diaryId: null == diaryId
                ? _value.diaryId
                : diaryId // ignore: cast_nullable_to_non_nullable
                      as int,
            filePath: null == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String,
            fileType: null == fileType
                ? _value.fileType
                : fileType // ignore: cast_nullable_to_non_nullable
                      as String,
            fileSize: freezed == fileSize
                ? _value.fileSize
                : fileSize // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateAttachmentDtoImplCopyWith<$Res>
    implements $CreateAttachmentDtoCopyWith<$Res> {
  factory _$$CreateAttachmentDtoImplCopyWith(
    _$CreateAttachmentDtoImpl value,
    $Res Function(_$CreateAttachmentDtoImpl) then,
  ) = __$$CreateAttachmentDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int diaryId, String filePath, String fileType, int? fileSize});
}

/// @nodoc
class __$$CreateAttachmentDtoImplCopyWithImpl<$Res>
    extends _$CreateAttachmentDtoCopyWithImpl<$Res, _$CreateAttachmentDtoImpl>
    implements _$$CreateAttachmentDtoImplCopyWith<$Res> {
  __$$CreateAttachmentDtoImplCopyWithImpl(
    _$CreateAttachmentDtoImpl _value,
    $Res Function(_$CreateAttachmentDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateAttachmentDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? diaryId = null,
    Object? filePath = null,
    Object? fileType = null,
    Object? fileSize = freezed,
  }) {
    return _then(
      _$CreateAttachmentDtoImpl(
        diaryId: null == diaryId
            ? _value.diaryId
            : diaryId // ignore: cast_nullable_to_non_nullable
                  as int,
        filePath: null == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String,
        fileType: null == fileType
            ? _value.fileType
            : fileType // ignore: cast_nullable_to_non_nullable
                  as String,
        fileSize: freezed == fileSize
            ? _value.fileSize
            : fileSize // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateAttachmentDtoImpl implements _CreateAttachmentDto {
  const _$CreateAttachmentDtoImpl({
    required this.diaryId,
    required this.filePath,
    required this.fileType,
    this.fileSize,
  });

  factory _$CreateAttachmentDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateAttachmentDtoImplFromJson(json);

  @override
  final int diaryId;
  @override
  final String filePath;
  @override
  final String fileType;
  @override
  final int? fileSize;

  @override
  String toString() {
    return 'CreateAttachmentDto(diaryId: $diaryId, filePath: $filePath, fileType: $fileType, fileSize: $fileSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateAttachmentDtoImpl &&
            (identical(other.diaryId, diaryId) || other.diaryId == diaryId) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.fileType, fileType) ||
                other.fileType == fileType) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, diaryId, filePath, fileType, fileSize);

  /// Create a copy of CreateAttachmentDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateAttachmentDtoImplCopyWith<_$CreateAttachmentDtoImpl> get copyWith =>
      __$$CreateAttachmentDtoImplCopyWithImpl<_$CreateAttachmentDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateAttachmentDtoImplToJson(this);
  }
}

abstract class _CreateAttachmentDto implements CreateAttachmentDto {
  const factory _CreateAttachmentDto({
    required final int diaryId,
    required final String filePath,
    required final String fileType,
    final int? fileSize,
  }) = _$CreateAttachmentDtoImpl;

  factory _CreateAttachmentDto.fromJson(Map<String, dynamic> json) =
      _$CreateAttachmentDtoImpl.fromJson;

  @override
  int get diaryId;
  @override
  String get filePath;
  @override
  String get fileType;
  @override
  int? get fileSize;

  /// Create a copy of CreateAttachmentDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateAttachmentDtoImplCopyWith<_$CreateAttachmentDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateAttachmentDto _$UpdateAttachmentDtoFromJson(Map<String, dynamic> json) {
  return _UpdateAttachmentDto.fromJson(json);
}

/// @nodoc
mixin _$UpdateAttachmentDto {
  String? get filePath => throw _privateConstructorUsedError;
  String? get fileType => throw _privateConstructorUsedError;
  int? get fileSize => throw _privateConstructorUsedError;

  /// Serializes this UpdateAttachmentDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateAttachmentDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateAttachmentDtoCopyWith<UpdateAttachmentDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateAttachmentDtoCopyWith<$Res> {
  factory $UpdateAttachmentDtoCopyWith(
    UpdateAttachmentDto value,
    $Res Function(UpdateAttachmentDto) then,
  ) = _$UpdateAttachmentDtoCopyWithImpl<$Res, UpdateAttachmentDto>;
  @useResult
  $Res call({String? filePath, String? fileType, int? fileSize});
}

/// @nodoc
class _$UpdateAttachmentDtoCopyWithImpl<$Res, $Val extends UpdateAttachmentDto>
    implements $UpdateAttachmentDtoCopyWith<$Res> {
  _$UpdateAttachmentDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateAttachmentDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filePath = freezed,
    Object? fileType = freezed,
    Object? fileSize = freezed,
  }) {
    return _then(
      _value.copyWith(
            filePath: freezed == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileType: freezed == fileType
                ? _value.fileType
                : fileType // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileSize: freezed == fileSize
                ? _value.fileSize
                : fileSize // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpdateAttachmentDtoImplCopyWith<$Res>
    implements $UpdateAttachmentDtoCopyWith<$Res> {
  factory _$$UpdateAttachmentDtoImplCopyWith(
    _$UpdateAttachmentDtoImpl value,
    $Res Function(_$UpdateAttachmentDtoImpl) then,
  ) = __$$UpdateAttachmentDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? filePath, String? fileType, int? fileSize});
}

/// @nodoc
class __$$UpdateAttachmentDtoImplCopyWithImpl<$Res>
    extends _$UpdateAttachmentDtoCopyWithImpl<$Res, _$UpdateAttachmentDtoImpl>
    implements _$$UpdateAttachmentDtoImplCopyWith<$Res> {
  __$$UpdateAttachmentDtoImplCopyWithImpl(
    _$UpdateAttachmentDtoImpl _value,
    $Res Function(_$UpdateAttachmentDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateAttachmentDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filePath = freezed,
    Object? fileType = freezed,
    Object? fileSize = freezed,
  }) {
    return _then(
      _$UpdateAttachmentDtoImpl(
        filePath: freezed == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileType: freezed == fileType
            ? _value.fileType
            : fileType // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileSize: freezed == fileSize
            ? _value.fileSize
            : fileSize // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateAttachmentDtoImpl implements _UpdateAttachmentDto {
  const _$UpdateAttachmentDtoImpl({
    this.filePath,
    this.fileType,
    this.fileSize,
  });

  factory _$UpdateAttachmentDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateAttachmentDtoImplFromJson(json);

  @override
  final String? filePath;
  @override
  final String? fileType;
  @override
  final int? fileSize;

  @override
  String toString() {
    return 'UpdateAttachmentDto(filePath: $filePath, fileType: $fileType, fileSize: $fileSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateAttachmentDtoImpl &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.fileType, fileType) ||
                other.fileType == fileType) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, filePath, fileType, fileSize);

  /// Create a copy of UpdateAttachmentDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateAttachmentDtoImplCopyWith<_$UpdateAttachmentDtoImpl> get copyWith =>
      __$$UpdateAttachmentDtoImplCopyWithImpl<_$UpdateAttachmentDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateAttachmentDtoImplToJson(this);
  }
}

abstract class _UpdateAttachmentDto implements UpdateAttachmentDto {
  const factory _UpdateAttachmentDto({
    final String? filePath,
    final String? fileType,
    final int? fileSize,
  }) = _$UpdateAttachmentDtoImpl;

  factory _UpdateAttachmentDto.fromJson(Map<String, dynamic> json) =
      _$UpdateAttachmentDtoImpl.fromJson;

  @override
  String? get filePath;
  @override
  String? get fileType;
  @override
  int? get fileSize;

  /// Create a copy of UpdateAttachmentDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateAttachmentDtoImplCopyWith<_$UpdateAttachmentDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
