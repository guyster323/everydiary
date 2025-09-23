import 'package:flutter/material.dart';

/// 갤러리 컨트롤 위젯
/// 이미지 선택 및 OCR 처리 버튼들을 제공합니다.
class GalleryControls extends StatelessWidget {
  final VoidCallback onPickSingle;
  final VoidCallback onPickMultiple;
  final VoidCallback onProcessImages;
  final VoidCallback? onCreateTestImage;
  final bool hasImages;
  final bool isProcessing;

  const GalleryControls({
    super.key,
    required this.onPickSingle,
    required this.onPickMultiple,
    required this.onProcessImages,
    required this.hasImages,
    this.onCreateTestImage,
    this.isProcessing = false,
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
            // 이미지 선택 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isProcessing ? null : onPickSingle,
                    icon: const Icon(Icons.photo),
                    label: const Text('단일 선택'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isProcessing ? null : onPickMultiple,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('다중 선택'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            // 테스트 이미지 생성 버튼
            if (onCreateTestImage != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isProcessing ? null : onCreateTestImage,
                  icon: const Icon(Icons.science),
                  label: const Text('OCR 테스트 이미지 생성'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Colors.blue,
                  ),
                ),
              ),
            ],

            // OCR 처리 버튼
            if (hasImages) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isProcessing ? null : onProcessImages,
                  icon: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.text_fields),
                  label: Text(isProcessing ? 'OCR 처리 중...' : 'OCR 처리 시작'),
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
            ],

            // 도움말 텍스트
            if (!hasImages) ...[
              const SizedBox(height: 12),
              Text(
                '이미지를 선택한 후 OCR 처리를 시작하세요',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
