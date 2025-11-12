import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

/// Android 네이티브 알림 서비스
/// PWA 푸시 알림을 대체하는 Android 네이티브 알림 구현
class AndroidNotificationService {
  static final AndroidNotificationService _instance =
      AndroidNotificationService._internal();
  factory AndroidNotificationService() => _instance;
  AndroidNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _networkStatusNotificationId = 100;

  bool _isInitialized = false;
  bool _hasPermission = false;

  // 로컬라이즈된 메시지
  String _offlineTitle = '📴 오프라인 모드';
  String _offlineMessage = 'AI이미지 생성이 실패할 수 있습니다.';

  // 이벤트 스트림
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔧 Android Notification Service 초기화 시작...');

      // Android 초기화 설정
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // 알림 권한 요청
      await _requestNotificationPermission();

      _isInitialized = true;
      debugPrint('✅ Android Notification Service 초기화 완료');
    } catch (e) {
      debugPrint('❌ Android Notification Service 초기화 실패: $e');
    }
  }

  /// 알림 권한 요청
  Future<bool> _requestNotificationPermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        _hasPermission = status.isGranted;

        if (!_hasPermission) {
          debugPrint('⚠️ 알림 권한이 거부됨');
        }
      } else {
        _hasPermission = true; // iOS는 다른 방식으로 처리
      }

      return _hasPermission;
    } catch (e) {
      debugPrint('❌ 알림 권한 요청 실패: $e');
      return false;
    }
  }

  /// 알림 권한 확인
  Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      _hasPermission = status.isGranted;
    }
    return _hasPermission;
  }

  /// 로컬라이즈된 메시지 설정
  void setLocalizedMessages({
    required String offlineTitle,
    required String offlineMessage,
  }) {
    _offlineTitle = offlineTitle;
    _offlineMessage = offlineMessage;
    debugPrint('✅ 알림 메시지 로컬라이즈 설정됨: $_offlineTitle');
  }

  /// 알림 전송
  Future<void> sendNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationDetails? details,
  }) async {
    if (!_hasPermission) {
      debugPrint('⚠️ 알림 권한이 없어서 알림을 전송할 수 없습니다');
      return;
    }

    try {
      final notificationDetails = details ?? _getDefaultNotificationDetails();

      await _notifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      debugPrint('📱 알림 전송됨: $title');

      // 이벤트 스트림에 알림 전송 이벤트 추가
      _notificationController.add({
        'type': 'notification_sent',
        'id': id,
        'title': title,
        'body': body,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ 알림 전송 실패: $e');
    }
  }

  /// 기본 알림 설정
  NotificationDetails _getDefaultNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'everydiary_channel',
      'EveryDiary 알림',
      channelDescription: 'EveryDiary 앱의 알림을 표시합니다',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// 일기 작성 알림
  Future<void> sendDiaryReminderNotification() async {
    await sendNotification(
      id: 1,
      title: '📝 일기 작성 시간',
      body: '오늘의 하루를 기록해보세요!',
      payload: 'diary_reminder',
    );
  }

  /// 백그라운드 동기화 완료 알림
  Future<void> sendSyncCompleteNotification() async {
    await sendNotification(
      id: 2,
      title: '🔄 동기화 완료',
      body: '데이터가 성공적으로 동기화되었습니다',
      payload: 'sync_complete',
    );
  }

  /// 오프라인 상태 알림
  Future<void> sendOfflineNotification() async {
    await showNetworkStatusNotification(isOnline: false);
  }

  /// 네트워크 상태 알림 업데이트 (스택 방지)
  Future<void> showNetworkStatusNotification({required bool isOnline}) async {
    if (!_hasPermission) {
      debugPrint('⚠️ 알림 권한이 없어 네트워크 알림을 표시할 수 없습니다');
      return;
    }

    try {
      // 온라인 상태일 때는 알림을 표시하지 않고 기존 알림만 취소
      if (isOnline) {
        await _notifications.cancel(_networkStatusNotificationId);
        debugPrint('🗑️ 네트워크 복구: 오프라인 알림 해제');
        return;
      }

      // 오프라인 상태일 때만 알림 표시
      final notificationDetails = _getDefaultNotificationDetails();
      final title = _offlineTitle;
      final body = _offlineMessage;
      const payload = 'offline_mode';

      await _notifications.show(
        _networkStatusNotificationId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      debugPrint('📶 네트워크 상태 알림 전송됨: $title');
    } catch (e) {
      debugPrint('❌ 네트워크 상태 알림 처리 실패: $e');
    }
  }

  /// 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 알림 탭됨: ${response.payload}');

    // 이벤트 스트림에 알림 탭 이벤트 추가
    _notificationController.add({
      'type': 'notification_tapped',
      'payload': response.payload,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// 예약된 알림 설정
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_hasPermission) {
      debugPrint('⚠️ 알림 권한이 없어서 예약 알림을 설정할 수 없습니다');
      return;
    }

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        _getDefaultNotificationDetails(),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('⏰ 예약 알림 설정됨: $scheduledDate');
    } catch (e) {
      debugPrint('❌ 예약 알림 설정 실패: $e');
    }
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      debugPrint('🗑️ 모든 알림이 취소됨');
    } catch (e) {
      debugPrint('❌ 알림 취소 실패: $e');
    }
  }

  /// 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      debugPrint('🗑️ 알림 취소됨: $id');
    } catch (e) {
      debugPrint('❌ 알림 취소 실패: $e');
    }
  }

  /// 대기 중인 알림 조회
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('❌ 대기 중인 알림 조회 실패: $e');
      return [];
    }
  }

  /// 서비스 정리
  Future<void> dispose() async {
    await _notificationController.close();
  }
}
