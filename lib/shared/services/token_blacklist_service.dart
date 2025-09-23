import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/logger.dart';

/// 토큰 블랙리스트 관리 서비스
class TokenBlacklistService {
  static const String _blacklistKey = 'token_blacklist';
  static const String _blacklistExpiryKey = 'blacklist_expiry';

  /// 블랙리스트에 토큰 추가
  static Future<void> addToBlacklist(
    String token, {
    Duration? customExpiry,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 기존 블랙리스트 가져오기
      final blacklistJson = prefs.getString(_blacklistKey) ?? '{}';
      final blacklist = Map<String, dynamic>.from(
        json.decode(blacklistJson) as Map,
      );

      // 토큰의 JTI (JWT ID) 추출
      final jti = _extractJtiFromToken(token);
      if (jti == null) return;

      // 만료 시간 설정 (기본값: 토큰의 실제 만료 시간)
      final expiry = customExpiry ?? const Duration(hours: 1);
      final expiryTime = DateTime.now().add(expiry).millisecondsSinceEpoch;

      // 블랙리스트에 추가
      blacklist[jti] = {
        'token': token,
        'expiresAt': expiryTime,
        'blacklistedAt': DateTime.now().millisecondsSinceEpoch,
      };

      // 저장
      await prefs.setString(_blacklistKey, json.encode(blacklist));

      // 만료 시간 업데이트
      await _updateBlacklistExpiry(prefs, blacklist);
    } catch (e) {
      Logger.warning('토큰 블랙리스트 추가 실패: $e');
    }
  }

  /// 블랙리스트에서 토큰 확인
  static Future<bool> isTokenBlacklisted(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 블랙리스트 가져오기
      final blacklistJson = prefs.getString(_blacklistKey) ?? '{}';
      final blacklist = Map<String, dynamic>.from(
        json.decode(blacklistJson) as Map,
      );

      // 토큰의 JTI 추출
      final jti = _extractJtiFromToken(token);
      if (jti == null) return false;

      // 블랙리스트에 있는지 확인
      if (!blacklist.containsKey(jti)) return false;

      final tokenData = blacklist[jti] as Map<String, dynamic>;
      final expiresAt = tokenData['expiresAt'] as int;

      // 만료된 토큰은 블랙리스트에서 제거
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        blacklist.remove(jti);
        await prefs.setString(_blacklistKey, json.encode(blacklist));
        await _updateBlacklistExpiry(prefs, blacklist);
        return false;
      }

      return true;
    } catch (e) {
      Logger.warning('토큰 블랙리스트 확인 실패: $e');
      return false;
    }
  }

  /// 블랙리스트에서 토큰 제거
  static Future<void> removeFromBlacklist(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 블랙리스트 가져오기
      final blacklistJson = prefs.getString(_blacklistKey) ?? '{}';
      final blacklist = Map<String, dynamic>.from(
        json.decode(blacklistJson) as Map,
      );

      // 토큰의 JTI 추출
      final jti = _extractJtiFromToken(token);
      if (jti == null) return;

      // 블랙리스트에서 제거
      blacklist.remove(jti);

      // 저장
      await prefs.setString(_blacklistKey, json.encode(blacklist));
      await _updateBlacklistExpiry(prefs, blacklist);
    } catch (e) {
      Logger.warning('토큰 블랙리스트 제거 실패: $e');
    }
  }

  /// 만료된 토큰들 정리
  static Future<void> cleanupExpiredTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 블랙리스트 가져오기
      final blacklistJson = prefs.getString(_blacklistKey) ?? '{}';
      final blacklist = Map<String, dynamic>.from(
        json.decode(blacklistJson) as Map,
      );

      final now = DateTime.now().millisecondsSinceEpoch;
      final expiredTokens = <String>[];

      // 만료된 토큰 찾기
      for (final entry in blacklist.entries) {
        final tokenData = entry.value as Map<String, dynamic>;
        final expiresAt = tokenData['expiresAt'] as int;

        if (now > expiresAt) {
          expiredTokens.add(entry.key);
        }
      }

      // 만료된 토큰 제거
      for (final jti in expiredTokens) {
        blacklist.remove(jti);
      }

      // 저장
      await prefs.setString(_blacklistKey, json.encode(blacklist));
      await _updateBlacklistExpiry(prefs, blacklist);

      if (expiredTokens.isNotEmpty) {
        Logger.info('${expiredTokens.length}개의 만료된 토큰을 블랙리스트에서 제거했습니다.');
      }
    } catch (e) {
      Logger.warning('만료된 토큰 정리 실패: $e');
    }
  }

  /// 블랙리스트 전체 초기화
  static Future<void> clearBlacklist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_blacklistKey);
      await prefs.remove(_blacklistExpiryKey);
    } catch (e) {
      Logger.warning('블랙리스트 초기화 실패: $e');
    }
  }

  /// 블랙리스트 통계 정보
  static Future<BlacklistStats> getBlacklistStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 블랙리스트 가져오기
      final blacklistJson = prefs.getString(_blacklistKey) ?? '{}';
      final blacklist = Map<String, dynamic>.from(
        json.decode(blacklistJson) as Map,
      );

      final now = DateTime.now().millisecondsSinceEpoch;
      int activeTokens = 0;
      int expiredTokens = 0;
      DateTime? oldestToken;
      DateTime? newestToken;

      for (final entry in blacklist.entries) {
        final tokenData = entry.value as Map<String, dynamic>;
        final expiresAt = tokenData['expiresAt'] as int;
        final blacklistedAt = tokenData['blacklistedAt'] as int;

        if (now > expiresAt) {
          expiredTokens++;
        } else {
          activeTokens++;
        }

        final blacklistedDate = DateTime.fromMillisecondsSinceEpoch(
          blacklistedAt,
        );
        if (oldestToken == null || blacklistedDate.isBefore(oldestToken)) {
          oldestToken = blacklistedDate;
        }
        if (newestToken == null || blacklistedDate.isAfter(newestToken)) {
          newestToken = blacklistedDate;
        }
      }

      return BlacklistStats(
        totalTokens: blacklist.length,
        activeTokens: activeTokens,
        expiredTokens: expiredTokens,
        oldestToken: oldestToken,
        newestToken: newestToken,
      );
    } catch (e) {
      Logger.warning('블랙리스트 통계 조회 실패: $e');
      return const BlacklistStats(
        totalTokens: 0,
        activeTokens: 0,
        expiredTokens: 0,
        oldestToken: null,
        newestToken: null,
      );
    }
  }

  /// 토큰에서 JTI 추출
  static String? _extractJtiFromToken(String token) {
    try {
      // JWT 토큰 파싱 (header.payload.signature)
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // payload 디코딩
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp) as Map<String, dynamic>;

      return payloadMap['jti'] as String?;
    } catch (e) {
      Logger.warning('JTI 추출 실패: $e');
      return null;
    }
  }

  /// 블랙리스트 만료 시간 업데이트
  static Future<void> _updateBlacklistExpiry(
    SharedPreferences prefs,
    Map<String, dynamic> blacklist,
  ) async {
    if (blacklist.isEmpty) {
      await prefs.remove(_blacklistExpiryKey);
      return;
    }

    // 가장 늦은 만료 시간 찾기
    int latestExpiry = 0;
    for (final entry in blacklist.entries) {
      final tokenData = entry.value as Map<String, dynamic>;
      final expiresAt = tokenData['expiresAt'] as int;
      if (expiresAt > latestExpiry) {
        latestExpiry = expiresAt;
      }
    }

    await prefs.setString(_blacklistExpiryKey, latestExpiry.toString());
  }
}

/// 블랙리스트 통계 정보
class BlacklistStats {
  final int totalTokens;
  final int activeTokens;
  final int expiredTokens;
  final DateTime? oldestToken;
  final DateTime? newestToken;

  const BlacklistStats({
    required this.totalTokens,
    required this.activeTokens,
    required this.expiredTokens,
    this.oldestToken,
    this.newestToken,
  });

  @override
  String toString() {
    return 'BlacklistStats(totalTokens: $totalTokens, activeTokens: $activeTokens, expiredTokens: $expiredTokens, oldestToken: $oldestToken, newestToken: $newestToken)';
  }
}
