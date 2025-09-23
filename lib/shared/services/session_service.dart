import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_token.dart';
import '../models/user.dart';
import 'jwt_service.dart';

/// 세션 관리 서비스
class SessionService {
  static const String _sessionKey = 'user_session';
  static const String _lastActivityKey = 'last_activity';
  static const String _sessionTimeoutKey = 'session_timeout';
  static const String _loginAttemptsKey = 'login_attempts';
  static const String _lockoutUntilKey = 'lockout_until';

  // 세션 타임아웃 (30분)
  static const Duration _sessionTimeout = Duration(minutes: 30);
  // 최대 로그인 시도 횟수
  static const int _maxLoginAttempts = 5;
  // 계정 잠금 시간 (15분)
  static const Duration _lockoutDuration = Duration(minutes: 15);

  static SessionService? _instance;
  static SessionService get instance => _instance ??= SessionService._();

  SessionService._();

  Timer? _sessionTimer;
  StreamController<SessionEvent>? _sessionController;

  /// 세션 이벤트 스트림
  Stream<SessionEvent> get sessionStream {
    _sessionController ??= StreamController<SessionEvent>.broadcast();
    return _sessionController!.stream;
  }

  /// 세션 초기화
  Future<void> initialize() async {
    await _checkSessionValidity();
    _startSessionMonitoring();
  }

  /// 세션 생성
  Future<void> createSession(User user, AuthToken tokens) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // 사용자 세션 정보 저장
    final sessionData = {
      'user': user.toJson(),
      'tokens': tokens.toJson(),
      'createdAt': now.toIso8601String(),
      'lastActivity': now.toIso8601String(),
    };

    await prefs.setString(_sessionKey, jsonEncode(sessionData));
    await prefs.setString(_lastActivityKey, now.toIso8601String());
    await prefs.setInt(_sessionTimeoutKey, _sessionTimeout.inMilliseconds);

    // 로그인 시도 횟수 초기화
    await prefs.remove(_loginAttemptsKey);
    await prefs.remove(_lockoutUntilKey);

    _sessionController?.add(SessionEvent.sessionCreated(user));
    _startSessionTimer();
  }

  /// 세션 갱신
  Future<void> refreshSession(AuthToken newTokens) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = await getSessionData();

    if (sessionData != null) {
      sessionData['tokens'] = newTokens.toJson();
      sessionData['lastActivity'] = DateTime.now().toIso8601String();

      await prefs.setString(_sessionKey, jsonEncode(sessionData));
      await prefs.setString(_lastActivityKey, DateTime.now().toIso8601String());

      _sessionController?.add(SessionEvent.sessionRefreshed());
      _startSessionTimer();
    }
  }

  /// 세션 업데이트 (사용자 정보 변경 시)
  Future<void> updateSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = await getSessionData();

    if (sessionData != null) {
      sessionData['user'] = user.toJson();
      sessionData['lastActivity'] = DateTime.now().toIso8601String();

      await prefs.setString(_sessionKey, jsonEncode(sessionData));
      await prefs.setString(_lastActivityKey, DateTime.now().toIso8601String());

      _sessionController?.add(SessionEvent.sessionUpdated(user));
    }
  }

  /// 세션 종료
  Future<void> endSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_sessionKey);
    await prefs.remove(_lastActivityKey);
    await prefs.remove(_sessionTimeoutKey);

    _stopSessionTimer();
    _sessionController?.add(SessionEvent.sessionEnded());
  }

  /// 세션 데이터 가져오기
  Future<Map<String, dynamic>?> getSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionString = prefs.getString(_sessionKey);

    if (sessionString != null) {
      try {
        return jsonDecode(sessionString) as Map<String, dynamic>;
      } catch (e) {
        // 잘못된 세션 데이터 삭제
        await prefs.remove(_sessionKey);
        return null;
      }
    }

    return null;
  }

  /// 현재 사용자 가져오기
  Future<User?> getCurrentUser() async {
    final sessionData = await getSessionData();

    if (sessionData != null && sessionData['user'] != null) {
      try {
        return User.fromJson(sessionData['user'] as Map<String, dynamic>);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// 세션 유효성 확인
  Future<bool> isSessionValid() async {
    final sessionData = await getSessionData();

    if (sessionData == null) {
      return false;
    }

    // 토큰 유효성 확인
    final tokens = sessionData['tokens'] as Map<String, dynamic>?;
    if (tokens == null) {
      return false;
    }

    final accessToken = tokens['accessToken'] as String?;
    if (accessToken == null) {
      return false;
    }

    final isValid = await JwtService.verifyToken(accessToken);
    if (!isValid) {
      return false;
    }

    // 세션 타임아웃 확인
    final lastActivityString = sessionData['lastActivity'] as String?;
    if (lastActivityString != null) {
      final lastActivity = DateTime.parse(lastActivityString);
      final now = DateTime.now();

      if (now.difference(lastActivity) > _sessionTimeout) {
        await endSession();
        return false;
      }
    }

    return true;
  }

  /// 활동 기록 업데이트
  Future<void> updateActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    await prefs.setString(_lastActivityKey, now.toIso8601String());

    // 세션 데이터의 마지막 활동 시간도 업데이트
    final sessionData = await getSessionData();
    if (sessionData != null) {
      sessionData['lastActivity'] = now.toIso8601String();
      await prefs.setString(_sessionKey, jsonEncode(sessionData));
    }
  }

  /// 로그인 시도 기록
  Future<void> recordLoginAttempt(String email, bool success) async {
    final prefs = await SharedPreferences.getInstance();

    if (success) {
      // 성공 시 시도 횟수 초기화
      await prefs.remove(_loginAttemptsKey);
      await prefs.remove(_lockoutUntilKey);
    } else {
      // 실패 시 시도 횟수 증가
      final attempts = prefs.getInt(_loginAttemptsKey) ?? 0;
      final newAttempts = attempts + 1;

      await prefs.setInt(_loginAttemptsKey, newAttempts);

      // 최대 시도 횟수 초과 시 계정 잠금
      if (newAttempts >= _maxLoginAttempts) {
        final lockoutUntil = DateTime.now().add(_lockoutDuration);
        await prefs.setString(_lockoutUntilKey, lockoutUntil.toIso8601String());

        _sessionController?.add(SessionEvent.accountLocked(lockoutUntil));
      }
    }
  }

  /// 계정 잠금 상태 확인
  Future<bool> isAccountLocked() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutUntilString = prefs.getString(_lockoutUntilKey);

    if (lockoutUntilString != null) {
      final lockoutUntil = DateTime.parse(lockoutUntilString);
      final now = DateTime.now();

      if (now.isBefore(lockoutUntil)) {
        return true;
      } else {
        // 잠금 시간 만료 시 잠금 해제
        await prefs.remove(_lockoutUntilKey);
        await prefs.remove(_loginAttemptsKey);
      }
    }

    return false;
  }

  /// 잠금 해제까지 남은 시간
  Future<Duration?> getRemainingLockoutTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutUntilString = prefs.getString(_lockoutUntilKey);

    if (lockoutUntilString != null) {
      final lockoutUntil = DateTime.parse(lockoutUntilString);
      final now = DateTime.now();

      if (now.isBefore(lockoutUntil)) {
        return lockoutUntil.difference(now);
      }
    }

    return null;
  }

  /// 남은 로그인 시도 횟수
  Future<int> getRemainingLoginAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt(_loginAttemptsKey) ?? 0;
    return _maxLoginAttempts - attempts;
  }

  /// 세션 모니터링 시작
  void _startSessionMonitoring() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkSessionValidity();
    });
  }

  /// 세션 타이머 시작
  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(_sessionTimeout, () {
      _sessionController?.add(SessionEvent.sessionTimeout());
    });
  }

  /// 세션 타이머 중지
  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  /// 세션 유효성 확인
  Future<void> _checkSessionValidity() async {
    if (!await isSessionValid()) {
      await endSession();
    }
  }

  /// 세션 통계 정보
  Future<SessionStats> getSessionStats() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = await getSessionData();

    DateTime? createdAt;
    DateTime? lastActivity;
    int loginAttempts = 0;
    bool isLocked = false;
    Duration? lockoutRemaining;

    if (sessionData != null) {
      final createdAtString = sessionData['createdAt'] as String?;
      final lastActivityString = sessionData['lastActivity'] as String?;

      if (createdAtString != null) {
        createdAt = DateTime.parse(createdAtString);
      }
      if (lastActivityString != null) {
        lastActivity = DateTime.parse(lastActivityString);
      }
    }

    loginAttempts = prefs.getInt(_loginAttemptsKey) ?? 0;
    isLocked = await isAccountLocked();
    lockoutRemaining = await getRemainingLockoutTime();

    return SessionStats(
      createdAt: createdAt,
      lastActivity: lastActivity,
      loginAttempts: loginAttempts,
      isLocked: isLocked,
      lockoutRemaining: lockoutRemaining,
      isValid: await isSessionValid(),
    );
  }

  /// 리소스 정리
  void dispose() {
    _sessionTimer?.cancel();
    _sessionController?.close();
    _sessionController = null;
  }
}

/// 세션 이벤트
abstract class SessionEvent {
  const SessionEvent();

  factory SessionEvent.sessionCreated(User user) = SessionCreatedEvent;
  factory SessionEvent.sessionRefreshed() = SessionRefreshedEvent;
  factory SessionEvent.sessionUpdated(User user) = SessionUpdatedEvent;
  factory SessionEvent.sessionEnded() = SessionEndedEvent;
  factory SessionEvent.sessionTimeout() = SessionTimeoutEvent;
  factory SessionEvent.accountLocked(DateTime lockoutUntil) =
      AccountLockedEvent;
}

class SessionCreatedEvent extends SessionEvent {
  final User user;
  const SessionCreatedEvent(this.user);
}

class SessionRefreshedEvent extends SessionEvent {
  const SessionRefreshedEvent();
}

class SessionUpdatedEvent extends SessionEvent {
  final User user;
  const SessionUpdatedEvent(this.user);
}

class SessionEndedEvent extends SessionEvent {
  const SessionEndedEvent();
}

class SessionTimeoutEvent extends SessionEvent {
  const SessionTimeoutEvent();
}

class AccountLockedEvent extends SessionEvent {
  final DateTime lockoutUntil;
  const AccountLockedEvent(this.lockoutUntil);
}

/// 세션 통계 정보
class SessionStats {
  final DateTime? createdAt;
  final DateTime? lastActivity;
  final int loginAttempts;
  final bool isLocked;
  final Duration? lockoutRemaining;
  final bool isValid;

  const SessionStats({
    this.createdAt,
    this.lastActivity,
    required this.loginAttempts,
    required this.isLocked,
    this.lockoutRemaining,
    required this.isValid,
  });

  Duration? get sessionDuration {
    if (createdAt != null && lastActivity != null) {
      return lastActivity!.difference(createdAt!);
    }
    return null;
  }

  Duration? get idleTime {
    if (lastActivity != null) {
      return DateTime.now().difference(lastActivity!);
    }
    return null;
  }
}
