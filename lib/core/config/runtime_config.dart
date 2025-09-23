import 'dart:async';

import 'package:flutter/foundation.dart';

import 'config_manager.dart';

/// 런타임 구성 변경 이벤트
class ConfigChangeEvent {
  const ConfigChangeEvent({
    required this.key,
    required this.oldValue,
    required this.newValue,
    required this.timestamp,
  });

  final String key;
  final dynamic oldValue;
  final dynamic newValue;
  final DateTime timestamp;

  @override
  String toString() {
    return 'ConfigChangeEvent(key: $key, oldValue: $oldValue, newValue: $newValue, timestamp: $timestamp)';
  }
}

/// 런타임 구성 변경 스트림
class RuntimeConfigStream {
  static RuntimeConfigStream? _instance;
  static RuntimeConfigStream get instance =>
      _instance ??= RuntimeConfigStream._();

  RuntimeConfigStream._();

  final StreamController<ConfigChangeEvent> _controller =
      StreamController<ConfigChangeEvent>.broadcast();

  /// 구성 변경 스트림
  Stream<ConfigChangeEvent> get stream => _controller.stream;

  /// 구성 변경 이벤트 발생
  void emit(ConfigChangeEvent event) {
    _controller.add(event);
  }

  /// 스트림 닫기
  void dispose() {
    _controller.close();
  }
}

/// 런타임 구성 관리자
class RuntimeConfigManager {
  static RuntimeConfigManager? _instance;
  static RuntimeConfigManager get instance =>
      _instance ??= RuntimeConfigManager._();

  RuntimeConfigManager._();

  final ConfigManager _configManager = ConfigManager.instance;
  final RuntimeConfigStream _stream = RuntimeConfigStream.instance;
  final Map<String, List<VoidCallback>> _listeners = {};

  /// 구성 변경 리스너 등록
  void addListener(String key, VoidCallback listener) {
    _listeners.putIfAbsent(key, () => []).add(listener);
  }

  /// 구성 변경 리스너 제거
  void removeListener(String key, VoidCallback listener) {
    _listeners[key]?.remove(listener);
    if (_listeners[key]?.isEmpty == true) {
      _listeners.remove(key);
    }
  }

  /// 모든 리스너 제거
  void clearListeners() {
    _listeners.clear();
  }

  /// 구성 변경 이벤트 발생
  void _emitChange(String key, dynamic oldValue, dynamic newValue) {
    final event = ConfigChangeEvent(
      key: key,
      oldValue: oldValue,
      newValue: newValue,
      timestamp: DateTime.now(),
    );

    // 스트림에 이벤트 발생
    _stream.emit(event);

    // 해당 키의 리스너들 호출
    _listeners[key]?.forEach((listener) {
      try {
        listener();
      } catch (e) {
        if (kDebugMode) {
          print('Error in config change listener for key $key: $e');
        }
      }
    });
  }

  /// API 기본 URL 변경
  Future<void> changeApiBaseUrl(String newUrl) async {
    final oldUrl = _configManager.apiBaseUrl;
    await _configManager.setApiBaseUrl(newUrl);
    _emitChange('api_base_url', oldUrl, newUrl);
  }

  /// 로깅 활성화 변경
  Future<void> changeLoggingEnabled(bool enabled) async {
    final oldValue = _configManager.enableLogging;
    await _configManager.setEnableLogging(enabled);
    _emitChange('enable_logging', oldValue, enabled);
  }

  /// 분석 활성화 변경
  Future<void> changeAnalyticsEnabled(bool enabled) async {
    final oldValue = _configManager.enableAnalytics;
    await _configManager.setEnableAnalytics(enabled);
    _emitChange('enable_analytics', oldValue, enabled);
  }

  /// 최대 일기 항목 수 변경
  Future<void> changeMaxDiaryEntries(int maxEntries) async {
    final oldValue = _configManager.maxDiaryEntries;
    await _configManager.setMaxDiaryEntries(maxEntries);
    _emitChange('max_diary_entries', oldValue, maxEntries);
  }

  /// 최대 이미지 크기 변경
  Future<void> changeMaxImageSize(int maxSize) async {
    final oldValue = _configManager.maxImageSize;
    await _configManager.setMaxImageSize(maxSize);
    _emitChange('max_image_size', oldValue, maxSize);
  }

  /// 기능 플래그 변경
  Future<void> changeFeatureFlag(String featureName, bool enabled) async {
    final oldValue = _configManager.isFeatureEnabled(featureName);
    await _configManager.setFeatureFlag(featureName, enabled);
    _emitChange('feature_$featureName', oldValue, enabled);
  }

  /// 환경 변수 변경
  Future<void> changeEnvironmentVariable(String key, String value) async {
    final oldValue = _configManager.getEnvironmentValue(key);
    await _configManager.setEnvironmentVariable(key, value);
    _emitChange('env_$key', oldValue, value);
  }

  /// 런타임 구성 값 변경
  Future<void> changeRuntimeValue<T>(String key, T value) async {
    final oldValue = _configManager.getRuntimeValue<T>(key);
    await _configManager.setRuntimeValue(key, value);
    _emitChange(key, oldValue, value);
  }

  /// 런타임 구성 값 제거
  Future<void> removeRuntimeValue(String key) async {
    final oldValue = _configManager.getRuntimeValue<dynamic>(key);
    await _configManager.removeRuntimeValue(key);
    _emitChange(key, oldValue, null);
  }

  /// 구성 변경 스트림 가져오기
  Stream<ConfigChangeEvent> get changeStream => _stream.stream;

  /// 특정 키의 구성 변경 스트림 가져오기
  Stream<ConfigChangeEvent> getChangesForKey(String key) {
    return _stream.stream.where((event) => event.key == key);
  }

  /// 구성 변경 이벤트 필터링
  Stream<ConfigChangeEvent> getChangesByType<T>() {
    return _stream.stream.where((event) => event.newValue is T);
  }

  /// 최근 구성 변경 이벤트들 가져오기
  List<ConfigChangeEvent> getRecentChanges({int limit = 10}) {
    final events = <ConfigChangeEvent>[];
    _stream.stream.take(limit).listen((event) {
      events.add(event);
    });
    return events;
  }

  /// 구성 변경 통계
  Map<String, int> getChangeStatistics() {
    final stats = <String, int>{};
    _stream.stream.listen((event) {
      stats[event.key] = (stats[event.key] ?? 0) + 1;
    });
    return stats;
  }

  /// 구성 변경 롤백 (이전 값으로 복원)
  Future<void> rollbackChange(String key) async {
    final recentChanges = getRecentChanges(limit: 50);
    final lastChange = recentChanges
        .where((event) => event.key == key)
        .lastOrNull;

    if (lastChange != null) {
      await changeRuntimeValue(key, lastChange.oldValue);
    }
  }

  /// 모든 런타임 구성 초기화
  Future<void> resetAllRuntimeConfig() async {
    final allConfig = _configManager.allRuntimeConfig;

    for (final key in allConfig.keys) {
      await removeRuntimeValue(key);
    }
  }

  /// 구성 변경 이벤트 내보내기 (디버깅용)
  Map<String, dynamic> exportChangeHistory() {
    return {
      'recent_changes': getRecentChanges(limit: 20),
      'change_statistics': getChangeStatistics(),
      'active_listeners': _listeners.keys.toList(),
      'total_listeners': _listeners.values.fold(
        0,
        (sum, list) => sum + list.length,
      ),
    };
  }
}
