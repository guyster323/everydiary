// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttachmentImpl _$$AttachmentImplFromJson(Map<String, dynamic> json) =>
    _$AttachmentImpl(
      id: (json['id'] as num?)?.toInt(),
      diaryId: (json['diaryId'] as num).toInt(),
      filePath: json['filePath'] as String,
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      mimeType: json['mimeType'] as String?,
      thumbnailPath: json['thumbnailPath'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$AttachmentImplToJson(_$AttachmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'diaryId': instance.diaryId,
      'filePath': instance.filePath,
      'fileName': instance.fileName,
      'fileType': instance.fileType,
      'fileSize': instance.fileSize,
      'mimeType': instance.mimeType,
      'thumbnailPath': instance.thumbnailPath,
      'width': instance.width,
      'height': instance.height,
      'duration': instance.duration,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'isDeleted': instance.isDeleted,
    };

_$CreateAttachmentDtoImpl _$$CreateAttachmentDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CreateAttachmentDtoImpl(
  diaryId: (json['diaryId'] as num).toInt(),
  filePath: json['filePath'] as String,
  fileType: json['fileType'] as String,
  fileSize: (json['fileSize'] as num?)?.toInt(),
);

Map<String, dynamic> _$$CreateAttachmentDtoImplToJson(
  _$CreateAttachmentDtoImpl instance,
) => <String, dynamic>{
  'diaryId': instance.diaryId,
  'filePath': instance.filePath,
  'fileType': instance.fileType,
  'fileSize': instance.fileSize,
};

_$UpdateAttachmentDtoImpl _$$UpdateAttachmentDtoImplFromJson(
  Map<String, dynamic> json,
) => _$UpdateAttachmentDtoImpl(
  filePath: json['filePath'] as String?,
  fileType: json['fileType'] as String?,
  fileSize: (json['fileSize'] as num?)?.toInt(),
);

Map<String, dynamic> _$$UpdateAttachmentDtoImplToJson(
  _$UpdateAttachmentDtoImpl instance,
) => <String, dynamic>{
  'filePath': instance.filePath,
  'fileType': instance.fileType,
  'fileSize': instance.fileSize,
};
