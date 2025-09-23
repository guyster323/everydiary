import '../../core/utils/logger.dart';
import '../models/user.dart';
import 'database_connection_monitor.dart';
import 'database_service.dart';
import 'migration_manager.dart';
import 'relationship_manager.dart';
import 'repositories/diary_repository.dart';
import 'repositories/user_repository.dart';
import 'seed_data_service.dart';
import 'storage_service.dart';

/// 데이터베이스 관리자
/// 데이터베이스 초기화, 마이그레이션, 초기 데이터 설정을 담당
class DatabaseManager {
  static DatabaseManager? _instance;
  static DatabaseManager get instance => _instance ??= DatabaseManager._();

  DatabaseManager._();

  late DatabaseService _databaseService;
  late UserRepository _userRepository;
  late DiaryRepository _diaryRepository;
  late RelationshipManager _relationshipManager;

  /// 데이터베이스 초기화
  Future<void> initialize() async {
    try {
      // StorageService 초기화
      await StorageService.init();

      // DatabaseService 초기화
      _databaseService = DatabaseService();
      await _databaseService.database; // 데이터베이스 생성/열기

      // 연결 모니터링 시작
      _databaseService.startConnectionMonitoring();

      // 리포지토리 초기화
      _userRepository = UserRepository(_databaseService);
      _diaryRepository = DiaryRepository(_databaseService);
      _relationshipManager = RelationshipManager(_databaseService);

      // 마이그레이션 실행
      await _runMigrations();

      // 초기 데이터 설정
      await _setupInitialData();

      // 관계 무결성 검증
      await _validateInitialIntegrity();

      // 데이터베이스 최적화
      await _databaseService.optimizeDatabase();
    } catch (e) {
      // 에러 로깅 및 재시도 로직
      Logger.error('데이터베이스 초기화 중 오류 발생', tag: 'DatabaseManager', error: e);
      rethrow;
    }
  }

  /// 초기 데이터 설정
  Future<void> _setupInitialData() async {
    // 첫 실행인지 확인
    if (StorageService.isFirstRun()) {
      await _createDefaultUser();
      await StorageService.setFirstRunCompleted();
    }
  }

  /// 기본 사용자 생성
  Future<void> _createDefaultUser() async {
    try {
      // 이미 사용자가 있는지 확인
      final userCount = await _userRepository.getUserCount();
      if (userCount > 0) return;

      // 기본 사용자 생성
      const defaultUser = CreateUserDto(name: '사용자');

      final user = await _userRepository.createUser(defaultUser);

      // 시드 데이터 생성 (기본 태그, 알림 설정, 환영 일기 등)
      await _databaseService.createSeedData(userId: user.id);

      // 시드 데이터 검증
      final validationResult = await _databaseService.validateSeedData(user.id);
      if (!validationResult.isValid) {
        Logger.warning(
          '시드 데이터 검증 실패: ${validationResult.errors}',
          tag: 'DatabaseManager',
        );
        // 시드 데이터 재생성 시도
        await _databaseService.recreateSeedData(user.id);
      }
    } catch (e) {
      // 에러 로깅
      Logger.error('기본 사용자 생성 중 오류 발생', tag: 'DatabaseManager', error: e);
      rethrow;
    }
  }

  /// 데이터베이스 백업
  Future<Map<String, dynamic>> backupDatabase() async {
    // 모든 테이블의 데이터를 백업
    final backup = <String, dynamic>{};

    // 사용자 데이터
    final users = await _userRepository.getAllUsers();
    backup['users'] = users.map((user) => user.toJson()).toList();

    // 일기 데이터 (모든 사용자)
    for (final user in users) {
      final diaries = await _diaryRepository.getDiaryEntriesByUserId(user.id!);
      backup['diaries_${user.id}'] = diaries
          .map((diary) => diary.toJson())
          .toList();
    }

    // 메타데이터
    backup['backup_date'] = DateTime.now().toIso8601String();
    backup['version'] = 1;

    return backup;
  }

  /// 데이터베이스 복원
  Future<void> restoreDatabase(Map<String, dynamic> backup) async {
    try {
      final db = await _databaseService.database;
      await db.transaction((txn) async {
        // 기존 데이터 삭제
        await txn.delete('diary_entries');
        await txn.delete('users');

        // 사용자 데이터 복원
        if (backup['users'] != null) {
          final users = backup['users'] as List<dynamic>;
          for (final userData in users) {
            await txn.insert('users', userData as Map<String, Object?>);
          }
        }

        // 일기 데이터 복원
        for (final key in backup.keys) {
          if (key.startsWith('diaries_')) {
            if (backup[key] != null) {
              final diaries = backup[key] as List<dynamic>;
              for (final diaryData in diaries) {
                await txn.insert(
                  'diary_entries',
                  diaryData as Map<String, Object?>,
                );
              }
            }
          }
        }
      });
    } catch (e) {
      throw Exception('데이터베이스 복원 중 오류 발생: $e');
    }
  }

  /// 데이터베이스 정리
  Future<void> cleanupDatabase() async {
    // 삭제된 데이터 정리 (30일 이상 된 것)
    final thirtyDaysAgo = DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String();

    final db = await _databaseService.database;

    await db.delete(
      'diary_entries',
      where: 'is_deleted = 1 AND updated_at < ?',
      whereArgs: [thirtyDaysAgo],
    );

    await db.delete(
      'users',
      where: 'is_deleted = 1 AND updated_at < ?',
      whereArgs: [thirtyDaysAgo],
    );
  }

  /// 데이터베이스 통계
  Future<Map<String, int>> getDatabaseStats() async {
    final db = await _databaseService.database;

    final stats = <String, int>{};

    // 사용자 수
    final userCount = await _userRepository.getUserCount();
    stats['users'] = userCount;

    // 일기 수 (전체)
    final diaryResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM diary_entries WHERE is_deleted = 0',
    );
    stats['diaries'] = diaryResult.first['count'] as int;

    // 삭제된 데이터 수
    final deletedDiaryResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM diary_entries WHERE is_deleted = 1',
    );
    stats['deleted_diaries'] = deletedDiaryResult.first['count'] as int;

    final deletedUserResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM users WHERE is_deleted = 1',
    );
    stats['deleted_users'] = deletedUserResult.first['count'] as int;

    return stats;
  }

  /// 데이터베이스 연결 종료
  Future<void> close() async {
    _databaseService.stopConnectionMonitoring();
    _databaseService.dispose();
    await _databaseService.close();
    await StorageService.close();
  }

  /// 데이터베이스 상태 리포트 생성
  Future<DatabaseStatusReport> generateStatusReport() async {
    return await _databaseService.generateStatusReport();
  }

  /// 데이터베이스 연결 테스트
  Future<DatabaseConnectionTestResult> testConnection() async {
    return await _databaseService.testConnection();
  }

  /// 데이터베이스 무결성 검사
  Future<DatabaseIntegrityResult> checkIntegrity() async {
    return await _databaseService.checkIntegrity();
  }

  /// 시드 데이터 검증
  Future<SeedDataValidationResult> validateSeedData(int? userId) async {
    return await _databaseService.validateSeedData(userId);
  }

  /// 시드 데이터 재생성
  Future<void> recreateSeedData(int? userId) async {
    await _databaseService.recreateSeedData(userId);
  }

  /// 데이터베이스 성능 벤치마크
  Future<Map<String, dynamic>> benchmarkPerformance() async {
    return await _databaseService.benchmarkCommonQueries();
  }

  /// 데이터베이스 최적화
  Future<Map<String, dynamic>> optimizeDatabase() async {
    return await _databaseService.optimizeDatabase();
  }

  /// 초기 무결성 검증
  Future<void> _validateInitialIntegrity() async {
    try {
      final integrityReport = await _relationshipManager
          .generateIntegrityReport();
      if (integrityReport['is_healthy'] != true) {
        Logger.warning(
          '데이터베이스 무결성 문제 발견: ${integrityReport['total_orphaned_records']}개의 고아 레코드',
          tag: 'DatabaseManager',
        );
        // 자동 복구 시도
        await _relationshipManager.repairRelationships();
      }
    } catch (e) {
      Logger.error('무결성 검증 중 오류 발생', tag: 'DatabaseManager', error: e);
    }
  }

  /// 관계 무결성 검증
  Future<Map<String, dynamic>> validateIntegrity() async {
    return await _relationshipManager.generateIntegrityReport();
  }

  /// 관계 복구
  Future<Map<String, dynamic>> repairRelationships() async {
    return await _relationshipManager.repairRelationships();
  }

  /// 관계 최적화
  Future<void> optimizeRelationships() async {
    await _relationshipManager.optimizeRelationships();
  }

  /// 관계 통계 조회
  Future<Map<String, List<Map<String, dynamic>>>> getRelationshipStats() async {
    return await _relationshipManager.getRelationshipStats();
  }

  /// 마이그레이션 실행
  Future<void> _runMigrations() async {
    try {
      await _databaseService.migrate();
      Logger.success('마이그레이션 실행 완료', tag: 'DatabaseManager');
    } catch (e) {
      Logger.error('마이그레이션 실행 중 오류 발생', tag: 'DatabaseManager', error: e);
      rethrow;
    }
  }

  /// 마이그레이션 상태 확인
  Future<MigrationStatus> getMigrationStatus() async {
    return await _databaseService.getMigrationStatus();
  }

  /// 마이그레이션 롤백
  Future<void> rollbackMigration(int version) async {
    await _databaseService.rollbackTo(version);
  }

  /// 마이그레이션 검증
  Future<bool> validateMigrations() async {
    return await _databaseService.validateMigrations();
  }

  // Getters
  DatabaseService get databaseService => _databaseService;
  UserRepository get userRepository => _userRepository;
  DiaryRepository get diaryRepository => _diaryRepository;
  RelationshipManager get relationshipManager => _relationshipManager;
}
