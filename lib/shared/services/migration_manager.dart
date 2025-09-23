import 'package:sqflite/sqflite.dart';

import '../../core/utils/logger.dart';
import 'database_service.dart';

/// 마이그레이션 관리자
/// 데이터베이스 스키마 변경을 관리하고 버전별 마이그레이션을 처리
class MigrationManager {
  final DatabaseService _databaseService;
  static const String _migrationTable = 'schema_migrations';

  MigrationManager(this._databaseService);

  /// 마이그레이션 테이블 초기화
  Future<void> _initMigrationTable() async {
    final db = await _databaseService.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_migrationTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        version INTEGER UNIQUE NOT NULL,
        name TEXT NOT NULL,
        executed_at TEXT NOT NULL,
        checksum TEXT,
        rollback_sql TEXT
      )
    ''');
  }

  /// 마이그레이션 정의
  static const List<Migration> migrations = [
    Migration(
      version: 1,
      name: 'initial_schema',
      up: _migration1Up,
      down: _migration1Down,
    ),
    Migration(
      version: 2,
      name: 'add_diary_fields',
      up: _migration2Up,
      down: _migration2Down,
    ),
    Migration(
      version: 3,
      name: 'update_tags_table',
      up: _migration3Up,
      down: _migration3Down,
    ),
  ];

  /// 마이그레이션 1: 초기 스키마
  static Future<void> _migration1Up(Database db) async {
    // 이미 DatabaseSchema에서 처리되므로 여기서는 추가 작업만 수행
    await db.execute('''
      INSERT OR IGNORE INTO $_migrationTable (version, name, executed_at, checksum)
      VALUES (1, 'initial_schema', datetime('now'), 'initial')
    ''');
  }

  static Future<void> _migration1Down(Database db) async {
    // 초기 스키마 롤백 (모든 테이블 삭제)
    final tables = [
      'app_settings',
      'backup_history',
      'notification_settings',
      'diary_stats',
      'mood_stats',
      'attachments',
      'diary_tags',
      'tags',
      'diary_entries',
      'users',
    ];

    for (final table in tables) {
      await db.execute('DROP TABLE IF EXISTS $table');
    }

    await db.execute('DELETE FROM $_migrationTable WHERE version = 1');
  }

  /// 마이그레이션 2: 일기 테이블 필드 추가
  static Future<void> _migration2Up(Database db) async {
    // diary_entries 테이블에 새로운 필드들 추가
    await db.execute('''
      ALTER TABLE diary_entries ADD COLUMN latitude REAL
    ''');

    await db.execute('''
      ALTER TABLE diary_entries ADD COLUMN longitude REAL
    ''');

    await db.execute('''
      ALTER TABLE diary_entries ADD COLUMN is_favorite BOOLEAN DEFAULT 0
    ''');

    await db.execute('''
      ALTER TABLE diary_entries ADD COLUMN word_count INTEGER DEFAULT 0
    ''');

    await db.execute('''
      ALTER TABLE diary_entries ADD COLUMN reading_time INTEGER DEFAULT 0
    ''');

    // title 필드를 nullable로 변경 (이미 nullable이지만 명시적으로 처리)
    await db.execute('''
      CREATE TABLE diary_entries_new (
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
    ''');

    // 기존 데이터 복사
    await db.execute('''
      INSERT INTO diary_entries_new
      SELECT id, user_id, title, content, date, mood, weather, location,
             latitude, longitude, is_private, is_favorite, word_count, reading_time,
             created_at, updated_at, is_deleted
      FROM diary_entries
    ''');

    // 기존 테이블 삭제 및 새 테이블로 교체
    await db.execute('DROP TABLE diary_entries');
    await db.execute('ALTER TABLE diary_entries_new RENAME TO diary_entries');

    // 마이그레이션 기록 추가
    await db.execute('''
      INSERT OR IGNORE INTO $_migrationTable (version, name, executed_at, checksum)
      VALUES (2, 'add_diary_fields', datetime('now'), 'diary_fields_v2')
    ''');
  }

  static Future<void> _migration2Down(Database db) async {
    // 새로 추가된 필드들을 제거하고 원래 스키마로 복원
    await db.execute('''
      CREATE TABLE diary_entries_old (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        mood TEXT,
        weather TEXT,
        location TEXT,
        is_private BOOLEAN DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_deleted BOOLEAN DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 기존 데이터 복사 (새 필드 제외)
    await db.execute('''
      INSERT INTO diary_entries_old
      SELECT id, user_id, title, content, date, mood, weather, location,
             is_private, created_at, updated_at, is_deleted
      FROM diary_entries
    ''');

    // 기존 테이블 삭제 및 원래 테이블로 교체
    await db.execute('DROP TABLE diary_entries');
    await db.execute('ALTER TABLE diary_entries_old RENAME TO diary_entries');

    // 마이그레이션 기록 삭제
    await db.execute('DELETE FROM $_migrationTable WHERE version = 2');
  }

  /// 마이그레이션 3: 태그 테이블 업데이트
  static Future<void> _migration3Up(Database db) async {
    // 기존 태그 테이블을 새 스키마로 재생성
    await db.execute('''
      CREATE TABLE tags_new (
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
    ''');

    // 기존 데이터 복사 (기본값으로 누락된 필드 채우기)
    await db.execute('''
      INSERT INTO tags_new
      SELECT id, 1 as user_id, name, color, NULL as icon, NULL as description,
             0 as usage_count, created_at, updated_at, 0 as is_deleted
      FROM tags
    ''');

    // 기존 테이블 삭제 및 새 테이블로 교체
    await db.execute('DROP TABLE tags');
    await db.execute('ALTER TABLE tags_new RENAME TO tags');

    // 마이그레이션 기록 추가
    await db.execute('''
      INSERT OR IGNORE INTO $_migrationTable (version, name, executed_at, checksum)
      VALUES (3, 'update_tags_table', datetime('now'), 'tags_table_v3')
    ''');
  }

  static Future<void> _migration3Down(Database db) async {
    // 원래 태그 테이블로 복원
    await db.execute('''
      CREATE TABLE tags_old (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        color TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 기존 데이터 복사 (새 필드 제외)
    await db.execute('''
      INSERT INTO tags_old
      SELECT id, name, color, created_at, updated_at
      FROM tags
    ''');

    // 기존 테이블 삭제 및 원래 테이블로 교체
    await db.execute('DROP TABLE tags');
    await db.execute('ALTER TABLE tags_old RENAME TO tags');

    // 마이그레이션 기록 삭제
    await db.execute('DELETE FROM $_migrationTable WHERE version = 3');
  }

  /// 현재 데이터베이스 버전 조회
  Future<int> getCurrentVersion() async {
    await _initMigrationTable();
    final db = await _databaseService.database;

    final result = await db.rawQuery(
      'SELECT MAX(version) as version FROM $_migrationTable',
    );

    return result.first['version'] as int? ?? 0;
  }

  /// 실행된 마이그레이션 목록 조회
  Future<List<MigrationRecord>> getExecutedMigrations() async {
    await _initMigrationTable();
    final db = await _databaseService.database;

    final results = await db.query(_migrationTable, orderBy: 'version ASC');

    return results.map((row) => MigrationRecord.fromMap(row)).toList();
  }

  /// 마이그레이션 실행
  Future<void> migrate() async {
    await _initMigrationTable();
    final currentVersion = await getCurrentVersion();
    final targetVersion = migrations.last.version;

    if (currentVersion >= targetVersion) {
      return; // 이미 최신 버전
    }

    final db = await _databaseService.database;

    await db.transaction((txn) async {
      for (final migration in migrations) {
        if (migration.version > currentVersion) {
          try {
            await migration.upWithTransaction(txn);
            Logger.success(
              '마이그레이션 ${migration.version} (${migration.name}) 실행 완료',
              tag: 'MigrationManager',
            );
          } catch (e) {
            Logger.error(
              '마이그레이션 ${migration.version} 실행 실패',
              tag: 'MigrationManager',
              error: e,
            );
            rethrow;
          }
        }
      }
    });
  }

  /// 특정 버전으로 롤백
  Future<void> rollbackTo(int targetVersion) async {
    await _initMigrationTable();
    final currentVersion = await getCurrentVersion();

    if (currentVersion <= targetVersion) {
      return; // 이미 목표 버전 이하
    }

    final db = await _databaseService.database;

    await db.transaction((txn) async {
      // 역순으로 롤백 실행
      final migrationsToRollback =
          migrations
              .where(
                (m) => m.version > targetVersion && m.version <= currentVersion,
              )
              .toList()
            ..sort((a, b) => b.version.compareTo(a.version));

      for (final migration in migrationsToRollback) {
        try {
          await migration.downWithTransaction(txn);
          Logger.success(
            '롤백 ${migration.version} (${migration.name}) 실행 완료',
            tag: 'MigrationManager',
          );
        } catch (e) {
          Logger.error(
            '롤백 ${migration.version} 실행 실패',
            tag: 'MigrationManager',
            error: e,
          );
          rethrow;
        }
      }
    });
  }

  /// 마이그레이션 상태 확인
  Future<MigrationStatus> getMigrationStatus() async {
    await _initMigrationTable();
    final currentVersion = await getCurrentVersion();
    final targetVersion = migrations.last.version;
    final executedMigrations = await getExecutedMigrations();

    return MigrationStatus(
      currentVersion: currentVersion,
      targetVersion: targetVersion,
      isUpToDate: currentVersion >= targetVersion,
      executedMigrations: executedMigrations,
      pendingMigrations: migrations
          .where((m) => m.version > currentVersion)
          .toList(),
    );
  }

  /// 마이그레이션 검증
  Future<bool> validateMigrations() async {
    try {
      final status = await getMigrationStatus();

      // 실행된 마이그레이션과 정의된 마이그레이션 일치 확인
      for (final executed in status.executedMigrations) {
        final defined = migrations.firstWhere(
          (m) => m.version == executed.version,
          orElse: () => throw Exception('정의되지 않은 마이그레이션: ${executed.version}'),
        );

        if (defined.name != executed.name) {
          throw Exception('마이그레이션 이름 불일치: ${executed.version}');
        }
      }

      return true;
    } catch (e) {
      Logger.error('마이그레이션 검증 실패', tag: 'MigrationManager', error: e);
      return false;
    }
  }

  /// 마이그레이션 백업 생성
  Future<String> createMigrationBackup() async {
    final db = await _databaseService.database;
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final backupName = 'migration_backup_$timestamp';

    // 마이그레이션 기록 백업
    await db.query(_migrationTable);

    // 백업 데이터를 JSON 형태로 저장 (실제로는 파일로 저장)
    Logger.info('마이그레이션 백업 생성: $backupName', tag: 'MigrationManager');
    return backupName;
  }

  /// 마이그레이션 백업 복원
  Future<void> restoreMigrationBackup(String backupName) async {
    // 실제 구현에서는 백업 파일에서 데이터를 읽어와 복원
    Logger.info('마이그레이션 백업 복원: $backupName', tag: 'MigrationManager');
  }
}

/// 마이그레이션 정의 클래스
class Migration {
  final int version;
  final String name;
  final Future<void> Function(Database) up;
  final Future<void> Function(Database) down;

  const Migration({
    required this.version,
    required this.name,
    required this.up,
    required this.down,
  });

  /// 트랜잭션에서 실행할 수 있는 up 메서드
  Future<void> upWithTransaction(Transaction txn) async {
    // Transaction은 Database를 상속하므로 직접 전달 가능
    await up(txn as Database);
  }

  /// 트랜잭션에서 실행할 수 있는 down 메서드
  Future<void> downWithTransaction(Transaction txn) async {
    // Transaction은 Database를 상속하므로 직접 전달 가능
    await down(txn as Database);
  }
}

/// 마이그레이션 기록 모델
class MigrationRecord {
  final int id;
  final int version;
  final String name;
  final String executedAt;
  final String? checksum;
  final String? rollbackSql;

  const MigrationRecord({
    required this.id,
    required this.version,
    required this.name,
    required this.executedAt,
    this.checksum,
    this.rollbackSql,
  });

  factory MigrationRecord.fromMap(Map<String, dynamic> map) {
    return MigrationRecord(
      id: map['id'] as int,
      version: map['version'] as int,
      name: map['name'] as String,
      executedAt: map['executed_at'] as String,
      checksum: map['checksum'] as String?,
      rollbackSql: map['rollback_sql'] as String?,
    );
  }
}

/// 마이그레이션 상태 모델
class MigrationStatus {
  final int currentVersion;
  final int targetVersion;
  final bool isUpToDate;
  final List<MigrationRecord> executedMigrations;
  final List<Migration> pendingMigrations;

  const MigrationStatus({
    required this.currentVersion,
    required this.targetVersion,
    required this.isUpToDate,
    required this.executedMigrations,
    required this.pendingMigrations,
  });

  @override
  String toString() {
    return '''
MigrationStatus:
  Current Version: $currentVersion
  Target Version: $targetVersion
  Is Up to Date: $isUpToDate
  Executed Migrations: ${executedMigrations.length}
  Pending Migrations: ${pendingMigrations.length}
''';
  }
}
