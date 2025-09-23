# Everydiary (편한일기장) - 개발 요구사항 문서

## 프로젝트 개요
- **앱 이름**: Everydiary (한국어: 편한일기장)
- **플랫폼**: Android 우선 출시
- **개발 환경**: Cursor IDE + Flutter
- **개발자 배경**: VS Code/Flutter 경험 있음, 앱 출시 경험 없음

## 핵심 기능 요구사항

### 1. 기본 기능
- **텍스트 일기 작성**: 기본 텍스트 입력을 통한 일기 작성
- **심리적으로 안정되고 편안한 UI/UX 디자인**
- **안전한 데이터 저장**: 기기 내 저장 + 서버 저장 옵션

### 2. 프리미엄 기능 (과금 체계)
#### 음성 인식 기능
- 음성 녹음 후 음성 인식으로 다이어리 작성
- 오타 수정을 위한 터치&드래그 편집 기능

#### OCR 기능
- 카메라를 통한 실시간 텍스트 인식
- 앨범에서 이미지 선택하여 필기 내용 Import
- 오타 수정을 위한 터치&드래그 편집 기능

### 3. 고급 기능
#### 과거 기록 추천 시스템
- 하루 전 작성된 일기
- 같은 시간대에 작성된 과거 기록
- 같은 날짜(작년, 재작년)에 작성된 기록

#### AI 기반 배경 이미지
- 작성 중/완료된 일기의 분위기 분석
- 실시간 Blur 배경 이미지 자동 적용
- 텍스트 가독성 확보

#### 썸네일 시스템
- 저장된 일기를 한 단어로 요약
- 요약 단어와 연관된 이미지를 썸네일로 생성
- 썸네일 기반 캘린더 뷰 제공

## 기술 스택 및 필요 패키지

### Flutter 핵심 패키지
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # UI/UX
  cupertino_icons: ^1.0.6
  material_design_icons_flutter: ^7.0.7296
  
  # 상태 관리
  provider: ^6.1.1
  riverpod: ^2.4.9
  
  # 로컬 데이터베이스
  sqflite: ^2.3.0
  path: ^1.8.3
  path_provider: ^2.1.1
  
  # 음성 인식
  speech_to_text: ^6.6.2
  
  # OCR
  google_mlkit_text_recognition: ^0.7.0
  image_picker: ^1.0.7
  camera: ^0.10.5+5
  
  # 인앱 결제
  in_app_purchase: ^3.1.11
  
  # 네트워킹
  http: ^1.1.0
  dio: ^5.3.2
  
  # 보안
  flutter_secure_storage: ^9.0.0
  crypto: ^3.0.3
  
  # AI/이미지 생성
  openai_client: ^1.0.0
  
  # 권한 관리
  permission_handler: ^11.0.1
  
  # 날짜/시간
  intl: ^0.18.1
  
  # 캘린더
  table_calendar: ^3.0.9
  
  # 이미지 처리
  image: ^4.1.3
  cached_network_image: ^3.3.0
```

### Android 권한 설정 (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>

<queries>
  <intent>
    <action android:name="android.speech.RecognitionService" />
  </intent>
</queries>
```

## 프로젝트 구조
```
lib/
├── main.dart
├── models/
│   ├── diary_entry.dart
│   ├── user.dart
│   └── subscription.dart
├── screens/
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   ├── write/
│   │   ├── write_diary_screen.dart
│   │   ├── voice_input_screen.dart
│   │   └── ocr_input_screen.dart
│   ├── calendar/
│   │   └── calendar_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── services/
│   ├── database_service.dart
│   ├── speech_service.dart
│   ├── ocr_service.dart
│   ├── ai_service.dart
│   ├── subscription_service.dart
│   └── storage_service.dart
├── providers/
│   ├── diary_provider.dart
│   ├── user_provider.dart
│   └── subscription_provider.dart
├── widgets/
│   ├── diary_card.dart
│   ├── custom_calendar.dart
│   └── common/
└── utils/
    ├── constants.dart
    ├── theme.dart
    └── helpers.dart
```

## 인앱 결제 설정

### Google Play Console 설정
1. Google Play Developer 계정 필요 ($25 일회성 등록비)
2. 인앱 상품 생성:
   - **음성 인식 기능**: 월간 구독 또는 일회성 결제
   - **OCR 기능**: 월간 구독 또는 일회성 결제
   - **프리미엄 번들**: 모든 기능 포함 구독

### 결제 상품 ID 예시
```dart
static const String voiceRecognitionMonthly = 'voice_recognition_monthly';
static const String ocrFeatureMonthly = 'ocr_feature_monthly';
static const String premiumBundleMonthly = 'premium_bundle_monthly';
```

## 디자인 가이드라인

### 컬러 팔레트 (심리적 안정감)
```dart
class AppColors {
  static const Color primarySoft = Color(0xFF8DB4D1); // 부드러운 블루
  static const Color accentWarm = Color(0xFFF4E4C1); // 따뜻한 베이지
  static const Color backgroundCalm = Color(0xFFF8F9FA); // 차분한 회백색
  static const Color textGentle = Color(0xFF4A5568); // 부드러운 그레이
  static const Color positiveGreen = Color(0xFF9CC5A1); // 안정감 주는 녹색
}
```

### 타이포그래피
- **폰트**: 한글 가독성이 좋은 Noto Sans KR
- **크기**: 제목 24sp, 본문 16sp, 캡션 14sp

## Cursor IDE 최적화 설정

### .cursor-rules 파일 생성
```markdown
# Flutter Everydiary 프로젝트 규칙

## 개발 원칙
- Material Design 3 가이드라인 준수
- 한국 사용자 UX 고려
- 심리적 안정감을 주는 디자인
- 접근성 고려한 UI 구현

## 코딩 스타일
- Dart 공식 style guide 준수
- Provider 패턴을 통한 상태 관리
- 비동기 처리 시 FutureBuilder/StreamBuilder 활용
- 에러 처리 및 로딩 상태 UI 제공

## 보안 요구사항
- 민감한 데이터는 flutter_secure_storage 사용
- API 키는 환경변수로 관리
- 사용자 데이터 암호화 저장

## 성능 최적화
- 이미지 캐싱 및 최적화
- 불필요한 rebuild 방지
- 메모리 사용량 모니터링
```

## API 및 서버 설정

### 필요한 외부 서비스
1. **음성 인식**: Google Speech-to-Text API 또는 온디바이스 처리
2. **이미지 생성**: OpenAI DALL-E API 또는 Stable Diffusion
3. **백엔드**: Firebase (Auth, Firestore, Storage) 또는 Supabase
4. **결제 처리**: Google Play Billing

### Firebase 설정 (추천)
```bash
# Firebase CLI 설치
npm install -g firebase-tools

# Flutter Firebase 설정
dart pub global activate flutterfire_cli
flutterfire configure
```

## 개발 단계별 계획

### Phase 1: 기본 기능 (2-3주)
- [x] 프로젝트 초기 설정
- [x] 기본 UI/UX 디자인
- [x] 텍스트 일기 작성 기능
- [x] 로컬 데이터베이스 구현
- [x] 기본 캘린더 뷰

### Phase 2: 고급 기능 (3-4주)
- [x] 음성 인식 기능 구현
- [x] OCR 기능 구현
- [x] 과거 기록 추천 시스템
- [x] AI 배경 이미지 생성

### Phase 3: 결제 시스템 (2주)
- [x] 인앱 결제 구현
- [x] 구독 관리 시스템
- [x] 사용자 권한 관리

### Phase 4: 출시 준비 (2주)
- [x] 앱 아이콘 및 스플래시 스크린
- [x] Google Play Console 설정
- [x] 테스트 및 버그 수정
- [x] 개인정보 처리방침 작성

## 추가 고려사항

### MCP 통합 (TaskMaster 추천)
Cursor IDE의 MCP 기능을 활용하여 개발 효율성을 높일 수 있습니다:

1. **TaskMaster MCP 설치**:
```bash
git clone https://github.com/eyaltoledano/claude-task-master
```

2. **Cursor 설정에서 MCP 활성화**
3. **PRD(Product Requirements Document) 작성**을 통한 작업 자동화

### 성능 모니터링
- **Firebase Crashlytics**: 크래시 리포트
- **Firebase Performance**: 성능 모니터링
- **Firebase Analytics**: 사용자 행동 분석

### 출시 후 운영
- **A/B 테스팅**: 기능 및 UI 개선
- **사용자 피드백 수집**: 리뷰 및 평점 모니터링
- **정기 업데이트**: 버그 수정 및 신규 기능 추가

## 개발 시 주의사항

1. **개인정보 보호**: 일기는 민감한 개인정보이므로 보안에 특히 신경쓸 것
2. **오프라인 기능**: 네트워크 없이도 기본 기능 사용 가능하게 구현
3. **배터리 최적화**: AI 기능 사용 시 배터리 소모 최소화
4. **접근성**: 시각/청각 장애인도 사용할 수 있는 UI 구현
5. **다양한 화면 크기 대응**: 다양한 Android 기기 호환성

---

이 문서를 바탕으로 Cursor IDE에서 개발을 시작하세요. 각 단계별로 세부 구현 사항이 필요하면 언제든 추가 요청해 주세요!