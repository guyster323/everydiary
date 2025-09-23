# Features

앱의 주요 기능별 모듈을 포함하는 폴더입니다.

## 구조

- `auth/` - 사용자 인증 관련 기능
- `diary/` - 일기 작성 및 관리 기능
- `profile/` - 사용자 프로필 관리 기능

## 사용법

각 기능 폴더는 독립적인 모듈로 구성되며, 해당 기능과 관련된 모든 코드(UI, 비즈니스 로직, 상태 관리 등)를 포함합니다.

## 폴더 구조 예시

```
features/
├── auth/
│   ├── data/
│   ├── domain/
│   ├── presentation/
│   └── auth.dart
├── diary/
│   ├── data/
│   ├── domain/
│   ├── presentation/
│   └── diary.dart
└── profile/
    ├── data/
    ├── domain/
    ├── presentation/
    └── profile.dart
```
