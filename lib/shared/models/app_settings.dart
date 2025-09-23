import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

/// 앱 설정 모델
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    int? id,
    required String key,
    String? value,
    required String type,
    String? description,
    required String createdAt,
    required String updatedAt,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}

/// 앱 설정 생성용 DTO
@freezed
class CreateAppSettingsDto with _$CreateAppSettingsDto {
  const factory CreateAppSettingsDto({
    required String key,
    String? value,
    required String type,
    String? description,
  }) = _CreateAppSettingsDto;

  factory CreateAppSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$CreateAppSettingsDtoFromJson(json);
}

/// 앱 설정 업데이트용 DTO
@freezed
class UpdateAppSettingsDto with _$UpdateAppSettingsDto {
  const factory UpdateAppSettingsDto({
    String? value,
    String? type,
    String? description,
  }) = _UpdateAppSettingsDto;

  factory UpdateAppSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateAppSettingsDtoFromJson(json);
}

/// 설정 타입 열거형
enum SettingType {
  @JsonValue('string')
  string,
  @JsonValue('integer')
  integer,
  @JsonValue('boolean')
  boolean,
  @JsonValue('float')
  float,
  @JsonValue('json')
  json,
}

/// 설정 타입 확장
extension SettingTypeExtension on SettingType {
  String get value {
    switch (this) {
      case SettingType.string:
        return 'string';
      case SettingType.integer:
        return 'integer';
      case SettingType.boolean:
        return 'boolean';
      case SettingType.float:
        return 'float';
      case SettingType.json:
        return 'json';
    }
  }

  static SettingType fromString(String value) {
    switch (value) {
      case 'string':
        return SettingType.string;
      case 'integer':
        return SettingType.integer;
      case 'boolean':
        return SettingType.boolean;
      case 'float':
        return SettingType.float;
      case 'json':
        return SettingType.json;
      default:
        return SettingType.string;
    }
  }
}
