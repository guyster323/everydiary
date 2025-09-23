import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/logger.dart';
import '../../features/auth/providers/session_providers.dart';
import '../models/auth_token.dart';
import '../models/user.dart';
import 'auth_service.dart';
import 'jwt_service.dart';
import 'session_service.dart';
import 'token_refresh_service.dart';

/// 자동 로그인 이벤트 타입
enum AutoLoginEventType {
  autoLoginStarted, // 자동 로그인 시작
  autoLoginSuccess, // 자동 로그인 성공
  autoLoginFailed, // 자동 로그인 실패
  autoLoginSkipped, // 자동 로그인 건너뜀
  rememberMeEnabled, // 로그인 상태 유지 활성화
  rememberMeDisabled, // 로그인 상태 유지 비활성화
}

/// 자동 로그인 이벤트
class AutoLoginEvent {
  final AutoLoginEventType type;
  final String? message;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final Exception? error;

  const AutoLoginEvent({
    required this.type,
    this.message,
    required this.timestamp,
    this.metadata,
    this.error,
  });

  @override
  String toString() {
    return 'AutoLoginEvent(type: $type, message: $message, timestamp: $timestamp, metadata: $metadata, error: $error)';
  }
}

/// 자동 로그인 서비스
class AutoLoginService {
  final AuthService _authService;
  final SessionService _sessionService;
  final TokenRefreshService _tokenRefreshService;

  // 자동 로그인 이벤트 스트림
  final StreamController<AutoLoginEvent> _autoLoginEventController =
      StreamController<AutoLoginEvent>.broadcast();

  // 설정 키
  static const String _rememberMeKey = 'remember_me';
  static const String _lastLoginEmailKey = 'last_login_email';
  static const String _autoLoginEnabledKey = 'auto_login_enabled';

  AutoLoginService(
    this._authService,
    this._sessionService,
    this._tokenRefreshService,
  );

  /// 자동 로그인 이벤트 스트림
  Stream<AutoLoginEvent> get autoLoginStream =>
      _autoLoginEventController.stream;

  /// 로그인 상태 유지 설정
  Future<void> setRememberMe(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, enabled);

      _autoLoginEventController.add(
        AutoLoginEvent(
          type: enabled
              ? AutoLoginEventType.rememberMeEnabled
              : AutoLoginEventType.rememberMeDisabled,
          message: enabled ? '로그인 상태 유지가 활성화되었습니다.' : '로그인 상태 유지가 비활성화되었습니다.',
          timestamp: DateTime.now(),
        ),
      );

      // 로그인 상태 유지가 비활성화되면 자동 로그인도 비활성화
      if (!enabled) {
        await setAutoLoginEnabled(false);
      }
    } catch (e) {
      Logger.warning('로그인 상태 유지 설정 실패: $e');
    }
  }

  /// 로그인 상태 유지 여부 확인
  Future<bool> isRememberMeEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_rememberMeKey) ?? false;
    } catch (e) {
      Logger.warning('로그인 상태 유지 확인 실패: $e');
      return false;
    }
  }

  /// 자동 로그인 활성화 설정
  Future<void> setAutoLoginEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoLoginEnabledKey, enabled);

      _autoLoginEventController.add(
        AutoLoginEvent(
          type: enabled
              ? AutoLoginEventType.rememberMeEnabled
              : AutoLoginEventType.rememberMeDisabled,
          message: enabled ? '자동 로그인이 활성화되었습니다.' : '자동 로그인이 비활성화되었습니다.',
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      Logger.warning('자동 로그인 설정 실패: $e');
    }
  }

  /// 자동 로그인 활성화 여부 확인
  Future<bool> isAutoLoginEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_autoLoginEnabledKey) ?? false;
    } catch (e) {
      Logger.warning('자동 로그인 확인 실패: $e');
      return false;
    }
  }

  /// 마지막 로그인 이메일 저장
  Future<void> saveLastLoginEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastLoginEmailKey, email);
    } catch (e) {
      Logger.warning('마지막 로그인 이메일 저장 실패: $e');
    }
  }

  /// 마지막 로그인 이메일 가져오기
  Future<String?> getLastLoginEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastLoginEmailKey);
    } catch (e) {
      Logger.warning('마지막 로그인 이메일 조회 실패: $e');
      return null;
    }
  }

  /// 자동 로그인 시도
  Future<bool> attemptAutoLogin() async {
    try {
      _autoLoginEventController.add(
        AutoLoginEvent(
          type: AutoLoginEventType.autoLoginStarted,
          message: '자동 로그인을 시도합니다.',
          timestamp: DateTime.now(),
        ),
      );

      // 자동 로그인 활성화 여부 확인
      final isAutoLoginEnabled = await this.isAutoLoginEnabled();
      if (!isAutoLoginEnabled) {
        _autoLoginEventController.add(
          AutoLoginEvent(
            type: AutoLoginEventType.autoLoginSkipped,
            message: '자동 로그인이 비활성화되어 있습니다.',
            timestamp: DateTime.now(),
          ),
        );
        return false;
      }

      // 로그인 상태 유지 여부 확인
      final rememberMeEnabled = await isRememberMeEnabled();
      if (!rememberMeEnabled) {
        _autoLoginEventController.add(
          AutoLoginEvent(
            type: AutoLoginEventType.autoLoginSkipped,
            message: '로그인 상태 유지가 비활성화되어 있습니다.',
            timestamp: DateTime.now(),
          ),
        );
        return false;
      }

      // 유효한 토큰 확인
      final hasValidToken = await JwtService.hasValidToken();
      if (!hasValidToken) {
        _autoLoginEventController.add(
          AutoLoginEvent(
            type: AutoLoginEventType.autoLoginFailed,
            message: '유효한 토큰이 없습니다.',
            timestamp: DateTime.now(),
          ),
        );
        return false;
      }

      // 토큰 갱신 필요 여부 확인
      final needsRefresh = await _tokenRefreshService.needsTokenRefresh();
      if (needsRefresh) {
        final refreshSuccess = await _tokenRefreshService.refreshToken();
        if (!refreshSuccess) {
          _autoLoginEventController.add(
            AutoLoginEvent(
              type: AutoLoginEventType.autoLoginFailed,
              message: '토큰 갱신에 실패했습니다.',
              timestamp: DateTime.now(),
            ),
          );
          return false;
        }
      }

      // 사용자 정보 가져오기
      final user = await _authService.getCurrentUser();

      // 세션 상태 확인
      final isSessionValid = await _sessionService.isSessionValid();
      if (!isSessionValid) {
        // 세션이 유효하지 않으면 새로 생성
        final accessToken = await JwtService.getAccessToken();
        final refreshToken = await JwtService.getRefreshToken();
        final expiresAt = await JwtService.getTokenExpiry();

        if (accessToken != null && refreshToken != null && expiresAt != null) {
          final tokens = AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt,
            tokenType: 'Bearer',
          );
          await _sessionService.createSession(user, tokens);
        }
      }

      _autoLoginEventController.add(
        AutoLoginEvent(
          type: AutoLoginEventType.autoLoginSuccess,
          message: '자동 로그인이 성공했습니다.',
          timestamp: DateTime.now(),
          metadata: {'userId': user.id, 'email': user.email, 'name': user.name},
        ),
      );

      return true;
    } catch (e) {
      Logger.warning('자동 로그인 실패: $e');

      _autoLoginEventController.add(
        AutoLoginEvent(
          type: AutoLoginEventType.autoLoginFailed,
          message: '자동 로그인에 실패했습니다.',
          timestamp: DateTime.now(),
          error: e is Exception ? e : Exception(e.toString()),
          metadata: {'errorType': e.runtimeType.toString()},
        ),
      );

      return false;
    }
  }

  /// 로그인 성공 시 자동 로그인 설정 저장
  Future<void> onLoginSuccess({
    required User user,
    required bool rememberMe,
  }) async {
    try {
      // 로그인 상태 유지 설정 저장
      await setRememberMe(rememberMe);

      // 자동 로그인 활성화 (로그인 상태 유지가 활성화된 경우)
      await setAutoLoginEnabled(rememberMe);

      // 마지막 로그인 이메일 저장
      if (user.email != null) {
        await saveLastLoginEmail(user.email!);
      }
    } catch (e) {
      Logger.warning('로그인 성공 후 설정 저장 실패: $e');
    }
  }

  /// 로그아웃 시 자동 로그인 설정 정리
  Future<void> onLogout() async {
    try {
      // 자동 로그인 비활성화
      await setAutoLoginEnabled(false);

      // 로그인 상태 유지 비활성화
      await setRememberMe(false);
    } catch (e) {
      Logger.warning('로그아웃 시 설정 정리 실패: $e');
    }
  }

  /// 자동 로그인 설정 초기화
  Future<void> clearAutoLoginSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_rememberMeKey);
      await prefs.remove(_lastLoginEmailKey);
      await prefs.remove(_autoLoginEnabledKey);
    } catch (e) {
      Logger.warning('자동 로그인 설정 초기화 실패: $e');
    }
  }

  /// 자동 로그인 상태 정보 가져오기
  Future<AutoLoginStatus> getAutoLoginStatus() async {
    try {
      final rememberMeEnabled = await isRememberMeEnabled();
      final autoLoginEnabled = await isAutoLoginEnabled();
      final lastLoginEmail = await getLastLoginEmail();
      final hasValidToken = await JwtService.hasValidToken();
      final isSessionValid = await _sessionService.isSessionValid();

      return AutoLoginStatus(
        isRememberMeEnabled: rememberMeEnabled,
        isAutoLoginEnabled: autoLoginEnabled,
        lastLoginEmail: lastLoginEmail,
        hasValidToken: hasValidToken,
        isSessionValid: isSessionValid,
        canAutoLogin: rememberMeEnabled && autoLoginEnabled && hasValidToken,
      );
    } catch (e) {
      Logger.warning('자동 로그인 상태 조회 실패: $e');
      return const AutoLoginStatus(
        isRememberMeEnabled: false,
        isAutoLoginEnabled: false,
        lastLoginEmail: null,
        hasValidToken: false,
        isSessionValid: false,
        canAutoLogin: false,
      );
    }
  }

  /// 서비스 정리
  void dispose() {
    _autoLoginEventController.close();
  }
}

/// 자동 로그인 상태 정보
class AutoLoginStatus {
  final bool isRememberMeEnabled;
  final bool isAutoLoginEnabled;
  final String? lastLoginEmail;
  final bool hasValidToken;
  final bool isSessionValid;
  final bool canAutoLogin;

  const AutoLoginStatus({
    required this.isRememberMeEnabled,
    required this.isAutoLoginEnabled,
    this.lastLoginEmail,
    required this.hasValidToken,
    required this.isSessionValid,
    required this.canAutoLogin,
  });

  @override
  String toString() {
    return 'AutoLoginStatus(isRememberMeEnabled: $isRememberMeEnabled, isAutoLoginEnabled: $isAutoLoginEnabled, lastLoginEmail: $lastLoginEmail, hasValidToken: $hasValidToken, isSessionValid: $isSessionValid, canAutoLogin: $canAutoLogin)';
  }
}

/// AutoLoginService Provider
final autoLoginServiceProvider = Provider<AutoLoginService>((ref) {
  final authService = ref.watch(authServiceProvider);
  final sessionService = ref.watch(sessionServiceProvider);
  final tokenRefreshService = ref.watch(tokenRefreshServiceProvider);
  return AutoLoginService(authService, sessionService, tokenRefreshService);
});

/// 자동 로그인 이벤트 스트림 Provider
final autoLoginEventStreamProvider = StreamProvider<AutoLoginEvent>((ref) {
  final autoLoginService = ref.watch(autoLoginServiceProvider);
  return autoLoginService.autoLoginStream;
});

/// 자동 로그인 상태 Provider
final autoLoginStatusProvider = FutureProvider<AutoLoginStatus>((ref) {
  final autoLoginService = ref.watch(autoLoginServiceProvider);
  return autoLoginService.getAutoLoginStatus();
});

/// 자동 로그인 상태 관리 Provider
final autoLoginStateProvider =
    StateNotifierProvider<AutoLoginStateNotifier, AutoLoginState>((ref) {
      final autoLoginService = ref.watch(autoLoginServiceProvider);
      return AutoLoginStateNotifier(autoLoginService);
    });

/// 자동 로그인 상태
class AutoLoginState {
  final bool isAttemptingAutoLogin;
  final bool isRememberMeEnabled;
  final bool isAutoLoginEnabled;
  final AutoLoginEvent? lastEvent;
  final String? error;
  final AutoLoginStatus? status;

  const AutoLoginState({
    this.isAttemptingAutoLogin = false,
    this.isRememberMeEnabled = false,
    this.isAutoLoginEnabled = false,
    this.lastEvent,
    this.error,
    this.status,
  });

  AutoLoginState copyWith({
    bool? isAttemptingAutoLogin,
    bool? isRememberMeEnabled,
    bool? isAutoLoginEnabled,
    AutoLoginEvent? lastEvent,
    String? error,
    AutoLoginStatus? status,
  }) {
    return AutoLoginState(
      isAttemptingAutoLogin:
          isAttemptingAutoLogin ?? this.isAttemptingAutoLogin,
      isRememberMeEnabled: isRememberMeEnabled ?? this.isRememberMeEnabled,
      isAutoLoginEnabled: isAutoLoginEnabled ?? this.isAutoLoginEnabled,
      lastEvent: lastEvent ?? this.lastEvent,
      error: error ?? this.error,
      status: status ?? this.status,
    );
  }
}

/// 자동 로그인 상태 관리 Notifier
class AutoLoginStateNotifier extends StateNotifier<AutoLoginState> {
  final AutoLoginService _autoLoginService;
  StreamSubscription<AutoLoginEvent>? _autoLoginSubscription;

  AutoLoginStateNotifier(this._autoLoginService)
    : super(const AutoLoginState()) {
    _setupAutoLoginListener();
    _initializeState();
  }

  void _setupAutoLoginListener() {
    _autoLoginSubscription = _autoLoginService.autoLoginStream.listen(
      (event) {
        state = state.copyWith(
          isAttemptingAutoLogin:
              event.type == AutoLoginEventType.autoLoginStarted,
          lastEvent: event,
          error: event.type == AutoLoginEventType.autoLoginFailed
              ? event.message
              : null,
        );

        // 설정 변경 이벤트 처리
        if (event.type == AutoLoginEventType.rememberMeEnabled) {
          state = state.copyWith(isRememberMeEnabled: true);
        } else if (event.type == AutoLoginEventType.rememberMeDisabled) {
          state = state.copyWith(isRememberMeEnabled: false);
        }
      },
      onError: (dynamic error) {
        state = state.copyWith(
          isAttemptingAutoLogin: false,
          error: error.toString(),
        );
      },
    );
  }

  Future<void> _initializeState() async {
    try {
      final status = await _autoLoginService.getAutoLoginStatus();
      state = state.copyWith(
        isRememberMeEnabled: status.isRememberMeEnabled,
        isAutoLoginEnabled: status.isAutoLoginEnabled,
        status: status,
      );
    } catch (e) {
      // 초기화 실패는 치명적이지 않음
    }
  }

  /// 자동 로그인 시도
  Future<bool> attemptAutoLogin() async {
    state = state.copyWith(isAttemptingAutoLogin: true, error: null);
    final success = await _autoLoginService.attemptAutoLogin();
    return success;
  }

  /// 로그인 상태 유지 설정
  Future<void> setRememberMe(bool enabled) async {
    await _autoLoginService.setRememberMe(enabled);
    state = state.copyWith(isRememberMeEnabled: enabled);
  }

  /// 자동 로그인 설정
  Future<void> setAutoLoginEnabled(bool enabled) async {
    await _autoLoginService.setAutoLoginEnabled(enabled);
    state = state.copyWith(isAutoLoginEnabled: enabled);
  }

  /// 로그인 성공 시 설정 저장
  Future<void> onLoginSuccess({
    required User user,
    required bool rememberMe,
  }) async {
    await _autoLoginService.onLoginSuccess(user: user, rememberMe: rememberMe);
    await _updateStatus();
  }

  /// 로그아웃 시 설정 정리
  Future<void> onLogout() async {
    await _autoLoginService.onLogout();
    await _updateStatus();
  }

  /// 상태 업데이트
  Future<void> _updateStatus() async {
    try {
      final status = await _autoLoginService.getAutoLoginStatus();
      state = state.copyWith(status: status);
    } catch (e) {
      // 상태 업데이트 실패는 치명적이지 않음
    }
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _autoLoginSubscription?.cancel();
    super.dispose();
  }
}
