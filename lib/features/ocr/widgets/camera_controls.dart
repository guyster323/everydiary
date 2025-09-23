import 'package:flutter/material.dart';

/// 카메라 컨트롤 위젯
/// 촬영 버튼과 갤러리 접근 버튼을 제공합니다.
class CameraControls extends StatelessWidget {
  final VoidCallback onTakePicture;
  final VoidCallback onPickFromGallery;
  final bool isProcessing;

  const CameraControls({
    super.key,
    required this.onTakePicture,
    required this.onPickFromGallery,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 갤러리 버튼
            _buildGalleryButton(),

            // 촬영 버튼
            _buildCaptureButton(),

            // 플레이스홀더 (대칭을 위해)
            const SizedBox(width: 60),
          ],
        ),
      ),
    );
  }

  /// 갤러리 버튼 빌드
  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: isProcessing ? null : onPickFromGallery,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
        ),
        child: Icon(
          Icons.photo_library,
          color: isProcessing ? Colors.white.withValues(alpha: 0.5) : Colors.white,
          size: 30,
        ),
      ),
    );
  }

  /// 촬영 버튼 빌드
  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: isProcessing ? null : onTakePicture,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isProcessing ? Colors.grey.withValues(alpha: 0.5) : Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: isProcessing
                ? Colors.grey.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.3),
            width: 4,
          ),
        ),
        child: isProcessing
            ? const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 3,
                  ),
                ),
              )
            : const Center(
                child: Icon(Icons.camera_alt, color: Colors.black, size: 40),
              ),
      ),
    );
  }
}
