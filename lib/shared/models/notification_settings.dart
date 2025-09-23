import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_settings.freezed.dart';
part 'notification_settings.g.dart';

/// 알림 설정 모델
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    int? id,
    required int userId,
    required String type,
    @Default(true) bool enabled,
    String? time,
    String? days,
    String? message,
    required String createdAt,
    required String updatedAt,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);
}

/// 알림 설정 생성용 DTO
@freezed
class CreateNotificationSettingsDto with _$CreateNotificationSettingsDto {
  const factory CreateNotificationSettingsDto({
    required int userId,
    required String type,
    @Default(true) bool enabled,
    String? time,
    String? days,
    String? message,
  }) = _CreateNotificationSettingsDto;

  factory CreateNotificationSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$CreateNotificationSettingsDtoFromJson(json);
}

/// 알림 설정 업데이트용 DTO
@freezed
class UpdateNotificationSettingsDto with _$UpdateNotificationSettingsDto {
  const factory UpdateNotificationSettingsDto({
    String? type,
    bool? enabled,
    String? time,
    String? days,
    String? message,
  }) = _UpdateNotificationSettingsDto;

  factory UpdateNotificationSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateNotificationSettingsDtoFromJson(json);
}

/// 알림 타입 열거형
enum NotificationType {
  @JsonValue('daily_reminder')
  dailyReminder,
  @JsonValue('weekly_summary')
  weeklySummary,
  @JsonValue('monthly_report')
  monthlyReport,
  @JsonValue('backup_reminder')
  backupReminder,
  @JsonValue('streak_reminder')
  streakReminder,
}

/// 알림 타입 확장
extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.dailyReminder:
        return 'daily_reminder';
      case NotificationType.weeklySummary:
        return 'weekly_summary';
      case NotificationType.monthlyReport:
        return 'monthly_report';
      case NotificationType.backupReminder:
        return 'backup_reminder';
      case NotificationType.streakReminder:
        return 'streak_reminder';
    }
  }

  static NotificationType fromString(String value) {
    switch (value) {
      case 'daily_reminder':
        return NotificationType.dailyReminder;
      case 'weekly_summary':
        return NotificationType.weeklySummary;
      case 'monthly_report':
        return NotificationType.monthlyReport;
      case 'backup_reminder':
        return NotificationType.backupReminder;
      case 'streak_reminder':
        return NotificationType.streakReminder;
      default:
        return NotificationType.dailyReminder;
    }
  }
}
