import 'package:everydiary/core/providers/image_generation_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 시작 시 이미지 생성 서비스를 초기화하는 서비스
class ImageGenerationInitializer {
  final ProviderContainer _container;
  bool _isInitialized = false;

  ImageGenerationInitializer(this._container);

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ ImageGenerationInitializer 이미 초기화됨');
      return;
    }

    debugPrint('🔄 ImageGenerationInitializer 초기화 시작');
    try {
      // 이미지 생성 서비스 초기화
      await _container.read(imageGenerationInitializationProvider.future);
      _isInitialized = true;
      debugPrint('✅ ImageGenerationInitializer 초기화 완료');
    } catch (e) {
      debugPrint('❌ ImageGenerationInitializer 초기화 실패: $e');
    }
  }
}
