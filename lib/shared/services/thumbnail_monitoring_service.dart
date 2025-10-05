import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/thumbnail_batch_job.dart';
import '../models/thumbnail_generation_log.dart';
import '../models/thumbnail_quality_metric.dart';
import 'database_service.dart';

class ThumbnailMonitoringSummary {
  const ThumbnailMonitoringSummary({
    required this.total,
    required this.succeeded,
    required this.failed,
    required this.started,
    required this.cancelled,
    required this.byStatus,
    required this.byEngine,
  });

  final int total;
  final int succeeded;
  final int failed;
  final int started;
  final int cancelled;
  final Map<String, int> byStatus;
  final Map<String, int> byEngine;
}

class ThumbnailMonitoringService {
  ThumbnailMonitoringService({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  final DatabaseService _databaseService;

  Future<int> logGenerationStart({
    required int diaryId,
    required ThumbnailBatchJobType jobType,
    Map<String, dynamic>? metadata,
  }) {
    return logEvent(
      diaryId: diaryId,
      engine: 'batch:${jobType.name}',
      status: 'started',
      metadata: metadata,
    );
  }

  Future<int> logGenerationSuccess({
    required int diaryId,
    required ThumbnailBatchJob job,
    required Duration duration,
    Map<String, dynamic>? metadata,
  }) {
    return logEvent(
      diaryId: diaryId,
      jobId: job.id,
      engine: 'batch:${job.jobType.name}',
      status: 'succeeded',
      duration: duration,
      retryCount: job.retryCount,
      metadata: metadata,
    );
  }

  Future<int> logGenerationFailure({
    required int diaryId,
    required ThumbnailBatchJob job,
    required Object error,
    Map<String, dynamic>? metadata,
  }) {
    return logEvent(
      diaryId: diaryId,
      jobId: job.id,
      engine: 'batch:${job.jobType.name}',
      status: 'failed',
      retryCount: job.retryCount,
      metadata: {'error': error.toString(), if (metadata != null) ...metadata},
    );
  }

  Future<int> logRegressionQueued({
    required int diaryId,
    required int sampleId,
    String? group,
  }) {
    return logEvent(
      diaryId: diaryId,
      engine: group == null ? 'regression' : 'regression:$group',
      status: 'queued',
      metadata: {
        'sample_id': sampleId,
        if (group != null) 'sample_group': group,
      },
    );
  }

  Future<int> logRegressionResult({
    required int diaryId,
    required int sampleId,
    required bool succeeded,
    Duration? duration,
    String? group,
    Map<String, dynamic>? metadata,
  }) {
    return logEvent(
      diaryId: diaryId,
      engine: group == null ? 'regression' : 'regression:$group',
      status: succeeded ? 'succeeded' : 'failed',
      duration: duration,
      metadata: {
        'sample_id': sampleId,
        if (group != null) 'sample_group': group,
        if (metadata != null) ...metadata,
      },
    );
  }

  Future<int> logEvent({
    required int diaryId,
    required String engine,
    required String status,
    int? jobId,
    Duration? duration,
    int? retryCount,
    bool? negativeHit,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final db = await _databaseService.database;
      return await db.insert('thumbnail_generation_logs', {
        'diary_id': diaryId,
        'job_id': jobId,
        'engine': engine,
        'status': status,
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
      return -1;
    }
  }

  Future<int> recordMetric({
    required int logId,
    required String metricType,
    double? value,
    Map<String, dynamic>? details,
  }) async {
    final db = await _databaseService.database;
    return db.insert('thumbnail_quality_metrics', {
      'log_id': logId,
      'metric_type': metricType,
      'value': value,
      'details': details == null ? null : jsonEncode(details),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<ThumbnailGenerationLog>> fetchRecentLogs({
    int limit = 50,
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

    final rows = await db.query(
      'thumbnail_generation_logs',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map(ThumbnailGenerationLog.fromDb).toList();
  }

  Future<List<ThumbnailGenerationLog>> fetchRecentFailures({
    int limit = 20,
    String? engine,
  }) {
    return fetchRecentLogs(limit: limit, engine: engine, status: 'failed');
  }

  Future<List<ThumbnailQualityMetric>> fetchMetricsForLog(int logId) async {
    final db = await _databaseService.database;
    final rows = await db.query(
      'thumbnail_quality_metrics',
      where: 'log_id = ?',
      whereArgs: [logId],
      orderBy: 'created_at DESC',
    );
    return rows.map(ThumbnailQualityMetric.fromDb).toList();
  }

  Future<ThumbnailMonitoringSummary> fetchSummary({
    DateTime? since,
    DateTime? until,
  }) async {
    final db = await _databaseService.database;
    final where = <String>[];
    final args = <Object?>[];

    if (since != null) {
      where.add('created_at >= ?');
      args.add(since.toIso8601String());
    }
    if (until != null) {
      where.add('created_at <= ?');
      args.add(until.toIso8601String());
    }

    final whereClause = where.isEmpty ? null : where.join(' AND ');

    final statusRows = await db.query(
      'thumbnail_generation_logs',
      columns: ['status', 'COUNT(*) as count'],
      where: whereClause,
      whereArgs: args,
      groupBy: 'status',
    );

    final engineRows = await db.query(
      'thumbnail_generation_logs',
      columns: ['engine', 'COUNT(*) as count'],
      where: whereClause,
      whereArgs: args,
      groupBy: 'engine',
    );

    final totalRow = await db.rawQuery(
      '''SELECT COUNT(*) as count FROM thumbnail_generation_logs
         ${whereClause == null ? '' : 'WHERE $whereClause'}''',
      args,
    );

    final byStatus = <String, int>{
      for (final row in statusRows)
        row['status'] as String: (row['count'] as int?) ?? 0,
    };

    final byEngine = <String, int>{
      for (final row in engineRows)
        row['engine'] as String: (row['count'] as int?) ?? 0,
    };

    final total = (totalRow.first['count'] as int?) ?? 0;

    return ThumbnailMonitoringSummary(
      total: total,
      succeeded: byStatus['succeeded'] ?? 0,
      failed: byStatus['failed'] ?? 0,
      started: byStatus['started'] ?? 0,
      cancelled: byStatus['cancelled'] ?? 0,
      byStatus: byStatus,
      byEngine: byEngine,
    );
  }

  Future<void> cleanup({required Duration olderThan}) async {
    final threshold = DateTime.now().subtract(olderThan).toIso8601String();
    final db = await _databaseService.database;
    await db.delete(
      'thumbnail_generation_logs',
      where: 'created_at < ?',
      whereArgs: [threshold],
    );
    await db.delete(
      'thumbnail_quality_metrics',
      where: 'created_at < ?',
      whereArgs: [threshold],
    );
  }
}
