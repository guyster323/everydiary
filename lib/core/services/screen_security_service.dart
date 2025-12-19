import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 플랫폼별 스크린 보안 설정을 제어하는 서비스.
class ScreenSecurityService {
  ScreenSecurityService._();

  static final ScreenSecurityService instance = ScreenSecurityService._();

  static const MethodChannel _channel = MethodChannel(
    'com.everydiary.lite/screen_security',
  );

  bool _currentApplied = false;

  Future<void> setSecure(bool enabled) async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }
    if (_currentApplied == enabled) {
      return;
    }
    _currentApplied = enabled;
    try {
      await _channel.invokeMethod<void>('setSecure', {'enabled': enabled});
    } on PlatformException catch (_) {
      _currentApplied = !enabled;
      rethrow;
    }
  }
}
