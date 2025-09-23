import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/custom_card.dart';
import '../services/image_attachment_service.dart';

/// 이미지 첨부 위젯
class ImageAttachmentWidget extends ConsumerWidget {
  final ImageAttachmentService imageService;
  final VoidCallback? onImageAdded;
  final VoidCallback? onImageRemoved;

  const ImageAttachmentWidget({
    super.key,
    required this.imageService,
    this.onImageAdded,
    this.onImageRemoved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedBuilder(
      animation: imageService,
      builder: (context, child) {
        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  const Icon(Icons.photo_library, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '이미지 첨부',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (imageService.imageCount > 0)
                    Text(
                      '${imageService.imageCount}개',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // 이미지 선택 버튼들
              Row(
                children: [
                  Expanded(
                    child: _buildImagePickerButton(
                      context: context,
                      icon: Icons.photo_library,
                      label: '갤러리',
                      onTap: () => _pickFromGallery(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildImagePickerButton(
                      context: context,
                      icon: Icons.camera_alt,
                      label: '카메라',
                      onTap: () => _pickFromCamera(context),
                    ),
                  ),
                ],
              ),

              // 첨부된 이미지 목록
              if (imageService.attachedImages.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                _buildImageGrid(context),
              ],

              // 처리 중 표시
              if (imageService.isProcessing) ...[
                const SizedBox(height: 12),
                const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('이미지 처리 중...'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePickerButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: imageService.attachedImages.length,
      itemBuilder: (context, index) {
        final image = imageService.attachedImages[index];
        return _buildImageThumbnail(context, image, index);
      },
    );
  }

  Widget _buildImageThumbnail(
    BuildContext context,
    AttachedImage image,
    int index,
  ) {
    return Stack(
      children: [
        // 이미지 썸네일
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(image.localPath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
        ),

        // 삭제 버튼
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(context, image),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),

        // 이미지 정보
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Text(
              image.formattedFileSize,
              style: const TextStyle(color: Colors.white, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      await imageService.pickImageFromGallery();
      onImageAdded?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    try {
      await imageService.pickImageFromCamera();
      onImageAdded?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 촬영 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _removeImage(BuildContext context, AttachedImage image) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 삭제'),
        content: const Text('이 이미지를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              imageService.removeImage(image.id);
              onImageRemoved?.call();
              Navigator.of(context).pop();
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

/// 이미지 첨부 미리보기 위젯 (읽기 전용)
class ImageAttachmentPreview extends StatelessWidget {
  final List<AttachedImage> images;
  final void Function(AttachedImage)? onImageTap;

  const ImageAttachmentPreview({
    super.key,
    required this.images,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library, size: 20),
              const SizedBox(width: 8),
              Text(
                '첨부된 이미지 (${images.length}개)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              return _buildImageThumbnail(context, image);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(BuildContext context, AttachedImage image) {
    return GestureDetector(
      onTap: () => onImageTap?.call(image),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(image.localPath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              );
            },
          ),
        ),
      ),
    );
  }
}
