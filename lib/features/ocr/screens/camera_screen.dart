import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/providers/ocr_provider.dart';
import '../../../shared/services/ocr_service.dart' as ocr_service;
import 'gallery_screen.dart';
import 'text_editor_screen.dart';

/// OCR 카메라 화면
/// 기기의 기본 카메라 앱을 사용하여 고화질 사진을 촬영하고 텍스트를 인식합니다.
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final ocr_service.OCRService _ocrService = ocr_service.OCRService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 자동으로 카메라 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _takePictureWithNativeCamera();
    });
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  /// 기기 기본 카메라 앱으로 사진 촬영
  Future<void> _takePictureWithNativeCamera() async {
    if (_isProcessing) return;

    try {
      // 기기 기본 카메라 앱 실행 (최대 화질)
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // 최대 화질
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) {
        // 사용자가 취소한 경우 이전 화면으로
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }

      await _processImage(image);
    } catch (e) {
      if (mounted) {
        _showErrorDialog('카메라 실행 중 오류가 발생했습니다: $e');
      }
    }
  }

  /// 이미지 OCR 처리
  Future<void> _processImage(XFile image) async {
    if (_isProcessing || !mounted) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final file = File(image.path);
      final imageBytes = await file.readAsBytes();

      // 이미지 크기 확인
      if (imageBytes.length > 15 * 1024 * 1024) {
        _showErrorDialog('이미지가 너무 큽니다. (최대 15MB)');
        return;
      }

      // OCR 처리 (타임아웃 설정)
      final result = await _ocrService
          .extractTextFromBytes(imageBytes)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('OCR 처리 시간이 초과되었습니다.');
            },
          );

      if (mounted) {
        // OCR 결과를 프로바이더에 저장
        ref.read(oCRResultStateProvider.notifier).setResult(result);

        // 텍스트 편집 화면으로 이동
        _navigateToTextEditor(result);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = '텍스트 인식 중 오류가 발생했습니다.';
        if (e.toString().contains('시간이 초과')) {
          errorMessage = '처리 시간이 초과되었습니다. 다시 시도해주세요.';
        } else if (e.toString().contains('메모리')) {
          errorMessage = '메모리 부족으로 처리할 수 없습니다.';
        }
        _showErrorDialog(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// 갤러리에서 이미지 선택
  Future<void> _pickImageFromGallery() async {
    try {
      // 갤러리 화면으로 이동
      final result = await Navigator.of(context).push<ocr_service.OCRResult>(
        MaterialPageRoute(builder: (context) => const GalleryScreen()),
      );

      if (result != null && mounted) {
        // OCR 결과를 텍스트 편집 화면으로 전달
        _navigateToTextEditor(result);
      }
    } catch (e) {
      _showErrorDialog('갤러리 접근 중 오류가 발생했습니다: $e');
    }
  }

  /// 텍스트 편집 화면으로 이동
  void _navigateToTextEditor(ocr_service.OCRResult result) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => TextEditorScreen(ocrResult: result),
      ),
    );
  }

  /// 에러 다이얼로그 표시
  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // 이전 화면으로 돌아가기
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('OCR 텍스트 인식'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: _isProcessing
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 24),
                  Text(
                    '텍스트를 인식하는 중...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '고화질 이미지는 처리 시간이 오래 걸릴 수 있습니다.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.document_scanner_outlined,
                    size: 64,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'OCR 텍스트 인식',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '사진을 촬영하거나 갤러리에서 선택하세요',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _takePictureWithNativeCamera,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('카메라'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: _pickImageFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('갤러리'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
