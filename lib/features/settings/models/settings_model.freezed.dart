// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SettingsModel _$SettingsModelFromJson(Map<String, dynamic> json) {
  return _SettingsModel.fromJson(json);
}

/// @nodoc
mixin _$SettingsModel {
  ThemeMode get themeMode => throw _privateConstructorUsedError;
  FontSize get fontSize => throw _privateConstructorUsedError;
  Language get language => throw _privateConstructorUsedError;
  bool get dailyReminder => throw _privateConstructorUsedError;
  @TimeOfDayConverter()
  TimeOfDay get reminderTime => throw _privateConstructorUsedError;
  bool get highContrast => throw _privateConstructorUsedError;
  bool get textToSpeech => throw _privateConstructorUsedError;
  bool get autoSave => throw _privateConstructorUsedError;
  int get autoSaveInterval => throw _privateConstructorUsedError; // 분 단위
  bool get showStatistics => throw _privateConstructorUsedError;
  bool get enableAnalytics => throw _privateConstructorUsedError;
  bool get enableCrashReporting => throw _privateConstructorUsedError;
  bool get showIntroVideo => throw _privateConstructorUsedError;

  /// Serializes this SettingsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettingsModelCopyWith<SettingsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsModelCopyWith<$Res> {
  factory $SettingsModelCopyWith(
    SettingsModel value,
    $Res Function(SettingsModel) then,
  ) = _$SettingsModelCopyWithImpl<$Res, SettingsModel>;
  @useResult
  $Res call({
    ThemeMode themeMode,
    FontSize fontSize,
    Language language,
    bool dailyReminder,
    @TimeOfDayConverter() TimeOfDay reminderTime,
    bool highContrast,
    bool textToSpeech,
    bool autoSave,
    int autoSaveInterval,
    bool showStatistics,
    bool enableAnalytics,
    bool enableCrashReporting,
    bool showIntroVideo,
  });
}

/// @nodoc
class _$SettingsModelCopyWithImpl<$Res, $Val extends SettingsModel>
    implements $SettingsModelCopyWith<$Res> {
  _$SettingsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? fontSize = null,
    Object? language = null,
    Object? dailyReminder = null,
    Object? reminderTime = null,
    Object? highContrast = null,
    Object? textToSpeech = null,
    Object? autoSave = null,
    Object? autoSaveInterval = null,
    Object? showStatistics = null,
    Object? enableAnalytics = null,
    Object? enableCrashReporting = null,
    Object? showIntroVideo = null,
  }) {
    return _then(
      _value.copyWith(
            themeMode: null == themeMode
                ? _value.themeMode
                : themeMode // ignore: cast_nullable_to_non_nullable
                      as ThemeMode,
            fontSize: null == fontSize
                ? _value.fontSize
                : fontSize // ignore: cast_nullable_to_non_nullable
                      as FontSize,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as Language,
            dailyReminder: null == dailyReminder
                ? _value.dailyReminder
                : dailyReminder // ignore: cast_nullable_to_non_nullable
                      as bool,
            reminderTime: null == reminderTime
                ? _value.reminderTime
                : reminderTime // ignore: cast_nullable_to_non_nullable
                      as TimeOfDay,
            highContrast: null == highContrast
                ? _value.highContrast
                : highContrast // ignore: cast_nullable_to_non_nullable
                      as bool,
            textToSpeech: null == textToSpeech
                ? _value.textToSpeech
                : textToSpeech // ignore: cast_nullable_to_non_nullable
                      as bool,
            autoSave: null == autoSave
                ? _value.autoSave
                : autoSave // ignore: cast_nullable_to_non_nullable
                      as bool,
            autoSaveInterval: null == autoSaveInterval
                ? _value.autoSaveInterval
                : autoSaveInterval // ignore: cast_nullable_to_non_nullable
                      as int,
            showStatistics: null == showStatistics
                ? _value.showStatistics
                : showStatistics // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableAnalytics: null == enableAnalytics
                ? _value.enableAnalytics
                : enableAnalytics // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableCrashReporting: null == enableCrashReporting
                ? _value.enableCrashReporting
                : enableCrashReporting // ignore: cast_nullable_to_non_nullable
                      as bool,
            showIntroVideo: null == showIntroVideo
                ? _value.showIntroVideo
                : showIntroVideo // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SettingsModelImplCopyWith<$Res>
    implements $SettingsModelCopyWith<$Res> {
  factory _$$SettingsModelImplCopyWith(
    _$SettingsModelImpl value,
    $Res Function(_$SettingsModelImpl) then,
  ) = __$$SettingsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ThemeMode themeMode,
    FontSize fontSize,
    Language language,
    bool dailyReminder,
    @TimeOfDayConverter() TimeOfDay reminderTime,
    bool highContrast,
    bool textToSpeech,
    bool autoSave,
    int autoSaveInterval,
    bool showStatistics,
    bool enableAnalytics,
    bool enableCrashReporting,
    bool showIntroVideo,
  });
}

/// @nodoc
class __$$SettingsModelImplCopyWithImpl<$Res>
    extends _$SettingsModelCopyWithImpl<$Res, _$SettingsModelImpl>
    implements _$$SettingsModelImplCopyWith<$Res> {
  __$$SettingsModelImplCopyWithImpl(
    _$SettingsModelImpl _value,
    $Res Function(_$SettingsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? fontSize = null,
    Object? language = null,
    Object? dailyReminder = null,
    Object? reminderTime = null,
    Object? highContrast = null,
    Object? textToSpeech = null,
    Object? autoSave = null,
    Object? autoSaveInterval = null,
    Object? showStatistics = null,
    Object? enableAnalytics = null,
    Object? enableCrashReporting = null,
    Object? showIntroVideo = null,
  }) {
    return _then(
      _$SettingsModelImpl(
        themeMode: null == themeMode
            ? _value.themeMode
            : themeMode // ignore: cast_nullable_to_non_nullable
                  as ThemeMode,
        fontSize: null == fontSize
            ? _value.fontSize
            : fontSize // ignore: cast_nullable_to_non_nullable
                  as FontSize,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as Language,
        dailyReminder: null == dailyReminder
            ? _value.dailyReminder
            : dailyReminder // ignore: cast_nullable_to_non_nullable
                  as bool,
        reminderTime: null == reminderTime
            ? _value.reminderTime
            : reminderTime // ignore: cast_nullable_to_non_nullable
                  as TimeOfDay,
        highContrast: null == highContrast
            ? _value.highContrast
            : highContrast // ignore: cast_nullable_to_non_nullable
                  as bool,
        textToSpeech: null == textToSpeech
            ? _value.textToSpeech
            : textToSpeech // ignore: cast_nullable_to_non_nullable
                  as bool,
        autoSave: null == autoSave
            ? _value.autoSave
            : autoSave // ignore: cast_nullable_to_non_nullable
                  as bool,
        autoSaveInterval: null == autoSaveInterval
            ? _value.autoSaveInterval
            : autoSaveInterval // ignore: cast_nullable_to_non_nullable
                  as int,
        showStatistics: null == showStatistics
            ? _value.showStatistics
            : showStatistics // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableAnalytics: null == enableAnalytics
            ? _value.enableAnalytics
            : enableAnalytics // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableCrashReporting: null == enableCrashReporting
            ? _value.enableCrashReporting
            : enableCrashReporting // ignore: cast_nullable_to_non_nullable
                  as bool,
        showIntroVideo: null == showIntroVideo
            ? _value.showIntroVideo
            : showIntroVideo // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SettingsModelImpl implements _SettingsModel {
  const _$SettingsModelImpl({
    this.themeMode = ThemeMode.system,
    this.fontSize = FontSize.medium,
    this.language = Language.korean,
    this.dailyReminder = false,
    @TimeOfDayConverter()
    this.reminderTime = const TimeOfDay(hour: 20, minute: 0),
    this.highContrast = false,
    this.textToSpeech = false,
    this.autoSave = true,
    this.autoSaveInterval = 5,
    this.showStatistics = true,
    this.enableAnalytics = false,
    this.enableCrashReporting = true,
    this.showIntroVideo = true,
  });

  factory _$SettingsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettingsModelImplFromJson(json);

  @override
  @JsonKey()
  final ThemeMode themeMode;
  @override
  @JsonKey()
  final FontSize fontSize;
  @override
  @JsonKey()
  final Language language;
  @override
  @JsonKey()
  final bool dailyReminder;
  @override
  @JsonKey()
  @TimeOfDayConverter()
  final TimeOfDay reminderTime;
  @override
  @JsonKey()
  final bool highContrast;
  @override
  @JsonKey()
  final bool textToSpeech;
  @override
  @JsonKey()
  final bool autoSave;
  @override
  @JsonKey()
  final int autoSaveInterval;
  // 분 단위
  @override
  @JsonKey()
  final bool showStatistics;
  @override
  @JsonKey()
  final bool enableAnalytics;
  @override
  @JsonKey()
  final bool enableCrashReporting;
  @override
  @JsonKey()
  final bool showIntroVideo;

  @override
  String toString() {
    return 'SettingsModel(themeMode: $themeMode, fontSize: $fontSize, language: $language, dailyReminder: $dailyReminder, reminderTime: $reminderTime, highContrast: $highContrast, textToSpeech: $textToSpeech, autoSave: $autoSave, autoSaveInterval: $autoSaveInterval, showStatistics: $showStatistics, enableAnalytics: $enableAnalytics, enableCrashReporting: $enableCrashReporting, showIntroVideo: $showIntroVideo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsModelImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.dailyReminder, dailyReminder) ||
                other.dailyReminder == dailyReminder) &&
            (identical(other.reminderTime, reminderTime) ||
                other.reminderTime == reminderTime) &&
            (identical(other.highContrast, highContrast) ||
                other.highContrast == highContrast) &&
            (identical(other.textToSpeech, textToSpeech) ||
                other.textToSpeech == textToSpeech) &&
            (identical(other.autoSave, autoSave) ||
                other.autoSave == autoSave) &&
            (identical(other.autoSaveInterval, autoSaveInterval) ||
                other.autoSaveInterval == autoSaveInterval) &&
            (identical(other.showStatistics, showStatistics) ||
                other.showStatistics == showStatistics) &&
            (identical(other.enableAnalytics, enableAnalytics) ||
                other.enableAnalytics == enableAnalytics) &&
            (identical(other.enableCrashReporting, enableCrashReporting) ||
                other.enableCrashReporting == enableCrashReporting) &&
            (identical(other.showIntroVideo, showIntroVideo) ||
                other.showIntroVideo == showIntroVideo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    themeMode,
    fontSize,
    language,
    dailyReminder,
    reminderTime,
    highContrast,
    textToSpeech,
    autoSave,
    autoSaveInterval,
    showStatistics,
    enableAnalytics,
    enableCrashReporting,
    showIntroVideo,
  );

  /// Create a copy of SettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsModelImplCopyWith<_$SettingsModelImpl> get copyWith =>
      __$$SettingsModelImplCopyWithImpl<_$SettingsModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettingsModelImplToJson(this);
  }
}

abstract class _SettingsModel implements SettingsModel {
  const factory _SettingsModel({
    final ThemeMode themeMode,
    final FontSize fontSize,
    final Language language,
    final bool dailyReminder,
    @TimeOfDayConverter() final TimeOfDay reminderTime,
    final bool highContrast,
    final bool textToSpeech,
    final bool autoSave,
    final int autoSaveInterval,
    final bool showStatistics,
    final bool enableAnalytics,
    final bool enableCrashReporting,
    final bool showIntroVideo,
  }) = _$SettingsModelImpl;

  factory _SettingsModel.fromJson(Map<String, dynamic> json) =
      _$SettingsModelImpl.fromJson;

  @override
  ThemeMode get themeMode;
  @override
  FontSize get fontSize;
  @override
  Language get language;
  @override
  bool get dailyReminder;
  @override
  @TimeOfDayConverter()
  TimeOfDay get reminderTime;
  @override
  bool get highContrast;
  @override
  bool get textToSpeech;
  @override
  bool get autoSave;
  @override
  int get autoSaveInterval; // 분 단위
  @override
  bool get showStatistics;
  @override
  bool get enableAnalytics;
  @override
  bool get enableCrashReporting;
  @override
  bool get showIntroVideo;

  /// Create a copy of SettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettingsModelImplCopyWith<_$SettingsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
