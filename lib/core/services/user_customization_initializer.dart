import 'package:everydiary/core/providers/user_customization_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 시작 시 사용자 커스터마이징 서비스를 초기화하는 서비스
class UserCustomizationInitializer {
  final ProviderContainer _container;
  bool _isInitialized = false;

  UserCustomizationInitializer(this._container);

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ UserCustomizationInitializer 이미 초기화됨');
      return;
    }

    debugPrint('🔄 UserCustomizationInitializer 초기화 시작');
    try {
      // 사용자 커스터마이징 서비스 초기화
      await _container.read(userCustomizationInitializationProvider.future);
      _isInitialized = true;
      debugPrint('✅ UserCustomizationInitializer 초기화 완료');
    } catch (e) {
      debugPrint('❌ UserCustomizationInitializer 초기화 실패: $e');
    }
  }
}
