# Privacy Policy & Terms & Conditions 호스팅 가이드

구글 플레이 콘솔에 앱을 업로드할 때 Privacy Policy와 Terms & Conditions의 URL이 필요합니다.

## 생성된 파일

- `privacy-policy.html` - Privacy Policy HTML 파일
- `terms-and-conditions.html` - Terms & Conditions HTML 파일

## 호스팅 방법

### 방법 1: GitHub Pages (추천 - 무료)

1. GitHub 저장소에 이 파일들을 업로드합니다
2. 저장소 설정에서 Pages를 활성화합니다
   - Settings > Pages > Source를 "main" 브랜치의 "/docs" 폴더로 설정
3. 몇 분 후 다음 URL로 접근 가능합니다:
   - `https://[사용자명].github.io/[저장소명]/privacy-policy.html`
   - `https://[사용자명].github.io/[저장소명]/terms-and-conditions.html`

### 방법 2: Firebase Hosting (무료)

1. Firebase 프로젝트 생성
2. Firebase CLI 설치 및 로그인
3. `firebase init hosting` 실행
4. `docs` 폴더를 public 디렉토리로 설정
5. `firebase deploy` 실행
6. URL: `https://[프로젝트명].web.app/privacy-policy.html`

### 방법 3: Netlify (무료)

1. Netlify 계정 생성
2. GitHub 저장소 연결 또는 드래그 앤 드롭으로 `docs` 폴더 업로드
3. 자동으로 URL 생성됨

### 방법 4: 직접 웹 서버 호스팅

HTML 파일을 웹 서버에 업로드하고 공개 URL을 제공합니다.

## 구글 플레이 콘솔 설정

1. Google Play Console에 로그인
2. 앱 선택 > 정책 > 앱 콘텐츠
3. "개인정보처리방침" 섹션에서 호스팅된 Privacy Policy URL 입력
4. "이용약관" 섹션에서 호스팅된 Terms & Conditions URL 입력

## 참고사항

- URL은 HTTPS를 사용해야 합니다
- URL은 공개적으로 접근 가능해야 합니다
- 내용이 변경되면 URL은 동일하게 유지하되 내용만 업데이트하는 것이 좋습니다
