import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_token.dart';
import '../models/user.dart';
import 'auth_service.dart';
import 'auto_login_service.dart';
import 'jwt_service.dart';
import 'logout_service.dart';
import 'session_service.dart';
import 'token_refresh_service.dart';

/// 통합 인증 관리자
///
/// 모든 인증 관련 서비스를 통합하여 관리하는 중앙 서비스입니다.
///
/// 포함된 서비스:
/// - AuthService: 로그인/회원가입 처리
/// - SessionService: 세션 관리
/// - AutoLoginService: 자동 로그인 처리
/// - TokenRefreshService: 토큰 갱신 처리
/// - LogoutService: 로그아웃 처리
///
/// 사용법:
/// ```dart
/// final authManager = AuthManager.instance;
/// await authManager.initialize();
///
/// // 로그인
/// final result = await authManager.login(
///   email: 'user@example.com',
///   password: 'password',
///   rememberMe: true,
/// );
///
/// // 로그아웃
/// await authManager.logout();
/// ```
///
/// 상태 관리:
/// - AuthState.loading: 인증 처리 중
/// - AuthState.authenticated: 인증됨 (User 객체 포함)
/// - AuthState.unauthenticated: 인증되지 않음
/// - AuthState.error: 오류 발생 (오류 메시지 포함)
class AuthManager {
  static AuthManager? _instance;
  static AuthManager get instance => _instance ??= AuthManager._();

  AuthManager._();

  late final AuthService _authService;
  late final SessionService _sessionService;
  late final AutoLoginService _autoLoginService;
  late final TokenRefreshService _tokenRefreshService;

  // 스트림 컨트롤러
  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>.broadcast();

  /// 인증 상태 스트림
  Stream<AuthState> get authStateStream => _authStateController.stream;

  /// 현재 인증 상태
  AuthState _currentState = const AuthState.unauthenticated();

  AuthState get currentState => _currentState;

  /// 인증 매니저 초기화
  ///
  /// 모든 인증 관련 서비스를 초기화하고 기존 세션을 확인합니다.
  /// 앱 시작 시 반드시 호출해야 합니다.
  ///
  /// Throws: [Exception] 초기화 중 오류 발생 시
  Future<void> initialize() async {
    try {
      // 서비스 인스턴스 초기화
      _authService = AuthService(Dio());
      _sessionService = SessionService.instance;
      final logoutService = LogoutService(_authService);
      _tokenRefreshService = TokenRefreshService(_authService, logoutService);
      _autoLoginService = AutoLoginService(
        _authService,
        _sessionService,
        _tokenRefreshService,
      );

      // 기존 세션 확인
      await _checkExistingSession();
    } catch (e) {
      _updateAuthState(AuthState.error('초기화 중 오류가 발생했습니다: $e'));
    }
  }

  /// 기존 세션 확인
  Future<void> _checkExistingSession() async {
    try {
      final user = await _sessionService.getCurrentUser();
      if (user != null) {
        _updateAuthState(AuthState.authenticated(user));
        return;
      }

      // 자동 로그인 시도
      await _autoLoginService.attemptAutoLogin();
    } catch (e) {
      _updateAuthState(const AuthState.unauthenticated());
    }
  }

  /// 로그인
  Future<AuthResult> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      _updateAuthState(const AuthState.loading('로그인 중...'));

      final result = await _authService.login(
        LoginRequest(
          email: email,
          password: password,
          rememberMe: rememberMe,
        ),
      );

      if (result.success) {
        final user = User.fromJson(result.user);

        // 세션 생성
        await _sessionService.createSession(user, result.tokens);

        // 자동 로그인 설정
        await _autoLoginService.onLoginSuccess(
          user: user,
          rememberMe: rememberMe,
        );

        _updateAuthState(AuthState.authenticated(user));

        return AuthResult.success(user: user, message: result.message);
      } else {
        _updateAuthState(const AuthState.unauthenticated());
        return AuthResult.failure(message: result.message ?? '로그인에 실패했습니다.');
      }
    } catch (e) {
      _updateAuthState(AuthState.error('로그인 중 오류가 발생했습니다: $e'));
      return AuthResult.failure(message: '로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 회원가입
  Future<AuthResult> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
  }) async {
    try {
      _updateAuthState(const AuthState.loading('회원가입 중...'));

      final result = await _authService.register(
        RegisterRequest(
          email: email,
          password: password,
          confirmPassword: confirmPassword,
          displayName: name,
        ),
      );

      if (result.success) {
        final user = User.fromJson(result.user);

        // 세션 생성
        await _sessionService.createSession(user, result.tokens);

        _updateAuthState(AuthState.authenticated(user));

        return AuthResult.success(user: user, message: result.message);
      } else {
        _updateAuthState(const AuthState.unauthenticated());
        return AuthResult.failure(message: result.message ?? '회원가입에 실패했습니다.');
      }
    } catch (e) {
      _updateAuthState(AuthState.error('회원가입 중 오류가 발생했습니다: $e'));
      return AuthResult.failure(message: '회원가입 중 오류가 발생했습니다: $e');
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      _updateAuthState(const AuthState.loading('로그아웃 중...'));

      // 자동 로그인 설정 정리
      await _autoLoginService.onLogout();

      // 세션 정리 (SharedPreferences 직접 사용)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_session');

      // 토큰 정리
      await JwtService.clearTokens();

      _updateAuthState(const AuthState.unauthenticated());
    } catch (e) {
      _updateAuthState(AuthState.error('로그아웃 중 오류가 발생했습니다: $e'));
    }
  }

  /// 토큰 갱신
  Future<bool> refreshToken() async {
    try {
      final success = await _tokenRefreshService.refreshToken();

      if (success) {
        final user = await _sessionService.getCurrentUser();
        if (user != null) {
          _updateAuthState(AuthState.authenticated(user));
        }
      }

      return success;
    } catch (e) {
      _updateAuthState(AuthState.error('토큰 갱신 중 오류가 발생했습니다: $e'));
      return false;
    }
  }

  /// 현재 사용자 정보 가져오기
  Future<User?> getCurrentUser() async {
    return await _sessionService.getCurrentUser();
  }

  /// 인증 상태 업데이트
  void _updateAuthState(AuthState newState) {
    _currentState = newState;
    _authStateController.add(newState);
  }

  /// 리소스 정리
  void dispose() {
    _authStateController.close();
  }
}

/// 인증 상태
sealed class AuthState {
  const AuthState();

  const factory AuthState.unauthenticated() = UnauthenticatedState;
  const factory AuthState.authenticated(User user) = AuthenticatedState;
  const factory AuthState.loading(String message) = LoadingState;
  const factory AuthState.error(String message) = ErrorState;
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class AuthenticatedState extends AuthState {
  final User user;
  const AuthenticatedState(this.user);
}

class LoadingState extends AuthState {
  final String message;
  const LoadingState(this.message);
}

class ErrorState extends AuthState {
  final String message;
  const ErrorState(this.message);
}

/// 인증 결과
class AuthResult {
  final bool success;
  final User? user;
  final String message;

  const AuthResult._({required this.success, this.user, required this.message});

  factory AuthResult.success({User? user, String? message}) {
    return AuthResult._(success: true, user: user, message: message ?? '성공');
  }

  factory AuthResult.failure({required String message}) {
    return AuthResult._(success: false, message: message);
  }
}

/// AuthManager Provider
final authManagerProvider = Provider<AuthManager>((ref) {
  return AuthManager.instance;
});

/// 인증 상태 Provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authManager = ref.watch(authManagerProvider);
  return authManager.authStateStream;
});

/// 현재 사용자 Provider
final currentUserProvider = FutureProvider<User?>((ref) async {
  final authManager = ref.watch(authManagerProvider);
  return await authManager.getCurrentUser();
});
