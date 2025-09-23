import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/diary_list_service.dart';

/// 일기 필터 다이얼로그
class DiaryFilterDialog extends StatefulWidget {
  final DiaryListFilter currentFilter;
  final void Function(DiaryListFilter) onFilterApplied;

  const DiaryFilterDialog({
    super.key,
    required this.currentFilter,
    required this.onFilterApplied,
  });

  @override
  State<DiaryFilterDialog> createState() => _DiaryFilterDialogState();
}

class _DiaryFilterDialogState extends State<DiaryFilterDialog> {
  late DiaryListFilter _filter;
  late TextEditingController _searchController;
  DateTime? _startDate;
  DateTime? _endDate;

  // 기분 옵션
  final List<String> _moodOptions = [
    '행복',
    '슬픔',
    '화남',
    '평온',
    '설렘',
    '걱정',
    '피곤',
    '만족',
    '실망',
    '감사',
    '외로움',
    '흥분',
    '우울',
    '긴장',
    '편안',
    '기타',
  ];

  // 날씨 옵션
  final List<String> _weatherOptions = [
    '맑음',
    '흐림',
    '비',
    '눈',
    '바람',
    '안개',
    '폭염',
    '한파',
    '기타',
  ];

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _searchController = TextEditingController(text: _filter.searchQuery ?? '');
    _startDate = _filter.startDate;
    _endDate = _filter.endDate;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 필터 적용
  void _applyFilter() {
    widget.onFilterApplied(_filter);
    Navigator.of(context).pop();
  }

  /// 필터 초기화
  void _clearFilter() {
    setState(() {
      _filter = const DiaryListFilter();
      _searchController.clear();
      _startDate = null;
      _endDate = null;
    });
  }

  /// 날짜 선택
  Future<void> _selectDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR'),
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
          _filter = _filter.copyWith(startDate: date);
        } else {
          _endDate = date;
          _filter = _filter.copyWith(endDate: date);
        }
      });
    }
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime? date) {
    if (date == null) return '선택 안함';
    return DateFormat('yyyy년 M월 d일', 'ko_KR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('필터'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 검색어
              _buildSectionTitle('검색어'),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: '제목 또는 내용으로 검색',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _filter = _filter.copyWith(
                    searchQuery: value.isEmpty ? null : value,
                  );
                },
              ),
              const SizedBox(height: 16),

              // 기분 필터
              _buildSectionTitle('기분'),
              _buildChipFilter(
                options: _moodOptions,
                selectedValue: _filter.mood,
                onChanged: (value) {
                  _filter = _filter.copyWith(mood: value);
                },
              ),
              const SizedBox(height: 16),

              // 날씨 필터
              _buildSectionTitle('날씨'),
              _buildChipFilter(
                options: _weatherOptions,
                selectedValue: _filter.weather,
                onChanged: (value) {
                  _filter = _filter.copyWith(weather: value);
                },
              ),
              const SizedBox(height: 16),

              // 날짜 범위
              _buildSectionTitle('날짜 범위'),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _formatDate(_startDate),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('~'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _formatDate(_endDate),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 기타 옵션
              _buildSectionTitle('기타'),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('즐겨찾기만'),
                      value: _filter.isFavorite ?? false,
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(
                            isFavorite: value == true ? true : null,
                          );
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('비공개만'),
                      value: _filter.isPrivate ?? false,
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(
                            isPrivate: value == true ? true : null,
                          );
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _clearFilter, child: const Text('초기화')),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(onPressed: _applyFilter, child: const Text('적용')),
      ],
    );
  }

  /// 섹션 제목
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  /// 칩 필터
  Widget _buildChipFilter({
    required List<String> options,
    String? selectedValue,
    required void Function(String?) onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        // 전체 선택 칩
        FilterChip(
          label: const Text('전체'),
          selected: selectedValue == null,
          onSelected: (selected) {
            onChanged(selected ? null : selectedValue);
          },
        ),
        // 옵션 칩들
        ...options.map(
          (option) => FilterChip(
            label: Text(option),
            selected: selectedValue == option,
            onSelected: (selected) {
              onChanged(selected ? option : null);
            },
          ),
        ),
      ],
    );
  }
}
