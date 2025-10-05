class RegressionSample {
  const RegressionSample({
    required this.id,
    required this.diaryId,
    this.sampleGroup,
    this.priority = 0,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int diaryId;
  final String? sampleGroup;
  final int priority;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory RegressionSample.fromDb(Map<String, Object?> row) {
    return RegressionSample(
      id: row['id'] as int,
      diaryId: row['diary_id'] as int,
      sampleGroup: row['sample_group'] as String?,
      priority: (row['priority'] as int?) ?? 0,
      notes: row['notes'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  Map<String, Object?> toDbMap() {
    return {
      'id': id,
      'diary_id': diaryId,
      'sample_group': sampleGroup,
      'priority': priority,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  RegressionSample copyWith({
    int? id,
    int? diaryId,
    String? sampleGroup,
    int? priority,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RegressionSample(
      id: id ?? this.id,
      diaryId: diaryId ?? this.diaryId,
      sampleGroup: sampleGroup ?? this.sampleGroup,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
