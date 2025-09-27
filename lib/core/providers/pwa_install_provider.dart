import 'dart:async';

import 'package:everydiary/core/services/pwa_install_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final pwaInstallServiceProvider = AutoDisposeProvider<PWAInstallService>((ref) {
  final service = PWAInstallService();
  ref.onDispose(service.dispose);
  return service;
});

final pwaInstallStateNotifierProvider =
    AutoDisposeNotifierProvider<PWAInstallStateNotifier, PWAInstallStateData>(
      PWAInstallStateNotifier.new,
    );

class PWAInstallStateNotifier extends AutoDisposeNotifier<PWAInstallStateData> {
  @override
  PWAInstallStateData build() {
    _initialize();
    return const PWAInstallStateData();
  }

  /// 초기화
  Future<void> _initialize() async {
    debugPrint('🔄 PWA 설치 상태 초기화 시작');

    final service = ref.read(pwaInstallServiceProvider);
    await service.initialize();

    state = state.copyWith(
      isInstallable: service.isInstallable,
      isInstalled: service.isInstalled,
      isUpdateAvailable: service.isUpdateAvailable,
      currentVersion: service.currentVersion,
      latestVersion: service.latestVersion,
    );

    // 설치 가능성 스트림 구독
    service.installabilityStream.listen(
      (isInstallable) {
        debugPrint('🔔 설치 가능성 변경: $isInstallable');
        state = state.copyWith(isInstallable: isInstallable);
      },
      onError: (Object error) {
        debugPrint('❌ 설치 가능성 스트림 오류: $error');
      },
    );

    // 설치 상태 스트림 구독
    service.installedStream.listen(
      (isInstalled) {
        debugPrint('🔔 설치 상태 변경: $isInstalled');
        state = state.copyWith(isInstalled: isInstalled);
      },
      onError: (Object error) {
        debugPrint('❌ 설치 상태 스트림 오류: $error');
      },
    );

    // 업데이트 확인 스트림 구독
    service.updateAvailableStream.listen(
      (isUpdateAvailable) {
        debugPrint('🔔 업데이트 가능성 변경: $isUpdateAvailable');
        state = state.copyWith(isUpdateAvailable: isUpdateAvailable);
      },
      onError: (Object error) {
        debugPrint('❌ 업데이트 가능성 스트림 오류: $error');
      },
    );

    // 버전 정보 스트림 구독
    service.versionInfoStream.listen(
      (versionInfo) {
        debugPrint('🔔 버전 정보 변경: $versionInfo');
        state = state.copyWith(
          currentVersion: versionInfo['currentVersion'] as String?,
          latestVersion: versionInfo['latestVersion'] as String?,
        );
      },
      onError: (Object error) {
        debugPrint('❌ 버전 정보 스트림 오류: $error');
      },
    );

    debugPrint('✅ PWA 설치 상태 초기화 완료');
  }

  /// PWA 설치
  Future<bool> installPWA() async {
    try {
      final service = ref.read(pwaInstallServiceProvider);
      final success = await service.installPWA();

      if (success) {
        debugPrint('✅ PWA 설치 성공');
        state = state.copyWith(isInstalled: true, isInstallable: false);
      } else {
        debugPrint('❌ PWA 설치 실패');
      }

      return success;
    } catch (e) {
      debugPrint('❌ PWA 설치 오류: $e');
      return false;
    }
  }

  /// PWA 업데이트
  Future<bool> updatePWA() async {
    try {
      final service = ref.read(pwaInstallServiceProvider);
      final success = await service.updatePWA();

      if (success) {
        debugPrint('✅ PWA 업데이트 성공');
        state = state.copyWith(isUpdateAvailable: false);
      } else {
        debugPrint('❌ PWA 업데이트 실패');
      }

      return success;
    } catch (e) {
      debugPrint('❌ PWA 업데이트 오류: $e');
      return false;
    }
  }

  /// 설치 이벤트 추적
  void trackInstallEvent(String event, Map<String, dynamic> data) {
    try {
      final service = ref.read(pwaInstallServiceProvider);
      service.trackInstallEvent(event, data);
    } catch (e) {
      debugPrint('❌ 설치 이벤트 추적 오류: $e');
    }
  }

  /// 업데이트 이벤트 추적
  void trackUpdateEvent(String event, Map<String, dynamic> data) {
    try {
      final service = ref.read(pwaInstallServiceProvider);
      service.trackUpdateEvent(event, data);
    } catch (e) {
      debugPrint('❌ 업데이트 이벤트 추적 오류: $e');
    }
  }

  /// 설치 가능성 확인
  Future<void> checkInstallability() async {
    try {
      final service = ref.read(pwaInstallServiceProvider);
      await service.checkInstallability();
    } catch (e) {
      debugPrint('❌ 설치 가능성 확인 오류: $e');
    }
  }

  /// 업데이트 확인
  Future<void> checkForUpdates() async {
    try {
      final service = ref.read(pwaInstallServiceProvider);
      await service.checkForUpdates();
    } catch (e) {
      debugPrint('❌ 업데이트 확인 오류: $e');
    }
  }
}

/// PWA 설치 상태 데이터
class PWAInstallStateData {
  final bool isInstalled;
  final bool isInstallable;
  final bool isUpdateAvailable;
  final String? currentVersion;
  final String? latestVersion;

  const PWAInstallStateData({
    this.isInstalled = false,
    this.isInstallable = false,
    this.isUpdateAvailable = false,
    this.currentVersion,
    this.latestVersion,
  });

  PWAInstallStateData copyWith({
    bool? isInstalled,
    bool? isInstallable,
    bool? isUpdateAvailable,
    String? currentVersion,
    String? latestVersion,
  }) {
    return PWAInstallStateData(
      isInstalled: isInstalled ?? this.isInstalled,
      isInstallable: isInstallable ?? this.isInstallable,
      isUpdateAvailable: isUpdateAvailable ?? this.isUpdateAvailable,
      currentVersion: currentVersion ?? this.currentVersion,
      latestVersion: latestVersion ?? this.latestVersion,
    );
  }
}
