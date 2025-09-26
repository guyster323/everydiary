import 'package:flutter/foundation.dart';

import 'offline_state_manager.dart';

/// 오프라인 상태 초기화 서비스
class OfflineStateInitializer {
  static final OfflineStateInitializer _instance =
      OfflineStateInitializer._internal();
  factory OfflineStateInitializer() => _instance;
  OfflineStateInitializer._internal();

  bool _isInitialized = false;

  /// 오프라인 상태 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 오프라인 상태 초기화 시작');

      final manager = OfflineStateManager();
      await manager.initialize();

      _isInitialized = true;
      debugPrint('✅ 오프라인 상태 초기화 완료');
    } catch (e) {
      debugPrint('❌ 오프라인 상태 초기화 실패: $e');
    }
  }

  /// 초기화 상태 확인
  bool get isInitialized => _isInitialized;
}
