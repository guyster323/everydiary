# Google AdMob 수익 연결 가이드

## 📱 현재 상태

### ✅ 이미 완료된 설정

1. **앱에 AdMob SDK 통합 완료**
   - `pubspec.yaml`에 `google_mobile_ads` 패키지 추가됨
   - `lib/shared/services/ad_service.dart` 구현 완료
   - 보상형 광고 (Rewarded Ad) 기능 구현됨

2. **AndroidManifest.xml 설정 완료**
   - 파일: `android/app/src/main/AndroidManifest.xml`
   - AdMob App ID 등록됨 (현재 테스트 ID 사용 중)
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="ca-app-pub-3940256099942544~3347511713"/>
   ```

3. **앱 초기화 시 AdService 로드**
   - `lib/main.dart`에서 AdService 초기화
   - 보상형 광고 자동 로드

---

## 🚀 실제 수익 연결 단계

### 1단계: Google AdMob 계정 생성

1. **AdMob 콘솔 접속**
   - URL: https://admob.google.com/
   - Google 계정으로 로그인

2. **새 앱 추가**
   - "앱" > "앱 추가" 클릭
   - 플랫폼 선택: **Android**
   - 앱 이름: **EveryDiary** (또는 원하는 이름)
   - 앱이 Google Play에 게시되었나요? **아니요** (아직 출시 전)

3. **App ID 받기**
   - 앱을 추가하면 **AdMob App ID**가 발급됩니다
   - 형식: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`
   - 이 ID를 복사해 두세요!

---

### 2단계: 광고 단위 생성

#### 보상형 광고 단위 만들기

1. **AdMob 콘솔에서 광고 단위 생성**
   - 앱 선택 > "광고 단위" 탭
   - "광고 단위 추가" 클릭
   - 광고 형식: **보상형 광고** 선택

2. **광고 단위 설정**
   - 광고 단위 이름: `Image_Generation_Reward` (또는 원하는 이름)
   - 보상 설정:
     - 보상 항목: `이미지 생성 횟수`
     - 보상 수량: `3`
   - 저장 후 **광고 단위 ID** 받기
   - 형식: `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY`

---

### 3단계: 앱 코드에 실제 ID 적용

#### AndroidManifest.xml 업데이트

```xml
<!-- 파일: android/app/src/main/AndroidManifest.xml -->

<!-- 기존 테스트 ID를 실제 AdMob App ID로 교체 -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
```

**⚠️ 주의:** 위의 `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`를 1단계에서 받은 실제 App ID로 교체하세요!

#### AdService 코드 업데이트

```dart
// 파일: lib/shared/services/ad_service.dart

class AdService {
  // 테스트 ID를 실제 광고 단위 ID로 교체
  static const String _rewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY' // 2단계에서 받은 광고 단위 ID
      : 'ca-app-pub-3940256099942544/1712485313'; // iOS는 나중에 설정
}
```

**⚠️ 주의:** 위의 `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY`를 2단계에서 받은 실제 광고 단위 ID로 교체하세요!

---

### 4단계: 결제 정보 설정 (수익 수령)

1. **AdMob 콘솔에서 결제 정보 입력**
   - AdMob 콘솔 > "결제" 탭
   - "결제 정보 추가" 클릭

2. **필수 정보 입력**
   - **수취인 이름**: 본인 이름 또는 사업자명
   - **주소**: 정확한 주소 입력
   - **세금 정보**:
     - 한국: 사업자 등록번호 (개인사업자) 또는 주민등록번호 (개인)
     - 미국 세금 정보 (W-8BEN 또는 W-9 양식)
   - **결제 방법**:
     - 은행 계좌 (전신 송금)
     - 권장: 은행 계좌 정보 입력

3. **최소 지급 금액**
   - 기본: **$100** (약 13만원)
   - 수익이 $100 이상 누적되면 자동으로 은행 계좌로 입금됨

---

### 5단계: 앱 출시 및 검토

1. **Google Play Console에서 앱 출시**
   - 내부 테스트 → 비공개 테스트 → 공개 테스트 → 프로덕션
   - AdMob 정책 준수 확인

2. **AdMob 정책 검토**
   - 광고 배치가 정책에 맞는지 확인
   - 클릭 유도하지 않기
   - 광고와 콘텐츠 구분 명확히

3. **광고 승인 대기**
   - 앱 출시 후 AdMob에서 앱 검토 (보통 24-48시간)
   - 승인되면 실제 광고가 표시되기 시작

---

## 💰 수익 확인 방법

### AdMob 콘솔에서 수익 확인

1. **대시보드 확인**
   - AdMob 콘솔 > "홈" 탭
   - 일일 수익, 노출수, 클릭수 확인

2. **상세 보고서**
   - "보고서" 탭에서 상세 분석
   - 앱별, 광고 단위별 수익 확인
   - 날짜별 추이 그래프

3. **예상 수익**
   - 실시간으로 업데이트되지 않음
   - 보통 24-48시간 지연
   - 매월 말 확정 수익 계산

---

## 📊 현재 앱의 광고 구현 상태

### ✅ 구현된 기능

1. **보상형 광고**
   - 위치: 이미지 생성 횟수 구매 다이얼로그
   - 보상: 3회 이미지 생성 횟수 추가
   - 파일: `lib/features/diary/widgets/image_generation_purchase_dialog.dart`

2. **광고 로드 로직**
   - 앱 시작 시 자동 로드
   - 광고 시청 후 다음 광고 자동 로드
   - 실패 시 재시도 로직

3. **사용자 경험**
   - 광고 시청 완료 시 SnackBar 표시
   - 광고 로드 실패 시 에러 메시지
   - 생성 횟수 자동 업데이트

---

## 🔧 추가 설정 (선택사항)

### 광고 유형 추가

#### 배너 광고 추가 (추가 수익)

```dart
// lib/shared/services/ad_service.dart에 추가

BannerAd? _bannerAd;

void loadBannerAd() {
  _bannerAd = BannerAd(
    adUnitId: Platform.isAndroid
        ? 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY' // 배너 광고 단위 ID
        : 'ca-app-pub-3940256099942544/6300978111',
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (_) => debugPrint('배너 광고 로드 성공'),
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        debugPrint('배너 광고 로드 실패: $error');
      },
    ),
  );
  _bannerAd?.load();
}
```

#### 전면 광고 추가 (높은 수익)

```dart
InterstitialAd? _interstitialAd;

void loadInterstitialAd() {
  InterstitialAd.load(
    adUnitId: Platform.isAndroid
        ? 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY' // 전면 광고 단위 ID
        : 'ca-app-pub-3940256099942544/1033173712',
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (ad) {
        _interstitialAd = ad;
        debugPrint('전면 광고 로드 성공');
      },
      onAdFailedToLoad: (error) {
        debugPrint('전면 광고 로드 실패: $error');
      },
    ),
  );
}

void showInterstitialAd() {
  _interstitialAd?.show();
  _interstitialAd = null;
  loadInterstitialAd(); // 다음 광고 로드
}
```

---

## 🎯 수익 극대화 팁

### 1. 광고 배치 최적화
- **보상형 광고**: 사용자가 원하는 기능과 연계
- **전면 광고**: 화면 전환 시 (과도하지 않게)
- **배너 광고**: 하단에 고정 (콘텐츠 방해하지 않게)

### 2. 사용자 경험 중시
- 광고를 억지로 보게 하지 않기
- 광고 스킵 옵션 제공
- 광고 시청에 대한 명확한 보상

### 3. AdMob 정책 준수
- 클릭 유도 금지
- 광고와 콘텐츠 구분
- 아동 대상 앱 정책 준수 (해당 시)

---

## ⚠️ 주의사항

### 테스트 vs 프로덕션

1. **개발/테스트 단계**
   - 반드시 **테스트 광고 ID** 사용
   - 실제 광고 ID로 테스트 시 계정 정지 위험

2. **프로덕션 배포 시**
   - 실제 광고 단위 ID로 교체
   - Google Play에 앱 출시 필수

### 계정 정지 방지

- ❌ 자신의 광고 클릭 금지
- ❌ 클릭 유도 문구 사용 금지
- ❌ 광고 강제 시청 금지
- ✅ 정책 준수
- ✅ 사용자 경험 우선

---

## 📞 문제 해결

### 광고가 표시되지 않을 때

1. **AdMob App ID 확인**
   - AndroidManifest.xml의 ID가 정확한지 확인

2. **광고 단위 ID 확인**
   - AdService의 ID가 정확한지 확인

3. **인터넷 연결 확인**
   - 광고 로드에는 인터넷 필요

4. **AdMob 계정 상태 확인**
   - 계정이 정지되지 않았는지 확인
   - 결제 정보가 등록되었는지 확인

### 수익이 발생하지 않을 때

1. **앱 트래픽 확인**
   - 사용자 수가 충분한지 확인

2. **광고 노출 확인**
   - AdMob 콘솔에서 노출 수 확인

3. **지역 설정**
   - 일부 지역은 광고 수익이 낮을 수 있음

---

## 🎉 요약

### 수익 연결 완료 체크리스트

- [ ] AdMob 계정 생성
- [ ] 앱 추가 및 App ID 발급
- [ ] 광고 단위 생성 (보상형)
- [ ] AndroidManifest.xml에 실제 App ID 입력
- [ ] AdService에 실제 광고 단위 ID 입력
- [ ] 결제 정보 등록
- [ ] Google Play에 앱 출시
- [ ] AdMob 승인 대기
- [ ] 수익 확인!

---

## 📚 참고 자료

- AdMob 공식 문서: https://developers.google.com/admob
- Flutter AdMob 플러그인: https://pub.dev/packages/google_mobile_ads
- AdMob 정책: https://support.google.com/admob/answer/6128543

---

**작성일**: 2025-11-11
**버전**: 1.0
**앱**: EveryDiary
