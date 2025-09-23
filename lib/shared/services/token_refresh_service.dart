import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/logger.dart';
import 'auth_service.dart';
import 'jwt_service.dart';
import 'logout_service.dart';
import 'session_service.dart';

/// 토큰 갱신 이벤트 타입
enum TokenRefreshEventType {
  refreshStarted, // 토큰 갱신 시작
  refreshSuccess, // 토큰 갱신 성공
  refreshFailed, // 토큰 갱신 실패
  refreshSkipped, // 토큰 갱신 건너뜀 (불필요)
  autoRefreshEnabled, // 자동 갱신 활성화
  autoRefreshDisabled, // 자동 갱신 비활성화
}

/// 토큰 갱신 이벤트
class TokenRefreshEvent {
  final TokenRefreshEventType type;
  final String? message;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final Exception? error;

  const TokenRefreshEvent({
    required this.type,
    this.message,
    required this.timestamp,
    this.metadata,
    this.error,
  });

  @override
  String toString() {
    return 'TokenRefreshEvent(type: $type, message: $message, timestamp: $timestamp, metadata: $metadata, error: $error)';
  }
}

/// 토큰 갱신 서비스
class TokenRefreshService {
  final AuthService _authService;
  final LogoutService _logoutService;
  final SessionService _sessionService;

  // 토큰 갱신 이벤트 스트림
  final StreamController<TokenRefreshEvent> _refreshEventController =
      StreamController<TokenRefreshEvent>.broadcast();

  // 자동 갱신 타이머
  Timer? _autoRefreshTimer;

  // 갱신 설정
  bool _isAutoRefreshEnabled = true;
  Duration _refreshCheckInterval = const Duration(minutes: 5);
  Duration _refreshThreshold = const Duration(minutes: 5); // 만료 5분 전에 갱신

  TokenRefreshService(this._authService, this._logoutService)
    : _sessionService = SessionService.instance;

  /// 토큰 갱신 이벤트 스트림
  Stream<TokenRefreshEvent> get refreshStream => _refreshEventController.stream;

  /// 자동 갱신 활성화 여부
  bool get isAutoRefreshEnabled => _isAutoRefreshEnabled;

  /// 자동 갱신 시작
  void startAutoRefresh() {
    if (_isAutoRefreshEnabled && _autoRefreshTimer == null) {
      _autoRefreshTimer = Timer.periodic(_refreshCheckInterval, (_) {
        _checkAndRefreshToken();
      });

      _refreshEventController.add(
        TokenRefreshEvent(
          type: TokenRefreshEventType.autoRefreshEnabled,
          message: '자동 토큰 갱신이 활성화되었습니다.',
          timestamp: DateTime.now(),
          metadata: {
            'checkInterval': _refreshCheckInterval.inMinutes,
            'refreshThreshold': _refreshThreshold.inMinutes,
          },
        ),
      );
    }
  }

  /// 자동 갱신 중지
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;

    _refreshEventController.add(
      TokenRefreshEvent(
        type: TokenRefreshEventType.autoRefreshDisabled,
        message: '자동 토큰 갱신이 비활성화되었습니다.',
        timestamp: DateTime.now(),
      ),
    );
  }

  /// 자동 갱신 설정 변경
  void setAutoRefreshEnabled(bool enabled) {
    _isAutoRefreshEnabled = enabled;

    if (enabled) {
      startAutoRefresh();
    } else {
      stopAutoRefresh();
    }
  }

  /// 갱신 체크 간격 설정
  void setRefreshCheckInterval(Duration interval) {
    _refreshCheckInterval = interval;

    // 자동 갱신이 활성화되어 있으면 타이머 재시작
    if (_isAutoRefreshEnabled) {
      stopAutoRefresh();
      startAutoRefresh();
    }
  }

  /// 갱신 임계값 설정
  void setRefreshThreshold(Duration threshold) {
    _refreshThreshold = threshold;
  }

  /// 토큰 갱신 필요 여부 확인
  Future<bool> needsTokenRefresh() async {
    try {
      return await JwtService.needsTokenRefresh();
    } catch (e) {
      Logger.warning('토큰 갱신 필요 여부 확인 실패: $e');
      return false;
    }
  }

  /// 토큰 갱신 수행
  Future<bool> refreshToken() async {
    try {
      _refreshEventController.add(
        TokenRefreshEvent(
          type: TokenRefreshEventType.refreshStarted,
          message: '토큰 갱신을 시작합니다.',
          timestamp: DateTime.now(),
        ),
      );

      // 현재 토큰 상태 확인
      final hasValidToken = await JwtService.hasValidToken();
      if (!hasValidToken) {
        _refreshEventController.add(
          TokenRefreshEvent(
            type: TokenRefreshEventType.refreshSkipped,
            message: '유효한 토큰이 없어 갱신을 건너뜁니다.',
            timestamp: DateTime.now(),
          ),
        );
        return false;
      }

      // 갱신 필요 여부 확인
      final needsRefresh = await needsTokenRefresh();
      if (!needsRefresh) {
        _refreshEventController.add(
          TokenRefreshEvent(
            type: TokenRefreshEventType.refreshSkipped,
            message: '토큰이 아직 유효하여 갱신을 건너뜁니다.',
            timestamp: DateTime.now(),
          ),
        );
        return true;
      }

      // 토큰 갱신 수행
      final newTokens = await _authService.refreshToken();

      // 세션 갱신
      await _sessionService.refreshSession(newTokens);

      _refreshEventController.add(
        TokenRefreshEvent(
          type: TokenRefreshEventType.refreshSuccess,
          message: '토큰이 성공적으로 갱신되었습니다.',
          timestamp: DateTime.now(),
          metadata: {'newExpiry': newTokens.expiresAt.toIso8601String()},
        ),
      );

      return true;
    } catch (e) {
      Logger.warning('토큰 갱신 실패: $e');

      _refreshEventController.add(
        TokenRefreshEvent(
          type: TokenRefreshEventType.refreshFailed,
          message: '토큰 갱신에 실패했습니다.',
          timestamp: DateTime.now(),
          error: e is Exception ? e : Exception(e.toString()),
          metadata: {'errorType': e.runtimeType.toString()},
        ),
      );

      // 토큰 갱신 실패 시 로그아웃 처리
      await _logoutService.logoutDueToTokenExpiry(
        reason: '토큰 갱신에 실패하여 로그아웃됩니다.',
        metadata: {'refreshError': e.toString()},
      );

      return false;
    }
  }

  /// 토큰 갱신 체크 및 수행 (내부 메서드)
  Future<void> _checkAndRefreshToken() async {
    try {
      final needsRefresh = await needsTokenRefresh();
      if (needsRefresh) {
        await refreshToken();
      }
    } catch (e) {
      Logger.warning('자동 토큰 갱신 체크 실패: $e');
    }
  }

  /// 강제 토큰 갱신
  Future<bool> forceRefreshToken() async {
    try {
      _refreshEventController.add(
        TokenRefreshEvent(
          type: TokenRefreshEventType.refreshStarted,
          message: '강제 토큰 갱신을 시작합니다.',
          timestamp: DateTime.now(),
          metadata: {'forceRefresh': true},
        ),
      );

      final newTokens = await _authService.refreshToken();
      await _sessionService.refreshSession(newTokens);

      _refreshEventController.add(
        TokenRefreshEvent(
          type: TokenRefreshEventType.refreshSuccess,
          message: '강제 토큰 갱신이 완료되었습니다.',
          timestamp: DateTime.now(),
          metadata: {
            'forceRefresh': true,
            'newExpiry': newTokens.expiresAt.toIso8601String(),
          },
        ),
      );

      return true;
    } catch (e) {
      Logger.warning('강제 토큰 갱신 실패: $e');

      _refreshEventController.add(
        TokenRefreshEvent(
          type: TokenRefreshEventType.refreshFailed,
          message: '강제 토큰 갱신에 실패했습니다.',
          timestamp: DateTime.now(),
          error: e is Exception ? e : Exception(e.toString()),
          metadata: {
            'forceRefresh': true,
            'errorType': e.runtimeType.toString(),
          },
        ),
      );

      return false;
    }
  }

  /// 토큰 상태 정보 가져오기
  Future<TokenStatus> getTokenStatus() async {
    try {
      final accessToken = await JwtService.getAccessToken();
      final refreshToken = await JwtService.getRefreshToken();
      final expiry = await JwtService.getTokenExpiry();
      final isValid = await JwtService.hasValidToken();
      final needsRefresh = await needsTokenRefresh();

      return TokenStatus(
        hasAccessToken: accessToken != null,
        hasRefreshToken: refreshToken != null,
        isValid: isValid,
        needsRefresh: needsRefresh,
        expiresAt: expiry,
        timeUntilExpiry: expiry?.difference(DateTime.now()),
      );
    } catch (e) {
      Logger.warning('토큰 상태 조회 실패: $e');
      return const TokenStatus(
        hasAccessToken: false,
        hasRefreshToken: false,
        isValid: false,
        needsRefresh: true,
        expiresAt: null,
        timeUntilExpiry: null,
      );
    }
  }

  /// 서비스 정리
  void dispose() {
    stopAutoRefresh();
    _refreshEventController.close();
  }
}

/// 토큰 상태 정보
class TokenStatus {
  final bool hasAccessToken;
  final bool hasRefreshToken;
  final bool isValid;
  final bool needsRefresh;
  final DateTime? expiresAt;
  final Duration? timeUntilExpiry;

  const TokenStatus({
    required this.hasAccessToken,
    required this.hasRefreshToken,
    required this.isValid,
    required this.needsRefresh,
    this.expiresAt,
    this.timeUntilExpiry,
  });

  @override
  String toString() {
    return 'TokenStatus(hasAccessToken: $hasAccessToken, hasRefreshToken: $hasRefreshToken, isValid: $isValid, needsRefresh: $needsRefresh, expiresAt: $expiresAt, timeUntilExpiry: $timeUntilExpiry)';
  }
}

/// TokenRefreshService Provider
final tokenRefreshServiceProvider = Provider<TokenRefreshService>((ref) {
  final authService = ref.watch(authServiceProvider);
  final logoutService = ref.watch(logoutServiceProvider);
  return TokenRefreshService(authService, logoutService);
});

/// 토큰 갱신 이벤트 스트림 Provider
final tokenRefreshEventStreamProvider = StreamProvider<TokenRefreshEvent>((
  ref,
) {
  final refreshService = ref.watch(tokenRefreshServiceProvider);
  return refreshService.refreshStream;
});

/// 토큰 상태 Provider
final tokenStatusProvider = FutureProvider<TokenStatus>((ref) {
  final refreshService = ref.watch(tokenRefreshServiceProvider);
  return refreshService.getTokenStatus();
});

/// 토큰 갱신 상태 Provider
final tokenRefreshStateProvider =
    StateNotifierProvider<TokenRefreshStateNotifier, TokenRefreshState>((ref) {
      final refreshService = ref.watch(tokenRefreshServiceProvider);
      return TokenRefreshStateNotifier(refreshService);
    });

/// 토큰 갱신 상태
class TokenRefreshState {
  final bool isRefreshing;
  final bool isAutoRefreshEnabled;
  final TokenRefreshEvent? lastEvent;
  final String? error;
  final TokenStatus? tokenStatus;

  const TokenRefreshState({
    this.isRefreshing = false,
    this.isAutoRefreshEnabled = true,
    this.lastEvent,
    this.error,
    this.tokenStatus,
  });

  TokenRefreshState copyWith({
    bool? isRefreshing,
    bool? isAutoRefreshEnabled,
    TokenRefreshEvent? lastEvent,
    String? error,
    TokenStatus? tokenStatus,
  }) {
    return TokenRefreshState(
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isAutoRefreshEnabled: isAutoRefreshEnabled ?? this.isAutoRefreshEnabled,
      lastEvent: lastEvent ?? this.lastEvent,
      error: error ?? this.error,
      tokenStatus: tokenStatus ?? this.tokenStatus,
    );
  }
}

/// 토큰 갱신 상태 관리 Notifier
class TokenRefreshStateNotifier extends StateNotifier<TokenRefreshState> {
  final TokenRefreshService _refreshService;
  StreamSubscription<TokenRefreshEvent>? _refreshSubscription;

  TokenRefreshStateNotifier(this._refreshService)
    : super(const TokenRefreshState()) {
    _setupRefreshListener();
    _initializeAutoRefresh();
  }

  void _setupRefreshListener() {
    _refreshSubscription = _refreshService.refreshStream.listen(
      (event) {
        state = state.copyWith(
          isRefreshing: event.type == TokenRefreshEventType.refreshStarted,
          lastEvent: event,
          error: event.type == TokenRefreshEventType.refreshFailed
              ? event.message
              : null,
        );

        // 토큰 상태 업데이트
        if (event.type == TokenRefreshEventType.refreshSuccess) {
          _updateTokenStatus();
        }
      },
      onError: (dynamic error) {
        state = state.copyWith(isRefreshing: false, error: error.toString());
      },
    );
  }

  void _initializeAutoRefresh() {
    state = state.copyWith(
      isAutoRefreshEnabled: _refreshService.isAutoRefreshEnabled,
    );

    if (_refreshService.isAutoRefreshEnabled) {
      _refreshService.startAutoRefresh();
    }
  }

  /// 토큰 갱신 수행
  Future<void> refreshToken() async {
    state = state.copyWith(isRefreshing: true, error: null);
    await _refreshService.refreshToken();
  }

  /// 강제 토큰 갱신
  Future<void> forceRefreshToken() async {
    state = state.copyWith(isRefreshing: true, error: null);
    await _refreshService.forceRefreshToken();
  }

  /// 자동 갱신 토글
  void toggleAutoRefresh() {
    final newState = !state.isAutoRefreshEnabled;
    _refreshService.setAutoRefreshEnabled(newState);
    state = state.copyWith(isAutoRefreshEnabled: newState);
  }

  /// 토큰 상태 업데이트
  Future<void> _updateTokenStatus() async {
    try {
      final status = await _refreshService.getTokenStatus();
      state = state.copyWith(tokenStatus: status);
    } catch (e) {
      // 에러는 무시 (상태 업데이트 실패는 치명적이지 않음)
    }
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _refreshSubscription?.cancel();
    super.dispose();
  }
}
