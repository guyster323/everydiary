# OCR 개선 시도 내역 및 결과 분석

## 개요

Flutter EveryDiary 앱의 OCR(Optical Character Recognition) 기능 개선을 위한 다양한 시도와 결과를 정리한 문서입니다.

## 문제 상황

- **한국어 OCR**: 정상 동작 ✅
- **영어 OCR**: 품질 저하 ⚠️ (인식률 낮음, 오타 많음)
- **일본어/중국어 OCR**: 앱 크래시 ❌ (`AbstractMethodError` 발생)

## 시도한 개선 방법들

### 1. 언어별 전처리 파이프라인 분기

**목적**: 각 언어의 특성에 맞는 이미지 전처리 적용

**구현 내용**:

```dart
// lib/shared/services/ocr_service.dart
img.Image _applyLanguagePreprocessing(
  img.Image image, {
  required OCRLanguageOption language,
}) {
  switch (language.code) {
    case 'ko': // 한국어
      final grayscale = img.grayscale(image);
      final contrasted = img.adjustColor(
        grayscale,
        contrast: 1.8,
        brightness: 1.15,
      );
      return img.adjustColor(contrasted, contrast: 1.2, brightness: 1.05);

    case 'ja': // 일본어
      final grayscale = img.grayscale(image);
      final contrasted = img.adjustColor(
        grayscale,
        contrast: 1.5,
        brightness: 1.05,
      );
      return img.gaussianBlur(contrasted, radius: 1);

    case 'zh': // 중국어
      final grayscale = img.grayscale(image);
      return img.adjustColor(grayscale, contrast: 1.4, brightness: 1.1);

    case 'en': // 영어
      final grayscale = img.grayscale(image);
      return img.adjustColor(grayscale, contrast: 1.3, brightness: 1.05);

    default:
      return img.adjustColor(image, contrast: 1.2, brightness: 1.05);
  }
}
```

**결과**:

- 한국어: 정상 동작
- 영어: 여전히 품질 저하
- 일본어/중국어: 크래시 지속

### 2. ML Kit 예외 처리 강화

**목적**: OCR 처리 중 발생하는 예외를 안전하게 처리

**구현 내용**:

```dart
// lib/shared/services/ocr_service.dart
Future<RecognizedText> _processInputImage(InputImage inputImage) async {
  try {
    final result = await _textRecognizer!.processImage(inputImage);
    return result;
  } catch (error, stackTrace) {
    debugPrint('🔍 ML Kit OCR 처리 중 오류 발생: $error');
    debugPrint('🔍 Stack trace: $stackTrace');
    throw OCRException('OCR 처리 중 오류가 발생했습니다: $error');
  }
}
```

**결과**: 예외는 처리되지만 근본적인 크래시 문제는 해결되지 않음

### 3. OCR 서비스 재초기화 로직 개선

**목적**: 언어 변경 시 OCR 서비스의 안정적인 재초기화

**구현 내용**:

```dart
Future<bool> initialize({OCRLanguageOption? language}) async {
  if (_isDisposed) {
    debugPrint('🔍 OCR 서비스가 해제됨 - 재초기화 진행');
    _isDisposed = false;
  }

  final OCRLanguageOption languageToUse = language ?? _currentLanguage;
  final bool languageChanged = languageToUse.code != _currentLanguage.code;

  if (languageChanged || !_isInitialized || _textRecognizer == null) {
    // 기존 recognizer 해제
    if (_textRecognizer != null) {
      await _textRecognizer!.close();
      _textRecognizer = null;
    }

    // 새로운 언어로 초기화
    try {
      if (_currentLanguage.script != null) {
        _textRecognizer = TextRecognizer(script: _currentLanguage.script!);
      } else {
        _textRecognizer = TextRecognizer();
      }
    } catch (error, stackTrace) {
      debugPrint('⚠️ ${_currentLanguage.label} 스크립트 초기화 실패: $error');
      _textRecognizer = TextRecognizer();
      _usingFallbackScript = true;
    }
  }
}
```

**결과**: 한국어/영어는 정상 동작, 일본어/중국어는 여전히 크래시

### 4. ML Kit 의존성 버전 조정

**목적**: 버전 충돌로 인한 `AbstractMethodError` 해결

**변경 내용**:

```gradle
// android/app/build.gradle
dependencies {
    coreLibraryDesugaring "com.android.tools:desugar_jdk_libs:2.0.4"
    implementation "com.google.mlkit:text-recognition-korean:16.0.0"
    implementation "com.google.mlkit:text-recognition-japanese:16.0.0-beta6"
    implementation "com.google.mlkit:text-recognition-chinese:16.0.0-beta6"
}
```

**결과**: 빌드는 성공하지만 일본어/중국어 OCR 시 여전히 크래시

### 5. 언어 선택 UI 추가

**목적**: 사용자가 OCR 언어를 선택할 수 있도록 UI 개선

**구현 내용**:

```dart
// lib/features/ocr/screens/simple_camera_screen.dart
DropdownButton<OCRLanguageOption>(
  value: _selectedLanguage,
  items: _languageOptions.map((language) {
    return DropdownMenuItem<OCRLanguageOption>(
      value: language,
      child: Text(language.label),
    );
  }).toList(),
  onChanged: _onLanguageChanged,
)
```

**결과**: UI는 정상 작동하지만 일본어/중국어 선택 시 크래시

## 현재 상태 분석

### 성공한 부분

1. ✅ **한국어 OCR**: 완전히 정상 동작
2. ✅ **UI 개선**: 언어 선택 드롭다운 추가
3. ✅ **빌드 시스템**: Gradle 의존성 문제 해결
4. ✅ **예외 처리**: 기본적인 오류 처리 구현

### 실패한 부분

1. ❌ **일본어/중국어 OCR**: `AbstractMethodError` 지속
2. ❌ **영어 OCR 품질**: 여전히 낮은 인식률
3. ❌ **ML Kit 버전 호환성**: 일본어/중국어 모델과 Flutter 플러그인 간 호환성 문제

## 근본 원인 분석

### 1. 일본어/중국어 크래시 원인

```
java.lang.AbstractMethodError: abstract method "java.lang.String com.google.mlkit.vision.text.TextRecognizerOptionsInterface.getConfigLabel()" on receiver java.lang.Class<com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions>
```

**분석**:

- ML Kit의 일본어/중국어 모델과 Flutter 플러그인 간의 인터페이스 불일치
- `google_mlkit_text_recognition` 플러그인이 최신 ML Kit 모델을 완전히 지원하지 않음
- 베타 버전 의존성(`16.0.0-beta6`)의 불안정성

### 2. 영어 OCR 품질 저하 원인

- **전처리 부족**: 현재 단순한 contrast/brightness 조정만 적용
- **이미지 품질**: 원본 이미지의 해상도, 각도, 조명 등이 OCR 품질에 영향
- **후처리 부족**: 인식된 텍스트의 오타 수정 로직 없음

## 권장 해결 방안

### 1. 일본어/중국어 OCR 크래시 해결

1. **ML Kit 플러그인 업데이트**: `google_mlkit_text_recognition`을 최신 버전으로 업데이트
2. **대안 라이브러리 검토**: Tesseract OCR 등 다른 OCR 라이브러리 고려
3. **네이티브 구현**: Android/iOS 네이티브 코드로 직접 ML Kit 연동

### 2. 영어 OCR 품질 향상

1. **고급 전처리**:
   - 기울기 보정 (deskew)
   - 노이즈 제거
   - 적응적 임계값 (adaptive threshold)
   - 텍스트 영역 감지 및 크롭
2. **후처리 개선**:
   - 오타 패턴 인식 및 수정
   - 단어 경계 정리
   - 문맥 기반 텍스트 보정

### 3. 전체적인 아키텍처 개선

1. **OCR 엔진 분리**: 언어별로 다른 OCR 엔진 사용
2. **폴백 메커니즘**: 주요 언어 실패 시 기본 OCR로 폴백
3. **사용자 피드백**: OCR 결과에 대한 사용자 수정 기능

## 다음 단계

1. **Perplexity AI 활용**: 최신 OCR 기술 및 ML Kit 호환성 문제 해결 방법 조사
2. **대안 OCR 라이브러리 검토**: Tesseract, EasyOCR 등 다른 솔루션 평가
3. **네이티브 구현 검토**: Flutter 플러그인 대신 직접 네이티브 코드 구현
4. **사용자 경험 개선**: OCR 품질이 낮을 때의 대안 제공

## 참고 자료

- [Google ML Kit Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition)
- [Flutter ML Kit Plugin](https://pub.dev/packages/google_mlkit_text_recognition)
- [Tesseract OCR](https://github.com/tesseract-ocr/tesseract)
- [EasyOCR](https://github.com/JaidedAI/EasyOCR)

---

_문서 생성일: 2024년 12월 19일_
_마지막 업데이트: 2024년 12월 19일_
