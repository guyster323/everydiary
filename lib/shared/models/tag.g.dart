// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TagImpl _$$TagImplFromJson(Map<String, dynamic> json) => _$TagImpl(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['userId'] as num).toInt(),
  name: json['name'] as String,
  color: json['color'] as String? ?? '#6366F1',
  icon: json['icon'] as String?,
  description: json['description'] as String?,
  usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$$TagImplToJson(_$TagImpl instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'color': instance.color,
  'icon': instance.icon,
  'description': instance.description,
  'usageCount': instance.usageCount,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'isDeleted': instance.isDeleted,
};

_$CreateTagDtoImpl _$$CreateTagDtoImplFromJson(Map<String, dynamic> json) =>
    _$CreateTagDtoImpl(
      name: json['name'] as String,
      color: json['color'] as String?,
    );

Map<String, dynamic> _$$CreateTagDtoImplToJson(_$CreateTagDtoImpl instance) =>
    <String, dynamic>{'name': instance.name, 'color': instance.color};

_$UpdateTagDtoImpl _$$UpdateTagDtoImplFromJson(Map<String, dynamic> json) =>
    _$UpdateTagDtoImpl(
      name: json['name'] as String?,
      color: json['color'] as String?,
    );

Map<String, dynamic> _$$UpdateTagDtoImplToJson(_$UpdateTagDtoImpl instance) =>
    <String, dynamic>{'name': instance.name, 'color': instance.color};

_$DiaryTagImpl _$$DiaryTagImplFromJson(Map<String, dynamic> json) =>
    _$DiaryTagImpl(
      id: (json['id'] as num?)?.toInt(),
      diaryId: (json['diaryId'] as num).toInt(),
      tagId: (json['tagId'] as num).toInt(),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$$DiaryTagImplToJson(_$DiaryTagImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'diaryId': instance.diaryId,
      'tagId': instance.tagId,
      'createdAt': instance.createdAt,
    };

_$CreateDiaryTagDtoImpl _$$CreateDiaryTagDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CreateDiaryTagDtoImpl(
  diaryId: (json['diaryId'] as num).toInt(),
  tagId: (json['tagId'] as num).toInt(),
);

Map<String, dynamic> _$$CreateDiaryTagDtoImplToJson(
  _$CreateDiaryTagDtoImpl instance,
) => <String, dynamic>{'diaryId': instance.diaryId, 'tagId': instance.tagId};
