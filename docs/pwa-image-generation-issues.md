# PWA 및 이미지 생성 문제 해결 요청

## 현재 상황 요약

### 1. PWA (Progressive Web App) 문제

- **초기화**: PWA Provider 초기화는 성공적으로 완료됨
- **상태 불일치**:
  - `isInstalled: false`
  - `isInstallable: false`
  - `canInstall: false`
  - 한글 로그: "설치가능: false, 설치됨: false, 버전: null"
- **설치 버튼**: UI에 표시되지만 클릭 시 "앱설치 실패" 메시지 표시

### 2. 이미지 생성 문제

- **API 키 설정**: `api_keys.dart`에 Gemini와 Hugging Face API 키가 하드코딩됨
- **실패 원인**:
  - Gemini API: 404 오류 (잘못된 엔드포인트)
  - Hugging Face API: 401 오류 (인증 실패)
- **현재 엔드포인트**:
  - Gemini: `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent`
  - Hugging Face: `https://api-inference.huggingface.co/models/runwayml/stable-diffusion-v1-5`

## 기술 스택

- **Flutter**: Android 앱 (PWA는 Android 내부 플로우로 구현)
- **상태 관리**: Riverpod (hooks_riverpod)
- **PWA**: Android 네이티브 PWA 서비스
- **이미지 생성**: Gemini API + Hugging Face API

## 코드 구조

### PWA 관련 파일

```
lib/core/
├── providers/
│   ├── pwa_provider.dart          # PWA 상태 관리
│   └── pwa_install_provider.dart  # PWA 설치 상태 관리
├── services/
│   ├── pwa_service.dart          # PWA 서비스 인터페이스
│   ├── pwa_service_stub.dart     # Android용 PWA 서비스 구현
│   └── pwa_install_service.dart   # PWA 설치 서비스
└── widgets/
    ├── pwa_install_button.dart   # PWA 설치 버튼
    └── pwa_install_prompt.dart   # PWA 설치 프롬프트
```

### 이미지 생성 관련 파일

```
lib/core/
├── config/
│   └── api_keys.dart             # API 키 관리
└── services/
    └── image_generation_service.dart  # 이미지 생성 서비스
```

## 현재 문제점

### 1. PWA 상태 불일치

- `PWAService`의 `canInstall`이 `true`로 설정되어 있지만
- `PWAInstallPrompt`와 `PWAInstallButton`에서 `false`로 표시됨
- 상태 전파가 제대로 되지 않는 것으로 추정

### 2. PWA 설치 실패

- Android에서 PWA 설치가 실제로 동작하지 않음
- `pwa_service_stub.dart`는 단순히 stub 구현으로 실제 설치 로직이 없음

### 3. 이미지 생성 API 문제

- **Gemini API**:
  - 현재 엔드포인트가 이미지 생성용이 아닌 텍스트 생성용
  - Gemini는 이미지 생성이 아닌 텍스트 생성 API
- **Hugging Face API**:
  - API 키 인증 실패
  - 모델 엔드포인트 문제 가능성

## 요청 사항

### 1. PWA 문제 해결

- Android에서 실제 PWA 설치가 가능하도록 구현
- PWA 상태 관리 개선 (상태 불일치 해결)
- PWA 설치 버튼이 실제로 동작하도록 수정

### 2. 이미지 생성 문제 해결

- **Gemini API**: 이미지 생성이 아닌 텍스트 생성이므로 다른 API 사용 필요
- **Hugging Face API**: 올바른 엔드포인트와 인증 방식 확인
- 대안: DALL-E, Midjourney API, 또는 다른 이미지 생성 서비스 사용

### 3. 권장 해결 방안

1. **PWA**: Android WebView 기반 PWA 설치 구현
2. **이미지 생성**:
   - OpenAI DALL-E API 사용
   - 또는 Hugging Face API 올바른 이미지 생성 모델 사용
   - 또는 Stability AI API 사용

## 현재 API 키 (테스트용)

- **Gemini**: `[API_KEY_HIDDEN]`
- **Hugging Face**: `[API_KEY_HIDDEN]`

## 테스트 환경

- **플랫폼**: Android 에뮬레이터
- **Flutter 버전**: 최신 안정 버전
- **디바이스**: sdk gphone64 x86 64

## 로그 예시

```
I/flutter: 🔧 PWA Provider 초기화 완료 - canInstall: true
I/flutter: 🔍 PWA Install Prompt - isInstalled: false, isInstallable: false
I/flutter: 🔍 PWA Install Button - canInstall: false
I/flutter: 📊 PWA 초기 상태 - 설치 가능: false, 설치됨: false, 버전: null
I/flutter: ❌ 이미지 생성 실패 (Gemini/Hugging Face 둘 다 실패)
```

## 기대 결과

1. PWA 설치 버튼이 실제로 Android 앱을 설치할 수 있어야 함
2. 이미지 생성이 성공적으로 작동해야 함
3. PWA 상태가 일관되게 표시되어야 함
