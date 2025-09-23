/// 데이터베이스 관계 및 외래키 설정
/// Everydiary 앱의 테이블 간 관계를 정의하고 관리
class DatabaseRelationships {

  /// 테이블 관계 정의
  static const Map<String, List<TableRelationship>> relationships = {
    'users': [
      TableRelationship(
        targetTable: 'diary_entries',
        foreignKey: 'user_id',
        onDelete: CascadeAction.cascade,
        onUpdate: CascadeAction.cascade,
        description: '사용자가 삭제되면 해당 사용자의 모든 일기도 삭제',
      ),
      TableRelationship(
        targetTable: 'tags',
        foreignKey: 'user_id',
        onDelete: CascadeAction.cascade,
        onUpdate: CascadeAction.cascade,
        description: '사용자가 삭제되면 해당 사용자의 모든 태그도 삭제',
      ),
      TableRelationship(
        targetTable: 'mood_stats',
        foreignKey: 'user_id',
        onDelete: CascadeAction.cascade,
        onUpdate: CascadeAction.cascade,
        description: '사용자가 삭제되면 해당 사용자의 모든 기분 통계도 삭제',
      ),
      TableRelationship(
        targetTable: 'diary_stats',
        foreignKey: 'user_id',
        onDelete: CascadeAction.cascade,
        onUpdate: CascadeAction.cascade,
        description: '사용자가 삭제되면 해당 사용자의 모든 일기 통계도 삭제',
      ),
      TableRelationship(
        targetTable: 'notification_settings',
        foreignKey: 'user_id',
        onDelete: CascadeAction.cascade,
        onUpdate: CascadeAction.cascade,
        description: '사용자가 삭제되면 해당 사용자의 모든 알림 설정도 삭제',
      ),
      TableRelationship(
        targetTable: 'backup_history',
        foreignKey: 'user_id',
        onDelete: CascadeAction.cascade,
        onUpdate: CascadeAction.cascade,
        description: '사용자가 삭제되면 해당 사용자의 모든 백업 기록도 삭제',
      ),
    ],
    'diary_entries': [
      TableRelationship(
        targetTable: 'diary_tags',
        foreignKey: 'diary_id',
        onDelete: CascadeAction.cascade,
        onUpdate: CascadeAction.cascade,
        description: '일기가 삭제되면 해당 일기의 모든 태그 관계도 삭제',
      ),
      TableRelationship(
        targetTable: 'attachments',
        foreignKey: 'diary_id',
        onDelete: CascadeAction.cascade,
        onUpdate: CascadeAction.cascade,
        description: '일기가 삭제되면 해당 일기의 모든 첨부파일도 삭제',
      ),
    ],
    'tags': [
      TableRelationship(
        targetTable: 'diary_tags',
        foreignKey: 'tag_id',
        onDelete: CascadeAction.cascade,
        onUpdate: CascadeAction.cascade,
        description: '태그가 삭제되면 해당 태그의 모든 일기 관계도 삭제',
      ),
    ],
  };

  /// 관계 무결성 검증 쿼리
  static const List<String> integrityCheckQueries = [
    // 사용자-일기 관계 검증
    '''
    SELECT COUNT(*) as orphaned_diaries
    FROM diary_entries d
    LEFT JOIN users u ON d.user_id = u.id
    WHERE u.id IS NULL AND d.is_deleted = 0
    ''',

    // 사용자-태그 관계 검증
    '''
    SELECT COUNT(*) as orphaned_tags
    FROM tags t
    LEFT JOIN users u ON t.user_id = u.id
    WHERE u.id IS NULL AND t.is_deleted = 0
    ''',

    // 일기-태그 관계 검증
    '''
    SELECT COUNT(*) as orphaned_diary_tags
    FROM diary_tags dt
    LEFT JOIN diary_entries d ON dt.diary_id = d.id
    LEFT JOIN tags t ON dt.tag_id = t.id
    WHERE d.id IS NULL OR t.id IS NULL
    ''',

    // 일기-첨부파일 관계 검증
    '''
    SELECT COUNT(*) as orphaned_attachments
    FROM attachments a
    LEFT JOIN diary_entries d ON a.diary_id = d.id
    WHERE d.id IS NULL AND a.is_deleted = 0
    ''',

    // 사용자-통계 관계 검증
    '''
    SELECT COUNT(*) as orphaned_mood_stats
    FROM mood_stats ms
    LEFT JOIN users u ON ms.user_id = u.id
    WHERE u.id IS NULL
    ''',

    '''
    SELECT COUNT(*) as orphaned_diary_stats
    FROM diary_stats ds
    LEFT JOIN users u ON ds.user_id = u.id
    WHERE u.id IS NULL
    ''',
  ];

  /// 관계 정리 쿼리 (고아 레코드 삭제)
  static const List<String> cleanupQueries = [
    // 고아 일기 삭제
    '''
    DELETE FROM diary_entries
    WHERE user_id NOT IN (SELECT id FROM users WHERE is_deleted = 0)
    ''',

    // 고아 태그 삭제
    '''
    DELETE FROM tags
    WHERE user_id NOT IN (SELECT id FROM users WHERE is_deleted = 0)
    ''',

    // 고아 일기-태그 관계 삭제
    '''
    DELETE FROM diary_tags
    WHERE diary_id NOT IN (SELECT id FROM diary_entries WHERE is_deleted = 0)
    OR tag_id NOT IN (SELECT id FROM tags WHERE is_deleted = 0)
    ''',

    // 고아 첨부파일 삭제
    '''
    DELETE FROM attachments
    WHERE diary_id NOT IN (SELECT id FROM diary_entries WHERE is_deleted = 0)
    ''',

    // 고아 통계 삭제
    '''
    DELETE FROM mood_stats
    WHERE user_id NOT IN (SELECT id FROM users WHERE is_deleted = 0)
    ''',

    '''
    DELETE FROM diary_stats
    WHERE user_id NOT IN (SELECT id FROM users WHERE is_deleted = 0)
    ''',

    // 고아 알림 설정 삭제
    '''
    DELETE FROM notification_settings
    WHERE user_id NOT IN (SELECT id FROM users WHERE is_deleted = 0)
    ''',

    // 고아 백업 기록 삭제
    '''
    DELETE FROM backup_history
    WHERE user_id NOT IN (SELECT id FROM users WHERE is_deleted = 0)
    ''',
  ];

  /// 관계 통계 쿼리
  static const Map<String, String> relationshipStatsQueries = {
    'user_diary_count': '''
      SELECT u.id, u.name, COUNT(d.id) as diary_count
      FROM users u
      LEFT JOIN diary_entries d ON u.id = d.user_id AND d.is_deleted = 0
      WHERE u.is_deleted = 0
      GROUP BY u.id, u.name
    ''',

    'user_tag_count': '''
      SELECT u.id, u.name, COUNT(t.id) as tag_count
      FROM users u
      LEFT JOIN tags t ON u.id = t.user_id AND t.is_deleted = 0
      WHERE u.is_deleted = 0
      GROUP BY u.id, u.name
    ''',

    'diary_tag_usage': '''
      SELECT t.name, COUNT(dt.diary_id) as usage_count
      FROM tags t
      LEFT JOIN diary_tags dt ON t.id = dt.tag_id
      LEFT JOIN diary_entries d ON dt.diary_id = d.id AND d.is_deleted = 0
      WHERE t.is_deleted = 0
      GROUP BY t.id, t.name
      ORDER BY usage_count DESC
    ''',

    'diary_attachment_count': '''
      SELECT d.id, d.title, COUNT(a.id) as attachment_count
      FROM diary_entries d
      LEFT JOIN attachments a ON d.id = a.diary_id AND a.is_deleted = 0
      WHERE d.is_deleted = 0
      GROUP BY d.id, d.title
    ''',
  };

  /// 관계 최적화 쿼리
  static const List<String> optimizationQueries = [
    // 태그 사용량 업데이트
    '''
    UPDATE tags
    SET usage_count = (
      SELECT COUNT(*)
      FROM diary_tags dt
      JOIN diary_entries d ON dt.diary_id = d.id
      WHERE dt.tag_id = tags.id AND d.is_deleted = 0
    )
    ''',

    // 일기 통계 업데이트
    '''
    INSERT OR REPLACE INTO diary_stats (user_id, date, entries_count, total_words, total_reading_time, created_at, updated_at)
    SELECT
      user_id,
      DATE(created_at) as date,
      COUNT(*) as entries_count,
      SUM(word_count) as total_words,
      SUM(reading_time) as total_reading_time,
      datetime('now') as created_at,
      datetime('now') as updated_at
    FROM diary_entries
    WHERE is_deleted = 0
    GROUP BY user_id, DATE(created_at)
    ''',

    // 기분 통계 업데이트
    '''
    INSERT OR REPLACE INTO mood_stats (user_id, mood, date, count, created_at, updated_at)
    SELECT
      user_id,
      mood,
      DATE(created_at) as date,
      COUNT(*) as count,
      datetime('now') as created_at,
      datetime('now') as updated_at
    FROM diary_entries
    WHERE is_deleted = 0 AND mood IS NOT NULL
    GROUP BY user_id, mood, DATE(created_at)
    ''',
  ];
}

/// 테이블 관계 정의 클래스
class TableRelationship {
  final String targetTable;
  final String foreignKey;
  final CascadeAction onDelete;
  final CascadeAction onUpdate;
  final String description;

  const TableRelationship({
    required this.targetTable,
    required this.foreignKey,
    required this.onDelete,
    required this.onUpdate,
    required this.description,
  });
}

/// CASCADE 액션 열거형
enum CascadeAction {
  cascade,
  restrict,
  setNull,
  setDefault,
  noAction,
}

/// CASCADE 액션 확장
extension CascadeActionExtension on CascadeAction {
  String get sqlValue {
    switch (this) {
      case CascadeAction.cascade:
        return 'CASCADE';
      case CascadeAction.restrict:
        return 'RESTRICT';
      case CascadeAction.setNull:
        return 'SET NULL';
      case CascadeAction.setDefault:
        return 'SET DEFAULT';
      case CascadeAction.noAction:
        return 'NO ACTION';
    }
  }
}
