import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_history.freezed.dart';
part 'backup_history.g.dart';

/// 백업 기록 모델
@freezed
class BackupHistory with _$BackupHistory {
  const factory BackupHistory({
    int? id,
    required int userId,
    required String backupType,
    String? filePath,
    int? fileSize,
    required String status,
    required String createdAt,
    String? completedAt,
    String? errorMessage,
  }) = _BackupHistory;

  factory BackupHistory.fromJson(Map<String, dynamic> json) =>
      _$BackupHistoryFromJson(json);
}

/// 백업 기록 생성용 DTO
@freezed
class CreateBackupHistoryDto with _$CreateBackupHistoryDto {
  const factory CreateBackupHistoryDto({
    required int userId,
    required String backupType,
    String? filePath,
    int? fileSize,
    required String status,
    String? errorMessage,
  }) = _CreateBackupHistoryDto;

  factory CreateBackupHistoryDto.fromJson(Map<String, dynamic> json) =>
      _$CreateBackupHistoryDtoFromJson(json);
}

/// 백업 기록 업데이트용 DTO
@freezed
class UpdateBackupHistoryDto with _$UpdateBackupHistoryDto {
  const factory UpdateBackupHistoryDto({
    String? filePath,
    int? fileSize,
    String? status,
    String? completedAt,
    String? errorMessage,
  }) = _UpdateBackupHistoryDto;

  factory UpdateBackupHistoryDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateBackupHistoryDtoFromJson(json);
}

/// 백업 타입 열거형
enum BackupType {
  @JsonValue('manual')
  manual,
  @JsonValue('automatic')
  automatic,
  @JsonValue('export')
  export,
  @JsonValue('import')
  import,
}

/// 백업 타입 확장
extension BackupTypeExtension on BackupType {
  String get value {
    switch (this) {
      case BackupType.manual:
        return 'manual';
      case BackupType.automatic:
        return 'automatic';
      case BackupType.export:
        return 'export';
      case BackupType.import:
        return 'import';
    }
  }

  static BackupType fromString(String value) {
    switch (value) {
      case 'manual':
        return BackupType.manual;
      case 'automatic':
        return BackupType.automatic;
      case 'export':
        return BackupType.export;
      case 'import':
        return BackupType.import;
      default:
        return BackupType.manual;
    }
  }
}

/// 백업 상태 열거형
enum BackupStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
}

/// 백업 상태 확장
extension BackupStatusExtension on BackupStatus {
  String get value {
    switch (this) {
      case BackupStatus.pending:
        return 'pending';
      case BackupStatus.inProgress:
        return 'in_progress';
      case BackupStatus.completed:
        return 'completed';
      case BackupStatus.failed:
        return 'failed';
      case BackupStatus.cancelled:
        return 'cancelled';
    }
  }

  static BackupStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return BackupStatus.pending;
      case 'in_progress':
        return BackupStatus.inProgress;
      case 'completed':
        return BackupStatus.completed;
      case 'failed':
        return BackupStatus.failed;
      case 'cancelled':
        return BackupStatus.cancelled;
      default:
        return BackupStatus.pending;
    }
  }
}
