// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diary_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DiaryEntry _$DiaryEntryFromJson(Map<String, dynamic> json) {
  return _DiaryEntry.fromJson(json);
}

/// @nodoc
mixin _$DiaryEntry {
  int? get id => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  String? get mood => throw _privateConstructorUsedError;
  String? get weather => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  bool get isPrivate => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  int get wordCount => throw _privateConstructorUsedError;
  int get readingTime => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  List<Attachment> get attachments => throw _privateConstructorUsedError;
  List<Tag> get tags => throw _privateConstructorUsedError;

  /// Serializes this DiaryEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiaryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiaryEntryCopyWith<DiaryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiaryEntryCopyWith<$Res> {
  factory $DiaryEntryCopyWith(
    DiaryEntry value,
    $Res Function(DiaryEntry) then,
  ) = _$DiaryEntryCopyWithImpl<$Res, DiaryEntry>;
  @useResult
  $Res call({
    int? id,
    int userId,
    String? title,
    String content,
    String date,
    String? mood,
    String? weather,
    String? location,
    double? latitude,
    double? longitude,
    bool isPrivate,
    bool isFavorite,
    int wordCount,
    int readingTime,
    String createdAt,
    String updatedAt,
    bool isDeleted,
    List<Attachment> attachments,
    List<Tag> tags,
  });
}

/// @nodoc
class _$DiaryEntryCopyWithImpl<$Res, $Val extends DiaryEntry>
    implements $DiaryEntryCopyWith<$Res> {
  _$DiaryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiaryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? title = freezed,
    Object? content = null,
    Object? date = null,
    Object? mood = freezed,
    Object? weather = freezed,
    Object? location = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? isPrivate = null,
    Object? isFavorite = null,
    Object? wordCount = null,
    Object? readingTime = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isDeleted = null,
    Object? attachments = null,
    Object? tags = null,
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
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            mood: freezed == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                      as String?,
            weather: freezed == weather
                ? _value.weather
                : weather // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            isPrivate: null == isPrivate
                ? _value.isPrivate
                : isPrivate // ignore: cast_nullable_to_non_nullable
                      as bool,
            isFavorite: null == isFavorite
                ? _value.isFavorite
                : isFavorite // ignore: cast_nullable_to_non_nullable
                      as bool,
            wordCount: null == wordCount
                ? _value.wordCount
                : wordCount // ignore: cast_nullable_to_non_nullable
                      as int,
            readingTime: null == readingTime
                ? _value.readingTime
                : readingTime // ignore: cast_nullable_to_non_nullable
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
            attachments: null == attachments
                ? _value.attachments
                : attachments // ignore: cast_nullable_to_non_nullable
                      as List<Attachment>,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<Tag>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DiaryEntryImplCopyWith<$Res>
    implements $DiaryEntryCopyWith<$Res> {
  factory _$$DiaryEntryImplCopyWith(
    _$DiaryEntryImpl value,
    $Res Function(_$DiaryEntryImpl) then,
  ) = __$$DiaryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    int userId,
    String? title,
    String content,
    String date,
    String? mood,
    String? weather,
    String? location,
    double? latitude,
    double? longitude,
    bool isPrivate,
    bool isFavorite,
    int wordCount,
    int readingTime,
    String createdAt,
    String updatedAt,
    bool isDeleted,
    List<Attachment> attachments,
    List<Tag> tags,
  });
}

/// @nodoc
class __$$DiaryEntryImplCopyWithImpl<$Res>
    extends _$DiaryEntryCopyWithImpl<$Res, _$DiaryEntryImpl>
    implements _$$DiaryEntryImplCopyWith<$Res> {
  __$$DiaryEntryImplCopyWithImpl(
    _$DiaryEntryImpl _value,
    $Res Function(_$DiaryEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiaryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? title = freezed,
    Object? content = null,
    Object? date = null,
    Object? mood = freezed,
    Object? weather = freezed,
    Object? location = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? isPrivate = null,
    Object? isFavorite = null,
    Object? wordCount = null,
    Object? readingTime = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isDeleted = null,
    Object? attachments = null,
    Object? tags = null,
  }) {
    return _then(
      _$DiaryEntryImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        mood: freezed == mood
            ? _value.mood
            : mood // ignore: cast_nullable_to_non_nullable
                  as String?,
        weather: freezed == weather
            ? _value.weather
            : weather // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        isPrivate: null == isPrivate
            ? _value.isPrivate
            : isPrivate // ignore: cast_nullable_to_non_nullable
                  as bool,
        isFavorite: null == isFavorite
            ? _value.isFavorite
            : isFavorite // ignore: cast_nullable_to_non_nullable
                  as bool,
        wordCount: null == wordCount
            ? _value.wordCount
            : wordCount // ignore: cast_nullable_to_non_nullable
                  as int,
        readingTime: null == readingTime
            ? _value.readingTime
            : readingTime // ignore: cast_nullable_to_non_nullable
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
        attachments: null == attachments
            ? _value._attachments
            : attachments // ignore: cast_nullable_to_non_nullable
                  as List<Attachment>,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<Tag>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DiaryEntryImpl implements _DiaryEntry {
  const _$DiaryEntryImpl({
    this.id,
    required this.userId,
    this.title,
    required this.content,
    required this.date,
    this.mood,
    this.weather,
    this.location,
    this.latitude,
    this.longitude,
    this.isPrivate = false,
    this.isFavorite = false,
    this.wordCount = 0,
    this.readingTime = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    final List<Attachment> attachments = const [],
    final List<Tag> tags = const [],
  }) : _attachments = attachments,
       _tags = tags;

  factory _$DiaryEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiaryEntryImplFromJson(json);

  @override
  final int? id;
  @override
  final int userId;
  @override
  final String? title;
  @override
  final String content;
  @override
  final String date;
  @override
  final String? mood;
  @override
  final String? weather;
  @override
  final String? location;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey()
  final bool isPrivate;
  @override
  @JsonKey()
  final bool isFavorite;
  @override
  @JsonKey()
  final int wordCount;
  @override
  @JsonKey()
  final int readingTime;
  @override
  final String createdAt;
  @override
  final String updatedAt;
  @override
  @JsonKey()
  final bool isDeleted;
  final List<Attachment> _attachments;
  @override
  @JsonKey()
  List<Attachment> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  final List<Tag> _tags;
  @override
  @JsonKey()
  List<Tag> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'DiaryEntry(id: $id, userId: $userId, title: $title, content: $content, date: $date, mood: $mood, weather: $weather, location: $location, latitude: $latitude, longitude: $longitude, isPrivate: $isPrivate, isFavorite: $isFavorite, wordCount: $wordCount, readingTime: $readingTime, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted, attachments: $attachments, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiaryEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.weather, weather) || other.weather == weather) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.wordCount, wordCount) ||
                other.wordCount == wordCount) &&
            (identical(other.readingTime, readingTime) ||
                other.readingTime == readingTime) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    userId,
    title,
    content,
    date,
    mood,
    weather,
    location,
    latitude,
    longitude,
    isPrivate,
    isFavorite,
    wordCount,
    readingTime,
    createdAt,
    updatedAt,
    isDeleted,
    const DeepCollectionEquality().hash(_attachments),
    const DeepCollectionEquality().hash(_tags),
  ]);

  /// Create a copy of DiaryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiaryEntryImplCopyWith<_$DiaryEntryImpl> get copyWith =>
      __$$DiaryEntryImplCopyWithImpl<_$DiaryEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiaryEntryImplToJson(this);
  }
}

abstract class _DiaryEntry implements DiaryEntry {
  const factory _DiaryEntry({
    final int? id,
    required final int userId,
    final String? title,
    required final String content,
    required final String date,
    final String? mood,
    final String? weather,
    final String? location,
    final double? latitude,
    final double? longitude,
    final bool isPrivate,
    final bool isFavorite,
    final int wordCount,
    final int readingTime,
    required final String createdAt,
    required final String updatedAt,
    final bool isDeleted,
    final List<Attachment> attachments,
    final List<Tag> tags,
  }) = _$DiaryEntryImpl;

  factory _DiaryEntry.fromJson(Map<String, dynamic> json) =
      _$DiaryEntryImpl.fromJson;

  @override
  int? get id;
  @override
  int get userId;
  @override
  String? get title;
  @override
  String get content;
  @override
  String get date;
  @override
  String? get mood;
  @override
  String? get weather;
  @override
  String? get location;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  bool get isPrivate;
  @override
  bool get isFavorite;
  @override
  int get wordCount;
  @override
  int get readingTime;
  @override
  String get createdAt;
  @override
  String get updatedAt;
  @override
  bool get isDeleted;
  @override
  List<Attachment> get attachments;
  @override
  List<Tag> get tags;

  /// Create a copy of DiaryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiaryEntryImplCopyWith<_$DiaryEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateDiaryEntryDto _$CreateDiaryEntryDtoFromJson(Map<String, dynamic> json) {
  return _CreateDiaryEntryDto.fromJson(json);
}

/// @nodoc
mixin _$CreateDiaryEntryDto {
  int get userId => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  String? get mood => throw _privateConstructorUsedError;
  String? get weather => throw _privateConstructorUsedError;

  /// Serializes this CreateDiaryEntryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateDiaryEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateDiaryEntryDtoCopyWith<CreateDiaryEntryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateDiaryEntryDtoCopyWith<$Res> {
  factory $CreateDiaryEntryDtoCopyWith(
    CreateDiaryEntryDto value,
    $Res Function(CreateDiaryEntryDto) then,
  ) = _$CreateDiaryEntryDtoCopyWithImpl<$Res, CreateDiaryEntryDto>;
  @useResult
  $Res call({
    int userId,
    String? title,
    String content,
    String date,
    String? mood,
    String? weather,
  });
}

/// @nodoc
class _$CreateDiaryEntryDtoCopyWithImpl<$Res, $Val extends CreateDiaryEntryDto>
    implements $CreateDiaryEntryDtoCopyWith<$Res> {
  _$CreateDiaryEntryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateDiaryEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? title = freezed,
    Object? content = null,
    Object? date = null,
    Object? mood = freezed,
    Object? weather = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            mood: freezed == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                      as String?,
            weather: freezed == weather
                ? _value.weather
                : weather // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateDiaryEntryDtoImplCopyWith<$Res>
    implements $CreateDiaryEntryDtoCopyWith<$Res> {
  factory _$$CreateDiaryEntryDtoImplCopyWith(
    _$CreateDiaryEntryDtoImpl value,
    $Res Function(_$CreateDiaryEntryDtoImpl) then,
  ) = __$$CreateDiaryEntryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int userId,
    String? title,
    String content,
    String date,
    String? mood,
    String? weather,
  });
}

/// @nodoc
class __$$CreateDiaryEntryDtoImplCopyWithImpl<$Res>
    extends _$CreateDiaryEntryDtoCopyWithImpl<$Res, _$CreateDiaryEntryDtoImpl>
    implements _$$CreateDiaryEntryDtoImplCopyWith<$Res> {
  __$$CreateDiaryEntryDtoImplCopyWithImpl(
    _$CreateDiaryEntryDtoImpl _value,
    $Res Function(_$CreateDiaryEntryDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateDiaryEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? title = freezed,
    Object? content = null,
    Object? date = null,
    Object? mood = freezed,
    Object? weather = freezed,
  }) {
    return _then(
      _$CreateDiaryEntryDtoImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        mood: freezed == mood
            ? _value.mood
            : mood // ignore: cast_nullable_to_non_nullable
                  as String?,
        weather: freezed == weather
            ? _value.weather
            : weather // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateDiaryEntryDtoImpl implements _CreateDiaryEntryDto {
  const _$CreateDiaryEntryDtoImpl({
    required this.userId,
    this.title,
    required this.content,
    required this.date,
    this.mood,
    this.weather,
  });

  factory _$CreateDiaryEntryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateDiaryEntryDtoImplFromJson(json);

  @override
  final int userId;
  @override
  final String? title;
  @override
  final String content;
  @override
  final String date;
  @override
  final String? mood;
  @override
  final String? weather;

  @override
  String toString() {
    return 'CreateDiaryEntryDto(userId: $userId, title: $title, content: $content, date: $date, mood: $mood, weather: $weather)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateDiaryEntryDtoImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.weather, weather) || other.weather == weather));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, title, content, date, mood, weather);

  /// Create a copy of CreateDiaryEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateDiaryEntryDtoImplCopyWith<_$CreateDiaryEntryDtoImpl> get copyWith =>
      __$$CreateDiaryEntryDtoImplCopyWithImpl<_$CreateDiaryEntryDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateDiaryEntryDtoImplToJson(this);
  }
}

abstract class _CreateDiaryEntryDto implements CreateDiaryEntryDto {
  const factory _CreateDiaryEntryDto({
    required final int userId,
    final String? title,
    required final String content,
    required final String date,
    final String? mood,
    final String? weather,
  }) = _$CreateDiaryEntryDtoImpl;

  factory _CreateDiaryEntryDto.fromJson(Map<String, dynamic> json) =
      _$CreateDiaryEntryDtoImpl.fromJson;

  @override
  int get userId;
  @override
  String? get title;
  @override
  String get content;
  @override
  String get date;
  @override
  String? get mood;
  @override
  String? get weather;

  /// Create a copy of CreateDiaryEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateDiaryEntryDtoImplCopyWith<_$CreateDiaryEntryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateDiaryEntryDto _$UpdateDiaryEntryDtoFromJson(Map<String, dynamic> json) {
  return _UpdateDiaryEntryDto.fromJson(json);
}

/// @nodoc
mixin _$UpdateDiaryEntryDto {
  String? get title => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  String? get date => throw _privateConstructorUsedError;
  String? get mood => throw _privateConstructorUsedError;
  String? get weather => throw _privateConstructorUsedError;
  int? get wordCount => throw _privateConstructorUsedError;
  int? get readingTime => throw _privateConstructorUsedError;

  /// Serializes this UpdateDiaryEntryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateDiaryEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateDiaryEntryDtoCopyWith<UpdateDiaryEntryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateDiaryEntryDtoCopyWith<$Res> {
  factory $UpdateDiaryEntryDtoCopyWith(
    UpdateDiaryEntryDto value,
    $Res Function(UpdateDiaryEntryDto) then,
  ) = _$UpdateDiaryEntryDtoCopyWithImpl<$Res, UpdateDiaryEntryDto>;
  @useResult
  $Res call({
    String? title,
    String? content,
    String? date,
    String? mood,
    String? weather,
    int? wordCount,
    int? readingTime,
  });
}

/// @nodoc
class _$UpdateDiaryEntryDtoCopyWithImpl<$Res, $Val extends UpdateDiaryEntryDto>
    implements $UpdateDiaryEntryDtoCopyWith<$Res> {
  _$UpdateDiaryEntryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateDiaryEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? content = freezed,
    Object? date = freezed,
    Object? mood = freezed,
    Object? weather = freezed,
    Object? wordCount = freezed,
    Object? readingTime = freezed,
  }) {
    return _then(
      _value.copyWith(
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
            date: freezed == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String?,
            mood: freezed == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                      as String?,
            weather: freezed == weather
                ? _value.weather
                : weather // ignore: cast_nullable_to_non_nullable
                      as String?,
            wordCount: freezed == wordCount
                ? _value.wordCount
                : wordCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            readingTime: freezed == readingTime
                ? _value.readingTime
                : readingTime // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpdateDiaryEntryDtoImplCopyWith<$Res>
    implements $UpdateDiaryEntryDtoCopyWith<$Res> {
  factory _$$UpdateDiaryEntryDtoImplCopyWith(
    _$UpdateDiaryEntryDtoImpl value,
    $Res Function(_$UpdateDiaryEntryDtoImpl) then,
  ) = __$$UpdateDiaryEntryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? title,
    String? content,
    String? date,
    String? mood,
    String? weather,
    int? wordCount,
    int? readingTime,
  });
}

/// @nodoc
class __$$UpdateDiaryEntryDtoImplCopyWithImpl<$Res>
    extends _$UpdateDiaryEntryDtoCopyWithImpl<$Res, _$UpdateDiaryEntryDtoImpl>
    implements _$$UpdateDiaryEntryDtoImplCopyWith<$Res> {
  __$$UpdateDiaryEntryDtoImplCopyWithImpl(
    _$UpdateDiaryEntryDtoImpl _value,
    $Res Function(_$UpdateDiaryEntryDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateDiaryEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? content = freezed,
    Object? date = freezed,
    Object? mood = freezed,
    Object? weather = freezed,
    Object? wordCount = freezed,
    Object? readingTime = freezed,
  }) {
    return _then(
      _$UpdateDiaryEntryDtoImpl(
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        date: freezed == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String?,
        mood: freezed == mood
            ? _value.mood
            : mood // ignore: cast_nullable_to_non_nullable
                  as String?,
        weather: freezed == weather
            ? _value.weather
            : weather // ignore: cast_nullable_to_non_nullable
                  as String?,
        wordCount: freezed == wordCount
            ? _value.wordCount
            : wordCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        readingTime: freezed == readingTime
            ? _value.readingTime
            : readingTime // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateDiaryEntryDtoImpl implements _UpdateDiaryEntryDto {
  const _$UpdateDiaryEntryDtoImpl({
    this.title,
    this.content,
    this.date,
    this.mood,
    this.weather,
    this.wordCount,
    this.readingTime,
  });

  factory _$UpdateDiaryEntryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateDiaryEntryDtoImplFromJson(json);

  @override
  final String? title;
  @override
  final String? content;
  @override
  final String? date;
  @override
  final String? mood;
  @override
  final String? weather;
  @override
  final int? wordCount;
  @override
  final int? readingTime;

  @override
  String toString() {
    return 'UpdateDiaryEntryDto(title: $title, content: $content, date: $date, mood: $mood, weather: $weather, wordCount: $wordCount, readingTime: $readingTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateDiaryEntryDtoImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.weather, weather) || other.weather == weather) &&
            (identical(other.wordCount, wordCount) ||
                other.wordCount == wordCount) &&
            (identical(other.readingTime, readingTime) ||
                other.readingTime == readingTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    content,
    date,
    mood,
    weather,
    wordCount,
    readingTime,
  );

  /// Create a copy of UpdateDiaryEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateDiaryEntryDtoImplCopyWith<_$UpdateDiaryEntryDtoImpl> get copyWith =>
      __$$UpdateDiaryEntryDtoImplCopyWithImpl<_$UpdateDiaryEntryDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateDiaryEntryDtoImplToJson(this);
  }
}

abstract class _UpdateDiaryEntryDto implements UpdateDiaryEntryDto {
  const factory _UpdateDiaryEntryDto({
    final String? title,
    final String? content,
    final String? date,
    final String? mood,
    final String? weather,
    final int? wordCount,
    final int? readingTime,
  }) = _$UpdateDiaryEntryDtoImpl;

  factory _UpdateDiaryEntryDto.fromJson(Map<String, dynamic> json) =
      _$UpdateDiaryEntryDtoImpl.fromJson;

  @override
  String? get title;
  @override
  String? get content;
  @override
  String? get date;
  @override
  String? get mood;
  @override
  String? get weather;
  @override
  int? get wordCount;
  @override
  int? get readingTime;

  /// Create a copy of UpdateDiaryEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateDiaryEntryDtoImplCopyWith<_$UpdateDiaryEntryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DiaryEntryFilter _$DiaryEntryFilterFromJson(Map<String, dynamic> json) {
  return _DiaryEntryFilter.fromJson(json);
}

/// @nodoc
mixin _$DiaryEntryFilter {
  int? get userId => throw _privateConstructorUsedError;
  String? get mood => throw _privateConstructorUsedError;
  String? get weather => throw _privateConstructorUsedError;
  String? get startDate => throw _privateConstructorUsedError;
  String? get endDate => throw _privateConstructorUsedError;
  String? get searchQuery => throw _privateConstructorUsedError;
  int? get limit => throw _privateConstructorUsedError;
  int? get offset => throw _privateConstructorUsedError;

  /// Serializes this DiaryEntryFilter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiaryEntryFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiaryEntryFilterCopyWith<DiaryEntryFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiaryEntryFilterCopyWith<$Res> {
  factory $DiaryEntryFilterCopyWith(
    DiaryEntryFilter value,
    $Res Function(DiaryEntryFilter) then,
  ) = _$DiaryEntryFilterCopyWithImpl<$Res, DiaryEntryFilter>;
  @useResult
  $Res call({
    int? userId,
    String? mood,
    String? weather,
    String? startDate,
    String? endDate,
    String? searchQuery,
    int? limit,
    int? offset,
  });
}

/// @nodoc
class _$DiaryEntryFilterCopyWithImpl<$Res, $Val extends DiaryEntryFilter>
    implements $DiaryEntryFilterCopyWith<$Res> {
  _$DiaryEntryFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiaryEntryFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? mood = freezed,
    Object? weather = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? searchQuery = freezed,
    Object? limit = freezed,
    Object? offset = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int?,
            mood: freezed == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                      as String?,
            weather: freezed == weather
                ? _value.weather
                : weather // ignore: cast_nullable_to_non_nullable
                      as String?,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            searchQuery: freezed == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                      as String?,
            limit: freezed == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int?,
            offset: freezed == offset
                ? _value.offset
                : offset // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DiaryEntryFilterImplCopyWith<$Res>
    implements $DiaryEntryFilterCopyWith<$Res> {
  factory _$$DiaryEntryFilterImplCopyWith(
    _$DiaryEntryFilterImpl value,
    $Res Function(_$DiaryEntryFilterImpl) then,
  ) = __$$DiaryEntryFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? userId,
    String? mood,
    String? weather,
    String? startDate,
    String? endDate,
    String? searchQuery,
    int? limit,
    int? offset,
  });
}

/// @nodoc
class __$$DiaryEntryFilterImplCopyWithImpl<$Res>
    extends _$DiaryEntryFilterCopyWithImpl<$Res, _$DiaryEntryFilterImpl>
    implements _$$DiaryEntryFilterImplCopyWith<$Res> {
  __$$DiaryEntryFilterImplCopyWithImpl(
    _$DiaryEntryFilterImpl _value,
    $Res Function(_$DiaryEntryFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiaryEntryFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? mood = freezed,
    Object? weather = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? searchQuery = freezed,
    Object? limit = freezed,
    Object? offset = freezed,
  }) {
    return _then(
      _$DiaryEntryFilterImpl(
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int?,
        mood: freezed == mood
            ? _value.mood
            : mood // ignore: cast_nullable_to_non_nullable
                  as String?,
        weather: freezed == weather
            ? _value.weather
            : weather // ignore: cast_nullable_to_non_nullable
                  as String?,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        searchQuery: freezed == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String?,
        limit: freezed == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int?,
        offset: freezed == offset
            ? _value.offset
            : offset // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DiaryEntryFilterImpl implements _DiaryEntryFilter {
  const _$DiaryEntryFilterImpl({
    this.userId,
    this.mood,
    this.weather,
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.limit,
    this.offset,
  });

  factory _$DiaryEntryFilterImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiaryEntryFilterImplFromJson(json);

  @override
  final int? userId;
  @override
  final String? mood;
  @override
  final String? weather;
  @override
  final String? startDate;
  @override
  final String? endDate;
  @override
  final String? searchQuery;
  @override
  final int? limit;
  @override
  final int? offset;

  @override
  String toString() {
    return 'DiaryEntryFilter(userId: $userId, mood: $mood, weather: $weather, startDate: $startDate, endDate: $endDate, searchQuery: $searchQuery, limit: $limit, offset: $offset)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiaryEntryFilterImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.weather, weather) || other.weather == weather) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.offset, offset) || other.offset == offset));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    mood,
    weather,
    startDate,
    endDate,
    searchQuery,
    limit,
    offset,
  );

  /// Create a copy of DiaryEntryFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiaryEntryFilterImplCopyWith<_$DiaryEntryFilterImpl> get copyWith =>
      __$$DiaryEntryFilterImplCopyWithImpl<_$DiaryEntryFilterImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DiaryEntryFilterImplToJson(this);
  }
}

abstract class _DiaryEntryFilter implements DiaryEntryFilter {
  const factory _DiaryEntryFilter({
    final int? userId,
    final String? mood,
    final String? weather,
    final String? startDate,
    final String? endDate,
    final String? searchQuery,
    final int? limit,
    final int? offset,
  }) = _$DiaryEntryFilterImpl;

  factory _DiaryEntryFilter.fromJson(Map<String, dynamic> json) =
      _$DiaryEntryFilterImpl.fromJson;

  @override
  int? get userId;
  @override
  String? get mood;
  @override
  String? get weather;
  @override
  String? get startDate;
  @override
  String? get endDate;
  @override
  String? get searchQuery;
  @override
  int? get limit;
  @override
  int? get offset;

  /// Create a copy of DiaryEntryFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiaryEntryFilterImplCopyWith<_$DiaryEntryFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
