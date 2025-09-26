import 'package:flutter/foundation.dart';

/// PWA 서비스 스텁 (웹이 아닌 플랫폼용)
class PWAService {
  static final PWAService _instance = PWAService._internal();
  factory PWAService() => _instance;
  PWAService._internal();

  bool get isServiceWorkerSupported => false;
  bool get isServiceWorkerRegistered => false;
  bool get isOnline => true;
  bool get canInstall => false;

  Future<void> initialize() async {
    debugPrint('🔧 PWA Service: 웹이 아닌 환경에서는 PWA를 지원하지 않습니다.');
  }

  Future<void> addToOfflineQueue(Map<String, dynamic> data) async {
    // 웹이 아닌 환경에서는 아무것도 하지 않음
  }

  Future<bool> requestNotificationPermission() async => false;

  Future<void> sendNotification(
    String title,
    String body, {
    Map<String, dynamic>? data,
  }) async {
    // 웹이 아닌 환경에서는 아무것도 하지 않음
  }

  Future<void> clearCache() async {
    // 웹이 아닌 환경에서는 아무것도 하지 않음
  }

  Future<String?> getServiceWorkerVersion() async => null;

  Future<void> installPWA() async {
    // 웹이 아닌 환경에서는 아무것도 하지 않음
  }

  void printDebugInfo() {
    debugPrint('🔧 PWA Service: 웹이 아닌 환경에서는 PWA를 지원하지 않습니다.');
  }
}
