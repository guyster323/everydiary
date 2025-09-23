import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_connection_monitor.dart';
import 'database_performance.dart';
import 'database_schema.dart';
import 'migration_manager.dart';
import 'search_service.dart';
import 'seed_data_service.dart';

/// 데이터베이스 서비스 클래스
/// SQLite를 사용한 로컬 데이터베이스 관리
class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'everydiary.db';
  static const int _databaseVersion = DatabaseSchema.version;

  late MigrationManager _migrationManager;
  late DatabasePerformance _performance;
  late SearchService _searchService;
  late DatabaseConnectionMonitor _connectionMonitor;
  late SeedDataService _seedDataService;

  /// 데이터베이스 인스턴스 가져오기
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 데이터베이스 초기화
  Future<Database> _initDatabase() async {
    String path;

    if (kIsWeb) {
      // 웹에서는 메모리 데이터베이스 사용
      path = ':memory:';
    } else {
      // 모바일/데스크톱에서는 파일 시스템 사용
      final Directory documentsDirectory =
          await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, _databaseName);
    }

    // 마이그레이션 매니저 초기화 (데이터베이스 열기 전에)
    _migrationManager = MigrationManager(this);

    final db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // 성능 모니터링 및 검색 서비스 초기화
    _performance = DatabasePerformance(db);
    _searchService = SearchService(db);
    _connectionMonitor = DatabaseConnectionMonitor(db);
    _seedDataService = SeedDataService(db);

    return db;
  }

  /// 데이터베이스 생성 시 실행
  Future<void> _onCreate(Database db, int version) async {
    // 테이블 생성
    for (final createTableQuery in DatabaseSchema.createTables) {
      await db.execute(createTableQuery);
    }

    // 인덱스 생성
    await _createIndexes(db);

    // FTS 트리거 생성
    await _createSearchTriggers(db);

    // 초기 데이터 삽입
    await _insertInitialData(db);
  }

  /// 데이터베이스 업그레이드 시 실행
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 마이그레이션 매니저를 통한 업그레이드 처리
    await _migrationManager.migrate();
  }

  /// 인덱스 생성
  Future<void> _createIndexes(Database db) async {
    for (final createIndexQuery in DatabaseSchema.createIndexes) {
      await db.execute(createIndexQuery);
    }
  }

  /// FTS 트리거 생성
  Future<void> _createSearchTriggers(Database db) async {
    for (final createTriggerQuery in DatabaseSchema.createSearchTriggers) {
      await db.execute(createTriggerQuery);
    }
  }

  /// 초기 데이터 삽입
  Future<void> _insertInitialData(Database db) async {
    for (final insertQuery in DatabaseSchema.insertInitialData) {
      await db.execute(insertQuery);
    }
  }

  /// 데이터베이스 연결 종료
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// 데이터베이스 삭제 (개발/테스트용)
  Future<void> deleteDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  /// 마이그레이션 실행
  Future<void> migrate() async {
    await _migrationManager.migrate();
  }

  /// 마이그레이션 상태 확인
  Future<MigrationStatus> getMigrationStatus() async {
    return await _migrationManager.getMigrationStatus();
  }

  /// 마이그레이션 롤백
  Future<void> rollbackTo(int version) async {
    await _migrationManager.rollbackTo(version);
  }

  /// 마이그레이션 검증
  Future<bool> validateMigrations() async {
    return await _migrationManager.validateMigrations();
  }

  /// 마이그레이션 매니저 가져오기
  MigrationManager get migrationManager => _migrationManager;

  /// 성능 모니터링 서비스 가져오기
  DatabasePerformance get performance => _performance;

  /// 검색 서비스 가져오기
  SearchService get searchService => _searchService;

  /// 데이터베이스 최적화 실행
  Future<Map<String, dynamic>> optimizeDatabase() async {
    return await _performance.optimizeDatabase();
  }

  /// 데이터베이스 통계 조회
  Future<Map<String, dynamic>> getDatabaseStats() async {
    return await _performance.getDatabaseStats();
  }

  /// 쿼리 성능 벤치마크
  Future<Map<String, dynamic>> benchmarkCommonQueries() async {
    return await _performance.benchmarkCommonQueries();
  }

  /// 인덱스 최적화 제안 조회
  Future<List<Map<String, dynamic>>> getIndexOptimizationSuggestions() async {
    return await _performance.getIndexOptimizationSuggestions();
  }

  /// 연결 모니터링 서비스 가져오기
  DatabaseConnectionMonitor get connectionMonitor => _connectionMonitor;

  /// 시드 데이터 서비스 가져오기
  SeedDataService get seedDataService => _seedDataService;

  /// 연결 모니터링 시작
  void startConnectionMonitoring() {
    _connectionMonitor.startMonitoring();
  }

  /// 연결 모니터링 중지
  void stopConnectionMonitoring() {
    _connectionMonitor.stopMonitoring();
  }

  /// 데이터베이스 상태 리포트 생성
  Future<DatabaseStatusReport> generateStatusReport() async {
    return await _connectionMonitor.generateStatusReport();
  }

  /// 초기 시드 데이터 생성
  Future<void> createSeedData({int? userId}) async {
    await _seedDataService.createAllSeedData(userId: userId);
  }

  /// 시드 데이터 검증
  Future<SeedDataValidationResult> validateSeedData(int? userId) async {
    return await _seedDataService.validateSeedData(userId);
  }

  /// 시드 데이터 재생성
  Future<void> recreateSeedData(int? userId) async {
    await _seedDataService.recreateSeedData(userId);
  }

  /// 데이터베이스 연결 테스트
  Future<DatabaseConnectionTestResult> testConnection() async {
    return await _connectionMonitor.testConnection();
  }

  /// 데이터베이스 무결성 검사
  Future<DatabaseIntegrityResult> checkIntegrity() async {
    return await _connectionMonitor.checkIntegrity();
  }

  /// 리소스 정리
  void dispose() {
    _connectionMonitor.dispose();
  }
}
