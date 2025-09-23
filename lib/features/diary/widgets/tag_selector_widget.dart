import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_input_field.dart';
import '../services/tag_service.dart';

/// 태그 선택 위젯
class TagSelectorWidget extends ConsumerStatefulWidget {
  final TagService tagService;
  final VoidCallback? onTagsChanged;

  const TagSelectorWidget({
    super.key,
    required this.tagService,
    this.onTagsChanged,
  });

  @override
  ConsumerState<TagSelectorWidget> createState() => _TagSelectorWidgetState();
}

class _TagSelectorWidgetState extends ConsumerState<TagSelectorWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.tagService,
      builder: (context, child) {
        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  const Icon(Icons.tag, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '태그',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (widget.tagService.selectedTagCount > 0)
                    Text(
                      '${widget.tagService.selectedTagCount}개 선택됨',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // 검색 및 추가 버튼
              Row(
                children: [
                  Expanded(
                    child: CustomInputField(
                      controller: _searchController,
                      hintText: '태그 검색...',
                      prefixIcon: Icons.search,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _openAddTagDialog,
                    icon: const Icon(Icons.add),
                    tooltip: '새 태그 추가',
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 선택된 태그들
              if (widget.tagService.selectedTags.isNotEmpty) ...[
                _buildSelectedTags(),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
              ],

              // 태그 목록
              _buildTagList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.tagService.selectedTags.map((tag) {
        return _buildTagChip(
          tag: tag,
          isSelected: true,
          onTap: () => widget.tagService.deselectTag(tag.id),
        );
      }).toList(),
    );
  }

  Widget _buildTagList() {
    final tags = _searchQuery.isEmpty
        ? widget.tagService.allTags
        : widget.tagService.searchTags(_searchQuery);

    if (tags.isEmpty) {
      return _buildEmptyState();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        final isSelected = widget.tagService.selectedTags.any(
          (t) => t.id == tag.id,
        );
        return _buildTagChip(
          tag: tag,
          isSelected: isSelected,
          onTap: () => widget.tagService.toggleTagSelection(tag.id),
        );
      }).toList(),
    );
  }

  Widget _buildTagChip({
    required DiaryTag tag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? _parseColor(tag.color).withValues(alpha: 0.2)
              : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? _parseColor(tag.color) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _parseColor(tag.color),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              tag.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? _parseColor(tag.color)
                    : Colors.grey.shade700,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(Icons.check, size: 14, color: _parseColor(tag.color)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
      return Column(
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _openAddTagDialog,
            icon: const Icon(Icons.add),
            label: const Text('새 태그 추가'),
          ),
        ],
      );
    }

    return Column(
      children: [
        const Icon(Icons.tag, size: 48, color: Colors.grey),
        const SizedBox(height: 8),
        Text(
          '아직 태그가 없습니다',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _openAddTagDialog,
          icon: const Icon(Icons.add),
          label: const Text('첫 번째 태그 추가'),
        ),
      ],
    );
  }

  void _openAddTagDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => _AddTagDialog(
        onTagAdded: (name, color, description) {
          widget.tagService.addTag(
            name,
            color: color,
            description: description,
          );
          widget.onTagsChanged?.call();
        },
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
}

/// 태그 추가 다이얼로그
class _AddTagDialog extends StatefulWidget {
  final void Function(String name, String color, String? description)
  onTagAdded;

  const _AddTagDialog({required this.onTagAdded});

  @override
  State<_AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<_AddTagDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedColor = '#FF6B6B';

  final List<String> _colorOptions = [
    '#FF6B6B',
    '#4ECDC4',
    '#45B7D1',
    '#96CEB4',
    '#FFEAA7',
    '#DDA0DD',
    '#98D8C8',
    '#F7DC6F',
    '#BB8FCE',
    '#85C1E9',
    '#F8C471',
    '#82E0AA',
    '#F1948A',
    '#85C1E9',
    '#D7BDE2',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('새 태그 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 태그 이름
            CustomInputField(
              controller: _nameController,
              labelText: '태그 이름',
              hintText: '예: 여행, 일상, 감정',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '태그 이름을 입력해주세요';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 색상 선택
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '색상',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colorOptions.map((color) {
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _parseColor(color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.black
                                : Colors.grey.shade300,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 설명 (선택사항)
            CustomInputField(
              controller: _descriptionController,
              labelText: '설명 (선택사항)',
              hintText: '태그에 대한 설명을 입력하세요',
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(onPressed: _addTag, child: const Text('추가')),
      ],
    );
  }

  void _addTag() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('태그 이름을 입력해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final description = _descriptionController.text.trim();
    widget.onTagAdded(
      name,
      _selectedColor,
      description.isEmpty ? null : description,
    );
    Navigator.of(context).pop();
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
}
