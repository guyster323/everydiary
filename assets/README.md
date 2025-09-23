# Assets

앱에서 사용되는 정적 리소스들을 포함하는 폴더입니다.

## 구조

- `images/` - 이미지 파일들 (PNG, JPG, WebP 등)
- `icons/` - 아이콘 파일들 (SVG, PNG 등)
- `animations/` - 애니메이션 파일들 (Lottie JSON 등)
- `fonts/` - 커스텀 폰트 파일들 (TTF, OTF 등)

## 사용법

이 폴더의 리소스들은 `pubspec.yaml`의 `assets` 섹션에서 참조되며, Flutter 앱에서 `AssetImage` 또는 `Image.asset()` 등을 통해 사용할 수 있습니다.

## 예시

```dart
// 이미지 사용
Image.asset('assets/images/logo.png')

// 아이콘 사용
SvgPicture.asset('assets/icons/home.svg')

// 애니메이션 사용
Lottie.asset('assets/animations/loading.json')
```
