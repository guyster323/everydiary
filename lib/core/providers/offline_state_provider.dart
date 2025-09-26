import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/offline_state_manager.dart';

part 'offline_state_provider.g.dart';

/// 오프라인 상태 프로바이더
@riverpod
OfflineStateManager offlineStateManager(OfflineStateManagerRef ref) {
  return OfflineStateManager();
}

/// 오프라인 상태 관리자
@riverpod
class OfflineStateNotifier extends _$OfflineStateNotifier {
  @override
  OfflineState build() {
    _initialize();
    return const OfflineState(
      isOnline: true,
      isOfflineMode: false,
      isOfflineModeForced: false,
      networkInfo: {},
    );
  }

  /// 초기화
  Future<void> _initialize() async {
    try {
      debugPrint('🔄 오프라인 상태 관리자 초기화 시작');

      final manager = ref.read(offlineStateManagerProvider);
      await manager.initialize();

      // 상태 스트림 구독
      manager.stateStream.listen(
        (OfflineState newState) {
          state = newState;
        },
        onError: (Object error) {
          debugPrint('❌ 오프라인 상태 스트림 오류: $error');
        },
      );

      // 초기 상태 설정
      state = manager.currentState;

      debugPrint('✅ 오프라인 상태 관리자 초기화 완료');
    } catch (e) {
      debugPrint('❌ 오프라인 상태 관리자 초기화 실패: $e');
    }
  }

  /// 오프라인 모드 강제 설정
  void setOfflineModeForced(bool forced) {
    try {
      final manager = ref.read(offlineStateManagerProvider);
      manager.setOfflineModeForced(forced);
    } catch (e) {
      debugPrint('❌ 오프라인 모드 강제 설정 실패: $e');
    }
  }

  /// 네트워크 상태 수동 확인
  Future<bool> checkNetworkStatus() async {
    try {
      final manager = ref.read(offlineStateManagerProvider);
      return await manager.checkNetworkStatus();
    } catch (e) {
      debugPrint('❌ 네트워크 상태 수동 확인 실패: $e');
      return false;
    }
  }

  /// 오프라인 상태 정보 가져오기
  Map<String, dynamic> getOfflineStateInfo() {
    try {
      final manager = ref.read(offlineStateManagerProvider);
      return manager.getOfflineStateInfo();
    } catch (e) {
      debugPrint('❌ 오프라인 상태 정보 가져오기 실패: $e');
      return {};
    }
  }
}

/// 오프라인 상태 프로바이더
@riverpod
OfflineState offlineState(OfflineStateRef ref) {
  return ref.watch(offlineStateNotifierProvider);
}

/// 온라인 상태 프로바이더
@riverpod
bool isOnline(IsOnlineRef ref) {
  final offlineState = ref.watch(offlineStateProvider);
  return offlineState.isOnline;
}

/// 오프라인 모드 상태 프로바이더
@riverpod
bool isOfflineMode(IsOfflineModeRef ref) {
  final offlineState = ref.watch(offlineStateProvider);
  return offlineState.isOfflineMode;
}

/// 오프라인 모드 강제 설정 상태 프로바이더
@riverpod
bool isOfflineModeForced(IsOfflineModeForcedRef ref) {
  final offlineState = ref.watch(offlineStateProvider);
  return offlineState.isOfflineModeForced;
}

/// 네트워크 연결 타입 프로바이더
@riverpod
String connectionType(ConnectionTypeRef ref) {
  final offlineState = ref.watch(offlineStateProvider);
  return offlineState.connectionType;
}

/// 오프라인 지속 시간 프로바이더
@riverpod
Duration? offlineDuration(OfflineDurationRef ref) {
  final offlineState = ref.watch(offlineStateProvider);
  return offlineState.offlineDuration;
}

/// 온라인 지속 시간 프로바이더
@riverpod
Duration? onlineDuration(OnlineDurationRef ref) {
  final offlineState = ref.watch(offlineStateProvider);
  return offlineState.onlineDuration;
}

/// 오프라인 상태 정보 프로바이더
@riverpod
Map<String, dynamic> offlineStateInfo(OfflineStateInfoRef ref) {
  final notifier = ref.read(offlineStateNotifierProvider.notifier);
  return notifier.getOfflineStateInfo();
}
