// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_memory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiaryMemoryImpl _$$DiaryMemoryImplFromJson(Map<String, dynamic> json) =>
    _$DiaryMemoryImpl(
      id: json['id'] as String,
      diaryId: json['diaryId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      originalDate: DateTime.parse(json['originalDate'] as String),
      reason: MemoryReason.fromJson(json['reason'] as Map<String, dynamic>),
      relevance: (json['relevance'] as num).toDouble(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      imageUrl: json['imageUrl'] as String?,
      location: json['location'] as String?,
      isViewed: json['isViewed'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      lastViewedAt: json['lastViewedAt'] == null
          ? null
          : DateTime.parse(json['lastViewedAt'] as String),
    );

Map<String, dynamic> _$$DiaryMemoryImplToJson(_$DiaryMemoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'diaryId': instance.diaryId,
      'title': instance.title,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'originalDate': instance.originalDate.toIso8601String(),
      'reason': instance.reason,
      'relevance': instance.relevance,
      'tags': instance.tags,
      'imageUrl': instance.imageUrl,
      'location': instance.location,
      'isViewed': instance.isViewed,
      'isBookmarked': instance.isBookmarked,
      'lastViewedAt': instance.lastViewedAt?.toIso8601String(),
    };

_$MemoryReasonImpl _$$MemoryReasonImplFromJson(Map<String, dynamic> json) =>
    _$MemoryReasonImpl(
      type: $enumDecode(_$MemoryTypeEnumMap, json['type']),
      description: json['description'] as String,
      displayText: json['displayText'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$MemoryReasonImplToJson(_$MemoryReasonImpl instance) =>
    <String, dynamic>{
      'type': _$MemoryTypeEnumMap[instance.type]!,
      'description': instance.description,
      'displayText': instance.displayText,
      'metadata': instance.metadata,
    };

const _$MemoryTypeEnumMap = {
  MemoryType.yesterday: 'yesterday',
  MemoryType.oneWeekAgo: 'oneWeekAgo',
  MemoryType.oneMonthAgo: 'oneMonthAgo',
  MemoryType.oneYearAgo: 'oneYearAgo',
  MemoryType.pastToday: 'pastToday',
  MemoryType.sameTimeOfDay: 'sameTimeOfDay',
  MemoryType.seasonal: 'seasonal',
  MemoryType.specialDate: 'specialDate',
  MemoryType.similarTags: 'similarTags',
};

_$MemoryResultImpl _$$MemoryResultImplFromJson(Map<String, dynamic> json) =>
    _$MemoryResultImpl(
      memories: (json['memories'] as List<dynamic>)
          .map((e) => DiaryMemory.fromJson(e as Map<String, dynamic>))
          .toList(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      userId: json['userId'] as String,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      filteredCount: (json['filteredCount'] as num?)?.toInt() ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$MemoryResultImplToJson(_$MemoryResultImpl instance) =>
    <String, dynamic>{
      'memories': instance.memories,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'userId': instance.userId,
      'totalCount': instance.totalCount,
      'filteredCount': instance.filteredCount,
      'metadata': instance.metadata,
    };

_$MemoryStatsImpl _$$MemoryStatsImplFromJson(Map<String, dynamic> json) =>
    _$MemoryStatsImpl(
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      typeCounts: (json['typeCounts'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry($enumDecode(_$MemoryTypeEnumMap, k), (e as num).toInt()),
      ),
      averageRelevance: (json['averageRelevance'] as num).toDouble(),
      totalMemories: (json['totalMemories'] as num).toInt(),
      viewedCount: (json['viewedCount'] as num).toInt(),
      bookmarkedCount: (json['bookmarkedCount'] as num).toInt(),
      engagementRate: (json['engagementRate'] as num).toDouble(),
    );

Map<String, dynamic> _$$MemoryStatsImplToJson(_$MemoryStatsImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'date': instance.date.toIso8601String(),
      'typeCounts': instance.typeCounts.map(
        (k, e) => MapEntry(_$MemoryTypeEnumMap[k]!, e),
      ),
      'averageRelevance': instance.averageRelevance,
      'totalMemories': instance.totalMemories,
      'viewedCount': instance.viewedCount,
      'bookmarkedCount': instance.bookmarkedCount,
      'engagementRate': instance.engagementRate,
    };
