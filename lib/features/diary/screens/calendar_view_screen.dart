import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/animations/animations.dart';
import '../../../core/layout/responsive_widgets.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_loading.dart';
import '../../../shared/models/diary_entry.dart';
import '../../../shared/services/database_service.dart';
import '../../../shared/services/repositories/diary_repository.dart';
import '../services/calendar_service.dart';
import '../services/diary_list_service.dart';
import '../widgets/diary_preview_card.dart';

/// 캘린더 뷰 화면
class CalendarViewScreen extends ConsumerStatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  ConsumerState<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends ConsumerState<CalendarViewScreen>
    with TickerProviderStateMixin {
  late CalendarService _calendarService;
  late PageController _pageController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 애니메이션 컨트롤러들
  late AnimationController _calendarTransitionController;
  late AnimationController _diaryListController;
  late Animation<double> _calendarFadeAnimation;
  late Animation<Offset> _diaryListSlideAnimation;

  // 새로고침 이벤트 리스너
  final DiaryListRefreshNotifier _refreshNotifier = DiaryListRefreshNotifier();
  StreamSubscription<void>? _refreshSubscription;

  @override
  void initState() {
    super.initState();

    // CalendarService 초기화
    _calendarService = CalendarService(
      diaryRepository: DiaryRepository(DatabaseService()),
    );

    _pageController = PageController();
    _selectedDay = DateTime.now();

    // 애니메이션 컨트롤러 초기화
    _calendarTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _diaryListController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // 애니메이션 정의
    _calendarFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _calendarTransitionController,
        curve: Curves.easeOutCubic,
      ),
    );

    _diaryListSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _diaryListController,
            curve: Curves.easeOutQuart,
          ),
        );

    // 초기 애니메이션 시작
    _calendarTransitionController.forward();
    _diaryListController.forward();

    // 초기 데이터 로드
    _calendarService.loadDiaries();

    // 새로고침 이벤트 리스너 등록
    _refreshSubscription = _refreshNotifier.refreshStream.listen((_) {
      _calendarService.loadDiaries();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _calendarService.dispose();
    _calendarTransitionController.dispose();
    _diaryListController.dispose();
    _refreshSubscription?.cancel();
    super.dispose();
  }

  /// 날짜 선택 처리
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        // focusedDay는 선택된 날짜와 동일하게 설정
        _focusedDay = selectedDay;
      });

      // 일기 목록 애니메이션 재시작
      _diaryListController.reset();
      _diaryListController.forward();

      // 선택된 날짜의 일기 로드
      _calendarService.loadDiariesForDate(selectedDay);
    }
  }

  /// 포커스된 날짜 변경 처리
  void _onPageChanged(DateTime focusedDay) {
    // 포커스 변경은 월/년도 변경 시에만 허용
    if (focusedDay.month != _focusedDay.month ||
        focusedDay.year != _focusedDay.year) {
      setState(() {
        _focusedDay = focusedDay;
      });
    }
  }

  /// 캘린더 포맷 변경
  void _onFormatChanged(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });

    // 캘린더 전환 애니메이션
    _calendarTransitionController.reset();
    _calendarTransitionController.forward();
  }

  /// 새 일기 작성
  void _createNewDiary() {
    context.push('/diary/write');
  }

  /// 선택된 날짜에 일기 작성
  void _createDiaryForDate() {
    if (_selectedDay != null) {
      context.push('/diary/write', extra: {'selectedDate': _selectedDay});
    }
  }

  /// 일기 상세 보기
  void _viewDiary(DiaryEntry diary) {
    context.push('/diary/detail/${diary.id}');
  }

  /// 일기 편집
  void _editDiary(DiaryEntry diary) {
    context.push('/diary/edit/${diary.id}');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: '캘린더',
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
            tooltip: '뒤로가기',
          ),
          actions: [
            // 통계 버튼
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () {
                context.push('/diary/statistics');
              },
              tooltip: '일기 통계',
            ),

            // 뷰 전환 버튼
            IconButton(
              icon: Icon(
                _calendarFormat == CalendarFormat.month
                    ? Icons.view_week
                    : Icons.view_module,
              ),
              onPressed: () {
                setState(() {
                  _calendarFormat = _calendarFormat == CalendarFormat.month
                      ? CalendarFormat.week
                      : CalendarFormat.month;
                });
              },
              tooltip: _calendarFormat == CalendarFormat.month
                  ? '주간 보기'
                  : '월간 보기',
            ),

            // 오늘로 이동 버튼
            IconButton(
              icon: const Icon(Icons.today),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime.now();
                  _selectedDay = DateTime.now();
                });
                _calendarService.loadDiariesForDate(DateTime.now());
              },
              tooltip: '오늘',
            ),
          ],
        ),
        body: ResponsiveWrapper(
          child: Column(
            children: [
              // 캘린더
              _buildCalendar(),

              // 구분선
              const Divider(height: 1),

              // 선택된 날짜의 일기 목록
              Expanded(child: _buildSelectedDayDiaries()),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _createNewDiary,
          tooltip: '새 일기 작성',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  /// 캘린더 위젯 빌드
  Widget _buildCalendar() {
    return ListenableBuilder(
      listenable: _calendarService,
      builder: (context, child) {
        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _calendarFadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _calendarFadeAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: TableCalendar<DiaryEntry>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    eventLoader: _calendarService.getEventsForDay,
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      holidayTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 3,
                      markerSize: 6,
                      markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      formatButtonTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onDaySelected: _onDaySelected,
                    onFormatChanged: _onFormatChanged,
                    onPageChanged: _onPageChanged,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isEmpty) return null;

                        return Positioned(
                          bottom: 1,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: events.take(3).map((event) {
                              return Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// 선택된 날짜의 일기 목록 빌드
  Widget _buildSelectedDayDiaries() {
    if (_selectedDay == null) {
      return const Center(child: Text('날짜를 선택해주세요'));
    }

    return ListenableBuilder(
      listenable: _calendarService,
      builder: (context, child) {
        final selectedDayDiaries = _calendarService.getDiariesForDate(
          _selectedDay!,
        );

        if (_calendarService.isLoading) {
          return const Center(child: CustomLoading());
        }

        if (selectedDayDiaries.isEmpty) {
          return _buildEmptyDayWidget();
        }

        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _diaryListSlideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: _diaryListSlideAnimation.value,
                child: Column(
                  children: [
                    // 선택된 날짜 헤더
                    ScrollAnimations.scrollReveal(
                      direction: ScrollRevealDirection.top,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatSelectedDate(_selectedDay!),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${selectedDayDiaries.length}개의 일기',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 일기 목록
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: selectedDayDiaries.length,
                        itemBuilder: (context, index) {
                          final diary = selectedDayDiaries[index];
                          return ScrollAnimations.scrollReveal(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InteractionAnimations.tapFeedback(
                                onTap: () => _viewDiary(diary),
                                child: DiaryPreviewCard(
                                  diary: diary,
                                  onTap: () => _viewDiary(diary),
                                  onEdit: () => _editDiary(diary),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// 빈 날짜 위젯
  Widget _buildEmptyDayWidget() {
    return Center(
      child: ScrollAnimations.scrollScaleFade(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScrollAnimations.scrollReveal(
              direction: ScrollRevealDirection.bottom,
              child: Icon(
                Icons.event_note_outlined,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 16),
            ScrollAnimations.scrollFadeIn(
              child: Text(
                '이 날에는 일기가 없습니다',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            ScrollAnimations.scrollFadeIn(
              child: Text(
                _formatSelectedDate(_selectedDay!),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ScrollAnimations.scrollReveal(
              direction: ScrollRevealDirection.bottom,
              child: InteractionAnimations.bounceFeedback(
                onTap: _createDiaryForDate,
                child: ElevatedButton.icon(
                  onPressed: _createDiaryForDate,
                  icon: const Icon(Icons.add),
                  label: const Text('일기 작성하기'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 선택된 날짜 포맷팅
  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) {
      return '오늘 (${date.month}월 ${date.day}일)';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return '어제 (${date.month}월 ${date.day}일)';
    } else if (selected == today.add(const Duration(days: 1))) {
      return '내일 (${date.month}월 ${date.day}일)';
    } else {
      return '${date.year}년 ${date.month}월 ${date.day}일';
    }
  }
}
