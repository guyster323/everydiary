import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/pwa_service.dart';

/// PWA 서비스 프로바이더
final pwaServiceProvider = Provider<PWAService>((ref) {
  return PWAService();
});

/// PWA 상태 관리
class PWAState {
  const PWAState({
    this.isServiceWorkerSupported = false,
    this.isServiceWorkerRegistered = false,
    this.isOnline = true,
    this.canInstall = false,
    this.isInitialized = false,
  });

  final bool isServiceWorkerSupported;
  final bool isServiceWorkerRegistered;
  final bool isOnline;
  final bool canInstall;
  final bool isInitialized;

  PWAState copyWith({
    bool? isServiceWorkerSupported,
    bool? isServiceWorkerRegistered,
    bool? isOnline,
    bool? canInstall,
    bool? isInitialized,
  }) {
    return PWAState(
      isServiceWorkerSupported:
          isServiceWorkerSupported ?? this.isServiceWorkerSupported,
      isServiceWorkerRegistered:
          isServiceWorkerRegistered ?? this.isServiceWorkerRegistered,
      isOnline: isOnline ?? this.isOnline,
      canInstall: canInstall ?? this.canInstall,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// PWA 상태 관리자
class PWANotifier extends StateNotifier<PWAState> {
  PWANotifier(this._pwaService) : super(const PWAState());

  final PWAService _pwaService;

  /// PWA 서비스 초기화
  Future<void> initialize() async {
    if (state.isInitialized) return;

    try {
      await _pwaService.initialize();

      state = state.copyWith(
        isServiceWorkerSupported: _pwaService.isServiceWorkerSupported,
        isServiceWorkerRegistered: _pwaService.isServiceWorkerRegistered,
        isOnline: _pwaService.isOnline,
        canInstall: _pwaService.canInstall,
        isInitialized: true,
      );
    } catch (e) {
      // 초기화 실패 시 기본 상태 유지
    }
  }

  /// 네트워크 상태 업데이트
  void updateNetworkStatus(bool isOnline) {
    state = state.copyWith(isOnline: isOnline);
  }

  /// PWA 설치 가능 상태 업데이트
  void updateInstallAvailability(bool canInstall) {
    state = state.copyWith(canInstall: canInstall);
  }

  /// 백그라운드 동기화 트리거
  Future<void> triggerBackgroundSync() async {
    if (!state.isServiceWorkerRegistered) return;

    try {
      // PWAService의 백그라운드 동기화 메서드 호출
      // 실제 구현에서는 PWAService에 public 메서드 추가 필요
    } catch (e) {
      // 동기화 실패 처리
    }
  }

  /// 오프라인 큐에 작업 추가
  Future<void> addToOfflineQueue(Map<String, dynamic> data) async {
    if (!state.isServiceWorkerRegistered) return;

    try {
      await _pwaService.addToOfflineQueue(data);
    } catch (e) {
      // 오프라인 큐 추가 실패 처리
    }
  }

  /// 푸시 알림 권한 요청
  Future<bool> requestNotificationPermission() async {
    if (!state.isServiceWorkerRegistered) return false;

    try {
      return await _pwaService.requestNotificationPermission();
    } catch (e) {
      return false;
    }
  }

  /// 푸시 알림 전송
  Future<void> sendNotification(
    String title,
    String body, {
    Map<String, dynamic>? data,
  }) async {
    if (!state.isServiceWorkerRegistered) return;

    try {
      await _pwaService.sendNotification(title, body, data: data);
    } catch (e) {
      // 알림 전송 실패 처리
    }
  }

  /// 캐시 정리
  Future<void> clearCache() async {
    if (!state.isServiceWorkerRegistered) return;

    try {
      await _pwaService.clearCache();
    } catch (e) {
      // 캐시 정리 실패 처리
    }
  }

  /// PWA 설치
  Future<void> installPWA() async {
    if (!state.canInstall) return;

    try {
      await _pwaService.installPWA();
    } catch (e) {
      // PWA 설치 실패 처리
    }
  }

  /// 디버그 정보 출력
  void printDebugInfo() {
    _pwaService.printDebugInfo();
  }
}

/// PWA 상태 프로바이더
final pwaProvider = StateNotifierProvider<PWANotifier, PWAState>((ref) {
  final pwaService = ref.watch(pwaServiceProvider);
  return PWANotifier(pwaService);
});

/// PWA 초기화 프로바이더
final pwaInitializationProvider = FutureProvider<void>((ref) async {
  final pwaNotifier = ref.read(pwaProvider.notifier);
  await pwaNotifier.initialize();
});

/// 온라인 상태 프로바이더
final onlineStatusProvider = Provider<bool>((ref) {
  final pwaState = ref.watch(pwaProvider);
  return pwaState.isOnline;
});

/// Service Worker 등록 상태 프로바이더
final serviceWorkerStatusProvider = Provider<bool>((ref) {
  final pwaState = ref.watch(pwaProvider);
  return pwaState.isServiceWorkerRegistered;
});

/// PWA 설치 가능 상태 프로바이더
final pwaInstallableProvider = Provider<bool>((ref) {
  final pwaState = ref.watch(pwaProvider);
  return pwaState.canInstall;
});
