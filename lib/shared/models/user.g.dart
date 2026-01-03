// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: (json['id'] as num?)?.toInt(),
  email: json['email'] as String?,
  name: json['name'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  bio: json['bio'] as String?,
  birthDate: json['birthDate'] as String?,
  gender: json['gender'] as String?,
  timezone: json['timezone'] as String? ?? 'Asia/Seoul',
  language: json['language'] as String? ?? 'ko',
  theme: json['theme'] as String? ?? 'system',
  notificationEnabled: json['notificationEnabled'] as bool? ?? true,
  notificationTime: json['notificationTime'] as String? ?? '21:00',
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  lastLoginAt: json['lastLoginAt'] as String?,
  isDeleted: json['isDeleted'] as bool? ?? false,
  isEmailVerified: json['isEmailVerified'] as bool? ?? false,
  roles:
      (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  passwordHash: json['passwordHash'] as String?,
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'bio': instance.bio,
      'birthDate': instance.birthDate,
      'gender': instance.gender,
      'timezone': instance.timezone,
      'language': instance.language,
      'theme': instance.theme,
      'notificationEnabled': instance.notificationEnabled,
      'notificationTime': instance.notificationTime,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'lastLoginAt': instance.lastLoginAt,
      'isDeleted': instance.isDeleted,
      'isEmailVerified': instance.isEmailVerified,
      'roles': instance.roles,
      'passwordHash': instance.passwordHash,
    };

_$CreateUserDtoImpl _$$CreateUserDtoImplFromJson(Map<String, dynamic> json) =>
    _$CreateUserDtoImpl(
      email: json['email'] as String?,
      name: json['name'] as String,
    );

Map<String, dynamic> _$$CreateUserDtoImplToJson(_$CreateUserDtoImpl instance) =>
    <String, dynamic>{'email': instance.email, 'name': instance.name};

_$UpdateUserDtoImpl _$$UpdateUserDtoImplFromJson(Map<String, dynamic> json) =>
    _$UpdateUserDtoImpl(
      email: json['email'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$UpdateUserDtoImplToJson(_$UpdateUserDtoImpl instance) =>
    <String, dynamic>{'email': instance.email, 'name': instance.name};
