# 빠른 시작 가이드 🚀

## API 키 설정 (최초 1회만)

### 1️⃣ API 키 파일 생성

```bash
# Windows PowerShell
Copy-Item .env.flutter.example .env.flutter.local

# Linux/Mac
cp .env.flutter.example .env.flutter.local
```

### 2️⃣ API 키 입력

`.env.flutter.local` 파일을 열어서 실제 API 키를 입력하세요:

```bash
# Windows
notepad .env.flutter.local

# Mac
open -e .env.flutter.local

# VS Code
code .env.flutter.local
```

파일 내용:
```env
GEMINI_API_KEY=AIzaSy...실제_키_입력...
HUGGING_FACE_API_KEY=hf_...실제_키_입력...
```

### 3️⃣ 빌드 실행

```bash
# Windows PowerShell
.\build.ps1 apk

# Linux/Mac
chmod +x build.sh  # 처음 한 번만
./build.sh apk
```

---

## Claude에게 빌드 요청하기

이제 Claude에게 다음과 같이 요청할 수 있습니다:

```
"앱을 APK로 빌드해줘"
"iOS 빌드 해줘"
"앱번들로 빌드해줘"
```

Claude가 자동으로 다음 명령어를 실행합니다:

```bash
.\build.ps1 apk  # Windows
./build.sh apk   # Linux/Mac
```

---

## 보안 체크 ✅

- ✅ `.env.flutter.local` 파일은 Git에 커밋되지 않습니다
- ✅ `.env.flutter.example`만 템플릿으로 커밋됩니다
- ✅ Claude는 실제 API 키를 볼 수 없습니다
- ✅ 빌드 시 로컬 파일에서 자동으로 API 키를 읽어옵니다

---

## 문제 해결

### "API 키 파일이 없습니다" 오류

```bash
# 템플릿 파일 확인
ls .env.flutter.example

# 로컬 파일 생성
cp .env.flutter.example .env.flutter.local
```

### "API 키가 설정되지 않았습니다" 오류

```bash
# 로컬 파일 확인
cat .env.flutter.local  # Linux/Mac
type .env.flutter.local  # Windows

# 키가 "your_gemini_api_key_here"로 되어 있다면 실제 키로 교체
```

### Windows에서 PowerShell 스크립트 실행 오류

```powershell
# PowerShell을 관리자 권한으로 실행 후
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 더 자세한 정보

전체 가이드는 `API_KEYS_SETUP.md` 파일을 참고하세요.
