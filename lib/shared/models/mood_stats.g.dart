// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MoodStatsImpl _$$MoodStatsImplFromJson(Map<String, dynamic> json) =>
    _$MoodStatsImpl(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      mood: json['mood'] as String,
      date: json['date'] as String,
      count: (json['count'] as num?)?.toInt() ?? 1,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$MoodStatsImplToJson(_$MoodStatsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'mood': instance.mood,
      'date': instance.date,
      'count': instance.count,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_$CreateMoodStatsDtoImpl _$$CreateMoodStatsDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CreateMoodStatsDtoImpl(
  userId: (json['userId'] as num).toInt(),
  mood: json['mood'] as String,
  date: json['date'] as String,
  count: (json['count'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$$CreateMoodStatsDtoImplToJson(
  _$CreateMoodStatsDtoImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'mood': instance.mood,
  'date': instance.date,
  'count': instance.count,
};

_$UpdateMoodStatsDtoImpl _$$UpdateMoodStatsDtoImplFromJson(
  Map<String, dynamic> json,
) => _$UpdateMoodStatsDtoImpl(
  mood: json['mood'] as String?,
  date: json['date'] as String?,
  count: (json['count'] as num?)?.toInt(),
);

Map<String, dynamic> _$$UpdateMoodStatsDtoImplToJson(
  _$UpdateMoodStatsDtoImpl instance,
) => <String, dynamic>{
  'mood': instance.mood,
  'date': instance.date,
  'count': instance.count,
};
