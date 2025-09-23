// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BackupHistory _$BackupHistoryFromJson(Map<String, dynamic> json) {
  return _BackupHistory.fromJson(json);
}

/// @nodoc
mixin _$BackupHistory {
  int? get id => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  String get backupType => throw _privateConstructorUsedError;
  String? get filePath => throw _privateConstructorUsedError;
  int? get fileSize => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String? get completedAt => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this BackupHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BackupHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BackupHistoryCopyWith<BackupHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupHistoryCopyWith<$Res> {
  factory $BackupHistoryCopyWith(
    BackupHistory value,
    $Res Function(BackupHistory) then,
  ) = _$BackupHistoryCopyWithImpl<$Res, BackupHistory>;
  @useResult
  $Res call({
    int? id,
    int userId,
    String backupType,
    String? filePath,
    int? fileSize,
    String status,
    String createdAt,
    String? completedAt,
    String? errorMessage,
  });
}

/// @nodoc
class _$BackupHistoryCopyWithImpl<$Res, $Val extends BackupHistory>
    implements $BackupHistoryCopyWith<$Res> {
  _$BackupHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? backupType = null,
    Object? filePath = freezed,
    Object? fileSize = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? completedAt = freezed,
    Object? errorMessage = freezed,
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
            backupType: null == backupType
                ? _value.backupType
                : backupType // ignore: cast_nullable_to_non_nullable
                      as String,
            filePath: freezed == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileSize: freezed == fileSize
                ? _value.fileSize
                : fileSize // ignore: cast_nullable_to_non_nullable
                      as int?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BackupHistoryImplCopyWith<$Res>
    implements $BackupHistoryCopyWith<$Res> {
  factory _$$BackupHistoryImplCopyWith(
    _$BackupHistoryImpl value,
    $Res Function(_$BackupHistoryImpl) then,
  ) = __$$BackupHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    int userId,
    String backupType,
    String? filePath,
    int? fileSize,
    String status,
    String createdAt,
    String? completedAt,
    String? errorMessage,
  });
}

/// @nodoc
class __$$BackupHistoryImplCopyWithImpl<$Res>
    extends _$BackupHistoryCopyWithImpl<$Res, _$BackupHistoryImpl>
    implements _$$BackupHistoryImplCopyWith<$Res> {
  __$$BackupHistoryImplCopyWithImpl(
    _$BackupHistoryImpl _value,
    $Res Function(_$BackupHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BackupHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? backupType = null,
    Object? filePath = freezed,
    Object? fileSize = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? completedAt = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$BackupHistoryImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        backupType: null == backupType
            ? _value.backupType
            : backupType // ignore: cast_nullable_to_non_nullable
                  as String,
        filePath: freezed == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileSize: freezed == fileSize
            ? _value.fileSize
            : fileSize // ignore: cast_nullable_to_non_nullable
                  as int?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BackupHistoryImpl implements _BackupHistory {
  const _$BackupHistoryImpl({
    this.id,
    required this.userId,
    required this.backupType,
    this.filePath,
    this.fileSize,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
  });

  factory _$BackupHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackupHistoryImplFromJson(json);

  @override
  final int? id;
  @override
  final int userId;
  @override
  final String backupType;
  @override
  final String? filePath;
  @override
  final int? fileSize;
  @override
  final String status;
  @override
  final String createdAt;
  @override
  final String? completedAt;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'BackupHistory(id: $id, userId: $userId, backupType: $backupType, filePath: $filePath, fileSize: $fileSize, status: $status, createdAt: $createdAt, completedAt: $completedAt, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupHistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.backupType, backupType) ||
                other.backupType == backupType) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    backupType,
    filePath,
    fileSize,
    status,
    createdAt,
    completedAt,
    errorMessage,
  );

  /// Create a copy of BackupHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupHistoryImplCopyWith<_$BackupHistoryImpl> get copyWith =>
      __$$BackupHistoryImplCopyWithImpl<_$BackupHistoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BackupHistoryImplToJson(this);
  }
}

abstract class _BackupHistory implements BackupHistory {
  const factory _BackupHistory({
    final int? id,
    required final int userId,
    required final String backupType,
    final String? filePath,
    final int? fileSize,
    required final String status,
    required final String createdAt,
    final String? completedAt,
    final String? errorMessage,
  }) = _$BackupHistoryImpl;

  factory _BackupHistory.fromJson(Map<String, dynamic> json) =
      _$BackupHistoryImpl.fromJson;

  @override
  int? get id;
  @override
  int get userId;
  @override
  String get backupType;
  @override
  String? get filePath;
  @override
  int? get fileSize;
  @override
  String get status;
  @override
  String get createdAt;
  @override
  String? get completedAt;
  @override
  String? get errorMessage;

  /// Create a copy of BackupHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupHistoryImplCopyWith<_$BackupHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateBackupHistoryDto _$CreateBackupHistoryDtoFromJson(
  Map<String, dynamic> json,
) {
  return _CreateBackupHistoryDto.fromJson(json);
}

/// @nodoc
mixin _$CreateBackupHistoryDto {
  int get userId => throw _privateConstructorUsedError;
  String get backupType => throw _privateConstructorUsedError;
  String? get filePath => throw _privateConstructorUsedError;
  int? get fileSize => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this CreateBackupHistoryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateBackupHistoryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateBackupHistoryDtoCopyWith<CreateBackupHistoryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateBackupHistoryDtoCopyWith<$Res> {
  factory $CreateBackupHistoryDtoCopyWith(
    CreateBackupHistoryDto value,
    $Res Function(CreateBackupHistoryDto) then,
  ) = _$CreateBackupHistoryDtoCopyWithImpl<$Res, CreateBackupHistoryDto>;
  @useResult
  $Res call({
    int userId,
    String backupType,
    String? filePath,
    int? fileSize,
    String status,
    String? errorMessage,
  });
}

/// @nodoc
class _$CreateBackupHistoryDtoCopyWithImpl<
  $Res,
  $Val extends CreateBackupHistoryDto
>
    implements $CreateBackupHistoryDtoCopyWith<$Res> {
  _$CreateBackupHistoryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateBackupHistoryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? backupType = null,
    Object? filePath = freezed,
    Object? fileSize = freezed,
    Object? status = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            backupType: null == backupType
                ? _value.backupType
                : backupType // ignore: cast_nullable_to_non_nullable
                      as String,
            filePath: freezed == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileSize: freezed == fileSize
                ? _value.fileSize
                : fileSize // ignore: cast_nullable_to_non_nullable
                      as int?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateBackupHistoryDtoImplCopyWith<$Res>
    implements $CreateBackupHistoryDtoCopyWith<$Res> {
  factory _$$CreateBackupHistoryDtoImplCopyWith(
    _$CreateBackupHistoryDtoImpl value,
    $Res Function(_$CreateBackupHistoryDtoImpl) then,
  ) = __$$CreateBackupHistoryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int userId,
    String backupType,
    String? filePath,
    int? fileSize,
    String status,
    String? errorMessage,
  });
}

/// @nodoc
class __$$CreateBackupHistoryDtoImplCopyWithImpl<$Res>
    extends
        _$CreateBackupHistoryDtoCopyWithImpl<$Res, _$CreateBackupHistoryDtoImpl>
    implements _$$CreateBackupHistoryDtoImplCopyWith<$Res> {
  __$$CreateBackupHistoryDtoImplCopyWithImpl(
    _$CreateBackupHistoryDtoImpl _value,
    $Res Function(_$CreateBackupHistoryDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateBackupHistoryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? backupType = null,
    Object? filePath = freezed,
    Object? fileSize = freezed,
    Object? status = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$CreateBackupHistoryDtoImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        backupType: null == backupType
            ? _value.backupType
            : backupType // ignore: cast_nullable_to_non_nullable
                  as String,
        filePath: freezed == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileSize: freezed == fileSize
            ? _value.fileSize
            : fileSize // ignore: cast_nullable_to_non_nullable
                  as int?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateBackupHistoryDtoImpl implements _CreateBackupHistoryDto {
  const _$CreateBackupHistoryDtoImpl({
    required this.userId,
    required this.backupType,
    this.filePath,
    this.fileSize,
    required this.status,
    this.errorMessage,
  });

  factory _$CreateBackupHistoryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateBackupHistoryDtoImplFromJson(json);

  @override
  final int userId;
  @override
  final String backupType;
  @override
  final String? filePath;
  @override
  final int? fileSize;
  @override
  final String status;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'CreateBackupHistoryDto(userId: $userId, backupType: $backupType, filePath: $filePath, fileSize: $fileSize, status: $status, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateBackupHistoryDtoImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.backupType, backupType) ||
                other.backupType == backupType) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    backupType,
    filePath,
    fileSize,
    status,
    errorMessage,
  );

  /// Create a copy of CreateBackupHistoryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateBackupHistoryDtoImplCopyWith<_$CreateBackupHistoryDtoImpl>
  get copyWith =>
      __$$CreateBackupHistoryDtoImplCopyWithImpl<_$CreateBackupHistoryDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateBackupHistoryDtoImplToJson(this);
  }
}

abstract class _CreateBackupHistoryDto implements CreateBackupHistoryDto {
  const factory _CreateBackupHistoryDto({
    required final int userId,
    required final String backupType,
    final String? filePath,
    final int? fileSize,
    required final String status,
    final String? errorMessage,
  }) = _$CreateBackupHistoryDtoImpl;

  factory _CreateBackupHistoryDto.fromJson(Map<String, dynamic> json) =
      _$CreateBackupHistoryDtoImpl.fromJson;

  @override
  int get userId;
  @override
  String get backupType;
  @override
  String? get filePath;
  @override
  int? get fileSize;
  @override
  String get status;
  @override
  String? get errorMessage;

  /// Create a copy of CreateBackupHistoryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateBackupHistoryDtoImplCopyWith<_$CreateBackupHistoryDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

UpdateBackupHistoryDto _$UpdateBackupHistoryDtoFromJson(
  Map<String, dynamic> json,
) {
  return _UpdateBackupHistoryDto.fromJson(json);
}

/// @nodoc
mixin _$UpdateBackupHistoryDto {
  String? get filePath => throw _privateConstructorUsedError;
  int? get fileSize => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get completedAt => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this UpdateBackupHistoryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateBackupHistoryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateBackupHistoryDtoCopyWith<UpdateBackupHistoryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateBackupHistoryDtoCopyWith<$Res> {
  factory $UpdateBackupHistoryDtoCopyWith(
    UpdateBackupHistoryDto value,
    $Res Function(UpdateBackupHistoryDto) then,
  ) = _$UpdateBackupHistoryDtoCopyWithImpl<$Res, UpdateBackupHistoryDto>;
  @useResult
  $Res call({
    String? filePath,
    int? fileSize,
    String? status,
    String? completedAt,
    String? errorMessage,
  });
}

/// @nodoc
class _$UpdateBackupHistoryDtoCopyWithImpl<
  $Res,
  $Val extends UpdateBackupHistoryDto
>
    implements $UpdateBackupHistoryDtoCopyWith<$Res> {
  _$UpdateBackupHistoryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateBackupHistoryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filePath = freezed,
    Object? fileSize = freezed,
    Object? status = freezed,
    Object? completedAt = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            filePath: freezed == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileSize: freezed == fileSize
                ? _value.fileSize
                : fileSize // ignore: cast_nullable_to_non_nullable
                      as int?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpdateBackupHistoryDtoImplCopyWith<$Res>
    implements $UpdateBackupHistoryDtoCopyWith<$Res> {
  factory _$$UpdateBackupHistoryDtoImplCopyWith(
    _$UpdateBackupHistoryDtoImpl value,
    $Res Function(_$UpdateBackupHistoryDtoImpl) then,
  ) = __$$UpdateBackupHistoryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? filePath,
    int? fileSize,
    String? status,
    String? completedAt,
    String? errorMessage,
  });
}

/// @nodoc
class __$$UpdateBackupHistoryDtoImplCopyWithImpl<$Res>
    extends
        _$UpdateBackupHistoryDtoCopyWithImpl<$Res, _$UpdateBackupHistoryDtoImpl>
    implements _$$UpdateBackupHistoryDtoImplCopyWith<$Res> {
  __$$UpdateBackupHistoryDtoImplCopyWithImpl(
    _$UpdateBackupHistoryDtoImpl _value,
    $Res Function(_$UpdateBackupHistoryDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateBackupHistoryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filePath = freezed,
    Object? fileSize = freezed,
    Object? status = freezed,
    Object? completedAt = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$UpdateBackupHistoryDtoImpl(
        filePath: freezed == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileSize: freezed == fileSize
            ? _value.fileSize
            : fileSize // ignore: cast_nullable_to_non_nullable
                  as int?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateBackupHistoryDtoImpl implements _UpdateBackupHistoryDto {
  const _$UpdateBackupHistoryDtoImpl({
    this.filePath,
    this.fileSize,
    this.status,
    this.completedAt,
    this.errorMessage,
  });

  factory _$UpdateBackupHistoryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateBackupHistoryDtoImplFromJson(json);

  @override
  final String? filePath;
  @override
  final int? fileSize;
  @override
  final String? status;
  @override
  final String? completedAt;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'UpdateBackupHistoryDto(filePath: $filePath, fileSize: $fileSize, status: $status, completedAt: $completedAt, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateBackupHistoryDtoImpl &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    filePath,
    fileSize,
    status,
    completedAt,
    errorMessage,
  );

  /// Create a copy of UpdateBackupHistoryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateBackupHistoryDtoImplCopyWith<_$UpdateBackupHistoryDtoImpl>
  get copyWith =>
      __$$UpdateBackupHistoryDtoImplCopyWithImpl<_$UpdateBackupHistoryDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateBackupHistoryDtoImplToJson(this);
  }
}

abstract class _UpdateBackupHistoryDto implements UpdateBackupHistoryDto {
  const factory _UpdateBackupHistoryDto({
    final String? filePath,
    final int? fileSize,
    final String? status,
    final String? completedAt,
    final String? errorMessage,
  }) = _$UpdateBackupHistoryDtoImpl;

  factory _UpdateBackupHistoryDto.fromJson(Map<String, dynamic> json) =
      _$UpdateBackupHistoryDtoImpl.fromJson;

  @override
  String? get filePath;
  @override
  int? get fileSize;
  @override
  String? get status;
  @override
  String? get completedAt;
  @override
  String? get errorMessage;

  /// Create a copy of UpdateBackupHistoryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateBackupHistoryDtoImplCopyWith<_$UpdateBackupHistoryDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}
