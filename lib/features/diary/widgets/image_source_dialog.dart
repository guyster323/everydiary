import 'package:flutter/material.dart';

/// 이미지 소스 선택 다이얼로그
/// 카메라, 갤러리, OCR 기능을 선택할 수 있는 다이얼로그
class ImageSourceDialog extends StatelessWidget {
  final VoidCallback? onCamera;
  final VoidCallback? onGallery;
  final VoidCallback? onOCR;

  const ImageSourceDialog({
    super.key,
    this.onCamera,
    this.onGallery,
    this.onOCR,
  });

  /// 다이얼로그 표시
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onCamera,
    VoidCallback? onGallery,
    VoidCallback? onOCR,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ImageSourceDialog(
        onCamera: onCamera,
        onGallery: onGallery,
        onOCR: onOCR,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들 바
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          // 제목
          Text(
            '이미지 선택',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          // 옵션 버튼들
          Row(
            children: [
              // 카메라
              Expanded(
                child: _buildOptionButton(
                  context: context,
                  icon: Icons.camera_alt,
                  label: '카메라',
                  description: '사진 촬영',
                  onTap: () {
                    Navigator.of(context).pop();
                    onCamera?.call();
                  },
                ),
              ),

              const SizedBox(width: 16),

              // 갤러리
              Expanded(
                child: _buildOptionButton(
                  context: context,
                  icon: Icons.photo_library,
                  label: '갤러리',
                  description: '이미지 선택',
                  onTap: () {
                    Navigator.of(context).pop();
                    onGallery?.call();
                  },
                ),
              ),

              const SizedBox(width: 16),

              // OCR
              Expanded(
                child: _buildOptionButton(
                  context: context,
                  icon: Icons.text_fields,
                  label: 'OCR',
                  description: '텍스트 인식',
                  onTap: () {
                    Navigator.of(context).pop();
                    onOCR?.call();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 취소 버튼
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
