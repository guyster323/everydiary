// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiaryStatsImpl _$$DiaryStatsImplFromJson(Map<String, dynamic> json) =>
    _$DiaryStatsImpl(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      date: json['date'] as String,
      entriesCount: (json['entriesCount'] as num?)?.toInt() ?? 0,
      totalWords: (json['totalWords'] as num?)?.toInt() ?? 0,
      totalReadingTime: (json['totalReadingTime'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$DiaryStatsImplToJson(_$DiaryStatsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': instance.date,
      'entriesCount': instance.entriesCount,
      'totalWords': instance.totalWords,
      'totalReadingTime': instance.totalReadingTime,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_$CreateDiaryStatsDtoImpl _$$CreateDiaryStatsDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CreateDiaryStatsDtoImpl(
  userId: (json['userId'] as num).toInt(),
  date: json['date'] as String,
  entriesCount: (json['entriesCount'] as num?)?.toInt() ?? 0,
  totalWords: (json['totalWords'] as num?)?.toInt() ?? 0,
  totalReadingTime: (json['totalReadingTime'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$CreateDiaryStatsDtoImplToJson(
  _$CreateDiaryStatsDtoImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'date': instance.date,
  'entriesCount': instance.entriesCount,
  'totalWords': instance.totalWords,
  'totalReadingTime': instance.totalReadingTime,
};

_$UpdateDiaryStatsDtoImpl _$$UpdateDiaryStatsDtoImplFromJson(
  Map<String, dynamic> json,
) => _$UpdateDiaryStatsDtoImpl(
  entriesCount: (json['entriesCount'] as num?)?.toInt(),
  totalWords: (json['totalWords'] as num?)?.toInt(),
  totalReadingTime: (json['totalReadingTime'] as num?)?.toInt(),
);

Map<String, dynamic> _$$UpdateDiaryStatsDtoImplToJson(
  _$UpdateDiaryStatsDtoImpl instance,
) => <String, dynamic>{
  'entriesCount': instance.entriesCount,
  'totalWords': instance.totalWords,
  'totalReadingTime': instance.totalReadingTime,
};
