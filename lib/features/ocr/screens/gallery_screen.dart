import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/ocr_service.dart' as ocr_service;
import '../services/image_picker_service.dart';
import '../widgets/gallery_controls.dart';
import '../widgets/image_preview_widget.dart';
import 'text_editor_screen.dart';

/// 갤러리 화면
/// 갤러리에서 이미지를 선택하고 OCR 처리를 할 수 있는 화면입니다.
class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  final ImagePickerService _imagePickerService = ImagePickerService();
  final ocr_service.OCRService _ocrService = ocr_service.OCRService();

  List<ImagePickerResult> _selectedImages = [];
  bool _isProcessing = false;
  String _processingStatus = '';

  @override
  void initState() {
    super.initState();
    _initializeOCRService();
  }

  /// OCR 서비스 초기화
  Future<void> _initializeOCRService() async {
    try {
      debugPrint('🔍 OCR 서비스 초기화 시작');
      final success = await _ocrService.initialize();
      if (success) {
        debugPrint('🔍 OCR 서비스 초기화 성공');
        _ocrService.printDebugInfo();
      } else {
        debugPrint('🔍 OCR 서비스 초기화 실패');
        _showErrorDialog('OCR 서비스 초기화에 실패했습니다.');
      }
    } catch (e) {
      debugPrint('🔍 OCR 서비스 초기화 중 오류: $e');
      _showErrorDialog('OCR 서비스 초기화 중 오류가 발생했습니다: $e');
    }
  }

  /// 단일 이미지 선택
  Future<void> _pickSingleImage() async {
    setState(() {
      _isProcessing = true;
      _processingStatus = '이미지 선택 중...';
    });

    try {
      final result = await _imagePickerService.pickImageFromGallery(
        quality: ImageQuality.high,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (result != null && result.isSuccess) {
        setState(() {
          _selectedImages = [result];
          _processingStatus = '이미지가 선택되었습니다.';
        });
      } else if (result != null && result.isError) {
        _showErrorDialog(result.errorMessage ?? '이미지 선택 중 오류가 발생했습니다.');
      }
    } catch (e) {
      _showErrorDialog('이미지 선택 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// 다중 이미지 선택
  Future<void> _pickMultipleImages() async {
    setState(() {
      _isProcessing = true;
      _processingStatus = '이미지 선택 중...';
    });

    try {
      final results = await _imagePickerService.pickMultipleImages(
        quality: ImageQuality.high,
        maxWidth: 1920,
        maxHeight: 1920,
        limit: 5,
      );

      final successResults = results.where((r) => r.isSuccess).toList();

      if (successResults.isNotEmpty) {
        setState(() {
          _selectedImages = successResults;
          _processingStatus = '${successResults.length}개의 이미지가 선택되었습니다.';
        });
      } else if (results.any((r) => r.isError)) {
        final errorResult = results.firstWhere((r) => r.isError);
        _showErrorDialog(errorResult.errorMessage ?? '이미지 선택 중 오류가 발생했습니다.');
      }
    } catch (e) {
      _showErrorDialog('다중 이미지 선택 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// 선택된 이미지들에 OCR 처리 - 개선된 안전한 버전
  Future<void> _processSelectedImages() async {
    if (_selectedImages.isEmpty) {
      _showInfoDialog('처리할 이미지를 먼저 선택해주세요.');
      return;
    }

    // OCR 서비스 상태 확인 및 재초기화
    if (!_ocrService.isAvailable) {
      debugPrint('🔍 OCR 서비스 사용 불가, 재초기화 시도');
      _ocrService.printDebugInfo();

      try {
        final reinitialized = await _ocrService.reinitialize();
        if (!reinitialized) {
          _showErrorDialog('OCR 서비스를 사용할 수 없습니다. 앱을 재시작해주세요.');
          return;
        }
        debugPrint('🔍 OCR 서비스 재초기화 성공');
      } catch (e) {
        debugPrint('🔍 OCR 서비스 재초기화 실패: $e');
        _showErrorDialog('OCR 서비스를 사용할 수 없습니다. 앱을 재시작해주세요.');
        return;
      }
    }

    setState(() {
      _isProcessing = true;
      _processingStatus = 'OCR 처리 중...';
    });

    try {
      final ocrResults = <ocr_service.OCRResult>[];

      for (int i = 0; i < _selectedImages.length; i++) {
        final image = _selectedImages[i];
        if (image.isSuccess && image.bytes != null) {
          setState(() {
            _processingStatus =
                'OCR 처리 중... (${i + 1}/${_selectedImages.length})';
          });

          try {
            // 안전한 OCR 처리
            final result = await _ocrService.extractTextFromBytes(image.bytes!);

            // 결과 검증
            if (result.isValid) {
              ocrResults.add(result);
              debugPrint('🔍 이미지 ${i + 1} OCR 성공: ${result.safeText.length}자');
            } else {
              debugPrint('🔍 이미지 ${i + 1} OCR 결과 비어있음');
            }
          } catch (e) {
            debugPrint('🔍 이미지 ${i + 1} OCR 실패: $e');
            // 개별 이미지 실패는 무시하고 계속 진행
          }
        }
      }

      if (ocrResults.isNotEmpty) {
        // OCR 결과를 텍스트 편집 화면으로 전달
        _navigateToTextEditor(ocrResults);
      } else {
        _showErrorDialog('OCR 처리에 실패했습니다. 이미지에 텍스트가 없거나 인식할 수 없습니다.');
      }
    } catch (e) {
      debugPrint('🔍 OCR 처리 중 전체 오류: $e');
      _showErrorDialog('OCR 처리 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isProcessing = false;
        _processingStatus = '';
      });
    }
  }

  /// 선택된 이미지 제거
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /// 모든 이미지 제거
  void _clearAllImages() {
    setState(() {
      _selectedImages.clear();
    });
  }

  /// OCR 테스트용 이미지 생성
  Future<void> _createTestImage() async {
    setState(() {
      _isProcessing = true;
      _processingStatus = '테스트 이미지 생성 중...';
    });

    try {
      // 테스트용 텍스트
      const testText = '안녕하세요! 이것은 OCR 테스트입니다.\n한글과 영문이 함께 있는 텍스트입니다.';

      // OCR 서비스로 테스트 이미지 생성
      final testImageBytes = await _ocrService.createTestImage(testText);

      // ImagePickerResult 형태로 변환 (임시 파일 생성)
      final tempFile = File(
        '${Directory.systemTemp.path}/test_ocr_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await tempFile.writeAsBytes(testImageBytes);

      final testResult = ImagePickerResult.success(
        file: tempFile,
        bytes: testImageBytes,
        path: tempFile.path,
        name: 'test_ocr.png',
        size: testImageBytes.length,
      );

      setState(() {
        _selectedImages = [testResult];
        _processingStatus = '테스트 이미지가 생성되었습니다.';
      });

      debugPrint('🔍 테스트 이미지 생성 완료: ${testImageBytes.length} bytes');
    } catch (e) {
      debugPrint('🔍 테스트 이미지 생성 실패: $e');
      _showErrorDialog('테스트 이미지 생성에 실패했습니다: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// 텍스트 편집 화면으로 이동
  void _navigateToTextEditor(List<ocr_service.OCRResult> results) {
    if (results.isNotEmpty) {
      // 첫 번째 결과를 사용하여 텍스트 편집 화면으로 이동
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => TextEditorScreen(ocrResult: results.first),
        ),
      );
    }
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 정보 다이얼로그 표시
  void _showInfoDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정보'),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('갤러리에서 선택'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_selectedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearAllImages,
              tooltip: '모두 제거',
            ),
        ],
      ),
      body: Column(
        children: [
          // 처리 상태 표시
          if (_isProcessing || _processingStatus.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _isProcessing
                  ? Colors.orange.withValues(alpha: 0.1)
                  : Colors.green.withValues(alpha: 0.1),
              child: Row(
                children: [
                  if (_isProcessing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      _processingStatus.contains('오류')
                          ? Icons.error
                          : Icons.check,
                      color: _processingStatus.contains('오류')
                          ? Colors.red
                          : Colors.green,
                      size: 20,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _processingStatus,
                      style: TextStyle(
                        color: _processingStatus.contains('오류')
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 선택된 이미지 목록
          Expanded(
            child: _selectedImages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '이미지를 선택해주세요',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '단일 또는 다중 이미지 선택이 가능합니다',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      final image = _selectedImages[index];
                      return ImagePreviewWidget(
                        image: image,
                        onRemove: () => _removeImage(index),
                        index: index + 1,
                      );
                    },
                  ),
          ),

          // 컨트롤 버튼들
          GalleryControls(
            onPickSingle: _pickSingleImage,
            onPickMultiple: _pickMultipleImages,
            onProcessImages: _processSelectedImages,
            onCreateTestImage: _createTestImage,
            hasImages: _selectedImages.isNotEmpty,
            isProcessing: _isProcessing,
          ),
        ],
      ),
    );
  }
}
