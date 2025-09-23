import 'package:flutter/material.dart';

/// 텍스트 편집 컨트롤 위젯
/// 텍스트 편집 관련 버튼들을 제공합니다.
class TextEditorControls extends StatelessWidget {
  final bool isEditing;
  final bool hasSelectedBlocks;
  final VoidCallback onEdit;
  final VoidCallback onFinish;
  final VoidCallback onCopy;
  final VoidCallback onSave;
  final VoidCallback onReset;

  const TextEditorControls({
    super.key,
    required this.isEditing,
    required this.hasSelectedBlocks,
    required this.onEdit,
    required this.onFinish,
    required this.onCopy,
    required this.onSave,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 편집 모드 버튼들
            if (!isEditing) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: hasSelectedBlocks ? onEdit : null,
                      icon: const Icon(Icons.edit),
                      label: const Text('선택된 블록 편집'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCopy,
                      icon: const Icon(Icons.copy),
                      label: const Text('복사'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // 편집 중일 때의 버튼들
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onFinish,
                      icon: const Icon(Icons.check),
                      label: const Text('편집 완료'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('취소'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // 저장 및 초기화 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.save),
                    label: const Text('일기에 저장'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.restore),
                  label: const Text('초기화'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),

            // 도움말 텍스트
            const SizedBox(height: 12),
            Text(
              isEditing
                  ? '텍스트를 편집한 후 "편집 완료"를 눌러주세요'
                  : '편집할 텍스트 블록을 선택한 후 "선택된 블록 편집"을 눌러주세요',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
