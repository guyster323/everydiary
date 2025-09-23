import 'package:flutter/material.dart';

/// 프로필 이미지 선택기 위젯
/// 카메라 또는 갤러리에서 이미지를 선택할 수 있는 위젯입니다.
class ProfileImagePicker extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onRemoveTap;

  const ProfileImagePicker({
    super.key,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 제목
          Text(
            '프로필 이미지 선택',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          // 옵션들
          _buildOption(
            context,
            icon: Icons.camera_alt,
            title: '카메라로 촬영',
            subtitle: '새로운 사진을 촬영합니다',
            onTap: onCameraTap,
          ),

          const SizedBox(height: 16),

          _buildOption(
            context,
            icon: Icons.photo_library,
            title: '갤러리에서 선택',
            subtitle: '기존 사진을 선택합니다',
            onTap: onGalleryTap,
          ),

          const SizedBox(height: 16),

          _buildOption(
            context,
            icon: Icons.delete_outline,
            title: '이미지 제거',
            subtitle: '현재 프로필 이미지를 제거합니다',
            onTap: onRemoveTap,
            isDestructive: true,
          ),

          const SizedBox(height: 24),

          // 취소 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = isDestructive ? Colors.red : colorScheme.primary;
    final textColor = isDestructive ? Colors.red : colorScheme.onSurface;

    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
