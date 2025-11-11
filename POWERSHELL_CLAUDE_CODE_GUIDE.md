# PowerShell에서 Claude Code 작업 가이드

## 📘 빠른 시작

### Claude Code 실행
```powershell
# 프로젝트 디렉토리로 이동
cd C:\Users\windo\everydiary

# Cursor 실행
cursor .
```

Cursor에서 `Ctrl+L`을 눌러 Claude Code 채팅을 엽니다.

---

## 🎯 내일 시작할 때 첫 메시지

```
안녕! TOMORROW_TODO.md 파일을 확인하고 우선순위 1번부터 시작하자.

1. lib/main.dart에서 AppIntroService.instance.preload() 제거
2. AppIntro 관련 이미지 생성 코드 완전 제거
3. secrets.json API 키 로드 문제 해결
4. flutter analyze 실행 후 경고 수정

각 작업을 순서대로 진행하고 완료되면 다음으로 넘어가줘.
```

---

## 📋 자주 사용하는 명령어

### Flutter 명령어
```powershell
# 의존성 설치
flutter pub get

# 코드 분석
flutter analyze

# 특정 파일 분석
flutter analyze lib/main.dart

# 앱 실행 (디바이스 연결 필요)
flutter run -d R3CW80CCH6V

# Clean build
flutter clean
```

### Git 명령어
```powershell
# 상태 확인
git status

# 변경사항 확인
git diff

# 특정 파일 변경사항
git diff lib/main.dart

# 최근 커밋
git log --oneline -5
```

### 디버깅 명령어
```powershell
# Android 로그 확인
adb logcat | grep "flutter"

# 연결된 디바이스 확인
flutter devices
```

---

## 💡 Claude Code 사용 팁

### 1. 컨텍스트 제공
**좋은 예시:**
```
TOMORROW_TODO.md를 참고해서 main.dart의 preload() 호출을 제거해줘.
파일 경로: lib/main.dart, line 63
```

**나쁜 예시:**
```
preload 제거해줘
```

### 2. 구체적인 요청
**좋은 예시:**
```
lib/core/config/secrets_manager.dart의 loadSecretsFromAssets() 메서드가
assets/config/secrets.json을 제대로 로드하는지 확인하고 수정해줘.
```

**나쁜 예시:**
```
API 키 안 읽혀
```

### 3. 단계별 작업
```
1단계: lib/main.dart에서 AppIntroService 관련 코드 찾기
2단계: preload() 호출 제거
3단계: flutter analyze로 확인
4단계: 앱 재실행해서 로그 확인
```

### 4. 에러 발생 시
```
다음 에러가 발생했어:

I/flutter: 🎨 텍스트에서 이미지 생성 시작
I/flutter: ❌ 이미지 생성 실패

어디서 이미지 생성을 시도하는지 찾아서 제거해줘.
```

---

## 🔍 자주 묻는 질문

### Q1: 파일을 어떻게 찾나요?
```
lib/features/home/widgets/ 폴더에서
"app_intro"를 포함하는 파일을 찾아줘
```

### Q2: 특정 코드가 어디에 있는지 모를 때?
```
"AppIntroService.instance.preload()" 코드가
어디서 호출되는지 찾아줘
```

### Q3: 여러 파일을 한번에 수정?
```
다음 파일들을 순서대로 수정해줘:
1. lib/main.dart - preload() 제거
2. lib/core/providers/app_intro_provider.dart - 확인
3. flutter analyze 실행
```

### Q4: 변경사항 확인?
```
지금까지 수정한 파일 목록과
각 파일에서 무엇을 변경했는지 요약해줘
```

---

## ⚠️ 주의사항

### 1. 백그라운드 프로세스 확인
```powershell
# flutter run이 실행 중이라면
# Ctrl+C로 종료하거나 q 입력
```

### 2. 변경사항 저장 확인
Claude Code가 파일을 수정한 후:
```powershell
git status  # 변경된 파일 확인
git diff    # 변경 내용 확인
```

### 3. 빌드 캐시 문제
간혹 변경사항이 반영되지 않으면:
```powershell
flutter clean
flutter pub get
flutter run -d R3CW80CCH6V
```

---

## 📚 현재 프로젝트 상태

### 완료된 작업
- ✅ 이미지 생성 제한 로직 (무료 3회 + 구매)
- ✅ 구매 상품 정의 ($1, $2, $6)
- ✅ 구매 다이얼로그 구현
- ✅ 썸네일 모니터링 화면 삭제
- ✅ 미구현 기능 제거
- ✅ AppIntro assets 이미지로 변경 (진행중)
- ✅ 회상 기능 로컬 DB 전환
- ✅ 개인정보/이용약관 작성

### 현재 문제점
- 🔴 AppIntro에서 여전히 이미지 생성 시도
- 🔴 secrets.json API 키 로드 안됨
- 🟡 lint 경고 1개

### 다음 작업
- main.dart의 preload() 제거
- API 키 로드 문제 해결
- lint 경고 수정
- 테스트 및 검증

---

## 🎯 작업 우선순위

### 우선순위 1: 긴급 (30분)
1. AppIntro 이미지 생성 코드 완전 제거
2. API 키 로드 문제 해결
3. lint 경고 수정

### 우선순위 2: 중요 (1시간)
1. 앱 소개 섹션 테스트
2. 이미지 생성 제한 테스트
3. 구매 플로우 테스트

### 우선순위 3: 문서화 (20분)
1. CHANGES_SUMMARY.md 업데이트
2. Git commit
3. 다음 TODO 작성

---

## 🛠️ 트러블슈팅

### 문제: "Missing required secret" 로그
**해결:**
```
lib/core/config/secrets_manager.dart의
loadSecretsFromAssets() 메서드를 확인하고
assets/config/secrets.json이 제대로 로드되도록 수정해줘
```

### 문제: "이미지 생성 실패" 로그
**해결:**
```
1. lib/main.dart의 preload() 제거
2. AppIntro 관련 모든 이미지 생성 코드 검색
3. 제거 후 flutter analyze 실행
```

### 문제: Provider not found 에러
**해결:**
```
Provider 이름이 충돌하는지 확인해줘:
- imageGenerationServiceProvider
- generationCountServiceProvider
```

---

## 📞 도움이 필요할 때

### Claude Code에게 물어보기
```
지금 어떤 작업을 하고 있었는지 요약해줘
```

```
다음 단계로 무엇을 해야 하는지 알려줘
```

```
현재 문제가 무엇인지 설명해줘
```

---

## ✅ 작업 완료 시

### 1. 변경사항 확인
```powershell
git status
git diff
```

### 2. 테스트
```powershell
flutter analyze
flutter test
```

### 3. 커밋 (선택)
```powershell
git add .
git commit -m "fix: AppIntro assets 이미지 사용, 이미지 생성 로직 제거"
```

### 4. 다음 TODO 작성
```
다음에 할 작업을 TOMORROW_TODO.md에 정리해줘
```

---

**작성일**: 2025-11-10
**프로젝트**: EveryDiary
**작업자**: Claude Code + 사용자
