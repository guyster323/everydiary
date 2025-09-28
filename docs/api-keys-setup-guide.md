# API 키 설정 가이드

## 🔑 **API 키 설정 방법**

### **1. 환경변수 설정 (권장)**

PowerShell에서 다음 명령어를 실행하세요:

```powershell
# Gemini API 키 설정
$env:GEMINI_API_KEY = "AIzaSyD5-akvjn0fCX7ZVRbyyw01EE9yYqIjOCY"

# Hugging Face API 키 설정
$env:HUGGING_FACE_API_KEY = "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"

# Flutter 앱 실행
flutter run -d emulator-5554
```

### **2. 코드에서 직접 설정 (개발용)**

`lib/core/config/api_keys.dart` 파일을 수정하세요:

```dart
class ApiKeys {
  static String get geminiApiKey {
    final envKey = Platform.environment['GEMINI_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }
    // 실제 키로 교체
    return 'AIzaSyD5-akvjn0fCX7ZVRbyyw01EE9yYqIjOCY';
  }

  static String get huggingFaceApiKey {
    final envKey = Platform.environment['HUGGING_FACE_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }
    // 실제 키로 교체
    return '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';
  }
}
```

## 🚀 **Firebase 설정**

### **1. Firebase 프로젝트 생성**

1. [Firebase Console](https://console.firebase.google.com/)에서 새 프로젝트 생성
2. Android 앱 추가
3. `google-services.json` 파일을 `android/app/` 폴더에 복사

### **2. Google Sign-In 설정**

1. Firebase Console > Authentication > Sign-in method
2. Google 제공업체 활성화
3. SHA-1 인증서 지문 추가 (디버그용)

## 📱 **앱 실행**

```powershell
# API 키 설정 후 앱 실행
flutter run -d emulator-5554
```

## 🔍 **문제 해결**

### **API 키가 인식되지 않는 경우:**

1. 터미널을 완전히 종료하고 다시 시작
2. 환경변수 재설정
3. Flutter clean 후 재빌드: `flutter clean && flutter pub get`

### **Google Sign-In이 작동하지 않는 경우:**

1. `google-services.json` 파일이 올바른 위치에 있는지 확인
2. SHA-1 인증서 지문이 Firebase에 등록되었는지 확인
3. Firebase 프로젝트 설정 확인

## 📋 **체크리스트**

- [ ] Gemini API 키 설정됨
- [ ] Hugging Face API 키 설정됨
- [ ] Firebase 프로젝트 생성됨
- [ ] `google-services.json` 파일 추가됨
- [ ] Google Sign-In 활성화됨
- [ ] 앱이 정상적으로 실행됨

