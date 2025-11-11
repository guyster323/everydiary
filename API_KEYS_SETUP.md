# API 키 설정 가이드

이 프로젝트는 **Gemini API**와 **HuggingFace API**를 사용하여 AI 이미지를 생성합니다.
개인 API 키를 안전하게 관리하면서 Claude가 빌드를 도울 수 있는 방법을 설명합니다.

---

## 🔐 보안 원칙

✅ **API 키는 절대 Git에 커밋하지 않습니다**
✅ **로컬 파일에만 저장합니다**
✅ **Claude는 템플릿만 관리하고, 실제 키는 사용자만 관리합니다**

---

## 🎯 추천 방법: 3가지 옵션

### 방법 1: `--dart-define` 사용 (가장 간단) ⭐ 추천

#### 장점
- 추가 패키지 불필요
- 빌드 시에만 API 키 사용
- Flutter 공식 지원 방법

#### 사용 방법

1. **로컬 설정 파일 생성** (한 번만)

```bash
# .env.flutter.local 파일 생성
cp .env.flutter.example .env.flutter.local
```

2. **실제 API 키 입력** (`.env.flutter.local` 편집)

```bash
GEMINI_API_KEY=AIzaSy...실제_키...
HUGGING_FACE_API_KEY=hf_...실제_키...
```

3. **빌드 스크립트 사용** (Claude가 실행 가능)

```bash
# Android 빌드
flutter build apk --dart-define=GEMINI_API_KEY=$(grep GEMINI_API_KEY .env.flutter.local | cut -d '=' -f2) --dart-define=HUGGING_FACE_API_KEY=$(grep HUGGING_FACE_API_KEY .env.flutter.local | cut -d '=' -f2)

# iOS 빌드
flutter build ios --dart-define=GEMINI_API_KEY=$(grep GEMINI_API_KEY .env.flutter.local | cut -d '=' -f2) --dart-define=HUGGING_FACE_API_KEY=$(grep HUGGING_FACE_API_KEY .env.flutter.local | cut -d '=' -f2)
```

#### Windows PowerShell 사용자용

```powershell
# build.ps1 스크립트 사용 (권장)
.\build.ps1 apk
.\build.ps1 ios
```

---

### 방법 2: `flutter_dotenv` 패키지 사용

#### 장점
- 더 직관적인 .env 파일 관리
- 런타임에 환경 변수 로드 가능

#### 설치 방법

1. `pubspec.yaml`에 추가:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

2. `pubspec.yaml`의 assets에 추가:
```yaml
flutter:
  assets:
    - .env.flutter.local
```

3. `main.dart` 수정:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env.flutter.local");
  runApp(const MyApp());
}
```

4. `api_keys.dart` 수정:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeys {
  static String get geminiApiKey {
    return dotenv.env['GEMINI_API_KEY'] ??
           Platform.environment['GEMINI_API_KEY'] ??
           SecretsManager.instance.getSecret('gemini_api_key') ?? '';
  }

  static String get huggingFaceApiKey {
    return dotenv.env['HUGGING_FACE_API_KEY'] ??
           Platform.environment['HUGGING_FACE_API_KEY'] ??
           SecretsManager.instance.getSecret('hugging_face_api_key') ?? '';
  }
}
```

---

### 방법 3: 빌드 스크립트 자동화 (고급 사용자용)

#### PowerShell 스크립트 생성 (`build.ps1`)

```powershell
# API 키를 .env.flutter.local에서 읽어서 빌드
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("apk", "appbundle", "ios", "web")]
    [string]$target
)

# .env.flutter.local 파일 확인
if (-Not (Test-Path ".env.flutter.local")) {
    Write-Error ".env.flutter.local 파일이 없습니다. .env.flutter.example을 복사하여 생성하세요."
    exit 1
}

# API 키 읽기
$geminiKey = (Get-Content .env.flutter.local | Select-String "GEMINI_API_KEY").ToString().Split("=")[1]
$hfKey = (Get-Content .env.flutter.local | Select-String "HUGGING_FACE_API_KEY").ToString().Split("=")[1]

# 빌드 실행
Write-Host "🚀 빌드 시작: $target" -ForegroundColor Green

switch ($target) {
    "apk" {
        flutter build apk --dart-define=GEMINI_API_KEY=$geminiKey --dart-define=HUGGING_FACE_API_KEY=$hfKey
    }
    "appbundle" {
        flutter build appbundle --dart-define=GEMINI_API_KEY=$geminiKey --dart-define=HUGGING_FACE_API_KEY=$hfKey
    }
    "ios" {
        flutter build ios --dart-define=GEMINI_API_KEY=$geminiKey --dart-define=HUGGING_FACE_API_KEY=$hfKey
    }
    "web" {
        flutter build web --dart-define=GEMINI_API_KEY=$geminiKey --dart-define=HUGGING_FACE_API_KEY=$hfKey
    }
}

Write-Host "✅ 빌드 완료!" -ForegroundColor Green
```

#### Bash 스크립트 생성 (`build.sh`)

```bash
#!/bin/bash

# 사용법: ./build.sh [apk|appbundle|ios|web]

TARGET=$1

if [ -z "$TARGET" ]; then
    echo "❌ 사용법: ./build.sh [apk|appbundle|ios|web]"
    exit 1
fi

if [ ! -f ".env.flutter.local" ]; then
    echo "❌ .env.flutter.local 파일이 없습니다."
    echo "   .env.flutter.example을 복사하여 생성하세요."
    exit 1
fi

# API 키 읽기
GEMINI_KEY=$(grep GEMINI_API_KEY .env.flutter.local | cut -d '=' -f2)
HF_KEY=$(grep HUGGING_FACE_API_KEY .env.flutter.local | cut -d '=' -f2)

echo "🚀 빌드 시작: $TARGET"

flutter build $TARGET \
    --dart-define=GEMINI_API_KEY=$GEMINI_KEY \
    --dart-define=HUGGING_FACE_API_KEY=$HF_KEY

echo "✅ 빌드 완료!"
```

---

## 🎯 Claude와의 협업 워크플로우

### 1️⃣ 초기 설정 (한 번만)

```bash
# 1. 템플릿 파일을 복사하여 로컬 설정 파일 생성
cp .env.flutter.example .env.flutter.local

# 2. .env.flutter.local 파일을 편집하여 실제 API 키 입력
# GEMINI_API_KEY=AIzaSy...
# HUGGING_FACE_API_KEY=hf_...
```

### 2️⃣ 빌드 요청 시

**사용자**: "앱을 APK로 빌드해줘"

**Claude**:
```bash
flutter build apk \
    --dart-define=GEMINI_API_KEY=$(grep GEMINI_API_KEY .env.flutter.local | cut -d '=' -f2) \
    --dart-define=HUGGING_FACE_API_KEY=$(grep HUGGING_FACE_API_KEY .env.flutter.local | cut -d '=' -f2)
```

또는 스크립트 사용:
```bash
./build.sh apk  # Linux/Mac
.\build.ps1 apk  # Windows
```

### 3️⃣ Claude가 할 수 있는 것

✅ 빌드 명령어 실행 (API 키는 로컬 파일에서 자동 로드)
✅ 코드 수정 및 개선
✅ 테스트 실행
✅ 의존성 업데이트
✅ `.env.flutter.example` 템플릿 수정 (새로운 API 키 추가 시)

### 4️⃣ Claude가 할 수 없는 것

❌ `.env.flutter.local` 파일 보기 (보안상 중요)
❌ 실제 API 키 알기
❌ Git에 API 키 커밋

---

## 🛡️ 보안 체크리스트

- [x] `.env.flutter.local` 파일이 `.gitignore`에 포함됨
- [x] `.env.flutter.example`만 Git에 커밋됨
- [x] 실제 API 키는 로컬에만 보관됨
- [x] Claude는 템플릿만 관리
- [ ] `.env.flutter.local` 파일 생성 완료
- [ ] 실제 API 키 입력 완료

---

## 📝 .gitignore 확인

다음 항목이 `.gitignore`에 포함되어 있는지 확인:

```gitignore
# API Keys - 절대 커밋하지 마세요!
.env.flutter.local
.env.local
*.env.local

# 빌드 출력
/build/
```

---

## 🚀 빠른 시작

```bash
# 1. 로컬 API 키 파일 생성
cp .env.flutter.example .env.flutter.local

# 2. API 키 입력 (편집기로 .env.flutter.local 열기)
code .env.flutter.local  # VS Code
notepad .env.flutter.local  # Windows

# 3. 빌드 스크립트에 실행 권한 부여 (Linux/Mac)
chmod +x build.sh

# 4. 빌드 실행
./build.sh apk  # Linux/Mac
.\build.ps1 apk  # Windows

# 또는 직접 명령어 실행
flutter build apk --dart-define=GEMINI_API_KEY=<실제키> --dart-define=HUGGING_FACE_API_KEY=<실제키>
```

---

## 💡 자주 묻는 질문

### Q: Claude가 내 API 키를 볼 수 있나요?
A: 아니요. `.env.flutter.local` 파일은 로컬에만 존재하며 Claude는 접근할 수 없습니다.

### Q: 빌드할 때마다 API 키를 입력해야 하나요?
A: 아니요. `.env.flutter.local` 파일에 한 번만 저장하면 빌드 스크립트가 자동으로 읽어옵니다.

### Q: 새 컴퓨터에서 작업할 때는?
A: `.env.flutter.example`을 복사하여 `.env.flutter.local`을 만들고 API 키를 다시 입력하면 됩니다.

### Q: API 키가 앱에 포함되나요?
A: 네, 빌드된 앱에 포함됩니다. 하지만 Git에는 커밋되지 않습니다.

### Q: 프로덕션 빌드는 어떻게 하나요?
A: 동일한 방법을 사용하거나, CI/CD 환경 변수를 활용하면 됩니다.

---

## 🔧 문제 해결

### "API 키가 없습니다" 오류
```bash
# .env.flutter.local 파일이 있는지 확인
ls -la .env.flutter.local

# 파일 내용 확인 (키 값이 비어있지 않은지)
cat .env.flutter.local
```

### Windows에서 스크립트 실행 오류
```powershell
# PowerShell 실행 정책 변경 (관리자 권한)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

**이제 API 키를 안전하게 관리하면서 Claude와 협업할 수 있습니다!** 🎉
