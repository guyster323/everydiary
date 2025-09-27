# EveryDiary Refactor Plan

## ✅ 완료된 작업

- **Step 1 – AI 이미지 서비스 안정화**
  - `ImageGenerationResult`의 `metadata`를 null-safe/불변 처리.
  - `flutter analyze` 실행으로 관련 오류가 제거되었음을 확인.
- **Step 2 – IndexedDB 및 웹 전용 로직 정리**
  - `indexed_db_service_web.dart` 삭제 및 조건부 import 정리.
  - `offline_sync_service_web.dart`를 Stub 구현으로 단순화.
  - 삭제된 기능 사용처 점검 후 lint 재실행.
- **Step 3 – Riverpod 구조 재정비**
  - `@riverpod` 기반 Provider 및 `.g.dart` 제거.
  - `hooks_riverpod` 기반 수동 Provider/Notifier로 재작성.
  - 리팩터링 이후 `flutter analyze` clean 확인.

## ⏳ 남은 작업

1. **Step 4 – 잔여 lint/info 정리**
   - `withOpacity` → `.withValues(alpha: …)` 변환.
   - `dart:html`, `dart:js` 의존 및 Deprecated Ref 경고 제거.
   - 최종 `flutter analyze` clean 확인.

## 빌드 관련 메모

- API 키는 `android/app/build.gradle`의 `buildConfigField`를 통해 주입.
- 로컬 빌드 시 PowerShell에서 환경변수 설정 후 `flutter run` 실행 필요.
