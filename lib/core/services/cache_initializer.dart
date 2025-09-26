import 'package:flutter/foundation.dart';

import 'cache_manager_service.dart';

/// 캐시 초기화 서비스
class CacheInitializer {
  static final CacheInitializer _instance = CacheInitializer._internal();
  factory CacheInitializer() => _instance;
  CacheInitializer._internal();

  bool _isInitialized = false;

  /// 캐시 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 캐시 초기화 시작');

      final cacheManager = CacheManagerService();
      await cacheManager.initialize();

      _isInitialized = true;
      debugPrint('✅ 캐시 초기화 완료');
    } catch (e) {
      debugPrint('❌ 캐시 초기화 실패: $e');
    }
  }

  /// 초기화 상태 확인
  bool get isInitialized => _isInitialized;
}
