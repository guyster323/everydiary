import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/pwa_service.dart';

final pwaServiceProvider = Provider<PWAService>((ref) {
  return PWAService();
});

class PWAState {
  const PWAState({this.canInstall = false, this.isInitialized = false});

  final bool canInstall;
  final bool isInitialized;

  PWAState copyWith({bool? canInstall, bool? isInitialized}) {
    return PWAState(
      canInstall: canInstall ?? this.canInstall,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class PWANotifier extends StateNotifier<PWAState> {
  PWANotifier(this._pwaService) : super(const PWAState());

  final PWAService _pwaService;

  Future<void> initialize() async {
    if (state.isInitialized) return;

    try {
      await _pwaService.initialize();
      state = state.copyWith(
        canInstall: _pwaService.canInstall,
        isInitialized: true,
      );
      debugPrint(
        '🔧 PWA Provider 초기화 완료 - canInstall: ${_pwaService.canInstall}',
      );
    } catch (e) {
      debugPrint('❌ PWA Provider 초기화 실패: $e');
    }
  }

  Future<void> installPWA() async {
    if (!state.canInstall) return;
    await _pwaService.installPWA();
  }

  void printDebugInfo() {
    _pwaService.printDebugInfo();
  }
}

final pwaProvider = StateNotifierProvider<PWANotifier, PWAState>((ref) {
  final pwaService = ref.watch(pwaServiceProvider);
  return PWANotifier(pwaService);
});

final pwaInitializationProvider = FutureProvider<void>((ref) async {
  final notifier = ref.read(pwaProvider.notifier);
  await notifier.initialize();
});

final pwaInstallableProvider = Provider<bool>((ref) {
  final state = ref.watch(pwaProvider);
  return state.canInstall;
});
