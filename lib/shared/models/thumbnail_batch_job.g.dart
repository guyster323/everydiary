// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thumbnail_batch_job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ThumbnailBatchJobImpl _$$ThumbnailBatchJobImplFromJson(
  Map<String, dynamic> json,
) => _$ThumbnailBatchJobImpl(
  id: (json['id'] as num?)?.toInt(),
  diaryId: (json['diaryId'] as num).toInt(),
  jobType:
      $enumDecodeNullable(_$ThumbnailBatchJobTypeEnumMap, json['jobType']) ??
      ThumbnailBatchJobType.regenerate,
  status:
      $enumDecodeNullable(_$ThumbnailBatchJobStatusEnumMap, json['status']) ??
      ThumbnailBatchJobStatus.pending,
  payload: json['payload'] as Map<String, dynamic>?,
  retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
  lastError: json['lastError'] as String?,
  scheduledAt: DateTime.parse(json['scheduledAt'] as String),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$$ThumbnailBatchJobImplToJson(
  _$ThumbnailBatchJobImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'diaryId': instance.diaryId,
  'jobType': _$ThumbnailBatchJobTypeEnumMap[instance.jobType]!,
  'status': _$ThumbnailBatchJobStatusEnumMap[instance.status]!,
  'payload': instance.payload,
  'retryCount': instance.retryCount,
  'lastError': instance.lastError,
  'scheduledAt': instance.scheduledAt.toIso8601String(),
  'startedAt': instance.startedAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'isDeleted': instance.isDeleted,
};

const _$ThumbnailBatchJobTypeEnumMap = {
  ThumbnailBatchJobType.regenerate: 'regenerate',
  ThumbnailBatchJobType.initial: 'initial',
  ThumbnailBatchJobType.bulkRebuild: 'bulk_rebuild',
};

const _$ThumbnailBatchJobStatusEnumMap = {
  ThumbnailBatchJobStatus.pending: 'pending',
  ThumbnailBatchJobStatus.processing: 'processing',
  ThumbnailBatchJobStatus.succeeded: 'succeeded',
  ThumbnailBatchJobStatus.failed: 'failed',
  ThumbnailBatchJobStatus.cancelled: 'cancelled',
};
