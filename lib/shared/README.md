# Shared

여러 기능에서 공통으로 사용되는 컴포넌트들을 포함하는 폴더입니다.

## 구조

- `models/` - 공통 데이터 모델들
- `services/` - 공통 서비스들 (API, 로컬 저장소 등)
- `widgets/` - 공통 UI 컴포넌트들

## 사용법

이 폴더의 컴포넌트들은 여러 기능에서 재사용되지만, core 폴더의 컴포넌트보다는 더 구체적인 기능을 제공합니다.

## 예시

- `models/` - User, Diary, ApiResponse 등의 공통 모델
- `services/` - DatabaseService, ApiService 등의 공통 서비스
- `widgets/` - CustomButton, LoadingIndicator 등의 공통 위젯
