// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsImpl _$$AppSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AppSettingsImpl(
      id: (json['id'] as num?)?.toInt(),
      key: json['key'] as String,
      value: json['value'] as String?,
      type: json['type'] as String,
      description: json['description'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$AppSettingsImplToJson(_$AppSettingsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
      'type': instance.type,
      'description': instance.description,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_$CreateAppSettingsDtoImpl _$$CreateAppSettingsDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CreateAppSettingsDtoImpl(
  key: json['key'] as String,
  value: json['value'] as String?,
  type: json['type'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$$CreateAppSettingsDtoImplToJson(
  _$CreateAppSettingsDtoImpl instance,
) => <String, dynamic>{
  'key': instance.key,
  'value': instance.value,
  'type': instance.type,
  'description': instance.description,
};

_$UpdateAppSettingsDtoImpl _$$UpdateAppSettingsDtoImplFromJson(
  Map<String, dynamic> json,
) => _$UpdateAppSettingsDtoImpl(
  value: json['value'] as String?,
  type: json['type'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$$UpdateAppSettingsDtoImplToJson(
  _$UpdateAppSettingsDtoImpl instance,
) => <String, dynamic>{
  'value': instance.value,
  'type': instance.type,
  'description': instance.description,
};
