import 'package:freezed_annotation/freezed_annotation.dart';

part 'mood_stats.freezed.dart';
part 'mood_stats.g.dart';

/// 기분 통계 모델
@freezed
class MoodStats with _$MoodStats {
  const factory MoodStats({
    int? id,
    required int userId,
    required String mood,
    required String date,
    @Default(1) int count,
    required String createdAt,
    required String updatedAt,
  }) = _MoodStats;

  factory MoodStats.fromJson(Map<String, dynamic> json) =>
      _$MoodStatsFromJson(json);
}

/// 기분 통계 생성용 DTO
@freezed
class CreateMoodStatsDto with _$CreateMoodStatsDto {
  const factory CreateMoodStatsDto({
    required int userId,
    required String mood,
    required String date,
    @Default(1) int count,
  }) = _CreateMoodStatsDto;

  factory CreateMoodStatsDto.fromJson(Map<String, dynamic> json) =>
      _$CreateMoodStatsDtoFromJson(json);
}

/// 기분 통계 업데이트용 DTO
@freezed
class UpdateMoodStatsDto with _$UpdateMoodStatsDto {
  const factory UpdateMoodStatsDto({String? mood, String? date, int? count}) =
      _UpdateMoodStatsDto;

  factory UpdateMoodStatsDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateMoodStatsDtoFromJson(json);
}
