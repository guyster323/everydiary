import 'package:flutter/foundation.dart';

/// Android 전용 PWA 서비스 (실제 네이티브 설치 유도 로그용)
class PWAService {
  static final PWAService _instance = PWAService._internal();
  factory PWAService() => _instance;
  PWAService._internal();

  bool get canInstall => true;

  Future<void> initialize() async {
    debugPrint('🔧 Android PWA Service 초기화 완료');
  }

  Future<bool> isAppInstalled() async {
    // Android 네이티브 설치 여부 체크는 별도로 처리하지 않음
    return false;
  }

  Future<String?> getServiceWorkerVersion() async => null;

  Future<void> installPWA() async {
    debugPrint('📱 Android: 네이티브 설치 안내 표시');
  }

  Future<void> clearCache() async {}

  Future<void> addToOfflineQueue(Map<String, dynamic> data) async {}

  Future<bool> requestNotificationPermission() async => true;

  Future<void> sendNotification(
    String title,
    String body, {
    Map<String, dynamic>? data,
  }) async {}

  void printDebugInfo() {}
}
