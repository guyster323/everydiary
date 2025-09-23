import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/services/ocr_service.dart' as ocr_service;

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
      await _ocrService.initialize().timeout(
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

      // OCR 처리
      await _processImageWithOCR(image.path);
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
        // OCR 처리
        await _processImageWithOCR(image.path);
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
  Future<void> _processImageWithOCR(String imagePath) async {
    if (!mounted) return;

    debugPrint('📷 OCR 처리 시작: $imagePath');

    try {
      setState(() {
        _isLoading = true;
        _isProcessingOCR = true;
      });

      debugPrint('📷 OCR 상태: 로딩 시작');

      // 파일 존재 확인
      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('📷 파일이 존재하지 않음: $imagePath');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isProcessingOCR = false;
          });
          _showErrorDialog('이미지 파일을 찾을 수 없습니다.');
        }
        return;
      }

      // 파일 크기 확인 (안정성을 위해 제한 줄임)
      final fileSize = await file.length();
      if (fileSize == 0) {
        debugPrint('📷 파일이 비어있음');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isProcessingOCR = false;
          });
          _showErrorDialog('이미지 파일이 비어있습니다.');
        }
        return;
      }
      if (fileSize > 10 * 1024 * 1024) {
        debugPrint(
          '📷 파일 크기 초과: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB',
        );
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isProcessingOCR = false;
          });
          _showErrorDialog('이미지 파일이 너무 큽니다. (최대 10MB)');
        }
        return;
      }

      debugPrint('📷 파일 크기: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');

      // OCR 서비스 초기화 확인
      debugPrint('📷 OCR 서비스 초기화 중...');
      try {
        await _ocrService.initialize().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            throw Exception('OCR 서비스 초기화 타임아웃');
          },
        );
      } catch (e) {
        debugPrint('📷 OCR 서비스 초기화 실패: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isProcessingOCR = false;
          });
          _showErrorDialog('OCR 서비스를 사용할 수 없습니다.');
        }
        return;
      }

      // OCR 처리 (try-catch로 한번 더 감싸기)
      String? resultText;
      try {
        debugPrint('📷 OCR 텍스트 추출 시작...');
        final result = await _ocrService
            .extractTextFromFile(imagePath)
            .timeout(
              const Duration(seconds: 20), // 타임아웃 단축
              onTimeout: () {
                throw Exception('OCR 처리 시간이 초과되었습니다. 다시 시도해주세요.');
              },
            );
        resultText = result.fullText.trim();
        debugPrint('📷 OCR 결과 길이: ${resultText.length}자');
        if (resultText.isNotEmpty) {
          debugPrint(
            '📷 OCR 결과 미리보기: ${resultText.substring(0, resultText.length > 100 ? 100 : resultText.length)}...',
          );
        }
      } catch (ocrError) {
        debugPrint('📷 OCR 처리 중 오류: $ocrError');

        // 간단한 오류 메시지로 변경
        String errorMessage = '텍스트 인식에 실패했습니다.';
        if (ocrError.toString().contains('timeout') ||
            ocrError.toString().contains('시간')) {
          errorMessage = '⏰ 처리 시간이 초과되었습니다.\n\n더 작은 이미지를 시도해보세요.';
        } else if (ocrError.toString().contains('memory') ||
            ocrError.toString().contains('메모리')) {
          errorMessage = '💾 메모리 부족으로 처리할 수 없습니다.\n\n앱을 재시작한 후 다시 시도해보세요.';
        } else if (ocrError.toString().contains('network') ||
            ocrError.toString().contains('네트워크')) {
          errorMessage = '🌐 네트워크 연결에 문제가 있습니다.\n\n인터넷 연결을 확인해주세요.';
        } else {
          errorMessage = '❌ 텍스트 인식에 실패했습니다.\n\n다른 이미지를 시도해보세요.';
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
            _isProcessingOCR = false;
          });
          _showErrorDialog(errorMessage);
        }
        return;
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isProcessingOCR = false;
      });

      if (resultText.isNotEmpty) {
        // OCR 결과를 일기 작성 화면으로 전달
        Navigator.of(context).pop(resultText);
      } else {
        _showErrorDialog('이미지에서 텍스트를 인식할 수 없습니다.\n다른 이미지를 시도해보세요.');
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
              '📏 이미지 파일이 너무 큽니다.\n\n• 최대 10MB 이하의 이미지를 선택해주세요\n• 이미지 크기를 줄여서 다시 시도해보세요';
        } else if (e.toString().contains('네트워크') ||
            e.toString().contains('network')) {
          errorMessage =
              '🌐 네트워크 연결에 문제가 있습니다.\n\n• 인터넷 연결을 확인해주세요\n• 잠시 후 다시 시도해보세요';
        } else {
          errorMessage =
              '❌ 텍스트 인식에 실패했습니다.\n\n• 다른 이미지를 시도해보세요\n• 이미지가 선명한지 확인해보세요\n• 잠시 후 다시 시도해보세요';
        }

        _showErrorDialog(errorMessage);
      }
    } finally {
      // 메모리 정리를 위한 가비지 컬렉션 힌트
      if (mounted) {
        // 잠시 대기 후 가비지 컬렉션 유도
        Future.delayed(const Duration(milliseconds: 100), () {
          // 가비지 컬렉션 힌트
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
}
