# 내일 작업 TODO - EveryDiary

## 📅 날짜: 2025-11-12

---

## 🎯 오늘(2025-11-11) 완료된 작업

### 1. 회상 페이지 로컬라이제이션 ✅
- **Badge 텍스트 로컬라이징**
  - '어제의 기록', '이 시간의 기록' 등 → 다국어 지원
  - `memory_card.dart` 수정: `_getMemoryReasonText()` 메서드 추가

- **필터 버튼 로컬라이징**
  - '전체', '어제', '일주일 전', '한달 전', '계절별' 등 → 다국어 지원
  - `memory_type_selector.dart` 수정: `_getTypeDisplayName()` 메서드 수정

- **로컬라이제이션 키 추가** (`app_localizations.dart`)
  - `memory_type_*` 시리즈 (9개 키)
  - `memory_reason_*` 시리즈 (9개 키)
  - 한국어, 영어, 일본어, 중국어(간체/번체) 총 4개 언어 지원

### 2. 광고 보상 시스템 개선 ✅
- **생성 횟수 조정**
  - 광고 시청 보상: 3회 → 1회로 감소
  - `image_generation_purchase_dialog.dart` 수정
  - `countService.addGenerations(3)` → `addGenerations(1)`

- **문구 수정**
  - "광고 보고 3회 받기" → "광고 보고 1회 더 받기"
  - "3 times" → "1 time more" 형식으로 변경
  - 로컬라이제이션 키: `watch_ad_for_1_time`, `ad_reward_success`

### 3. Git 커밋 및 업로드 ✅
- 커밋 ID: `587adaa`
- 커밋 메시지: "refactor: localize memory feature and reduce ad reward to 1 generation"
- 변경 파일: 8개
- GitHub 업로드 완료

---

## 📋 내일(2025-11-12) 작업 계획

### 🔴 우선순위 1: OCR 및 음성 인식 기능 로컬라이제이션 (2시간)

#### Task 1.1: OCR 관련 텍스트 로컬라이징
**목표**: OCR 기능의 모든 사용자 표시 텍스트를 다국어로 지원

**작업 단계**:
1. **OCR 기능 파일 탐색 및 분석** (30분)
   - [ ] OCR 관련 파일 찾기 (예상 위치)
     ```
     lib/features/diary/widgets/diary_rich_text_editor.dart
     lib/features/diary/services/ocr_service.dart (있다면)
     lib/features/ocr/ (디렉토리가 있다면)
     ```
   - [ ] 하드코딩된 한글 텍스트 식별
   - [ ] OCR 사용 UI 확인 (버튼, 다이얼로그, 에러 메시지 등)

2. **로컬라이제이션 키 추가** (20분)
   - [ ] `app_localizations.dart`에 OCR 관련 키 추가
     ```dart
     // 예상 필요 키
     'ocr_button': 'OCR로 텍스트 추출',
     'ocr_button_en': 'Extract Text',
     'ocr_processing': '이미지에서 텍스트를 추출하는 중...',
     'ocr_success': '텍스트 추출 완료',
     'ocr_failed': 'OCR 처리 실패',
     'ocr_no_text': '추출된 텍스트가 없습니다',
     'ocr_permission_required': '카메라 권한이 필요합니다',
     'ocr_select_source': '이미지 소스 선택',
     'ocr_camera': '카메라',
     'ocr_gallery': '갤러리',
     ```
   - [ ] 영어, 일본어, 중국어 번역 추가

3. **OCR UI 파일 수정** (40분)
   - [ ] 하드코딩된 문자열 → `l10n.get()` 변경
   - [ ] Widget을 ConsumerWidget/ConsumerStatefulWidget으로 변환 (필요시)
   - [ ] `localizationProvider` 추가
   - [ ] 모든 사용자 표시 텍스트 교체

4. **테스트 및 검증** (30분)
   - [ ] 4개 언어로 앱 실행하여 OCR 기능 테스트
   - [ ] 모든 텍스트가 올바르게 표시되는지 확인
   - [ ] 에러 메시지도 로컬라이징 되었는지 확인

#### Task 1.2: 음성 인식 관련 텍스트 로컬라이징
**목표**: 음성 인식 기능의 모든 사용자 표시 텍스트를 다국어로 지원

**작업 단계**:
1. **음성 인식 기능 파일 탐색** (20분)
   - [ ] 음성 인식 관련 파일 찾기 (예상 위치)
     ```
     lib/features/diary/widgets/diary_rich_text_editor.dart
     lib/features/diary/services/voice_recognition_service.dart (있다면)
     lib/features/voice/ (디렉토리가 있다면)
     ```
   - [ ] 하드코딩된 한글 텍스트 식별

2. **로컬라이제이션 키 추가** (20분)
   - [ ] `app_localizations.dart`에 음성 인식 관련 키 추가
     ```dart
     // 예상 필요 키
     'voice_button': '음성으로 입력',
     'voice_button_en': 'Voice Input',
     'voice_listening': '듣는 중...',
     'voice_processing': '음성을 텍스트로 변환 중...',
     'voice_success': '음성 입력 완료',
     'voice_failed': '음성 인식 실패',
     'voice_permission_required': '마이크 권한이 필요합니다',
     'voice_not_available': '음성 인식을 사용할 수 없습니다',
     'voice_tap_to_speak': '말하기 시작하려면 탭하세요',
     'voice_tap_to_stop': '중지하려면 탭하세요',
     ```
   - [ ] 영어, 일본어, 중국어 번역 추가

3. **음성 인식 UI 파일 수정** (30분)
   - [ ] 하드코딩된 문자열 → `l10n.get()` 변경
   - [ ] Widget 구조 변환 (필요시)
   - [ ] `localizationProvider` 추가

4. **테스트 및 검증** (20분)
   - [ ] 다국어 환경에서 음성 인식 테스트
   - [ ] 권한 요청 메시지 확인
   - [ ] 에러 처리 메시지 확인

---

### 🟡 우선순위 2: OCR 사용 시 PIN 재요구 문제 개선 (1.5시간)

#### 현재 문제점 분석
**증상**: OCR 기능을 사용할 때마다 PIN을 다시 요구함
**원인**: (예상)
- 백그라운드/포그라운드 전환 시 세션 만료
- OCR 처리 중 앱이 일시정지 상태로 전환
- 보안 설정이 너무 엄격하게 구성됨

#### 해결 방안 옵션

**Option A: 세션 기반 인증 유지 (권장)**
- **장점**: 자연스러운 사용자 경험, 보안 유지
- **단점**: 구현 복잡도 중간
- **구현 내용**:
  1. [ ] `lib/shared/services/session_service.dart` 확인
  2. [ ] 세션 타임아웃 설정 확인 (현재 값)
  3. [ ] OCR 사용 중에는 세션 유지하도록 수정
  4. [ ] 백그라운드 전환 시 일정 시간(예: 5분) 동안 세션 유지
  5. [ ] 테스트: OCR → 다른 앱 전환 → 복귀 시 PIN 요구 안 함

**Option B: OCR 전용 권한 캐싱**
- **장점**: OCR 사용성 대폭 향상
- **단점**: 보안 취약점 가능성
- **구현 내용**:
  1. [ ] OCR 권한 캐시 플래그 추가
  2. [ ] PIN 입력 후 일정 시간(예: 30분) 동안 OCR 사용 시 PIN 생략
  3. [ ] 캐시 만료 시간 설정 추가
  4. [ ] 테스트 및 보안 검토

**Option C: 사용자 설정 추가**
- **장점**: 사용자가 보안 수준 선택 가능
- **단점**: UI 복잡도 증가
- **구현 내용**:
  1. [ ] 설정 화면에 "OCR 사용 시 PIN 생략" 옵션 추가
  2. [ ] `lib/features/settings/models/settings_model.dart` 수정
  3. [ ] `settings_provider.dart`에 로직 추가
  4. [ ] PIN 요구 로직 수정
  5. [ ] 테스트

#### 추천 접근법: **Option A (세션 기반 인증)**
- 보안과 사용성의 균형
- 기존 세션 관리 시스템 활용
- 사용자 혼란 최소화

#### 작업 단계 (Option A 기준)
1. **세션 관리 분석** (30분)
   - [ ] `lib/shared/services/session_service.dart` 읽기
   - [ ] PIN 인증 로직 확인
   - [ ] 세션 만료 조건 파악
   - [ ] OCR 호출 시점의 세션 상태 로깅

2. **세션 유지 로직 구현** (40분)
   - [ ] `SessionService`에 `extendSession()` 메서드 추가
   - [ ] OCR 시작 시 세션 연장 호출
   - [ ] 백그라운드 전환 시 타임아웃 증가 (예: 5분)
   - [ ] 세션 만료 시간 설정 추가

3. **PIN 요구 로직 수정** (20분)
   - [ ] `lib/features/security/screens/pin_unlock_screen.dart` 확인
   - [ ] OCR 컨텍스트에서는 짧은 타임아웃 적용
   - [ ] 디버그 로그 추가

4. **테스트 및 검증** (30분)
   - [ ] 시나리오 1: OCR 사용 → 대기 → 다시 OCR (PIN 요구 안 함)
   - [ ] 시나리오 2: OCR 사용 → 다른 앱 전환 → 복귀 → OCR (PIN 요구 안 함)
   - [ ] 시나리오 3: 5분 이상 대기 → OCR (PIN 요구됨)
   - [ ] 보안 취약점 확인

---

## 📁 예상 수정 파일 목록

### OCR 로컬라이제이션
```
lib/core/l10n/app_localizations.dart                    # 로컬라이제이션 키 추가
lib/features/diary/widgets/diary_rich_text_editor.dart  # OCR 버튼 UI
lib/features/diary/services/ocr_service.dart            # OCR 서비스 (있다면)
lib/features/ocr/*.dart                                 # OCR 관련 파일들
```

### 음성 인식 로컬라이제이션
```
lib/core/l10n/app_localizations.dart                    # 로컬라이제이션 키 추가
lib/features/diary/widgets/diary_rich_text_editor.dart  # 음성 버튼 UI
lib/features/diary/services/voice_recognition_service.dart  # 음성 서비스 (있다면)
lib/features/voice/*.dart                               # 음성 관련 파일들
```

### PIN 재요구 개선
```
lib/shared/services/session_service.dart                # 세션 관리
lib/features/security/screens/pin_unlock_screen.dart    # PIN 입력 화면
lib/features/security/services/pin_service.dart         # PIN 서비스 (있다면)
lib/features/settings/models/settings_model.dart        # 설정 모델 (Option C)
lib/features/settings/providers/settings_provider.dart  # 설정 프로바이더 (Option C)
```

---

## ⏱️ 예상 소요 시간

| 작업 | 예상 시간 | 우선순위 |
|------|----------|---------|
| OCR 텍스트 로컬라이징 | 2시간 | 🔴 높음 |
| 음성 인식 텍스트 로컬라이징 | 1.5시간 | 🔴 높음 |
| PIN 재요구 문제 분석 | 30분 | 🟡 중간 |
| PIN 재요구 문제 해결 | 1시간 | 🟡 중간 |
| 테스트 및 검증 | 1시간 | 🟢 낮음 |
| **총 예상 시간** | **6시간** | - |

---

## 🎯 작업 완료 체크리스트

### ✅ 우선순위 1: OCR/음성 로컬라이제이션
- [ ] OCR 관련 파일 탐색 및 분석
- [ ] OCR 로컬라이제이션 키 추가 (4개 언어)
- [ ] OCR UI 파일 수정
- [ ] 음성 인식 관련 파일 탐색
- [ ] 음성 인식 로컬라이제이션 키 추가 (4개 언어)
- [ ] 음성 인식 UI 파일 수정
- [ ] 다국어 환경에서 테스트

### ✅ 우선순위 2: PIN 재요구 개선
- [ ] 세션 관리 로직 분석
- [ ] 세션 유지 메커니즘 구현
- [ ] PIN 요구 로직 수정
- [ ] 다양한 시나리오 테스트
- [ ] 보안 취약점 확인

### ✅ 우선순위 3: Git 관리
- [ ] 변경사항 커밋 (OCR/음성 로컬라이제이션)
- [ ] 변경사항 커밋 (PIN 재요구 개선)
- [ ] GitHub 업로드
- [ ] 다음 TODO 파일 작성

---

## 💡 참고 사항

### 로컬라이제이션 베스트 프랙티스
1. **일관성 유지**: 기존 로컬라이제이션 키 네이밍 규칙 따르기
   - `feature_action_context` 형식 (예: `ocr_button_camera`)

2. **번역 품질**:
   - 영어: 자연스러운 표현 사용
   - 일본어: 경어 사용, 간결하게
   - 중국어: 간체/번체 구분 (현재 간체만 지원 중)

3. **테스트 커버리지**:
   - 각 언어로 전환하여 UI 깨짐 확인
   - 긴 텍스트가 UI를 벗어나지 않는지 확인

### 보안 고려사항
1. **세션 타임아웃**:
   - 너무 짧으면 사용성 저하
   - 너무 길면 보안 취약
   - **권장**: 활성 사용 시 5분, 백그라운드 1분

2. **PIN 재입력 시나리오**:
   - 앱 종료 후 재실행: PIN 필수
   - 설정 변경: PIN 필수
   - 민감한 데이터 접근: PIN 필수
   - OCR/음성 인식: 세션 유효 시 생략 가능

---

## 📝 커밋 메시지 템플릿

### OCR/음성 로컬라이제이션 완료 시
```
feat: localize OCR and voice recognition features

Major Changes:
- Added localization keys for OCR feature (10+ keys)
- Added localization keys for voice recognition (10+ keys)
- Updated diary_rich_text_editor.dart to use localizationProvider
- Converted widgets to ConsumerWidget for l10n access
- Replaced all hardcoded Korean strings with l10n.get() calls

Localization:
- Korean: OCR/음성 인식 관련 텍스트
- English: OCR/voice recognition texts
- Japanese: OCR/音声認識 texts
- Chinese: OCR/语音识别 texts

Files Modified:
- lib/core/l10n/app_localizations.dart
- lib/features/diary/widgets/diary_rich_text_editor.dart
- lib/features/diary/services/ocr_service.dart (if exists)
- lib/features/diary/services/voice_recognition_service.dart (if exists)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### PIN 재요구 개선 완료 시
```
fix: improve PIN re-authentication flow for OCR/voice features

Problem:
- PIN was requested every time OCR/voice recognition was used
- Session expired too quickly during media processing
- Poor user experience with frequent re-authentication

Solution:
- Extended session timeout during active OCR/voice processing
- Implemented session extension mechanism in SessionService
- Background transitions now maintain session for 5 minutes
- OCR/voice context maintains session without re-authentication

Changes:
- lib/shared/services/session_service.dart: Added extendSession() method
- lib/features/security/screens/pin_unlock_screen.dart: Context-aware timeout
- Added debug logging for session state transitions

Testing:
- Verified OCR usage without PIN re-prompt within session
- Tested background/foreground transitions
- Confirmed security timeout after extended inactivity

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## 🔍 디버깅 가이드

### OCR 관련 로그 확인
```bash
# OCR 관련 로그 필터링
adb logcat | grep -i "ocr"

# 권한 관련 로그
adb logcat | grep -i "permission"
```

### 세션 관리 로그 확인
```bash
# 세션 관련 로그
adb logcat | grep -i "session"

# PIN 인증 로그
adb logcat | grep -i "pin"
```

### 문제 발생 시 체크리스트
1. [ ] Flutter analyze 실행하여 경고 확인
2. [ ] 로컬라이제이션 키가 모든 언어에 추가되었는지 확인
3. [ ] ConsumerWidget 변환 시 ref 파라미터 추가했는지 확인
4. [ ] import 문에 `flutter_riverpod/flutter_riverpod.dart` 포함되었는지 확인

---

**작성일**: 2025-11-11 23:00
**다음 작업일**: 2025-11-12
**예상 소요 시간**: 6시간
**우선순위**: 🔴 높음
