import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/custom_card.dart';
import '../../../shared/models/diary_entry.dart';

/// 일기 미리보기 카드
/// 캘린더 뷰에서 특정 날짜의 일기를 미리보기로 보여주는 카드입니다.
class DiaryPreviewCard extends StatelessWidget {
  final DiaryEntry diary;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;

  const DiaryPreviewCard({
    super.key,
    required this.diary,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (시간, 기분, 날씨)
            _buildHeader(context),

            const SizedBox(height: 12),

            // 제목
            if (diary.title?.isNotEmpty == true) ...[
              Text(
                diary.title!,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],

            // 내용 미리보기
            _buildContentPreview(context),

            const SizedBox(height: 12),

            // 하단 정보 (태그, 액션 버튼)
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  /// 헤더 빌드 (시간, 기분, 날씨)
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // 작성 시간
        Icon(
          Icons.access_time,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Text(
          _formatTime(diary.createdAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),

        const Spacer(),

        // 기분 아이콘
        if (diary.mood != null) ...[
          _buildMoodChip(context),
          const SizedBox(width: 8),
        ],

        // 날씨 아이콘
        if (diary.weather != null) ...[_buildWeatherChip(context)],
      ],
    );
  }

  /// 내용 미리보기 빌드
  Widget _buildContentPreview(BuildContext context) {
    String content = '';

    if (diary.content.isNotEmpty) {
      // HTML 태그 제거 및 텍스트만 추출
      content = diary.content
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&nbsp;', ' ')
          .trim();
    }

    if (content.isEmpty) {
      return Text(
        '내용이 없습니다',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Text(
      content,
      style: Theme.of(context).textTheme.bodyMedium,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 하단 정보 빌드 (태그, 액션 버튼)
  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        // 태그
        if (diary.tags.isNotEmpty) ...[
          Expanded(child: _buildTags(context)),
        ] else
          const Spacer(),

        // 액션 버튼들
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 즐겨찾기 버튼
            if (onToggleFavorite != null)
              IconButton(
                icon: Icon(
                  diary.isFavorite == true
                      ? Icons.favorite
                      : Icons.favorite_border,
                  size: 20,
                  color: diary.isFavorite == true
                      ? Colors.red
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: onToggleFavorite,
                tooltip: diary.isFavorite == true ? '즐겨찾기 해제' : '즐겨찾기',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),

            // 편집 버튼
            if (onEdit != null)
              IconButton(
                icon: Icon(
                  Icons.edit,
                  size: 20,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: onEdit,
                tooltip: '편집',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),

            // 삭제 버튼
            if (onDelete != null)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.7),
                ),
                onPressed: onDelete,
                tooltip: '삭제',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
          ],
        ),
      ],
    );
  }

  /// 기분 칩 빌드
  Widget _buildMoodChip(BuildContext context) {
    final mood = diary.mood!;
    final moodData = _getMoodData(mood);
    final color = moodData['color'] as Color;
    final icon = moodData['icon'] as IconData;
    final text = moodData['text'] as String;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 날씨 칩 빌드
  Widget _buildWeatherChip(BuildContext context) {
    final weather = diary.weather!;
    final weatherData = _getWeatherData(weather);
    final color = weatherData['color'] as Color;
    final icon = weatherData['icon'] as IconData;
    final text = weatherData['text'] as String;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 태그 빌드
  Widget _buildTags(BuildContext context) {
    final tags = diary.tags;
    final displayTags = tags.take(3).toList(); // 최대 3개만 표시

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...displayTags.map(
          (tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tag.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 11,
              ),
            ),
          ),
        ),

        // 더 많은 태그가 있는 경우
        if (tags.length > 3)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${tags.length - 3}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  /// 시간 포맷팅
  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';

    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (date == today) {
        return DateFormat('HH:mm').format(dateTime);
      } else {
        return DateFormat('MM/dd HH:mm').format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }

  /// 기분 데이터 반환
  Map<String, dynamic> _getMoodData(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case '행복':
        return {
          'icon': Icons.sentiment_very_satisfied,
          'color': Colors.orange,
          'text': '행복',
        };
      case 'sad':
      case '슬픔':
        return {
          'icon': Icons.sentiment_very_dissatisfied,
          'color': Colors.blue,
          'text': '슬픔',
        };
      case 'angry':
      case '화남':
        return {
          'icon': Icons.sentiment_very_dissatisfied,
          'color': Colors.red,
          'text': '화남',
        };
      case 'calm':
      case '평온':
        return {
          'icon': Icons.sentiment_neutral,
          'color': Colors.green,
          'text': '평온',
        };
      case 'excited':
      case '신남':
        return {
          'icon': Icons.sentiment_satisfied_alt,
          'color': Colors.purple,
          'text': '신남',
        };
      case 'worried':
      case '걱정':
        return {
          'icon': Icons.sentiment_dissatisfied,
          'color': Colors.amber,
          'text': '걱정',
        };
      default:
        return {
          'icon': Icons.sentiment_neutral,
          'color': Colors.grey,
          'text': mood,
        };
    }
  }

  /// 날씨 데이터 반환
  Map<String, dynamic> _getWeatherData(String weather) {
    switch (weather.toLowerCase()) {
      case 'sunny':
      case '맑음':
        return {'icon': Icons.wb_sunny, 'color': Colors.orange, 'text': '맑음'};
      case 'cloudy':
      case '흐림':
        return {'icon': Icons.cloud, 'color': Colors.grey, 'text': '흐림'};
      case 'rainy':
      case '비':
        return {'icon': Icons.grain, 'color': Colors.blue, 'text': '비'};
      case 'snowy':
      case '눈':
        return {'icon': Icons.ac_unit, 'color': Colors.lightBlue, 'text': '눈'};
      case 'windy':
      case '바람':
        return {'icon': Icons.air, 'color': Colors.cyan, 'text': '바람'};
      default:
        return {'icon': Icons.wb_sunny, 'color': Colors.grey, 'text': weather};
    }
  }
}
