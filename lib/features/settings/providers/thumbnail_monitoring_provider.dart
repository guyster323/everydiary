import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/thumbnail_generation_log.dart';
import '../../../shared/services/regression_sample_repository.dart';
import '../../../shared/services/thumbnail_monitoring_service.dart';
import '../../../shared/services/thumbnail_regression_runner.dart';

part 'thumbnail_monitoring_provider.g.dart';

class ThumbnailMonitoringDashboardData {
  const ThumbnailMonitoringDashboardData({
    required this.summary,
    required this.recentFailures,
    required this.recentLogs,
    required this.regressionSampleCount,
    this.lastRunResult,
    this.isRunningRegression = false,
    required this.lastUpdated,
  });

  final ThumbnailMonitoringSummary summary;
  final List<ThumbnailGenerationLog> recentFailures;
  final List<ThumbnailGenerationLog> recentLogs;
  final int regressionSampleCount;
  final RegressionRunResult? lastRunResult;
  final bool isRunningRegression;
  final DateTime lastUpdated;

  ThumbnailMonitoringDashboardData copyWith({
    ThumbnailMonitoringSummary? summary,
    List<ThumbnailGenerationLog>? recentFailures,
    List<ThumbnailGenerationLog>? recentLogs,
    int? regressionSampleCount,
    RegressionRunResult? lastRunResult,
    bool? isRunningRegression,
    DateTime? lastUpdated,
  }) {
    return ThumbnailMonitoringDashboardData(
      summary: summary ?? this.summary,
      recentFailures: recentFailures ?? this.recentFailures,
      recentLogs: recentLogs ?? this.recentLogs,
      regressionSampleCount:
          regressionSampleCount ?? this.regressionSampleCount,
      lastRunResult: lastRunResult ?? this.lastRunResult,
      isRunningRegression: isRunningRegression ?? this.isRunningRegression,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

@riverpod
class ThumbnailMonitoringDashboard extends _$ThumbnailMonitoringDashboard {
  late final ThumbnailMonitoringService _monitoringService;
  late final ThumbnailRegressionRunner _regressionRunner;
  late final RegressionSampleRepository _sampleRepository;

  @override
  Future<ThumbnailMonitoringDashboardData> build() async {
    _monitoringService = ThumbnailMonitoringService();
    _sampleRepository = RegressionSampleRepository();
    _regressionRunner = ThumbnailRegressionRunner(
      sampleRepository: _sampleRepository,
      monitoringService: _monitoringService,
    );
    return _loadData();
  }

  Future<void> refresh() async {
    final previous = state.valueOrNull;
    if (previous != null) {
      state = AsyncData(previous.copyWith(lastUpdated: DateTime.now()));
    }

    state = await AsyncValue.guard(() async {
      final data = await _loadData(lastRunResult: previous?.lastRunResult);
      return data;
    });
  }

  Future<void> runRegression({
    int limit = 10,
    String? group,
    bool processImmediately = true,
  }) async {
    final previous = state.valueOrNull ?? await _loadData();
    state = AsyncData(previous.copyWith(isRunningRegression: true));

    try {
      final result = await _regressionRunner.enqueueSamples(
        limit: limit,
        group: group,
        processImmediately: processImmediately,
      );

      final refreshed = await _loadData(lastRunResult: result);
      state = AsyncData(refreshed);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<ThumbnailMonitoringDashboardData> _loadData({
    RegressionRunResult? lastRunResult,
    bool isRunningRegression = false,
  }) async {
    final summary = await _monitoringService.fetchSummary();
    final recentFailures = await _monitoringService.fetchRecentFailures(
      limit: 10,
    );
    final recentLogs = await _monitoringService.fetchRecentLogs(limit: 20);
    final sampleCount = await _sampleRepository.countSamples();

    return ThumbnailMonitoringDashboardData(
      summary: summary,
      recentFailures: recentFailures,
      recentLogs: recentLogs,
      regressionSampleCount: sampleCount,
      lastRunResult: lastRunResult,
      isRunningRegression: isRunningRegression,
      lastUpdated: DateTime.now(),
    );
  }
}
