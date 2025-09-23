import 'package:everydiary/shared/services/password_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_providers.freezed.dart';

/// 비밀번호 강도 검증 상태
@freezed
class PasswordValidationState with _$PasswordValidationState {
  const factory PasswordValidationState({
    @Default('') String password,
    @Default(PasswordStrength.veryWeak) PasswordStrength strength,
    @Default(0) int score,
    @Default([]) List<String> issues,
    @Default(false) bool isValid,
    @Default(false) bool isVisible,
  }) = _PasswordValidationState;

  const PasswordValidationState._();

  /// 비밀번호 강도 텍스트
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

  /// 비밀번호 강도 색상
  Color get strengthColor {
    switch (strength) {
      case PasswordStrength.veryWeak:
        return Colors.red;
      case PasswordStrength.weak:
        return Colors.orange;
      case PasswordStrength.medium:
        return Colors.yellow;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }
}

/// 비밀번호 검증 상태 관리 Provider
final passwordValidationProvider =
    StateNotifierProvider<PasswordValidationNotifier, PasswordValidationState>((
      ref,
    ) {
      return PasswordValidationNotifier();
    });

/// 비밀번호 검증 상태 관리 Notifier
class PasswordValidationNotifier
    extends StateNotifier<PasswordValidationState> {
  PasswordValidationNotifier() : super(const PasswordValidationState());

  /// 비밀번호 업데이트 및 검증
  void updatePassword(String password) {
    final result = PasswordService.validatePasswordStrength(password);

    state = state.copyWith(
      password: password,
      strength: result.strength,
      score: result.score,
      issues: result.issues,
      isValid: result.isValid,
    );
  }

  /// 비밀번호 표시/숨김 토글
  void toggleVisibility() {
    state = state.copyWith(isVisible: !state.isVisible);
  }

  /// 비밀번호 초기화
  void clearPassword() {
    state = state.copyWith(
      password: '',
      strength: PasswordStrength.veryWeak,
      score: 0,
      issues: [],
      isValid: false,
    );
  }

  /// 비밀번호 힌트 생성
  String getPasswordHint() {
    return PasswordService.generatePasswordHint(state.password);
  }

  /// 안전한 비밀번호 생성
  String generateSecurePassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    final generatedPassword = PasswordService.generateSecurePassword(
      length: length,
      includeUppercase: includeUppercase,
      includeLowercase: includeLowercase,
      includeNumbers: includeNumbers,
      includeSymbols: includeSymbols,
    );

    updatePassword(generatedPassword);
    return generatedPassword;
  }
}

/// 비밀번호 변경 상태
@freezed
class PasswordChangeState with _$PasswordChangeState {
  const factory PasswordChangeState({
    @Default('') String currentPassword,
    @Default('') String newPassword,
    @Default('') String confirmPassword,
    @Default(false) bool isCurrentPasswordVisible,
    @Default(false) bool isNewPasswordVisible,
    @Default(false) bool isConfirmPasswordVisible,
    @Default(false) bool isLoading,
    String? error,
    PasswordChangeResult? validationResult,
  }) = _PasswordChangeState;
}

/// 비밀번호 변경 상태 관리 Provider
final passwordChangeProvider =
    StateNotifierProvider<PasswordChangeNotifier, PasswordChangeState>((ref) {
      return PasswordChangeNotifier();
    });

/// 비밀번호 변경 상태 관리 Notifier
class PasswordChangeNotifier extends StateNotifier<PasswordChangeState> {
  PasswordChangeNotifier() : super(const PasswordChangeState());

  /// 현재 비밀번호 업데이트
  void updateCurrentPassword(String password) {
    state = state.copyWith(currentPassword: password);
    _validatePasswords();
  }

  /// 새 비밀번호 업데이트
  void updateNewPassword(String password) {
    state = state.copyWith(newPassword: password);
    _validatePasswords();
  }

  /// 확인 비밀번호 업데이트
  void updateConfirmPassword(String password) {
    state = state.copyWith(confirmPassword: password);
    _validatePasswords();
  }

  /// 현재 비밀번호 표시/숨김 토글
  void toggleCurrentPasswordVisibility() {
    state = state.copyWith(
      isCurrentPasswordVisible: !state.isCurrentPasswordVisible,
    );
  }

  /// 새 비밀번호 표시/숨김 토글
  void toggleNewPasswordVisibility() {
    state = state.copyWith(isNewPasswordVisible: !state.isNewPasswordVisible);
  }

  /// 확인 비밀번호 표시/숨김 토글
  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      isConfirmPasswordVisible: !state.isConfirmPasswordVisible,
    );
  }

  /// 비밀번호 변경 검증
  void _validatePasswords() {
    if (state.newPassword.isNotEmpty && state.confirmPassword.isNotEmpty) {
      final result = PasswordService.validatePasswordChange(
        currentPassword: state.currentPassword,
        newPassword: state.newPassword,
        confirmPassword: state.confirmPassword,
      );

      state = state.copyWith(validationResult: result);
    }
  }

  /// 로딩 상태 설정
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// 에러 설정
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 모든 필드 초기화
  void clearAll() {
    state = const PasswordChangeState();
  }

  /// 안전한 새 비밀번호 생성
  void generateNewPassword() {
    final generatedPassword = PasswordService.generateSecurePassword();
    updateNewPassword(generatedPassword);
    updateConfirmPassword(generatedPassword);
  }
}

/// 비밀번호 재설정 상태
@freezed
class PasswordResetState with _$PasswordResetState {
  const factory PasswordResetState({
    @Default('') String token,
    @Default('') String newPassword,
    @Default('') String confirmPassword,
    @Default(false) bool isNewPasswordVisible,
    @Default(false) bool isConfirmPasswordVisible,
    @Default(false) bool isLoading,
    String? error,
    PasswordChangeResult? validationResult,
  }) = _PasswordResetState;
}

/// 비밀번호 재설정 상태 관리 Provider
final passwordResetProvider =
    StateNotifierProvider<PasswordResetNotifier, PasswordResetState>((ref) {
      return PasswordResetNotifier();
    });

/// 비밀번호 재설정 상태 관리 Notifier
class PasswordResetNotifier extends StateNotifier<PasswordResetState> {
  PasswordResetNotifier() : super(const PasswordResetState());

  /// 토큰 설정
  void setToken(String token) {
    state = state.copyWith(token: token);
  }

  /// 새 비밀번호 업데이트
  void updateNewPassword(String password) {
    state = state.copyWith(newPassword: password);
    _validatePasswords();
  }

  /// 확인 비밀번호 업데이트
  void updateConfirmPassword(String password) {
    state = state.copyWith(confirmPassword: password);
    _validatePasswords();
  }

  /// 새 비밀번호 표시/숨김 토글
  void toggleNewPasswordVisibility() {
    state = state.copyWith(isNewPasswordVisible: !state.isNewPasswordVisible);
  }

  /// 확인 비밀번호 표시/숨김 토글
  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      isConfirmPasswordVisible: !state.isConfirmPasswordVisible,
    );
  }

  /// 비밀번호 재설정 검증
  void _validatePasswords() {
    if (state.newPassword.isNotEmpty && state.confirmPassword.isNotEmpty) {
      final result = PasswordService.validatePasswordChange(
        currentPassword: '', // 재설정 시에는 현재 비밀번호 불필요
        newPassword: state.newPassword,
        confirmPassword: state.confirmPassword,
      );

      state = state.copyWith(validationResult: result);
    }
  }

  /// 로딩 상태 설정
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// 에러 설정
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 모든 필드 초기화
  void clearAll() {
    state = const PasswordResetState();
  }

  /// 안전한 새 비밀번호 생성
  void generateNewPassword() {
    final generatedPassword = PasswordService.generateSecurePassword();
    updateNewPassword(generatedPassword);
    updateConfirmPassword(generatedPassword);
  }
}

/// 비밀번호 강도 Provider
final passwordStrengthProvider =
    Provider.family<PasswordStrengthResult, String>((ref, password) {
      return PasswordService.validatePasswordStrength(password);
    });

/// 비밀번호 복잡도 점수 Provider
final passwordComplexityProvider = Provider.family<int, String>((
  ref,
  password,
) {
  return PasswordService.calculateComplexityScore(password);
});
