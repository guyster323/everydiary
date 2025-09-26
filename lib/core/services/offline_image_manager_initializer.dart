import 'package:everydiary/core/providers/offline_image_manager_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 시작 시 오프라인 이미지 관리 서비스를 초기화하는 서비스
class OfflineImageManagerInitializer {
  final ProviderContainer _container;
  bool _isInitialized = false;

  OfflineImageManagerInitializer(this._container);

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ OfflineImageManagerInitializer 이미 초기화됨');
      return;
    }

    debugPrint('🔄 OfflineImageManagerInitializer 초기화 시작');
    try {
      // 오프라인 이미지 관리 서비스 초기화
      await _container.read(offlineImageManagerInitializationProvider.future);
      _isInitialized = true;
      debugPrint('✅ OfflineImageManagerInitializer 초기화 완료');
    } catch (e) {
      debugPrint('❌ OfflineImageManagerInitializer 초기화 실패: $e');
    }
  }
}
