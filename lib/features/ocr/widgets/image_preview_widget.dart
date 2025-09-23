import 'package:flutter/material.dart';

import '../services/image_picker_service.dart';

/// 이미지 미리보기 위젯
/// 선택된 이미지를 미리보기하고 제거할 수 있는 위젯입니다.
class ImagePreviewWidget extends StatelessWidget {
  final ImagePickerResult image;
  final VoidCallback onRemove;
  final int index;

  const ImagePreviewWidget({
    super.key,
    required this.image,
    required this.onRemove,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 이미지 썸네일
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: image.file != null
                    ? Image.file(
                        image.file!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),
            ),

            const SizedBox(width: 12),

            // 이미지 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$index',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          image.name ?? '이미지',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    image.formattedSize,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  if (image.path != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      image.path!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),

            // 제거 버튼
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, color: Colors.red),
              tooltip: '제거',
            ),
          ],
        ),
      ),
    );
  }
}
