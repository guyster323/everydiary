import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// 사용자 모델
@freezed
class User with _$User {
  const factory User({
    int? id,
    String? email,
    required String name,
    String? avatarUrl,
    String? bio,
    String? birthDate,
    String? gender,
    @Default('Asia/Seoul') String timezone,
    @Default('ko') String language,
    @Default('system') String theme,
    @Default(true) bool notificationEnabled,
    @Default('21:00') String notificationTime,
    required String createdAt,
    required String updatedAt,
    String? lastLoginAt,
    @Default(false) bool isDeleted,
    @Default(false) bool isPremium,
    String? premiumExpiresAt,
    // 인증 관련 필드
    @Default(false) bool isEmailVerified,
    @Default([]) List<String> roles,
    String? passwordHash,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// 사용자 생성용 DTO
@freezed
class CreateUserDto with _$CreateUserDto {
  const factory CreateUserDto({String? email, required String name}) =
      _CreateUserDto;

  factory CreateUserDto.fromJson(Map<String, dynamic> json) =>
      _$CreateUserDtoFromJson(json);
}

/// 사용자 업데이트용 DTO
@freezed
class UpdateUserDto with _$UpdateUserDto {
  const factory UpdateUserDto({String? email, String? name}) = _UpdateUserDto;

  factory UpdateUserDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserDtoFromJson(json);
}
