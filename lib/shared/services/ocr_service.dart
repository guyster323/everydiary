import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

/// OCR에서 지원하는 언어 옵션
class OCRLanguageOption {
  const OCRLanguageOption({
    required this.code,
    required this.label,
    required this.script,
  });

  final String code;
  final String label;
  final TextRecognitionScript script;
}

const List<OCRLanguageOption> kSupportedOcrLanguages = <OCRLanguageOption>[
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

/// 다국어 OCR 서비스를 담당하는 싱글턴
class OCRService {
  factory OCRService() => _instance;
  OCRService._internal();

  static final OCRService _instance = OCRService._internal();

  final Map<TextRecognitionScript, TextRecognizer> _recognizers = <TextRecognitionScript, TextRecognizer>{};
  bool _isInitialized = false;
  bool _isDisposed = false;
  int _processingCount = 0;

  static const int _maxConcurrentProcessing = 3;
  static const int _maxImageBytes = 6 * 1024 * 1024; // 6MB

  OCRLanguageOption get defaultLanguage => kSupportedOcrLanguages.first;

  bool get isInitialized => _isInitialized && !_isDisposed && _recognizers.isNotEmpty;
  bool get isDisposed => _isDisposed;
  Iterable<TextRecognitionScript> get supportedScripts => _recognizers.keys;

  /// 모든 언어에 대한 TextRecognizer를 초기화한다.
  Future<bool> initialize({OCRLanguageOption? language}) async {
    if (_isDisposed) {
      debugPrint('🔍 OCR 서비스가 해제되어 다시 초기화합니다.');
      _isDisposed = false;
    }

    if (_isInitialized) {
      if (language != null) {
        await _ensureRecognizer(language.script);
      }
      return true;
    }

    try {
      debugPrint('🔍 다국어 OCR 서비스 초기화 시작');
      final Set<TextRecognitionScript> scripts = <TextRecognitionScript>{
        TextRecognitionScript.korean,
        TextRecognitionScript.latin,
        TextRecognitionScript.japanese,
        TextRecognitionScript.chinese,
      };
      if (language != null) {
        scripts.add(language.script);
      }

      for (final TextRecognitionScript script in scripts) {
        await _ensureRecognizer(script);
      }

      _isInitialized = _recognizers.isNotEmpty;
      debugPrint('🔍 OCR 서비스 초기화 완료 (${_recognizers.length}개 스크립트)');
      return _isInitialized;
    } catch (error, stackTrace) {
      debugPrint('❌ OCR 서비스 초기화 실패: $error');
      debugPrint(stackTrace.toString());
      _recognizers.clear();
      _isInitialized = false;
      return false;
    }
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }

    debugPrint('🔍 OCR 서비스 해제 시작');
    for (final TextRecognizer recognizer in _recognizers.values) {
      try {
        await recognizer.close();
      } catch (error) {
        debugPrint('⚠️ Recognizer 해제 실패: $error');
      }
    }
    _recognizers.clear();
    _isInitialized = false;
    _isDisposed = true;
    debugPrint('🔍 OCR 서비스 해제 완료');
  }

  Future<OCRResult> extractTextFromFile(
    String imagePath, {
    OCRLanguageOption? language,
  }) async {
    final OCRLanguageOption targetLanguage = language ?? defaultLanguage;
    return _withGuardedProcessing(targetLanguage.script, () async {
      final File file = File(imagePath);
      if (!await file.exists()) {
        throw const OCRException('이미지 파일이 존재하지 않습니다.');
      }

      _validateSize(await file.length());

      final Uint8List bytes = await file.readAsBytes();
      return _extractFromBytes(
        bytes,
        script: targetLanguage.script,
        sourceDescription: imagePath,
      );
    });
  }

  Future<OCRResult> extractTextFromBytes(
    Uint8List imageBytes, {
    OCRLanguageOption? language,
  }) async {
    final OCRLanguageOption targetLanguage = language ?? defaultLanguage;
    return _withGuardedProcessing(targetLanguage.script, () async {
      if (imageBytes.isEmpty) {
        throw const OCRException('이미지 데이터가 비어있습니다.');
      }

      _validateSize(imageBytes.length);

      return _extractFromBytes(
        imageBytes,
        script: targetLanguage.script,
        sourceDescription: 'memory-bytes',
      );
    });
  }

  /// 언어 자동 감지를 수행하여 가장 신뢰도가 높은 결과를 반환한다.
  Future<OCRResult> extractTextWithAutoDetection(String imagePath) async {
    final File file = File(imagePath);
    if (!await file.exists()) {
      throw const OCRException('이미지 파일이 존재하지 않습니다.');
    }
    _validateSize(await file.length());

    final Uint8List bytes = await file.readAsBytes();
    return extractTextWithAutoDetectionFromBytes(bytes);
  }

  Future<OCRResult> extractTextWithAutoDetectionFromBytes(Uint8List bytes) async {
    final List<OCRLanguageOption> languagePriority = <OCRLanguageOption>[
      ...kSupportedOcrLanguages,
    ];

    OCRResult? bestResult;
    double bestConfidence = 0;

    for (final OCRLanguageOption option in languagePriority) {
      try {
        final OCRResult result = await extractTextFromBytes(
          bytes,
          language: option,
        );
        if (result.isValid && result.confidence > bestConfidence) {
          bestResult = result;
          bestConfidence = result.confidence;
        }
      } catch (error) {
        debugPrint('⚠️ ${option.label} 자동 인식 실패: $error');
      }
    }

    return bestResult ?? OCRResult.empty();
  }

  Future<Uint8List> preprocessImage(
    Uint8List imageBytes, {
    required OCRLanguageOption language,
  }) async {
    try {
      final _OptimizedImage optimized = _optimizeImageForScript(
        imageBytes,
        language.script,
      );
      return optimized.bytes;
    } catch (error) {
      debugPrint('⚠️ 이미지 전처리 실패: $error');
      return imageBytes;
    }
  }

  Future<OCRResult> _extractFromBytes(
    Uint8List imageBytes, {
    required TextRecognitionScript script,
    required String sourceDescription,
  }) async {
    final _OptimizedImage optimized = _optimizeImageForScript(
      imageBytes,
      script,
    );

    OCRResult result = await _processImageBytes(
      optimized,
      script: script,
      description: '$sourceDescription (optimized)',
    );

    if (result.isValid) {
      return result;
    }

    debugPrint('⚠️ $sourceDescription 최적화 결과가 비어 있어 raw로 재시도');

    result = await _processImageBytes(
      _OptimizedImage(bytes: imageBytes, width: null, height: null),
      script: script,
      description: '$sourceDescription (raw)',
      allowFallback: false,
    );

    if (result.isValid) {
      return result;
    }

    return _extractWithFallback(imageBytes, script);
  }

  Future<OCRResult> _processImageBytes(
    _OptimizedImage optimized, {
    required TextRecognitionScript script,
    required String description,
    bool allowFallback = true,
  }) async {
    final TextRecognizer? recognizer = _recognizers[script];
    if (recognizer == null) {
      debugPrint('⚠️ ${script.name} recognizer 없음, fallback 시도');
      if (allowFallback) {
        return _extractWithFallback(optimized.bytes, script);
      }
      return OCRResult.empty();
    }

    final File tempFile = File(
      '${Directory.systemTemp.path}/ocr_${script.name}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    try {
      await tempFile.writeAsBytes(optimized.bytes, flush: true);
      final InputImage inputImage = InputImage.fromFilePath(tempFile.path);
      debugPrint('🔍 OCR 시작 ($description, script: ${script.name})');
      final RecognizedText recognizedText = await recognizer
          .processImage(inputImage)
          .timeout(const Duration(seconds: 12));

      if (recognizedText.text.isEmpty && allowFallback) {
        debugPrint('⚠️ OCR 결과 없음, fallback 이동');
        return _extractWithFallback(optimized.bytes, script);
      }

      final String normalized = _normalizeText(recognizedText.text);
      final List<String> blocks = recognizedText.blocks
          .map((TextBlock block) => block.text.trim())
          .where((String text) => text.isNotEmpty)
          .toList();

      return OCRResult(
        fullText: normalized,
        textBlocks: blocks,
        confidence: _calculateAverageConfidence(recognizedText, script),
      );
    } on TimeoutException {
      debugPrint('⏱️ OCR 처리 타임아웃 ($description)');
      if (allowFallback) {
        return _extractWithFallback(optimized.bytes, script);
      }
      throw const OCRException('텍스트 인식 시간이 초과되었습니다.');
    } on OCRException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('❌ OCR 처리 실패 ($description): $error');
      debugPrint(stackTrace.toString());
      if (allowFallback) {
        return _extractWithFallback(optimized.bytes, script);
      }
      throw OCRException('OCR 처리 중 오류가 발생했습니다: $error');
    } finally {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  Future<OCRResult> _extractWithFallback(
    Uint8List imageBytes,
    TextRecognitionScript targetScript,
  ) async {
    debugPrint('🔍 Fallback TextRecognizer 사용');
    final TextRecognizer fallbackRecognizer = TextRecognizer();
    final File tempFile = File(
      '${Directory.systemTemp.path}/ocr_fallback_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    try {
      await tempFile.writeAsBytes(imageBytes, flush: true);
      final InputImage inputImage = InputImage.fromFilePath(tempFile.path);
      final RecognizedText result = await fallbackRecognizer.processImage(inputImage);

      if (result.text.isNotEmpty) {
        final String normalized = _normalizeText(result.text);
        final List<String> blocks = result.blocks
            .map((TextBlock block) => block.text.trim())
            .where((String text) => text.isNotEmpty)
            .toList();

        return OCRResult(
          fullText: normalized,
          textBlocks: blocks,
          confidence: 0.6,
        );
      }

      return OCRResult.empty();
    } catch (error) {
      debugPrint('❌ Fallback OCR 실패: $error');
      return OCRResult.empty();
    } finally {
      await fallbackRecognizer.close();
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  Future<OCRResult> _withGuardedProcessing(
    TextRecognitionScript script,
    Future<OCRResult> Function() action,
  ) async {
    if (_isDisposed) {
      throw const OCRException('OCR 서비스가 해제되었습니다.');
    }

    if (_processingCount >= _maxConcurrentProcessing) {
      throw const OCRException('OCR 처리 중입니다. 잠시 후 다시 시도해주세요.');
    }

    if (!isInitialized) {
      final bool initialized = await initialize();
      if (!initialized) {
        throw const OCRException('OCR 서비스를 초기화할 수 없습니다.');
      }
    }

    await _ensureRecognizer(script);

    _processingCount++;
    try {
      return await action();
    } finally {
      _processingCount--;
    }
  }

  Future<void> _ensureRecognizer(TextRecognitionScript script) async {
    if (_recognizers.containsKey(script)) {
      return;
    }
    try {
      final TextRecognizer recognizer = TextRecognizer(script: script);
      _recognizers[script] = recognizer;
      debugPrint('✅ ${script.name} recognizer 초기화');
    } on ArgumentError catch (error) {
      debugPrint('⚠️ ${script.name} 스크립트 초기화 실패: $error');
    } catch (error, stackTrace) {
      debugPrint('⚠️ ${script.name} 초기화 중 알 수 없는 오류: $error');
      debugPrint(stackTrace.toString());
    }
  }

  void _validateSize(int length) {
    if (length == 0) {
      throw const OCRException('이미지 데이터가 비어있습니다.');
    }
    if (length > _maxImageBytes) {
      throw OCRException(
        '이미지 데이터가 너무 큽니다. (최대 ${( _maxImageBytes / (1024 * 1024)).toStringAsFixed(1)}MB)',
      );
    }
  }

  String _normalizeText(String text) {
    final String normalized = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return normalized;
  }

  double _calculateAverageConfidence(
    RecognizedText text,
    TextRecognitionScript script,
  ) {
    if (text.text.isEmpty) {
      return 0;
    }

    double baseConfidence = 0.7;
    switch (script) {
      case TextRecognitionScript.korean:
        baseConfidence = 0.85;
        break;
      case TextRecognitionScript.latin:
        baseConfidence = 0.8;
        break;
      case TextRecognitionScript.japanese:
      case TextRecognitionScript.chinese:
        baseConfidence = 0.75;
        break;
      default:
        baseConfidence = 0.7;
    }

    if (text.text.length > 100 && text.blocks.length > 2) {
      baseConfidence += 0.1;
    }

    return baseConfidence.clamp(0.0, 1.0);
  }

  _OptimizedImage _optimizeImageForScript(
    Uint8List bytes,
    TextRecognitionScript script,
  ) {
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const OCRException('이미지 디코딩에 실패했습니다.');
    }

    img.Image processed = decoded;

    switch (script) {
      case TextRecognitionScript.latin:
        processed = img.copyResize(decoded, width: 1200, height: 900);
        processed = img.adjustColor(
          processed,
          contrast: 1.3,
          brightness: 1.1,
          saturation: 0.8,
        );
        processed = img.grayscale(processed);
        break;
      case TextRecognitionScript.korean:
        processed = img.copyResize(decoded, width: 900, height: 1200);
        processed = img.adjustColor(processed, contrast: 1.4, brightness: 1.1);
        processed = img.grayscale(processed);
        break;
      case TextRecognitionScript.japanese:
        processed = img.copyResize(decoded, width: 1000, height: 1200);
        processed = img.adjustColor(processed, contrast: 1.4, brightness: 1.05);
        processed = img.grayscale(processed);
        break;
      case TextRecognitionScript.chinese:
        processed = img.copyResize(decoded, width: 1000, height: 800);
        processed = img.adjustColor(processed, contrast: 1.3, brightness: 1.1);
        processed = img.grayscale(processed);
        break;
      default:
        processed = img.copyResize(decoded, width: 900, height: 900);
        processed = img.grayscale(processed);
    }

    return _OptimizedImage(
      bytes: Uint8List.fromList(img.encodeJpg(processed, quality: 90)),
      width: processed.width,
      height: processed.height,
    );
  }
}

class _OptimizedImage {
  const _OptimizedImage({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final int? width;
  final int? height;
}

class OCRResult {
  const OCRResult({
    required this.fullText,
    required this.textBlocks,
    required this.confidence,
  });

  final String fullText;
  final List<String> textBlocks;
  final double confidence;

  static OCRResult empty() => const OCRResult(
        fullText: '',
        textBlocks: <String>[],
        confidence: 0.0,
      );

  String get safeText {
    if (fullText.isNotEmpty) {
      return fullText;
    }
    if (textBlocks.isNotEmpty) {
      return textBlocks.join('\n');
    }
    return '';
  }

  bool get isValid => safeText.trim().isNotEmpty;

  @override
  String toString() =>
      'OCRResult(full:${fullText.length}, blocks:${textBlocks.length}, conf:${confidence.toStringAsFixed(2)})';
}

class OCRException implements Exception {
  const OCRException(this.message);

  final String message;

  @override
  String toString() => 'OCRException: $message';
}
