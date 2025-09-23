// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemoryFilterImpl _$$MemoryFilterImplFromJson(
  Map<String, dynamic> json,
) => _$MemoryFilterImpl(
  allowedTypes:
      (json['allowedTypes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$MemoryTypeEnumMap, e))
          .toList() ??
      const [],
  excludedTypes:
      (json['excludedTypes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$MemoryTypeEnumMap, e))
          .toList() ??
      const [],
  minRelevance: (json['minRelevance'] as num?)?.toDouble() ?? 0.0,
  maxRelevance: (json['maxRelevance'] as num?)?.toDouble() ?? 1.0,
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  requiredTags:
      (json['requiredTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  excludedTags:
      (json['excludedTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  excludeViewed: json['excludeViewed'] as bool? ?? false,
  excludeBookmarked: json['excludeBookmarked'] as bool? ?? false,
  maxResults: (json['maxResults'] as num?)?.toInt() ?? 10,
  sortBy:
      $enumDecodeNullable(_$MemorySortByEnumMap, json['sortBy']) ??
      MemorySortBy.relevance,
  sortOrder:
      $enumDecodeNullable(_$SortOrderEnumMap, json['sortOrder']) ??
      SortOrder.descending,
  enableYesterdayMemories: json['enableYesterdayMemories'] as bool? ?? true,
  enableOneWeekAgoMemories: json['enableOneWeekAgoMemories'] as bool? ?? true,
  enableOneMonthAgoMemories: json['enableOneMonthAgoMemories'] as bool? ?? true,
  enableOneYearAgoMemories: json['enableOneYearAgoMemories'] as bool? ?? true,
  enablePastTodayMemories: json['enablePastTodayMemories'] as bool? ?? true,
  enableSameTimeMemories: json['enableSameTimeMemories'] as bool? ?? true,
  enableSeasonalMemories: json['enableSeasonalMemories'] as bool? ?? true,
  enableSpecialDateMemories: json['enableSpecialDateMemories'] as bool? ?? true,
  enableSimilarTagsMemories: json['enableSimilarTagsMemories'] as bool? ?? true,
);

Map<String, dynamic> _$$MemoryFilterImplToJson(_$MemoryFilterImpl instance) =>
    <String, dynamic>{
      'allowedTypes': instance.allowedTypes
          .map((e) => _$MemoryTypeEnumMap[e]!)
          .toList(),
      'excludedTypes': instance.excludedTypes
          .map((e) => _$MemoryTypeEnumMap[e]!)
          .toList(),
      'minRelevance': instance.minRelevance,
      'maxRelevance': instance.maxRelevance,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'requiredTags': instance.requiredTags,
      'excludedTags': instance.excludedTags,
      'excludeViewed': instance.excludeViewed,
      'excludeBookmarked': instance.excludeBookmarked,
      'maxResults': instance.maxResults,
      'sortBy': _$MemorySortByEnumMap[instance.sortBy]!,
      'sortOrder': _$SortOrderEnumMap[instance.sortOrder]!,
      'enableYesterdayMemories': instance.enableYesterdayMemories,
      'enableOneWeekAgoMemories': instance.enableOneWeekAgoMemories,
      'enableOneMonthAgoMemories': instance.enableOneMonthAgoMemories,
      'enableOneYearAgoMemories': instance.enableOneYearAgoMemories,
      'enablePastTodayMemories': instance.enablePastTodayMemories,
      'enableSameTimeMemories': instance.enableSameTimeMemories,
      'enableSeasonalMemories': instance.enableSeasonalMemories,
      'enableSpecialDateMemories': instance.enableSpecialDateMemories,
      'enableSimilarTagsMemories': instance.enableSimilarTagsMemories,
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

const _$MemorySortByEnumMap = {
  MemorySortBy.relevance: 'relevance',
  MemorySortBy.createdAt: 'createdAt',
  MemorySortBy.originalDate: 'originalDate',
  MemorySortBy.lastViewedAt: 'lastViewedAt',
  MemorySortBy.title: 'title',
};

const _$SortOrderEnumMap = {
  SortOrder.ascending: 'ascending',
  SortOrder.descending: 'descending',
};

_$MemorySettingsImpl _$$MemorySettingsImplFromJson(
  Map<String, dynamic> json,
) => _$MemorySettingsImpl(
  enableYesterdayMemories: json['enableYesterdayMemories'] as bool? ?? true,
  enableOneWeekAgoMemories: json['enableOneWeekAgoMemories'] as bool? ?? true,
  enableOneMonthAgoMemories: json['enableOneMonthAgoMemories'] as bool? ?? true,
  enableOneYearAgoMemories: json['enableOneYearAgoMemories'] as bool? ?? true,
  enablePastTodayMemories: json['enablePastTodayMemories'] as bool? ?? true,
  enableSameTimeMemories: json['enableSameTimeMemories'] as bool? ?? true,
  enableSeasonalMemories: json['enableSeasonalMemories'] as bool? ?? true,
  enableSpecialDateMemories: json['enableSpecialDateMemories'] as bool? ?? true,
  enableSimilarTagsMemories: json['enableSimilarTagsMemories'] as bool? ?? true,
  maxMemoriesPerType: (json['maxMemoriesPerType'] as num?)?.toInt() ?? 10,
  minMemoryRelevance: (json['minMemoryRelevance'] as num?)?.toDouble() ?? 0.3,
  enableNotifications: json['enableNotifications'] as bool? ?? true,
  notificationHours:
      (json['notificationHours'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  maxDaysToLookBack: (json['maxDaysToLookBack'] as num?)?.toInt() ?? 7,
  maxDaysForSameDate: (json['maxDaysForSameDate'] as num?)?.toInt() ?? 365,
);

Map<String, dynamic> _$$MemorySettingsImplToJson(
  _$MemorySettingsImpl instance,
) => <String, dynamic>{
  'enableYesterdayMemories': instance.enableYesterdayMemories,
  'enableOneWeekAgoMemories': instance.enableOneWeekAgoMemories,
  'enableOneMonthAgoMemories': instance.enableOneMonthAgoMemories,
  'enableOneYearAgoMemories': instance.enableOneYearAgoMemories,
  'enablePastTodayMemories': instance.enablePastTodayMemories,
  'enableSameTimeMemories': instance.enableSameTimeMemories,
  'enableSeasonalMemories': instance.enableSeasonalMemories,
  'enableSpecialDateMemories': instance.enableSpecialDateMemories,
  'enableSimilarTagsMemories': instance.enableSimilarTagsMemories,
  'maxMemoriesPerType': instance.maxMemoriesPerType,
  'minMemoryRelevance': instance.minMemoryRelevance,
  'enableNotifications': instance.enableNotifications,
  'notificationHours': instance.notificationHours,
  'maxDaysToLookBack': instance.maxDaysToLookBack,
  'maxDaysForSameDate': instance.maxDaysForSameDate,
};
