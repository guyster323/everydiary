import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 PIN 잠금을 관리하는 서비스.
class PinLockService {
  PinLockService()
      : _secureStorage = const FlutterSecureStorage(),
        _random = Random.secure();

  final FlutterSecureStorage _secureStorage;
  final Random _random;

  static const String _pinHashKey = 'pin_lock.hash';
  static const String _pinSaltKey = 'pin_lock.salt';
  static const String _attemptCountKey = 'pin_lock.attempt_count';
  static const String _lockUntilKey = 'pin_lock.lock_until';
  static const String _lastUnlockedKey = 'pin_lock.last_unlocked';

  static const int _maxAttempts = 5;
  static const Duration _lockDuration = Duration(minutes: 30);

  /// PIN이 설정되어 있는지 여부를 반환합니다.
  Future<bool> hasPin() async {
    final hash = await _secureStorage.read(key: _pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  /// PIN을 설정합니다. 기존 PIN은 덮어씁니다.
  Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);

    await _secureStorage.write(key: _pinSaltKey, value: salt);
    await _secureStorage.write(key: _pinHashKey, value: hash);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_attemptCountKey);
    await prefs.remove(_lockUntilKey);
    await prefs.setInt(_lastUnlockedKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// PIN을 제거합니다.
  Future<void> clearPin() async {
    await _secureStorage.delete(key: _pinHashKey);
    await _secureStorage.delete(key: _pinSaltKey);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_attemptCountKey);
    await prefs.remove(_lockUntilKey);
    await prefs.remove(_lastUnlockedKey);
  }

  /// 남은 재시도 횟수를 반환합니다.
  Future<int> remainingAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt(_attemptCountKey) ?? 0;
    return _maxAttempts - attempts;
  }

  /// 현재 잠금이 해제 가능한 상태인지 확인합니다.
  Future<bool> isLockedOut() async {
    final prefs = await SharedPreferences.getInstance();
    final lockUntil = prefs.getInt(_lockUntilKey);
    if (lockUntil == null) {
      return false;
    }

    final lockUntilTime = DateTime.fromMillisecondsSinceEpoch(lockUntil);
    if (DateTime.now().isAfter(lockUntilTime)) {
      await prefs.remove(_lockUntilKey);
      await prefs.remove(_attemptCountKey);
      return false;
    }
    return true;
  }

  /// 잠금 해제 가능 시각을 반환합니다.
  Future<DateTime?> lockExpiresAt() async {
    final prefs = await SharedPreferences.getInstance();
    final lockUntil = prefs.getInt(_lockUntilKey);
    if (lockUntil == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(lockUntil);
  }

  /// PIN을 검증하고 성공 시 재시도 횟수를 초기화합니다.
  Future<bool> verifyPin(String pin) async {
    if (await isLockedOut()) {
      return false;
    }

    final salt = await _secureStorage.read(key: _pinSaltKey);
    final storedHash = await _secureStorage.read(key: _pinHashKey);
    if (salt == null || storedHash == null) {
      return false;
    }

    final computedHash = _hashPin(pin, salt);
    final matches = _safeEquals(storedHash, computedHash);

    final prefs = await SharedPreferences.getInstance();

    if (matches) {
      await prefs.remove(_attemptCountKey);
      await prefs.remove(_lockUntilKey);
      await prefs.setInt(
        _lastUnlockedKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      return true;
    }

    final attempts = (prefs.getInt(_attemptCountKey) ?? 0) + 1;
    await prefs.setInt(_attemptCountKey, attempts);

    if (attempts >= _maxAttempts) {
      final lockUntil = DateTime.now().add(_lockDuration);
      await prefs.setInt(_lockUntilKey, lockUntil.millisecondsSinceEpoch);
      await prefs.remove(_attemptCountKey);
    }

    return false;
  }

  /// 마지막으로 잠금이 해제된 시각을 반환합니다.
  Future<DateTime?> lastUnlockedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastUnlockedKey);
    if (timestamp == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// 수동으로 마지막 잠금 해제 시각을 갱신합니다.
  Future<void> markUnlockedNow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastUnlockedKey, DateTime.now().millisecondsSinceEpoch);
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }

  String _generateSalt([int length = 16]) {
    final bytes = List<int>.generate(length, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  bool _safeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}

