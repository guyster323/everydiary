import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/custom_app_bar.dart';
import '../../../shared/models/thumbnail_generation_log.dart';
import '../providers/thumbnail_monitoring_provider.dart';

class ThumbnailMonitoringScreen extends ConsumerWidget {
  const ThumbnailMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(thumbnailMonitoringDashboardProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: '썸네일 품질 리포트',
        actions: [
          IconButton(
            onPressed: () async {
              await ref
                  .read(thumbnailMonitoringDashboardProvider.notifier)
                  .refresh();
            },
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (data) => RefreshIndicator(
          onRefresh: () =>
              ref.read(thumbnailMonitoringDashboardProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummarySection(data: data),
              const SizedBox(height: 16),
              _RegressionSection(data: data, ref: ref),
              const SizedBox(height: 16),
              _FailuresSection(failures: data.recentFailures),
              const SizedBox(height: 16),
              _RecentLogsSection(logs: data.recentLogs),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Padding(
          padding: const EdgeInsets.all(24),
          child: SelectableText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '데이터를 불러오는 중 오류가 발생했습니다:\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: error.toString()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.data});

  final ThumbnailMonitoringDashboardData data;

  @override
  Widget build(BuildContext context) {
    final summary = data.summary;
    final successRate = summary.total == 0
        ? 0.0
        : summary.succeeded / summary.total.clamp(1, summary.total);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '요약',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SummaryChip(
                  label: '총 작업',
                  value: summary.total.toString(),
                  color: theme.colorScheme.primary,
                ),
                _SummaryChip(
                  label: '성공',
                  value: summary.succeeded.toString(),
                  color: theme.colorScheme.secondary,
                ),
                _SummaryChip(
                  label: '실패',
                  value: summary.failed.toString(),
                  color: theme.colorScheme.error,
                ),
                _SummaryChip(
                  label: '대기 중',
                  value: summary.started.toString(),
                  color: theme.colorScheme.tertiary,
                ),
                _SummaryChip(
                  label: '취소',
                  value: summary.cancelled.toString(),
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '성공률 ${(successRate * 100).toStringAsFixed(1)}%',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: successRate,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            Text('엔진별 작업 현황', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            ...summary.byEngine.entries.map(
              (entry) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(entry.key),
                trailing: Text(entry.value.toString()),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '마지막 갱신: ${DateFormat('yyyy-MM-dd HH:mm').format(data.lastUpdated)}',
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide.none,
    );
  }
}

class _RegressionSection extends StatelessWidget {
  const _RegressionSection({required this.data, required this.ref});

  final ThumbnailMonitoringDashboardData data;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastRun = data.lastRunResult;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '회귀 테스트',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('등록된 회귀 샘플: ${data.regressionSampleCount}개'),
            const SizedBox(height: 8),
            if (lastRun != null) ...[
              Text('최근 실행 결과', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              SelectableText.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '요청: ${lastRun.requested} | '),
                    TextSpan(text: '큐 등록: ${lastRun.enqueued} | '),
                    TextSpan(
                      text: '실패: ${lastRun.failed}\n',
                      style: TextStyle(
                        color: lastRun.failed > 0
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    TextSpan(
                      text:
                          '소요 시간: ${lastRun.elapsed.inMilliseconds / 1000.0}s',
                    ),
                  ],
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 12),
            ],
            ElevatedButton.icon(
              onPressed: data.isRunningRegression
                  ? null
                  : () async {
                      await ref
                          .read(thumbnailMonitoringDashboardProvider.notifier)
                          .runRegression(limit: 10, processImmediately: true);
                    },
              icon: data.isRunningRegression
                  ? SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Icon(Icons.refresh_outlined),
              label: Text(
                data.isRunningRegression ? '회귀 테스트 실행 중...' : '회귀 테스트 실행',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FailuresSection extends StatelessWidget {
  const _FailuresSection({required this.failures});

  final List<ThumbnailGenerationLog> failures;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '최근 실패 로그',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (failures.isEmpty)
              Text('최근 실패 로그가 없습니다.', style: textTheme.bodyMedium)
            else
              ...failures.map((log) {
                final metadata = log.metadata;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SelectableText.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '[${DateFormat('MM-dd HH:mm').format(log.createdAt)}] ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.error,
                          ),
                        ),
                        TextSpan(text: '${log.engine} → ${log.status}\n'),
                        if (metadata != null)
                          TextSpan(
                            text:
                                metadata['error']?.toString() ??
                                metadata.toString(),
                          ),
                      ],
                      style: textTheme.bodyMedium,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _RecentLogsSection extends StatelessWidget {
  const _RecentLogsSection({required this.logs});

  final List<ThumbnailGenerationLog> logs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '최근 작업 로그',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (logs.isEmpty)
              Text('로그가 없습니다.', style: textTheme.bodyMedium)
            else
              ...logs.map(
                (log) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${log.engine} → ${log.status}'),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(log.createdAt),
                  ),
                  trailing: Text(
                    log.durationMs == null ? '-' : '${log.durationMs}ms',
                    style: textTheme.bodySmall,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
