import 'package:everydiary/core/providers/pwa_install_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 시작 시 PWA 설치 서비스를 초기화하는 서비스
class PWAInstallInitializer {
  final ProviderContainer _container;
  bool _isInitialized = false;

  PWAInstallInitializer(this._container);

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ PWAInstallInitializer 이미 초기화됨');
      return;
    }

    debugPrint('🔄 PWAInstallInitializer 초기화 시작');
    try {
      _container.read(pwaInstallStateNotifierProvider);
      _isInitialized = true;
      debugPrint('✅ PWAInstallInitializer 초기화 완료');
    } catch (e) {
      debugPrint('❌ PWAInstallInitializer 초기화 실패: $e');
    }
  }
}
