import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// 카메라 프리뷰 위젯
class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;

  const CameraPreviewWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize?.height ?? 0,
          height: controller.value.previewSize?.width ?? 0,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

