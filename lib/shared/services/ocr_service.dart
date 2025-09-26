import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class OCRLanguageOption {
  const OCRLanguageOption({
    required this.code,
    required this.label,
    this.script,
  });

  final String code;
  final String label;
  final TextRecognitionScript? script;
}

const List<OCRLanguageOption> kSupportedOcrLanguages = [
  OCRLanguageOption(
    code: 'ko',
    label: '한국어',
    script: TextRecognitionScript.korean,
  ),
  OCRLanguageOption(
    code: 'en',
    label: 'English',
    script: TextRecognitionScript.latin,
  ),
  OCRLanguageOption(
    code: 'ja',
    label: '日本語',
    script: TextRecognitionScript.japanese,
  ),
  OCRLanguageOption(
    code: 'zh',
    label: '中文',
    script: TextRecognitionScript.chinese,
  ),
];

/// OCR 서비스 - 안정성과 오류 처리 개선 버전
class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  bool _isInitialized = false;
  bool _isDisposed = false;
  int _processingCount = 0;
  static const int _maxConcurrentProcessing = 2;
  static const int _maxImageBytes = 6 * 1024 * 1024; // 6MB 허용
  TextRecognizer? _textRecognizer;
  OCRLanguageOption _currentLanguage = kSupportedOcrLanguages.first;
  bool _usingFallbackScript = false;

  /// 현재 선택된 언어
  OCRLanguageOption get currentLanguage => _currentLanguage;
  bool get isUsingFallbackScript => _usingFallbackScript;

  /// 서비스 초기화 - 언어 선택 반영
  Future<bool> initialize({OCRLanguageOption? language}) async {
    if (_isDisposed) {
      debugPrint('🔍 OCR 서비스가 해제됨 - 재초기화 진행');
      _isDisposed = false;
    }

    final OCRLanguageOption languageToUse = language ?? _currentLanguage;

    final bool languageChanged = languageToUse.code != _currentLanguage.code;
    if (languageChanged || !_isInitialized || _textRecognizer == null) {
      _currentLanguage = languageToUse;
      _isInitialized = false;
      _usingFallbackScript = false;
      if (_textRecognizer != null) {
        await _textRecognizer!.close();
        _textRecognizer = null;
      }
    } else if (_isInitialized && _textRecognizer != null) {
      return true;
    }

    try {
      debugPrint('🔍 OCR 서비스 초기화 시작...');

      // 기존 recognizer 해제
      if (_textRecognizer != null) {
        await _textRecognizer!.close();
        _textRecognizer = null;
      }

      // ML Kit Text Recognizer 초기화 - 선택된 언어 적용
      try {
        if (_currentLanguage.script != null) {
          _textRecognizer = TextRecognizer(script: _currentLanguage.script!);
          debugPrint('🔍 OCR 언어 설정: ${_currentLanguage.label}');
        } else {
          _textRecognizer = TextRecognizer();
        }
      } on ArgumentError catch (_) {
        debugPrint(
          '⚠️ ${_currentLanguage.label} 스크립트를 지원하지 않는 환경, 기본 모드로 fallback',
        );
        _textRecognizer = TextRecognizer();
        _usingFallbackScript = true;
      } catch (error, stackTrace) {
        debugPrint('⚠️ ${_currentLanguage.label} 스크립트 초기화 실패: $error');
        debugPrint(stackTrace.toString());
        debugPrint('⚠️ 기본 TextRecognizer로 fallback');
        _textRecognizer = TextRecognizer();
        _usingFallbackScript = true;
      }

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
      _usingFallbackScript = false;
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
  Future<OCRResult> extractTextFromFile(
    String imagePath, {
    OCRLanguageOption? language,
  }) async {
    final OCRLanguageOption lang = language ?? _currentLanguage;
    return _withGuardedProcessing(() async {
      if (lang.code != _currentLanguage.code) {
        await initialize(language: lang);
      }

      final file = File(imagePath);
      if (!await file.exists()) {
        throw const OCRException('이미지 파일이 존재하지 않습니다.');
      }

      final fileSize = await file.length();
      _validateSize(fileSize);

      final originalBytes = await file.readAsBytes();
      final processedBytes = await preprocessImage(
        originalBytes,
        language: lang,
      );
      final processedResult = await _processBytes(
        processedBytes,
        sourceDescription: '$imagePath (processed)',
      );

      if (_hasRecognizedText(processedResult)) {
        return processedResult;
      }

      debugPrint('🔍 전처리 결과가 비어있어 원본 이미지로 재시도');

      final directPathResult = await _processFromFilePath(
        imagePath,
        description: '$imagePath (direct)',
      );
      if (directPathResult != null && _hasRecognizedText(directPathResult)) {
        return directPathResult;
      }

      return await _processBytes(
        originalBytes,
        sourceDescription: '$imagePath (raw)',
        isFallback: true,
      );
    });
  }

  /// 바이트에서 텍스트 추출 - 개선된 버전
  Future<OCRResult> extractTextFromBytes(
    Uint8List imageBytes, {
    OCRLanguageOption? language,
  }) async {
    final OCRLanguageOption lang = language ?? _currentLanguage;
    return _withGuardedProcessing(() async {
      if (lang.code != _currentLanguage.code) {
        await initialize(language: lang);
      }

      if (imageBytes.isEmpty) {
        throw const OCRException('이미지 데이터가 비어있습니다.');
      }

      _validateSize(imageBytes.length);

      final processedBytes = await preprocessImage(imageBytes, language: lang);
      final processedResult = await _processBytes(
        processedBytes,
        sourceDescription: 'memory-bytes (processed)',
      );

      if (_hasRecognizedText(processedResult)) {
        return processedResult;
      }

      debugPrint('🔍 메모리 이미지 전처리 결과가 비어있어 원본으로 재시도');

      // 이미지가 파일 기반인 경우 직접 경로 재시도
      final tempPath = await _createTempImageFile(imageBytes);
      if (tempPath != null) {
        try {
          final directResult = await _processFromFilePath(
            tempPath,
            description: 'memory-bytes (direct)',
          );
          if (directResult != null && _hasRecognizedText(directResult)) {
            return directResult;
          }
        } finally {
          await _deleteTempFile(tempPath);
        }
      }

      // 보수적인 전처리로 재시도
      final conservativeBytes = await _preprocessImageConservative(
        imageBytes,
        language: lang,
      );
      final conservativeResult = await _processBytes(
        conservativeBytes,
        sourceDescription: 'memory-bytes (conservative)',
        isFallback: true,
      );
      if (_hasRecognizedText(conservativeResult)) {
        return conservativeResult;
      }

      // 원본 이미지 그대로 시도 (전처리 없음)
      debugPrint('🔍 원본 이미지로 직접 시도');
      final rawResult = await _processBytes(
        imageBytes,
        sourceDescription: 'memory-bytes (raw)',
        isFallback: true,
      );
      if (_hasRecognizedText(rawResult)) {
        return rawResult;
      }

      // 최종 폴백: 빈 결과 반환
      debugPrint('🔍 모든 OCR 시도 실패');
      return const OCRResult(fullText: '', textBlocks: [], confidence: 0.0);
    });
  }

  /// 이미지 전처리 (개선된 버전)
  Future<Uint8List> preprocessImage(
    Uint8List imageBytes, {
    required OCRLanguageOption language,
  }) async {
    try {
      // 이미지 디코딩
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw const OCRException('이미지 디코딩 실패');
      }

      // 이미지 크기 조정 (OCR 최적화)
      const maxDimension = 1200; // 조금 더 유연한 크기 제한
      img.Image resizedImage = image;
      if (image.width > maxDimension || image.height > maxDimension) {
        if (image.width > image.height) {
          resizedImage = img.copyResize(
            image,
            width: maxDimension,
            interpolation: img.Interpolation.linear,
          );
        } else {
          resizedImage = img.copyResize(
            image,
            height: maxDimension,
            interpolation: img.Interpolation.linear,
          );
        }
        debugPrint(
          '🔍 리사이즈된 이미지 크기: ${resizedImage.width}x${resizedImage.height}',
        );
      }

      final processed = _applyLanguagePreprocessing(
        resizedImage,
        language: language,
      );

      debugPrint('🔍 ${language.label} 전처리 완료');

      return Uint8List.fromList(img.encodePng(processed));
    } catch (e) {
      debugPrint('🔍 이미지 전처리 실패: $e');
      // 전처리 실패 시 원본 반환
      return imageBytes;
    }
  }

  img.Image _applyLanguagePreprocessing(
    img.Image image, {
    required OCRLanguageOption language,
  }) {
    switch (language.code) {
      case 'ko':
        final grayscale = img.grayscale(image);
        final contrasted = img.adjustColor(
          grayscale,
          contrast: 1.8,
          brightness: 1.15,
        );
        return img.adjustColor(contrasted, contrast: 1.2, brightness: 1.05);
      case 'ja':
        final grayscale = img.grayscale(image);
        final contrasted = img.adjustColor(
          grayscale,
          contrast: 1.5,
          brightness: 1.05,
        );
        return img.gaussianBlur(contrasted, radius: 1);
      case 'zh':
        final grayscale = img.grayscale(image);
        return img.adjustColor(grayscale, contrast: 1.4, brightness: 1.1);
      case 'en':
        final grayscale = img.grayscale(image);
        return img.adjustColor(grayscale, contrast: 1.3, brightness: 1.05);
      default:
        return img.adjustColor(image, contrast: 1.2, brightness: 1.05);
    }
  }

  /// 텍스트 인식 결과가 있는지 확인
  bool _hasRecognizedText(OCRResult result) {
    if (_hasMeaningfulText(result.fullText)) {
      return true;
    }

    for (final block in result.textBlocks) {
      if (_hasMeaningfulText(block)) {
        return true;
      }
    }
    return false;
  }

  bool _hasMeaningfulText(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), '');
    if (normalized.isEmpty) {
      return false;
    }

    final alphanumeric = normalized.replaceAll(
      RegExp(r'[^\p{L}\p{N}]', unicode: true),
      '',
    );

    if (alphanumeric.length > 1) {
      return true;
    }

    return RegExp(r'[가-힣]', unicode: true).hasMatch(normalized);
  }

  /// 보수적인 이미지 전처리 (원본에 가까운 처리)
  Future<Uint8List> _preprocessImageConservative(
    Uint8List imageBytes, {
    required OCRLanguageOption language,
  }) async {
    try {
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        debugPrint('⚠️ 보수적 전처리: 이미지 디코딩 실패');
        return imageBytes;
      }

      final enhanced = _applyConservativeAdjustments(
        originalImage,
        language: language,
      );

      debugPrint('🔍 보수적 전처리 완료 (원본 크기 유지)');

      return Uint8List.fromList(img.encodePng(enhanced));
    } catch (e) {
      debugPrint('⚠️ 보수적 전처리 실패: $e');
      return imageBytes;
    }
  }

  img.Image _applyConservativeAdjustments(
    img.Image image, {
    required OCRLanguageOption language,
  }) {
    switch (language.code) {
      case 'ja':
      case 'zh':
        return img.adjustColor(image, contrast: 1.2, brightness: 1.05);
      case 'ko':
        return img.adjustColor(image, contrast: 1.3, brightness: 1.1);
      case 'en':
        return img.adjustColor(image, contrast: 1.05, brightness: 1.02);
      default:
        return img.adjustColor(image, contrast: 1.1, brightness: 1.05);
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
    return <String, Object?>{
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
    if (bytesLength > _maxImageBytes) {
      throw OCRException(
        '이미지 데이터가 너무 큽니다. (최대 ${(_maxImageBytes / (1024 * 1024)).toStringAsFixed(1)}MB)',
      );
    }
  }

  Future<OCRResult> _processBytes(
    Uint8List imageBytes, {
    required String sourceDescription,
    bool isFallback = false,
  }) async {
    final tempFile = File(
      '${Directory.systemTemp.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    try {
      await tempFile.writeAsBytes(imageBytes, flush: true);
      final inputImage = InputImage.fromFilePath(tempFile.path);
      final result = await _processInputImage(
        inputImage,
        sourceDescription: sourceDescription,
        isFallback: isFallback,
      );
      return result;
    } on OCRException {
      rethrow;
    } catch (e) {
      debugPrint('🔍 파일 기반 OCR 처리 실패 ($sourceDescription): $e');
      throw OCRException('파일 OCR 처리 실패: $e');
    } finally {
      try {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (e) {
        debugPrint('🔍 임시 파일 삭제 실패: $e');
      }
    }
  }

  Future<OCRResult?> _processFromFilePath(
    String path, {
    required String description,
  }) async {
    if (path.isEmpty) {
      return null;
    }

    try {
      final inputImage = InputImage.fromFilePath(path);
      final fallbackResult = await _processInputImage(
        inputImage,
        sourceDescription: description,
        isFallback: true,
      );
      return fallbackResult;
    } catch (e) {
      debugPrint('🔍 경로 기반 재시도 실패 ($description): $e');
      return null;
    }
  }

  Future<OCRResult> _processInputImage(
    InputImage inputImage, {
    required String sourceDescription,
    bool isFallback = false,
  }) async {
    final recognizer = _textRecognizer;
    if (recognizer == null) {
      throw const OCRException('Text Recognizer가 초기화되지 않았습니다.');
    }

    try {
      debugPrint(
        '🔍 ML Kit OCR 처리 시작... (source: $sourceDescription, '
        'fallback: $isFallback)',
      );
      final recognizedText = await recognizer
          .processImage(inputImage)
          .timeout(const Duration(seconds: 12))
          .catchError((Object error) {
            debugPrint('🔍 ML Kit 처리 예외 ($sourceDescription): $error');
            throw const OCRException('OCR 엔진 처리 중 오류가 발생했습니다.');
          });

      debugPrint('🔍 Raw OCR 텍스트 길이: ${recognizedText.text.length}');
      debugPrint('🔍 인식된 블록 수: ${recognizedText.blocks.length}');

      if (recognizedText.text.length < 200) {
        debugPrint('🔍 Raw OCR 텍스트: "${recognizedText.text}"');
      }

      // 블록별 상세 로깅
      for (int i = 0; i < recognizedText.blocks.length; i++) {
        final block = recognizedText.blocks[i];
        debugPrint(
          '🔍 블록 $i: "${block.text}" (언어: ${block.recognizedLanguages.join(', ')})',
        );
      }

      final normalizedText = _normalizeText(recognizedText.text);

      if (normalizedText.isEmpty) {
        debugPrint('🔍 정규화된 텍스트가 비어있음, 블록 기반 추출 시도');
        final textFromBlocks = _extractFromBlocks(recognizedText.blocks);
        if (textFromBlocks.isNotEmpty) {
          debugPrint('🔍 블록 기반 텍스트 사용: ${textFromBlocks.length}자');
          return OCRResult(
            fullText: textFromBlocks,
            textBlocks: recognizedText.blocks.map((b) => b.text).toList(),
            confidence: _calculateAverageConfidence(recognizedText.blocks),
          );
        }

        debugPrint('🔍 OCR 결과가 비어있음 (source: $sourceDescription)');
        debugPrint('🔍 블록 수: ${recognizedText.blocks.length}');
        debugPrint('🔍 원본 텍스트: "${recognizedText.text}"');
        throw const OCRException('이미지에서 텍스트를 인식할 수 없습니다.');
      }

      final blockTexts = recognizedText.blocks
          .map((block) => block.text)
          .where((text) => text.trim().isNotEmpty)
          .toList();

      return OCRResult(
        fullText: normalizedText,
        textBlocks: blockTexts,
        confidence: _calculateAverageConfidence(recognizedText.blocks),
      );
    } on TimeoutException {
      debugPrint('⏱️ OCR 처리 타임아웃 ($sourceDescription)');
      throw const OCRException('텍스트 인식 시간이 초과되었습니다.');
    } on OCRException {
      rethrow;
    } catch (e, stack) {
      debugPrint('🔍 실제 OCR 처리 실패 ($sourceDescription): $e');
      debugPrint(stack.toString());
      throw OCRException('OCR 처리 중 오류가 발생했습니다: $e');
    }
  }

  String _normalizeText(String text) {
    final normalized = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized.isNotEmpty) {
      debugPrint('🔍 정규화된 텍스트 길이: ${normalized.length}자');
    }
    return normalized;
  }

  String _extractFromBlocks(List<TextBlock> blocks) {
    if (blocks.isEmpty) return '';
    final buffer = StringBuffer();
    for (final block in blocks) {
      final text = block.text.trim();
      if (text.isNotEmpty) {
        buffer.writeln(text);
      }
    }
    return buffer.toString().trim();
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

  Future<String?> _createTempImageFile(Uint8List bytes) async {
    try {
      final tempFile = File(
        '${Directory.systemTemp.path}/ocr_detect_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(bytes, flush: true);
      return tempFile.path;
    } catch (e) {
      debugPrint('🔍 임시 파일 생성 실패 (경로 감지): $e');
      return null;
    }
  }

  Future<void> _deleteTempFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('🔍 임시 파일 삭제 실패 (경로 감지): $e');
    }
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
