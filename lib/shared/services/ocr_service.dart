import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

/// OCR 서비스 - 안정성과 오류 처리 개선 버전
class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  bool _isInitialized = false;
  bool _isDisposed = false;
  int _processingCount = 0;
  static const int _maxConcurrentProcessing = 1; // 동시 처리 수를 1로 제한
  TextRecognizer? _textRecognizer;

  /// 서비스 초기화 - 더 안전한 방식
  Future<bool> initialize() async {
    if (_isDisposed) {
      debugPrint('🔍 OCR 서비스가 이미 해제되었습니다.');
      return false;
    }
    if (_isInitialized && _textRecognizer != null) {
      debugPrint('🔍 OCR 서비스가 이미 초기화되었습니다.');
      return true;
    }

    try {
      debugPrint('🔍 OCR 서비스 초기화 시작...');

      // 기존 recognizer 해제
      if (_textRecognizer != null) {
        await _textRecognizer!.close();
        _textRecognizer = null;
      }

      // ML Kit Text Recognizer 초기화 - 안정성을 위해 기본 생성자 사용
      _textRecognizer = TextRecognizer(); // 기본 생성자 사용으로 크래시 방지

      // 초기화 테스트
      await Future<void>.delayed(const Duration(milliseconds: 100));

      _isInitialized = true;
      _isDisposed = false;
      debugPrint('🔍 OCR 서비스 초기화 성공');
      return true;
    } catch (e) {
      debugPrint('🔍 OCR 서비스 초기화 실패: $e');
      _isInitialized = false;
      _textRecognizer = null;
      return false;
    }
  }

  /// 서비스 해제
  Future<void> dispose() async {
    if (_isDisposed) return;
    debugPrint('🔍 OCR 서비스 해제 시작...');

    // 모든 처리 완료 대기 (최대 5초)
    int waitCount = 0;
    while (_processingCount > 0 && waitCount < 50) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      waitCount++;
    }

    // Text Recognizer 해제
    try {
      await _textRecognizer?.close();
    } catch (e) {
      debugPrint('🔍 Text Recognizer 해제 중 오류: $e');
    }

    _textRecognizer = null;
    _isInitialized = false;
    _isDisposed = true;
    debugPrint('🔍 OCR 서비스 해제 완료');
  }

  /// 파일에서 텍스트 추출 - 개선된 버전
  Future<OCRResult> extractTextFromFile(String imagePath) async {
    return _withGuardedProcessing(() async {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw const OCRException('이미지 파일이 존재하지 않습니다.');
      }

      final fileSize = await file.length();
      _validateSize(fileSize);

      final originalBytes = await file.readAsBytes();
      final processedBytes = await preprocessImage(originalBytes);
      return await _processBytes(processedBytes);
    });
  }

  /// 바이트에서 텍스트 추출 - 개선된 버전
  Future<OCRResult> extractTextFromBytes(Uint8List imageBytes) async {
    return _withGuardedProcessing(() async {
      if (imageBytes.isEmpty) {
        throw const OCRException('이미지 데이터가 비어있습니다.');
      }

      _validateSize(imageBytes.length);

      final processedBytes = await preprocessImage(imageBytes);
      return await _processBytes(processedBytes);
    });
  }

  /// 이미지 전처리 (개선된 버전)
  Future<Uint8List> preprocessImage(Uint8List imageBytes) async {
    try {
      // 이미지 디코딩
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const OCRException('이미지 디코딩 실패');
      }

      // 이미지 크기 조정 (OCR 최적화) - 더 보수적인 크기
      const maxDimension = 1024; // 1280에서 1024로 줄임
      int newWidth = image.width;
      int newHeight = image.height;

      if (image.width > maxDimension || image.height > maxDimension) {
        if (image.width > image.height) {
          newWidth = maxDimension;
          newHeight = (image.height * maxDimension ~/ image.width);
        } else {
          newHeight = maxDimension;
          newWidth = (image.width * maxDimension ~/ image.height);
        }
      }

      final resizedImage = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // 이미지 품질 개선
      final enhancedImage = _enhanceImage(resizedImage);

      // JPEG로 인코딩 (품질 80으로 조정)
      final processedBytes = img.encodeJpg(enhancedImage, quality: 80);
      return Uint8List.fromList(processedBytes);
    } catch (e) {
      debugPrint('🔍 이미지 전처리 실패: $e');
      // 전처리 실패 시 원본 반환
      return imageBytes;
    }
  }

  /// 이미지 품질 개선 (개선된 버전)
  img.Image _enhanceImage(img.Image image) {
    try {
      // 그레이스케일 변환
      final grayscale = img.grayscale(image);

      // 대비 개선 (더 보수적인 값)
      final contrasted = img.adjustColor(
        grayscale,
        contrast: 1.1, // 1.2에서 1.1로 줄임
        brightness: 1.05, // 1.1에서 1.05로 줄임
      );

      return contrasted;
    } catch (e) {
      debugPrint('🔍 이미지 개선 실패: $e');
      return image;
    }
  }

  /// 서비스 상태 확인
  bool get isInitialized =>
      _isInitialized && !_isDisposed && _textRecognizer != null;
  bool get isAvailable =>
      _isInitialized && !_isDisposed && _textRecognizer != null;
  int get processingCount => _processingCount;

  /// 서비스 정보 가져오기
  Map<String, dynamic> getServiceInfo() {
    return {
      'isInitialized': _isInitialized,
      'isDisposed': _isDisposed,
      'isAvailable': isAvailable,
      'processingCount': _processingCount,
      'maxConcurrentProcessing': _maxConcurrentProcessing,
      'hasRecognizer': _textRecognizer != null,
      'mode': 'Enhanced',
    };
  }

  /// 서비스 재초기화
  Future<bool> reinitialize() async {
    debugPrint('🔍 OCR 서비스 재초기화 시작...');
    await dispose();
    await Future<void>.delayed(const Duration(milliseconds: 200)); // 약간의 대기
    _isDisposed = false;
    return await initialize();
  }

  /// 디버그 정보 출력
  void printDebugInfo() {
    debugPrint('🔍 OCR 서비스 상태:');
    debugPrint(' - 초기화됨: $_isInitialized');
    debugPrint(' - 해제됨: $_isDisposed');
    debugPrint(' - 사용 가능: $isAvailable');
    debugPrint(' - 처리 중인 작업: $_processingCount');
    debugPrint(' - 최대 동시 처리: $_maxConcurrentProcessing');
    debugPrint(' - Recognizer 존재: ${_textRecognizer != null}');
    debugPrint(' - 모드: 개선된 안정화');
  }

  Future<OCRResult> _withGuardedProcessing(
    Future<OCRResult> Function() action,
  ) async {
    if (_isDisposed) {
      debugPrint('🔍 OCR 서비스가 해제됨');
      throw const OCRException('OCR 서비스가 해제되었습니다.');
    }

    if (_processingCount >= _maxConcurrentProcessing) {
      throw const OCRException('OCR 처리 중입니다. 잠시 후 다시 시도해주세요.');
    }

    if (!_isInitialized || _textRecognizer == null) {
      final initialized = await initialize();
      if (!initialized) {
        debugPrint('🔍 OCR 서비스 초기화 실패');
        throw const OCRException('OCR 서비스를 초기화할 수 없습니다.');
      }
    }

    _processingCount++;
    try {
      return await action();
    } finally {
      _processingCount--;
    }
  }

  void _validateSize(int bytesLength) {
    if (bytesLength == 0) {
      throw const OCRException('이미지 데이터가 비어있습니다.');
    }
    if (bytesLength > 5 * 1024 * 1024) {
      throw const OCRException('이미지 데이터가 너무 큽니다. (최대 5MB)');
    }
  }

  Future<OCRResult> _processBytes(Uint8List imageBytes) async {
    try {
      final tempFile = File(
        '${Directory.systemTemp.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      try {
        await tempFile.writeAsBytes(imageBytes, flush: true);
        final inputImage = InputImage.fromFilePath(tempFile.path);
        return await _processInputImage(inputImage);
      } finally {
        try {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (e) {
          debugPrint('🔍 임시 파일 삭제 실패: $e');
        }
      }
    } on OCRException {
      rethrow;
    } catch (e) {
      debugPrint('🔍 파일 기반 OCR 처리 실패: $e');
      throw OCRException('파일 OCR 처리 실패: $e');
    }
  }

  Future<OCRResult> _processInputImage(InputImage inputImage) async {
    final recognizer = _textRecognizer;
    if (recognizer == null) {
      throw const OCRException('Text Recognizer가 초기화되지 않았습니다.');
    }

    try {
      debugPrint('🔍 ML Kit OCR 처리 시작...');
      final recognizedText = await recognizer
          .processImage(inputImage)
          .timeout(const Duration(seconds: 10));

      final trimmedText = recognizedText.text.trim();
      if (trimmedText.isEmpty) {
        debugPrint('🔍 OCR 결과가 비어있음');
        throw const OCRException('이미지에서 텍스트를 인식할 수 없습니다.');
      }

      final textBlocks = recognizedText.blocks
          .map((block) => block.text)
          .where((text) => text.trim().isNotEmpty)
          .toList();

      return OCRResult(
        fullText: recognizedText.text,
        textBlocks: textBlocks,
        confidence: _calculateAverageConfidence(recognizedText.blocks),
      );
    } on OCRException {
      rethrow;
    } catch (e) {
      debugPrint('🔍 실제 OCR 처리 실패: $e');
      throw OCRException('OCR 처리 중 오류가 발생했습니다: $e');
    }
  }

  /// ML Kit 블록들의 평균 신뢰도 계산
  double _calculateAverageConfidence(List<TextBlock> blocks) {
    if (blocks.isEmpty) return 0.0;

    // ML Kit은 직접적인 신뢰도를 제공하지 않으므로
    // 텍스트 블록 수와 길이를 기반으로 추정
    double totalScore = 0.0;
    int totalChars = 0;

    for (final block in blocks) {
      final text = block.text;
      final charCount = text.length;
      // 더 긴 텍스트와 알파벳/숫자/한글이 많을수록 높은 신뢰도
      final alphanumericCount = text
          .replaceAll(RegExp(r'[^a-zA-Z0-9가-힣]'), '')
          .length;
      final confidence =
          (alphanumericCount / charCount.clamp(1, double.infinity)) * 0.9 + 0.1;

      totalScore += confidence * charCount;
      totalChars += charCount;
    }

    return totalChars > 0 ? (totalScore / totalChars).clamp(0.0, 1.0) : 0.0;
  }
}

/// OCR 결과 데이터 클래스 (동일)
class OCRResult {
  final String fullText;
  final List<String> textBlocks;
  final double confidence;

  const OCRResult({
    required this.fullText,
    required this.textBlocks,
    required this.confidence,
  });

  /// 안전한 텍스트 반환 (빈 결과 방지)
  String get safeText {
    if (fullText.isNotEmpty) {
      return fullText;
    }
    // fullText가 비어있으면 blocks에서 수집
    if (textBlocks.isNotEmpty) {
      return textBlocks.join('\n\n');
    }
    return '';
  }

  /// 결과가 유효한지 확인
  bool get isValid => safeText.isNotEmpty;

  @override
  String toString() {
    return 'OCRResult(fullText: ${fullText.length}자, blocks: ${textBlocks.length}개, confidence: ${confidence.toStringAsFixed(2)})';
  }
}

/// OCR 예외 클래스 (동일)
class OCRException implements Exception {
  final String message;

  const OCRException(this.message);

  @override
  String toString() => 'OCRException: $message';
}
