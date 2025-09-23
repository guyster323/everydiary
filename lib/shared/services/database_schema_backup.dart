/// 데이터베이스 스키마 정의
/// Everydiary 앱의 모든 테이블 구조와 관계를 정의
class DatabaseSchema {
  static const int version = 1;

  /// 사용자 테이블
  static const String createUsersTable = '''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE,
      name TEXT NOT NULL,
      avatar_url TEXT,
      bio TEXT,
      birth_date TEXT,
      gender TEXT,
      timezone TEXT DEFAULT 'Asia/Seoul',
      language TEXT DEFAULT 'ko',
      theme TEXT DEFAULT 'system',
      notification_enabled INTEGER DEFAULT 1,
      notification_time TEXT DEFAULT '21:00',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      last_login_at TEXT,
      is_deleted INTEGER DEFAULT 0,
      is_premium INTEGER DEFAULT 0,
      premium_expires_at TEXT
    )
  ''';

  /// 일기 테이블
  static const String createDiaryEntriesTable = '''
    CREATE TABLE diary_entries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      title TEXT,
      content TEXT NOT NULL,
      mood TEXT,
      weather TEXT,
      location TEXT,
      latitude REAL,
      longitude REAL,
      is_private INTEGER DEFAULT 0,
      is_favorite INTEGER DEFAULT 0,
      word_count INTEGER DEFAULT 0,
      reading_time INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      is_deleted INTEGER DEFAULT 0,
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
    )
  ''';

  /// 태그 테이블
  static const String createTagsTable = '''
    CREATE TABLE tags (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      color TEXT DEFAULT '#6366F1',
      icon TEXT,
      description TEXT,
      usage_count INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      is_deleted INTEGER DEFAULT 0,
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
      UNIQUE(user_id, name)
    )
  ''';

  /// 일기-태그 관계 테이블
  static const String createDiaryTagsTable = '''
    CREATE TABLE diary_tags (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      diary_id INTEGER NOT NULL,
      tag_id INTEGER NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (diary_id) REFERENCES diary_entries (id) ON DELETE CASCADE,
      FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE,
      UNIQUE(diary_id, tag_id)
    )
  ''';

  /// 첨부파일 테이블
  static const String createAttachmentsTable = '''
    CREATE TABLE attachments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      diary_id INTEGER NOT NULL,
      file_path TEXT NOT NULL,
      file_name TEXT NOT NULL,
      file_type TEXT NOT NULL,
      file_size INTEGER,
      mime_type TEXT,
      thumbnail_path TEXT,
      width INTEGER,
      height INTEGER,
      duration INTEGER,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      is_deleted INTEGER DEFAULT 0,
      FOREIGN KEY (diary_id) REFERENCES diary_entries (id) ON DELETE CASCADE
    )
  ''';

  /// 기분 통계 테이블
  static const String createMoodStatsTable = '''
    CREATE TABLE mood_stats (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      mood TEXT NOT NULL,
      date TEXT NOT NULL,
      count INTEGER DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
      UNIQUE(user_id, mood, date)
    )
  ''';

  /// 일기 통계 테이블
  static const String createDiaryStatsTable = '''
    CREATE TABLE diary_stats (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      entries_count INTEGER DEFAULT 0,
      total_words INTEGER DEFAULT 0,
      total_reading_time INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
      UNIQUE(user_id, date)
    )
  ''';

  /// 알림 설정 테이블
  static const String createNotificationSettingsTable = '''
    CREATE TABLE notification_settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      type TEXT NOT NULL,
      enabled INTEGER DEFAULT 1,
      time TEXT,
      days TEXT,
      message TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
      UNIQUE(user_id, type)
    )
  ''';

  /// 백업 기록 테이블
  static const String createBackupHistoryTable = '''
    CREATE TABLE backup_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      backup_type TEXT NOT NULL,
      file_path TEXT,
      file_size INTEGER,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      completed_at TEXT,
      error_message TEXT,
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
    )
  ''';

  /// 앱 설정 테이블
  static const String createAppSettingsTable = '''
    CREATE TABLE app_settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      key TEXT UNIQUE NOT NULL,
      value TEXT,
      type TEXT NOT NULL,
      description TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  /// 일반 검색용 인덱스 (FTS5 대신 LIKE 검색 사용)
  static const String createDiarySearchIndexes = '''
    -- 일기 제목 검색용 인덱스
    CREATE INDEX idx_diary_title_search ON diaries(title);
    -- 일기 내용 검색용 인덱스  
    CREATE INDEX idx_diary_content_search ON diaries(content);
    -- 일기 태그 검색용 인덱스
    CREATE INDEX idx_diary_tags_search ON diaries(tags);
  ''';

  /// 인덱스 생성 쿼리들
  static const List<String> createIndexes = [
    // 사용자 테이블 인덱스
    'CREATE INDEX idx_users_email ON users(email)',
    'CREATE INDEX idx_users_created_at ON users(created_at)',
    'CREATE INDEX idx_users_is_deleted ON users(is_deleted)',
    'CREATE INDEX idx_users_email_deleted ON users(email, is_deleted)',

    // 일기 테이블 인덱스 - 기본 인덱스
    'CREATE INDEX idx_diary_entries_user_id ON diary_entries(user_id)',
    'CREATE INDEX idx_diary_entries_created_at ON diary_entries(created_at)',
    'CREATE INDEX idx_diary_entries_mood ON diary_entries(mood)',
    'CREATE INDEX idx_diary_entries_weather ON diary_entries(weather)',
    'CREATE INDEX idx_diary_entries_is_favorite ON diary_entries(is_favorite)',
    'CREATE INDEX idx_diary_entries_is_private ON diary_entries(is_private)',
    'CREATE INDEX idx_diary_entries_is_deleted ON diary_entries(is_deleted)',

    // 일기 테이블 인덱스 - 복합 인덱스 (성능 최적화)
    'CREATE INDEX idx_diary_entries_user_created ON diary_entries(user_id, created_at)',
    'CREATE INDEX idx_diary_entries_user_deleted_created ON diary_entries(user_id, is_deleted, created_at)',
    'CREATE INDEX idx_diary_entries_user_favorite_created ON diary_entries(user_id, is_favorite, created_at)',
    'CREATE INDEX idx_diary_entries_user_private_created ON diary_entries(user_id, is_private, created_at)',
    'CREATE INDEX idx_diary_entries_user_mood_created ON diary_entries(user_id, mood, created_at)',
    'CREATE INDEX idx_diary_entries_user_weather_created ON diary_entries(user_id, weather, created_at)',
    'CREATE INDEX idx_diary_entries_deleted_created ON diary_entries(is_deleted, created_at)',

    // 일기 테이블 인덱스 - 통계 및 분석용
    'CREATE INDEX idx_diary_entries_user_mood_date ON diary_entries(user_id, mood, date(created_at))',
    'CREATE INDEX idx_diary_entries_user_weather_date ON diary_entries(user_id, weather, date(created_at))',
    'CREATE INDEX idx_diary_entries_word_count ON diary_entries(user_id, word_count)',

    // 태그 테이블 인덱스
    'CREATE INDEX idx_tags_user_id ON tags(user_id)',
    'CREATE INDEX idx_tags_name ON tags(name)',
    'CREATE INDEX idx_tags_usage_count ON tags(usage_count)',
    'CREATE INDEX idx_tags_is_deleted ON tags(is_deleted)',
    'CREATE INDEX idx_tags_user_name ON tags(user_id, name)',
    'CREATE INDEX idx_tags_user_deleted ON tags(user_id, is_deleted)',
    'CREATE INDEX idx_tags_user_usage ON tags(user_id, usage_count DESC)',

    // 일기-태그 관계 테이블 인덱스
    'CREATE INDEX idx_diary_tags_diary_id ON diary_tags(diary_id)',
    'CREATE INDEX idx_diary_tags_tag_id ON diary_tags(tag_id)',
    'CREATE INDEX idx_diary_tags_diary_tag ON diary_tags(diary_id, tag_id)',

    // 첨부파일 테이블 인덱스
    'CREATE INDEX idx_attachments_diary_id ON attachments(diary_id)',
    'CREATE INDEX idx_attachments_file_type ON attachments(file_type)',
    'CREATE INDEX idx_attachments_is_deleted ON attachments(is_deleted)',
    'CREATE INDEX idx_attachments_diary_deleted ON attachments(diary_id, is_deleted)',
    'CREATE INDEX idx_attachments_type_deleted ON attachments(file_type, is_deleted)',

    // 기분 통계 테이블 인덱스
    'CREATE INDEX idx_mood_stats_user_id ON mood_stats(user_id)',
    'CREATE INDEX idx_mood_stats_date ON mood_stats(date)',
    'CREATE INDEX idx_mood_stats_mood ON mood_stats(mood)',
    'CREATE INDEX idx_mood_stats_user_date ON mood_stats(user_id, date)',
    'CREATE INDEX idx_mood_stats_user_mood_date ON mood_stats(user_id, mood, date)',

    // 일기 통계 테이블 인덱스
    'CREATE INDEX idx_diary_stats_user_id ON diary_stats(user_id)',
    'CREATE INDEX idx_diary_stats_date ON diary_stats(date)',
    'CREATE INDEX idx_diary_stats_user_date ON diary_stats(user_id, date)',
    'CREATE INDEX idx_diary_stats_user_month ON diary_stats(user_id, strftime("%Y-%m", date))',

    // 알림 설정 테이블 인덱스
    'CREATE INDEX idx_notification_settings_user_id ON notification_settings(user_id)',
    'CREATE INDEX idx_notification_settings_type ON notification_settings(type)',
    'CREATE INDEX idx_notification_settings_user_type ON notification_settings(user_id, type)',

    // 백업 기록 테이블 인덱스
    'CREATE INDEX idx_backup_history_user_id ON backup_history(user_id)',
    'CREATE INDEX idx_backup_history_created_at ON backup_history(created_at)',
    'CREATE INDEX idx_backup_history_status ON backup_history(status)',
    'CREATE INDEX idx_backup_history_user_status ON backup_history(user_id, status)',
    'CREATE INDEX idx_backup_history_user_created ON backup_history(user_id, created_at)',

    // 앱 설정 테이블 인덱스
    'CREATE INDEX idx_app_settings_key ON app_settings(key)',
    'CREATE INDEX idx_app_settings_type ON app_settings(type)',
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

  /// 검색 최적화를 위한 트리거들 (FTS5 대신 일반 인덱스 사용)
  static const List<String> createSearchTriggers = [
    // 일기 삽입 시 FTS 테이블 업데이트
    '''
    CREATE TRIGGER diary_fts_insert AFTER INSERT ON diary_entries
    BEGIN
      INSERT INTO diary_fts(diary_id, user_id, title, content, tags)
      SELECT
        NEW.id,
        NEW.user_id,
        NEW.title,
        NEW.content,
        COALESCE(GROUP_CONCAT(t.name, ' '), '')
      FROM diary_tags dt
      LEFT JOIN tags t ON dt.tag_id = t.id
      WHERE dt.diary_id = NEW.id
      GROUP BY dt.diary_id;
    END
    ''',

    // 일기 수정 시 FTS 테이블 업데이트
    '''
    CREATE TRIGGER diary_fts_update AFTER UPDATE ON diary_entries
    BEGIN
      DELETE FROM diary_fts WHERE diary_id = NEW.id;
      INSERT INTO diary_fts(diary_id, user_id, title, content, tags)
      SELECT
        NEW.id,
        NEW.user_id,
        NEW.title,
        NEW.content,
        COALESCE(GROUP_CONCAT(t.name, ' '), '')
      FROM diary_tags dt
      LEFT JOIN tags t ON dt.tag_id = t.id
      WHERE dt.diary_id = NEW.id
      GROUP BY dt.diary_id;
    END
    ''',

    // 일기 삭제 시 FTS 테이블에서 제거
    '''
    CREATE TRIGGER diary_fts_delete AFTER DELETE ON diary_entries
    BEGIN
      DELETE FROM diary_fts WHERE diary_id = OLD.id;
    END
    ''',

    // 태그 추가 시 FTS 테이블 업데이트
    '''
    CREATE TRIGGER diary_fts_tag_insert AFTER INSERT ON diary_tags
    BEGIN
      DELETE FROM diary_fts WHERE diary_id = NEW.diary_id;
      INSERT INTO diary_fts(diary_id, user_id, title, content, tags)
      SELECT
        d.id,
        d.user_id,
        d.title,
        d.content,
        COALESCE(GROUP_CONCAT(t.name, ' '), '')
      FROM diary_entries d
      LEFT JOIN diary_tags dt ON d.id = dt.diary_id
      LEFT JOIN tags t ON dt.tag_id = t.id
      WHERE d.id = NEW.diary_id AND d.is_deleted = 0
      GROUP BY d.id;
    END
    ''',

    // 태그 삭제 시 FTS 테이블 업데이트
    '''
    CREATE TRIGGER diary_fts_tag_delete AFTER DELETE ON diary_tags
    BEGIN
      DELETE FROM diary_fts WHERE diary_id = OLD.diary_id;
      INSERT INTO diary_fts(diary_id, user_id, title, content, tags)
      SELECT
        d.id,
        d.user_id,
        d.title,
        d.content,
        COALESCE(GROUP_CONCAT(t.name, ' '), '')
      FROM diary_entries d
      LEFT JOIN diary_tags dt ON d.id = dt.diary_id
      LEFT JOIN tags t ON dt.tag_id = t.id
      WHERE d.id = OLD.diary_id AND d.is_deleted = 0
      GROUP BY d.id;
    END
    ''',
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
    "INSERT INTO tags (user_id, name, color, description, created_at, updated_at) VALUES ($userId, '일상', '#10B981', '일상적인 하루', datetime('now'), datetime('now'))",
    "INSERT INTO tags (user_id, name, color, description, created_at, updated_at) VALUES ($userId, '여행', '#F59E0B', '여행 관련 일기', datetime('now'), datetime('now'))",
    "INSERT INTO tags (user_id, name, color, description, created_at, updated_at) VALUES ($userId, '감사', '#8B5CF6', '감사한 일들', datetime('now'), datetime('now'))",
    "INSERT INTO tags (user_id, name, color, description, created_at, updated_at) VALUES ($userId, '성장', '#06B6D4', '성장과 배움', datetime('now'), datetime('now'))",
    "INSERT INTO tags (user_id, name, color, description, created_at, updated_at) VALUES ($userId, '관계', '#EC4899', '사람들과의 관계', datetime('now'), datetime('now'))",
  ];

  /// 기본 알림 설정 생성
  static List<String> getDefaultNotificationSettings(int userId) => [
    "INSERT INTO notification_settings (user_id, type, enabled, time, days, message, created_at, updated_at) VALUES ($userId, 'daily_reminder', 1, '21:00', '1,2,3,4,5,6,7', '오늘 하루는 어떠셨나요? 일기를 작성해보세요.', datetime('now'), datetime('now'))",
    "INSERT INTO notification_settings (user_id, type, enabled, time, days, message, created_at, updated_at) VALUES ($userId, 'weekly_summary', 1, '20:00', '7', '이번 주 일기 요약을 확인해보세요.', datetime('now'), datetime('now'))",
  ];
}
