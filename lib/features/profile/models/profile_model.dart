import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

/// 사용자 프로필 모델
/// 사용자의 프로필 정보를 담는 모델입니다.
@freezed
class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    @Default('') String id,
    @Default('') String username,
    @Default('') String email,
    @Default('') String profileImagePath,
    @Default('') String bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(0) int totalDiaries,
    @Default(0) int consecutiveDays,
    @Default(0) int totalWords,
    @Default(0) int totalCharacters,
    @Default([]) List<String> favoriteTags,
    @Default(false) bool isPremium,
    @Default('') String timezone,
    @Default('') String language,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
}

/// 프로필 통계 모델
@freezed
class ProfileStats with _$ProfileStats {
  const factory ProfileStats({
    @Default(0) int totalDiaries,
    @Default(0) int consecutiveDays,
    @Default(0) int totalWords,
    @Default(0) int totalCharacters,
    @Default(0) int thisMonthDiaries,
    @Default(0) int thisWeekDiaries,
    @Default(0) int longestStreak,
    @Default(0) int averageWordsPerDiary,
    @Default([]) List<String> mostUsedTags,
    DateTime? firstDiaryDate,
    DateTime? lastDiaryDate,
  }) = _ProfileStats;

  factory ProfileStats.fromJson(Map<String, dynamic> json) =>
      _$ProfileStatsFromJson(json);
}
