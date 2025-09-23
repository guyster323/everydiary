import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

/// 태그 모델
@freezed
class Tag with _$Tag {
  const factory Tag({
    int? id,
    required int userId,
    required String name,
    @Default('#6366F1') String color,
    String? icon,
    String? description,
    @Default(0) int usageCount,
    required String createdAt,
    required String updatedAt,
    @Default(false) bool isDeleted,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}

/// 태그 생성용 DTO
@freezed
class CreateTagDto with _$CreateTagDto {
  const factory CreateTagDto({required String name, String? color}) =
      _CreateTagDto;

  factory CreateTagDto.fromJson(Map<String, dynamic> json) =>
      _$CreateTagDtoFromJson(json);
}

/// 태그 업데이트용 DTO
@freezed
class UpdateTagDto with _$UpdateTagDto {
  const factory UpdateTagDto({String? name, String? color}) = _UpdateTagDto;

  factory UpdateTagDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateTagDtoFromJson(json);
}

/// 일기-태그 관계 모델
@freezed
class DiaryTag with _$DiaryTag {
  const factory DiaryTag({
    int? id,
    required int diaryId,
    required int tagId,
    required String createdAt,
  }) = _DiaryTag;

  factory DiaryTag.fromJson(Map<String, dynamic> json) =>
      _$DiaryTagFromJson(json);
}

/// 일기-태그 관계 생성용 DTO
@freezed
class CreateDiaryTagDto with _$CreateDiaryTagDto {
  const factory CreateDiaryTagDto({required int diaryId, required int tagId}) =
      _CreateDiaryTagDto;

  factory CreateDiaryTagDto.fromJson(Map<String, dynamic> json) =>
      _$CreateDiaryTagDtoFromJson(json);
}
