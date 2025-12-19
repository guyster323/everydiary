/// 앱 전역 상수 정의
class AppConstants {
  // 라우트 경로
  static const String homeRoute = '/';
  static const String diaryRoute = '/diary';
  static const String memoryRoute = '/memory';
  static const String introRoute = '/intro';
  static const String permissionRoute = '/permission';
  static const String pinRoute = '/pin';

  // API 엔드포인트
  static const String huggingFaceEndpoint =
      'https://router.huggingface.co/hf-inference/models/stabilityai/stable-diffusion-xl-base-1.0';
  static const String geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent';

  // 이미지 생성 설정
  static const int maxRetryAttempts = 3;
  static const int defaultImageSize = 1024;
  static const String defaultImageFormat = 'png';
  static const bool enableGemini = true; // Gemini 활성화 (최신 2.5 Flash Image 모델 사용)

  // 보안 설정
  static const List<String> protectedPaths = [
    homeRoute,
    diaryRoute,
    memoryRoute,
    introRoute,
    permissionRoute,
    pinRoute,
  ];

  // API 키 이름
  static const String geminiApiKeyName = 'GEMINI_API_KEY';
  static const String huggingFaceApiKeyName = 'HUGGING_FACE_API_KEY';
}
