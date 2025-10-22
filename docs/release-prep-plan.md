# Release 준비 진행 계획

## 현재 상태

- PIN 보안, 앱 소개 슬라이드, 썸네일 시스템 등 핵심 기능 구현 완료
- Task 15.1 (Release 빌드 설정 및 API 키 관리)을 진행 중
- Release 파이프라인 통합과 브랜드 자산 교체 작업은 미착수

## 다음 단계

1. **Android keystore 및 서명 구성 확인** ✅

   - `release.keystore` 생성 및 `android/key.properties` 등록 완료
   - `app/build.gradle`의 release `signingConfig` 연결 확인 완료

2. **Release 빌드 파이프라인 검증** ✅

   - `flutter build apk --release` 실행 및 실제 기기 설치 검증 완료
   - `flutter build appbundle --release` 실행 완료 (Play Console 업로드 대비)

3. **API 키 분리 및 보안 강화**

   - 현재는 `--dart-define` + 환경 변수 주입 방식으로 릴리스 빌드를 진행하기로 결정
   - 개발/운영 스크립트 (예: `scripts/build-release.ps1`) 작성 여부 검토
   - 문서화 수준에서 주입 방식 명시 (자동화는 추후 CI 도입 시 고려)

4. **프로가드 및 리소스 최적화 검토**

   - ProGuard/Minify 설정 확인, 필요 시 rules 추가
   - 불필요한 디버그 리소스/로그 제거

5. **브랜드 자산 교체 (15.2)** 🔄
   - `everydiary_icon.png` (1024×1024) 확정, `flutter_launcher_icons` 설정 추가 후 Android/iOS/Web 아이콘 생성 완료
   - adaptive icon 배경색 `#FF6A2E`, 웹 파비콘 갱신 완료
   - **남은 작업:** 실제 기기/시뮬레이터에서 새 아이콘 표시 확인, iOS 런치 스크린/스플래시 최종 점검

## 참고 Task

- 15.1 Release 빌드 설정 및 API 키 관리 (진행 중)
- 15.2 앱 아이콘 및 런처 리소스 교체 (진행 중)
