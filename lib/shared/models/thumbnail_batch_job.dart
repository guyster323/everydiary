import 'package:freezed_annotation/freezed_annotation.dart';

part 'thumbnail_batch_job.freezed.dart';
part 'thumbnail_batch_job.g.dart';

@freezed
class ThumbnailBatchJob with _$ThumbnailBatchJob {
  const factory ThumbnailBatchJob({
    int? id,
    required int diaryId,
    @Default(ThumbnailBatchJobType.regenerate) ThumbnailBatchJobType jobType,
    @Default(ThumbnailBatchJobStatus.pending) ThumbnailBatchJobStatus status,
    Map<String, dynamic>? payload,
    @Default(0) int retryCount,
    String? lastError,
    required DateTime scheduledAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
  }) = _ThumbnailBatchJob;

  factory ThumbnailBatchJob.fromJson(Map<String, dynamic> json) =>
      _$ThumbnailBatchJobFromJson(json);
}

enum ThumbnailBatchJobStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('succeeded')
  succeeded,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
}

extension ThumbnailBatchJobStatusX on ThumbnailBatchJobStatus {
  String get value => name;

  bool get isTerminal => switch (this) {
    ThumbnailBatchJobStatus.succeeded => true,
    ThumbnailBatchJobStatus.failed => true,
    ThumbnailBatchJobStatus.cancelled => true,
    _ => false,
  };

  static ThumbnailBatchJobStatus fromValue(String value) {
    return ThumbnailBatchJobStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ThumbnailBatchJobStatus.pending,
    );
  }
}

enum ThumbnailBatchJobType {
  @JsonValue('regenerate')
  regenerate,
  @JsonValue('initial')
  initial,
  @JsonValue('bulk_rebuild')
  bulkRebuild,
}

extension ThumbnailBatchJobTypeX on ThumbnailBatchJobType {
  String get value => name;

  static ThumbnailBatchJobType fromValue(String value) {
    return ThumbnailBatchJobType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ThumbnailBatchJobType.regenerate,
    );
  }
}
