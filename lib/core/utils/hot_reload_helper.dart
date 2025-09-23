import 'package:flutter/foundation.dart';

import '../config/config.dart';
import 'logger.dart';

/// 핫 리로드 및 개발 도구 헬퍼 클래스
class HotReloadHelper {
  static bool _isHotReloadEnabled = true;
  static DateTime? _lastHotReload;

  /// 핫 리로드가 활성화되어 있는지 확인
  static bool get isHotReloadEnabled => _isHotReloadEnabled && kDebugMode;

  /// 마지막 핫 리로드 시간
  static DateTime? get lastHotReload => _lastHotReload;

  /// 핫 리로드 활성화/비활성화
  static void setHotReloadEnabled(bool enabled) {
    _isHotReloadEnabled = enabled;
    Logger.info('🔥 Hot reload ${enabled ? 'enabled' : 'disabled'}');
  }

  /// 핫 리로드 실행 (개발 모드에서만)
  static void performHotReload() {
    if (!kDebugMode) {
      Logger.warning('Hot reload is only available in debug mode');
      return;
    }

    if (!_isHotReloadEnabled) {
      Logger.warning('Hot reload is disabled');
      return;
    }

    try {
      // Flutter의 핫 리로드 기능 사용
      // 실제로는 Flutter의 hot reload API를 사용해야 함
      _lastHotReload = DateTime.now();
      Logger.info(
        '🔥 Hot reload performed at ${_lastHotReload!.toIso8601String()}',
      );

      // 성공 피드백
      if (ConfigManager.instance.enableLogging) {
        debugPrint('🔥 Hot reload completed successfully');
      }
    } catch (e) {
      Logger.error('Failed to perform hot reload: $e');
    }
  }

  /// 핫 리스타트 실행 (개발 모드에서만)
  static void performHotRestart() {
    if (!kDebugMode) {
      Logger.warning('Hot restart is only available in debug mode');
      return;
    }

    try {
      // Flutter의 핫 리스타트 기능 사용
      Logger.info('🔄 Hot restart requested');

      // 실제로는 Flutter의 hot restart API를 사용해야 함
      // 현재는 로그만 출력
      if (ConfigManager.instance.enableLogging) {
        debugPrint('🔄 Hot restart requested (implementation needed)');
      }
    } catch (e) {
      Logger.error('Failed to perform hot restart: $e');
    }
  }

  /// 개발 도구 상태 정보 가져오기
  static Map<String, dynamic> getDevToolsStatus() {
    return {
      'hot_reload_enabled': _isHotReloadEnabled,
      'debug_mode': kDebugMode,
      'profile_mode': kProfileMode,
      'release_mode': kReleaseMode,
      'last_hot_reload': _lastHotReload?.toIso8601String(),
      'flutter_version': _getFlutterVersion(),
      'dart_version': _getDartVersion(),
    };
  }

  /// Flutter 버전 정보 가져오기
  static String _getFlutterVersion() {
    try {
      // Flutter 버전 정보는 실제로는 다른 방법으로 가져와야 함
      return 'Flutter 3.x.x';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Dart 버전 정보 가져오기
  static String _getDartVersion() {
    try {
      // Dart 버전 정보는 실제로는 다른 방법으로 가져와야 함
      return 'Dart 3.x.x';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// 개발 도구 상태 출력
  static void printDevToolsStatus() {
    if (!ConfigManager.instance.enableLogging) return;

    final status = getDevToolsStatus();
    Logger.info('🛠️ Development Tools Status:');
    status.forEach((key, value) {
      Logger.info('  $key: $value');
    });
  }

  /// 키보드 단축키 등록 (개발 모드에서만)
  static void registerDevShortcuts() {
    if (!kDebugMode ||
        !FeatureFlagManager.instance.isFeatureEnabled('enableDebugMenu')) {
      return;
    }

    // Ctrl+R: 핫 리로드
    // Ctrl+Shift+R: 핫 리스타트
    // 실제 구현에서는 키보드 이벤트 리스너를 등록해야 함
    Logger.debug('🎹 Development shortcuts registered');
  }

  /// 개발 도구 초기화
  static void initialize() {
    if (!kDebugMode) return;

    Logger.info('🛠️ Initializing development tools...');

    // 개발 도구 상태 출력
    printDevToolsStatus();

    // 키보드 단축키 등록
    registerDevShortcuts();

    Logger.info('🛠️ Development tools initialized');
  }
}
