import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/responsive_widgets.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_loading.dart';
import '../../../shared/services/database_service.dart';
import '../../../shared/services/repositories/diary_repository.dart';
import '../services/calendar_service.dart';
import '../widgets/statistics_widget.dart';

/// 통계 화면
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  late CalendarService _calendarService;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    _calendarService = CalendarService(
      diaryRepository: DiaryRepository(DatabaseService()),
    );

    await _calendarService.loadDiaries();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _calendarService.dispose();
    super.dispose();
  }

  /// 날짜 범위 선택 다이얼로그
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      locale: const Locale('ko', 'KR'),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  /// 기간 프리셋 선택
  void _selectPreset(String preset) {
    final now = DateTime.now();
    DateTime start;
    final DateTime end = now;

    switch (preset) {
      case 'week':
        start = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        start = now.subtract(const Duration(days: 30));
        break;
      case 'quarter':
        start = now.subtract(const Duration(days: 90));
        break;
      case 'year':
        start = now.subtract(const Duration(days: 365));
        break;
      default:
        return;
    }

    setState(() {
      _startDate = start;
      _endDate = end;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '일기 통계',
        actions: [
          // 날짜 범위 선택 버튼
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: '날짜 범위 선택',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CustomLoading())
          : ResponsiveWrapper(
              child: Column(
                children: [
                  // 기간 선택 및 필터
                  _buildPeriodSelector(),

                  // 통계 내용
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: StatisticsWidget(
                        calendarService: _calendarService,
                        startDate: _startDate,
                        endDate: _endDate,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// 기간 선택 위젯
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 선택된 기간 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '분석 기간',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                  '${_startDate.year}.${_startDate.month.toString().padLeft(2, '0')}.${_startDate.day.toString().padLeft(2, '0')} - ${_endDate.year}.${_endDate.month.toString().padLeft(2, '0')}.${_endDate.day.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 기간 프리셋 버튼들
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPresetButton('최근 1주', 'week'),
                const SizedBox(width: 8),
                _buildPresetButton('최근 1개월', 'month'),
                const SizedBox(width: 8),
                _buildPresetButton('최근 3개월', 'quarter'),
                const SizedBox(width: 8),
                _buildPresetButton('최근 1년', 'year'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 기간 프리셋 버튼
  Widget _buildPresetButton(String label, String preset) {
    final isSelected = _isPresetSelected(preset);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _selectPreset(preset),
      selectedColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  /// 프리셋이 선택되었는지 확인
  bool _isPresetSelected(String preset) {
    final now = DateTime.now();
    DateTime expectedStart;

    switch (preset) {
      case 'week':
        expectedStart = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        expectedStart = now.subtract(const Duration(days: 30));
        break;
      case 'quarter':
        expectedStart = now.subtract(const Duration(days: 90));
        break;
      case 'year':
        expectedStart = now.subtract(const Duration(days: 365));
        break;
      default:
        return false;
    }

    return _startDate.year == expectedStart.year &&
        _startDate.month == expectedStart.month &&
        _startDate.day == expectedStart.day &&
        _endDate.year == now.year &&
        _endDate.month == now.month &&
        _endDate.day == now.day;
  }
}
