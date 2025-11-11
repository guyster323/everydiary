import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animations/fade_in_animation.dart';
import '../../../core/animations/slide_in_animation.dart';
import '../../../core/providers/localization_provider.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_loading.dart';
import '../../../shared/services/session_service.dart';
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
      // SessionService에서 현재 사용자 ID를 가져오기
      final sessionService = SessionService.instance;
      final user = await sessionService.getCurrentUser();

      // 사용자가 없거나 ID가 없으면 기본값 1 사용 (게스트 모드)
      final userId = user?.id?.toString() ?? '1';

      final result = await _memoryService.generateMemories(
        userId: userId,
        filter: _currentFilter,
      );

      if (mounted) {
        setState(() {
          _memoryResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
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
    final l10n = ref.read(localizationProvider);
    // 북마크 기능 구현
    setState(() {
      if (_bookmarkedMemories.contains(memory.id)) {
        _bookmarkedMemories.remove(memory.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.get('memory_bookmark_removed').replaceAll('{title}', memory.title)),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _bookmarkedMemories.add(memory.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.get('memory_bookmarked').replaceAll('{title}', memory.title)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(localizationProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: l10n.get('memory_title'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
            tooltip: l10n.get('memory_back_tooltip'),
          ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push('/memory/notification-settings'),
            tooltip: l10n.get('memory_notifications_tooltip'),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
            tooltip: l10n.get('memory_filter_tooltip'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMemories,
            tooltip: l10n.get('memory_refresh_tooltip'),
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
      ),
    );
  }

  Widget _buildMemoryList() {
    final l10n = ref.watch(localizationProvider);
    if (_isLoading) {
      return Center(child: CustomLoading(message: l10n.get('memory_loading')));
    }

    if (_error != null) {
      return _buildErrorState();
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

  Widget _buildErrorState() {
    final l10n = ref.read(localizationProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              l10n.get('memory_load_failed'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? l10n.get('memory_unknown_error'),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadMemories,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.get('memory_retry_button')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = ref.read(localizationProvider);
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
            l10n.get('memory_empty_title'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.get('memory_empty_description'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/diary/write'),
            icon: const Icon(Icons.edit),
            label: Text(l10n.get('memory_write_diary_button')),
          ),
        ],
      ),
    );
  }
}
