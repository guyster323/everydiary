import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;

import '../constants/subscription_constants.dart';
import '../models/subscription_model.dart';
import '../services/local_storage_service.dart';

/// 구독 만료 알림 서비스
///
/// 구독 만료 전에 사용자에게 알림을 보내는 서비스입니다.
class SubscriptionExpiryService {
  static final SubscriptionExpiryService _instance =
      SubscriptionExpiryService._internal();
  factory SubscriptionExpiryService() => _instance;
  SubscriptionExpiryService._internal();

  // 전역 네비게이션 키
  static final GlobalKey<NavigatorState> _navigationKey =
      GlobalKey<NavigatorState>();

  final LocalStorageService _storageService = LocalStorageService();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Timer? _expiryCheckTimer;
  static const int _expiryCheckIntervalMinutes = 60; // 1시간마다 확인

  /// 서비스 초기화
  Future<void> initialize() async {
    try {
      // 알림 플러그인 초기화
      await _initializeNotifications();

      // 만료 확인 타이머 시작
      _startExpiryCheckTimer();

      debugPrint('Subscription expiry service initialized');
    } catch (e) {
      debugPrint('Error initializing subscription expiry service: $e');
    }
  }

  /// 알림 플러그인 초기화
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // 구독 화면으로 이동하는 로직 구현
    try {
      final context = _navigationKey.currentContext;
      if (context != null) {
        context.go('/settings/subscription');
      }
    } catch (e) {
      debugPrint('Navigation failed: $e');
    }
  }

  /// 만료 확인 타이머 시작
  void _startExpiryCheckTimer() {
    _expiryCheckTimer?.cancel();
    _expiryCheckTimer = Timer.periodic(
      const Duration(minutes: _expiryCheckIntervalMinutes),
      (_) => _checkSubscriptionExpiry(),
    );
  }

  /// 구독 만료 확인
  Future<void> _checkSubscriptionExpiry() async {
    try {
      final subscription = await _storageService.loadSubscriptionInfo();
      if (subscription == null || !subscription.isActive) {
        return;
      }

      // 평생 이용권은 만료 확인 불필요
      if (subscription.planType == SubscriptionConstants.lifetimeType) {
        return;
      }

      final now = DateTime.now();
      final expiryDate = subscription.expiresAt;
      if (expiryDate == null) {
        return;
      }

      final daysUntilExpiry = expiryDate.difference(now).inDays;

      // 만료일이 지났으면 만료 알림
      if (daysUntilExpiry < 0) {
        await _showExpiredNotification(subscription);
        return;
      }

      // 만료 3일 전 알림
      if (daysUntilExpiry == 3) {
        await _showExpiryWarningNotification(subscription, 3);
      }
      // 만료 1일 전 알림
      else if (daysUntilExpiry == 1) {
        await _showExpiryWarningNotification(subscription, 1);
      }
      // 만료 당일 알림
      else if (daysUntilExpiry == 0) {
        await _showExpiryWarningNotification(subscription, 0);
      }
    } catch (e) {
      debugPrint('Error checking subscription expiry: $e');
    }
  }

  /// 만료 알림 표시
  Future<void> _showExpiredNotification(SubscriptionModel subscription) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'subscription_expired',
          '구독 만료',
          channelDescription: '구독이 만료되었을 때 알림',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      1, // subscription_expired
      '구독이 만료되었습니다',
      '프리미엄 기능을 계속 사용하려면 구독을 갱신해주세요.',
      notificationDetails,
      payload: 'subscription_expired',
    );

    debugPrint('Subscription expired notification shown');
  }

  /// 만료 경고 알림 표시
  Future<void> _showExpiryWarningNotification(
    SubscriptionModel subscription,
    int daysLeft,
  ) async {
    String title;
    String body;

    if (daysLeft == 0) {
      title = '구독이 오늘 만료됩니다';
      body = '프리미엄 기능을 계속 사용하려면 지금 갱신해주세요.';
    } else {
      title = '구독이 $daysLeft일 후 만료됩니다';
      body = '연속성을 위해 미리 갱신하는 것을 권장합니다.';
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'subscription_expiry_warning',
          '구독 만료 경고',
          channelDescription: '구독 만료 전 경고 알림',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      2 + daysLeft, // subscription_expiry_warning_$daysLeft
      title,
      body,
      notificationDetails,
      payload: 'subscription_expiry_warning',
    );

    debugPrint(
      'Subscription expiry warning notification shown: $daysLeft days left',
    );
  }

  /// 수동으로 만료 확인 실행
  Future<void> checkExpiryNow() async {
    await _checkSubscriptionExpiry();
  }

  /// 특정 구독에 대한 만료 알림 스케줄링
  Future<void> scheduleExpiryNotifications(
    SubscriptionModel subscription,
  ) async {
    try {
      if (subscription.planType == SubscriptionConstants.lifetimeType) {
        return; // 평생 이용권은 알림 불필요
      }

      final expiryDate = subscription.expiresAt;
      if (expiryDate == null) {
        return;
      }

      final now = DateTime.now();
      final daysUntilExpiry = expiryDate.difference(now).inDays;

      // 이미 만료된 경우
      if (daysUntilExpiry < 0) {
        await _showExpiredNotification(subscription);
        return;
      }

      // 3일 전 알림 스케줄링
      if (daysUntilExpiry >= 3) {
        final threeDaysBefore = expiryDate.subtract(const Duration(days: 3));
        if (threeDaysBefore.isAfter(now)) {
          await _scheduleNotification(
            'subscription_expiry_warning_3',
            '구독이 3일 후 만료됩니다',
            '연속성을 위해 미리 갱신하는 것을 권장합니다.',
            threeDaysBefore,
          );
        }
      }

      // 1일 전 알림 스케줄링
      if (daysUntilExpiry >= 1) {
        final oneDayBefore = expiryDate.subtract(const Duration(days: 1));
        if (oneDayBefore.isAfter(now)) {
          await _scheduleNotification(
            'subscription_expiry_warning_1',
            '구독이 1일 후 만료됩니다',
            '프리미엄 기능을 계속 사용하려면 갱신해주세요.',
            oneDayBefore,
          );
        }
      }

      // 만료 당일 알림 스케줄링
      if (daysUntilExpiry >= 0) {
        final expiryDay = DateTime(
          expiryDate.year,
          expiryDate.month,
          expiryDate.day,
          9,
          0,
        );
        if (expiryDay.isAfter(now)) {
          await _scheduleNotification(
            'subscription_expiry_warning_0',
            '구독이 오늘 만료됩니다',
            '프리미엄 기능을 계속 사용하려면 지금 갱신해주세요.',
            expiryDay,
          );
        }
      }

      debugPrint(
        'Expiry notifications scheduled for subscription: ${subscription.productId}',
      );
    } catch (e) {
      debugPrint('Error scheduling expiry notifications: $e');
    }
  }

  /// 알림 스케줄링
  Future<void> _scheduleNotification(
    String id,
    String title,
    String body,
    DateTime scheduledDate,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'subscription_expiry_warning',
          '구독 만료 경고',
          channelDescription: '구독 만료 전 경고 알림',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      id.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'subscription_expiry_warning',
    );
  }

  /// 모든 만료 알림 취소
  Future<void> cancelAllExpiryNotifications() async {
    await _notifications.cancelAll();
    debugPrint('All expiry notifications cancelled');
  }

  /// 서비스 정리
  void dispose() {
    _expiryCheckTimer?.cancel();
    debugPrint('Subscription expiry service disposed');
  }
}
