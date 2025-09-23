// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationSettingsImpl _$$NotificationSettingsImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationSettingsImpl(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['userId'] as num).toInt(),
  type: json['type'] as String,
  enabled: json['enabled'] as bool? ?? true,
  time: json['time'] as String?,
  days: json['days'] as String?,
  message: json['message'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$$NotificationSettingsImplToJson(
  _$NotificationSettingsImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'type': instance.type,
  'enabled': instance.enabled,
  'time': instance.time,
  'days': instance.days,
  'message': instance.message,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

_$CreateNotificationSettingsDtoImpl
_$$CreateNotificationSettingsDtoImplFromJson(Map<String, dynamic> json) =>
    _$CreateNotificationSettingsDtoImpl(
      userId: (json['userId'] as num).toInt(),
      type: json['type'] as String,
      enabled: json['enabled'] as bool? ?? true,
      time: json['time'] as String?,
      days: json['days'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$CreateNotificationSettingsDtoImplToJson(
  _$CreateNotificationSettingsDtoImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'type': instance.type,
  'enabled': instance.enabled,
  'time': instance.time,
  'days': instance.days,
  'message': instance.message,
};

_$UpdateNotificationSettingsDtoImpl
_$$UpdateNotificationSettingsDtoImplFromJson(Map<String, dynamic> json) =>
    _$UpdateNotificationSettingsDtoImpl(
      type: json['type'] as String?,
      enabled: json['enabled'] as bool?,
      time: json['time'] as String?,
      days: json['days'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$UpdateNotificationSettingsDtoImplToJson(
  _$UpdateNotificationSettingsDtoImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'enabled': instance.enabled,
  'time': instance.time,
  'days': instance.days,
  'message': instance.message,
};
