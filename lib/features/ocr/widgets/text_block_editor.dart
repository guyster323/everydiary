import 'package:flutter/material.dart';

import '../screens/text_editor_screen.dart';

/// 텍스트 블록 편집 위젯
/// 개별 텍스트 블록을 표시하고 편집할 수 있는 위젯입니다.
class TextBlockEditor extends StatelessWidget {
  final TextBlock block;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const TextBlockEditor({
    super.key,
    required this.block,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: block.isSelected ? 4 : 1,
      color: block.isSelected
          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 (신뢰도 및 편집 버튼)
              Row(
                children: [
                  // 신뢰도 표시
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(block.confidence),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(block.confidence * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 선택 상태 표시
                  if (block.isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '선택됨',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // 편집 버튼
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    iconSize: 20,
                    tooltip: '편집',
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 텍스트 내용
              Text(
                block.text,
                style: TextStyle(
                  fontSize: 14,
                  color: block.isSelected
                      ? Theme.of(context).primaryColor
                      : null,
                  fontWeight: block.isSelected
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),

              // 텍스트 길이 정보
              const SizedBox(height: 4),
              Text(
                '${block.text.length}자',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 신뢰도에 따른 색상 반환
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
