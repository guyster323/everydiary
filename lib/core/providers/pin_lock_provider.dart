import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_profile_service.dart';
import '../services/pin_lock_service.dart';

class PinLockState {
  const PinLockState({
    this.isInitialized = false,
    this.isPinEnabled = false,
    this.isUnlocked = true,
    this.remainingAttempts = 5,
    this.lockExpiresAt,
  });

  final bool isInitialized;
  final bool isPinEnabled;
  final bool isUnlocked;
  final int remainingAttempts;
  final DateTime? lockExpiresAt;

  PinLockState copyWith({
    bool? isInitialized,
    bool? isPinEnabled,
    bool? isUnlocked,
    int? remainingAttempts,
    DateTime? lockExpiresAt,
  }) {
    return PinLockState(
      isInitialized: isInitialized ?? this.isInitialized,
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      remainingAttempts: remainingAttempts ?? this.remainingAttempts,
      lockExpiresAt: lockExpiresAt ?? this.lockExpiresAt,
    );
  }
}

final pinLockProvider = StateNotifierProvider<PinLockNotifier, PinLockState>((ref) {
  final pinService = PinLockService();
  final profileService = AppProfileService();
  return PinLockNotifier(pinService, profileService)..initialize();
});

class PinLockNotifier extends StateNotifier<PinLockState> {
  PinLockNotifier(this._pinService, this._profileService)
      : super(const PinLockState());

  final PinLockService _pinService;
  final AppProfileService _profileService;
  bool _loading = false;

  Future<void> initialize() async {
    if (_loading || state.isInitialized) return;
    _loading = true;

    final pinEnabled = await _profileService.isPinEnabled();
    final hasPin = await _pinService.hasPin();
    final remaining = await _pinService.remainingAttempts();
    final locked = await _pinService.isLockedOut();
    final lockExpires = await _pinService.lockExpiresAt();
    final requiresPin = pinEnabled && hasPin;

    state = state.copyWith(
      isInitialized: true,
      isPinEnabled: requiresPin,
      isUnlocked: !requiresPin || !locked,
      remainingAttempts: remaining,
      lockExpiresAt: lockExpires,
    );
    _loading = false;
  }

  Future<void> enablePin(String pin, {int autoLockMinutes = 1}) async {
    await _pinService.setPin(pin);
    await _profileService.setPinEnabled(true);
    await _profileService.setAutoLockMinutes(autoLockMinutes);
    state = state.copyWith(
      isInitialized: true,
      isPinEnabled: true,
      isUnlocked: true,
      remainingAttempts: await _pinService.remainingAttempts(),
      lockExpiresAt: await _pinService.lockExpiresAt(),
    );
  }

  Future<void> disablePin() async {
    await _pinService.clearPin();
    await _profileService.setPinEnabled(false);
    state = state.copyWith(
      isPinEnabled: false,
      isUnlocked: true,
      remainingAttempts: 5,
      lockExpiresAt: null,
    );
  }

  void requireUnlock() {
    if (!state.isPinEnabled) {
      return;
    }
    state = state.copyWith(isUnlocked: false);
  }

  Future<bool> unlockWithPin(String pin) async {
    final success = await _pinService.verifyPin(pin);
    final remaining = await _pinService.remainingAttempts();
    final lockExpires = await _pinService.lockExpiresAt();

    if (success) {
      await _pinService.markUnlockedNow();
      state = state.copyWith(
        isUnlocked: true,
        remainingAttempts: remaining,
        lockExpiresAt: lockExpires,
      );
      return true;
    }

    state = state.copyWith(
      isUnlocked: false,
      remainingAttempts: remaining,
      lockExpiresAt: lockExpires,
    );
    return false;
  }

  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    final verified = await _pinService.verifyPin(currentPin);
    if (!verified) {
      throw StateError('현재 PIN이 일치하지 않습니다.');
    }

    await _pinService.setPin(newPin);
    state = state.copyWith(
      isUnlocked: true,
      remainingAttempts: await _pinService.remainingAttempts(),
      lockExpiresAt: await _pinService.lockExpiresAt(),
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(isInitialized: false);
    await initialize();
  }
}

