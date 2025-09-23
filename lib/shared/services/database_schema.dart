import 'package:sqflite/sqflite.dart';

/// 데이터베이스 스키마 정의
class DatabaseSchema {
  static const int version = 3;

  /// 사용자 테이블
  static const String createUsersTable = '''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE NOT NULL,
      username TEXT NOT NULL,
      password_hash TEXT NOT NULL,
      profile_image_url TEXT,
      is_premium BOOLEAN DEFAULT 0,
      premium_expires_at TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      is_deleted BOOLEAN DEFAULT 0
    )
  ''';

  /// 일기 테이블
  static const String createDiaryEntriesTable = '''
    CREATE TABLE diary_entries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      title TEXT,
      content TEXT NOT NULL,
      date TEXT NOT NULL,
      mood TEXT,
      weather TEXT,
      location TEXT,
      latitude REAL,
      longitude REAL,
      is_private BOOLEAN DEFAULT 0,
      is_favorite BOOLEAN DEFAULT 0,
      word_count INTEGER DEFAULT 0,
      reading_time INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      is_deleted BOOLEAN DEFAULT 0,
      FOREIGN KEY (user_id) REFERENCES users (id)
    )
  ''';

  /// 태그 테이블
  static const String createTagsTable = '''
    CREATE TABLE tags (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      color TEXT,
      icon TEXT,
      description TEXT,
      usage_count INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      is_deleted BOOLEAN DEFAULT 0,
      FOREIGN KEY (user_id) REFERENCES users (id)
    )
  ''';

  /// 일기-태그 연결 테이블
  static const String createDiaryTagsTable = '''
    CREATE TABLE diary_tags (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      diary_id INTEGER NOT NULL,
      tag_id INTEGER NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (diary_id) REFERENCES diary_entries (id),
      FOREIGN KEY (tag_id) REFERENCES tags (id),
      UNIQUE(diary_id, tag_id)
    )
  ''';

  /// 첨부파일 테이블
  static const String createAttachmentsTable = '''
    CREATE TABLE attachments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      diary_id INTEGER NOT NULL,
      file_path TEXT NOT NULL,
      file_type TEXT NOT NULL,
      file_size INTEGER,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      is_deleted BOOLEAN DEFAULT 0,
      FOREIGN KEY (diary_id) REFERENCES diary_entries (id)
    )
  ''';

  /// 기분 통계 테이블
  static const String createMoodStatsTable = '''
    CREATE TABLE mood_stats (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      mood TEXT NOT NULL,
      count INTEGER DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id),
      UNIQUE(user_id, date, mood)
    )
  ''';

  /// 일기 통계 테이블
  static const String createDiaryStatsTable = '''
    CREATE TABLE diary_stats (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      total_entries INTEGER DEFAULT 0,
      total_words INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id),
      UNIQUE(user_id, date)
    )
  ''';

  /// 알림 설정 테이블
  static const String createNotificationSettingsTable = '''
    CREATE TABLE notification_settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      reminder_time TEXT,
      is_enabled BOOLEAN DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id)
    )
  ''';

  /// 백업 히스토리 테이블
  static const String createBackupHistoryTable = '''
    CREATE TABLE backup_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      backup_type TEXT NOT NULL,
      file_path TEXT NOT NULL,
      file_size INTEGER,
      created_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id)
    )
  ''';

  /// 앱 설정 테이블
  static const String createAppSettingsTable = '''
    CREATE TABLE app_settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      key TEXT UNIQUE NOT NULL,
      value TEXT NOT NULL,
      type TEXT NOT NULL,
      description TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  /// 일반 검색용 인덱스 (FTS5 대신 LIKE 검색 사용)
  static const String createDiarySearchIndexes = '''
    -- 일기 제목 검색용 인덱스
    CREATE INDEX idx_diary_title_search ON diary_entries(title);
    -- 일기 내용 검색용 인덱스
    CREATE INDEX idx_diary_content_search ON diary_entries(content);
    -- 일기 날짜 검색용 인덱스
    CREATE INDEX idx_diary_date_search ON diary_entries(date);
    -- 사용자별 일기 검색용 인덱스
    CREATE INDEX idx_diary_user_search ON diary_entries(user_id);
  ''';

  /// 인덱스 생성 쿼리들
  static const List<String> createIndexes = [
    // 사용자 테이블 인덱스
    'CREATE INDEX idx_users_email ON users(email)',
    'CREATE INDEX idx_users_created_at ON users(created_at)',
    'CREATE INDEX idx_users_is_deleted ON users(is_deleted)',

    // 일기 테이블 인덱스
    'CREATE INDEX idx_diary_entries_user_id ON diary_entries(user_id)',
    'CREATE INDEX idx_diary_entries_date ON diary_entries(date)',
    'CREATE INDEX idx_diary_entries_created_at ON diary_entries(created_at)',
    'CREATE INDEX idx_diary_entries_is_deleted ON diary_entries(is_deleted)',

    // 태그 테이블 인덱스
    'CREATE INDEX idx_tags_name ON tags(name)',

    // 일기-태그 연결 테이블 인덱스
    'CREATE INDEX idx_diary_tags_diary_id ON diary_tags(diary_id)',
    'CREATE INDEX idx_diary_tags_tag_id ON diary_tags(tag_id)',

    // 첨부파일 테이블 인덱스
    'CREATE INDEX idx_attachments_diary_id ON attachments(diary_id)',
    'CREATE INDEX idx_attachments_is_deleted ON attachments(is_deleted)',

    // 통계 테이블 인덱스
    'CREATE INDEX idx_mood_stats_user_date ON mood_stats(user_id, date)',
    'CREATE INDEX idx_diary_stats_user_date ON diary_stats(user_id, date)',

    // 알림 설정 테이블 인덱스
    'CREATE INDEX idx_notification_settings_user_id ON notification_settings(user_id)',

    // 백업 히스토리 테이블 인덱스
    'CREATE INDEX idx_backup_history_user_id ON backup_history(user_id)',
    'CREATE INDEX idx_backup_history_created_at ON backup_history(created_at)',
  ];

  /// 검색 최적화를 위한 트리거들 (FTS5 대신 일반 인덱스 사용)
  static const List<String> createSearchTriggers = [
    // 현재는 일반 인덱스로 충분하므로 빈 배열
  ];

  /// 초기 데이터 삽입 쿼리
  static const List<String> insertInitialData = [
    // 기본 앱 설정
    "INSERT INTO app_settings (key, value, type, description, created_at, updated_at) VALUES ('app_version', '1.0.0', 'string', '현재 앱 버전', datetime('now'), datetime('now'))",
    "INSERT INTO app_settings (key, value, type, description, created_at, updated_at) VALUES ('database_version', '1', 'integer', '데이터베이스 버전', datetime('now'), datetime('now'))",
    "INSERT INTO app_settings (key, value, type, description, created_at, updated_at) VALUES ('last_backup', '', 'string', '마지막 백업 시간', datetime('now'), datetime('now'))",
    "INSERT INTO app_settings (key, value, type, description, created_at, updated_at) VALUES ('auto_backup_enabled', '1', 'boolean', '자동 백업 활성화', datetime('now'), datetime('now'))",
    "INSERT INTO app_settings (key, value, type, description, created_at, updated_at) VALUES ('backup_frequency', '7', 'integer', '백업 주기 (일)', datetime('now'), datetime('now'))",
  ];

  /// 기본 태그 생성
  static List<String> getDefaultTags(int userId) => [
    "INSERT INTO tags (name, color, created_at, updated_at) VALUES ('일상', '#FF6B6B', datetime('now'), datetime('now'))",
    "INSERT INTO tags (name, color, created_at, updated_at) VALUES ('여행', '#4ECDC4', datetime('now'), datetime('now'))",
    "INSERT INTO tags (name, color, created_at, updated_at) VALUES ('일기', '#45B7D1', datetime('now'), datetime('now'))",
    "INSERT INTO tags (name, color, created_at, updated_at) VALUES ('감정', '#96CEB4', datetime('now'), datetime('now'))",
    "INSERT INTO tags (name, color, created_at, updated_at) VALUES ('회고', '#FFEAA7', datetime('now'), datetime('now'))",
  ];

  /// 모든 테이블 생성 쿼리
  static const List<String> createTables = [
    createUsersTable,
    createDiaryEntriesTable,
    createTagsTable,
    createDiaryTagsTable,
    createAttachmentsTable,
    createMoodStatsTable,
    createDiaryStatsTable,
    createNotificationSettingsTable,
    createBackupHistoryTable,
    createAppSettingsTable,
    createDiarySearchIndexes,
  ];

  /// 데이터베이스 초기화
  static Future<void> initializeDatabase(Database db) async {
    // 테이블 생성
    for (final query in createTables) {
      await db.execute(query);
    }

    // 인덱스 생성
    for (final query in createIndexes) {
      await db.execute(query);
    }

    // 트리거 생성
    for (final query in createSearchTriggers) {
      await db.execute(query);
    }

    // 초기 데이터 삽입
    for (final query in insertInitialData) {
      await db.execute(query);
    }
  }
}
