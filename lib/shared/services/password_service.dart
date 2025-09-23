import 'dart:math';

import 'package:bcrypt/bcrypt.dart';

/// 비밀번호 해싱 및 검증 서비스
class PasswordService {
  /// 비밀번호 해싱 (bcrypt 사용)
  static String hashPassword(String password) {
    try {
      // bcrypt를 사용한 안전한 해싱
      final salt = BCrypt.gensalt();
      return BCrypt.hashpw(password, salt);
    } catch (e) {
      throw Exception('비밀번호 해싱 중 오류가 발생했습니다: $e');
    }
  }

  /// 비밀번호 검증 (bcrypt 사용)
  static bool verifyPassword(String password, String hashedPassword) {
    try {
      return BCrypt.checkpw(password, hashedPassword);
    } catch (e) {
      throw Exception('비밀번호 검증 중 오류가 발생했습니다: $e');
    }
  }

  /// 비밀번호 강도 검증
  static PasswordStrengthResult validatePasswordStrength(String password) {
    final issues = <String>[];
    int score = 0;

    // 길이 검증
    if (password.length < 8) {
      issues.add('비밀번호는 최소 8자 이상이어야 합니다.');
    } else if (password.length >= 12) {
      score += 2;
    } else {
      score += 1;
    }

    // 대문자 포함 검증
    if (!password.contains(RegExp(r'[A-Z]'))) {
      issues.add('대문자를 포함해야 합니다.');
    } else {
      score += 1;
    }

    // 소문자 포함 검증
    if (!password.contains(RegExp(r'[a-z]'))) {
      issues.add('소문자를 포함해야 합니다.');
    } else {
      score += 1;
    }

    // 숫자 포함 검증
    if (!password.contains(RegExp(r'[0-9]'))) {
      issues.add('숫자를 포함해야 합니다.');
    } else {
      score += 1;
    }

    // 특수문자 포함 검증
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      issues.add('특수문자를 포함해야 합니다.');
    } else {
      score += 1;
    }

    // 연속된 문자 검증
    if (_hasConsecutiveCharacters(password)) {
      issues.add('연속된 문자는 피해주세요.');
      score -= 1;
    }

    // 반복 문자 검증
    if (_hasRepeatedCharacters(password)) {
      issues.add('반복된 문자는 피해주세요.');
      score -= 1;
    }

    // 일반적인 패턴 검증
    if (_hasCommonPatterns(password)) {
      issues.add('일반적인 패턴은 피해주세요.');
      score -= 1;
    }

    // 점수 기반 강도 결정
    PasswordStrength strength;
    if (score >= 6 && issues.isEmpty) {
      strength = PasswordStrength.strong;
    } else if (score >= 4) {
      strength = PasswordStrength.medium;
    } else if (score >= 2) {
      strength = PasswordStrength.weak;
    } else {
      strength = PasswordStrength.veryWeak;
    }

    return PasswordStrengthResult(
      strength: strength,
      score: score,
      issues: issues,
      isValid: issues.isEmpty,
    );
  }

  /// 연속된 문자 확인
  static bool _hasConsecutiveCharacters(String password) {
    for (int i = 0; i < password.length - 2; i++) {
      final char1 = password.codeUnitAt(i);
      final char2 = password.codeUnitAt(i + 1);
      final char3 = password.codeUnitAt(i + 2);

      if ((char2 == char1 + 1 && char3 == char2 + 1) ||
          (char2 == char1 - 1 && char3 == char2 - 1)) {
        return true;
      }
    }
    return false;
  }

  /// 반복된 문자 확인
  static bool _hasRepeatedCharacters(String password) {
    for (int i = 0; i < password.length - 2; i++) {
      if (password[i] == password[i + 1] &&
          password[i + 1] == password[i + 2]) {
        return true;
      }
    }
    return false;
  }

  /// 일반적인 패턴 확인
  static bool _hasCommonPatterns(String password) {
    final commonPatterns = [
      '123',
      'abc',
      'qwe',
      'asd',
      'zxc',
      'password',
      'admin',
      'user',
      'test',
      'qwerty',
      'asdfgh',
      'zxcvbn',
    ];

    final lowerPassword = password.toLowerCase();
    return commonPatterns.any((pattern) => lowerPassword.contains(pattern));
  }

  /// 비밀번호 힌트 생성
  static String generatePasswordHint(String password) {
    if (password.isEmpty) return '';

    final hint = StringBuffer();

    // 첫 글자와 마지막 글자 표시
    hint.write(password[0]);
    hint.write('*' * (password.length - 2));
    if (password.length > 1) {
      hint.write(password[password.length - 1]);
    }

    return hint.toString();
  }

  /// 안전한 비밀번호 생성
  static String generateSecurePassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
    bool excludeSimilar = true,
  }) {
    final random = Random.secure();
    final buffer = StringBuffer();

    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String charset = '';
    if (includeLowercase) charset += lowercase;
    if (includeUppercase) charset += uppercase;
    if (includeNumbers) charset += numbers;
    if (includeSymbols) charset += symbols;

    if (charset.isEmpty) {
      throw Exception('최소 하나의 문자 세트를 선택해야 합니다.');
    }

    // 비밀번호 생성
    for (int i = 0; i < length; i++) {
      buffer.write(charset[random.nextInt(charset.length)]);
    }

    final generatedPassword = buffer.toString();

    // 생성된 비밀번호가 요구사항을 만족하는지 확인
    final validation = validatePasswordStrength(generatedPassword);
    if (!validation.isValid) {
      // 요구사항을 만족하지 않으면 재생성
      return generateSecurePassword(
        length: length,
        includeUppercase: includeUppercase,
        includeLowercase: includeLowercase,
        includeNumbers: includeNumbers,
        includeSymbols: includeSymbols,
        excludeSimilar: excludeSimilar,
      );
    }

    return generatedPassword;
  }

  /// 비밀번호 변경 검증
  static PasswordChangeResult validatePasswordChange({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    String? currentHashedPassword,
  }) {
    final issues = <String>[];

    // 새 비밀번호와 확인 비밀번호 일치 검증
    if (newPassword != confirmPassword) {
      issues.add('새 비밀번호와 확인 비밀번호가 일치하지 않습니다.');
    }

    // 현재 비밀번호와 새 비밀번호 동일성 검증
    if (currentPassword == newPassword) {
      issues.add('새 비밀번호는 현재 비밀번호와 달라야 합니다.');
    }

    // 현재 비밀번호 검증 (해시가 제공된 경우)
    if (currentHashedPassword != null) {
      if (!verifyPassword(currentPassword, currentHashedPassword)) {
        issues.add('현재 비밀번호가 올바르지 않습니다.');
      }
    }

    // 새 비밀번호 강도 검증
    final strengthResult = validatePasswordStrength(newPassword);
    if (!strengthResult.isValid) {
      issues.addAll(strengthResult.issues);
    }

    return PasswordChangeResult(
      isValid: issues.isEmpty,
      issues: issues,
      strength: strengthResult.strength,
    );
  }

  /// 비밀번호 복잡도 점수 계산
  static int calculateComplexityScore(String password) {
    int score = 0;

    // 길이 점수
    if (password.length >= 8) score += 1;
    if (password.length >= 12) score += 1;
    if (password.length >= 16) score += 1;

    // 문자 종류 점수
    if (password.contains(RegExp(r'[a-z]'))) score += 1;
    if (password.contains(RegExp(r'[A-Z]'))) score += 1;
    if (password.contains(RegExp(r'[0-9]'))) score += 1;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 1;

    // 엔트로피 기반 점수
    final entropy = _calculateEntropy(password);
    if (entropy >= 4.0) score += 1;
    if (entropy >= 5.0) score += 1;

    return score;
  }

  /// 엔트로피 계산
  static double _calculateEntropy(String password) {
    final charCounts = <String, int>{};
    for (final char in password.split('')) {
      charCounts[char] = (charCounts[char] ?? 0) + 1;
    }

    double entropy = 0.0;
    for (final count in charCounts.values) {
      final probability = count / password.length;
      entropy -= probability * (log(probability) / ln2);
    }

    return entropy;
  }
}

/// 비밀번호 강도 열거형
enum PasswordStrength { veryWeak, weak, medium, strong }

/// 비밀번호 강도 검증 결과
class PasswordStrengthResult {
  final PasswordStrength strength;
  final int score;
  final List<String> issues;
  final bool isValid;

  const PasswordStrengthResult({
    required this.strength,
    required this.score,
    required this.issues,
    required this.isValid,
  });

  String get strengthText {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return '매우 약함';
      case PasswordStrength.weak:
        return '약함';
      case PasswordStrength.medium:
        return '보통';
      case PasswordStrength.strong:
        return '강함';
    }
  }

  String get strengthColor {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return '#FF0000'; // 빨간색
      case PasswordStrength.weak:
        return '#FFA500'; // 주황색
      case PasswordStrength.medium:
        return '#FFFF00'; // 노란색
      case PasswordStrength.strong:
        return '#00FF00'; // 초록색
    }
  }
}

/// 비밀번호 변경 검증 결과
class PasswordChangeResult {
  final bool isValid;
  final List<String> issues;
  final PasswordStrength strength;

  const PasswordChangeResult({
    required this.isValid,
    required this.issues,
    required this.strength,
  });
}
