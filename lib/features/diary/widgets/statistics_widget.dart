import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_card.dart';
import '../services/calendar_service.dart';

/// 일기 통계 표시 위젯
class StatisticsWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 전체 통계 요약
        _buildOverallStatsCard(context),

        const SizedBox(height: 16),

        // 월별/주별 통계
        Row(
          children: [
            Expanded(child: _buildMonthlyStatsCard(context)),
            const SizedBox(width: 12),
            Expanded(child: _buildWeeklyStatsCard(context)),
          ],
        ),

        const SizedBox(height: 16),

        // 일기 길이 통계
        _buildContentLengthStatsCard(context),

        const SizedBox(height: 16),

        // 작성 시간대 통계
        _buildWritingTimeStatsCard(context),
      ],
    );
  }

  /// 전체 통계 요약 카드
  Widget _buildOverallStatsCard(BuildContext context) {
    final overallStats = calendarService.getOverallStats();

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '전체 통계',
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
                    '총 일기 수',
                    '${overallStats['totalDiaries']}개',
                    Icons.book,
                    AppTheme.primaryBlue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    '현재 연속',
                    '${overallStats['currentStreak']}일',
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
                    '최장 연속',
                    '${overallStats['longestStreak']}일',
                    Icons.trending_up,
                    AppTheme.positiveGreen,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    '일평균',
                    '${overallStats['averagePerDay'].toStringAsFixed(1)}개',
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
                    '가장 활발한 요일',
                    '${overallStats['mostActiveDay']}요일',
                    Icons.schedule,
                    AppTheme.warningOrange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    '가장 활발한 월',
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
  Widget _buildMonthlyStatsCard(BuildContext context) {
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
              '월별 작성 빈도',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            if (monthlyStats.isEmpty)
              const Text('데이터가 없습니다')
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
                          '$count개',
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
  Widget _buildWeeklyStatsCard(BuildContext context) {
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
              '주별 작성 빈도',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            if (weeklyStats.isEmpty)
              const Text('데이터가 없습니다')
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
                          '$count개',
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
  Widget _buildContentLengthStatsCard(BuildContext context) {
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
              '일기 길이 통계',
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
                    '평균 글자 수',
                    '${lengthStats['averageCharacters']}자',
                    Icons.text_fields,
                    AppTheme.infoBlue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    '평균 단어 수',
                    '${lengthStats['averageWords']}개',
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
                    '최대 글자 수',
                    '${lengthStats['maxCharacters']}자',
                    Icons.trending_up,
                    AppTheme.warningOrange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    '최소 글자 수',
                    '${lengthStats['minCharacters']}자',
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
  Widget _buildWritingTimeStatsCard(BuildContext context) {
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
              '작성 시간대 통계',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            if (topTimes.isEmpty)
              const Text('데이터가 없습니다')
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
                          '$count회',
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
