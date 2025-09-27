import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/offline_state_manager.dart';

final offlineStateManagerProvider = AutoDisposeProvider<OfflineStateManager>((
  ref,
) {
  final manager = OfflineStateManager();
  ref.onDispose(manager.dispose);
  return manager;
});

class OfflineStateNotifier extends AutoDisposeNotifier<OfflineState> {
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

final offlineStateNotifierProvider =
    AutoDisposeNotifierProvider<OfflineStateNotifier, OfflineState>(
      OfflineStateNotifier.new,
    );

final offlineStateProvider = AutoDisposeProvider<OfflineState>((ref) {
  return ref.watch(offlineStateNotifierProvider);
});

final isOnlineProvider = AutoDisposeProvider<bool>((ref) {
  final offlineState = ref.watch(offlineStateProvider);
  return offlineState.isOnline;
});

final isOfflineModeProvider = AutoDisposeProvider<bool>((ref) {
  final offlineState = ref.watch(offlineStateProvider);
  return offlineState.isOfflineMode;
});

final isOfflineModeForcedProvider = AutoDisposeProvider<bool>((ref) {
  final offlineState = ref.watch(offlineStateProvider);
  return offlineState.isOfflineModeForced;
});

final connectionTypeProvider = AutoDisposeProvider<String>((ref) {
  final offlineState = ref.watch(offlineStateProvider);
  return offlineState.connectionType;
});

final offlineDurationProvider = AutoDisposeProvider<Duration?>((ref) {
  final offlineState = ref.watch(offlineStateProvider);
  return offlineState.offlineDuration;
});

final onlineDurationProvider = AutoDisposeProvider<Duration?>((ref) {
  final offlineState = ref.watch(offlineStateProvider);
  return offlineState.onlineDuration;
});

final offlineStateInfoProvider = AutoDisposeProvider<Map<String, dynamic>>((
  ref,
) {
  final notifier = ref.read(offlineStateNotifierProvider.notifier);
  return notifier.getOfflineStateInfo();
});
