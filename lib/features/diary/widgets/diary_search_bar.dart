import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/localization_provider.dart';

/// 일기 검색바 위젯
class DiarySearchBar extends ConsumerStatefulWidget {
  final void Function(String) onSearchChanged;
  final String initialValue;

  const DiarySearchBar({
    super.key,
    required this.onSearchChanged,
    this.initialValue = '',
  });

  @override
  ConsumerState<DiarySearchBar> createState() => _DiarySearchBarState();
}

class _DiarySearchBarState extends ConsumerState<DiarySearchBar> {
  late TextEditingController _controller;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _isSearching = widget.initialValue.isNotEmpty;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 검색 실행
  void _performSearch(String query) {
    widget.onSearchChanged(query);
    setState(() {
      _isSearching = query.isNotEmpty;
    });
  }

  /// 검색 취소
  void _clearSearch() {
    _controller.clear();
    _performSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(localizationProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 검색 아이콘
          Icon(
            Icons.search,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),

          // 검색 입력 필드
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: l10n.get('diary_search_hint'),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              onChanged: _performSearch,
              onSubmitted: _performSearch,
            ),
          ),

          // 검색 취소 버튼
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
              tooltip: l10n.get('clear_search_tooltip'),
              iconSize: 20,
            ),
        ],
      ),
    );
  }
}
