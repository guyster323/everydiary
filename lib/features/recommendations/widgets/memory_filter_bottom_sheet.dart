import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_dropdown.dart';
import '../../../core/widgets/custom_input_field.dart';
import '../models/memory_filter.dart';

/// 회상 필터 바텀시트 위젯
class MemoryFilterBottomSheet extends StatefulWidget {
  final MemoryFilter currentFilter;
  final ValueChanged<MemoryFilter> onFilterChanged;

  const MemoryFilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<MemoryFilterBottomSheet> createState() =>
      _MemoryFilterBottomSheetState();
}

class _MemoryFilterBottomSheetState extends State<MemoryFilterBottomSheet> {
  late MemoryFilter _filter;
  DateTime? _startDate;
  DateTime? _endDate;
  double _minRelevance = 0.0;
  double _maxRelevance = 1.0;
  List<String> _requiredTags = [];
  List<String> _excludedTags = [];
  MemorySortBy _sortBy = MemorySortBy.relevance;
  SortOrder _sortOrder = SortOrder.descending;
  bool _excludeViewed = false;
  bool _excludeBookmarked = false;

  @override
  void initState() {
    super.initState();
    _initializeFilter();
  }

  void _initializeFilter() {
    _filter = widget.currentFilter;
    _startDate = _filter.startDate;
    _endDate = _filter.endDate;
    _minRelevance = _filter.minRelevance;
    _maxRelevance = _filter.maxRelevance;
    _requiredTags = List.from(_filter.requiredTags);
    _excludedTags = List.from(_filter.excludedTags);
    _sortBy = _filter.sortBy;
    _sortOrder = _filter.sortOrder;
    _excludeViewed = _filter.excludeViewed;
    _excludeBookmarked = _filter.excludeBookmarked;
  }

  void _applyFilter() {
    final newFilter = MemoryFilter(
      allowedTypes: _filter.allowedTypes,
      excludedTypes: _filter.excludedTypes,
      minRelevance: _minRelevance,
      maxRelevance: _maxRelevance,
      startDate: _startDate,
      endDate: _endDate,
      requiredTags: _requiredTags,
      excludedTags: _excludedTags,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
      excludeViewed: _excludeViewed,
      excludeBookmarked: _excludeBookmarked,
      maxResults: _filter.maxResults,
    );

    widget.onFilterChanged(newFilter);
    Navigator.of(context).pop();
  }

  void _resetFilter() {
    setState(() {
      _filter = const MemoryFilter();
      _startDate = null;
      _endDate = null;
      _minRelevance = 0.0;
      _maxRelevance = 1.0;
      _requiredTags = [];
      _excludedTags = [];
      _sortBy = MemorySortBy.relevance;
      _sortOrder = SortOrder.descending;
      _excludeViewed = false;
      _excludeBookmarked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 헤더
          _buildHeader(),

          // 필터 내용
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 관련성 범위
                  _buildRelevanceRange(),
                  const SizedBox(height: 24),

                  // 날짜 범위
                  _buildDateRange(),
                  const SizedBox(height: 24),

                  // 정렬 옵션
                  _buildSortOptions(),
                  const SizedBox(height: 24),

                  // 필터 옵션
                  _buildFilterOptions(),
                  const SizedBox(height: 24),

                  // 태그 필터
                  _buildTagFilters(),
                ],
              ),
            ),
          ),

          // 하단 버튼
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '회상 필터',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          TextButton(onPressed: _resetFilter, child: const Text('초기화')),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildRelevanceRange() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '관련성 범위',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '최소: ${(_minRelevance * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Slider(
                      value: _minRelevance,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      onChanged: (value) {
                        setState(() {
                          _minRelevance = value;
                          if (_minRelevance > _maxRelevance) {
                            _maxRelevance = _minRelevance;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '최대: ${(_maxRelevance * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Slider(
                      value: _maxRelevance,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      onChanged: (value) {
                        setState(() {
                          _maxRelevance = value;
                          if (_maxRelevance < _minRelevance) {
                            _minRelevance = _maxRelevance;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRange() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '날짜 범위',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: '시작 날짜',
                  date: _startDate,
                  onDateSelected: (date) {
                    setState(() {
                      _startDate = date;
                      if (_endDate != null && _startDate!.isAfter(_endDate!)) {
                        _endDate = _startDate;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  label: '종료 날짜',
                  date: _endDate,
                  onDateSelected: (date) {
                    setState(() {
                      _endDate = date;
                      if (_startDate != null &&
                          _endDate!.isBefore(_startDate!)) {
                        _startDate = _endDate;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime?> onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? DateFormat('yyyy-MM-dd').format(date) : '선택 안함',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: date != null
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOptions() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '정렬 옵션',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomDropdown<MemorySortBy>(
                  value: _sortBy,
                  items: MemorySortBy.values.map((sortBy) {
                    return DropdownItem(
                      value: sortBy,
                      text: _getSortByDisplayName(sortBy),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value ?? MemorySortBy.relevance;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomDropdown<SortOrder>(
                  value: _sortOrder,
                  items: SortOrder.values.map((order) {
                    return DropdownItem(
                      value: order,
                      text: _getSortOrderDisplayName(order),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _sortOrder = value ?? SortOrder.descending;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '필터 옵션',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('조회한 회상 제외'),
            subtitle: const Text('이미 본 회상은 표시하지 않습니다'),
            value: _excludeViewed,
            onChanged: (value) {
              setState(() {
                _excludeViewed = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('북마크한 회상 제외'),
            subtitle: const Text('북마크한 회상은 표시하지 않습니다'),
            value: _excludeBookmarked,
            onChanged: (value) {
              setState(() {
                _excludeBookmarked = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTagFilters() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '태그 필터',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          CustomInputField(
            hintText: '예: 여행, 맛집',
            onChanged: (value) {
              setState(() {
                _requiredTags = value
                    .split(',')
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty)
                    .toList();
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            '필수 태그 (쉼표로 구분)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          CustomInputField(
            hintText: '예: 슬픔, 우울',
            onChanged: (value) {
              setState(() {
                _excludedTags = value
                    .split(',')
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty)
                    .toList();
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            '제외 태그 (쉼표로 구분)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilter,
              child: const Text('적용'),
            ),
          ),
        ],
      ),
    );
  }

  String _getSortByDisplayName(MemorySortBy sortBy) {
    switch (sortBy) {
      case MemorySortBy.relevance:
        return '관련성';
      case MemorySortBy.createdAt:
        return '생성 날짜';
      case MemorySortBy.originalDate:
        return '원본 날짜';
      case MemorySortBy.lastViewedAt:
        return '마지막 조회';
      case MemorySortBy.title:
        return '제목';
    }
  }

  String _getSortOrderDisplayName(SortOrder order) {
    switch (order) {
      case SortOrder.ascending:
        return '오름차순';
      case SortOrder.descending:
        return '내림차순';
    }
  }
}
