import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/services/image_generation_service.dart';
import '../models/diary_entry.dart';
import '../models/thumbnail_batch_job.dart';
import 'database_service.dart';
import 'diary_image_helper.dart';
import 'repositories/diary_repository.dart';
import 'thumbnail_batch_repository.dart';
import 'thumbnail_monitoring_service.dart';

class ThumbnailBatchService {
  factory ThumbnailBatchService({
    ThumbnailBatchRepository? repository,
    DiaryRepository? diaryRepository,
    DiaryImageHelper? diaryImageHelper,
    ImageGenerationService? imageGenerationService,
    DatabaseService? databaseService,
    ThumbnailMonitoringService? monitoringService,
  }) {
    final shouldShare =
        repository == null &&
        diaryRepository == null &&
        diaryImageHelper == null &&
        imageGenerationService == null &&
        databaseService == null &&
        monitoringService == null;

    if (shouldShare && _shared != null) {
      return _shared!;
    }

    final resolvedDb = databaseService ?? DatabaseService();
    final service = ThumbnailBatchService._(
      repository ?? ThumbnailBatchRepository(databaseService: resolvedDb),
      diaryRepository ?? DiaryRepository(resolvedDb),
      diaryImageHelper ?? DiaryImageHelper(databaseService: resolvedDb),
      imageGenerationService ?? ImageGenerationService(),
      monitoringService ??
          ThumbnailMonitoringService(databaseService: resolvedDb),
    );

    if (shouldShare) {
      _shared ??= service;
    }

    return service;
  }

  ThumbnailBatchService._(
    this._repository,
    this._diaryRepository,
    this._diaryImageHelper,
    this._imageGenerationService,
    this._monitoringService,
  );

  static ThumbnailBatchService? _shared;

  final ThumbnailBatchRepository _repository;
  final DiaryRepository _diaryRepository;
  final DiaryImageHelper _diaryImageHelper;
  final ImageGenerationService _imageGenerationService;
  final ThumbnailMonitoringService _monitoringService;

  final _lock = AsyncLock();
  Timer? _workerTimer;
  bool _isWorkerRunning = false;

  /// 주기적인 워커를 시작합니다.
  void startWorker({Duration interval = const Duration(seconds: 30)}) {
    _ensureWorker();
  }

  /// 워커를 중지합니다.
  void stopWorker() {
    if (!_isWorkerRunning) {
      return;
    }
    _workerTimer?.cancel();
    _workerTimer = null;
    _isWorkerRunning = false;
    debugPrint('🛑 ThumbnailBatchService: 워커 중지');
  }

  Future<void> initialize() async {
    await _imageGenerationService.initialize();
  }

  Future<void> enqueueForDiary(
    int diaryId, {
    ThumbnailBatchJobType jobType = ThumbnailBatchJobType.regenerate,
  }) async {
    _ensureWorker();
    debugPrint(
      '🌀 ThumbnailBatchService: 큐 등록 요청 diaryId=$diaryId jobType=$jobType',
    );
    await _repository.enqueueOrUpdateExisting(
      diaryId: diaryId,
      jobType: jobType,
    );
    await _monitoringService.logGenerationStart(
      diaryId: diaryId,
      jobType: jobType,
    );
  }

  Future<void> enqueueBulk(
    List<int> diaryIds, {
    ThumbnailBatchJobType jobType = ThumbnailBatchJobType.bulkRebuild,
  }) async {
    _ensureWorker();
    final uniqueIds = {for (final id in diaryIds) id};
    for (final id in uniqueIds) {
      await _repository.enqueueOrUpdateExisting(
        diaryId: id,
        jobType: jobType,
        delay: const Duration(milliseconds: 100),
      );
      await _monitoringService.logGenerationStart(
        diaryId: id,
        jobType: jobType,
      );
    }
  }

  Future<void> processPendingJobs({int maxJobs = 2}) async {
    _ensureWorker();
    await _lock.run(() async {
      final jobs = await _repository.dequeuePendingJobs(limit: maxJobs);
      if (jobs.isEmpty) return;

      for (final job in jobs) {
        await _processJob(job);
      }
    });
  }

  Future<List<ThumbnailBatchJob>> getRecentJobs({int limit = 20}) {
    return _repository.getJobs(limit: limit);
  }

  Future<void> cleanup() {
    return _repository.cleanupCompleted();
  }

  Future<void> markCancelled(int jobId) {
    return _repository.markCancelled(jobId);
  }

  Future<void> _processJob(ThumbnailBatchJob job) async {
    final stopwatch = Stopwatch()..start();
    try {
      final diary = await _fetchDiary(job.diaryId);
      if (diary == null) {
        if (job.id != null) {
          await _repository.markDeleted(job.id!);
        }
        await _monitoringService.logGenerationFailure(
          diaryId: job.diaryId,
          job: job,
          error: 'Diary not found',
        );
        return;
      }

      if (!await _imageGenerationService.canGenerateTodayAsync) {
        await _repository.markFailed(job, 'Daily quota exceeded');
        await _monitoringService.logGenerationFailure(
          diaryId: job.diaryId,
          job: job,
          error: 'Daily quota exceeded',
        );
        return;
      }

      await _monitoringService.logGenerationStart(
        diaryId: job.diaryId,
        jobType: job.jobType,
      );

      await _refreshAttachment(
        diary,
        forceRegenerate: job.jobType != ThumbnailBatchJobType.initial,
      );
      await _repository.markSucceeded(job);
      await _monitoringService.logGenerationSuccess(
        diaryId: job.diaryId,
        job: job,
        duration: stopwatch.elapsed,
      );
    } catch (error, stackTrace) {
      debugPrint('ThumbnailBatchService: job ${job.id} failed: $error');
      debugPrint('$stackTrace');
      await _repository.markFailed(job, error);
      await _monitoringService.logGenerationFailure(
        diaryId: job.diaryId,
        job: job,
        error: error,
      );
    }
  }

  Future<void> _runWorkerCycle({required String reason}) async {
    try {
      debugPrint('🌀 ThumbnailBatchService: 워커 실행 시작 ($reason)');
      await _lock.run(() async {
        final jobs = await _repository.dequeuePendingJobs();
        if (jobs.isEmpty) {
          return;
        }

        for (final job in jobs) {
          await _processJob(job);
        }
      });
      debugPrint('🌀 ThumbnailBatchService: 워커 실행 완료 ($reason)');
    } catch (error, stackTrace) {
      debugPrint('🌀 ThumbnailBatchService: 워커 실행 실패 ($reason): $error');
      debugPrint('$stackTrace');
    }
  }

  Future<DiaryEntry?> _fetchDiary(int diaryId) async {
    try {
      return await _diaryRepository.getDiaryEntryById(diaryId);
    } catch (e) {
      debugPrint('ThumbnailBatchService: diary $diaryId fetch failed: $e');
      return null;
    }
  }

  Future<void> _refreshAttachment(
    DiaryEntry diary, {
    bool forceRegenerate = false,
  }) async {
    await _diaryImageHelper.ensureAttachment(
      diary,
      forceRegenerate: forceRegenerate,
    );
  }

  void _ensureWorker({Duration interval = const Duration(seconds: 30)}) {
    if (_isWorkerRunning) {
      return;
    }

    _workerTimer?.cancel();
    _workerTimer = Timer.periodic(interval, (_) {
      scheduleMicrotask(() => _runWorkerCycle(reason: 'periodic'));
    });
    _isWorkerRunning = true;
    debugPrint(
      '🌀 ThumbnailBatchService: 워커 시작 (interval=${interval.inSeconds}s)',
    );
    scheduleMicrotask(() => _runWorkerCycle(reason: 'startup'));
  }
}

class AsyncLock {
  Completer<void>? _completer;

  Future<void> run(Future<void> Function() action) async {
    while (_completer != null) {
      await _completer!.future;
    }

    final completer = Completer<void>();
    _completer = completer;

    try {
      await action();
    } finally {
      _completer = null;
      completer.complete();
    }
  }
}
