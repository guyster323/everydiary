import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/ocr_provider.dart';
import '../../../shared/services/ocr_service.dart' as ocr_service;
import '../services/permission_service.dart';
import '../widgets/camera_controls.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/ocr_text_overlay.dart';
import '../widgets/permission_manager_widget.dart';
import 'gallery_screen.dart';
import 'text_editor_screen.dart';

/// 카메라 화면
/// 실시간 텍스트 인식 및 촬영 기능을 제공합니다.
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isProcessing = false;
  String _recognizedText = '';
  Timer? _recognitionTimer;
  final ocr_service.OCRService _ocrService = ocr_service.OCRService();
  final OCRPermissionService _permissionService = OCRPermissionService();
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionsAndInitialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // 타이머 정리
    _recognitionTimer?.cancel();
    _recognitionTimer = null;

    // 카메라 컨트롤러 정리
    _cameraController?.dispose();
    _cameraController = null;

    // OCR 서비스 정리
    _ocrService.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        // 앱이 비활성화되면 카메라 정리
        _cameraController?.dispose();
        _recognitionTimer?.cancel();
        break;
      case AppLifecycleState.resumed:
        // 앱이 다시 활성화되면 카메라 재초기화
        if (_hasPermissions) {
          _initializeCamera();
        }
        break;
      case AppLifecycleState.detached:
        // 앱이 완전히 종료되면 모든 리소스 정리
        _cameraController?.dispose();
        _recognitionTimer?.cancel();
        break;
      case AppLifecycleState.hidden:
        // 앱이 숨겨지면 카메라 정리
        _cameraController?.dispose();
        _recognitionTimer?.cancel();
        break;
    }
  }

  /// 권한 확인 및 카메라 초기화
  Future<void> _checkPermissionsAndInitialize() async {
    try {
      final summary = await _permissionService.getPermissionSummary();
      setState(() {
        _hasPermissions = summary.allGranted;
      });

      if (_hasPermissions) {
        await _initializeCamera();
      }
    } catch (e) {
      _showErrorDialog('권한 확인 중 오류가 발생했습니다: $e');
    }
  }

  /// 카메라 초기화
  Future<void> _initializeCamera() async {
    try {
      // 기존 컨트롤러가 있으면 정리
      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showErrorDialog('카메라를 찾을 수 없습니다.');
        return;
      }

      // 더 낮은 해상도로 설정하여 안정성 향상
      _cameraController = CameraController(
        _cameras.first,
        ResolutionPreset.medium, // high에서 medium으로 변경
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // 초기화 타임아웃 설정
      await _cameraController!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('카메라 초기화 시간 초과');
        },
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _startTextRecognition();
      }
    } catch (e) {
      debugPrint('카메라 초기화 오류: $e');
      if (mounted) {
        _showErrorDialog('카메라 초기화 중 오류가 발생했습니다: $e');
      }
    }
  }

  /// 실시간 텍스트 인식 시작
  void _startTextRecognition() {
    _recognitionTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        _performTextRecognition();
      }
    });
  }

  /// 텍스트 인식 수행 (안정성 개선)
  Future<void> _performTextRecognition() async {
    if (_isProcessing || _cameraController == null || !mounted) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final image = await _cameraController!.takePicture();
      final imageBytes = await image.readAsBytes();

      // 이미지 크기 확인 (메모리 안정성)
      if (imageBytes.length > 5 * 1024 * 1024) {
        // 5MB 초과 시 실시간 인식 스킵
        debugPrint('이미지가 너무 큽니다. 실시간 인식을 건너뜁니다.');
        return;
      }

      final result = await _ocrService
          .extractTextFromBytes(imageBytes)
          .timeout(
            const Duration(seconds: 10), // 실시간 인식용 짧은 타임아웃
            onTimeout: () {
              debugPrint('실시간 OCR 타임아웃');
              throw Exception('실시간 OCR 처리 시간 초과');
            },
          );

      if (mounted) {
        setState(() {
          _recognizedText = result.fullText;
        });

        // OCR 결과를 프로바이더에 저장
        ref.read(oCRResultStateProvider.notifier).setResult(result);
      }
    } catch (e) {
      debugPrint('실시간 텍스트 인식 오류: $e');
      // 실시간 인식 오류는 조용히 처리 (사용자에게 알리지 않음)
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// 사진 촬영 (안정성 개선)
  Future<void> _takePicture() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        !mounted) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      final imageBytes = await image.readAsBytes();

      // 이미지 크기 확인
      if (imageBytes.length > 10 * 1024 * 1024) {
        _showErrorDialog('이미지가 너무 큽니다. (최대 10MB)');
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
        String errorMessage = '사진 촬영 중 오류가 발생했습니다.';
        if (e.toString().contains('시간이 초과')) {
          errorMessage = '처리 시간이 초과되었습니다. 다시 시도해주세요.';
        } else if (e.toString().contains('메모리')) {
          errorMessage = '메모리 부족으로 처리할 수 없습니다.';
        }
        _showErrorDialog(errorMessage);
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
    Navigator.of(context).push<void>(
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
        title: const Text('OCR 카메라'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_hasPermissions)
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () {
                // 플래시 토글 기능
                _toggleFlash();
              },
            ),
        ],
      ),
      body: _hasPermissions
          ? _isInitialized
                ? Stack(
                    children: [
                      // 카메라 프리뷰
                      CameraPreviewWidget(controller: _cameraController!),

                      // OCR 텍스트 오버레이
                      if (_recognizedText.isNotEmpty)
                        OCRTextOverlay(
                          text: _recognizedText,
                          isProcessing: _isProcessing,
                        ),

                      // 카메라 컨트롤
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: CameraControls(
                          onTakePicture: _takePicture,
                          onPickFromGallery: _pickImageFromGallery,
                          isProcessing: _isProcessing,
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          '카메라를 초기화하는 중...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  )
          : PermissionManagerWidget(
              onPermissionsGranted: () {
                setState(() {
                  _hasPermissions = true;
                });
                _initializeCamera();
              },
            ),
    );
  }

  /// 플래시 토글
  void _toggleFlash() {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      _cameraController!.setFlashMode(
        _cameraController!.value.flashMode == FlashMode.off
            ? FlashMode.auto
            : FlashMode.off,
      );
    }
  }
}
