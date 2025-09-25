# Everydiary 프로젝트 개선 현황 보고서

## 📋 프로젝트 개요

- **프로젝트명**: Everydiary (Flutter 일기 앱)
- **GitHub 저장소**: https://github.com/guyster323/everydiary.git
- **최신 커밋**: `2db74aa` (2024년 현재)
- **개발 환경**: Flutter, Dart, Riverpod, Supabase

## ✅ 완료된 개선사항

### 1. UI 스타일 통일

- **상태**: ✅ 완료
- **내용**: 모든 입력 위젯의 텍스트 색상을 검정색으로 변경
- **수정 파일**: `lib/core/widgets/custom_input_field.dart`
- **변경사항**:
  - 입력 텍스트: `Colors.black`
  - 라벨 텍스트: `Colors.black87`
  - 힌트 텍스트: `Colors.black54`
  - 비활성화 텍스트: `Colors.black54`

### 2. 일기 작성 화면 OCR 텍스트 전달 로직 개선

- **상태**: ✅ 완료
- **내용**: OCR 텍스트를 일기 내용에 안정적으로 추가하는 로직 개선
- **수정 파일**: `lib/features/diary/screens/diary_write_screen.dart`
- **변경사항**:
  - 재시도 메커니즘 구현
  - 에디터 로드 안정성 향상
  - 시뮬레이션 텍스트 감지 로직 제거

### 3. 통계 화면 네비게이션 수정

- **상태**: ✅ 완료
- **내용**: Back 버튼이 메인 페이지로 직접 이동하도록 수정
- **수정 파일**: `lib/features/diary/screens/statistics_screen.dart`
- **변경사항**:
  - GoRouter를 사용한 안정적인 네비게이션 구현
  - `context.go('/home')` 사용

### 4. Supabase 연결 오류 처리 강화

- **상태**: ✅ 완료
- **내용**: MemoryService에 연결 상태 확인 로직 추가
- **수정 파일**:
  - `lib/features/recommendations/services/memory_service.dart`
  - `lib/features/recommendations/screens/memory_screen.dart`
- **변경사항**:
  - `_checkSupabaseAvailability()` 메서드 추가
  - 연결 실패 시 사용자 친화적인 오류 메시지 제공
  - 재시도 기능이 포함된 에러 상태 위젯 구현

### 5. Lint 오류 수정

- **상태**: ✅ 완료
- **내용**: 모든 코드 품질 문제 해결
- **결과**: Lint 오류 0개

## ❌ 남은 문제점들 (Perplexity 개선 필요)

### 1. OCR 기능 문제 (심각)

- **상태**: ❌ 미해결
- **문제**: 갤러리 한글 사진 선택 시 App 크래시
- **오류 로그**:

```
E/AndroidRuntime( 4923): java.lang.NoClassDefFoundError: Failed resolution of: Lcom/google/mlkit/vision/text/korean/KoreanTextRecognizerOptions$Builder;
E/AndroidRuntime( 4923): Caused by: java.lang.ClassNotFoundException: Didn't find class "com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder"
```

- **원인**: ML Kit 한국어 텍스트 인식 옵션이 제대로 설정되지 않음
- **영향**: OCR 기능 완전 불가
- **수정 파일**: `lib/shared/services/ocr_service.dart`
- **현재 코드**:

```dart
_textRecognizer = TextRecognizer(
  script: TextRecognitionScript.korean, // 이 부분이 문제
);
```

### 2. 네비게이션 문제

- **상태**: ❌ 미해결
- **문제**: Back 키 누를 시 "페이지를 찾을 수 없습니다" 오류
- **증상**:
  - Back 키를 누르면 404 페이지 표시
  - "Home으로 돌아가기" 버튼을 누르면 Main으로 이동됨
- **원인**: GoRouter 설정 문제로 추정
- **영향**: 사용자 경험 저하

### 3. Supabase 연결 오류

- **상태**: ❌ 미해결
- **문제**: `supabase.dart` 초기화 전 인스턴스 호출 오류
- **오류 메시지**:

```
Failed assertion Line 45 pos 7: supabase 인스턴스 호출 전에 초기화 필요
```

- **원인**: Supabase 클라이언트 초기화 순서 문제
- **영향**: 데이터베이스 연결 불가

### 4. 일기 편집 기능 문제

- **상태**: ❌ 미해결
- **문제**:
  - 수정 시 작성 위젯이 비어있음
  - 편집 없이 저장할 경우 이전 내용이 그대로 반영됨
- **원인**: 에디터 상태 관리 문제
- **영향**: 일기 수정 기능 불가

## 🔧 기술적 세부사항

### 현재 OCR 서비스 구조

```dart
// lib/shared/services/ocr_service.dart
class OCRService {
  TextRecognizer? _textRecognizer;

  Future<void> initialize() async {
    _textRecognizer = TextRecognizer(
      script: TextRecognitionScript.korean, // 문제 지점
    );
  }

  Future<OCRResult> extractTextFromFile(String imagePath) async {
    // 실제 ML Kit 사용 (시뮬레이션 제거됨)
  }
}
```

### 현재 네비게이션 구조

```dart
// lib/features/diary/screens/statistics_screen.dart
appBar: CustomAppBar(
  title: '일기 통계',
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      context.go('/home'); // 이 부분이 문제일 수 있음
    },
  ),
),
```

### 현재 Supabase 구조

```dart
// lib/features/recommendations/services/memory_service.dart
class MemoryService {
  final SupabaseClient _supabase = Supabase.instance.client; // 초기화 순서 문제

  Future<bool> _checkSupabaseAvailability() async {
    // 연결 상태 확인 로직
  }
}
```

## 📱 테스트 환경

- **에뮬레이터**: Android Emulator (sdk gphone64 x86 64)
- **Flutter 버전**: 최신
- **디바이스**: Medium phone Emulator
- **테스트 결과**: OCR 기능에서 크래시 발생

## 🎯 Perplexity 개선 요청사항

### 우선순위 1: OCR 기능 수정

1. **ML Kit 한국어 텍스트 인식 설정 수정**
   - `KoreanTextRecognizerOptions` 클래스 문제 해결
   - 올바른 한국어 텍스트 인식 설정 방법 적용
   - 갤러리 이미지 선택 시 크래시 방지

### 우선순위 2: 네비게이션 수정

1. **GoRouter 설정 개선**
   - Back 키 동작 수정
   - 404 페이지 오류 해결
   - 올바른 라우팅 설정

### 우선순위 3: Supabase 연결 수정

1. **초기화 순서 문제 해결**
   - Supabase 클라이언트 초기화 순서 수정
   - 인스턴스 호출 전 초기화 보장

### 우선순위 4: 일기 편집 기능 수정

1. **에디터 상태 관리 개선**
   - 수정 시 기존 내용 로드
   - 편집 상태 올바른 관리
   - 저장 시 변경사항 반영

## 📝 추가 정보

- **개발 도구**: Cursor IDE
- **버전 관리**: Git
- **의존성 관리**: Flutter pub
- **코드 품질**: Lint 통과
- **테스트**: Medium phone Emulator에서 검증 필요

## 🔗 관련 파일들

- `lib/shared/services/ocr_service.dart` - OCR 서비스
- `lib/features/diary/screens/diary_write_screen.dart` - 일기 작성 화면
- `lib/features/diary/screens/statistics_screen.dart` - 통계 화면
- `lib/features/recommendations/services/memory_service.dart` - 메모리 서비스
- `lib/features/recommendations/screens/memory_screen.dart` - 메모리 화면
- `lib/core/widgets/custom_input_field.dart` - 입력 위젯

---

**요청**: 위의 문제점들을 해결하여 Everydiary 앱이 안정적으로 작동하도록 개선해주세요.
