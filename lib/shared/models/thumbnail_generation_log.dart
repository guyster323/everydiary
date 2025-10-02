import 'dart:convert';

class ThumbnailGenerationLog {
  const ThumbnailGenerationLog({
    required this.id,
    required this.diaryId,
    this.jobId,
    required this.engine,
    required this.status,
    this.durationMs,
    this.retryCount,
    this.promptSignature,
    this.negativeHit = false,
    required this.createdAt,
    this.metadata,
  });

  final int id;
  final int diaryId;
  final int? jobId;
  final String engine;
  final String status;
  final int? durationMs;
  final int? retryCount;
  final String? promptSignature;
  final bool negativeHit;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  static ThumbnailGenerationLog fromDb(Map<String, Object?> row) {
    return ThumbnailGenerationLog(
      id: row['id'] as int,
      diaryId: row['diary_id'] as int,
      jobId: row['job_id'] as int?,
      engine: row['engine'] as String,
      status: row['status'] as String,
      durationMs: row['duration_ms'] as int?,
      retryCount: row['retry_count'] as int?,
      promptSignature: row['prompt_signature'] as String?,
      negativeHit: (row['negative_hit'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
      metadata: _decodeJson(row['metadata'] as String?),
    );
  }

  static Map<String, dynamic>? _decodeJson(String? value) {
    if (value == null) {
      return null;
    }
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
