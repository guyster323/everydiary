import 'package:freezed_annotation/freezed_annotation.dart';

part 'diary_memory.freezed.dart';
part 'diary_memory.g.dart';

/// 일기 회상 정보를 담는 모델
@freezed
class DiaryMemory with _$DiaryMemory {
  const factory DiaryMemory({
    required String id,
    required String diaryId,
    required String title,
    required String content,
    required DateTime createdAt,
    required DateTime originalDate,
    required MemoryReason reason,
    required double relevance,
    required List<String> tags,
    String? imageUrl,
    String? location,
    @Default(false) bool isViewed,
    @Default(false) bool isBookmarked,
    DateTime? lastViewedAt,
  }) = _DiaryMemory;

  factory DiaryMemory.fromJson(Map<String, dynamic> json) =>
      _$DiaryMemoryFromJson(json);
}

/// 회상 이유를 나타내는 enum
@freezed
class MemoryReason with _$MemoryReason {
  const factory MemoryReason({
    required MemoryType type,
    required String description,
    required String displayText,
    Map<String, dynamic>? metadata,
  }) = _MemoryReason;

  factory MemoryReason.fromJson(Map<String, dynamic> json) =>
      _$MemoryReasonFromJson(json);
}

/// 회상 유형
enum MemoryType {
  /// 어제 작성된 일기
  @JsonValue('yesterday')
  yesterday,

  /// 일주일 전 작성된 일기
  @JsonValue('oneWeekAgo')
  oneWeekAgo,

  /// 한달 전 작성된 일기
  @JsonValue('oneMonthAgo')
  oneMonthAgo,

  /// 1년 전 작성된 일기
  @JsonValue('oneYearAgo')
  oneYearAgo,

  /// 과거의 오늘 (작년, 재작년 같은 날짜)
  @JsonValue('pastToday')
  pastToday,

  /// 같은 시간대 과거 기록
  @JsonValue('sameTimeOfDay')
  sameTimeOfDay,

  /// 계절별 회상
  @JsonValue('seasonal')
  seasonal,

  /// 특별한 날짜 (생일, 기념일 등)
  @JsonValue('specialDate')
  specialDate,

  /// 비슷한 태그를 가진 일기
  @JsonValue('similarTags')
  similarTags,
}

/// 회상 결과를 담는 컨테이너
@freezed
class MemoryResult with _$MemoryResult {
  const factory MemoryResult({
    required List<DiaryMemory> memories,
    required DateTime generatedAt,
    required String userId,
    @Default(0) int totalCount,
    @Default(0) int filteredCount,
    Map<String, dynamic>? metadata,
  }) = _MemoryResult;

  factory MemoryResult.fromJson(Map<String, dynamic> json) =>
      _$MemoryResultFromJson(json);
}

/// 회상 통계 정보
@freezed
class MemoryStats with _$MemoryStats {
  const factory MemoryStats({
    required String userId,
    required DateTime date,
    required Map<MemoryType, int> typeCounts,
    required double averageRelevance,
    required int totalMemories,
    required int viewedCount,
    required int bookmarkedCount,
    required double engagementRate,
  }) = _MemoryStats;

  factory MemoryStats.fromJson(Map<String, dynamic> json) =>
      _$MemoryStatsFromJson(json);
}
