# Changelog - 2025년 12월 19일

## 커밋된 변경사항 (Recent Commits)

### v1.0.2+5 (8a93a81)
- **알림 시스템 버그 수정** - 메모리 알림 서비스 안정화
- **앱 아이콘 업데이트** - Android/iOS/Web 아이콘 전체 교체

### 이미지 생성 API 변경 이력
- `e704673`: AI 이미지 생성 API 엔드포인트 업데이트
- `3176cd1`: Gemini Imagen 3.0 API 요청/응답 포맷 수정
- `21009da`: Imagen 3.0 → Gemini 2.0 Flash Experimental로 변경
- `6607ea1`: 코드 경고 및 deprecation 해결

### Lite 버전 전환
- `d47d3a4`: 구독 시스템 제거 및 Lite (무료) 버전으로 전환
- `750c7fc`: 인앱 결제 권한 제거

---

## 미커밋 변경사항 (Uncommitted Changes)

### 수정된 파일 목록

| 파일 | 변경 내용 |
|------|----------|
| `lib/core/services/image_generation_service.dart` | AI 이미지 생성 서비스 로직 개선 |
| `lib/core/providers/image_generation_provider.dart` | 이미지 생성 프로바이더 상태 관리 개선 |
| `lib/features/home/widgets/generation_count_widget.dart` | 생성 횟수 위젯 UI 개선 |
| `lib/shared/services/ad_service.dart` | 광고 서비스 로직 수정 |
| `lib/shared/widgets/banner_ad_widget.dart` | 배너 광고 위젯 개선 |
| `lib/features/settings/screens/settings_screen.dart` | 설정 화면 UI 개선 |
| `lib/features/settings/widgets/thumbnail_style_selector.dart` | 썸네일 스타일 선택기 대폭 간소화 |
| `lib/features/diary/screens/diary_list_screen.dart` | 일기 목록 화면 개선 |
| `lib/features/ocr/screens/camera_screen.dart` | 카메라 화면 코드 정리 (362줄 → 간소화) |
| `lib/features/recommendations/services/memory_notification_service.dart` | 메모리 알림 서비스 수정 |
| `lib/core/l10n/app_localizations.dart` | 다국어 지원 추가 |
| `lib/core/constants/app_constants.dart` | 앱 상수 업데이트 |
| `lib/core/services/screen_security_service.dart` | 화면 보안 서비스 수정 |
| `lib/core/services/user_customization_service.dart` | 사용자 커스터마이징 서비스 개선 |
| `lib/main.dart` | 앱 초기화 로직 수정 |
| `pubspec.yaml` | 의존성 업데이트 |

### Android 변경사항
- `android/app/src/main/AndroidManifest.xml` - 매니페스트 수정
- `android/app/src/main/kotlin/com/everydiary/app/MainActivity.kt` 삭제
- `android/app/src/main/kotlin/com/everydiary/lite/` 새 패키지 추가

### 새로 추가된 파일
- `EverydiaryLite.aab` - 릴리즈 번들
- `app-ads.txt` - 광고 인증 파일
- `crash_log.txt` - 크래시 로그
- `android/app/src/main/res/values-night-v35/` - 다크 테마 리소스
- `android/app/src/main/res/values-v35/` - Android 15 리소스

---

## 오늘 완료된 작업

### AI 이미지 생성 모델 변경 ✅
- **변경 전**: `gemini-2.5-flash-image-preview` (곧 만료 예정)
- **변경 후**: `imagen-3.0-generate-002`
- **API Key**: 기존 Gemini API Key 유지
- **수정 파일**: `lib/core/services/image_generation_service.dart`

### 변경 내용
1. API 엔드포인트 변경:
   - 이전: `gemini-2.5-flash-image:generateContent`
   - 변경: `imagen-3.0-generate-002:predict`

2. 요청 Body 구조 변경:
   ```json
   // 이전 (Gemini)
   {
     "contents": [{"parts": [{"text": "..."}]}],
     "generationConfig": {...}
   }

   // 변경 (Imagen 3.0)
   {
     "instances": [{"prompt": "..."}],
     "parameters": {"sampleCount": 1, "aspectRatio": "1:1"}
   }
   ```

3. 응답 파싱 로직 변경:
   - `predictions[].bytesBase64Encoded` 형식 지원
   - `generated_images[].image.imageBytes` 형식 지원 (대체)

### 변경 이유
- `gemini-2.5-flash-image-preview` 모델이 실험적(experimental) 모델로 곧 만료될 예정
- `imagen-3.0-generate-002`는 Google의 공식 이미지 생성 모델로 안정적

---

## 기술 스택
- **Framework**: Flutter
- **Language**: Dart
- **AI Services**: Google Gemini API, Hugging Face API
- **Target Platforms**: Android, iOS, Web, macOS
