// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiaryEntryImpl _$$DiaryEntryImplFromJson(Map<String, dynamic> json) =>
    _$DiaryEntryImpl(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      title: json['title'] as String?,
      content: json['content'] as String,
      date: json['date'] as String,
      mood: json['mood'] as String?,
      weather: json['weather'] as String?,
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isPrivate: json['isPrivate'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      wordCount: (json['wordCount'] as num?)?.toInt() ?? 0,
      readingTime: (json['readingTime'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      isDeleted: json['isDeleted'] as bool? ?? false,
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$DiaryEntryImplToJson(_$DiaryEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'content': instance.content,
      'date': instance.date,
      'mood': instance.mood,
      'weather': instance.weather,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isPrivate': instance.isPrivate,
      'isFavorite': instance.isFavorite,
      'wordCount': instance.wordCount,
      'readingTime': instance.readingTime,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'isDeleted': instance.isDeleted,
      'attachments': instance.attachments,
      'tags': instance.tags,
    };

_$CreateDiaryEntryDtoImpl _$$CreateDiaryEntryDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CreateDiaryEntryDtoImpl(
  userId: (json['userId'] as num).toInt(),
  title: json['title'] as String?,
  content: json['content'] as String,
  date: json['date'] as String,
  mood: json['mood'] as String?,
  weather: json['weather'] as String?,
);

Map<String, dynamic> _$$CreateDiaryEntryDtoImplToJson(
  _$CreateDiaryEntryDtoImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'title': instance.title,
  'content': instance.content,
  'date': instance.date,
  'mood': instance.mood,
  'weather': instance.weather,
};

_$UpdateDiaryEntryDtoImpl _$$UpdateDiaryEntryDtoImplFromJson(
  Map<String, dynamic> json,
) => _$UpdateDiaryEntryDtoImpl(
  title: json['title'] as String?,
  content: json['content'] as String?,
  date: json['date'] as String?,
  mood: json['mood'] as String?,
  weather: json['weather'] as String?,
  wordCount: (json['wordCount'] as num?)?.toInt(),
  readingTime: (json['readingTime'] as num?)?.toInt(),
);

Map<String, dynamic> _$$UpdateDiaryEntryDtoImplToJson(
  _$UpdateDiaryEntryDtoImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'content': instance.content,
  'date': instance.date,
  'mood': instance.mood,
  'weather': instance.weather,
  'wordCount': instance.wordCount,
  'readingTime': instance.readingTime,
};

_$DiaryEntryFilterImpl _$$DiaryEntryFilterImplFromJson(
  Map<String, dynamic> json,
) => _$DiaryEntryFilterImpl(
  userId: (json['userId'] as num?)?.toInt(),
  mood: json['mood'] as String?,
  weather: json['weather'] as String?,
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
  searchQuery: json['searchQuery'] as String?,
  limit: (json['limit'] as num?)?.toInt(),
  offset: (json['offset'] as num?)?.toInt(),
);

Map<String, dynamic> _$$DiaryEntryFilterImplToJson(
  _$DiaryEntryFilterImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'mood': instance.mood,
  'weather': instance.weather,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'searchQuery': instance.searchQuery,
  'limit': instance.limit,
  'offset': instance.offset,
};
