import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animations/fade_in_animation.dart';
import '../../../core/animations/slide_in_animation.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_error_widget.dart';
import '../../../core/widgets/custom_loading.dart';
import '../models/diary_memory.dart';
import '../models/memory_filter.dart';
import '../services/memory_service.dart';
import '../widgets/memory_card.dart';
import '../widgets/memory_filter_bottom_sheet.dart';
import '../widgets/memory_type_selector.dart';

/// 회상 화면
class MemoryScreen extends ConsumerStatefulWidget {
  const MemoryScreen({super.key});

  @override
  ConsumerState<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends ConsumerState<MemoryScreen>
    with TickerProviderStateMixin {
  final MemoryService _memoryService = MemoryService();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _fadeController;
  late AnimationController _slideController;

  MemoryResult? _memoryResult;
  bool _isLoading = false;
  String? _error;
  MemoryFilter _currentFilter = const MemoryFilter();
  MemoryType? _selectedMemoryType;
  final Set<String> _bookmarkedMemories = <String>{};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadMemories();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadMemories() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 실제 사용자 ID를 가져오기 (임시로 1 사용)
      const userId = '1';

      final result = await _memoryService.generateMemories(
        userId: userId,
        filter: _currentFilter,
      );

      setState(() {
        _memoryResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshMemories() async {
    await _loadMemories();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MemoryFilterBottomSheet(
        currentFilter: _currentFilter,
        onFilterChanged: (newFilter) {
          setState(() {
            _currentFilter = newFilter;
          });
          _loadMemories();
        },
      ),
    );
  }

  void _onMemoryTypeSelected(MemoryType? type) {
    setState(() {
      _selectedMemoryType = type;
      if (type != null) {
        _currentFilter = _currentFilter.copyWith(allowedTypes: [type]);
      } else {
        _currentFilter = _currentFilter.copyWith(allowedTypes: []);
      }
    });
    _loadMemories();
  }

  void _onMemoryTap(DiaryMemory memory) {
    // 일기 상세 화면으로 이동
    context.push('/diary/${memory.diaryId}');
  }

  void _onMemoryBookmark(DiaryMemory memory) {
    // 북마크 기능 구현
    setState(() {
      if (_bookmarkedMemories.contains(memory.id)) {
        _bookmarkedMemories.remove(memory.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${memory.title} 북마크를 해제했습니다'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _bookmarkedMemories.add(memory.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${memory.title}을(를) 북마크했습니다'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '회상',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: '뒤로가기',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push('/memory/notification-settings'),
            tooltip: '알림 설정',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
            tooltip: '필터',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMemories,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Column(
        children: [
          // 회상 유형 선택기
          FadeInAnimation(
            controller: _fadeController,
            child: MemoryTypeSelector(
              selectedType: _selectedMemoryType,
              onTypeSelected: _onMemoryTypeSelected,
            ),
          ),

          // 회상 목록
          Expanded(child: _buildMemoryList()),
        ],
      ),
    );
  }

  Widget _buildMemoryList() {
    if (_isLoading) {
      return const Center(child: CustomLoading(message: '회상을 불러오는 중...'));
    }

    if (_error != null) {
      return CustomErrorWidget(
        message: '회상을 불러오는데 실패했습니다',
        error: _error!,
        onRetry: _loadMemories,
      );
    }

    if (_memoryResult == null || _memoryResult!.memories.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshMemories,
      child: SlideInAnimation(
        controller: _slideController,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _memoryResult!.memories.length,
          itemBuilder: (context, index) {
            final memory = _memoryResult!.memories[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MemoryCard(
                memory: memory,
                onTap: () => _onMemoryTap(memory),
                onBookmark: () => _onMemoryBookmark(memory),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '아직 회상할 일기가 없습니다',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '일기를 작성하면 과거 기록을 회상할 수 있습니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/diary/write'),
            icon: const Icon(Icons.edit),
            label: const Text('일기 작성하기'),
          ),
        ],
      ),
    );
  }
}
