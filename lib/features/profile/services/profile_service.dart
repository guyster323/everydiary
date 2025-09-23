import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../../shared/services/database_service.dart';
import '../models/profile_model.dart';

/// 프로필 서비스
/// 사용자 프로필 데이터를 저장하고 불러오는 서비스입니다.
class ProfileService {
  static const String _profileKey = 'user_profile';
  static const String _profileStatsKey = 'user_profile_stats';

  /// 프로필 저장
  Future<void> saveProfile(ProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = profile.toJson();
      final profileString = jsonEncode(profileJson);
      await prefs.setString(_profileKey, profileString);
    } catch (e) {
      throw Exception('프로필 저장 실패: $e');
    }
  }

  /// 프로필 로드
  Future<ProfileModel> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileString = prefs.getString(_profileKey);

      if (profileString == null) {
        // 기본 프로필 생성
        final now = DateTime.now();
        final defaultProfile = ProfileModel(
          id: _generateUserId(),
          username: '사용자',
          email: '',
          createdAt: now,
          updatedAt: now,
        );
        await saveProfile(defaultProfile);
        return defaultProfile;
      }

      final profileJson = jsonDecode(profileString) as Map<String, dynamic>;
      return ProfileModel.fromJson(profileJson);
    } catch (e) {
      throw Exception('프로필 로드 실패: $e');
    }
  }

  /// 프로필 통계 저장
  Future<void> saveProfileStats(ProfileStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = stats.toJson();
      final statsString = jsonEncode(statsJson);
      await prefs.setString(_profileStatsKey, statsString);
    } catch (e) {
      throw Exception('프로필 통계 저장 실패: $e');
    }
  }

  /// 프로필 통계 로드
  Future<ProfileStats> loadProfileStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsString = prefs.getString(_profileStatsKey);

      if (statsString == null) {
        // 기본 통계 생성
        const defaultStats = ProfileStats();
        await saveProfileStats(defaultStats);
        return defaultStats;
      }

      final statsJson = jsonDecode(statsString) as Map<String, dynamic>;
      return ProfileStats.fromJson(statsJson);
    } catch (e) {
      throw Exception('프로필 통계 로드 실패: $e');
    }
  }

  /// 프로필 삭제
  Future<void> deleteProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
      await prefs.remove(_profileStatsKey);
    } catch (e) {
      throw Exception('프로필 삭제 실패: $e');
    }
  }

  /// 프로필 백업 (JSON 문자열로)
  Future<String> backupProfile() async {
    try {
      final profile = await loadProfile();
      final stats = await loadProfileStats();

      final backupData = {
        'profile': profile.toJson(),
        'stats': stats.toJson(),
        'backupDate': DateTime.now().toIso8601String(),
      };

      return jsonEncode(backupData);
    } catch (e) {
      throw Exception('프로필 백업 실패: $e');
    }
  }

  /// 프로필 복원 (JSON 문자열에서)
  Future<void> restoreProfile(String backupJson) async {
    try {
      final backupData = jsonDecode(backupJson) as Map<String, dynamic>;

      if (backupData['profile'] != null) {
        final profile = ProfileModel.fromJson(
          backupData['profile'] as Map<String, dynamic>,
        );
        await saveProfile(profile);
      }

      if (backupData['stats'] != null) {
        final stats = ProfileStats.fromJson(
          backupData['stats'] as Map<String, dynamic>,
        );
        await saveProfileStats(stats);
      }
    } catch (e) {
      throw Exception('프로필 복원 실패: $e');
    }
  }

  /// 프로필 존재 여부 확인
  Future<bool> hasProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_profileKey);
    } catch (e) {
      return false;
    }
  }

  /// 프로필 크기 확인 (바이트)
  Future<int> getProfileSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileString = prefs.getString(_profileKey);
      final statsString = prefs.getString(_profileStatsKey);

      final profileSize = profileString?.length ?? 0;
      final statsSize = statsString?.length ?? 0;

      return profileSize + statsSize;
    } catch (e) {
      return 0;
    }
  }

  /// 사용자 ID 생성
  String _generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'user_$timestamp$random';
  }

  /// 프로필 검증
  bool validateProfile(ProfileModel profile) {
    // 기본적인 프로필 검증 로직
    if (profile.username.isEmpty) {
      return false;
    }

    if (profile.email.isNotEmpty && !_isValidEmail(profile.email)) {
      return false;
    }

    return true;
  }

  /// 이메일 형식 검증
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// 프로필 통계 계산
  Future<ProfileStats> calculateStats() async {
    try {
      final databaseService = DatabaseService();
      final db = await databaseService.database;

      // 현재 사용자 ID 가져오기 (임시로 1 사용)
      const userId = 1;

      // 전체 일기 수
      final totalDiariesResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM diary_entries WHERE user_id = ? AND is_deleted = 0',
        [userId],
      );
      final totalDiaries = totalDiariesResult.first['count'] as int;

      // 전체 단어 수
      final totalWordsResult = await db.rawQuery(
        'SELECT SUM(word_count) as total FROM diary_entries WHERE user_id = ? AND is_deleted = 0',
        [userId],
      );
      final totalWords = (totalWordsResult.first['total'] as int?) ?? 0;

      // 전체 문자 수
      final totalCharactersResult = await db.rawQuery(
        'SELECT SUM(LENGTH(content)) as total FROM diary_entries WHERE user_id = ? AND is_deleted = 0',
        [userId],
      );
      final totalCharacters = (totalCharactersResult.first['total'] as int?) ?? 0;

      // 이번 달 일기 수
      final now = DateTime.now();
      final thisMonthStart = DateTime(now.year, now.month, 1);
      final thisMonthEnd = DateTime(now.year, now.month + 1, 0);

      final thisMonthDiariesResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM diary_entries WHERE user_id = ? AND is_deleted = 0 AND date BETWEEN ? AND ?',
        [userId, thisMonthStart.toIso8601String(), thisMonthEnd.toIso8601String()],
      );
      final thisMonthDiaries = thisMonthDiariesResult.first['count'] as int;

      // 이번 주 일기 수
      final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
      final thisWeekEnd = thisWeekStart.add(const Duration(days: 6));

      final thisWeekDiariesResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM diary_entries WHERE user_id = ? AND is_deleted = 0 AND date BETWEEN ? AND ?',
        [userId, thisWeekStart.toIso8601String(), thisWeekEnd.toIso8601String()],
      );
      final thisWeekDiaries = thisWeekDiariesResult.first['count'] as int;

      // 연속 일기 수 계산
      final consecutiveDays = await _calculateConsecutiveDays(db, userId);

      // 가장 긴 연속 기록
      final longestStreak = await _calculateLongestStreak(db, userId);

      // 평균 단어 수
      final averageWordsPerDiary = totalDiaries > 0 ? (totalWords / totalDiaries).round() : 0;

      // 가장 많이 사용된 태그
      final mostUsedTags = await _getMostUsedTags(db, userId);

      // 첫 일기 날짜
      final firstDiaryResult = await db.rawQuery(
        'SELECT MIN(date) as first_date FROM diary_entries WHERE user_id = ? AND is_deleted = 0',
        [userId],
      );
      final firstDiaryDateStr = firstDiaryResult.first['first_date'] as String?;
      final firstDiaryDate = firstDiaryDateStr != null ? DateTime.parse(firstDiaryDateStr) : null;

      // 마지막 일기 날짜
      final lastDiaryResult = await db.rawQuery(
        'SELECT MAX(date) as last_date FROM diary_entries WHERE user_id = ? AND is_deleted = 0',
        [userId],
      );
      final lastDiaryDateStr = lastDiaryResult.first['last_date'] as String?;
      final lastDiaryDate = lastDiaryDateStr != null ? DateTime.parse(lastDiaryDateStr) : null;

      return ProfileStats(
        totalDiaries: totalDiaries,
        consecutiveDays: consecutiveDays,
        totalWords: totalWords,
        totalCharacters: totalCharacters,
        thisMonthDiaries: thisMonthDiaries,
        thisWeekDiaries: thisWeekDiaries,
        longestStreak: longestStreak,
        averageWordsPerDiary: averageWordsPerDiary,
        mostUsedTags: mostUsedTags,
        firstDiaryDate: firstDiaryDate,
        lastDiaryDate: lastDiaryDate,
      );
    } catch (e) {
      throw Exception('통계 계산 실패: $e');
    }
  }

  /// 연속 일기 수 계산
  Future<int> _calculateConsecutiveDays(sqflite.Database db, int userId) async {
    final result = await db.rawQuery(
      'SELECT date FROM diary_entries WHERE user_id = ? AND is_deleted = 0 ORDER BY date DESC',
      [userId],
    );

    if (result.isEmpty) return 0;

    int consecutiveDays = 0;
    DateTime? lastDate;

    for (final row in result) {
      final dateStr = row['date'] as String;
      final date = DateTime.parse(dateStr);

      if (lastDate == null) {
        consecutiveDays = 1;
        lastDate = date;
      } else {
        final difference = lastDate.difference(date).inDays;
        if (difference == 1) {
          consecutiveDays++;
          lastDate = date;
        } else {
          break;
        }
      }
    }

    return consecutiveDays;
  }

  /// 가장 긴 연속 기록 계산
  Future<int> _calculateLongestStreak(sqflite.Database db, int userId) async {
    final result = await db.rawQuery(
      'SELECT date FROM diary_entries WHERE user_id = ? AND is_deleted = 0 ORDER BY date ASC',
      [userId],
    );

    if (result.isEmpty) return 0;

    int longestStreak = 0;
    int currentStreak = 1;
    DateTime? lastDate;

    for (final row in result) {
      final dateStr = row['date'] as String;
      final date = DateTime.parse(dateStr);

      if (lastDate == null) {
        currentStreak = 1;
        lastDate = date;
      } else {
        final difference = date.difference(lastDate).inDays;
        if (difference == 1) {
          currentStreak++;
        } else {
          longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
          currentStreak = 1;
        }
        lastDate = date;
      }
    }

    return longestStreak > currentStreak ? longestStreak : currentStreak;
  }

  /// 가장 많이 사용된 태그 가져오기
  Future<List<String>> _getMostUsedTags(sqflite.Database db, int userId) async {
    final result = await db.rawQuery(
      '''
      SELECT t.name, COUNT(dt.diary_id) as usage_count
      FROM tags t
      JOIN diary_tags dt ON t.id = dt.tag_id
      JOIN diary_entries de ON dt.diary_id = de.id
      WHERE t.user_id = ? AND de.is_deleted = 0
      GROUP BY t.id, t.name
      ORDER BY usage_count DESC
      LIMIT 5
      ''',
      [userId],
    );

    return result.map((Map<String, dynamic> row) => row['name'] as String).toList();
  }

  /// 프로필 초기화
  Future<void> resetProfile() async {
    try {
      await deleteProfile();
      await loadProfile(); // 기본 프로필 생성
      await loadProfileStats(); // 기본 통계 생성
    } catch (e) {
      throw Exception('프로필 초기화 실패: $e');
    }
  }
}
