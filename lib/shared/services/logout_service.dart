import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/logger.dart';
import 'auth_service.dart';
import 'jwt_service.dart';
import 'session_service.dart';
import 'token_blacklist_service.dart';

/// 로그아웃 이벤트 타입
enum LogoutEventType {
  userInitiated, // 사용자가 직접 로그아웃
  tokenExpired, // 토큰 만료로 인한 로그아웃
  securityBreach, // 보안 위반으로 인한 로그아웃
  accountLocked, // 계정 잠금으로 인한 로그아웃
  serverError, // 서버 오류로 인한 로그아웃
  networkError, // 네트워크 오류로 인한 로그아웃
}

/// 로그아웃 이벤트
class LogoutEvent {
  final LogoutEventType type;
  final String? reason;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const LogoutEvent({
    required this.type,
    this.reason,
    required this.timestamp,
    this.metadata,
  });

  @override
  String toString() {
    return 'LogoutEvent(type: $type, reason: $reason, timestamp: $timestamp, metadata: $metadata)';
  }
}

/// 로그아웃 서비스
class LogoutService {
  final AuthService _authService;
  final SessionService _sessionService;

  // 로그아웃 이벤트 스트림
  final StreamController<LogoutEvent> _logoutEventController =
      StreamController<LogoutEvent>.broadcast();

  LogoutService(this._authService) : _sessionService = SessionService.instance;

  /// 로그아웃 이벤트 스트림
  Stream<LogoutEvent> get logoutStream => _logoutEventController.stream;

  /// 사용자 로그아웃 (일반적인 로그아웃)
  Future<void> logoutUser({
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    await _performLogout(
      LogoutEventType.userInitiated,
      reason: reason,
      metadata: metadata,
    );
  }

  /// 토큰 만료로 인한 로그아웃
  Future<void> logoutDueToTokenExpiry({
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    await _performLogout(
      LogoutEventType.tokenExpired,
      reason: reason ?? '토큰이 만료되었습니다.',
      metadata: metadata,
    );
  }

  /// 보안 위반으로 인한 로그아웃
  Future<void> logoutDueToSecurityBreach({
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    await _performLogout(
      LogoutEventType.securityBreach,
      reason: reason ?? '보안 위반이 감지되었습니다.',
      metadata: metadata,
    );
  }

  /// 계정 잠금으로 인한 로그아웃
  Future<void> logoutDueToAccountLocked({
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    await _performLogout(
      LogoutEventType.accountLocked,
      reason: reason ?? '계정이 잠겼습니다.',
      metadata: metadata,
    );
  }

  /// 서버 오류로 인한 로그아웃
  Future<void> logoutDueToServerError({
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    await _performLogout(
      LogoutEventType.serverError,
      reason: reason ?? '서버 오류가 발생했습니다.',
      metadata: metadata,
    );
  }

  /// 네트워크 오류로 인한 로그아웃
  Future<void> logoutDueToNetworkError({
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    await _performLogout(
      LogoutEventType.networkError,
      reason: reason ?? '네트워크 연결에 문제가 있습니다.',
      metadata: metadata,
    );
  }

  /// 강제 로그아웃 (모든 디바이스에서)
  Future<void> forceLogoutAllDevices({
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // 서버에 강제 로그아웃 요청
      await _authService.logout();

      // 로컬에서도 로그아웃 처리
      await _performLogout(
        LogoutEventType.securityBreach,
        reason: reason ?? '모든 디바이스에서 강제 로그아웃되었습니다.',
        metadata: {...?metadata, 'forceLogout': true, 'allDevices': true},
      );
    } catch (e) {
      // 서버 요청 실패해도 로컬 로그아웃은 수행
      await _performLogout(
        LogoutEventType.serverError,
        reason: '강제 로그아웃 중 서버 오류가 발생했습니다.',
        metadata: {
          ...?metadata,
          'forceLogout': true,
          'serverError': e.toString(),
        },
      );
    }
  }

  /// 로그아웃 수행 (내부 메서드)
  Future<void> _performLogout(
    LogoutEventType type, {
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // 현재 토큰들 가져오기
      final accessToken = await JwtService.getAccessToken();
      final refreshToken = await JwtService.getRefreshToken();

      // 토큰들을 블랙리스트에 추가
      if (accessToken != null) {
        await TokenBlacklistService.addToBlacklist(accessToken);
      }
      if (refreshToken != null) {
        await TokenBlacklistService.addToBlacklist(refreshToken);
      }

      // 서버에 로그아웃 요청 (실패해도 계속 진행)
      try {
        await _authService.logout();
      } catch (e) {
        Logger.warning('서버 로그아웃 요청 실패: $e');
      }

      // 로컬 토큰 삭제
      await JwtService.clearTokens();

      // 세션 종료
      await _sessionService.endSession();

      // 로그아웃 이벤트 발생
      final event = LogoutEvent(
        type: type,
        reason: reason,
        timestamp: DateTime.now(),
        metadata: {
          ...?metadata,
          'accessTokenBlacklisted': accessToken != null,
          'refreshTokenBlacklisted': refreshToken != null,
        },
      );

      _logoutEventController.add(event);

      Logger.info('로그아웃 완료: $event');
    } catch (e) {
      Logger.warning('로그아웃 처리 중 오류: $e');

      // 오류가 발생해도 강제로 로컬 정리
      try {
        await JwtService.clearTokens();
        await _sessionService.endSession();
      } catch (cleanupError) {
        Logger.warning('로그아웃 정리 중 오류: $cleanupError');
      }

      // 오류 이벤트 발생
      final errorEvent = LogoutEvent(
        type: type,
        reason: '로그아웃 처리 중 오류가 발생했습니다: $e',
        timestamp: DateTime.now(),
        metadata: {...?metadata, 'error': e.toString()},
      );

      _logoutEventController.add(errorEvent);
    }
  }

  /// 로그아웃 이벤트 리스너 등록
  void addLogoutListener(void Function(LogoutEvent) listener) {
    _logoutEventController.stream.listen(listener);
  }

  /// 로그아웃 이벤트 리스너 제거
  void removeLogoutListener() {
    // StreamController는 자동으로 관리되므로 별도 제거 불필요
  }

  /// 서비스 정리
  void dispose() {
    _logoutEventController.close();
  }
}

/// LogoutService Provider
final logoutServiceProvider = Provider<LogoutService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return LogoutService(authService);
});

/// 로그아웃 이벤트 스트림 Provider
final logoutEventStreamProvider = StreamProvider<LogoutEvent>((ref) {
  final logoutService = ref.watch(logoutServiceProvider);
  return logoutService.logoutStream;
});

/// 로그아웃 상태 Provider
final logoutStateProvider =
    StateNotifierProvider<LogoutStateNotifier, LogoutState>((ref) {
      final logoutService = ref.watch(logoutServiceProvider);
      return LogoutStateNotifier(logoutService);
    });

/// 로그아웃 상태
class LogoutState {
  final bool isLoggingOut;
  final LogoutEvent? lastEvent;
  final String? error;

  const LogoutState({this.isLoggingOut = false, this.lastEvent, this.error});

  LogoutState copyWith({
    bool? isLoggingOut,
    LogoutEvent? lastEvent,
    String? error,
  }) {
    return LogoutState(
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      lastEvent: lastEvent ?? this.lastEvent,
      error: error ?? this.error,
    );
  }
}

/// 로그아웃 상태 관리 Notifier
class LogoutStateNotifier extends StateNotifier<LogoutState> {
  final LogoutService _logoutService;
  StreamSubscription<LogoutEvent>? _logoutSubscription;

  LogoutStateNotifier(this._logoutService) : super(const LogoutState()) {
    _setupLogoutListener();
  }

  void _setupLogoutListener() {
    _logoutSubscription = _logoutService.logoutStream.listen(
      (event) {
        state = state.copyWith(
          isLoggingOut: false,
          lastEvent: event,
          error: null,
        );
      },
      onError: (dynamic error) {
        state = state.copyWith(isLoggingOut: false, error: error.toString());
      },
    );
  }

  /// 사용자 로그아웃
  Future<void> logoutUser({String? reason}) async {
    state = state.copyWith(isLoggingOut: true, error: null);
    await _logoutService.logoutUser(reason: reason);
  }

  /// 강제 로그아웃
  Future<void> forceLogout({String? reason}) async {
    state = state.copyWith(isLoggingOut: true, error: null);
    await _logoutService.forceLogoutAllDevices(reason: reason);
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _logoutSubscription?.cancel();
    super.dispose();
  }
}
