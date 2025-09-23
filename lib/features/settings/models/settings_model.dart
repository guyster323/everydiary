import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'settings_enums.dart';

part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

/// TimeOfDay JSON 변환기
class TimeOfDayConverter
    implements JsonConverter<TimeOfDay, Map<String, dynamic>> {
  const TimeOfDayConverter();

  @override
  TimeOfDay fromJson(Map<String, dynamic> json) {
    return TimeOfDay(hour: json['hour'] as int, minute: json['minute'] as int);
  }

  @override
  Map<String, dynamic> toJson(TimeOfDay timeOfDay) {
    return {'hour': timeOfDay.hour, 'minute': timeOfDay.minute};
  }
}

/// 앱 설정 모델
/// 사용자의 앱 설정 정보를 담는 모델입니다.
@freezed
class SettingsModel with _$SettingsModel {
  const factory SettingsModel({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(FontSize.medium) FontSize fontSize,
    @Default(Language.korean) Language language,
    @Default(false) bool dailyReminder,
    @TimeOfDayConverter()
    @Default(TimeOfDay(hour: 20, minute: 0))
    TimeOfDay reminderTime,
    @Default(false) bool highContrast,
    @Default(false) bool textToSpeech,
    @Default(true) bool autoSave,
    @Default(5) int autoSaveInterval, // 분 단위
    @Default(true) bool showStatistics,
    @Default(false) bool enableAnalytics,
    @Default(true) bool enableCrashReporting,
  }) = _SettingsModel;

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);
}
