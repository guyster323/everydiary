import 'package:flutter/foundation.dart';

import '../models/regression_sample.dart';
import '../models/thumbnail_batch_job.dart';
import 'regression_sample_repository.dart';
import 'thumbnail_batch_service.dart';
import 'thumbnail_monitoring_service.dart';

class RegressionRunResult {
  const RegressionRunResult({
    required this.requested,
    required this.enqueued,
    required this.failed,
    required this.elapsed,
    this.group,
    this.failedSampleIds = const [],
  });

  final int requested;
  final int enqueued;
  final int failed;
  final Duration elapsed;
  final String? group;
  final List<int> failedSampleIds;
}

class ThumbnailRegressionRunner {
  ThumbnailRegressionRunner({
    RegressionSampleRepository? sampleRepository,
    ThumbnailBatchService? batchService,
    ThumbnailMonitoringService? monitoringService,
  }) : _sampleRepository = sampleRepository ?? RegressionSampleRepository(),
       _batchService = batchService ?? ThumbnailBatchService(),
       _monitoringService = monitoringService ?? ThumbnailMonitoringService();

  final RegressionSampleRepository _sampleRepository;
  final ThumbnailBatchService _batchService;
  final ThumbnailMonitoringService _monitoringService;

  Future<RegressionRunResult> enqueueSamples({
    int limit = 10,
    String? group,
    bool processImmediately = false,
  }) async {
    final stopwatch = Stopwatch()..start();
    final List<RegressionSample> samples = await _sampleRepository.fetchSamples(
      limit: limit,
      group: group,
    );

    if (samples.isEmpty) {
      stopwatch.stop();
      return RegressionRunResult(
        requested: 0,
        enqueued: 0,
        failed: 0,
        elapsed: stopwatch.elapsed,
        group: group,
        failedSampleIds: const [],
      );
    }

    final failedSamples = <int>[];
    var enqueued = 0;

    for (final sample in samples) {
      try {
        await _monitoringService.logRegressionQueued(
          diaryId: sample.diaryId,
          sampleId: sample.id,
          group: sample.sampleGroup ?? group,
        );

        await _batchService.enqueueForDiary(
          sample.diaryId,
          jobType: ThumbnailBatchJobType.bulkRebuild,
        );

        await _sampleRepository.touchSample(sample.id);
        enqueued += 1;
      } catch (error, stackTrace) {
        failedSamples.add(sample.id);
        debugPrint('ThumbnailRegressionRunner: 샘플 ${sample.id} 처리 실패 - $error');
        debugPrint('$stackTrace');
        await _monitoringService.logRegressionResult(
          diaryId: sample.diaryId,
          sampleId: sample.id,
          succeeded: false,
          group: sample.sampleGroup ?? group,
          metadata: {'error': error.toString()},
        );
      }
    }

    if (processImmediately && enqueued > 0) {
      await _batchService.processPendingJobs(maxJobs: enqueued);
    }

    stopwatch.stop();

    return RegressionRunResult(
      requested: samples.length,
      enqueued: enqueued,
      failed: failedSamples.length,
      elapsed: stopwatch.elapsed,
      group: group,
      failedSampleIds: failedSamples,
    );
  }
}
