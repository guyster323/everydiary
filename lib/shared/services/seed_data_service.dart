import 'package:sqflite/sqflite.dart';

/// 초기 시드 데이터 서비스
/// 앱 첫 실행 시 필요한 기본 데이터를 생성
class SeedDataService {
  final Database _database;

  SeedDataService(this._database);

  /// 모든 초기 데이터 생성
  Future<void> createAllSeedData({int? userId}) async {
    await _createDefaultTags(userId);
    await _createDefaultNotificationSettings(userId);
    await _createDefaultMoodStats(userId);
    await _createDefaultDiaryStats(userId);
    await _createWelcomeDiary(userId);
  }

  /// 기본 태그 생성
  Future<void> _createDefaultTags(int? userId) async {
    if (userId == null) return;

    final defaultTags = [
      {
        'user_id': userId,
        'name': '일상',
        'color': '#10B981',
        'icon': 'home',
        'description': '일상적인 하루의 기록',
        'usage_count': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_deleted': 0,
      },
      {
        'user_id': userId,
        'name': '여행',
        'color': '#F59E0B',
        'icon': 'airplane',
        'description': '여행과 탐험의 기록',
        'usage_count': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_deleted': 0,
      },
      {
        'user_id': userId,
        'name': '감사',
        'color': '#8B5CF6',
        'icon': 'heart',
        'description': '감사한 순간들',
        'usage_count': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_deleted': 0,
      },
      {
        'user_id': userId,
        'name': '성장',
        'color': '#06B6D4',
        'icon': 'trending-up',
        'description': '성장과 배움의 과정',
        'usage_count': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_deleted': 0,
      },
      {
        'user_id': userId,
        'name': '관계',
        'color': '#EC4899',
        'icon': 'users',
        'description': '사람들과의 소중한 관계',
        'usage_count': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_deleted': 0,
      },
      {
        'user_id': userId,
        'name': '건강',
        'color': '#EF4444',
        'icon': 'activity',
        'description': '건강과 운동 관련',
        'usage_count': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_deleted': 0,
      },
      {
        'user_id': userId,
        'name': '취미',
        'color': '#84CC16',
        'icon': 'star',
        'description': '취미와 관심사',
        'usage_count': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_deleted': 0,
      },
      {
        'user_id': userId,
        'name': '일',
        'color': '#6366F1',
        'icon': 'briefcase',
        'description': '업무와 직장 관련',
        'usage_count': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_deleted': 0,
      },
    ];

    for (final tag in defaultTags) {
      await _database.insert('tags', tag);
    }
  }

  /// 기본 알림 설정 생성
  Future<void> _createDefaultNotificationSettings(int? userId) async {
    if (userId == null) return;

    final defaultSettings = [
      {
        'user_id': userId,
        'type': 'daily_reminder',
        'enabled': 1,
        'time': '21:00',
        'message': '오늘 하루는 어떠셨나요? 일기를 작성해보세요.',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'user_id': userId,
        'type': 'weekly_summary',
        'enabled': 1,
        'time': '20:00',
        'message': '이번 주 일기 요약을 확인해보세요.',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'user_id': userId,
        'type': 'backup_reminder',
        'enabled': 1,
        'time': '22:00',
        'message': '일기 데이터를 백업하는 것을 잊지 마세요.',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final setting in defaultSettings) {
      await _database.insert('notification_settings', setting);
    }
  }

  /// 기본 기분 통계 초기화
  Future<void> _createDefaultMoodStats(int? userId) async {
    if (userId == null) return;

    final moods = ['매우 좋음', '좋음', '보통', '나쁨', '매우 나쁨'];
    final today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];

      // 랜덤하게 기분 데이터 생성 (실제로는 사용자가 입력)
      final mood = moods[i % moods.length];

      await _database.insert('mood_stats', {
        'user_id': userId,
        'date': dateStr,
        'mood': mood,
        'count': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// 기본 일기 통계 초기화
  Future<void> _createDefaultDiaryStats(int? userId) async {
    if (userId == null) return;

    final today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];

      // 랜덤하게 일기 작성 여부 설정
      final hasDiary = i % 2 == 0; // 홀수 날에는 일기 작성

      await _database.insert('diary_stats', {
        'user_id': userId,
        'date': dateStr,
        'diary_count': hasDiary ? 1 : 0,
        'word_count': hasDiary ? (50 + (i * 10)) : 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// 환영 일기 생성
  Future<void> _createWelcomeDiary(int? userId) async {
    if (userId == null) return;

    final welcomeDiary = {
      'user_id': userId,
      'title': 'Everydiary에 오신 것을 환영합니다!',
      'content': '''안녕하세요! Everydiary에 오신 것을 환영합니다.

이 앱을 통해 소중한 순간들을 기록하고, 감정을 정리하며, 성장의 과정을 되돌아볼 수 있습니다.

**시작하기:**
- 매일 일기를 작성해보세요
- 태그를 사용해 일기를 분류해보세요
- 기분과 날씨를 기록해보세요
- 통계를 통해 자신의 패턴을 파악해보세요

일기 쓰기는 자신과의 대화입니다. 부담 없이 시작해보세요!''',
      'mood': '좋음',
      'weather': '맑음',
      'is_private': 0,
      'is_favorite': 1,
      'word_count': 150,
      'reading_time': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_deleted': 0,
    };

    final diaryId = await _database.insert('diary_entries', welcomeDiary);

    // 환영 일기에 기본 태그 추가
    final defaultTagIds = await _database.rawQuery(
      '''
      SELECT id FROM tags
      WHERE user_id = ? AND name IN ('일상', '감사')
    ''',
      [userId],
    );

    for (final tagRow in defaultTagIds) {
      await _database.insert('diary_tags', {
        'diary_id': diaryId,
        'tag_id': tagRow['id'],
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// 시드 데이터 검증
  Future<SeedDataValidationResult> validateSeedData(int? userId) async {
    if (userId == null) {
      return SeedDataValidationResult(
        isValid: false,
        errors: ['사용자 ID가 없습니다'],
        timestamp: DateTime.now(),
      );
    }

    final errors = <String>[];

    try {
      // 태그 검증
      final tagCount = await _database.rawQuery(
        'SELECT COUNT(*) as count FROM tags WHERE user_id = ?',
        [userId],
      );
      if (tagCount.first['count'] == 0) {
        errors.add('기본 태그가 생성되지 않았습니다');
      }

      // 알림 설정 검증
      final notificationCount = await _database.rawQuery(
        'SELECT COUNT(*) as count FROM notification_settings WHERE user_id = ?',
        [userId],
      );
      if (notificationCount.first['count'] == 0) {
        errors.add('기본 알림 설정이 생성되지 않았습니다');
      }

      // 환영 일기 검증
      final welcomeDiaryCount = await _database.rawQuery(
        'SELECT COUNT(*) as count FROM diary_entries WHERE user_id = ? AND title LIKE ?',
        [userId, '%환영%'],
      );
      if (welcomeDiaryCount.first['count'] == 0) {
        errors.add('환영 일기가 생성되지 않았습니다');
      }

      return SeedDataValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return SeedDataValidationResult(
        isValid: false,
        errors: ['시드 데이터 검증 중 오류 발생: $e'],
        timestamp: DateTime.now(),
      );
    }
  }

  /// 시드 데이터 재생성
  Future<void> recreateSeedData(int? userId) async {
    if (userId == null) return;

    try {
      // 기존 시드 데이터 삭제
      await _database.delete(
        'diary_entries',
        where: 'user_id = ? AND title LIKE ?',
        whereArgs: [userId, '%환영%'],
      );
      await _database.delete('tags', where: 'user_id = ?', whereArgs: [userId]);
      await _database.delete(
        'notification_settings',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      await _database.delete(
        'mood_stats',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      await _database.delete(
        'diary_stats',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      // 시드 데이터 재생성
      await createAllSeedData(userId: userId);
    } catch (e) {
      throw Exception('시드 데이터 재생성 중 오류 발생: $e');
    }
  }
}

/// 시드 데이터 검증 결과
class SeedDataValidationResult {
  final bool isValid;
  final List<String> errors;
  final DateTime timestamp;

  SeedDataValidationResult({
    required this.isValid,
    required this.errors,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'isValid': isValid,
    'errors': errors,
    'timestamp': timestamp.toIso8601String(),
  };
}
