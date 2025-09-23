import 'package:freezed_annotation/freezed_annotation.dart';

import 'diary_memory.dart';

part 'memory_filter.freezed.dart';
part 'memory_filter.g.dart';

/// 회상 필터링 옵션
@freezed
class MemoryFilter with _$MemoryFilter {
  const factory MemoryFilter({
    @Default([]) List<MemoryType> allowedTypes,
    @Default([]) List<MemoryType> excludedTypes,
    @Default(0.0) double minRelevance,
    @Default(1.0) double maxRelevance,
    DateTime? startDate,
    DateTime? endDate,
    @Default([]) List<String> requiredTags,
    @Default([]) List<String> excludedTags,
    @Default(false) bool excludeViewed,
    @Default(false) bool excludeBookmarked,
    @Default(10) int maxResults,
    @Default(MemorySortBy.relevance) MemorySortBy sortBy,
    @Default(SortOrder.descending) SortOrder sortOrder,
    @Default(true) bool enableYesterdayMemories,
    @Default(true) bool enableOneWeekAgoMemories,
    @Default(true) bool enableOneMonthAgoMemories,
    @Default(true) bool enableOneYearAgoMemories,
    @Default(true) bool enablePastTodayMemories,
    @Default(true) bool enableSameTimeMemories,
    @Default(true) bool enableSeasonalMemories,
    @Default(true) bool enableSpecialDateMemories,
    @Default(true) bool enableSimilarTagsMemories,
  }) = _MemoryFilter;

  factory MemoryFilter.fromJson(Map<String, dynamic> json) =>
      _$$MemoryFilterImplFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$$MemoryFilterImplToJson(this as _$MemoryFilterImpl);
}

/// 회상 정렬 기준
enum MemorySortBy {
  /// 관련성 점수
  @JsonValue('relevance')
  relevance,

  /// 생성 날짜
  @JsonValue('createdAt')
  createdAt,

  /// 원본 일기 날짜
  @JsonValue('originalDate')
  originalDate,

  /// 마지막 조회 시간
  @JsonValue('lastViewedAt')
  lastViewedAt,

  /// 제목 알파벳 순
  @JsonValue('title')
  title,
}

/// 정렬 순서
enum SortOrder {
  /// 오름차순
  @JsonValue('ascending')
  ascending,

  /// 내림차순
  @JsonValue('descending')
  descending,
}

/// 회상 설정
@freezed
class MemorySettings with _$MemorySettings {
  const factory MemorySettings({
    @Default(true) bool enableYesterdayMemories,
    @Default(true) bool enableOneWeekAgoMemories,
    @Default(true) bool enableOneMonthAgoMemories,
    @Default(true) bool enableOneYearAgoMemories,
    @Default(true) bool enablePastTodayMemories,
    @Default(true) bool enableSameTimeMemories,
    @Default(true) bool enableSeasonalMemories,
    @Default(true) bool enableSpecialDateMemories,
    @Default(true) bool enableSimilarTagsMemories,
    @Default(10) int maxMemoriesPerType,
    @Default(0.3) double minMemoryRelevance,
    @Default(true) bool enableNotifications,
    @Default([]) List<int> notificationHours,
    @Default(7) int maxDaysToLookBack,
    @Default(365) int maxDaysForSameDate,
  }) = _MemorySettings;

  factory MemorySettings.fromJson(Map<String, dynamic> json) =>
      _$$MemorySettingsImplFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$$MemorySettingsImplToJson(this as _$MemorySettingsImpl);
}
