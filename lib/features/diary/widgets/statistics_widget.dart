import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/localization_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_card.dart';
import '../services/calendar_service.dart';

/// 일기 통계 표시 위젯
class StatisticsWidget extends ConsumerWidget {
  final CalendarService calendarService;
  final DateTime startDate;
  final DateTime endDate;

  const StatisticsWidget({
    super.key,
    required this.calendarService,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 전체 통계 요약
        _buildOverallStatsCard(context, ref),

        const SizedBox(height: 16),

        // 월별/주별 통계
        Row(
          children: [
            Expanded(child: _buildMonthlyStatsCard(context, ref)),
            const SizedBox(width: 12),
            Expanded(child: _buildWeeklyStatsCard(context, ref)),
          ],
        ),

        const SizedBox(height: 16),

        // 일기 길이 통계
        _buildContentLengthStatsCard(context, ref),

        const SizedBox(height: 16),

        // 작성 시간대 통계
        _buildWritingTimeStatsCard(context, ref),
      ],
    );
  }

  /// 전체 통계 요약 카드
  Widget _buildOverallStatsCard(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(localizationProvider);
    final overallStats = calendarService.getOverallStats();

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.get('stats_overall_title'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    ref,
                    l10n.get('stats_total_diaries'),
                    l10n.get('stats_total_diaries_unit').replaceAll('{count}', '${overallStats['totalDiaries']}'),
                    Icons.book,
                    AppTheme.primaryBlue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    ref,
                    l10n.get('stats_current_streak'),
                    l10n.get('stats_current_streak_unit').replaceAll('{count}', '${overallStats['currentStreak']}'),
                    Icons.local_fire_department,
                    AppTheme.secondaryBeige,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    ref,
                    l10n.get('stats_longest_streak'),
                    l10n.get('stats_longest_streak_unit').replaceAll('{count}', '${overallStats['longestStreak']}'),
                    Icons.trending_up,
                    AppTheme.positiveGreen,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    ref,
                    l10n.get('stats_daily_average'),
                    l10n.get('stats_daily_average_unit').replaceAll('{count}', (overallStats['averagePerDay'] as num).toStringAsFixed(1)),
                    Icons.calendar_today,
                    AppTheme.infoBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    ref,
                    l10n.get('stats_most_active_day'),
                    l10n.get('stats_most_active_day_unit').replaceAll('{day}', '${overallStats['mostActiveDay']}'),
                    Icons.schedule,
                    AppTheme.warningOrange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    ref,
                    l10n.get('stats_most_active_month'),
                    '${overallStats['mostActiveMonth']}',
                    Icons.calendar_month,
                    AppTheme.neutralGray,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 월별 통계 카드
  Widget _buildMonthlyStatsCard(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(localizationProvider);
    final monthlyStats = calendarService.getMonthlyFrequencyStats(
      startDate,
      endDate,
    );

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.get('stats_monthly_frequency'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            if (monthlyStats.isEmpty)
              Text(l10n.get('stats_no_data'))
            else
              ...monthlyStats.entries.take(6).map((entry) {
                final month = entry.key;
                final count = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        month,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.get('stats_count_unit').replaceAll('{count}', '$count'),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  /// 주별 통계 카드
  Widget _buildWeeklyStatsCard(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(localizationProvider);
    final weeklyStats = calendarService.getWeeklyFrequencyStats(
      startDate,
      endDate,
    );

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.get('stats_weekly_frequency'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            if (weeklyStats.isEmpty)
              Text(l10n.get('stats_no_data'))
            else
              ...weeklyStats.entries.take(6).map((entry) {
                final week = entry.key;
                final count = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(week, style: Theme.of(context).textTheme.bodyMedium),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryBeige.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.get('stats_count_unit').replaceAll('{count}', '$count'),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.secondaryBeige,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  /// 일기 길이 통계 카드
  Widget _buildContentLengthStatsCard(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(localizationProvider);
    final lengthStats = calendarService.getContentLengthStats(
      startDate,
      endDate,
    );

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.get('stats_content_length_title'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    ref,
                    l10n.get('stats_average_characters'),
                    l10n.get('stats_characters_unit').replaceAll('{count}', '${lengthStats['averageCharacters']}'),
                    Icons.text_fields,
                    AppTheme.infoBlue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    ref,
                    l10n.get('stats_average_words'),
                    l10n.get('stats_words_unit').replaceAll('{count}', '${lengthStats['averageWords']}'),
                    Icons.format_list_bulleted,
                    AppTheme.positiveGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    ref,
                    l10n.get('stats_max_characters'),
                    l10n.get('stats_characters_unit').replaceAll('{count}', '${lengthStats['maxCharacters']}'),
                    Icons.trending_up,
                    AppTheme.warningOrange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    ref,
                    l10n.get('stats_min_characters'),
                    l10n.get('stats_characters_unit').replaceAll('{count}', '${lengthStats['minCharacters']}'),
                    Icons.trending_down,
                    AppTheme.neutralGray,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 작성 시간대 통계 카드
  Widget _buildWritingTimeStatsCard(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(localizationProvider);
    final timeStats = calendarService.getWritingTimeStats(startDate, endDate);

    // 가장 활발한 시간대 5개 찾기
    final sortedTimes = timeStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTimes = sortedTimes.take(5).toList();

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.get('stats_writing_time_title'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            if (topTimes.isEmpty)
              Text(l10n.get('stats_no_data'))
            else
              ...topTimes.map((entry) {
                final time = entry.key;
                final count = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.get('stats_time_count_unit').replaceAll('{count}', '$count'),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  /// 통계 항목 위젯
  Widget _buildStatItem(
    BuildContext context,
    WidgetRef ref,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
