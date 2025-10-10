import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animations/animations.dart';
import '../../../core/layout/responsive_widgets.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_loading.dart';
import '../../../shared/models/diary_entry.dart';
import '../../../shared/services/database_service.dart';
import '../../../shared/services/repositories/diary_repository.dart';
import '../services/diary_list_service.dart';
import '../widgets/diary_card.dart';
import '../widgets/diary_filter_dialog.dart';
import '../widgets/diary_search_bar.dart';

/// 일기 목록 화면
class DiaryListScreen extends ConsumerStatefulWidget {
  const DiaryListScreen({super.key});

  @override
  ConsumerState<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends ConsumerState<DiaryListScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late DiaryListService _diaryListService;
  final ScrollController _scrollController = ScrollController();
  late final StreamSubscription<void> _refreshSubscription;

  // 애니메이션 컨트롤러들
  late AnimationController _listAnimationController;
  late Animation<double> _listFadeAnimation;

  @override
  void initState() {
    super.initState();

    // DiaryListService 초기화
    _diaryListService = DiaryListService(
      databaseService: DatabaseService(), // 향후 싱글톤 인스턴스 사용 예정
      diaryRepository: DiaryRepository(DatabaseService()), // 향후 싱글톤 인스턴스 사용 예정
    );

    // 일기 목록 로드
    _loadDiaries();

    // 애니메이션 컨트롤러 초기화
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // 스크롤 리스너 추가 (무한 스크롤)
    _scrollController.addListener(_onScroll);

    // 초기 데이터 로드
    _diaryListService.loadDiaries();

    _refreshSubscription = DiaryListRefreshNotifier().refreshStream.listen((_) {
      if (!mounted) {
        return;
      }
      _loadDiaries();
    });

    // 애니메이션 시작
    _listAnimationController.forward();

    // 앱 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 다시 표시될 때마다 일기 목록 새로고침
    _loadDiaries();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 일기 목록 새로고침
      _loadDiaries();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _diaryListService.dispose();
    _listAnimationController.dispose();
    _refreshSubscription.cancel();
    // 앱 생명주기 관찰자 해제
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 일기 목록 로드
  Future<void> _loadDiaries() async {
    await _diaryListService.loadDiaries(refresh: true);
  }

  /// 스크롤 이벤트 처리 (무한 스크롤)
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _diaryListService.loadMoreDiaries();
    }
  }

  /// 새 일기 작성
  void _createNewDiary() async {
    final result = await context.push('/diary/write');
    // 일기 작성 후 돌아왔을 때 새로고침
    if (result == true) {
      _loadDiaries();
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

  /// 일기 삭제 확인
  void _confirmDeleteDiary(DiaryEntry diary) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일기 삭제'),
        content: const Text('이 일기를 삭제하시겠습니까?\n삭제된 일기는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _diaryListService.deleteDiary(diary.id!);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 즐겨찾기 토글
  void _toggleFavorite(DiaryEntry diary) {
    _diaryListService.toggleFavorite(diary.id!);
  }

  /// 필터 다이얼로그 표시
  void _showFilterDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => DiaryFilterDialog(
        currentFilter: _diaryListService.filter,
        onFilterApplied: (filter) {
          _diaryListService.applyFilter(filter);
        },
      ),
    );
  }

  /// 정렬 옵션 변경
  void _showSortOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _buildSortBottomSheet(),
    );
  }

  /// 정렬 바텀시트
  Widget _buildSortBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '정렬 기준',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...DiarySortOption.values.map(
            (option) => ListTile(
              title: Text(_getSortOptionName(option)),
              leading: Radio<DiarySortOption>(
                value: option,
                // ignore: deprecated_member_use
                groupValue: _diaryListService.sortOption,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  if (value != null) {
                    _diaryListService.setSortOption(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 정렬 옵션 이름
  String _getSortOptionName(DiarySortOption option) {
    switch (option) {
      case DiarySortOption.dateDesc:
        return '최신순';
      case DiarySortOption.dateAsc:
        return '오래된순';
      case DiarySortOption.titleAsc:
        return '제목순 (A-Z)';
      case DiarySortOption.titleDesc:
        return '제목순 (Z-A)';
      case DiarySortOption.mood:
        return '기분순';
      case DiarySortOption.weather:
        return '날씨순';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '내 일기',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: '뒤로가기',
        ),
        actions: [
          // 캘린더 버튼
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => context.go('/diary/calendar'),
            tooltip: '캘린더 보기',
          ),

          // 필터 버튼
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_diaryListService.filter.hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterDialog,
            tooltip: '필터',
          ),

          // 정렬 버튼
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: '정렬',
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: Column(
          children: [
            // 검색바
            DiarySearchBar(
              onSearchChanged: _diaryListService.searchDiaries,
              initialValue: _diaryListService.searchQuery,
            ),

            // 일기 목록
            Expanded(child: _buildDiaryList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewDiary,
        tooltip: '새 일기 작성',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 일기 목록 빌드
  Widget _buildDiaryList() {
    return ListenableBuilder(
      listenable: _diaryListService,
      builder: (context, child) {
        if (_diaryListService.isLoading && _diaryListService.diaries.isEmpty) {
          return const Center(child: CustomLoading());
        }

        if (_diaryListService.error != null) {
          return _buildErrorWidget();
        }

        if (_diaryListService.diaries.isEmpty) {
          return _buildEmptyWidget();
        }

        return RefreshIndicator(
          onRefresh: _diaryListService.refresh,
          child: ResponsiveWidgets.responsive(
            mobile: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  _diaryListService.diaries.length +
                  (_diaryListService.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _diaryListService.diaries.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final diary = _diaryListService.diaries[index];
                return ScrollAnimations.scrollReveal(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InteractionAnimations.tapFeedback(
                      onTap: () => _viewDiary(diary),
                      child: FadeTransition(
                        opacity: _listFadeAnimation,
                        child: DiaryCard(
                          diary: diary,
                          onTap: () => _viewDiary(diary),
                          onEdit: () => _editDiary(diary),
                          onDelete: () => _confirmDeleteDiary(diary),
                          onToggleFavorite: () => _toggleFavorite(diary),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            tablet: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount:
                  _diaryListService.diaries.length +
                  (_diaryListService.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _diaryListService.diaries.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final diary = _diaryListService.diaries[index];
                return DiaryCard(
                  diary: diary,
                  onTap: () => _viewDiary(diary),
                  onEdit: () => _editDiary(diary),
                  onDelete: () => _confirmDeleteDiary(diary),
                  onToggleFavorite: () => _toggleFavorite(diary),
                );
              },
            ),
            desktop: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount:
                  _diaryListService.diaries.length +
                  (_diaryListService.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _diaryListService.diaries.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final diary = _diaryListService.diaries[index];
                return DiaryCard(
                  diary: diary,
                  onTap: () => _viewDiary(diary),
                  onEdit: () => _editDiary(diary),
                  onDelete: () => _confirmDeleteDiary(diary),
                  onToggleFavorite: () => _toggleFavorite(diary),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// 에러 위젯
  Widget _buildErrorWidget() {
    return Center(
      child: ScrollAnimations.scrollScaleFade(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScrollAnimations.scrollReveal(
              direction: ScrollRevealDirection.bottom,
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ScrollAnimations.scrollFadeIn(
              child: Text(
                '일기를 불러올 수 없습니다',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            ScrollAnimations.scrollFadeIn(
              child: Text(
                _diaryListService.error ?? '알 수 없는 오류가 발생했습니다',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ScrollAnimations.scrollReveal(
              direction: ScrollRevealDirection.bottom,
              child: InteractionAnimations.pulseFeedback(
                onTap: _diaryListService.refresh,
                child: ElevatedButton(
                  onPressed: _diaryListService.refresh,
                  child: const Text('다시 시도'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyWidget() {
    return Center(
      child: ScrollAnimations.scrollScaleFade(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScrollAnimations.scrollReveal(
              direction: ScrollRevealDirection.bottom,
              child: const Icon(
                Icons.book_outlined,
                size: 64,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ScrollAnimations.scrollFadeIn(
              child: Text(
                '아직 작성한 일기가 없습니다',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            ScrollAnimations.scrollFadeIn(
              child: Text(
                '첫 번째 일기를 작성해보세요',
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
                onTap: _createNewDiary,
                child: ElevatedButton.icon(
                  onPressed: _createNewDiary,
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
}
