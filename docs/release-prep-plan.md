# Release 준비 진행 계획

## 현재 상태
- PIN 보안, 앱 소개 슬라이드, 썸네일 시스템 등 핵심 기능 구현 완료
- Task 15.1 (Release 빌드 설정 및 API 키 관리)을 진행 중
- Release 파이프라인 통합과 브랜드 자산 교체 작업은 미착수

## 다음 단계
1. **Android keystore 및 서명 구성 확인**
   - 기존 release keystore 존재 여부 확인
   - 없을 경우 `keytool`로 생성하여 `android/key.properties`에 등록
   - `app/build.gradle`의 release `signingConfig` 연결 상태 검증

2. **Release 빌드 파이프라인 검증**
   - `flutter build apk --release` 실행
   - Play Store 업로드 대비 `flutter build appbundle`도 점검
   - 빌드 중 발생하는 경고/오류 정리 및 해결

3. **API 키 분리 및 보안 강화**
   - 현재 코드에 하드코딩된 API 키/엔드포인트 파악
   - `--dart-define` 또는 환경 변수 방식으로 release/debug 분리 주입
   - Taskmaster 문서에 적용 방법 기록

4. **프로가드 및 리소스 최적화 검토**
   - ProGuard/Minify 설정 확인, 필요 시 rules 추가
   - 불필요한 디버그 리소스/로그 제거

5. **브랜드 자산 교체 계획 수립 (15.2)**
   - Android/iOS/Web 아이콘 및 스플래시 교체 작업 범위 정의
   - `flutter_launcher_icons` 사용 여부 결정 및 실행 시점 조율

## 참고 Task
- 15.1 Release 빌드 설정 및 API 키 관리 (진행 중)
- 15.2 앱 아이콘 및 런처 리소스 교체 (대기)

