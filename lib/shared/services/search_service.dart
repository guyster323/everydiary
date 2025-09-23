import 'package:sqflite/sqflite.dart';

/// 전문 검색 서비스
/// FTS5를 활용한 일기 내용 검색 기능
class SearchService {
  final Database _database;

  SearchService(this._database);

  /// 전문 검색 실행
  ///
  /// [query] 검색어
  /// [userId] 사용자 ID
  /// [limit] 결과 제한 수
  /// [offset] 결과 오프셋
  /// [includeDeleted] 삭제된 일기 포함 여부
  Future<List<Map<String, dynamic>>> searchDiaries({
    required String query,
    required int userId,
    int limit = 20,
    int offset = 0,
    bool includeDeleted = false,
  }) async {
    try {
      // FTS 검색 쿼리 구성
      final ftsQuery = _buildFtsQuery(query);

      final String sql =
          '''
        SELECT
          d.id,
          d.user_id,
          d.title,
          d.content,
          d.mood,
          d.weather,
          d.location,
          d.is_private,
          d.is_favorite,
          d.word_count,
          d.reading_time,
          d.created_at,
          d.updated_at,
          GROUP_CONCAT(t.name) as tags,
          GROUP_CONCAT(t.color) as tag_colors,
          snippet(diary_fts, 1, '<mark>', '</mark>', '...', 32) as title_snippet,
          snippet(diary_fts, 2, '<mark>', '</mark>', '...', 64) as content_snippet
        FROM diary_fts f
        INNER JOIN diary_entries d ON f.diary_id = d.id
        LEFT JOIN diary_tags dt ON d.id = dt.diary_id
        LEFT JOIN tags t ON dt.tag_id = t.id
        WHERE f.user_id = ?
        AND diary_fts MATCH ?
        ${includeDeleted ? '' : 'AND d.is_deleted = 0'}
        GROUP BY d.id
        ORDER BY rank
        LIMIT ? OFFSET ?
      ''';

      final result = await _database.rawQuery(sql, [
        userId,
        ftsQuery,
        limit,
        offset,
      ]);

      return result;
    } catch (e) {
      throw Exception('검색 중 오류가 발생했습니다: $e');
    }
  }

  /// 태그와 함께 검색
  Future<List<Map<String, dynamic>>> searchWithTags({
    required String query,
    required int userId,
    List<String>? tags,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final ftsQuery = _buildFtsQuery(query);

      final String sql =
          '''
        SELECT
          d.id,
          d.user_id,
          d.title,
          d.content,
          d.mood,
          d.weather,
          d.location,
          d.is_private,
          d.is_favorite,
          d.word_count,
          d.reading_time,
          d.created_at,
          d.updated_at,
          GROUP_CONCAT(t.name) as tags,
          GROUP_CONCAT(t.color) as tag_colors,
          snippet(diary_fts, 1, '<mark>', '</mark>', '...', 32) as title_snippet,
          snippet(diary_fts, 2, '<mark>', '</mark>', '...', 64) as content_snippet
        FROM diary_fts f
        INNER JOIN diary_entries d ON f.diary_id = d.id
        LEFT JOIN diary_tags dt ON d.id = dt.diary_id
        LEFT JOIN tags t ON dt.tag_id = t.id
        WHERE f.user_id = ?
        AND diary_fts MATCH ?
        AND d.is_deleted = 0
        ${tags != null && tags.isNotEmpty ? 'AND t.name IN (${tags.map((_) => '?').join(',')})' : ''}
        GROUP BY d.id
        HAVING COUNT(DISTINCT t.name) ${tags != null && tags.isNotEmpty ? '>= ?' : '>= 0'}
        ORDER BY rank
        LIMIT ? OFFSET ?
      ''';

      final params = [userId, ftsQuery];
      if (tags != null && tags.isNotEmpty) {
        params.addAll(tags);
        params.add(tags.length);
      }
      params.addAll([limit, offset]);

      final result = await _database.rawQuery(sql, params);
      return result;
    } catch (e) {
      throw Exception('태그 검색 중 오류가 발생했습니다: $e');
    }
  }

  /// 날짜 범위와 함께 검색
  Future<List<Map<String, dynamic>>> searchWithDateRange({
    required String query,
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final ftsQuery = _buildFtsQuery(query);

      final String sql =
          '''
        SELECT
          d.id,
          d.user_id,
          d.title,
          d.content,
          d.mood,
          d.weather,
          d.location,
          d.is_private,
          d.is_favorite,
          d.word_count,
          d.reading_time,
          d.created_at,
          d.updated_at,
          GROUP_CONCAT(t.name) as tags,
          GROUP_CONCAT(t.color) as tag_colors,
          snippet(diary_fts, 1, '<mark>', '</mark>', '...', 32) as title_snippet,
          snippet(diary_fts, 2, '<mark>', '</mark>', '...', 64) as content_snippet
        FROM diary_fts f
        INNER JOIN diary_entries d ON f.diary_id = d.id
        LEFT JOIN diary_tags dt ON d.id = dt.diary_id
        LEFT JOIN tags t ON dt.tag_id = t.id
        WHERE f.user_id = ?
        AND diary_fts MATCH ?
        AND d.is_deleted = 0
        ${startDate != null ? 'AND d.created_at >= ?' : ''}
        ${endDate != null ? 'AND d.created_at <= ?' : ''}
        GROUP BY d.id
        ORDER BY rank
        LIMIT ? OFFSET ?
      ''';

      final params = [userId, ftsQuery];
      if (startDate != null) {
        params.add(startDate.toIso8601String());
      }
      if (endDate != null) {
        params.add(endDate.toIso8601String());
      }
      params.addAll([limit, offset]);

      final result = await _database.rawQuery(sql, params);
      return result;
    } catch (e) {
      throw Exception('날짜 범위 검색 중 오류가 발생했습니다: $e');
    }
  }

  /// 검색어 자동완성
  Future<List<String>> getSearchSuggestions({
    required String partialQuery,
    required int userId,
    int limit = 10,
  }) async {
    try {
      // FTS 테이블에서 검색어와 유사한 단어들을 찾기
      const sql = '''
        SELECT DISTINCT term
        FROM diary_fts
        WHERE user_id = ?
        AND term MATCH ?
        ORDER BY term
        LIMIT ?
      ''';

      final result = await _database.rawQuery(sql, [
        userId,
        '$partialQuery*',
        limit,
      ]);

      return result.map((row) => row['term'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  /// 인기 검색어 조회
  Future<List<Map<String, dynamic>>> getPopularSearchTerms({
    required int userId,
    int limit = 10,
  }) async {
    try {
      // 실제 구현에서는 검색 기록을 별도 테이블에 저장해야 함
      // 여기서는 일기 내용에서 자주 나타나는 단어들을 기반으로 추천
      const sql = '''
        SELECT
          term,
          COUNT(*) as frequency
        FROM diary_fts
        WHERE user_id = ?
        AND length(term) > 2
        GROUP BY term
        ORDER BY frequency DESC
        LIMIT ?
      ''';

      final result = await _database.rawQuery(sql, [userId, limit]);
      return result;
    } catch (e) {
      return [];
    }
  }

  /// 검색 통계 조회
  Future<Map<String, dynamic>> getSearchStats({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final String sql =
          '''
        SELECT
          COUNT(DISTINCT d.id) as total_diaries,
          COUNT(DISTINCT t.id) as total_tags,
          AVG(d.word_count) as avg_word_count,
          SUM(d.word_count) as total_words
        FROM diary_entries d
        LEFT JOIN diary_tags dt ON d.id = dt.diary_id
        LEFT JOIN tags t ON dt.tag_id = t.id
        WHERE d.user_id = ?
        AND d.is_deleted = 0
        ${startDate != null ? 'AND d.created_at >= ?' : ''}
        ${endDate != null ? 'AND d.created_at <= ?' : ''}
      ''';

      final params = <Object>[userId];
      if (startDate != null) {
        params.add(startDate.toIso8601String());
      }
      if (endDate != null) {
        params.add(endDate.toIso8601String());
      }

      final result = await _database.rawQuery(sql, params);
      final stats = result.first;

      return {
        'total_diaries': stats['total_diaries'] ?? 0,
        'total_tags': stats['total_tags'] ?? 0,
        'avg_word_count': stats['avg_word_count'] ?? 0.0,
        'total_words': stats['total_words'] ?? 0,
        'searchable_content': 'FTS5 인덱스로 최적화됨',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// FTS 쿼리 구문 생성
  String _buildFtsQuery(String query) {
    // 특수 문자 이스케이프
    final escapedQuery = query
        .replaceAll("'", "''")
        .replaceAll('"', '""')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('+', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('{', '')
        .replaceAll('}', '')
        .replaceAll('^', '')
        .replaceAll(r'$', '')
        .replaceAll(r'\', '')
        .replaceAll('|', '')
        .replaceAll('&', '')
        .replaceAll('~', '')
        .replaceAll('!', '');

    // 공백으로 분리된 단어들을 AND 조건으로 연결
    final words = escapedQuery
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => '"$word"*')
        .join(' AND ');

    return words.isEmpty ? '*' : words;
  }

  /// 검색 결과 하이라이팅 제거
  String removeHighlighting(String text) {
    return text.replaceAll('<mark>', '').replaceAll('</mark>', '');
  }

  /// 검색 결과 요약 생성
  String generateSummary(String content, int maxLength) {
    if (content.length <= maxLength) {
      return content;
    }

    // 문장 단위로 자르기
    final sentences = content.split(RegExp(r'[.!?]'));
    final summary = <String>[];
    int currentLength = 0;

    for (final sentence in sentences) {
      if (currentLength + sentence.length > maxLength) {
        break;
      }
      summary.add(sentence.trim());
      currentLength += sentence.length;
    }

    return summary.join('. ') + (summary.isNotEmpty ? '...' : '');
  }
}
