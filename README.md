# Everydiary 📝

**Everydiary**는 개인 일기 작성과 관리를 위한 Flutter 기반 모바일 애플리케이션입니다. 음성 인식, 텍스트 인식, 이미지 첨부 등 다양한 기능을 통해 사용자가 쉽고 편리하게 일기를 작성할 수 있도록 도와줍니다.

## ✨ 주요 기능

### 🔐 인증 시스템 (구현 완료)

- **사용자 등록/로그인**: 이메일 기반 계정 생성 및 인증
- **자동 로그인**: 사용자 선택에 따른 자동 로그인 기능
- **토큰 관리**: JWT 기반 보안 토큰 시스템
- **세션 관리**: 안전한 사용자 세션 유지

### 📝 일기 작성 (개발 예정)

- **텍스트 작성**: 풍부한 텍스트 편집 기능
- **음성 인식**: 음성을 텍스트로 변환하여 빠른 일기 작성
- **텍스트 인식**: 사진의 텍스트를 자동으로 인식하여 일기에 추가
- **이미지 첨부**: 카메라 또는 갤러리에서 이미지 추가

### 🏷️ 관리 기능 (개발 예정)

- **카테고리 관리**: 일기를 주제별로 분류하고 관리
- **검색 기능**: 과거 일기를 쉽게 찾을 수 있는 검색 기능
- **통계 및 분석**: 일기 작성 패턴 분석 및 통계 제공

### 🔐 보안 및 프리미엄 (개발 예정)

- **생체 인증**: 지문/얼굴 인식을 통한 개인정보 보호
- **프리미엄 기능**: 인앱 구매를 통한 고급 기능 이용

## 🏗️ 프로젝트 구조

이 프로젝트는 **Clean Architecture** 패턴을 따라 구성되어 있습니다:

```
lib/
├── core/           # 핵심 기능 및 공통 컴포넌트
│   ├── constants/  # 앱 상수
│   ├── errors/     # 에러 처리
│   ├── network/    # 네트워크 통신
│   ├── utils/      # 유틸리티 함수
│   └── widgets/    # 기본 위젯
├── features/       # 기능별 모듈
│   ├── auth/       # 인증 기능
│   ├── diary/      # 일기 관리
│   └── profile/    # 프로필 관리
└── shared/         # 공통 컴포넌트
    ├── models/     # 데이터 모델
    ├── services/   # 공통 서비스
    └── widgets/    # 공통 위젯
```

## 📊 프로젝트 상태

### ✅ 완료된 기능

- **인증 시스템**: 사용자 등록, 로그인, 자동 로그인, 토큰 관리
- **프로젝트 구조**: Clean Architecture 기반 폴더 구조
- **코드 품질**: Linter 오류 해결, 성능 최적화
- **테스트**: 기본 테스트 통과, 빌드 성공

### 🚧 개발 중인 기능

- **일기 작성**: 기본 UI 및 기능 구현
- **데이터 저장**: 로컬 및 서버 저장소 연동

### 📋 개발 예정 기능

- **음성 인식**: 실시간 음성-텍스트 변환
- **텍스트 인식**: OCR 기능
- **이미지 처리**: 카메라 및 갤러리 연동
- **통계 및 분석**: 사용 패턴 분석
- **프리미엄 기능**: 인앱 구매 시스템

## 🚀 시작하기

### 필수 요구사항

- Flutter SDK (3.9.0 이상)
- Dart SDK
- Android Studio / VS Code
- Android SDK (Android 개발용)
- Xcode (iOS 개발용, macOS만)

### 설치 및 실행

1. **저장소 클론**

   ```bash
   git clone https://github.com/your-username/everydiary.git
   cd everydiary
   ```

2. **의존성 설치**

   ```bash
   flutter pub get
   ```

3. **코드 생성 실행** (필요시)

   ```bash
   flutter packages pub run build_runner build
   ```

4. **앱 실행**
   ```bash
   flutter run
   ```

### 개발 환경 설정

1. **VS Code 확장 프로그램 설치**

   - Dart
   - Flutter
   - Flutter Intl
   - Bracket Pair Colorizer

2. **환경 변수 설정**
   ```bash
   cp .env.example .env
   # .env 파일을 편집하여 필요한 API 키 설정
   ```

## 🛠️ 개발 도구

### 코드 품질

- **Dart Analysis**: `flutter analyze`
- **코드 포맷팅**: `flutter format`
- **테스트 실행**: `flutter test`

### 빌드

- **Debug 빌드**: `flutter build apk --debug`
- **Release 빌드**: `flutter build apk --release`
- **iOS 빌드**: `flutter build ios --release`

## 📱 지원 플랫폼

- ✅ Android (API 21+)
- ✅ iOS (iOS 11.0+)
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🧪 테스트

```bash
# 단위 테스트
flutter test

# 통합 테스트
flutter test integration_test/

# 커버리지 리포트
flutter test --coverage
```

## 📦 주요 의존성

### 상태 관리

- `riverpod` - 상태 관리 및 의존성 주입
- `flutter_riverpod` - Riverpod Flutter 통합

### 네비게이션

- `go_router` - 선언적 라우팅

### 로컬 저장소

- `sqflite` - SQLite 데이터베이스
- `hive` - NoSQL 로컬 저장소
- `shared_preferences` - 간단한 설정 저장

### 네트워킹

- `dio` - HTTP 클라이언트
- `http` - 기본 HTTP 요청

### UI/UX

- `flutter_svg` - SVG 이미지 지원
- `lottie` - 애니메이션
- `cached_network_image` - 이미지 캐싱

### 기능

- `speech_to_text` - 음성 인식
- `google_mlkit_text_recognition` - 텍스트 인식
- `image_picker` - 이미지 선택
- `local_auth` - 생체 인증

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 📞 지원

문제가 있거나 제안사항이 있으시면 [Issues](https://github.com/your-username/everydiary/issues)를 통해 알려주세요.

---

**Everydiary**로 더 나은 일기 작성 경험을 시작해보세요! ✨
