// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettingsModelImpl _$$SettingsModelImplFromJson(Map<String, dynamic> json) =>
    _$SettingsModelImpl(
      themeMode:
          $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
          ThemeMode.system,
      fontSize:
          $enumDecodeNullable(_$FontSizeEnumMap, json['fontSize']) ??
          FontSize.medium,
      language:
          $enumDecodeNullable(_$LanguageEnumMap, json['language']) ??
          Language.korean,
      dailyReminder: json['dailyReminder'] as bool? ?? false,
      reminderTime: json['reminderTime'] == null
          ? const TimeOfDay(hour: 20, minute: 0)
          : const TimeOfDayConverter().fromJson(
              json['reminderTime'] as Map<String, dynamic>,
            ),
      highContrast: json['highContrast'] as bool? ?? false,
      textToSpeech: json['textToSpeech'] as bool? ?? false,
      autoSave: json['autoSave'] as bool? ?? true,
      autoSaveInterval: (json['autoSaveInterval'] as num?)?.toInt() ?? 5,
      showStatistics: json['showStatistics'] as bool? ?? true,
      enableAnalytics: json['enableAnalytics'] as bool? ?? false,
      enableCrashReporting: json['enableCrashReporting'] as bool? ?? true,
    );

Map<String, dynamic> _$$SettingsModelImplToJson(_$SettingsModelImpl instance) =>
    <String, dynamic>{
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'fontSize': _$FontSizeEnumMap[instance.fontSize]!,
      'language': _$LanguageEnumMap[instance.language]!,
      'dailyReminder': instance.dailyReminder,
      'reminderTime': const TimeOfDayConverter().toJson(instance.reminderTime),
      'highContrast': instance.highContrast,
      'textToSpeech': instance.textToSpeech,
      'autoSave': instance.autoSave,
      'autoSaveInterval': instance.autoSaveInterval,
      'showStatistics': instance.showStatistics,
      'enableAnalytics': instance.enableAnalytics,
      'enableCrashReporting': instance.enableCrashReporting,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$FontSizeEnumMap = {
  FontSize.small: 'small',
  FontSize.medium: 'medium',
  FontSize.large: 'large',
  FontSize.extraLarge: 'extraLarge',
};

const _$LanguageEnumMap = {
  Language.korean: 'korean',
  Language.english: 'english',
  Language.japanese: 'japanese',
  Language.chineseSimplified: 'chineseSimplified',
  Language.chineseTraditional: 'chineseTraditional',
};
