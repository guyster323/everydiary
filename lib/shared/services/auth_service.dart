import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/logger.dart';
import '../models/auth_token.dart';
import '../models/user.dart';
import 'jwt_service.dart';
import 'password_service.dart';
import 'session_service.dart';
import 'token_blacklist_service.dart';

/// 인증 서비스
class AuthService {
  final Dio _dio;
  final SessionService _sessionService;

  AuthService(this._dio) : _sessionService = SessionService.instance;

  /// 회원가입
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      // 비밀번호 확인 검증
      if (request.password != request.confirmPassword) {
        throw Exception('비밀번호가 일치하지 않습니다.');
      }

      // 비밀번호 강도 검증
      _validatePassword(request.password);

      // 이메일 형식 검증
      _validateEmail(request.email);

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(response.data!);

        // 토큰 저장
        await JwtService.saveTokens(authResponse.tokens);

        // User 객체로 변환
        final user = User.fromJson(authResponse.user);

        // 세션 생성
        await _sessionService.createSession(user, authResponse.tokens);

        return AuthResponse(
          tokens: authResponse.tokens,
          user: user.toJson(),
          success: authResponse.success,
          message: authResponse.message,
        );
      } else {
        throw Exception('회원가입에 실패했습니다.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('이미 존재하는 이메일입니다.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('입력 정보를 확인해주세요.');
      } else {
        throw Exception('회원가입 중 오류가 발생했습니다.');
      }
    } catch (e) {
      throw Exception('회원가입 중 오류가 발생했습니다: $e');
    }
  }

  /// 로그인
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      // 계정 잠금 상태 확인
      if (await _sessionService.isAccountLocked()) {
        final remainingTime = await _sessionService.getRemainingLockoutTime();
        throw Exception('계정이 잠겼습니다. ${remainingTime?.inMinutes}분 후 다시 시도해주세요.');
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data!);

        // 토큰 저장
        await JwtService.saveTokens(authResponse.tokens);

        // User 객체로 변환
        final user = User.fromJson(authResponse.user);

        // 세션 생성
        await _sessionService.createSession(user, authResponse.tokens);

        // 로그인 성공 기록
        await _sessionService.recordLoginAttempt(request.email, true);

        return AuthResponse(
          tokens: authResponse.tokens,
          user: user.toJson(),
          success: authResponse.success,
          message: authResponse.message,
        );
      } else {
        // 로그인 실패 기록
        await _sessionService.recordLoginAttempt(request.email, false);
        throw Exception('로그인에 실패했습니다.');
      }
    } on DioException catch (e) {
      // 로그인 실패 기록
      await _sessionService.recordLoginAttempt(request.email, false);

      if (e.response?.statusCode == 401) {
        throw Exception('이메일 또는 비밀번호가 올바르지 않습니다.');
      } else if (e.response?.statusCode == 429) {
        throw Exception('너무 많은 로그인 시도가 있었습니다. 잠시 후 다시 시도해주세요.');
      } else {
        throw Exception('로그인 중 오류가 발생했습니다.');
      }
    } catch (e) {
      // 로그인 실패 기록
      await _sessionService.recordLoginAttempt(request.email, false);
      throw Exception('로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      final accessToken = await JwtService.getAccessToken();
      final refreshToken = await JwtService.getRefreshToken();

      // 서버에 로그아웃 요청
      if (refreshToken != null) {
        try {
          await _dio.post<Map<String, dynamic>>(
            '/auth/logout',
            data: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
          );
        } catch (e) {
          Logger.warning('Logout API call failed: $e');
          // API 호출 실패해도 계속 진행
        }
      }

      // 토큰들을 블랙리스트에 추가
      if (accessToken != null) {
        await TokenBlacklistService.addToBlacklist(accessToken);
      }
      if (refreshToken != null) {
        await TokenBlacklistService.addToBlacklist(refreshToken);
      }
    } catch (e) {
      Logger.warning('Logout token blacklisting failed: $e');
    } finally {
      // 로컬 토큰 삭제
      await JwtService.clearTokens();
      // 세션 종료
      await _sessionService.endSession();
    }
  }

  /// 토큰 갱신
  Future<AuthToken> refreshToken() async {
    try {
      final refreshToken = await JwtService.getRefreshToken();

      if (refreshToken == null) {
        throw Exception('리프레시 토큰이 없습니다.');
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
      );

      if (response.statusCode == 200) {
        final authToken = AuthToken.fromJson(response.data!);

        // 새 토큰 저장
        await JwtService.saveTokens(authToken);

        // 세션 갱신
        await _sessionService.refreshSession(authToken);

        return authToken;
      } else {
        throw Exception('토큰 갱신에 실패했습니다.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // 리프레시 토큰이 만료된 경우 로그아웃
        await JwtService.clearTokens();
        throw Exception('세션이 만료되었습니다. 다시 로그인해주세요.');
      } else {
        throw Exception('토큰 갱신 중 오류가 발생했습니다.');
      }
    } catch (e) {
      throw Exception('토큰 갱신 중 오류가 발생했습니다: $e');
    }
  }

  /// 현재 사용자 정보 가져오기
  Future<User> getCurrentUser() async {
    try {
      final accessToken = await JwtService.getAccessToken();

      if (accessToken == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final response = await _dio.get<Map<String, dynamic>>(
        '/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data!);
      } else {
        throw Exception('사용자 정보를 가져올 수 없습니다.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // 토큰이 만료된 경우 갱신 시도
        try {
          await refreshToken();
          return getCurrentUser(); // 재귀 호출로 다시 시도
        } catch (refreshError) {
          throw Exception('세션이 만료되었습니다. 다시 로그인해주세요.');
        }
      } else {
        throw Exception('사용자 정보를 가져오는 중 오류가 발생했습니다.');
      }
    } catch (e) {
      throw Exception('사용자 정보를 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  /// 비밀번호 변경
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    String? currentHashedPassword,
  }) async {
    try {
      // 비밀번호 변경 검증
      final validationResult = PasswordService.validatePasswordChange(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
        currentHashedPassword: currentHashedPassword,
      );

      if (!validationResult.isValid) {
        throw Exception(validationResult.issues.join(', '));
      }

      final accessToken = await JwtService.getAccessToken();

      if (accessToken == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // 새 비밀번호 해싱
      final hashedNewPassword = PasswordService.hashPassword(newPassword);

      final response = await _dio.put<Map<String, dynamic>>(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': hashedNewPassword,
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode != 200) {
        throw Exception('비밀번호 변경에 실패했습니다.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('현재 비밀번호가 올바르지 않습니다.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('새 비밀번호가 요구사항을 만족하지 않습니다.');
      } else {
        throw Exception('비밀번호 변경 중 오류가 발생했습니다.');
      }
    } catch (e) {
      throw Exception('비밀번호 변경 중 오류가 발생했습니다: $e');
    }
  }

  /// 이메일 인증 요청
  Future<void> requestEmailVerification() async {
    try {
      final accessToken = await JwtService.getAccessToken();

      if (accessToken == null) {
        throw Exception('로그인이 필요합니다.');
      }

      await _dio.post<Map<String, dynamic>>(
        '/auth/verify-email',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } catch (e) {
      throw Exception('이메일 인증 요청 중 오류가 발생했습니다: $e');
    }
  }

  /// 이메일 인증 확인
  Future<void> verifyEmail(String token) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/auth/verify-email/confirm',
        data: {'token': token},
      );
    } catch (e) {
      throw Exception('이메일 인증 중 오류가 발생했습니다: $e');
    }
  }

  /// 비밀번호 재설정 요청
  Future<void> requestPasswordReset(String email) async {
    try {
      _validateEmail(email);

      await _dio.post<Map<String, dynamic>>(
        '/auth/reset-password',
        data: {'email': email},
      );
    } catch (e) {
      throw Exception('비밀번호 재설정 요청 중 오류가 발생했습니다: $e');
    }
  }

  /// 비밀번호 재설정 확인
  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      // 비밀번호 재설정 검증
      final validationResult = PasswordService.validatePasswordChange(
        currentPassword: '', // 재설정 시에는 현재 비밀번호 불필요
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (!validationResult.isValid) {
        throw Exception(validationResult.issues.join(', '));
      }

      // 새 비밀번호 해싱
      final hashedNewPassword = PasswordService.hashPassword(newPassword);

      await _dio.post<Map<String, dynamic>>(
        '/auth/reset-password/confirm',
        data: {'token': token, 'newPassword': hashedNewPassword},
      );
    } catch (e) {
      throw Exception('비밀번호 재설정 중 오류가 발생했습니다: $e');
    }
  }

  /// 비밀번호 강도 검증
  void _validatePassword(String password) {
    final result = PasswordService.validatePasswordStrength(password);
    if (!result.isValid) {
      throw Exception(result.issues.join(', '));
    }
  }

  /// 이메일 형식 검증
  void _validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      throw Exception('올바른 이메일 형식이 아닙니다.');
    }
  }
}

/// AuthService Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final dio = Dio();
  return AuthService(dio);
});
