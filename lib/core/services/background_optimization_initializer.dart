import 'package:everydiary/core/providers/background_optimization_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 시작 시 배경 최적화 서비스를 초기화하는 서비스
class BackgroundOptimizationInitializer {
  final ProviderContainer _container;
  bool _isInitialized = false;

  BackgroundOptimizationInitializer(this._container);

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ BackgroundOptimizationInitializer 이미 초기화됨');
      return;
    }

    debugPrint('🔄 BackgroundOptimizationInitializer 초기화 시작');
    try {
      // 배경 최적화 서비스 초기화
      await _container.read(
        backgroundOptimizationInitializationProvider.future,
      );
      _isInitialized = true;
      debugPrint('✅ BackgroundOptimizationInitializer 초기화 완료');
    } catch (e) {
      debugPrint('❌ BackgroundOptimizationInitializer 초기화 실패: $e');
    }
  }
}
