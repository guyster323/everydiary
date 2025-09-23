import 'dart:async';

import 'package:flutter/foundation.dart';

import 'config_manager.dart';
import 'runtime_config.dart';

/// 기능 플래그 타입
enum FeatureFlagType { boolean, string, number, json }

/// 기능 플래그 정의
class FeatureFlag {
  const FeatureFlag({
    required this.name,
    required this.type,
    required this.defaultValue,
    this.description,
    this.environments,
    this.userGroups,
    this.percentage,
    this.startDate,
    this.endDate,
  });

  final String name;
  final FeatureFlagType type;
  final dynamic defaultValue;
  final String? description;
  final List<String>? environments;
  final List<String>? userGroups;
  final double? percentage; // 0.0 to 1.0
  final DateTime? startDate;
  final DateTime? endDate;

  /// 기능 플래그가 활성화되어 있는지 확인
  bool isActive({String? environment, String? userGroup, String? userId}) {
    // 날짜 범위 확인
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;

    // 환경 확인
    if (environments != null && environment != null) {
      if (!environments!.contains(environment)) return false;
    }

    // 사용자 그룹 확인
    if (userGroups != null && userGroup != null) {
      if (!userGroups!.contains(userGroup)) return false;
    }

    // 퍼센티지 확인 (A/B 테스트용)
    if (percentage != null && userId != null) {
      final hash = userId.hashCode.abs();
      final userPercentage = (hash % 100) / 100.0;
      if (userPercentage > percentage!) return false;
    }

    return true;
  }

  @override
  String toString() {
    return 'FeatureFlag(name: $name, type: $type, defaultValue: $defaultValue)';
  }
}

/// 기능 플래그 관리자
class FeatureFlagManager {
  static FeatureFlagManager? _instance;
  static FeatureFlagManager get instance =>
      _instance ??= FeatureFlagManager._();

  FeatureFlagManager._();

  final ConfigManager _configManager = ConfigManager.instance;
  final RuntimeConfigManager _runtimeConfig = RuntimeConfigManager.instance;
  final Map<String, FeatureFlag> _flags = {};
  final StreamController<Map<String, dynamic>> _flagChangeController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// 기능 플래그 변경 스트림
  Stream<Map<String, dynamic>> get flagChangeStream =>
      _flagChangeController.stream;

  /// 기능 플래그 등록
  void registerFlag(FeatureFlag flag) {
    _flags[flag.name] = flag;
  }

  /// 여러 기능 플래그 등록
  void registerFlags(List<FeatureFlag> flags) {
    for (final flag in flags) {
      registerFlag(flag);
    }
  }

  /// 기본 기능 플래그들 등록
  void registerDefaultFlags() {
    final defaultFlags = [
      const FeatureFlag(
        name: 'enableVoiceInput',
        type: FeatureFlagType.boolean,
        defaultValue: true,
        description: '음성 입력 기능 활성화',
        environments: ['development', 'staging', 'production'],
      ),
      const FeatureFlag(
        name: 'enableImageRecognition',
        type: FeatureFlagType.boolean,
        defaultValue: true,
        description: '이미지 인식 기능 활성화',
        environments: ['development', 'staging', 'production'],
      ),
      const FeatureFlag(
        name: 'enableCloudSync',
        type: FeatureFlagType.boolean,
        defaultValue: false,
        description: '클라우드 동기화 기능 활성화',
        environments: ['staging', 'production'],
      ),
      const FeatureFlag(
        name: 'enablePremiumFeatures',
        type: FeatureFlagType.boolean,
        defaultValue: true,
        description: '프리미엄 기능 활성화',
        environments: ['development', 'staging', 'production'],
      ),
      const FeatureFlag(
        name: 'enableBetaFeatures',
        type: FeatureFlagType.boolean,
        defaultValue: false,
        description: '베타 기능 활성화',
        environments: ['development'],
        userGroups: ['beta_testers'],
      ),
      const FeatureFlag(
        name: 'enableDebugMenu',
        type: FeatureFlagType.boolean,
        defaultValue: false,
        description: '디버그 메뉴 활성화',
        environments: ['development'],
      ),
      const FeatureFlag(
        name: 'enablePerformanceMonitoring',
        type: FeatureFlagType.boolean,
        defaultValue: true,
        description: '성능 모니터링 활성화',
        environments: ['development', 'staging', 'production'],
      ),
      const FeatureFlag(
        name: 'maxDiaryEntries',
        type: FeatureFlagType.number,
        defaultValue: 1000,
        description: '최대 일기 항목 수',
        environments: ['development', 'staging', 'production'],
      ),
      const FeatureFlag(
        name: 'apiTimeout',
        type: FeatureFlagType.number,
        defaultValue: 30,
        description: 'API 타임아웃 (초)',
        environments: ['development', 'staging', 'production'],
      ),
    ];

    registerFlags(defaultFlags);
  }

  /// 기능 플래그 값 가져오기
  T getFlagValue<T>(
    String flagName, {
    String? environment,
    String? userGroup,
    String? userId,
    T? fallback,
  }) {
    final flag = _flags[flagName];
    if (flag == null) {
      if (kDebugMode) {
        print('Feature flag not found: $flagName');
      }
      return fallback ?? _getDefaultValue<T>();
    }

    // 플래그가 활성화되어 있는지 확인
    if (!flag.isActive(
      environment: environment,
      userGroup: userGroup,
      userId: userId,
    )) {
      return fallback ?? _getDefaultValue<T>();
    }

    // 런타임 구성에서 값 가져오기
    final runtimeValue = _configManager.getRuntimeValue<T>('feature_$flagName');
    if (runtimeValue != null) {
      return runtimeValue;
    }

    // 기본 구성에서 값 가져오기
    final configValue = _configManager.config.featureFlags[flagName];
    if (configValue != null) {
      return configValue as T;
    }

    // 플래그 기본값 반환
    return flag.defaultValue as T;
  }

  /// 기본값 가져오기
  T _getDefaultValue<T>() {
    if (T == bool) return false as T;
    if (T == String) return '' as T;
    if (T == int) return 0 as T;
    if (T == double) return 0.0 as T;
    return null as T;
  }

  /// 기능 플래그 활성화 여부 확인
  bool isFeatureEnabled(
    String flagName, {
    String? environment,
    String? userGroup,
    String? userId,
  }) {
    return getFlagValue<bool>(
      flagName,
      environment: environment,
      userGroup: userGroup,
      userId: userId,
      fallback: false,
    );
  }

  /// 기능 플래그 값 설정 (런타임)
  Future<void> setFlagValue<T>(String flagName, T value) async {
    await _runtimeConfig.changeRuntimeValue('feature_$flagName', value);

    // 변경 이벤트 발생
    _flagChangeController.add({
      'flagName': flagName,
      'value': value,
      'timestamp': DateTime.now(),
    });
  }

  /// 기능 플래그 활성화/비활성화
  Future<void> setFeatureEnabled(String flagName, bool enabled) async {
    await setFlagValue(flagName, enabled);
  }

  /// 기능 플래그 제거 (런타임에서)
  Future<void> removeFlag(String flagName) async {
    await _runtimeConfig.removeRuntimeValue('feature_$flagName');

    // 변경 이벤트 발생
    _flagChangeController.add({
      'flagName': flagName,
      'value': null,
      'timestamp': DateTime.now(),
    });
  }

  /// 모든 기능 플래그 상태 가져오기
  Map<String, dynamic> getAllFlagStates({
    String? environment,
    String? userGroup,
    String? userId,
  }) {
    final states = <String, dynamic>{};

    for (final flag in _flags.values) {
      if (flag.isActive(
        environment: environment,
        userGroup: userGroup,
        userId: userId,
      )) {
        states[flag.name] = getFlagValue<dynamic>(
          flag.name,
          environment: environment,
          userGroup: userGroup,
          userId: userId,
        );
      } else {
        states[flag.name] = null;
      }
    }

    return states;
  }

  /// 활성화된 기능 플래그 목록 가져오기
  List<String> getEnabledFlags({
    String? environment,
    String? userGroup,
    String? userId,
  }) {
    final enabledFlags = <String>[];

    for (final flag in _flags.values) {
      if (flag.isActive(
        environment: environment,
        userGroup: userGroup,
        userId: userId,
      )) {
        final value = getFlagValue<dynamic>(
          flag.name,
          environment: environment,
          userGroup: userGroup,
          userId: userId,
        );

        if (value is bool && value) {
          enabledFlags.add(flag.name);
        } else if (value is! bool && value != null) {
          enabledFlags.add(flag.name);
        }
      }
    }

    return enabledFlags;
  }

  /// 기능 플래그 통계
  Map<String, dynamic> getFlagStatistics() {
    final stats = <String, dynamic>{
      'total_flags': _flags.length,
      'active_flags': 0,
      'inactive_flags': 0,
      'flag_types': <String, int>{},
    };

    for (final flag in _flags.values) {
      if (flag.isActive()) {
        stats['active_flags'] = (stats['active_flags'] as int) + 1;
      } else {
        stats['inactive_flags'] = (stats['inactive_flags'] as int) + 1;
      }

      final typeName = flag.type.name;
      stats['flag_types'][typeName] =
          (stats['flag_types'][typeName] as int? ?? 0) + 1;
    }

    return stats;
  }

  /// 기능 플래그 내보내기 (디버깅용)
  Map<String, dynamic> exportFlagsForDebug() {
    return {
      'registered_flags': _flags.map(
        (key, flag) => MapEntry(key, {
          'name': flag.name,
          'type': flag.type.name,
          'defaultValue': flag.defaultValue,
          'description': flag.description,
          'environments': flag.environments,
          'userGroups': flag.userGroups,
          'percentage': flag.percentage,
          'startDate': flag.startDate?.toIso8601String(),
          'endDate': flag.endDate?.toIso8601String(),
        }),
      ),
      'current_states': getAllFlagStates(),
      'statistics': getFlagStatistics(),
    };
  }

  /// 기능 플래그 검증
  bool validateFlags() {
    for (final flag in _flags.values) {
      // 필수 필드 확인
      if (flag.name.isEmpty) {
        if (kDebugMode) {
          print('Feature flag has empty name');
        }
        return false;
      }

      // 기본값 타입 확인
      if (flag.type == FeatureFlagType.boolean && flag.defaultValue is! bool) {
        if (kDebugMode) {
          print('Feature flag ${flag.name} has invalid boolean default value');
        }
        return false;
      }

      if (flag.type == FeatureFlagType.string && flag.defaultValue is! String) {
        if (kDebugMode) {
          print('Feature flag ${flag.name} has invalid string default value');
        }
        return false;
      }

      if (flag.type == FeatureFlagType.number && flag.defaultValue is! num) {
        if (kDebugMode) {
          print('Feature flag ${flag.name} has invalid number default value');
        }
        return false;
      }

      // 퍼센티지 범위 확인
      if (flag.percentage != null &&
          (flag.percentage! < 0.0 || flag.percentage! > 1.0)) {
        if (kDebugMode) {
          print('Feature flag ${flag.name} has invalid percentage value');
        }
        return false;
      }

      // 날짜 범위 확인
      if (flag.startDate != null &&
          flag.endDate != null &&
          flag.startDate!.isAfter(flag.endDate!)) {
        if (kDebugMode) {
          print('Feature flag ${flag.name} has invalid date range');
        }
        return false;
      }
    }

    return true;
  }

  /// 리소스 정리
  void dispose() {
    _flagChangeController.close();
  }
}
