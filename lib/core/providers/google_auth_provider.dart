import 'dart:async';

import 'package:everydiary/core/services/google_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Google 인증 상태 모델
class GoogleAuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const GoogleAuthState({this.user, this.isLoading = false, this.error});

  GoogleAuthState copyWith({User? user, bool? isLoading, String? error}) {
    return GoogleAuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isSignedIn => user != null;
}

/// Google 인증 상태 관리자
class GoogleAuthNotifier extends StateNotifier<GoogleAuthState> {
  GoogleAuthNotifier(this._authService) : super(const GoogleAuthState()) {
    _authStateSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
    );
  }

  final GoogleAuthService _authService;
  late final StreamSubscription<User?> _authStateSubscription;
  final _authEventsController = StreamController<User?>.broadcast();

  Stream<User?> get authEvents => _authEventsController.stream;

  void _onAuthStateChanged(User? user) {
    state = state.copyWith(user: user, isLoading: false, error: null);
    _authEventsController.add(user);
  }

  /// Google 로그인
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        state = state.copyWith(user: user, isLoading: false, error: null);
      } else {
        state = state.copyWith(isLoading: false, error: 'Google 로그인에 실패했습니다.');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Google 로그인 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// Google 로그아웃
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.signOut();
      state = const GoogleAuthState();
      _authEventsController.add(null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  /// 현재 사용자 정보 업데이트
  void updateUser(User? user) {
    state = state.copyWith(user: user);
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    _authEventsController.close();
    super.dispose();
  }
}

/// Google 인증 상태 프로바이더
final googleAuthProvider =
    StateNotifierProvider<GoogleAuthNotifier, GoogleAuthState>((ref) {
      final service = GoogleAuthService();
      final notifier = GoogleAuthNotifier(service);
      ref.onDispose(notifier.dispose);
      return notifier;
    });

final googleAuthEventsProvider = StreamProvider.autoDispose<User?>((ref) {
  final notifier = ref.watch(googleAuthProvider.notifier);
  return notifier.authEvents;
});

/// 현재 사용자 프로바이더
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(googleAuthProvider).user;
});

/// 로그인 상태 프로바이더
final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(googleAuthProvider).isSignedIn;
});
