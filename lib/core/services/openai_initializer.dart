import 'package:everydiary/core/providers/openai_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 시작 시 OpenAI 서비스를 초기화하는 서비스
class OpenAIInitializer {
  final ProviderContainer _container;
  bool _isInitialized = false;

  OpenAIInitializer(this._container);

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ OpenAIInitializer 이미 초기화됨');
      return;
    }

    debugPrint('🔄 OpenAIInitializer 초기화 시작');
    try {
      // OpenAI 서비스 초기화
      await _container.read(openaiInitializationProvider.future);
      _isInitialized = true;
      debugPrint('✅ OpenAIInitializer 초기화 완료');
    } catch (e) {
      debugPrint('❌ OpenAIInitializer 초기화 실패: $e');
    }
  }
}
