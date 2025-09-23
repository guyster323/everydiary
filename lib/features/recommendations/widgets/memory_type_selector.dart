import 'package:flutter/material.dart';

import '../../../core/animations/fade_in_animation.dart';
import '../models/diary_memory.dart';

/// 회상 유형 선택기 위젯
class MemoryTypeSelector extends StatefulWidget {
  final MemoryType? selectedType;
  final ValueChanged<MemoryType?> onTypeSelected;

  const MemoryTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  State<MemoryTypeSelector> createState() => _MemoryTypeSelectorState();
}

class _MemoryTypeSelectorState extends State<MemoryTypeSelector>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeInAnimation(
      controller: _animationController,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            // 전체 선택 버튼
            _buildTypeChip(type: null, label: '전체', icon: Icons.all_inclusive),
            const SizedBox(width: 8),

            // 각 회상 유형별 버튼
            ...MemoryType.values.map((type) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildTypeChip(
                  type: type,
                  label: _getTypeDisplayName(type),
                  icon: _getTypeIcon(type),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip({
    required MemoryType? type,
    required String label,
    required IconData icon,
  }) {
    final isSelected = widget.selectedType == type;

    return GestureDetector(
      onTap: () => widget.onTypeSelected(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeDisplayName(MemoryType type) {
    switch (type) {
      case MemoryType.yesterday:
        return '어제';
      case MemoryType.oneWeekAgo:
        return '일주일 전';
      case MemoryType.oneMonthAgo:
        return '한달 전';
      case MemoryType.oneYearAgo:
        return '1년 전';
      case MemoryType.pastToday:
        return '과거의 오늘';
      case MemoryType.sameTimeOfDay:
        return '같은 시간';
      case MemoryType.seasonal:
        return '계절별';
      case MemoryType.specialDate:
        return '특별한 날';
      case MemoryType.similarTags:
        return '관련 태그';
    }
  }

  IconData _getTypeIcon(MemoryType type) {
    switch (type) {
      case MemoryType.yesterday:
        return Icons.history;
      case MemoryType.oneWeekAgo:
        return Icons.calendar_view_week;
      case MemoryType.oneMonthAgo:
        return Icons.calendar_month;
      case MemoryType.oneYearAgo:
        return Icons.calendar_today;
      case MemoryType.pastToday:
        return Icons.history;
      case MemoryType.sameTimeOfDay:
        return Icons.access_time;
      case MemoryType.seasonal:
        return Icons.wb_sunny;
      case MemoryType.specialDate:
        return Icons.celebration;
      case MemoryType.similarTags:
        return Icons.label;
    }
  }
}
