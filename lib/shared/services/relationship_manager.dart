import 'database_relationships.dart';
import 'database_service.dart';

/// 관계 관리자
/// 데이터베이스 테이블 간 관계를 관리하고 무결성을 보장
class RelationshipManager {
  final DatabaseService _databaseService;

  RelationshipManager(this._databaseService);

  /// 관계 무결성 검증
  Future<Map<String, int>> validateRelationships() async {
    final db = await _databaseService.database;
    final results = <String, int>{};

    for (
      int i = 0;
      i < DatabaseRelationships.integrityCheckQueries.length;
      i++
    ) {
      final query = DatabaseRelationships.integrityCheckQueries[i];
      final result = await db.rawQuery(query);
      final count = result.first.values.first as int;

      switch (i) {
        case 0:
          results['orphaned_diaries'] = count;
          break;
        case 1:
          results['orphaned_tags'] = count;
          break;
        case 2:
          results['orphaned_diary_tags'] = count;
          break;
        case 3:
          results['orphaned_attachments'] = count;
          break;
        case 4:
          results['orphaned_mood_stats'] = count;
          break;
        case 5:
          results['orphaned_diary_stats'] = count;
          break;
      }
    }

    return results;
  }

  /// 관계 정리 (고아 레코드 삭제)
  Future<Map<String, int>> cleanupRelationships() async {
    final db = await _databaseService.database;
    final results = <String, int>{};

    await db.transaction((txn) async {
      for (int i = 0; i < DatabaseRelationships.cleanupQueries.length; i++) {
        final query = DatabaseRelationships.cleanupQueries[i];
        final changes = await txn.rawDelete(query);

        switch (i) {
          case 0:
            results['cleaned_diaries'] = changes;
            break;
          case 1:
            results['cleaned_tags'] = changes;
            break;
          case 2:
            results['cleaned_diary_tags'] = changes;
            break;
          case 3:
            results['cleaned_attachments'] = changes;
            break;
          case 4:
            results['cleaned_mood_stats'] = changes;
            break;
          case 5:
            results['cleaned_diary_stats'] = changes;
            break;
          case 6:
            results['cleaned_notification_settings'] = changes;
            break;
          case 7:
            results['cleaned_backup_history'] = changes;
            break;
        }
      }
    });

    return results;
  }

  /// 관계 통계 조회
  Future<Map<String, List<Map<String, dynamic>>>> getRelationshipStats() async {
    final db = await _databaseService.database;
    final results = <String, List<Map<String, dynamic>>>{};

    for (final entry
        in DatabaseRelationships.relationshipStatsQueries.entries) {
      final query = entry.value;
      final result = await db.rawQuery(query);
      results[entry.key] = result;
    }

    return results;
  }

  /// 관계 최적화 실행
  Future<void> optimizeRelationships() async {
    final db = await _databaseService.database;

    await db.transaction((txn) async {
      for (final query in DatabaseRelationships.optimizationQueries) {
        await txn.execute(query);
      }
    });
  }

  /// 특정 사용자의 모든 관련 데이터 삭제
  Future<void> deleteUserCascade(int userId) async {
    final db = await _databaseService.database;

    await db.transaction((txn) async {
      // 사용자의 모든 관련 데이터 삭제 (CASCADE로 자동 처리됨)
      await txn.delete('users', where: 'id = ?', whereArgs: [userId]);
    });
  }

  /// 특정 일기의 모든 관련 데이터 삭제
  Future<void> deleteDiaryCascade(int diaryId) async {
    final db = await _databaseService.database;

    await db.transaction((txn) async {
      // 일기의 모든 관련 데이터 삭제 (CASCADE로 자동 처리됨)
      await txn.delete('diary_entries', where: 'id = ?', whereArgs: [diaryId]);
    });
  }

  /// 특정 태그의 모든 관련 데이터 삭제
  Future<void> deleteTagCascade(int tagId) async {
    final db = await _databaseService.database;

    await db.transaction((txn) async {
      // 태그의 모든 관련 데이터 삭제 (CASCADE로 자동 처리됨)
      await txn.delete('tags', where: 'id = ?', whereArgs: [tagId]);
    });
  }

  /// 관계 무결성 리포트 생성
  Future<Map<String, dynamic>> generateIntegrityReport() async {
    final validationResults = await validateRelationships();
    final relationshipStats = await getRelationshipStats();

    final totalOrphaned = validationResults.values.fold(
      0,
      (sum, count) => sum + count,
    );
    final isHealthy = totalOrphaned == 0;

    return {
      'is_healthy': isHealthy,
      'total_orphaned_records': totalOrphaned,
      'validation_results': validationResults,
      'relationship_stats': relationshipStats,
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// 관계 복구 (고아 레코드 정리 후 재검증)
  Future<Map<String, dynamic>> repairRelationships() async {
    // 1. 현재 상태 확인
    final beforeReport = await generateIntegrityReport();

    // 2. 고아 레코드 정리
    final cleanupResults = await cleanupRelationships();

    // 3. 관계 최적화
    await optimizeRelationships();

    // 4. 정리 후 상태 확인
    final afterReport = await generateIntegrityReport();

    return {
      'before_repair': beforeReport,
      'cleanup_results': cleanupResults,
      'after_repair': afterReport,
      'repair_completed_at': DateTime.now().toIso8601String(),
    };
  }

  /// 특정 테이블의 관계 정보 조회
  Future<List<TableRelationship>> getTableRelationships(
    String tableName,
  ) async {
    return DatabaseRelationships.relationships[tableName] ?? [];
  }

  /// 모든 테이블 관계 정보 조회
  Future<Map<String, List<TableRelationship>>> getAllRelationships() async {
    return DatabaseRelationships.relationships;
  }

  /// 관계 의존성 체크 (삭제 가능 여부 확인)
  Future<bool> canDeleteRecord(String tableName, int recordId) async {
    final db = await _databaseService.database;

    // 해당 테이블을 참조하는 다른 테이블이 있는지 확인
    final relationships = DatabaseRelationships.relationships[tableName] ?? [];

    for (final relationship in relationships) {
      final query =
          '''
        SELECT COUNT(*) as count
        FROM ${relationship.targetTable}
        WHERE ${relationship.foreignKey} = ?
      ''';

      final result = await db.rawQuery(query, [recordId]);
      final count = result.first['count'] as int;

      if (count > 0) {
        return false; // 참조하는 레코드가 있으면 삭제 불가
      }
    }

    return true; // 참조하는 레코드가 없으면 삭제 가능
  }

  /// 관계 의존성 정보 조회 (삭제 시 영향받는 레코드 수)
  Future<Map<String, int>> getDependencyCounts(
    String tableName,
    int recordId,
  ) async {
    final db = await _databaseService.database;
    final results = <String, int>{};

    final relationships = DatabaseRelationships.relationships[tableName] ?? [];

    for (final relationship in relationships) {
      final query =
          '''
        SELECT COUNT(*) as count
        FROM ${relationship.targetTable}
        WHERE ${relationship.foreignKey} = ?
      ''';

      final result = await db.rawQuery(query, [recordId]);
      final count = result.first['count'] as int;
      results[relationship.targetTable] = count;
    }

    return results;
  }
}
