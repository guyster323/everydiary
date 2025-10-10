import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_profile_service.dart';

/// 앱 프로필 상태
class AppProfileState {
  const AppProfileState({
    this.isInitialized = false,
    this.onboardingComplete = false,
    this.userName,
    this.pinEnabled = false,
    this.autoLockMinutes = 1,
  });

  final bool isInitialized;
  final bool onboardingComplete;
  final String? userName;
  final bool pinEnabled;
  final int autoLockMinutes;

  AppProfileState copyWith({
    bool? isInitialized,
    bool? onboardingComplete,
    String? userName,
    bool? pinEnabled,
    int? autoLockMinutes,
  }) {
    return AppProfileState(
      isInitialized: isInitialized ?? this.isInitialized,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      userName: userName ?? this.userName,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
    );
  }
}

final appProfileProvider =
    StateNotifierProvider<AppProfileNotifier, AppProfileState>((ref) {
      final service = AppProfileService();
      return AppProfileNotifier(service)..initialize();
    });

/// 앱 프로필 상태 관리자
class AppProfileNotifier extends StateNotifier<AppProfileState> {
  AppProfileNotifier(this._service) : super(const AppProfileState());

  final AppProfileService _service;
  bool _loading = false;

  Future<void> initialize() async {
    if (_loading || state.isInitialized) return;
    _loading = true;
    final onboardingComplete = await _service.isOnboardingComplete();
    final userName = await _service.loadUserName();
    final pinEnabled = await _service.isPinEnabled();
    final autoLockMinutes = await _service.getAutoLockMinutes();

    state = state.copyWith(
      isInitialized: true,
      onboardingComplete: onboardingComplete,
      userName: userName,
      pinEnabled: pinEnabled,
      autoLockMinutes: autoLockMinutes,
    );
    _loading = false;
  }

  Future<void> refresh() async {
    state = state.copyWith(isInitialized: false);
    await initialize();
  }

  Future<void> completeOnboarding({
    required String userName,
    required bool pinEnabled,
    int autoLockMinutes = 1,
  }) async {
    await _service.completeOnboarding(
      userName: userName,
      pinEnabled: pinEnabled,
      autoLockMinutes: autoLockMinutes,
    );
    state = state.copyWith(
      onboardingComplete: true,
      userName: userName,
      pinEnabled: pinEnabled,
      autoLockMinutes: autoLockMinutes,
      isInitialized: true,
    );
  }

  Future<void> updateUserName(String userName) async {
    await _service.updateUserName(userName);
    state = state.copyWith(userName: userName);
  }

  Future<void> setPinEnabled(bool enabled) async {
    await _service.setPinEnabled(enabled);
    state = state.copyWith(pinEnabled: enabled);
  }

  Future<void> setAutoLockMinutes(int minutes) async {
    await _service.setAutoLockMinutes(minutes);
    state = state.copyWith(autoLockMinutes: minutes);
  }
}

