import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter/foundation.dart';

/// PWA (Progressive Web App) 서비스 (웹 전용)
/// Service Worker와의 상호작용을 담당합니다.
class PWAService {
  static final PWAService _instance = PWAService._internal();
  factory PWAService() => _instance;
  PWAService._internal();

  bool _isServiceWorkerSupported = false;
  bool _isServiceWorkerRegistered = false;
  bool _isOnline = true;

  /// Service Worker 지원 여부
  bool get isServiceWorkerSupported => _isServiceWorkerSupported;

  /// Service Worker 등록 여부
  bool get isServiceWorkerRegistered => _isServiceWorkerRegistered;

  /// 온라인 상태
  bool get isOnline => _isOnline;

  /// PWA 서비스 초기화
  Future<void> initialize() async {
    try {
      debugPrint('🔧 PWA Service 초기화 시작...');

      // Service Worker 지원 확인
      _isServiceWorkerSupported = html.window.navigator.serviceWorker != null;

      if (!_isServiceWorkerSupported) {
        debugPrint('⚠️ PWA Service: Service Worker를 지원하지 않습니다.');
        return;
      }

      // 네트워크 상태 감지
      _setupNetworkStatusListener();

      // Service Worker 등록
      await _registerServiceWorker();

      debugPrint('✅ PWA Service 초기화 완료');
    } catch (e) {
      debugPrint('❌ PWA Service 초기화 실패: $e');
    }
  }

  /// Service Worker 등록
  Future<void> _registerServiceWorker() async {
    try {
      final registration = await html.window.navigator.serviceWorker!.register(
        '/sw.js',
      );

      _isServiceWorkerRegistered = true;
      debugPrint('✅ Service Worker 등록 성공: ${registration.scope}');

      // 업데이트 감지
      registration.addEventListener('updatefound', (event) {
        debugPrint('🔄 Service Worker 업데이트 감지');
        _handleServiceWorkerUpdate(registration);
      });

      // 컨트롤러 변경 감지
      html.window.navigator.serviceWorker!.addEventListener(
        'controllerchange',
        (event) {
          debugPrint('🔄 Service Worker 컨트롤러 변경');
          html.window.location.reload();
        },
      );
    } catch (e) {
      debugPrint('❌ Service Worker 등록 실패: $e');
      _isServiceWorkerRegistered = false;
    }
  }

  /// Service Worker 업데이트 처리
  void _handleServiceWorkerUpdate(html.ServiceWorkerRegistration registration) {
    final newWorker = registration.installing;
    if (newWorker == null) return;

    newWorker.addEventListener('statechange', (event) {
      if (newWorker.state == 'installed' &&
          html.window.navigator.serviceWorker!.controller != null) {
        debugPrint('🔄 새로운 Service Worker 버전 사용 가능');
        _showUpdateNotification();
      }
    });
  }

  /// 업데이트 알림 표시
  void _showUpdateNotification() {
    // 사용자에게 업데이트 알림
    if (html.window.confirm('새로운 버전이 사용 가능합니다. 지금 업데이트하시겠습니까?')) {
      _skipWaiting();
    }
  }

  /// Service Worker 대기 건너뛰기
  void _skipWaiting() {
    if (html.window.navigator.serviceWorker!.controller != null) {
      html.window.navigator.serviceWorker!.controller!.postMessage({
        'type': 'SKIP_WAITING',
      });
    }
  }

  /// 네트워크 상태 리스너 설정
  void _setupNetworkStatusListener() {
    _isOnline = html.window.navigator.onLine ?? true;

    html.window.addEventListener('online', (event) {
      _isOnline = true;
      debugPrint('🌐 네트워크 연결됨');
      _onNetworkStatusChanged(true);
    });

    html.window.addEventListener('offline', (event) {
      _isOnline = false;
      debugPrint('📴 네트워크 연결 끊어짐');
      _onNetworkStatusChanged(false);
    });
  }

  /// 네트워크 상태 변경 처리
  void _onNetworkStatusChanged(bool isOnline) {
    if (isOnline) {
      // 온라인 상태로 복구 시 백그라운드 동기화 트리거
      _triggerBackgroundSync();
    }
  }

  /// 백그라운드 동기화 트리거
  Future<void> _triggerBackgroundSync() async {
    if (!_isServiceWorkerRegistered) return;

    try {
      final registration = await html.window.navigator.serviceWorker!.ready;
      await registration.sync?.register('background-sync');
      debugPrint('🔄 백그라운드 동기화 트리거됨');
    } catch (e) {
      debugPrint('❌ 백그라운드 동기화 트리거 실패: $e');
    }
  }

  /// 오프라인 큐에 작업 추가
  Future<void> addToOfflineQueue(Map<String, dynamic> data) async {
    if (!_isServiceWorkerRegistered) return;

    try {
      // 간소화된 로컬 스토리지 사용
      final key = 'offline_queue_${DateTime.now().millisecondsSinceEpoch}';
      final value = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'retryCount': 0,
      };

      html.window.localStorage[key] = value.toString();
      debugPrint('📝 오프라인 큐에 작업 추가됨');
    } catch (e) {
      debugPrint('❌ 오프라인 큐 추가 실패: $e');
    }
  }

  /// 푸시 알림 권한 요청
  Future<bool> requestNotificationPermission() async {
    if (!_isServiceWorkerRegistered) return false;

    try {
      // 간소화된 알림 권한 처리
      return true;
    } catch (e) {
      debugPrint('❌ 알림 권한 요청 실패: $e');
      return false;
    }
  }

  /// 푸시 알림 전송
  Future<void> sendNotification(
    String title,
    String body, {
    Map<String, dynamic>? data,
  }) async {
    if (!_isServiceWorkerRegistered) return;

    try {
      final registration = await html.window.navigator.serviceWorker!.ready;

      await registration.showNotification(title, {
        'body': body,
        'icon': '/icons/Icon-192.png',
        'badge': '/icons/Icon-192.png',
        'data': data ?? {},
        'vibrate': [200, 100, 200],
        'actions': [
          {'action': 'view', 'title': '확인하기', 'icon': '/icons/Icon-192.png'},
          {'action': 'dismiss', 'title': '닫기', 'icon': '/icons/Icon-192.png'},
        ],
      });

      debugPrint('📱 푸시 알림 전송됨: $title');
    } catch (e) {
      debugPrint('❌ 푸시 알림 전송 실패: $e');
    }
  }

  /// 캐시 정리
  Future<void> clearCache() async {
    if (!_isServiceWorkerRegistered) return;

    try {
      await html.window.navigator.serviceWorker!.ready;
      const cacheNames = [
        'everydiary-static-v1.0.0',
        'everydiary-dynamic-v1.0.0',
      ];

      for (final cacheName in cacheNames) {
        await html.window.caches?.delete(cacheName);
      }

      debugPrint('🗑️ 캐시 정리 완료');
    } catch (e) {
      debugPrint('❌ 캐시 정리 실패: $e');
    }
  }

  /// Service Worker 버전 확인
  Future<String?> getServiceWorkerVersion() async {
    if (!_isServiceWorkerRegistered) return null;

    try {
      final controller = html.window.navigator.serviceWorker!.controller;
      if (controller != null) {
        // Service Worker에 버전 요청
        final messageChannel = html.MessageChannel();
        controller.postMessage({'type': 'GET_VERSION'}, [messageChannel.port2]);

        // 응답 대기 (실제 구현에서는 Promise 기반으로 처리)
        return '1.0.0'; // 임시 버전
      }
      return null;
    } catch (e) {
      debugPrint('❌ Service Worker 버전 확인 실패: $e');
      return null;
    }
  }

  /// PWA 설치 가능 여부 확인
  bool get canInstall {
    // JavaScript 함수를 통해 설치 가능 상태 확인
    try {
      final result = js.context.callMethod('checkPWAInstallable');
      return result == true;
    } catch (e) {
      debugPrint('❌ PWA 설치 가능 상태 확인 실패: $e');
      return false;
    }
  }

  /// PWA 설치
  Future<void> installPWA() async {
    if (!canInstall) return;

    try {
      // JavaScript 함수를 통해 PWA 설치 실행
      js.context.callMethod('installPWA');
      debugPrint('📱 PWA 설치 프롬프트 실행됨');
    } catch (e) {
      debugPrint('❌ PWA 설치 실패: $e');
    }
  }

  /// 디버그 정보 출력
  void printDebugInfo() {
    debugPrint('🔧 PWA Service 디버그 정보:');
    debugPrint('  - Service Worker 지원: $_isServiceWorkerSupported');
    debugPrint('  - Service Worker 등록: $_isServiceWorkerRegistered');
    debugPrint('  - 온라인 상태: $_isOnline');
    debugPrint('  - PWA 설치 가능: $canInstall');
  }
}
