import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/thumbnail_batch_job.dart';
import '../models/thumbnail_generation_log.dart';
import 'database_service.dart';

class ThumbnailMonitoringService {
  ThumbnailMonitoringService({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  final DatabaseService _databaseService;

  Future<void> logGenerationStart({
    required int diaryId,
    required ThumbnailBatchJobType jobType,
    Map<String, dynamic>? metadata,
  }) async {
    await _insertLog(
      diaryId: diaryId,
      engine: jobType.name,
      status: 'started',
      metadata: metadata,
    );
  }

  Future<void> logGenerationSuccess({
    required int diaryId,
    required ThumbnailBatchJob job,
    required Duration duration,
    Map<String, dynamic>? metadata,
  }) async {
    await _insertLog(
      diaryId: diaryId,
      jobId: job.id,
      engine: job.jobType.name,
      status: 'succeeded',
      duration: duration,
      retryCount: job.retryCount,
      metadata: metadata,
    );
  }

  Future<void> logGenerationFailure({
    required int diaryId,
    required ThumbnailBatchJob job,
    required Object error,
    Map<String, dynamic>? metadata,
  }) async {
    await _insertLog(
      diaryId: diaryId,
      jobId: job.id,
      engine: job.jobType.name,
      status: 'failed',
      retryCount: job.retryCount,
      metadata: {'error': error.toString(), if (metadata != null) ...metadata},
    );
  }

  Future<void> recordMetric({
    required int logId,
    required String metricType,
    double? value,
    Map<String, dynamic>? details,
  }) async {
    final db = await _databaseService.database;
    await db.insert('thumbnail_quality_metrics', {
      'log_id': logId,
      'metric_type': metricType,
      'value': value,
      'details': details == null ? null : jsonEncode(details),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<ThumbnailGenerationLog>> fetchRecentLogs({int limit = 50}) async {
    final db = await _databaseService.database;
    final rows = await db.query(
      'thumbnail_generation_logs',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map(ThumbnailGenerationLog.fromDb).toList();
  }

  Future<Map<String, dynamic>> fetchSummary({
    String? engine,
    String? status,
  }) async {
    final db = await _databaseService.database;
    final where = <String>[];
    final args = <Object?>[];

    if (engine != null) {
      where.add('engine = ?');
      args.add(engine);
    }
    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }

    final logs = await db.query(
      'thumbnail_generation_logs',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      columns: ['status', 'COUNT(*) as count'],
      groupBy: 'status',
    );

    return {
      for (final row in logs) row['status'] as String: row['count'] as int,
    };
  }

  Future<void> _insertLog({
    required int diaryId,
    String? engine,
    String? status,
    int? jobId,
    Duration? duration,
    int? retryCount,
    bool? negativeHit,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final db = await _databaseService.database;
      await db.insert('thumbnail_generation_logs', {
        'diary_id': diaryId,
        'job_id': jobId,
        'engine': engine ?? 'unknown',
        'status': status ?? 'unknown',
        'duration_ms': duration?.inMilliseconds,
        'retry_count': retryCount,
        'negative_hit': negativeHit == true ? 1 : 0,
        'prompt_signature': metadata?['prompt_signature'] as String?,
        'created_at': DateTime.now().toIso8601String(),
        'metadata': metadata == null ? null : jsonEncode(metadata),
      });
    } catch (error, stackTrace) {
      debugPrint('ThumbnailMonitoringService: 로그 기록 실패 - $error');
      debugPrint('$stackTrace');
    }
  }
}
