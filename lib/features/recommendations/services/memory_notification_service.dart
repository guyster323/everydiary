import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/diary_memory.dart';
import '../models/memory_filter.dart';
import 'memory_service.dart';

/// 회상 알림 서비스
class MemoryNotificationService {
  static final MemoryNotificationService _instance =
      MemoryNotificationService._internal();
  factory MemoryNotificationService() => _instance;
  MemoryNotificationService._internal();

  // 전역 네비게이션 키
  static final GlobalKey<NavigatorState> _navigationKey =
      GlobalKey<NavigatorState>();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final MemoryService _memoryService = MemoryService();

  /// 네비게이션 키 설정
  static void setNavigationKey(GlobalKey<NavigatorState> key) {
    // 네비게이션 키는 이미 static으로 정의되어 있으므로 별도 설정 불필요
  }

  bool _isInitialized = false;
  Timer? _dailyCheckTimer;

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 타임존 초기화
      tz.initializeTimeZones();

      // Android 초기화 설정
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS 초기화 설정
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Android 알림 채널 생성
      if (Platform.isAndroid) {
        await _createNotificationChannels();
      }

      _isInitialized = true;
      debugPrint('Memory notification service initialized');
    } catch (e) {
      debugPrint('Failed to initialize notification service: $e');
      rethrow;
    }
  }

  /// 알림 채널 생성 (Android)
  Future<void> _createNotificationChannels() async {
    const memoryChannel = AndroidNotificationChannel(
      'memory_notifications',
      '회상 알림',
      description: '과거 일기 회상을 위한 알림',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(memoryChannel);
  }

  /// 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // 회상 화면으로 이동하는 로직 구현
      debugPrint('Notification tapped with payload: $payload');

      // 전역 네비게이션 키를 통해 회상 화면으로 이동
      try {
        final context = _navigationKey.currentContext;
        if (context != null) {
          context.go('/memories');
        }
      } catch (e) {
        debugPrint('Navigation failed: $e');
      }
    }
  }

  /// 일일 회상 알림 스케줄링
  Future<void> scheduleDailyMemoryNotifications({
    required String userId,
    required List<int> notificationHours,
    MemorySettings? settings,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // 기존 알림 취소
    await cancelAllMemoryNotifications();

    // 각 시간대별로 알림 스케줄링
    for (final hour in notificationHours) {
      await _scheduleNotificationForHour(
        userId: userId,
        hour: hour,
        settings: settings,
      );
    }

    // 일일 체크 타이머 시작
    _startDailyCheckTimer(userId, settings);
  }

  /// 특정 시간대 알림 스케줄링
  Future<void> _scheduleNotificationForHour({
    required String userId,
    required int hour,
    MemorySettings? settings,
  }) async {
    try {
      final now = DateTime.now();
      final scheduledTime = DateTime(now.year, now.month, now.day, hour);

      // 오늘 시간이 지났으면 내일로 설정
      final targetTime = scheduledTime.isBefore(now)
          ? scheduledTime.add(const Duration(days: 1))
          : scheduledTime;

      await _notifications.zonedSchedule(
        hour, // 고유 ID로 시간 사용
        '회상 시간',
        '과거의 오늘을 회상해보세요',
        tz.TZDateTime.from(targetTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'memory_notifications',
            '회상 알림',
            channelDescription: '과거 일기 회상을 위한 알림',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'memory_$userId',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('Scheduled memory notification for hour $hour');
    } catch (e) {
      debugPrint('Failed to schedule notification for hour $hour: $e');
    }
  }

  /// 일일 체크 타이머 시작
  void _startDailyCheckTimer(String userId, MemorySettings? settings) {
    _dailyCheckTimer?.cancel();

    _dailyCheckTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
      await _checkAndSendMemoryNotifications(userId, settings);
    });
  }

  /// 회상 알림 확인 및 전송
  Future<void> _checkAndSendMemoryNotifications(
    String userId,
    MemorySettings? settings,
  ) async {
    try {
      // 회상 데이터 생성
      final memoryResult = await _memoryService.generateMemories(
        userId: userId,
        settings: settings,
      );

      if (memoryResult.memories.isNotEmpty) {
        // 특별한 회상이 있는 경우 즉시 알림 전송
        await _sendImmediateMemoryNotification(memoryResult);
      }
    } catch (e) {
      debugPrint('Failed to check memory notifications: $e');
    }
  }

  /// 즉시 회상 알림 전송
  Future<void> _sendImmediateMemoryNotification(
    MemoryResult memoryResult,
  ) async {
    try {
      final memory = memoryResult.memories.first;
      final title = _getNotificationTitle(memory);
      final body = _getNotificationBody(memory);

      await _notifications.show(
        memory.hashCode,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'memory_notifications',
            '회상 알림',
            channelDescription: '과거 일기 회상을 위한 알림',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'memory_${memory.id}',
      );

      debugPrint('Sent immediate memory notification: $title');
    } catch (e) {
      debugPrint('Failed to send immediate memory notification: $e');
    }
  }

  /// 알림 제목 생성
  String _getNotificationTitle(DiaryMemory memory) {
    switch (memory.reason.type) {
      case MemoryType.yesterday:
        return '어제의 기록을 회상해보세요';
      case MemoryType.oneWeekAgo:
        return '일주일 전의 기록을 회상해보세요';
      case MemoryType.oneMonthAgo:
        return '한달 전의 기록을 회상해보세요';
      case MemoryType.oneYearAgo:
        return '1년 전의 기록을 회상해보세요';
      case MemoryType.pastToday:
        return '과거의 오늘을 회상해보세요';
      case MemoryType.sameTimeOfDay:
        return '이 시간의 과거 기록을 회상해보세요';
      case MemoryType.seasonal:
        return '작년 이맘때를 회상해보세요';
      case MemoryType.specialDate:
        return '특별한 날의 기록을 회상해보세요';
      case MemoryType.similarTags:
        return '관련된 과거 기록을 회상해보세요';
    }
  }

  /// 알림 본문 생성
  String _getNotificationBody(DiaryMemory memory) {
    final content = memory.content.length > 50
        ? '${memory.content.substring(0, 50)}...'
        : memory.content;

    return '${memory.title}\n$content';
  }

  /// 특별한 날짜 회상 알림 스케줄링
  Future<void> scheduleSpecialDateNotification({
    required String userId,
    required DateTime specialDate,
    required String title,
    required String description,
    MemorySettings? settings,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final scheduledTime = tz.TZDateTime.from(specialDate, tz.local);

      await _notifications.zonedSchedule(
        specialDate.hashCode,
        title,
        description,
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'memory_notifications',
            '회상 알림',
            channelDescription: '과거 일기 회상을 위한 알림',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'special_memory_$userId',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Scheduled special date notification for $specialDate');
    } catch (e) {
      debugPrint('Failed to schedule special date notification: $e');
    }
  }

  /// 모든 회상 알림 취소
  Future<void> cancelAllMemoryNotifications() async {
    await _notifications.cancelAll();
    _dailyCheckTimer?.cancel();
    debugPrint('Cancelled all memory notifications');
  }

  /// 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('Cancelled notification with ID: $id');
  }

  /// 예약된 알림 목록 조회
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// 알림 권한 요청
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      // 알림 권한 요청
      final notificationGranted =
          await androidPlugin?.requestNotificationsPermission() ?? false;

      // 정확한 알람 권한 요청 (Android 12+)
      final exactAlarmGranted =
          await androidPlugin?.requestExactAlarmsPermission() ?? false;

      debugPrint('Notification permission: $notificationGranted, Exact alarm permission: $exactAlarmGranted');

      return notificationGranted;
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      final granted =
          await iosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      return granted;
    }

    return false;
  }

  /// 알림 권한 상태 확인
  Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      return await androidPlugin?.areNotificationsEnabled() ?? false;
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      final result = await iosPlugin?.checkPermissions();
      return result?.isEnabled ?? false;
    }

    return false;
  }

  /// 서비스 정리
  void dispose() {
    _dailyCheckTimer?.cancel();
  }
}
