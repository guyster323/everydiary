import 'package:shared_preferences/shared_preferences.dart';

/// 로컬 사용자 프로필과 온보딩 상태를 관리하는 서비스.
class AppProfileService {
  AppProfileService();

  static const String _onboardingKey = 'app_profile.onboarding_complete';
  static const String _userNameKey = 'app_profile.user_name';
  static const String _userGenderKey = 'app_profile.user_gender';
  static const String _pinEnabledKey = 'app_profile.pin_enabled';
  static const String _autoLockMinutesKey = 'app_profile.auto_lock_minutes';

  /// 온보딩 완료 여부를 반환합니다.
  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  /// 온보딩 완료 상태와 함께 사용자 이름 및 PIN 설정 여부를 저장합니다.
  Future<void> completeOnboarding({
    required String userName,
    required bool pinEnabled,
    String userGender = 'none',
    int autoLockMinutes = 1,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    await prefs.setString(_userNameKey, userName.trim());
    await prefs.setString(_userGenderKey, userGender);
    await prefs.setBool(_pinEnabledKey, pinEnabled);
    await prefs.setInt(_autoLockMinutesKey, autoLockMinutes);
  }

  /// 사용자 이름을 반환합니다.
  Future<String?> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// 사용자 이름을 업데이트합니다.
  Future<void> updateUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, userName.trim());
  }

  /// 사용자 성별을 반환합니다.
  Future<String> loadUserGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userGenderKey) ?? 'none';
  }

  /// 사용자 성별을 업데이트합니다.
  Future<void> updateUserGender(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userGenderKey, gender);
  }

  /// PIN 사용 여부를 반환합니다.
  Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pinEnabledKey) ?? false;
  }

  /// PIN 사용 여부를 설정합니다.
  Future<void> setPinEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinEnabledKey, enabled);
  }

  /// 자동 잠금 시간을 반환합니다. (분 단위)
  Future<int> getAutoLockMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_autoLockMinutesKey) ?? 1;
  }

  /// 자동 잠금 시간을 설정합니다. (분 단위)
  Future<void> setAutoLockMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoLockMinutesKey, minutes);
  }

  /// 온보딩 상태와 사용자 정보를 초기화합니다.
  Future<void> resetProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userGenderKey);
    await prefs.remove(_pinEnabledKey);
    await prefs.remove(_autoLockMinutesKey);
  }
}
