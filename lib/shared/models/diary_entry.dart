import 'package:freezed_annotation/freezed_annotation.dart';

import 'attachment.dart';
import 'tag.dart';

part 'diary_entry.freezed.dart';
part 'diary_entry.g.dart';

/// 일기 모델
@freezed
class DiaryEntry with _$DiaryEntry {
  const factory DiaryEntry({
    int? id,
    required int userId,
    String? title,
    required String content,
    required String date,
    String? mood,
    String? weather,
    String? location,
    double? latitude,
    double? longitude,
    @Default(false) bool isPrivate,
    @Default(false) bool isFavorite,
    @Default(0) int wordCount,
    @Default(0) int readingTime,
    required String createdAt,
    required String updatedAt,
    @Default(false) bool isDeleted,
    @Default([]) List<Attachment> attachments,
    @Default([]) List<Tag> tags,
  }) = _DiaryEntry;

  factory DiaryEntry.fromJson(Map<String, dynamic> json) =>
      _$DiaryEntryFromJson(json);
}

/// 일기 생성용 DTO
@freezed
class CreateDiaryEntryDto with _$CreateDiaryEntryDto {
  const factory CreateDiaryEntryDto({
    required int userId,
    String? title,
    required String content,
    required String date,
    String? mood,
    String? weather,
  }) = _CreateDiaryEntryDto;

  factory CreateDiaryEntryDto.fromJson(Map<String, dynamic> json) =>
      _$CreateDiaryEntryDtoFromJson(json);
}

/// 일기 업데이트용 DTO
@freezed
class UpdateDiaryEntryDto with _$UpdateDiaryEntryDto {
  const factory UpdateDiaryEntryDto({
    String? title,
    String? content,
    String? date,
    String? mood,
    String? weather,
    int? wordCount,
    int? readingTime,
  }) = _UpdateDiaryEntryDto;

  factory UpdateDiaryEntryDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateDiaryEntryDtoFromJson(json);
}

/// 일기 목록 조회용 필터
@freezed
class DiaryEntryFilter with _$DiaryEntryFilter {
  const factory DiaryEntryFilter({
    int? userId,
    String? mood,
    String? weather,
    String? startDate,
    String? endDate,
    String? searchQuery,
    int? limit,
    int? offset,
  }) = _DiaryEntryFilter;

  factory DiaryEntryFilter.fromJson(Map<String, dynamic> json) =>
      _$DiaryEntryFilterFromJson(json);
}
