import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/animations/fade_in_animation.dart';
import '../../../core/animations/slide_in_animation.dart';
import '../../../core/providers/localization_provider.dart';
import '../../../core/widgets/custom_card.dart';
import '../models/diary_memory.dart';

/// 회상 카드 위젯
class MemoryCard extends ConsumerStatefulWidget {
  final DiaryMemory memory;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;

  const MemoryCard({
    super.key,
    required this.memory,
    this.onTap,
    this.onBookmark,
  });

  @override
  ConsumerState<MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends ConsumerState<MemoryCard> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeInAnimation(
      controller: _fadeController,
      child: SlideInAnimation(
        controller: _slideController,
        child: CustomCard(
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 (회상 이유, 날짜, 북마크)
              _buildHeader(),
              const SizedBox(height: 12),

              // 제목
              _buildTitle(),
              const SizedBox(height: 8),

              // 내용 미리보기
              _buildContentPreview(),
              const SizedBox(height: 12),

              // 태그 및 메타 정보
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = ref.watch(localizationProvider);
    return Row(
      children: [
        // 회상 이유 배지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getMemoryTypeColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getMemoryTypeColor().withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            _getMemoryReasonText(widget.memory.reason.type, l10n),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _getMemoryTypeColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),

        // 원본 날짜
        Text(
          DateFormat('MM/dd').format(widget.memory.originalDate),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),

        // 북마크 버튼
        IconButton(
          icon: Icon(
            widget.memory.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            size: 20,
            color: widget.memory.isBookmarked
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onPressed: widget.onBookmark,
          tooltip: widget.memory.isBookmarked
              ? l10n.get('memory_bookmark_remove')
              : l10n.get('memory_bookmark'),
        ),
      ],
    );
  }

  String _getMemoryReasonText(MemoryType type, dynamic l10n) {
    switch (type) {
      case MemoryType.yesterday:
        return l10n.get('memory_reason_yesterday');
      case MemoryType.oneWeekAgo:
        return l10n.get('memory_reason_one_week_ago');
      case MemoryType.oneMonthAgo:
        return l10n.get('memory_reason_one_month_ago');
      case MemoryType.oneYearAgo:
        return l10n.get('memory_reason_one_year_ago');
      case MemoryType.pastToday:
        return l10n.get('memory_reason_past_today');
      case MemoryType.sameTimeOfDay:
        return l10n.get('memory_reason_same_time');
      case MemoryType.seasonal:
        return l10n.get('memory_reason_seasonal');
      case MemoryType.specialDate:
        return l10n.get('memory_reason_special_date');
      case MemoryType.similarTags:
        return l10n.get('memory_reason_similar_tags');
    }
  }

  Widget _buildTitle() {
    return Text(
      widget.memory.title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildContentPreview() {
    final content = widget.memory.content;
    const previewLength = 120;

    return Text(
      content.length > previewLength
          ? '${content.substring(0, previewLength)}...'
          : content,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // 태그
        if (widget.memory.tags.isNotEmpty) ...[
          Expanded(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: widget.memory.tags.take(3).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#$tag',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 8),
        ],

        // 관련성 점수
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getRelevanceColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getRelevanceColor().withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, size: 12, color: _getRelevanceColor()),
              const SizedBox(width: 2),
              Text(
                '${(widget.memory.relevance * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _getRelevanceColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getMemoryTypeColor() {
    switch (widget.memory.reason.type) {
      case MemoryType.yesterday:
        return Colors.blue;
      case MemoryType.oneWeekAgo:
        return Colors.green;
      case MemoryType.oneMonthAgo:
        return Colors.orange;
      case MemoryType.oneYearAgo:
        return Colors.purple;
      case MemoryType.pastToday:
        return Colors.red;
      case MemoryType.sameTimeOfDay:
        return Colors.teal;
      case MemoryType.seasonal:
        return Colors.amber;
      case MemoryType.specialDate:
        return Colors.pink;
      case MemoryType.similarTags:
        return Colors.indigo;
    }
  }

  Color _getRelevanceColor() {
    if (widget.memory.relevance >= 0.8) {
      return Colors.green;
    } else if (widget.memory.relevance >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }
}
