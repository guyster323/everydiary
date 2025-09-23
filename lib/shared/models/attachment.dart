import 'package:freezed_annotation/freezed_annotation.dart';

part 'attachment.freezed.dart';
part 'attachment.g.dart';

/// 첨부파일 모델
@freezed
class Attachment with _$Attachment {
  const factory Attachment({
    int? id,
    required int diaryId,
    required String filePath,
    required String fileName,
    required String fileType,
    int? fileSize,
    String? mimeType,
    String? thumbnailPath,
    int? width,
    int? height,
    int? duration,
    required String createdAt,
    required String updatedAt,
    @Default(false) bool isDeleted,
  }) = _Attachment;

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);
}

/// 첨부파일 생성용 DTO
@freezed
class CreateAttachmentDto with _$CreateAttachmentDto {
  const factory CreateAttachmentDto({
    required int diaryId,
    required String filePath,
    required String fileType,
    int? fileSize,
  }) = _CreateAttachmentDto;

  factory CreateAttachmentDto.fromJson(Map<String, dynamic> json) =>
      _$CreateAttachmentDtoFromJson(json);
}

/// 첨부파일 업데이트용 DTO
@freezed
class UpdateAttachmentDto with _$UpdateAttachmentDto {
  const factory UpdateAttachmentDto({
    String? filePath,
    String? fileType,
    int? fileSize,
  }) = _UpdateAttachmentDto;

  factory UpdateAttachmentDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateAttachmentDtoFromJson(json);
}

/// 파일 타입 열거형
enum FileType {
  @JsonValue('image')
  image,
  @JsonValue('audio')
  audio,
  @JsonValue('video')
  video,
  @JsonValue('document')
  document,
  @JsonValue('other')
  other,
}

/// 파일 타입 확장
extension FileTypeExtension on FileType {
  String get value {
    switch (this) {
      case FileType.image:
        return 'image';
      case FileType.audio:
        return 'audio';
      case FileType.video:
        return 'video';
      case FileType.document:
        return 'document';
      case FileType.other:
        return 'other';
    }
  }

  static FileType fromString(String value) {
    switch (value) {
      case 'image':
        return FileType.image;
      case 'audio':
        return FileType.audio;
      case 'video':
        return FileType.video;
      case 'document':
        return FileType.document;
      case 'other':
        return FileType.other;
      default:
        return FileType.other;
    }
  }
}
