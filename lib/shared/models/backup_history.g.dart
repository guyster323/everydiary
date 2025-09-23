// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BackupHistoryImpl _$$BackupHistoryImplFromJson(Map<String, dynamic> json) =>
    _$BackupHistoryImpl(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      backupType: json['backupType'] as String,
      filePath: json['filePath'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      completedAt: json['completedAt'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$BackupHistoryImplToJson(_$BackupHistoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'backupType': instance.backupType,
      'filePath': instance.filePath,
      'fileSize': instance.fileSize,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'completedAt': instance.completedAt,
      'errorMessage': instance.errorMessage,
    };

_$CreateBackupHistoryDtoImpl _$$CreateBackupHistoryDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CreateBackupHistoryDtoImpl(
  userId: (json['userId'] as num).toInt(),
  backupType: json['backupType'] as String,
  filePath: json['filePath'] as String?,
  fileSize: (json['fileSize'] as num?)?.toInt(),
  status: json['status'] as String,
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$$CreateBackupHistoryDtoImplToJson(
  _$CreateBackupHistoryDtoImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'backupType': instance.backupType,
  'filePath': instance.filePath,
  'fileSize': instance.fileSize,
  'status': instance.status,
  'errorMessage': instance.errorMessage,
};

_$UpdateBackupHistoryDtoImpl _$$UpdateBackupHistoryDtoImplFromJson(
  Map<String, dynamic> json,
) => _$UpdateBackupHistoryDtoImpl(
  filePath: json['filePath'] as String?,
  fileSize: (json['fileSize'] as num?)?.toInt(),
  status: json['status'] as String?,
  completedAt: json['completedAt'] as String?,
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$$UpdateBackupHistoryDtoImplToJson(
  _$UpdateBackupHistoryDtoImpl instance,
) => <String, dynamic>{
  'filePath': instance.filePath,
  'fileSize': instance.fileSize,
  'status': instance.status,
  'completedAt': instance.completedAt,
  'errorMessage': instance.errorMessage,
};
