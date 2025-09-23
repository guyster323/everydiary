import 'package:everydiary/shared/models/auth_token.dart';
import 'package:everydiary/shared/models/user.dart';
import 'package:everydiary/shared/services/auth_service.dart';
import 'package:everydiary/shared/services/auto_login_service.dart';
import 'package:everydiary/shared/services/jwt_service.dart';
import 'package:everydiary/shared/services/logout_service.dart';
import 'package:everydiary/shared/services/token_refresh_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/logger.dart';

part 'auth_providers.freezed.dart';

/// 인증 상태
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    User? user,
    String? error,
    @Default(false) bool isInitialized,
  }) = _AuthState;
}

/// 인증 상태 관리 Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final logoutService = ref.watch(logoutServiceProvider);
  final autoLoginService = ref.watch(autoLoginServiceProvider);
  final tokenRefreshService = ref.watch(tokenRefreshServiceProvider);
  return AuthNotifier(
    authService,
    logoutService,
    autoLoginService,
    tokenRefreshService,
  );
});

/// 인증 상태 관리 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final LogoutService _logoutService;
  final AutoLoginService _autoLoginService;
  final TokenRefreshService _tokenRefreshService;

  AuthNotifier(
    this._authService,
    this._logoutService,
    this._autoLoginService,
    this._tokenRefreshService,
  ) : super(const AuthState()) {
    _initialize();
  }

  /// 초기화
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // 자동 로그인 시도
      final autoLoginSuccess = await _autoLoginService.attemptAutoLogin();

      if (autoLoginSuccess) {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isLoading: false,
          isInitialized: true,
        );

        // 토큰 갱신 서비스 시작
        _tokenRefreshService.startAutoRefresh();
      } else {
        // 자동 로그인 실패 시 기존 토큰 확인
        final hasValidToken = await JwtService.hasValidToken();

        if (hasValidToken) {
          final user = await _authService.getCurrentUser();
          state = state.copyWith(
            isAuthenticated: true,
            user: user,
            isLoading: false,
            isInitialized: true,
          );

          // 토큰 갱신 서비스 시작
          _tokenRefreshService.startAutoRefresh();
        } else {
          state = state.copyWith(
            isAuthenticated: false,
            isLoading: false,
            isInitialized: true,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        error: e.toString(),
        isLoading: false,
        isInitialized: true,
      );
    }
  }

  /// 로그인
  Future<void> login(LoginRequest request, {bool rememberMe = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authResponse = await _authService.login(request);
      final user = User.fromJson(authResponse.user);

      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
        error: null,
      );

      // 자동 로그인 설정 저장
      await _autoLoginService.onLoginSuccess(
        user: user,
        rememberMe: rememberMe,
      );

      // 토큰 갱신 서비스 시작
      _tokenRefreshService.startAutoRefresh();
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 회원가입
  Future<void> register(RegisterRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authResponse = await _authService.register(request);

      state = state.copyWith(
        isAuthenticated: true,
        user: User.fromJson(authResponse.user),
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _logoutService.logoutUser();

      // 자동 로그인 설정 정리
      await _autoLoginService.onLogout();

      // 토큰 갱신 서비스 중지
      _tokenRefreshService.stopAutoRefresh();

      state = state.copyWith(
        isAuthenticated: false,
        user: null,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      // 로그아웃 실패해도 상태는 초기화
      state = state.copyWith(
        isAuthenticated: false,
        user: null,
        isLoading: false,
        error: null,
      );
    }
  }

  /// 토큰 갱신
  Future<void> refreshToken() async {
    try {
      final success = await _tokenRefreshService.refreshToken();

      if (success) {
        // 토큰 갱신 후 사용자 정보 다시 가져오기
        final user = await _authService.getCurrentUser();
        state = state.copyWith(user: user);
      } else {
        // 토큰 갱신 실패 시 로그아웃
        await logout();
      }
    } catch (e) {
      // 토큰 갱신 실패 시 로그아웃
      await logout();
    }
  }

  /// 강제 토큰 갱신
  Future<void> forceRefreshToken() async {
    try {
      final success = await _tokenRefreshService.forceRefreshToken();

      if (success) {
        // 토큰 갱신 후 사용자 정보 다시 가져오기
        final user = await _authService.getCurrentUser();
        state = state.copyWith(user: user);
      }
    } catch (e) {
      // 강제 토큰 갱신 실패는 로그아웃하지 않음
      Logger.warning('강제 토큰 갱신 실패: $e');
    }
  }

  /// 사용자 정보 업데이트
  Future<void> updateUser(User user) async {
    state = state.copyWith(user: user);
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 로딩 상태 설정
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}

/// 현재 사용자 Provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.user;
});

/// 인증 상태 Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isAuthenticated;
});

/// 로딩 상태 Provider
final authLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isLoading;
});

/// 에러 상태 Provider
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.error;
});

/// 초기화 상태 Provider
final authInitializedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isInitialized;
});

/// 사용자 역할 Provider
final userRolesProvider = Provider<List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.roles ?? [];
});

/// 관리자 권한 Provider
final isAdminProvider = Provider<bool>((ref) {
  final roles = ref.watch(userRolesProvider);
  return roles.contains('admin');
});

/// 프리미엄 사용자 Provider
final isPremiumProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isPremium ?? false;
});
