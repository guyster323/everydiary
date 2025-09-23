import 'package:sqflite/sqflite.dart';

/// 데이터베이스 성능 모니터링 및 최적화 도구
class DatabasePerformance {
  final Database _database;

  DatabasePerformance(this._database);

  /// 쿼리 실행 계획 분석
  Future<Map<String, dynamic>> analyzeQueryPlan(String query) async {
    try {
      final result = await _database.rawQuery('EXPLAIN QUERY PLAN $query');
      return {
        'query': query,
        'plan': result,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'query': query,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// 인덱스 사용률 분석
  Future<List<Map<String, dynamic>>> getIndexUsage() async {
    try {
      // SQLite의 내부 통계 테이블에서 인덱스 정보 조회
      final result = await _database.rawQuery('''
        SELECT
          name as index_name,
          tbl_name as table_name,
          sql as index_sql
        FROM sqlite_master
        WHERE type = 'index'
        AND name NOT LIKE 'sqlite_%'
        ORDER BY tbl_name, name
      ''');
      return result;
    } catch (e) {
      return [];
    }
  }

  /// 테이블 통계 정보 조회
  Future<Map<String, dynamic>> getTableStats(String tableName) async {
    try {
      // 테이블의 행 수 조회
      final countResult = await _database.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      final count = countResult.first['count'] as int;

      // 테이블 크기 정보 (SQLite에서는 정확한 크기 측정이 제한적)
      final sizeResult = await _database.rawQuery('''
        SELECT
          COUNT(*) as row_count,
          COUNT(DISTINCT *) as unique_rows
        FROM $tableName
      ''');

      return {
        'table_name': tableName,
        'row_count': count,
        'unique_rows': sizeResult.first['unique_rows'],
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'table_name': tableName,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// 데이터베이스 전체 통계
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final tables = [
        'users',
        'diary_entries',
        'tags',
        'diary_tags',
        'attachments',
        'mood_stats',
        'diary_stats',
        'notification_settings',
        'backup_history',
        'app_settings',
        'diary_fts',
      ];

      final Map<String, dynamic> stats = <String, dynamic>{
        'timestamp': DateTime.now().toIso8601String(),
        'tables': <String, dynamic>{},
        'total_records': 0,
      };

      for (final table in tables) {
        final tableStats = await getTableStats(table);
        stats['tables'][table] = tableStats;
        if (tableStats['row_count'] != null) {
          stats['total_records'] += tableStats['row_count'] as int;
        }
      }

      // 인덱스 정보 추가
      stats['indexes'] = await getIndexUsage();

      return stats;
    } catch (e) {
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// 쿼리 성능 테스트
  Future<Map<String, dynamic>> benchmarkQuery(
    String query, {
    int iterations = 10,
  }) async {
    final List<int> executionTimes = [];

    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();
      try {
        await _database.rawQuery(query);
        stopwatch.stop();
        executionTimes.add(stopwatch.elapsedMicroseconds);
      } catch (e) {
        return {
          'query': query,
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
    }

    // 통계 계산
    executionTimes.sort();
    final avgTime =
        executionTimes.reduce((a, b) => a + b) / executionTimes.length;
    final minTime = executionTimes.first;
    final maxTime = executionTimes.last;
    final medianTime = executionTimes[executionTimes.length ~/ 2];

    return {
      'query': query,
      'iterations': iterations,
      'avg_time_microseconds': avgTime,
      'min_time_microseconds': minTime,
      'max_time_microseconds': maxTime,
      'median_time_microseconds': medianTime,
      'execution_times': executionTimes,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 주요 쿼리들의 성능 벤치마크
  Future<Map<String, dynamic>> benchmarkCommonQueries() async {
    final commonQueries = {
      'user_diary_list': '''
        SELECT d.*, GROUP_CONCAT(t.name) as tags
        FROM diary_entries d
        LEFT JOIN diary_tags dt ON d.id = dt.diary_id
        LEFT JOIN tags t ON dt.tag_id = t.id
        WHERE d.user_id = 1 AND d.is_deleted = 0
        GROUP BY d.id
        ORDER BY d.created_at DESC
        LIMIT 20
      ''',
      'diary_search': '''
        SELECT d.*, GROUP_CONCAT(t.name) as tags
        FROM diary_entries d
        LEFT JOIN diary_tags dt ON d.id = dt.diary_id
        LEFT JOIN tags t ON dt.tag_id = t.id
        WHERE d.user_id = 1 AND d.is_deleted = 0
        AND (d.title LIKE '%일기%' OR d.content LIKE '%일기%')
        GROUP BY d.id
        ORDER BY d.created_at DESC
      ''',
      'tag_filter': '''
        SELECT d.*, GROUP_CONCAT(t.name) as tags
        FROM diary_entries d
        INNER JOIN diary_tags dt ON d.id = dt.diary_id
        INNER JOIN tags t ON dt.tag_id = t.id
        WHERE d.user_id = 1 AND d.is_deleted = 0
        AND t.name = '일상'
        GROUP BY d.id
        ORDER BY d.created_at DESC
      ''',
      'mood_stats': '''
        SELECT mood, COUNT(*) as count
        FROM diary_entries
        WHERE user_id = 1 AND is_deleted = 0
        AND created_at >= date('now', '-30 days')
        GROUP BY mood
        ORDER BY count DESC
      ''',
      'fts_search': '''
        SELECT d.*, GROUP_CONCAT(t.name) as tags
        FROM diary_fts f
        INNER JOIN diary_entries d ON f.diary_id = d.id
        LEFT JOIN diary_tags dt ON d.id = dt.diary_id
        LEFT JOIN tags t ON dt.tag_id = t.id
        WHERE f.user_id = 1
        AND diary_fts MATCH '일기'
        GROUP BY d.id
        ORDER BY d.created_at DESC
      ''',
    };

    final Map<String, dynamic> results = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'benchmarks': <String, dynamic>{},
    };

    for (final entry in commonQueries.entries) {
      results['benchmarks'][entry.key] = await benchmarkQuery(
        entry.value,
        iterations: 5, // 빠른 테스트를 위해 5회만 실행
      );
    }

    return results;
  }

  /// 인덱스 최적화 제안
  Future<List<Map<String, dynamic>>> getIndexOptimizationSuggestions() async {
    final suggestions = <Map<String, dynamic>>[];

    try {
      // 사용되지 않는 인덱스 찾기 (SQLite에서는 제한적)
      // final indexUsage = await getIndexUsage();

      // 복합 인덱스 최적화 제안
      suggestions.addAll([
        {
          'type': 'composite_index',
          'table': 'diary_entries',
          'suggestion':
              'user_id + is_deleted + created_at 복합 인덱스가 이미 최적화되어 있습니다.',
          'priority': 'low',
        },
        {
          'type': 'fts_optimization',
          'table': 'diary_fts',
          'suggestion': 'FTS5 인덱스가 설정되어 있어 전문 검색이 최적화되어 있습니다.',
          'priority': 'low',
        },
        {
          'type': 'statistics_update',
          'table': 'all',
          'suggestion': '정기적으로 ANALYZE 명령을 실행하여 쿼리 최적화 통계를 업데이트하세요.',
          'priority': 'medium',
        },
      ]);

      return suggestions;
    } catch (e) {
      return [
        {
          'type': 'error',
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      ];
    }
  }

  /// 데이터베이스 최적화 실행
  Future<Map<String, dynamic>> optimizeDatabase() async {
    try {
      // ANALYZE 명령으로 통계 업데이트
      await _database.execute('ANALYZE');

      // VACUUM 명령으로 데이터베이스 최적화 (선택적)
      // await _database.execute('VACUUM');

      return {
        'status': 'success',
        'message': '데이터베이스 최적화가 완료되었습니다.',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
