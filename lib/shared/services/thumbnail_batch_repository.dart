import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../models/thumbnail_batch_job.dart';
import 'database_service.dart';

/// 썸네일 배치 작업을 SQLite에 저장/조회하는 리포지토리.
class ThumbnailBatchRepository {
  ThumbnailBatchRepository({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  final DatabaseService _databaseService;

  Future<Database> get _db async => _databaseService.database;

  Future<int> enqueue(ThumbnailBatchJob job) async {
    final db = await _db;
    final now = DateTime.now();
    final data = job.copyWith(
      createdAt: job.createdAt ?? now,
      updatedAt: job.updatedAt ?? now,
    );
    return db.insert('thumbnail_jobs', _toDbMap(data));
  }

  Future<int> enqueueOrUpdateExisting({
    required int diaryId,
    ThumbnailBatchJobType jobType = ThumbnailBatchJobType.regenerate,
    Duration delay = Duration.zero,
    Map<String, dynamic>? payload,
  }) async {
    final existing = await findPendingJobForDiary(diaryId, jobType: jobType);
    final scheduledAt = DateTime.now().add(delay);

    if (existing != null) {
      return updateJob(
        existing.copyWith(
          scheduledAt: scheduledAt,
          payload: payload ?? existing.payload,
          status: ThumbnailBatchJobStatus.pending,
          retryCount: 0,
          lastError: null,
        ),
      );
    }

    return enqueue(
      ThumbnailBatchJob(
        diaryId: diaryId,
        jobType: jobType,
        status: ThumbnailBatchJobStatus.pending,
        scheduledAt: scheduledAt,
        payload: payload,
      ),
    );
  }

  Future<List<ThumbnailBatchJob>> dequeuePendingJobs({int limit = 3}) async {
    final db = await _db;
    final nowIso = DateTime.now().toIso8601String();

    final rows = await db.query(
      'thumbnail_jobs',
      where:
          'status = ? AND is_deleted = 0 AND scheduled_at <= ? AND retry_count < ?',
      whereArgs: [
        ThumbnailBatchJobStatus.pending.value,
        nowIso,
        _maxRetryCount,
      ],
      orderBy: 'scheduled_at ASC, id ASC',
      limit: limit,
    );

    final jobs = rows.map(_fromDbMap).toList();

    if (jobs.isNotEmpty) {
      final ids = jobs.map((e) => e.id).nonNulls.toList();
      if (ids.isNotEmpty) {
        final placeholders = List.filled(ids.length, '?').join(',');
        await db.update(
          'thumbnail_jobs',
          {
            'status': ThumbnailBatchJobStatus.processing.value,
            'started_at': nowIso,
            'updated_at': nowIso,
          },
          where: 'id IN ($placeholders)',
          whereArgs: ids,
        );
      }
    }

    return jobs;
  }

  Future<void> markSucceeded(ThumbnailBatchJob job) async {
    await _updateStatus(
      job,
      status: ThumbnailBatchJobStatus.succeeded,
      completedAt: DateTime.now(),
    );
  }

  Future<void> markFailed(ThumbnailBatchJob job, Object error) async {
    final now = DateTime.now();
    final nextRetry = now.add(_nextBackoff(job.retryCount));

    final db = await _db;
    await db.update(
      'thumbnail_jobs',
      {
        'status': ThumbnailBatchJobStatus.pending.value,
        'retry_count': job.retryCount + 1,
        'last_error': error.toString(),
        'scheduled_at': nextRetry.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [job.id],
    );
  }

  Future<void> markCancelled(int jobId) async {
    final db = await _db;
    final nowIso = DateTime.now().toIso8601String();
    await db.update(
      'thumbnail_jobs',
      {'status': ThumbnailBatchJobStatus.cancelled.value, 'updated_at': nowIso},
      where: 'id = ?',
      whereArgs: [jobId],
    );
  }

  Future<List<ThumbnailBatchJob>> getJobs({
    ThumbnailBatchJobStatus? status,
    int? limit,
  }) async {
    final db = await _db;
    final where = <String>[];
    final args = <Object?>[];

    where.add('is_deleted = 0');

    if (status != null) {
      where.add('status = ?');
      args.add(status.value);
    }

    final rows = await db.query(
      'thumbnail_jobs',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'scheduled_at DESC',
      limit: limit,
    );

    return rows.map(_fromDbMap).toList();
  }

  Future<void> cleanupCompleted({
    Duration retention = const Duration(days: 7),
  }) async {
    final db = await _db;
    final threshold = DateTime.now().subtract(retention).toIso8601String();
    await db.delete(
      'thumbnail_jobs',
      where: 'is_deleted = 0 AND completed_at IS NOT NULL AND completed_at < ?',
      whereArgs: [threshold],
    );
  }

  Future<int?> findPendingJobIdByDiary(int diaryId) async {
    final job = await findPendingJobForDiary(diaryId);
    return job?.id;
  }

  Future<ThumbnailBatchJob?> findPendingJobForDiary(
    int diaryId, {
    ThumbnailBatchJobType jobType = ThumbnailBatchJobType.regenerate,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'thumbnail_jobs',
      where:
          'diary_id = ? AND job_type = ? AND status IN (?, ?) AND is_deleted = 0',
      whereArgs: [
        diaryId,
        jobType.value,
        ThumbnailBatchJobStatus.pending.value,
        ThumbnailBatchJobStatus.processing.value,
      ],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }
    return _fromDbMap(rows.first);
  }

  Future<int> updateJob(ThumbnailBatchJob job) async {
    final db = await _db;
    final now = DateTime.now();
    final map = _toDbMap(job.copyWith(updatedAt: now));
    return db.update(
      'thumbnail_jobs',
      map,
      where: 'id = ?',
      whereArgs: [job.id],
    );
  }

  Future<void> markDeleted(int jobId) async {
    final db = await _db;
    final nowIso = DateTime.now().toIso8601String();
    await db.update(
      'thumbnail_jobs',
      {'is_deleted': 1, 'updated_at': nowIso},
      where: 'id = ?',
      whereArgs: [jobId],
    );
  }

  ThumbnailBatchJob _fromDbMap(Map<String, Object?> map) {
    return ThumbnailBatchJob(
      id: map['id'] as int?,
      diaryId: map['diary_id'] as int,
      jobType: ThumbnailBatchJobTypeX.fromValue(
        map['job_type'] as String? ?? 'regenerate',
      ),
      status: ThumbnailBatchJobStatusX.fromValue(
        map['status'] as String? ?? 'pending',
      ),
      payload: _decodeJson(map['payload'] as String?),
      retryCount: (map['retry_count'] as int?) ?? 0,
      lastError: map['last_error'] as String?,
      scheduledAt: DateTime.parse(map['scheduled_at'] as String),
      startedAt: _parseNullableDate(map['started_at']),
      completedAt: _parseNullableDate(map['completed_at']),
      createdAt: _parseNullableDate(map['created_at']) ?? DateTime.now(),
      updatedAt: _parseNullableDate(map['updated_at']) ?? DateTime.now(),
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
    );
  }

  Map<String, Object?> _toDbMap(ThumbnailBatchJob job) {
    final now = DateTime.now();
    final created = job.createdAt ?? now;
    final updated = job.updatedAt ?? now;

    return {
      'id': job.id,
      'diary_id': job.diaryId,
      'job_type': job.jobType.value,
      'status': job.status.value,
      'payload': job.payload == null ? null : jsonEncode(job.payload),
      'retry_count': job.retryCount,
      'last_error': job.lastError,
      'scheduled_at': job.scheduledAt.toIso8601String(),
      'started_at': job.startedAt?.toIso8601String(),
      'completed_at': job.completedAt?.toIso8601String(),
      'created_at': created.toIso8601String(),
      'updated_at': updated.toIso8601String(),
      'is_deleted': job.isDeleted ? 1 : 0,
    }..removeWhere((_, value) => value == null);
  }

  Future<void> _updateStatus(
    ThumbnailBatchJob job, {
    required ThumbnailBatchJobStatus status,
    DateTime? completedAt,
  }) async {
    final db = await _db;
    final nowIso = DateTime.now().toIso8601String();
    await db.update(
      'thumbnail_jobs',
      {
        'status': status.value,
        'completed_at': completedAt?.toIso8601String(),
        'updated_at': nowIso,
      },
      where: 'id = ?',
      whereArgs: [job.id],
    );
  }

  Duration _nextBackoff(int retryCount) {
    final multiplier = 1 << retryCount;
    final seconds = multiplier * 30;
    return Duration(seconds: seconds.clamp(30, 3600));
  }

  DateTime? _parseNullableDate(Object? value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic>? _decodeJson(String? value) {
    if (value == null) {
      return null;
    }
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static const int _maxRetryCount = 5;
}

extension ThumbnailBatchJobTypeX on ThumbnailBatchJobType {
  static ThumbnailBatchJobType fromValue(String value) {
    return ThumbnailBatchJobType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ThumbnailBatchJobType.regenerate,
    );
  }
}

extension ThumbnailBatchJobStatusX on ThumbnailBatchJobStatus {
  static ThumbnailBatchJobStatus fromValue(String value) {
    return ThumbnailBatchJobStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ThumbnailBatchJobStatus.pending,
    );
  }
}
