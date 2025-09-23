import 'package:everydiary/shared/models/auth_token.dart';
import 'package:everydiary/shared/models/user.dart';
import 'package:everydiary/shared/services/session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_providers.freezed.dart';

/// 세션 서비스 Provider
final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService.instance;
});

/// 세션 이벤트 스트림 Provider
final sessionEventStreamProvider = StreamProvider<SessionEvent>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.sessionStream;
});

/// 현재 세션 사용자 Provider
final sessionUserProvider = FutureProvider<User?>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.getCurrentUser();
});

/// 세션 유효성 Provider
final sessionValidityProvider = FutureProvider<bool>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.isSessionValid();
});

/// 세션 통계 Provider
final sessionStatsProvider = FutureProvider<SessionStats>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.getSessionStats();
});

/// 계정 잠금 상태 Provider
final accountLockedProvider = FutureProvider<bool>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.isAccountLocked();
});

/// 잠금 해제까지 남은 시간 Provider
final lockoutRemainingProvider = FutureProvider<Duration?>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.getRemainingLockoutTime();
});

/// 남은 로그인 시도 횟수 Provider
final remainingLoginAttemptsProvider = FutureProvider<int>((ref) {
  final sessionService = ref.watch(sessionServiceProvider);
  return sessionService.getRemainingLoginAttempts();
});

/// 세션 상태 관리 Notifier
class SessionNotifier extends StateNotifier<SessionState> {
  final SessionService _sessionService;

  SessionNotifier(this._sessionService) : super(const SessionState()) {
    _initialize();
  }

  /// 초기화
  Future<void> _initialize() async {
    await _sessionService.initialize();
    await _updateSessionState();

    // 세션 이벤트 리스닝
    _sessionService.sessionStream.listen((event) {
      _handleSessionEvent(event);
    });
  }

  /// 세션 상태 업데이트
  Future<void> _updateSessionState() async {
    final isValid = await _sessionService.isSessionValid();
    final user = await _sessionService.getCurrentUser();
    final stats = await _sessionService.getSessionStats();

    state = state.copyWith(isValid: isValid, user: user, stats: stats);
  }

  /// 세션 이벤트 처리
  void _handleSessionEvent(SessionEvent event) {
    switch (event) {
      case SessionCreatedEvent _:
        state = state.copyWith(isValid: true, user: event.user);
        break;
      case SessionRefreshedEvent _:
        _updateSessionState();
        break;
      case SessionUpdatedEvent _:
        state = state.copyWith(user: event.user);
        break;
      case SessionEndedEvent _:
        state = state.copyWith(isValid: false, user: null);
        break;
      case SessionTimeoutEvent _:
        state = state.copyWith(
          isValid: false,
          user: null,
          error: '세션이 만료되었습니다',
        );
        break;
      case AccountLockedEvent _:
        state = state.copyWith(
          isLocked: true,
          lockoutUntil: event.lockoutUntil,
        );
        break;
    }
  }

  /// 세션 생성
  Future<void> createSession(User user, AuthToken tokens) async {
    try {
      await _sessionService.createSession(user, tokens);
      await _updateSessionState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 세션 갱신
  Future<void> refreshSession(AuthToken tokens) async {
    try {
      await _sessionService.refreshSession(tokens);
      await _updateSessionState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 세션 업데이트
  Future<void> updateSession(User user) async {
    try {
      await _sessionService.updateSession(user);
      await _updateSessionState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 세션 종료
  Future<void> endSession() async {
    try {
      await _sessionService.endSession();
      await _updateSessionState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 활동 기록 업데이트
  Future<void> updateActivity() async {
    try {
      await _sessionService.updateActivity();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 로그인 시도 기록
  Future<void> recordLoginAttempt(String email, bool success) async {
    try {
      await _sessionService.recordLoginAttempt(email, success);
      await _updateSessionState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 세션 상태
@freezed
class SessionState with _$SessionState {
  const factory SessionState({
    @Default(false) bool isValid,
    User? user,
    SessionStats? stats,
    @Default(false) bool isLocked,
    DateTime? lockoutUntil,
    String? error,
  }) = _SessionState;
}

/// 세션 상태 관리 Provider
final sessionStateProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
      final sessionService = ref.watch(sessionServiceProvider);
      return SessionNotifier(sessionService);
    });

/// 세션 유효성 상태 Provider
final sessionValidStateProvider = Provider<bool>((ref) {
  final sessionState = ref.watch(sessionStateProvider);
  return sessionState.isValid;
});

/// 세션 사용자 상태 Provider
final sessionUserStateProvider = Provider<User?>((ref) {
  final sessionState = ref.watch(sessionStateProvider);
  return sessionState.user;
});

/// 세션 에러 상태 Provider
final sessionErrorProvider = Provider<String?>((ref) {
  final sessionState = ref.watch(sessionStateProvider);
  return sessionState.error;
});

/// 계정 잠금 상태 Provider
final accountLockedStateProvider = Provider<bool>((ref) {
  final sessionState = ref.watch(sessionStateProvider);
  return sessionState.isLocked;
});

/// 잠금 해제 시간 Provider
final lockoutUntilProvider = Provider<DateTime?>((ref) {
  final sessionState = ref.watch(sessionStateProvider);
  return sessionState.lockoutUntil;
});
