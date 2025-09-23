import 'package:flutter/material.dart';

import '../../profile/screens/profile_screen.dart';

/// 프로필 통계 카드 위젯
/// 사용자의 통계 정보를 카드 형태로 표시하는 위젯입니다.
class ProfileStatsCard extends StatelessWidget {
  final String title;
  final List<StatItem> stats;

  const ProfileStatsCard({super.key, required this.title, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(height: 16),

          // 통계 그리드
          _buildStatsGrid(context),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    // 2열 그리드로 표시
    final rows = <Widget>[];

    for (int i = 0; i < stats.length; i += 2) {
      final leftStat = stats[i];
      final rightStat = i + 1 < stats.length ? stats[i + 1] : null;

      rows.add(
        Row(
          children: [
            Expanded(child: _buildStatItem(context, leftStat)),
            if (rightStat != null) ...[
              const SizedBox(width: 16),
              Expanded(child: _buildStatItem(context, rightStat)),
            ],
          ],
        ),
      );

      if (i + 2 < stats.length) {
        rows.add(const SizedBox(height: 16));
      }
    }

    return Column(children: rows);
  }

  Widget _buildStatItem(BuildContext context, StatItem stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              stat.icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),

          const SizedBox(height: 12),

          // 값
          if (stat.value.isNotEmpty)
            Text(
              stat.value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: 4),

          // 라벨
          Text(
            stat.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
