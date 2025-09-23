import 'package:freezed_annotation/freezed_annotation.dart';

part 'diary_stats.freezed.dart';
part 'diary_stats.g.dart';

/// 일기 통계 모델
@freezed
class DiaryStats with _$DiaryStats {
  const factory DiaryStats({
    int? id,
    required int userId,
    required String date,
    @Default(0) int entriesCount,
    @Default(0) int totalWords,
    @Default(0) int totalReadingTime,
    required String createdAt,
    required String updatedAt,
  }) = _DiaryStats;

  factory DiaryStats.fromJson(Map<String, dynamic> json) =>
      _$DiaryStatsFromJson(json);
}

/// 일기 통계 생성용 DTO
@freezed
class CreateDiaryStatsDto with _$CreateDiaryStatsDto {
  const factory CreateDiaryStatsDto({
    required int userId,
    required String date,
    @Default(0) int entriesCount,
    @Default(0) int totalWords,
    @Default(0) int totalReadingTime,
  }) = _CreateDiaryStatsDto;

  factory CreateDiaryStatsDto.fromJson(Map<String, dynamic> json) =>
      _$CreateDiaryStatsDtoFromJson(json);
}

/// 일기 통계 업데이트용 DTO
@freezed
class UpdateDiaryStatsDto with _$UpdateDiaryStatsDto {
  const factory UpdateDiaryStatsDto({
    int? entriesCount,
    int? totalWords,
    int? totalReadingTime,
  }) = _UpdateDiaryStatsDto;

  factory UpdateDiaryStatsDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateDiaryStatsDtoFromJson(json);
}
