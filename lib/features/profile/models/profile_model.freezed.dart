// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) {
  return _ProfileModel.fromJson(json);
}

/// @nodoc
mixin _$ProfileModel {
  String get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get profileImagePath => throw _privateConstructorUsedError;
  String get bio => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  int get totalDiaries => throw _privateConstructorUsedError;
  int get consecutiveDays => throw _privateConstructorUsedError;
  int get totalWords => throw _privateConstructorUsedError;
  int get totalCharacters => throw _privateConstructorUsedError;
  List<String> get favoriteTags => throw _privateConstructorUsedError;
  String get timezone => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;

  /// Serializes this ProfileModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileModelCopyWith<ProfileModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileModelCopyWith<$Res> {
  factory $ProfileModelCopyWith(
    ProfileModel value,
    $Res Function(ProfileModel) then,
  ) = _$ProfileModelCopyWithImpl<$Res, ProfileModel>;
  @useResult
  $Res call({
    String id,
    String username,
    String email,
    String profileImagePath,
    String bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    int totalDiaries,
    int consecutiveDays,
    int totalWords,
    int totalCharacters,
    List<String> favoriteTags,
    String timezone,
    String language,
  });
}

/// @nodoc
class _$ProfileModelCopyWithImpl<$Res, $Val extends ProfileModel>
    implements $ProfileModelCopyWith<$Res> {
  _$ProfileModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? email = null,
    Object? profileImagePath = null,
    Object? bio = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? totalDiaries = null,
    Object? consecutiveDays = null,
    Object? totalWords = null,
    Object? totalCharacters = null,
    Object? favoriteTags = null,
    Object? timezone = null,
    Object? language = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            profileImagePath: null == profileImagePath
                ? _value.profileImagePath
                : profileImagePath // ignore: cast_nullable_to_non_nullable
                      as String,
            bio: null == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            totalDiaries: null == totalDiaries
                ? _value.totalDiaries
                : totalDiaries // ignore: cast_nullable_to_non_nullable
                      as int,
            consecutiveDays: null == consecutiveDays
                ? _value.consecutiveDays
                : consecutiveDays // ignore: cast_nullable_to_non_nullable
                      as int,
            totalWords: null == totalWords
                ? _value.totalWords
                : totalWords // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCharacters: null == totalCharacters
                ? _value.totalCharacters
                : totalCharacters // ignore: cast_nullable_to_non_nullable
                      as int,
            favoriteTags: null == favoriteTags
                ? _value.favoriteTags
                : favoriteTags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            timezone: null == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                      as String,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileModelImplCopyWith<$Res>
    implements $ProfileModelCopyWith<$Res> {
  factory _$$ProfileModelImplCopyWith(
    _$ProfileModelImpl value,
    $Res Function(_$ProfileModelImpl) then,
  ) = __$$ProfileModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String username,
    String email,
    String profileImagePath,
    String bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    int totalDiaries,
    int consecutiveDays,
    int totalWords,
    int totalCharacters,
    List<String> favoriteTags,
    String timezone,
    String language,
  });
}

/// @nodoc
class __$$ProfileModelImplCopyWithImpl<$Res>
    extends _$ProfileModelCopyWithImpl<$Res, _$ProfileModelImpl>
    implements _$$ProfileModelImplCopyWith<$Res> {
  __$$ProfileModelImplCopyWithImpl(
    _$ProfileModelImpl _value,
    $Res Function(_$ProfileModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? email = null,
    Object? profileImagePath = null,
    Object? bio = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? totalDiaries = null,
    Object? consecutiveDays = null,
    Object? totalWords = null,
    Object? totalCharacters = null,
    Object? favoriteTags = null,
    Object? timezone = null,
    Object? language = null,
  }) {
    return _then(
      _$ProfileModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        profileImagePath: null == profileImagePath
            ? _value.profileImagePath
            : profileImagePath // ignore: cast_nullable_to_non_nullable
                  as String,
        bio: null == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        totalDiaries: null == totalDiaries
            ? _value.totalDiaries
            : totalDiaries // ignore: cast_nullable_to_non_nullable
                  as int,
        consecutiveDays: null == consecutiveDays
            ? _value.consecutiveDays
            : consecutiveDays // ignore: cast_nullable_to_non_nullable
                  as int,
        totalWords: null == totalWords
            ? _value.totalWords
            : totalWords // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCharacters: null == totalCharacters
            ? _value.totalCharacters
            : totalCharacters // ignore: cast_nullable_to_non_nullable
                  as int,
        favoriteTags: null == favoriteTags
            ? _value._favoriteTags
            : favoriteTags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        timezone: null == timezone
            ? _value.timezone
            : timezone // ignore: cast_nullable_to_non_nullable
                  as String,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileModelImpl implements _ProfileModel {
  const _$ProfileModelImpl({
    this.id = '',
    this.username = '',
    this.email = '',
    this.profileImagePath = '',
    this.bio = '',
    this.createdAt,
    this.updatedAt,
    this.totalDiaries = 0,
    this.consecutiveDays = 0,
    this.totalWords = 0,
    this.totalCharacters = 0,
    final List<String> favoriteTags = const [],
    this.timezone = '',
    this.language = '',
  }) : _favoriteTags = favoriteTags;

  factory _$ProfileModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileModelImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String username;
  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey()
  final String profileImagePath;
  @override
  @JsonKey()
  final String bio;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final int totalDiaries;
  @override
  @JsonKey()
  final int consecutiveDays;
  @override
  @JsonKey()
  final int totalWords;
  @override
  @JsonKey()
  final int totalCharacters;
  final List<String> _favoriteTags;
  @override
  @JsonKey()
  List<String> get favoriteTags {
    if (_favoriteTags is EqualUnmodifiableListView) return _favoriteTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteTags);
  }

  @override
  @JsonKey()
  final String timezone;
  @override
  @JsonKey()
  final String language;

  @override
  String toString() {
    return 'ProfileModel(id: $id, username: $username, email: $email, profileImagePath: $profileImagePath, bio: $bio, createdAt: $createdAt, updatedAt: $updatedAt, totalDiaries: $totalDiaries, consecutiveDays: $consecutiveDays, totalWords: $totalWords, totalCharacters: $totalCharacters, favoriteTags: $favoriteTags, timezone: $timezone, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.profileImagePath, profileImagePath) ||
                other.profileImagePath == profileImagePath) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.totalDiaries, totalDiaries) ||
                other.totalDiaries == totalDiaries) &&
            (identical(other.consecutiveDays, consecutiveDays) ||
                other.consecutiveDays == consecutiveDays) &&
            (identical(other.totalWords, totalWords) ||
                other.totalWords == totalWords) &&
            (identical(other.totalCharacters, totalCharacters) ||
                other.totalCharacters == totalCharacters) &&
            const DeepCollectionEquality().equals(
              other._favoriteTags,
              _favoriteTags,
            ) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    username,
    email,
    profileImagePath,
    bio,
    createdAt,
    updatedAt,
    totalDiaries,
    consecutiveDays,
    totalWords,
    totalCharacters,
    const DeepCollectionEquality().hash(_favoriteTags),
    timezone,
    language,
  );

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileModelImplCopyWith<_$ProfileModelImpl> get copyWith =>
      __$$ProfileModelImplCopyWithImpl<_$ProfileModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileModelImplToJson(this);
  }
}

abstract class _ProfileModel implements ProfileModel {
  const factory _ProfileModel({
    final String id,
    final String username,
    final String email,
    final String profileImagePath,
    final String bio,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final int totalDiaries,
    final int consecutiveDays,
    final int totalWords,
    final int totalCharacters,
    final List<String> favoriteTags,
    final String timezone,
    final String language,
  }) = _$ProfileModelImpl;

  factory _ProfileModel.fromJson(Map<String, dynamic> json) =
      _$ProfileModelImpl.fromJson;

  @override
  String get id;
  @override
  String get username;
  @override
  String get email;
  @override
  String get profileImagePath;
  @override
  String get bio;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  int get totalDiaries;
  @override
  int get consecutiveDays;
  @override
  int get totalWords;
  @override
  int get totalCharacters;
  @override
  List<String> get favoriteTags;
  @override
  String get timezone;
  @override
  String get language;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileModelImplCopyWith<_$ProfileModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProfileStats _$ProfileStatsFromJson(Map<String, dynamic> json) {
  return _ProfileStats.fromJson(json);
}

/// @nodoc
mixin _$ProfileStats {
  int get totalDiaries => throw _privateConstructorUsedError;
  int get consecutiveDays => throw _privateConstructorUsedError;
  int get totalWords => throw _privateConstructorUsedError;
  int get totalCharacters => throw _privateConstructorUsedError;
  int get thisMonthDiaries => throw _privateConstructorUsedError;
  int get thisWeekDiaries => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  int get averageWordsPerDiary => throw _privateConstructorUsedError;
  List<String> get mostUsedTags => throw _privateConstructorUsedError;
  DateTime? get firstDiaryDate => throw _privateConstructorUsedError;
  DateTime? get lastDiaryDate => throw _privateConstructorUsedError;

  /// Serializes this ProfileStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileStatsCopyWith<ProfileStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileStatsCopyWith<$Res> {
  factory $ProfileStatsCopyWith(
    ProfileStats value,
    $Res Function(ProfileStats) then,
  ) = _$ProfileStatsCopyWithImpl<$Res, ProfileStats>;
  @useResult
  $Res call({
    int totalDiaries,
    int consecutiveDays,
    int totalWords,
    int totalCharacters,
    int thisMonthDiaries,
    int thisWeekDiaries,
    int longestStreak,
    int averageWordsPerDiary,
    List<String> mostUsedTags,
    DateTime? firstDiaryDate,
    DateTime? lastDiaryDate,
  });
}

/// @nodoc
class _$ProfileStatsCopyWithImpl<$Res, $Val extends ProfileStats>
    implements $ProfileStatsCopyWith<$Res> {
  _$ProfileStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDiaries = null,
    Object? consecutiveDays = null,
    Object? totalWords = null,
    Object? totalCharacters = null,
    Object? thisMonthDiaries = null,
    Object? thisWeekDiaries = null,
    Object? longestStreak = null,
    Object? averageWordsPerDiary = null,
    Object? mostUsedTags = null,
    Object? firstDiaryDate = freezed,
    Object? lastDiaryDate = freezed,
  }) {
    return _then(
      _value.copyWith(
            totalDiaries: null == totalDiaries
                ? _value.totalDiaries
                : totalDiaries // ignore: cast_nullable_to_non_nullable
                      as int,
            consecutiveDays: null == consecutiveDays
                ? _value.consecutiveDays
                : consecutiveDays // ignore: cast_nullable_to_non_nullable
                      as int,
            totalWords: null == totalWords
                ? _value.totalWords
                : totalWords // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCharacters: null == totalCharacters
                ? _value.totalCharacters
                : totalCharacters // ignore: cast_nullable_to_non_nullable
                      as int,
            thisMonthDiaries: null == thisMonthDiaries
                ? _value.thisMonthDiaries
                : thisMonthDiaries // ignore: cast_nullable_to_non_nullable
                      as int,
            thisWeekDiaries: null == thisWeekDiaries
                ? _value.thisWeekDiaries
                : thisWeekDiaries // ignore: cast_nullable_to_non_nullable
                      as int,
            longestStreak: null == longestStreak
                ? _value.longestStreak
                : longestStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            averageWordsPerDiary: null == averageWordsPerDiary
                ? _value.averageWordsPerDiary
                : averageWordsPerDiary // ignore: cast_nullable_to_non_nullable
                      as int,
            mostUsedTags: null == mostUsedTags
                ? _value.mostUsedTags
                : mostUsedTags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            firstDiaryDate: freezed == firstDiaryDate
                ? _value.firstDiaryDate
                : firstDiaryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastDiaryDate: freezed == lastDiaryDate
                ? _value.lastDiaryDate
                : lastDiaryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileStatsImplCopyWith<$Res>
    implements $ProfileStatsCopyWith<$Res> {
  factory _$$ProfileStatsImplCopyWith(
    _$ProfileStatsImpl value,
    $Res Function(_$ProfileStatsImpl) then,
  ) = __$$ProfileStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalDiaries,
    int consecutiveDays,
    int totalWords,
    int totalCharacters,
    int thisMonthDiaries,
    int thisWeekDiaries,
    int longestStreak,
    int averageWordsPerDiary,
    List<String> mostUsedTags,
    DateTime? firstDiaryDate,
    DateTime? lastDiaryDate,
  });
}

/// @nodoc
class __$$ProfileStatsImplCopyWithImpl<$Res>
    extends _$ProfileStatsCopyWithImpl<$Res, _$ProfileStatsImpl>
    implements _$$ProfileStatsImplCopyWith<$Res> {
  __$$ProfileStatsImplCopyWithImpl(
    _$ProfileStatsImpl _value,
    $Res Function(_$ProfileStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDiaries = null,
    Object? consecutiveDays = null,
    Object? totalWords = null,
    Object? totalCharacters = null,
    Object? thisMonthDiaries = null,
    Object? thisWeekDiaries = null,
    Object? longestStreak = null,
    Object? averageWordsPerDiary = null,
    Object? mostUsedTags = null,
    Object? firstDiaryDate = freezed,
    Object? lastDiaryDate = freezed,
  }) {
    return _then(
      _$ProfileStatsImpl(
        totalDiaries: null == totalDiaries
            ? _value.totalDiaries
            : totalDiaries // ignore: cast_nullable_to_non_nullable
                  as int,
        consecutiveDays: null == consecutiveDays
            ? _value.consecutiveDays
            : consecutiveDays // ignore: cast_nullable_to_non_nullable
                  as int,
        totalWords: null == totalWords
            ? _value.totalWords
            : totalWords // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCharacters: null == totalCharacters
            ? _value.totalCharacters
            : totalCharacters // ignore: cast_nullable_to_non_nullable
                  as int,
        thisMonthDiaries: null == thisMonthDiaries
            ? _value.thisMonthDiaries
            : thisMonthDiaries // ignore: cast_nullable_to_non_nullable
                  as int,
        thisWeekDiaries: null == thisWeekDiaries
            ? _value.thisWeekDiaries
            : thisWeekDiaries // ignore: cast_nullable_to_non_nullable
                  as int,
        longestStreak: null == longestStreak
            ? _value.longestStreak
            : longestStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        averageWordsPerDiary: null == averageWordsPerDiary
            ? _value.averageWordsPerDiary
            : averageWordsPerDiary // ignore: cast_nullable_to_non_nullable
                  as int,
        mostUsedTags: null == mostUsedTags
            ? _value._mostUsedTags
            : mostUsedTags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        firstDiaryDate: freezed == firstDiaryDate
            ? _value.firstDiaryDate
            : firstDiaryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastDiaryDate: freezed == lastDiaryDate
            ? _value.lastDiaryDate
            : lastDiaryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileStatsImpl implements _ProfileStats {
  const _$ProfileStatsImpl({
    this.totalDiaries = 0,
    this.consecutiveDays = 0,
    this.totalWords = 0,
    this.totalCharacters = 0,
    this.thisMonthDiaries = 0,
    this.thisWeekDiaries = 0,
    this.longestStreak = 0,
    this.averageWordsPerDiary = 0,
    final List<String> mostUsedTags = const [],
    this.firstDiaryDate,
    this.lastDiaryDate,
  }) : _mostUsedTags = mostUsedTags;

  factory _$ProfileStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileStatsImplFromJson(json);

  @override
  @JsonKey()
  final int totalDiaries;
  @override
  @JsonKey()
  final int consecutiveDays;
  @override
  @JsonKey()
  final int totalWords;
  @override
  @JsonKey()
  final int totalCharacters;
  @override
  @JsonKey()
  final int thisMonthDiaries;
  @override
  @JsonKey()
  final int thisWeekDiaries;
  @override
  @JsonKey()
  final int longestStreak;
  @override
  @JsonKey()
  final int averageWordsPerDiary;
  final List<String> _mostUsedTags;
  @override
  @JsonKey()
  List<String> get mostUsedTags {
    if (_mostUsedTags is EqualUnmodifiableListView) return _mostUsedTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mostUsedTags);
  }

  @override
  final DateTime? firstDiaryDate;
  @override
  final DateTime? lastDiaryDate;

  @override
  String toString() {
    return 'ProfileStats(totalDiaries: $totalDiaries, consecutiveDays: $consecutiveDays, totalWords: $totalWords, totalCharacters: $totalCharacters, thisMonthDiaries: $thisMonthDiaries, thisWeekDiaries: $thisWeekDiaries, longestStreak: $longestStreak, averageWordsPerDiary: $averageWordsPerDiary, mostUsedTags: $mostUsedTags, firstDiaryDate: $firstDiaryDate, lastDiaryDate: $lastDiaryDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileStatsImpl &&
            (identical(other.totalDiaries, totalDiaries) ||
                other.totalDiaries == totalDiaries) &&
            (identical(other.consecutiveDays, consecutiveDays) ||
                other.consecutiveDays == consecutiveDays) &&
            (identical(other.totalWords, totalWords) ||
                other.totalWords == totalWords) &&
            (identical(other.totalCharacters, totalCharacters) ||
                other.totalCharacters == totalCharacters) &&
            (identical(other.thisMonthDiaries, thisMonthDiaries) ||
                other.thisMonthDiaries == thisMonthDiaries) &&
            (identical(other.thisWeekDiaries, thisWeekDiaries) ||
                other.thisWeekDiaries == thisWeekDiaries) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.averageWordsPerDiary, averageWordsPerDiary) ||
                other.averageWordsPerDiary == averageWordsPerDiary) &&
            const DeepCollectionEquality().equals(
              other._mostUsedTags,
              _mostUsedTags,
            ) &&
            (identical(other.firstDiaryDate, firstDiaryDate) ||
                other.firstDiaryDate == firstDiaryDate) &&
            (identical(other.lastDiaryDate, lastDiaryDate) ||
                other.lastDiaryDate == lastDiaryDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalDiaries,
    consecutiveDays,
    totalWords,
    totalCharacters,
    thisMonthDiaries,
    thisWeekDiaries,
    longestStreak,
    averageWordsPerDiary,
    const DeepCollectionEquality().hash(_mostUsedTags),
    firstDiaryDate,
    lastDiaryDate,
  );

  /// Create a copy of ProfileStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileStatsImplCopyWith<_$ProfileStatsImpl> get copyWith =>
      __$$ProfileStatsImplCopyWithImpl<_$ProfileStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileStatsImplToJson(this);
  }
}

abstract class _ProfileStats implements ProfileStats {
  const factory _ProfileStats({
    final int totalDiaries,
    final int consecutiveDays,
    final int totalWords,
    final int totalCharacters,
    final int thisMonthDiaries,
    final int thisWeekDiaries,
    final int longestStreak,
    final int averageWordsPerDiary,
    final List<String> mostUsedTags,
    final DateTime? firstDiaryDate,
    final DateTime? lastDiaryDate,
  }) = _$ProfileStatsImpl;

  factory _ProfileStats.fromJson(Map<String, dynamic> json) =
      _$ProfileStatsImpl.fromJson;

  @override
  int get totalDiaries;
  @override
  int get consecutiveDays;
  @override
  int get totalWords;
  @override
  int get totalCharacters;
  @override
  int get thisMonthDiaries;
  @override
  int get thisWeekDiaries;
  @override
  int get longestStreak;
  @override
  int get averageWordsPerDiary;
  @override
  List<String> get mostUsedTags;
  @override
  DateTime? get firstDiaryDate;
  @override
  DateTime? get lastDiaryDate;

  /// Create a copy of ProfileStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileStatsImplCopyWith<_$ProfileStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
