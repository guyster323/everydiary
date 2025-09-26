import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/services/ocr_service.dart' as ocr_service;

const List<ocr_service.OCRLanguageOption> _languageOptions =
    ocr_service.kSupportedOcrLanguages;

/// 간단한 카메라 화면 (안정성 우선)
class SimpleCameraScreen extends StatefulWidget {
  const SimpleCameraScreen({super.key});

  @override
  State<SimpleCameraScreen> createState() => _SimpleCameraScreenState();
}

class _SimpleCameraScreenState extends State<SimpleCameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isLoading = false;
  final ocr_service.OCRService _ocrService = ocr_service.OCRService();
  bool _isProcessingOCR = false;
  ocr_service.OCRLanguageOption _selectedLanguage = _languageOptions.first;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeOCR();
  }

  /// OCR 서비스 초기화
  Future<void> _initializeOCR() async {
    try {
      // 안전한 초기화 - 타임아웃 설정
      await _ocrService
          .initialize(language: _selectedLanguage)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('📷 OCR 서비스 초기화 타임아웃');
              throw Exception('OCR 서비스 초기화 타임아웃');
            },
          );
      debugPrint('📷 OCR 서비스 초기화 완료');
    } catch (e) {
      debugPrint('📷 OCR 서비스 초기화 실패: $e');
      // 초기화 실패 시에도 앱이 크래시되지 않도록 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OCR 서비스 초기화 실패: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _onLanguageChanged(ocr_service.OCRLanguageOption? option) {
    if (option == null || option.code == _selectedLanguage.code) {
      return;
    }
    setState(() {
      _selectedLanguage = option;
    });
    _ocrService.initialize(language: _selectedLanguage);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  /// 카메라 초기화 (완전히 안전한 버전)
  Future<void> _initializeCamera() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
      });

      // 카메라 권한 확인
      try {
        _cameras = await availableCameras();
        if (_cameras.isEmpty) {
          if (mounted) {
            _showErrorDialog('카메라를 찾을 수 없습니다.');
          }
          return;
        }
      } catch (e) {
        debugPrint('카메라 목록 조회 실패: $e');
        if (mounted) {
          _showErrorDialog('카메라에 접근할 수 없습니다. 권한을 확인해주세요.');
        }
        return;
      }

      // 카메라 컨트롤러 생성
      try {
        _cameraController = CameraController(
          _cameras.first,
          ResolutionPreset.low, // 안정성을 위해 low로 변경
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        // 초기화 타임아웃 설정
        await _cameraController!.initialize().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception('카메라 초기화 시간 초과');
          },
        );
      } catch (e) {
        debugPrint('카메라 컨트롤러 초기화 실패: $e');
        if (mounted) {
          _showErrorDialog('카메라를 초기화할 수 없습니다: ${e.toString()}');
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
        debugPrint('📷 카메라 초기화 완료');
      }
    } catch (e) {
      debugPrint('카메라 초기화 전체 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialized = false;
        });
        _showErrorDialog('카메라 초기화 중 오류가 발생했습니다: ${e.toString()}');
      }
    }
  }

  /// 사진 촬영
  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _isProcessingOCR = true;
      });

      final image = await _cameraController!.takePicture();

      final bytes = await image.readAsBytes();
      await _processImageBytesWithOCR(
        bytes,
        sourcePath: image.path,
        sourceDescription: 'camera:${image.name}',
      );
    } catch (e) {
      debugPrint('사진 촬영 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isProcessingOCR = false;
        });
        _showErrorDialog('사진 촬영 중 오류가 발생했습니다: $e');
      }
    }
  }

  /// 갤러리에서 이미지 선택
  Future<void> _pickFromGallery() async {
    try {
      setState(() {
        _isLoading = true;
        _isProcessingOCR = true;
      });

      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        final bytes = await image.readAsBytes();
        await _processImageBytesWithOCR(
          bytes,
          sourcePath: image.path,
          sourceDescription: 'gallery:${image.name}',
        );
      } else {
        setState(() {
          _isLoading = false;
          _isProcessingOCR = false;
        });
      }
    } catch (e) {
      debugPrint('갤러리 선택 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isProcessingOCR = false;
        });
        _showErrorDialog('갤러리에서 이미지를 선택할 수 없습니다: $e');
      }
    }
  }

  /// 이미지 OCR 처리 (안정성 개선)
  Future<void> _processImageBytesWithOCR(
    Uint8List originalBytes, {
    String? sourcePath,
    required String sourceDescription,
  }) async {
    if (!mounted) return;

    debugPrint('📷 OCR 처리 시작: ${sourcePath ?? sourceDescription}');

    try {
      setState(() {
        _isLoading = true;
        _isProcessingOCR = true;
      });

      debugPrint('📷 OCR 상태: 로딩 시작');

      if (originalBytes.isEmpty) {
        throw const ocr_service.OCRException('이미지 데이터가 비어있습니다.');
      }

      final fileSizeMb = originalBytes.length / 1024 / 1024;
      debugPrint('📷 파일 크기: ${fileSizeMb.toStringAsFixed(2)}MB');

      const maxBytes = 6 * 1024 * 1024;
      if (originalBytes.length > maxBytes) {
        throw ocr_service.OCRException(
          '이미지 파일이 너무 큽니다. (최대 ${(maxBytes / (1024 * 1024)).toStringAsFixed(1)}MB)',
        );
      }

      debugPrint('📷 OCR 서비스 초기화 중...');
      await _ocrService
          .initialize(language: _selectedLanguage)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw const ocr_service.OCRException('OCR 서비스 초기화 시간이 초과되었습니다.');
            },
          );

      String resultText = '';
      try {
        final processedBytes = await _ocrService.preprocessImage(
          originalBytes,
          language: _selectedLanguage,
        );
        final processedResult = await _ocrService.extractTextFromBytes(
          processedBytes,
          language: _selectedLanguage,
        );
        resultText = processedResult.safeText.trim();

        if (resultText.isEmpty && sourcePath != null) {
          debugPrint('📷 OCR 결과가 비어있음 - 원본 파일로 재시도: $sourcePath');
          final fallbackResult = await _ocrService.extractTextFromFile(
            sourcePath,
            language: _selectedLanguage,
          );
          resultText = fallbackResult.safeText.trim();
        }

        debugPrint('📷 OCR 결과 길이: ${resultText.length}자');
        if (resultText.isNotEmpty && resultText.length < 200) {
          debugPrint('📷 OCR 결과: $resultText');
        }
      } on ocr_service.OCRException catch (ocrError) {
        debugPrint('📷 OCR 처리 중 사용자 정의 오류: ${ocrError.message}');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isProcessingOCR = false;
          });
          _showErrorDialog('❌ ${ocrError.message}');
        }
        return;
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isProcessingOCR = false;
      });

      // OCR 결과 검증 - 의미있는 텍스트인지 확인
      if (resultText.isNotEmpty &&
          resultText.trim() != '.' &&
          resultText.trim().length >= 2 &&
          !_isMeaninglessText(resultText)) {
        Navigator.of(context).pop(resultText);
      } else {
        debugPrint('🔍 OCR 결과가 의미없음: "$resultText" (길이: ${resultText.length})');
        _showErrorDialog('텍스트를 인식할 수 없습니다. 더 선명한 이미지를 선택해주세요.');
      }
    } catch (e) {
      debugPrint('OCR 처리 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isProcessingOCR = false;
        });

        String errorMessage = '텍스트 인식 중 문제가 발생했습니다.';
        if (e.toString().contains('시간이 초과') ||
            e.toString().contains('timeout')) {
          errorMessage =
              '⏰ 처리 시간이 초과되었습니다.\n\n• 더 작은 이미지를 선택해보세요\n• 네트워크 연결을 확인해보세요\n• 잠시 후 다시 시도해보세요';
        } else if (e.toString().contains('메모리') ||
            e.toString().contains('memory')) {
          errorMessage =
              '💾 메모리 부족으로 처리할 수 없습니다.\n\n• 더 작은 이미지를 선택해보세요\n• 앱을 재시작한 후 다시 시도해보세요';
        } else if (e.toString().contains('너무 큽니다') ||
            e.toString().contains('too large')) {
          errorMessage =
              '📏 이미지 파일이 너무 큽니다.\n\n• 최대 6MB 이하의 이미지를 선택해주세요\n• 이미지 크기를 줄여서 다시 시도해보세요';
        } else if (e.toString().contains('네트워크') ||
            e.toString().contains('network')) {
          errorMessage =
              '🌐 네트워크 연결에 문제가 있습니다.\n\n• 인터넷 연결을 확인해주세요\n• 잠시 후 다시 시도해보세요';
        } else if (e is ocr_service.OCRException) {
          errorMessage = '❌ ${e.message}';
        } else {
          errorMessage =
              '❌ 텍스트 인식에 실패했습니다.\n\n• 다른 이미지를 시도해보세요\n• 이미지가 선명한지 확인해보세요\n• 잠시 후 다시 시도해보세요';
        }

        _showErrorDialog(errorMessage);
      }
    } finally {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {});
          }
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('사진 촬영'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    _isProcessingOCR ? 'OCR 처리 중...' : '카메라를 초기화하는 중...',
                    style: const TextStyle(color: Colors.white),
                  ),
                  if (_isProcessingOCR) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '이미지에서 텍스트를 인식하고 있습니다',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ],
              ),
            )
          : _isInitialized
          ? Stack(
              children: [
                // 카메라 프리뷰
                Positioned.fill(child: CameraPreview(_cameraController!)),

                // 하단 컨트롤
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // OCR 언어 선택
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child:
                                  DropdownButton<ocr_service.OCRLanguageOption>(
                                    dropdownColor: Colors.black87,
                                    value: _selectedLanguage,
                                    iconEnabledColor: Colors.white,
                                    style: const TextStyle(color: Colors.white),
                                    items: _languageOptions
                                        .map(
                                          (option) => DropdownMenuItem(
                                            value: option,
                                            child: Text(
                                              option.label,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: _onLanguageChanged,
                                  ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // 갤러리 버튼
                        GestureDetector(
                          onTap: _pickFromGallery,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),

                        // 촬영 버튼
                        GestureDetector(
                          onTap: _takePicture,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 40,
                            ),
                          ),
                        ),

                        // 플레이스홀더 (대칭을 위해)
                        const SizedBox(width: 60),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: Text(
                '카메라를 초기화할 수 없습니다.',
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }

  /// 의미없는 텍스트인지 확인
  bool _isMeaninglessText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return true;

    // 특수문자나 숫자만 있는 경우
    if (trimmed.length <= 3 && RegExp(r'^[^\w가-힣]+$').hasMatch(trimmed)) {
      return true;
    }

    // 반복되는 문자만 있는 경우
    if (trimmed.length <= 5 && RegExp(r'^(.)\1+$').hasMatch(trimmed)) {
      return true;
    }

    return false;
  }
}
