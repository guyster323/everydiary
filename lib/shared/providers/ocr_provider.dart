import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/ocr_service.dart';

part 'ocr_provider.g.dart';

/// OCR 서비스 프로바이더
@riverpod
class OCRService extends _$OCRService {
  @override
  OCRService build() {
    return OCRService();
  }

  /// OCR 서비스 초기화
  Future<void> initialize() async {
    await state.initialize();
  }

  /// 서비스 해제
  Future<void> dispose() async {
    await state.dispose();
  }

  /// 이미지 파일에서 텍스트 추출
  Future<OCRResult> extractTextFromFile(String imagePath) async {
    return await state.extractTextFromFile(imagePath);
  }

  /// 이미지 바이트 데이터에서 텍스트 추출
  Future<OCRResult> extractTextFromBytes(Uint8List imageBytes) async {
    return await state.extractTextFromBytes(imageBytes);
  }

  /// 이미지 전처리
  Future<Uint8List> preprocessImage(Uint8List imageBytes) async {
    return await state.preprocessImage(imageBytes);
  }
}

/// OCR 결과 상태 관리 프로바이더
@riverpod
class OCRResultState extends _$OCRResultState {
  @override
  OCRResult? build() {
    return null;
  }

  /// OCR 결과 설정
  void setResult(OCRResult result) {
    state = result;
  }

  /// OCR 결과 초기화
  void clearResult() {
    state = null;
  }
}

/// OCR 처리 상태 프로바이더
@riverpod
class OCRProcessingState extends _$OCRProcessingState {
  @override
  bool build() {
    return false;
  }

  /// 처리 중 상태 설정
  void setProcessing(bool isProcessing) {
    state = isProcessing;
  }
}

/// OCR 설정 프로바이더
@riverpod
class OCRSettings extends _$OCRSettings {
  @override
  OCRConfig build() {
    return const OCRConfig();
  }

  /// 설정 업데이트
  void updateSettings(OCRConfig config) {
    state = config;
  }

  /// 전처리 활성화/비활성화
  void togglePreprocessing() {
    state = state.copyWith(enablePreprocessing: !state.enablePreprocessing);
  }

  /// 신뢰도 임계값 설정
  void setConfidenceThreshold(double threshold) {
    state = state.copyWith(confidenceThreshold: threshold);
  }

  /// 언어 설정 변경
  void setLanguage(TextRecognitionScript script) {
    state = state.copyWith(script: script);
  }
}

/// OCR 설정 데이터 클래스
class OCRConfig {
  final bool enablePreprocessing;
  final double confidenceThreshold;
  final TextRecognitionScript script;
  final bool autoSaveResults;
  final bool showBoundingBoxes;

  const OCRConfig({
    this.enablePreprocessing = true,
    this.confidenceThreshold = 0.6,
    this.script = TextRecognitionScript.korean,
    this.autoSaveResults = false,
    this.showBoundingBoxes = false,
  });

  OCRConfig copyWith({
    bool? enablePreprocessing,
    double? confidenceThreshold,
    TextRecognitionScript? script,
    bool? autoSaveResults,
    bool? showBoundingBoxes,
  }) {
    return OCRConfig(
      enablePreprocessing: enablePreprocessing ?? this.enablePreprocessing,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      script: script ?? this.script,
      autoSaveResults: autoSaveResults ?? this.autoSaveResults,
      showBoundingBoxes: showBoundingBoxes ?? this.showBoundingBoxes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OCRConfig &&
        other.enablePreprocessing == enablePreprocessing &&
        other.confidenceThreshold == confidenceThreshold &&
        other.script == script &&
        other.autoSaveResults == autoSaveResults &&
        other.showBoundingBoxes == showBoundingBoxes;
  }

  @override
  int get hashCode {
    return Object.hash(
      enablePreprocessing,
      confidenceThreshold,
      script,
      autoSaveResults,
      showBoundingBoxes,
    );
  }
}
