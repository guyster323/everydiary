# 내일 작업 TODO - EveryDiary

## 📅 날짜: 2025-11-11

---

## 🎯 오늘(2025-11-10) 완료된 작업

### 1. AppIntro 이미지를 Assets으로 변경 ✅
- `lib/core/services/app_intro_service.dart` 수정
  - AI 이미지 생성 로직 제거
  - `assets/images/app_intro/{feature_id}.png` 직접 로드
  - Import 정리 (dart:io, path_provider, ImageGenerationService 제거)

- `lib/features/home/widgets/app_intro_section.dart` 수정
  - "이미지 생성 중" 메시지 제거
  - Progress bar 제거
  - `Image.file` → `Image.asset` 변경
  - dart:io import 제거

### 2. Android 빌드 수정 ✅
- `android/app/src/main/AndroidManifest.xml`
  - AdMob 테스트 App ID 추가

### 3. API Keys 설정 ✅
- `assets/config/secrets.json` 생성
  - Gemini API Key 추가
  - Hugging Face API Key 추가

### 4. Provider 이름 충돌 해결 ✅
- `lib/core/providers/generation_count_provider.dart`
  - `imageGenerationServiceProvider` → `generationCountServiceProvider`로 변경

- `lib/features/diary/widgets/image_generation_purchase_dialog.dart`
  - import 수정
  - provider 사용 코드 수정

### 5. 앱 빌드 및 실행 ✅
- SM F946N 디바이스에 성공적으로 설치
- Flutter DevTools 실행 중

---

## ✅ 완료된 문제점

### ✅ 1. **AppIntro 이미지 생성 시도 제거**
**상태: 완료됨**
- `lib/main.dart`에 `AppIntroService.instance.preload()` 호출 없음
- `app_intro_service.dart`에 `generateImageFromText` 호출 없음
- Assets 이미지만 사용하도록 변경 완료

### ✅ 2. **secrets.json API 키 로드**
**상태: 완료됨**
- `assets/config/secrets.json` 파일 존재
- `pubspec.yaml`에 `assets/config/` 경로 등록됨
- ConfigService 정상 로드

### ✅ 3. **백업 Notification 기능 삭제**
**상태: 완료됨**
- `backup_service.dart`에서 notification 관련 코드 없음
- 네트워크 연결 시 자동 백업 알림 기능 제거됨

### ✅ 4. **Flutter Analyze 문제 해결**
**상태: 완료됨 (28개 → 0개)**
- 모든 `print()` → `debugPrint()`로 변환
- Unused import 제거 (user_customization_provider.dart)
- Type inference 문제 수정 (catchError에 Object 타입 명시)
- Future.delayed 타입 명시 (Future<void>.delayed)
- Unnecessary import 제거 (image_generation_purchase_dialog.dart)

### ✅ 5. **Google AdMob 수익 연결 가이드 작성**
**상태: 완료됨**
- `ADMOB_SETUP_GUIDE.md` 생성
- AdMob 계정 생성부터 수익 수령까지 전체 프로세스 문서화
- 광고 단위 생성, 코드 통합, 결제 정보 설정 방법 포함
- 문제 해결 및 수익 극대화 팁 포함

### ✅ 6. **AI 이미지 생성 횟수 구매 페이지 구현**
**상태: 완료됨**
- `lib/shared/services/payment_service.dart` 수정
  - `_processImageGenerationPurchase()` 메서드 추가
  - SharedPreferences 통합으로 구매 횟수 자동 추가
  - 구매 기록 저장 기능
- `lib/features/diary/widgets/image_generation_purchase_dialog.dart` 수정
  - 실제 구매 로직 구현 (PaymentService 통합)
  - 에러 핸들링 및 사용자 피드백 (SnackBar)
  - 구매 성공 시 자동 UI 업데이트
- `lib/main.dart` 수정
  - PaymentService 초기화 추가

## ⚠️ 발견된 문제점 (우선순위 순)

### 🔴 긴급 - 즉시 수정 필요

**없음** - 모든 긴급 문제 해결 완료!

---

### 🟡 중요 - 향후 작업 권장

#### 1. **POWERSHELL_CLAUDE_CODE_GUIDE.md 포맷 확인** (선택사항)
**문제:**
- 파일 내용 재확인 필요

**해결방법:**
1. 파일 내용 확인
2. 마크다운 포맷 검증

---

## 📋 작업 완료 체크리스트

### ✅ 우선순위 1: 긴급 수정 (완료)
- [x] `lib/main.dart`에서 `AppIntroService.instance.preload()` 제거 확인
- [x] AppIntro 관련 이미지 생성 코드 제거 확인
- [x] secrets.json API 키 로드 확인
- [x] flutter analyze 실행 후 경고 수정 (28개 → 0개)

### 우선순위 2: 테스트 및 검증 (1시간)
- [ ] 앱 소개 섹션에 assets 이미지가 제대로 표시되는지 확인
- [ ] 이미지 생성 시도 로그가 더 이상 나타나지 않는지 확인
- [ ] 홈 화면에 generation count 위젯이 제대로 표시되는지 확인
- [ ] 일기 작성 시 이미지 생성 제한 로직 테스트 (무료 3회)
- [ ] 구매 다이얼로그 표시 확인

### 우선순위 3: 문서 정리 (20분)
- [ ] POWERSHELL_CLAUDE_CODE_GUIDE.md 재작성
- [ ] CHANGES_SUMMARY.md 업데이트
- [ ] Git commit 메시지 작성

### 우선순위 4: 추가 개선사항 (시간 있을 때)
- [ ] 회상 기능 로컬 DB 쿼리 테스트
- [ ] 개인정보/이용약관 화면 표시 확인
- [ ] 썸네일 모니터링 화면 제거 확인
- [ ] 설정 화면에서 미구현 기능 제거 확인

---

## 🎉 모든 긴급 작업 완료!

### 완료된 작업 (2025-11-11)

1. ✅ AppIntro preload() 제거 확인
2. ✅ AppIntro 이미지 생성 코드 제거 확인
3. ✅ secrets.json API 키 로드 확인
4. ✅ 백업 Notification 기능 삭제 확인
5. ✅ Flutter analyze 문제 수정 (28개 → 0개)
   - print() → debugPrint() 변환 (25개)
   - Unused import 제거 (2개)
   - Type inference 수정 (2개)
   - Future 타입 명시 (1개)
6. ✅ Google AdMob 수익 연결 가이드 작성
   - ADMOB_SETUP_GUIDE.md 생성
   - 계정 설정부터 수익 수령까지 전체 프로세스
7. ✅ AI 이미지 생성 횟수 구매 페이지 구현
   - PaymentService 통합
   - 실제 구매 로직 구현
   - 자동 횟수 추가 및 UI 업데이트

### 다음 세션 권장 작업

```
지금까지의 작업이 모두 완료되었어!

다음 작업으로는:
1. 앱 소개 섹션 assets 이미지 표시 확인
2. 이미지 생성 제한 로직 테스트
3. 회상 기능 테스트
4. 개인정보/이용약관 화면 확인

위 항목들 중 필요한 것부터 진행하면 돼.
```

---

## 💡 Claude Code 종료 전 체크리스트

### 현재 Claude Code를 종료하기 전에:

1. **백그라운드 프로세스 종료**
   ```bash
   # 실행 중인 flutter run 프로세스 확인
   # Ctrl+C로 종료하거나
   q  # flutter run 내에서 q 입력
   ```

2. **변경사항 확인**
   ```bash
   git status
   git diff
   ```

3. **필요시 커밋** (선택사항)
   ```bash
   git add .
   git commit -m "WIP: AppIntro assets 이미지 변경 작업 중"
   ```

4. **문서 저장 확인**
   - TOMORROW_TODO.md ✅
   - CHANGES_SUMMARY.md ✅
   - POWERSHELL_CLAUDE_CODE_GUIDE.md ⚠️ (재작성 필요)

---

## 📚 참고 파일 경로

### 긴급 수정 필요 파일
```
lib/main.dart                                          # preload() 제거
lib/core/providers/app_intro_provider.dart            # 이미지 생성 확인
lib/core/config/secrets_manager.dart                  # API 키 로드
lib/core/config/api_keys.dart                         # API 키 사용
assets/config/secrets.json                            # API 키 저장
```

### 테스트 필요 파일
```
lib/features/home/widgets/app_intro_section.dart     # 앱 소개 표시
lib/features/home/widgets/generation_count_widget.dart # 남은 횟수 표시
lib/features/diary/widgets/image_generation_purchase_dialog.dart # 구매 다이얼로그
lib/core/services/app_intro_service.dart              # Assets 로드
```

### 확인 필요 Assets
```
assets/images/app_intro/ocr.png
assets/images/app_intro/voice.png
assets/images/app_intro/emotion.png
assets/images/app_intro/ai_image.png
assets/images/app_intro/search.png
assets/images/app_intro/backup.png
assets/images/app_intro/pin_security.png
assets/images/app_intro/screen_privacy.png
```

---

## 🎯 최종 목표

### 단기 목표 (내일)
- AppIntro에서 이미지 생성 시도 완전 제거
- Assets 이미지만 사용하도록 확정
- API 키 로드 문제 해결
- Lint 경고 모두 제거

### 중기 목표 (이번 주)
- 모든 기능 테스트 완료
- 문서 정리
- Git commit 정리
- 배포 준비

---

## 📞 문제 발생 시

### 디버깅 명령어
```bash
# 로그 확인
adb logcat | grep "flutter"

# 앱 재시작
flutter run -d R3CW80CCH6V

# Clean build
flutter clean
flutter pub get
flutter run -d R3CW80CCH6V
```

### 자주 발생하는 오류

**1. "Missing required secret" 오류**
→ secrets.json 로드 확인
→ SecretsManager 로직 확인

**2. "이미지 생성 실패" 로그**
→ main.dart의 preload() 제거
→ AppIntroProvider 확인

**3. "Provider not found" 오류**
→ Provider 이름 확인
→ import 경로 확인

---

## ✅ 완료 시 업데이트

작업 완료 후 이 섹션에 체크:
- [ ] 긴급 수정 완료
- [ ] 테스트 완료
- [ ] 문서 업데이트
- [ ] Git commit
- [ ] 다음 TODO 파일 작성

---

**작성일**: 2025-11-10 22:20
**다음 작업일**: 2025-11-11
**예상 소요 시간**: 2시간
