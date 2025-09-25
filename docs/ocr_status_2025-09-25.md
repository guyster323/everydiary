## OCR 개선 작업 정리 (2025-09-25)

### 1. 진행한 개선 사항
- `SimpleCameraScreen`에 OCR 결과 유효성 검증 로직 추가
  - 의미 없는 결과(`"."`, 반복 문자, 특수문자 등) 필터링
  - 사용자에게 재시도 안내
- `DiaryWriteScreen`에서 OCR 텍스트 병합 시 Delta JSON 유효성 검증 강화
  - `SafeDeltaConverter`를 활용한 텍스트 추출 및 폴백 로직 추가
- `OCRService` 전면 개편
  - 그레이스케일 변환, 대비/밝기 강화, PNG 인코딩을 이용한 전처리 강화
  - 보수적 전처리 및 원본 이미지 재시도 포함한 5단계 폴백 구현
  - ML Kit 초기화/해제 로깅 및 예외 처리 강화
- Android Gradle 설정 업데이트
  - `com.google.mlkit:text-recognition-korean:16.0.0` 의존성 추가 (한국어 모델 직접 포함 시도)
- 테스트 및 실행 자동화
  - `flutter test` 재실행 → 모든 테스트 통과 확인
  - `flutter run` + `flutter logs`로 에뮬레이터 동작과 로그 모니터링 확인

### 2. 현재 관찰되는 현상 (Flutter 로그 기반)
- VisionKit 파이프라인이 여전히 `Latn` 모델을 선로드하며, `korean` 모델이 활성화되지 않음
- OCR 결과가 `"."` 또는 빈 문자열로만 추출되며, `block count == 0`
- ML Kit 로그에 `mlkit-google-ocr-models/.../Latn_ctc/optical/...` 경로가 반복적으로 등장
- `text-recognition-korean` 의존성을 추가했지만, 현재 Flutter 플러그인 (`google_mlkit_text_recognition`)은 최신 VisionKit 파이프라인을 강제로 사용하고 있어 한국어 모델로 전환되지 않음

### 3. 원인 가설
1. **플러그인 한계**: `google_mlkit_text_recognition` 0.13.x는 `TextRecognitionScript.korean`을 노출하지만, 실제 안드로이드 측 구현에서 VisionKit 파이프라인을 활용하면서 한국어 모델 로딩을 지원하지 않음
2. **플랫폼 제약**: VisionKit 파이프라인이 `Latn` 전용 모델을 우선적으로 사용하며, 한국어 모델 지원은 최신 플레이 서비스/ML Kit 버전에서만 가능할 수 있음
3. **아키텍처 제한**: 에뮬레이터 (x86
e64) 환경에서 한글 모델이 비활성화되어 있을 가능성

### 4. 대응 전략 제안
| 우선순위 | 방안 | 설명 |
| --- | --- | --- |
| ▲ | **플러그인 업데이트 조사** | `google_mlkit_text_recognition` 0.15.0 이상 또는 `google_mlkit_text_recognition_korean` 별도 패키지 등장 여부 조사 |
| ▲ | **안드로이드 네이티브 채널 구현** | Flutter에서 직접 ML Kit Android API(`TextRecognizerOptions.Builder().setExecutor`, `KoreanTextRecognizerOptions`)를 호출하는 네이티브 채널 작성 |
| ▲ | **Device/서비스 변경 검토** | 실제 기기 또는 Google ML Kit 최신 Play Service 환경에서 재확인, 필요 시 Cloud Vision API로 폴백 |
| △ | **Tesseract 등 대체 엔진 검토** | 오프라인 대체 OCR 엔진 탐색 (성능/용량 고려 필요) |

### 5. 차기 작업 제안 (우선순위 순)
1. `google_mlkit_text_recognition` 최신 버전(0.15.x) 및 관련 Kotlin API 구현 확인 → 스크립트 지정 가능 여부 검토
2. 안드로이드 네이티브 코드에서 `TextRecognizer`를 직접 생성하고 Flutter로 결과 전달하는 커스텀 플러그인 구현 PoC
3. 실제 안드로이드 물리 디바이스에서 한국어 인식 여부 재확인 (에뮬레이터 한계 가능성 배제)
4. 장기적으로는 OCR 품질 향상을 위해 Cloud Vision API 또는 다른 상용 OCR 서비스 도입 검토

### 6. 참고 로그 스니펫
```
D/PipelineManager: OCR process succeeded via visionkit pipeline.
I/native: ... Loading mlkit-google-ocr-models/gocr/gocr_models/line_recognition_legacy_mobile/Latn_ctc/optical...
I/flutter: 🔍 Raw OCR 텍스트 길이: 1
I/flutter: 🔍 OCR 결과: .
```

> 위 현상으로 보아 VisionKit이 라틴 파이프라인을 고정적으로 로드하며, 한국어 모델을 반영하지 못하고 있습니다. 상기 대응 전략을 기준으로 내일 후속 조치를 진행하는 것을 권장드립니다.
