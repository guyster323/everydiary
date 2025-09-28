// ignore_for_file: constant_identifier_names
import 'dart:io';

import 'secrets_manager.dart';

class ApiKeys {
  static String get geminiApiKey {
    final envKey = Platform.environment['GEMINI_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }

    final storedKey = SecretsManager.instance.getSecret('gemini_api_key');
    return storedKey ?? '';
  }

  static String get huggingFaceApiKey {
    final envKey = Platform.environment['HUGGING_FACE_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }

    final storedKey = SecretsManager.instance.getSecret('hugging_face_api_key');
    return storedKey ?? '';
  }
}
