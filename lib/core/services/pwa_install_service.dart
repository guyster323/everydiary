import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pwa_service.dart';

/// PWA 설치 및 업데이트를 관리하는 서비스
class PWAInstallService {
  static final PWAInstallService _instance = PWAInstallService._internal();
  factory PWAInstallService() => _instance;
  PWAInstallService._internal();

  final PWAService _pwaService = PWAService();

  // 설치 상태
  bool _isInstalled = false;
  bool _isInstallable = false;
  bool _isUpdateAvailable = false;
  String? _currentVersion;
  String? _latestVersion;

  // 이벤트 스트림
  final StreamController<PWAInstallEvent> _eventController =
      StreamController<PWAInstallEvent>.broadcast();
  Stream<PWAInstallEvent> get eventStream => _eventController.stream;

  // Riverpod과 통합을 위한 스트림들
  final StreamController<bool> _installabilityController =
      StreamController<bool>.broadcast();
  Stream<bool> get installabilityStream => _installabilityController.stream;

  final StreamController<bool> _installedController =
      StreamController<bool>.broadcast();
  Stream<bool> get installedStream => _installedController.stream;

  final StreamController<bool> _updateAvailableController =
      StreamController<bool>.broadcast();
  Stream<bool> get updateAvailableStream => _updateAvailableController.stream;

  final StreamController<Map<String, dynamic>> _versionInfoController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get versionInfoStream =>
      _versionInfoController.stream;

  // 타이머
  Timer? _updateCheckTimer;

  bool _isInitialized = false;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 PWA 설치 서비스 초기화 시작');

      await _pwaService.initialize();

      // 설치 상태 확인
      await _checkInstallStatus();
      debugPrint(
        '📊 PWA 초기 상태 - 설치 가능: $_isInstallable, 설치됨: $_isInstalled, 버전: $_currentVersion',
      );

      // 업데이트 체크 타이머 시작
      _startUpdateCheckTimer();

      _isInitialized = true;
      debugPrint('✅ PWA 설치 서비스 초기화 완료');
    } catch (e) {
      debugPrint('❌ PWA 설치 서비스 초기화 실패: $e');
    }
  }

  /// 설치 상태 확인
  Future<void> _checkInstallStatus() async {
    try {
      _isInstalled = await _pwaService.isAppInstalled();
      _isInstallable = _pwaService.canInstall;
      _currentVersion = await _pwaService.getServiceWorkerVersion();

      // 스트림에 상태 변경 알림
      _installabilityController.add(_isInstallable);
      _installedController.add(_isInstalled);
      _versionInfoController.add({
        'currentVersion': _currentVersion,
        'latestVersion': _latestVersion,
      });

      debugPrint('📱 PWA 설치 상태: $_isInstalled, 설치 가능: $_isInstallable');
    } catch (e) {
      debugPrint('❌ 설치 상태 확인 실패: $e');
    }
  }

  /// 업데이트 체크 타이머 시작
  void _startUpdateCheckTimer() {
    _updateCheckTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _checkForUpdates();
    });
  }

  /// 업데이트 확인
  Future<void> _checkForUpdates() async {
    try {
      final latestVersion = await _pwaService.getServiceWorkerVersion();
      if (latestVersion != null && latestVersion != _currentVersion) {
        _latestVersion = latestVersion;
        _isUpdateAvailable = true;

        // 스트림에 업데이트 가능성 알림
        _updateAvailableController.add(true);
        _versionInfoController.add({
          'currentVersion': _currentVersion,
          'latestVersion': _latestVersion,
        });

        _eventController.add(
          PWAInstallEvent.updateAvailable(_currentVersion, _latestVersion),
        );
        debugPrint('🔄 업데이트 사용 가능: $_currentVersion -> $_latestVersion');
      }
    } catch (e) {
      debugPrint('❌ 업데이트 확인 실패: $e');
    }
  }

  /// PWA 설치
  Future<bool> installPWA() async {
    try {
      debugPrint('📱 PWA 설치 시작');

      if (!_isInstallable) {
        debugPrint('❌ PWA 설치 불가능');
        return false;
      }

      await _pwaService.installPWA();
      // PWA 설치는 사용자 상호작용이므로 성공으로 간주
      const success = true;
      if (success) {
        _isInstalled = true;
        _isInstallable = false;

        // 통계 업데이트
        await _updateInstallStats();

        // 스트림에 상태 변경 알림
        _installedController.add(true);
        _installabilityController.add(false);

        _eventController.add(PWAInstallEvent.installed());
        debugPrint('✅ PWA 설치 완료');
      }

      return success;
    } catch (e) {
      debugPrint('❌ PWA 설치 실패: $e');
      return false;
    }
  }

  /// PWA 업데이트
  Future<bool> updatePWA() async {
    try {
      debugPrint('🔄 PWA 업데이트 시작');

      if (!_isUpdateAvailable) {
        debugPrint('❌ 업데이트 없음');
        return false;
      }

      // PWA 업데이트는 Service Worker 업데이트를 통해 처리
      await _pwaService.clearCache();
      const success = true;
      if (success) {
        _isUpdateAvailable = false;
        _currentVersion = _latestVersion;

        // 통계 업데이트
        await _updateUpdateStats();

        // 스트림에 상태 변경 알림
        _updateAvailableController.add(false);
        _versionInfoController.add({
          'currentVersion': _currentVersion,
          'latestVersion': _latestVersion,
        });

        _eventController.add(PWAInstallEvent.updated(_currentVersion));
        debugPrint('✅ PWA 업데이트 완료: $_currentVersion');
      }

      return success;
    } catch (e) {
      debugPrint('❌ PWA 업데이트 실패: $e');
      return false;
    }
  }

  /// 설치 가능 여부
  bool get isInstallable => _isInstallable;

  /// 설치 여부
  bool get isInstalled => _isInstalled;

  /// 업데이트 사용 가능 여부
  bool get isUpdateAvailable => _isUpdateAvailable;

  /// 현재 버전
  String? get currentVersion => _currentVersion;

  /// 최신 버전
  String? get latestVersion => _latestVersion;

  /// 설치 통계 가져오기
  Future<Map<String, dynamic>> getInstallStats() async {
    try {
      return {
        'isInstalled': _isInstalled,
        'isInstallable': _isInstallable,
        'isUpdateAvailable': _isUpdateAvailable,
        'currentVersion': _currentVersion,
        'latestVersion': _latestVersion,
        'installCount': await _getInstallCount(),
        'lastInstallTime': await _getLastInstallTime(),
        'updateCount': await _getUpdateCount(),
        'lastUpdateTime': await _getLastUpdateTime(),
      };
    } catch (e) {
      debugPrint('❌ 설치 통계 가져오기 실패: $e');
      return {};
    }
  }

  /// 설치 횟수 가져오기
  Future<int> _getInstallCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('pwa_install_count') ?? 0;
    } catch (e) {
      debugPrint('❌ 설치 횟수 가져오기 실패: $e');
      return 0;
    }
  }

  /// 마지막 설치 시간 가져오기
  Future<DateTime?> _getLastInstallTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('pwa_last_install_time');
      return timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null;
    } catch (e) {
      debugPrint('❌ 마지막 설치 시간 가져오기 실패: $e');
      return null;
    }
  }

  /// 업데이트 횟수 가져오기
  Future<int> _getUpdateCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('pwa_update_count') ?? 0;
    } catch (e) {
      debugPrint('❌ 업데이트 횟수 가져오기 실패: $e');
      return 0;
    }
  }

  /// 마지막 업데이트 시간 가져오기
  Future<DateTime?> _getLastUpdateTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('pwa_last_update_time');
      return timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null;
    } catch (e) {
      debugPrint('❌ 마지막 업데이트 시간 가져오기 실패: $e');
      return null;
    }
  }

  /// 설치 통계 업데이트
  Future<void> _updateInstallStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = await _getInstallCount();
      await prefs.setInt('pwa_install_count', currentCount + 1);
      await prefs.setInt(
        'pwa_last_install_time',
        DateTime.now().millisecondsSinceEpoch,
      );
      debugPrint('📊 설치 통계 업데이트: ${currentCount + 1}');
    } catch (e) {
      debugPrint('❌ 설치 통계 업데이트 실패: $e');
    }
  }

  /// 업데이트 통계 업데이트
  Future<void> _updateUpdateStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = await _getUpdateCount();
      await prefs.setInt('pwa_update_count', currentCount + 1);
      await prefs.setInt(
        'pwa_last_update_time',
        DateTime.now().millisecondsSinceEpoch,
      );
      debugPrint('📊 업데이트 통계 업데이트: ${currentCount + 1}');
    } catch (e) {
      debugPrint('❌ 업데이트 통계 업데이트 실패: $e');
    }
  }

  /// 설치 이벤트 추적
  void trackInstallEvent(String eventType, Map<String, dynamic> data) {
    try {
      debugPrint('📊 설치 이벤트 추적: $eventType');

      // 이벤트 데이터에 타임스탬프 추가
      final eventData = {
        ...data,
        'eventType': eventType,
        'timestamp': DateTime.now().toIso8601String(),
        'isInstalled': _isInstalled,
        'isInstallable': _isInstallable,
        'currentVersion': _currentVersion,
      };

      // 이벤트 스트림에 전송
      _eventController.add(
        PWAInstallEvent.installabilityChanged(_isInstallable),
      );

      // 실제 구현에서는 분석 서비스에 전송
      // 예: Firebase Analytics, Google Analytics 등
      debugPrint('📊 설치 이벤트 데이터: $eventData');
    } catch (e) {
      debugPrint('❌ 설치 이벤트 추적 실패: $e');
    }
  }

  /// 업데이트 이벤트 추적
  void trackUpdateEvent(String eventType, Map<String, dynamic> data) {
    try {
      debugPrint('📊 업데이트 이벤트 추적: $eventType');

      // 이벤트 데이터에 타임스탬프 추가
      final eventData = {
        ...data,
        'eventType': eventType,
        'timestamp': DateTime.now().toIso8601String(),
        'isUpdateAvailable': _isUpdateAvailable,
        'currentVersion': _currentVersion,
        'latestVersion': _latestVersion,
      };

      // 이벤트 스트림에 전송
      _eventController.add(
        PWAInstallEvent.updateStatusChanged(_isUpdateAvailable),
      );

      // 실제 구현에서는 분석 서비스에 전송
      // 예: Firebase Analytics, Google Analytics 등
      debugPrint('📊 업데이트 이벤트 데이터: $eventData');
    } catch (e) {
      debugPrint('❌ 업데이트 이벤트 추적 실패: $e');
    }
  }

  /// 설치 가능성 확인
  Future<void> checkInstallability() async {
    try {
      _isInstallable = _pwaService.canInstall;
      _installabilityController.add(_isInstallable);
      debugPrint('🔍 설치 가능성 확인: $_isInstallable');
    } catch (e) {
      debugPrint('❌ 설치 가능성 확인 실패: $e');
    }
  }

  /// 업데이트 확인 (public)
  Future<void> checkForUpdates() async {
    await _checkForUpdates();
  }

  /// 앱 설치 상태 확인
  /// 서비스 정리
  void dispose() {
    _updateCheckTimer?.cancel();
    _eventController.close();
    _installabilityController.close();
    _installedController.close();
    _updateAvailableController.close();
    _versionInfoController.close();
    debugPrint('🗑️ PWA 설치 서비스 정리 완료');
  }
}

/// PWA 설치 이벤트
abstract class PWAInstallEvent {
  final DateTime timestamp;

  PWAInstallEvent() : timestamp = DateTime.now();

  factory PWAInstallEvent.installed() = PWAInstalledEvent;
  factory PWAInstallEvent.updateAvailable(String? current, String? latest) =
      PWAUpdateAvailableEvent;
  factory PWAInstallEvent.updated(String? version) = PWAUpdatedEvent;
  factory PWAInstallEvent.installPromptShown() = PWAInstallPromptShownEvent;
  factory PWAInstallEvent.installPromptDismissed() =
      PWAInstallPromptDismissedEvent;
  factory PWAInstallEvent.installabilityChanged(bool isInstallable) =
      PWAInstallabilityChangedEvent;
  factory PWAInstallEvent.installedStatusChanged(bool isInstalled) =
      PWAInstalledStatusChangedEvent;
  factory PWAInstallEvent.updateStatusChanged(bool isUpdateAvailable) =
      PWAUpdateStatusChangedEvent;
}

class PWAInstalledEvent extends PWAInstallEvent {
  PWAInstalledEvent();
}

class PWAUpdateAvailableEvent extends PWAInstallEvent {
  final String? currentVersion;
  final String? latestVersion;

  PWAUpdateAvailableEvent(this.currentVersion, this.latestVersion);
}

class PWAUpdatedEvent extends PWAInstallEvent {
  final String? version;

  PWAUpdatedEvent(this.version);
}

class PWAInstallPromptShownEvent extends PWAInstallEvent {
  PWAInstallPromptShownEvent();
}

class PWAInstallPromptDismissedEvent extends PWAInstallEvent {
  PWAInstallPromptDismissedEvent();
}

class PWAInstallabilityChangedEvent extends PWAInstallEvent {
  final bool isInstallable;

  PWAInstallabilityChangedEvent(this.isInstallable);
}

class PWAInstalledStatusChangedEvent extends PWAInstallEvent {
  final bool isInstalled;

  PWAInstalledStatusChangedEvent(this.isInstalled);
}

class PWAUpdateStatusChangedEvent extends PWAInstallEvent {
  final bool isUpdateAvailable;

  PWAUpdateStatusChangedEvent(this.isUpdateAvailable);
}
