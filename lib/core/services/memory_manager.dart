import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 메모리 관리 서비스
class MemoryManager {
  static MemoryManager? _instance;
  static MemoryManager get instance => _instance ??= MemoryManager._();

  MemoryManager._();

  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, Duration> _cacheDurations = {};

  Timer? _cleanupTimer;
  final int _maxCacheSize = 100;
  final Duration _defaultCacheDuration = const Duration(minutes: 30);

  /// 초기화
  void initialize() {
    _startPeriodicCleanup();
  }

  /// 캐시에 데이터 저장
  void cacheData<T>(String key, T data, {Duration? duration}) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
    _cacheDurations[key] = duration ?? _defaultCacheDuration;

    // 캐시 크기 제한
    if (_cache.length > _maxCacheSize) {
      _evictOldestCache();
    }
  }

  /// 캐시에서 데이터 가져오기
  T? getCachedData<T>(String key) {
    if (!_cache.containsKey(key)) {
      return null;
    }

    final timestamp = _cacheTimestamps[key];
    final duration = _cacheDurations[key];

    if (timestamp == null || duration == null) {
      return null;
    }

    // 만료된 캐시 제거
    if (DateTime.now().difference(timestamp) > duration) {
      _removeCache(key);
      return null;
    }

    return _cache[key] as T?;
  }

  /// 캐시 제거
  void removeCache(String key) {
    _removeCache(key);
  }

  /// 특정 패턴의 캐시 제거
  void removeCacheByPattern(String pattern) {
    final keysToRemove = _cache.keys
        .where((key) => key.contains(pattern))
        .toList();

    for (final key in keysToRemove) {
      _removeCache(key);
    }
  }

  /// 모든 캐시 제거
  void clearAllCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    _cacheDurations.clear();
  }

  /// 캐시 제거 (내부 메서드)
  void _removeCache(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
    _cacheDurations.remove(key);
  }

  /// 가장 오래된 캐시 제거
  void _evictOldestCache() {
    if (_cacheTimestamps.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cacheTimestamps.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestTime = entry.value;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _removeCache(oldestKey);
    }
  }

  /// 주기적 캐시 정리 시작
  void _startPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _cleanupExpiredCache(),
    );
  }

  /// 만료된 캐시 정리
  void _cleanupExpiredCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      final key = entry.key;
      final timestamp = entry.value;
      final duration = _cacheDurations[key];

      if (duration != null && now.difference(timestamp) > duration) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      _removeCache(key);
    }

    if (kDebugMode && keysToRemove.isNotEmpty) {
      developer.log('Cleaned up ${keysToRemove.length} expired cache entries');
    }
  }

  /// 메모리 사용량 로깅
  void logMemoryUsage(String context) {
    if (kDebugMode) {
      developer.log('Memory usage at $context:');
      developer.log('  Cache size: ${_cache.length}');
      developer.log(
        '  Cache keys: ${_cache.keys.take(5).join(', ')}${_cache.length > 5 ? '...' : ''}',
      );
    }
  }

  /// 메모리 압박 상황 처리
  void handleMemoryPressure() {
    if (kDebugMode) {
      developer.log('Memory pressure detected, clearing cache');
    }

    // 캐시 크기를 절반으로 줄임
    final targetSize = _cache.length ~/ 2;
    while (_cache.length > targetSize) {
      _evictOldestCache();
    }
  }

  /// 리소스 정리
  void dispose() {
    _cleanupTimer?.cancel();
    clearAllCache();
  }
}

/// 메모리 효율적인 스트림 관리자
class StreamManager {
  static final Map<String, StreamSubscription<dynamic>> _subscriptions = {};

  /// 스트림 구독 등록
  static void registerSubscription(
    String key,
    StreamSubscription<dynamic> subscription,
  ) {
    _subscriptions[key]?.cancel();
    _subscriptions[key] = subscription;
  }

  /// 스트림 구독 취소
  static void cancelSubscription(String key) {
    _subscriptions[key]?.cancel();
    _subscriptions.remove(key);
  }

  /// 모든 스트림 구독 취소
  static void cancelAllSubscriptions() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}

/// 메모리 효율적인 이미지 캐시 관리자
class ImageCacheManager {
  static const int _maxImageCacheSize = 50;
  static final Map<String, DateTime> _imageAccessTimes = {};

  /// 이미지 캐시 크기 제한
  static void limitImageCacheSize() {
    final imageCache = PaintingBinding.instance.imageCache;

    if (imageCache.currentSize > _maxImageCacheSize) {
      // 가장 오래된 이미지부터 제거
      final keysToRemove = <Object>[];
      final currentTime = DateTime.now();

      for (final entry in _imageAccessTimes.entries) {
        if (currentTime.difference(entry.value) > const Duration(minutes: 10)) {
          keysToRemove.add(entry.key);
        }
      }

      for (final key in keysToRemove) {
        imageCache.evict(key);
        _imageAccessTimes.remove(key);
      }
    }
  }

  /// 이미지 접근 시간 기록
  static void recordImageAccess(String imageUrl) {
    _imageAccessTimes[imageUrl] = DateTime.now();
  }

  /// 이미지 캐시 정리
  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    _imageAccessTimes.clear();
  }
}

/// 메모리 모니터링 위젯
class MemoryMonitor extends StatefulWidget {
  final Widget child;
  final Duration checkInterval;
  final VoidCallback? onMemoryPressure;

  const MemoryMonitor({
    super.key,
    required this.child,
    this.checkInterval = const Duration(seconds: 30),
    this.onMemoryPressure,
  });

  @override
  State<MemoryMonitor> createState() => _MemoryMonitorState();
}

class _MemoryMonitorState extends State<MemoryMonitor> {
  Timer? _monitorTimer;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  @override
  void dispose() {
    _monitorTimer?.cancel();
    super.dispose();
  }

  void _startMonitoring() {
    _monitorTimer = Timer.periodic(widget.checkInterval, (_) {
      _checkMemoryUsage();
    });
  }

  void _checkMemoryUsage() {
    // 간단한 메모리 사용량 체크
    final imageCache = PaintingBinding.instance.imageCache;

    if (imageCache.currentSize > 100) {
      widget.onMemoryPressure?.call();
      MemoryManager.instance.handleMemoryPressure();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
