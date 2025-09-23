import 'package:dio/dio.dart';

import '../../core/utils/logger.dart';
import '../models/auth_token.dart';
import 'jwt_service.dart';

/// 인증 미들웨어
class AuthMiddleware extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 인증이 필요한 요청에 토큰 추가
    if (_requiresAuth(options.path)) {
      final accessToken = await JwtService.getAccessToken();

      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    // 보안 헤더 추가
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    options.headers['X-Requested-With'] = 'XMLHttpRequest';

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 에러인 경우 토큰 갱신 시도
    if (err.response?.statusCode == 401 &&
        _requiresAuth(err.requestOptions.path)) {
      try {
        final refreshToken = await JwtService.getRefreshToken();

        if (refreshToken != null) {
          // 토큰 갱신 시도
          final newTokens = await _refreshToken(refreshToken);

          if (newTokens != null) {
            // 새 토큰으로 원래 요청 재시도
            final newRequest = err.requestOptions.copyWith(
              headers: {
                ...err.requestOptions.headers,
                'Authorization': 'Bearer ${newTokens.accessToken}',
              },
            );

            final dio = Dio();
            final response = await dio.fetch<Map<String, dynamic>>(newRequest);
            handler.resolve(response);
            return;
          }
        }
      } catch (e) {
        // 토큰 갱신 실패 시 로그아웃 처리
        await JwtService.clearTokens();
      }
    }

    handler.next(err);
  }

  /// 인증이 필요한 경로인지 확인
  bool _requiresAuth(String path) {
    const publicPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/reset-password',
      '/auth/verify-email/confirm',
      '/auth/reset-password/confirm',
    ];

    return !publicPaths.any((publicPath) => path.startsWith(publicPath));
  }

  /// 토큰 갱신
  Future<dynamic> _refreshToken(String refreshToken) async {
    try {
      final dio = Dio();
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        // 새 토큰 저장
        await JwtService.saveTokens(AuthToken.fromJson(response.data!));
        return response.data;
      }
    } catch (e) {
      // 토큰 갱신 실패
    }

    return null;
  }
}

/// CORS 미들웨어
class CorsMiddleware extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // CORS 헤더 설정
    options.headers['Access-Control-Allow-Origin'] = '*';
    options.headers['Access-Control-Allow-Methods'] =
        'GET, POST, PUT, DELETE, OPTIONS';
    options.headers['Access-Control-Allow-Headers'] =
        'Content-Type, Authorization, X-Requested-With';

    handler.next(options);
  }
}

/// 레이트 리미팅 미들웨어
class RateLimitMiddleware extends Interceptor {
  final Map<String, List<DateTime>> _requestHistory = {};
  final int _maxRequests;
  final Duration _timeWindow;

  RateLimitMiddleware({
    int maxRequests = 100,
    Duration timeWindow = const Duration(minutes: 1),
  }) : _maxRequests = maxRequests,
       _timeWindow = timeWindow;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final clientId = _getClientId(options);
    final now = DateTime.now();

    // 클라이언트별 요청 히스토리 관리
    _requestHistory[clientId] ??= [];
    _requestHistory[clientId]!.removeWhere(
      (timestamp) => now.difference(timestamp) > _timeWindow,
    );

    // 요청 수 제한 확인
    if (_requestHistory[clientId]!.length >= _maxRequests) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Rate limit exceeded',
          type: DioExceptionType.unknown,
        ),
      );
      return;
    }

    // 요청 기록
    _requestHistory[clientId]!.add(now);

    handler.next(options);
  }

  String _getClientId(RequestOptions options) {
    // 실제 환경에서는 IP 주소나 사용자 ID를 사용
    return options.headers['Authorization']?.toString() ?? 'anonymous';
  }
}

/// 로깅 미들웨어
class LoggingMiddleware extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Logger.info('🚀 Request: ${options.method} ${options.uri}');
    if (options.data != null) {
      Logger.info('📤 Request Data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    Logger.info(
      '✅ Response: ${response.statusCode} ${response.requestOptions.uri}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Logger.warning(
      '❌ Error: ${err.response?.statusCode} ${err.requestOptions.uri}',
    );
    Logger.warning('Error Message: ${err.message}');
    handler.next(err);
  }
}
