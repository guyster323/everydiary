import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 로컬 저장소 서비스 클래스
/// Hive와 SharedPreferences를 사용한 설정 및 캐시 데이터 관리
class StorageService {
  static const String _settingsBoxName = 'settings';
  static const String _cacheBoxName = 'cache';
  static const String _userBoxName = 'user';

  // Hive 박스들
  static Box<dynamic>? _settingsBox;
  static Box<dynamic>? _cacheBox;
  static Box<dynamic>? _userBox;

  /// 저장소 초기화
  static Future<void> init() async {
    // Hive 초기화
    await Hive.initFlutter();

    // 박스들 열기
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _cacheBox = await Hive.openBox(_cacheBoxName);
    _userBox = await Hive.openBox(_userBoxName);
  }

  /// 설정 저장소 가져오기
  static Box<dynamic> get settingsBox {
    if (_settingsBox == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _settingsBox!;
  }

  /// 캐시 저장소 가져오기
  static Box<dynamic> get cacheBox {
    if (_cacheBox == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _cacheBox!;
  }

  /// 사용자 저장소 가져오기
  static Box<dynamic> get userBox {
    if (_userBox == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _userBox!;
  }

  // ========== 설정 관련 메서드 ==========

  /// 테마 설정 저장
  static Future<void> setTheme(String theme) async {
    await settingsBox.put('theme', theme);
  }

  /// 테마 설정 가져오기
  static String getTheme() {
    return settingsBox.get('theme', defaultValue: 'system') as String;
  }

  /// 언어 설정 저장
  static Future<void> setLanguage(String language) async {
    await settingsBox.put('language', language);
  }

  /// 언어 설정 가져오기
  static String getLanguage() {
    return settingsBox.get('language', defaultValue: 'ko') as String;
  }

  /// 알림 설정 저장
  static Future<void> setNotificationEnabled(bool enabled) async {
    await settingsBox.put('notification_enabled', enabled);
  }

  /// 알림 설정 가져오기
  static bool getNotificationEnabled() {
    return settingsBox.get('notification_enabled', defaultValue: true) as bool;
  }

  /// 알림 시간 설정 저장
  static Future<void> setNotificationTime(String time) async {
    await settingsBox.put('notification_time', time);
  }

  /// 알림 시간 설정 가져오기
  static String getNotificationTime() {
    return settingsBox.get('notification_time', defaultValue: '21:00')
        as String;
  }

  /// 첫 실행 여부 확인
  static bool isFirstRun() {
    return settingsBox.get('first_run', defaultValue: true) as bool;
  }

  /// 첫 실행 완료 표시
  static Future<void> setFirstRunCompleted() async {
    await settingsBox.put('first_run', false);
  }

  // ========== 캐시 관련 메서드 ==========

  /// 캐시 데이터 저장
  static Future<void> setCacheData(String key, dynamic value) async {
    await cacheBox.put(key, value);
  }

  /// 캐시 데이터 가져오기
  static T? getCacheData<T>(String key) {
    return cacheBox.get(key) as T?;
  }

  /// 캐시 데이터 삭제
  static Future<void> removeCacheData(String key) async {
    await cacheBox.delete(key);
  }

  /// 모든 캐시 데이터 삭제
  static Future<void> clearCache() async {
    await cacheBox.clear();
  }

  // ========== 사용자 관련 메서드 ==========

  /// 사용자 ID 저장
  static Future<void> setUserId(int userId) async {
    await userBox.put('user_id', userId);
  }

  /// 사용자 ID 가져오기
  static int? getUserId() {
    return userBox.get('user_id') as int?;
  }

  /// 사용자 정보 저장
  static Future<void> setUserInfo(Map<String, dynamic> userInfo) async {
    await userBox.put('user_info', userInfo);
  }

  /// 사용자 정보 가져오기
  static Map<String, dynamic>? getUserInfo() {
    return userBox.get('user_info') as Map<String, dynamic>?;
  }

  /// 로그인 상태 저장
  static Future<void> setLoginStatus(bool isLoggedIn) async {
    await userBox.put('is_logged_in', isLoggedIn);
  }

  /// 로그인 상태 가져오기
  static bool getLoginStatus() {
    return userBox.get('is_logged_in', defaultValue: false) as bool;
  }

  // ========== SharedPreferences 관련 메서드 ==========

  /// SharedPreferences 인스턴스 가져오기
  static Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  /// 앱 버전 저장
  static Future<void> setAppVersion(String version) async {
    final prefs = await _prefs;
    await prefs.setString('app_version', version);
  }

  /// 앱 버전 가져오기
  static Future<String?> getAppVersion() async {
    final prefs = await _prefs;
    return prefs.getString('app_version');
  }

  /// 마지막 동기화 시간 저장
  static Future<void> setLastSyncTime(DateTime time) async {
    final prefs = await _prefs;
    await prefs.setString('last_sync_time', time.toIso8601String());
  }

  /// 마지막 동기화 시간 가져오기
  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await _prefs;
    final timeString = prefs.getString('last_sync_time');
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }

  // ========== 정리 메서드 ==========

  /// 모든 저장소 정리
  static Future<void> clearAll() async {
    await settingsBox.clear();
    await cacheBox.clear();
    await userBox.clear();

    final prefs = await _prefs;
    await prefs.clear();
  }

  /// 저장소 종료
  static Future<void> close() async {
    await _settingsBox?.close();
    await _cacheBox?.close();
    await _userBox?.close();
  }
}
