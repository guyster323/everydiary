// ignore_for_file: constant_identifier_names
import 'dart:io';

class ApiKeys {
  static String get geminiApiKey {
    // 1. 환경변수에서 먼저 확인
    final envKey = Platform.environment['GEMINI_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }

    // 2. 하드코딩된 키 (개발용)
    return 'YOUR_GEMINI_API_KEY_HERE'; // 실제 키로 교체
  }

  static String get huggingFaceApiKey {
    // 1. 환경변수에서 먼저 확인
    final envKey = Platform.environment['HUGGING_FACE_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }

    // 2. 하드코딩된 키 (개발용)
    return 'YOUR_HUGGING_FACE_API_KEY_HERE'; // 실제 키로 교체
  }
}
