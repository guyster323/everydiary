# 에뮬레이터 검정 화면 문제 해결 가이드

## 🔍 **문제 상황**

- Flutter 앱이 에뮬레이터에서 검정 화면으로 시작됨
- DEBUG 배너는 표시되지만 UI가 렌더링되지 않음

## 🛠️ **해결 방법**

### **1. 에뮬레이터 그래픽 설정 변경**

1. **Android Studio에서 AVD Manager 열기**
2. **에뮬레이터 편집 (연필 아이콘 클릭)**
3. **Advanced Settings 클릭**
4. **Graphics 옵션을 다음 중 하나로 변경:**
   - `Software` (권장)
   - `OpenGL`
   - `Vulkan`에서 다른 옵션으로 변경

### **2. 에뮬레이터 재시작**

```bash
# 에뮬레이터 완전 종료
adb kill-server
adb start-server

# 에뮬레이터 재시작
emulator -avd Medium_Phone_5554 -gpu swiftshader_indirect
```

### **3. Flutter Clean 및 재빌드**

```bash
flutter clean
flutter pub get
flutter run -d emulator-5554
```

### **4. 대안: 물리적 기기 테스트**

에뮬레이터 문제가 지속되면 물리적 Android 기기에서 테스트:

```bash
# USB 디버깅 활성화된 기기 연결 후
flutter devices
flutter run -d [device-id]
```

## 🔧 **추가 디버깅**

### **로그 확인**

```bash
flutter run -d emulator-5554 --verbose
```

### **에뮬레이터 로그 확인**

```bash
adb logcat | grep -E "(flutter|android)"
```

## 📋 **체크리스트**

- [ ] 에뮬레이터 그래픽 설정을 Software로 변경
- [ ] 에뮬레이터 완전 재시작
- [ ] Flutter clean 후 재빌드
- [ ] 물리적 기기에서 테스트
- [ ] 로그에서 구체적인 오류 메시지 확인

## 🚨 **주의사항**

- 일부 에뮬레이터는 Vulkan을 지원하지 않아 검정 화면이 발생할 수 있음
- Flutter 3.35.4에서 Impeller 렌더링 엔진 변경으로 인한 호환성 문제 가능
- Android API 36 (Android 16)에서 일부 그래픽 드라이버 호환성 문제 가능

