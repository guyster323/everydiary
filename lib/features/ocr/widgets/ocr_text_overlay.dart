import 'package:flutter/material.dart';

/// OCR 텍스트 오버레이 위젯
/// 카메라 프리뷰 위에 인식된 텍스트를 표시합니다.
class OCRTextOverlay extends StatelessWidget {
  final String text;
  final bool isProcessing;

  const OCRTextOverlay({
    super.key,
    required this.text,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isProcessing ? Colors.orange : Colors.green,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isProcessing ? Icons.sync : Icons.text_fields,
                  color: isProcessing ? Colors.orange : Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  isProcessing ? '텍스트 인식 중...' : '인식된 텍스트',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
