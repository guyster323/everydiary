import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_token.dart';
import '../models/user.dart';
import 'token_blacklist_service.dart';

/// JWT 토큰 관리 서비스
class JwtService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  // JWT 설정
  static const String _secretKey = 'your-secret-key-here'; // 실제 환경에서는 환경변수로 관리
  static const Duration _accessTokenExpiry = Duration(hours: 1);
  static const Duration _refreshTokenExpiry = Duration(days: 30);

  /// 액세스 토큰 생성
  static String generateAccessToken(User user) {
    final jwt = JWT({
      'sub': user.id.toString(),
      'email': user.email,
      'name': user.name,
      'roles': user.roles,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp':
          DateTime.now().add(_accessTokenExpiry).millisecondsSinceEpoch ~/ 1000,
      'jti': _generateJti(),
    });

    return jwt.sign(SecretKey(_secretKey));
  }

  /// 리프레시 토큰 생성
  static String generateRefreshToken(String userId) {
    final jwt = JWT({
      'sub': userId,
      'type': 'refresh',
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp':
          DateTime.now().add(_refreshTokenExpiry).millisecondsSinceEpoch ~/
          1000,
      'jti': _generateJti(),
    });

    return jwt.sign(SecretKey(_secretKey));
  }

  /// JWT ID 생성
  static String _generateJti() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// 토큰 검증
  static Future<bool> verifyToken(String token) async {
    try {
      // 블랙리스트 확인
      if (await TokenBlacklistService.isTokenBlacklisted(token)) {
        return false;
      }

      // JWT 서명 검증
      JWT.verify(token, SecretKey(_secretKey));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 토큰에서 페이로드 추출
  static TokenPayload? getTokenPayload(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secretKey));
      final payload = jwt.payload;

      return TokenPayload(
        userId: payload['sub'] as String,
        email: payload['email'] as String,
        roles: (payload['roles'] as List<dynamic>?)?.cast<String>() ?? [],
        iat: payload['iat'] as int,
        exp: payload['exp'] as int,
        jti: payload['jti'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  /// 토큰 만료 확인
  static bool isTokenExpired(String token) {
    try {
      final payload = getTokenPayload(token);
      if (payload == null) return true;

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return payload.exp < now;
    } catch (e) {
      return true;
    }
  }

  /// 토큰 저장
  static Future<void> saveTokens(AuthToken tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, tokens.accessToken);
    await prefs.setString(_refreshTokenKey, tokens.refreshToken);
    await prefs.setString(_tokenExpiryKey, tokens.expiresAt.toIso8601String());
  }

  /// 액세스 토큰 가져오기
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// 리프레시 토큰 가져오기
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// 토큰 만료 시간 가져오기
  static Future<DateTime?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString(_tokenExpiryKey);
    if (expiryString != null) {
      return DateTime.parse(expiryString);
    }
    return null;
  }

  /// 모든 토큰 삭제
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
  }

  /// 토큰이 유효한지 확인
  static Future<bool> hasValidToken() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return false;

    return await verifyToken(accessToken) && !isTokenExpired(accessToken);
  }

  /// 토큰 갱신이 필요한지 확인
  static Future<bool> needsTokenRefresh() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return false;

    // 토큰이 유효하지 않으면 갱신 필요
    if (!await verifyToken(accessToken) || isTokenExpired(accessToken)) {
      return true;
    }

    // 토큰이 만료 5분 전이면 갱신 필요
    final expiry = await getTokenExpiry();
    if (expiry != null) {
      final timeUntilExpiry = expiry.difference(DateTime.now());
      return timeUntilExpiry.inMinutes <= 5;
    }

    return false;
  }

  /// 해시 생성 (비밀번호 해싱용) - bcrypt 사용 권장
  @Deprecated('Use PasswordService.hashPassword() instead')
  static String generateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 솔트 생성
  @Deprecated('Use PasswordService.hashPassword() instead')
  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// 솔트와 함께 해시 생성
  @Deprecated('Use PasswordService.hashPassword() instead')
  static String generateSaltedHash(String password, String salt) {
    return generateHash(password + salt);
  }
}
