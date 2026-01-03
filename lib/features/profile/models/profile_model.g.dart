// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileModelImpl _$$ProfileModelImplFromJson(Map<String, dynamic> json) =>
    _$ProfileModelImpl(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profileImagePath: json['profileImagePath'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      totalDiaries: (json['totalDiaries'] as num?)?.toInt() ?? 0,
      consecutiveDays: (json['consecutiveDays'] as num?)?.toInt() ?? 0,
      totalWords: (json['totalWords'] as num?)?.toInt() ?? 0,
      totalCharacters: (json['totalCharacters'] as num?)?.toInt() ?? 0,
      favoriteTags:
          (json['favoriteTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      timezone: json['timezone'] as String? ?? '',
      language: json['language'] as String? ?? '',
    );

Map<String, dynamic> _$$ProfileModelImplToJson(_$ProfileModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'profileImagePath': instance.profileImagePath,
      'bio': instance.bio,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'totalDiaries': instance.totalDiaries,
      'consecutiveDays': instance.consecutiveDays,
      'totalWords': instance.totalWords,
      'totalCharacters': instance.totalCharacters,
      'favoriteTags': instance.favoriteTags,
      'timezone': instance.timezone,
      'language': instance.language,
    };

_$ProfileStatsImpl _$$ProfileStatsImplFromJson(Map<String, dynamic> json) =>
    _$ProfileStatsImpl(
      totalDiaries: (json['totalDiaries'] as num?)?.toInt() ?? 0,
      consecutiveDays: (json['consecutiveDays'] as num?)?.toInt() ?? 0,
      totalWords: (json['totalWords'] as num?)?.toInt() ?? 0,
      totalCharacters: (json['totalCharacters'] as num?)?.toInt() ?? 0,
      thisMonthDiaries: (json['thisMonthDiaries'] as num?)?.toInt() ?? 0,
      thisWeekDiaries: (json['thisWeekDiaries'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      averageWordsPerDiary:
          (json['averageWordsPerDiary'] as num?)?.toInt() ?? 0,
      mostUsedTags:
          (json['mostUsedTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      firstDiaryDate: json['firstDiaryDate'] == null
          ? null
          : DateTime.parse(json['firstDiaryDate'] as String),
      lastDiaryDate: json['lastDiaryDate'] == null
          ? null
          : DateTime.parse(json['lastDiaryDate'] as String),
    );

Map<String, dynamic> _$$ProfileStatsImplToJson(_$ProfileStatsImpl instance) =>
    <String, dynamic>{
      'totalDiaries': instance.totalDiaries,
      'consecutiveDays': instance.consecutiveDays,
      'totalWords': instance.totalWords,
      'totalCharacters': instance.totalCharacters,
      'thisMonthDiaries': instance.thisMonthDiaries,
      'thisWeekDiaries': instance.thisWeekDiaries,
      'longestStreak': instance.longestStreak,
      'averageWordsPerDiary': instance.averageWordsPerDiary,
      'mostUsedTags': instance.mostUsedTags,
      'firstDiaryDate': instance.firstDiaryDate?.toIso8601String(),
      'lastDiaryDate': instance.lastDiaryDate?.toIso8601String(),
    };
