import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

/// 테마 모드 열거형
enum ThemeMode { light, dark, system }

/// 테마 매니저 서비스
/// 앱의 테마 모드를 관리하고 저장소에 영구 저장합니다.
class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _currentThemeMode = ThemeMode.system;
  late ThemeData _lightTheme;
  late ThemeData _darkTheme;
  bool _isInitialized = false;

  /// 현재 테마 모드
  ThemeMode get currentThemeMode => _currentThemeMode;

  /// 현재 테마 데이터
  ThemeData get currentTheme {
    if (!_isInitialized) {
      return AppTheme.lightTheme;
    }

    switch (_currentThemeMode) {
      case ThemeMode.light:
        return _lightTheme;
      case ThemeMode.dark:
        return _darkTheme;
      case ThemeMode.system:
        return _lightTheme; // 시스템 테마는 MaterialApp에서 처리
    }
  }

  /// 라이트 테마
  ThemeData get lightTheme {
    if (!_isInitialized) {
      return AppTheme.lightTheme;
    }
    return _lightTheme;
  }

  /// 다크 테마
  ThemeData get darkTheme {
    if (!_isInitialized) {
      return AppTheme.darkTheme;
    }
    return _darkTheme;
  }

  /// 시스템 테마 모드 (MaterialApp에서 사용)
  ThemeMode get materialThemeMode {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return ThemeMode.light;
      case ThemeMode.dark:
        return ThemeMode.dark;
      case ThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// 싱글톤 인스턴스
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  /// 초기화
  Future<void> initialize() async {
    _lightTheme = AppTheme.lightTheme;
    _darkTheme = AppTheme.darkTheme;
    _isInitialized = true;

    // 저장된 테마 모드 로드
    await _loadThemeMode();
  }

  /// 테마 모드 변경
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_currentThemeMode == mode) return;

    _currentThemeMode = mode;
    await _saveThemeMode();
    notifyListeners();
  }

  /// 라이트 모드로 전환
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  /// 다크 모드로 전환
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// 시스템 모드로 전환
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }

  /// 테마 모드 토글 (라이트 ↔ 다크)
  Future<void> toggleTheme() async {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        await setDarkMode();
        break;
      case ThemeMode.dark:
        await setLightMode();
        break;
      case ThemeMode.system:
        // 시스템 모드에서는 라이트 모드로 전환
        await setLightMode();
        break;
    }
  }

  /// 테마 모드 저장
  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _currentThemeMode.name);
  }

  /// 테마 모드 로드
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey);

    if (themeString != null) {
      _currentThemeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == themeString,
        orElse: () => ThemeMode.system,
      );
    }
  }

  /// 테마 모드 이름 반환
  String getThemeModeName() {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return '라이트 모드';
      case ThemeMode.dark:
        return '다크 모드';
      case ThemeMode.system:
        return '시스템 설정';
    }
  }

  /// 테마 모드 설명 반환
  String getThemeModeDescription() {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return '밝은 테마를 사용합니다';
      case ThemeMode.dark:
        return '어두운 테마를 사용합니다';
      case ThemeMode.system:
        return '시스템 설정을 따릅니다';
    }
  }

  /// 테마 모드 아이콘 반환
  IconData getThemeModeIcon() {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  /// 다음 테마 모드 반환 (순환)
  ThemeMode getNextThemeMode() {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return ThemeMode.dark;
      case ThemeMode.dark:
        return ThemeMode.system;
      case ThemeMode.system:
        return ThemeMode.light;
    }
  }

  /// 이전 테마 모드 반환 (순환)
  ThemeMode getPreviousThemeMode() {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return ThemeMode.system;
      case ThemeMode.dark:
        return ThemeMode.light;
      case ThemeMode.system:
        return ThemeMode.dark;
    }
  }

  /// 다음 테마 모드로 전환
  Future<void> switchToNextTheme() async {
    await setThemeMode(getNextThemeMode());
  }

  /// 이전 테마 모드로 전환
  Future<void> switchToPreviousTheme() async {
    await setThemeMode(getPreviousThemeMode());
  }

  /// 테마 모드가 라이트인지 확인
  bool get isLightMode => _currentThemeMode == ThemeMode.light;

  /// 테마 모드가 다크인지 확인
  bool get isDarkMode => _currentThemeMode == ThemeMode.dark;

  /// 테마 모드가 시스템인지 확인
  bool get isSystemMode => _currentThemeMode == ThemeMode.system;

  /// 현재 테마가 다크인지 확인 (시스템 모드 고려)
  bool isDarkTheme(BuildContext context) {
    if (_currentThemeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _currentThemeMode == ThemeMode.dark;
  }

  /// 현재 테마가 라이트인지 확인 (시스템 모드 고려)
  bool isLightTheme(BuildContext context) {
    return !isDarkTheme(context);
  }

  /// 테마 모드 변경 리스너 추가
  void addThemeChangeListener(VoidCallback listener) {
    addListener(listener);
  }

  /// 테마 모드 변경 리스너 제거
  void removeThemeChangeListener(VoidCallback listener) {
    removeListener(listener);
  }

  /// 테마 모드 초기화 (시스템 모드로 리셋)
  Future<void> resetTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// 테마 모드 정보 반환
  Map<String, dynamic> getThemeInfo() {
    return {
      'currentMode': _currentThemeMode.name,
      'currentModeName': getThemeModeName(),
      'currentModeDescription': getThemeModeDescription(),
      'currentModeIcon': getThemeModeIcon().codePoint,
      'isLightMode': isLightMode,
      'isDarkMode': isDarkMode,
      'isSystemMode': isSystemMode,
      'nextMode': getNextThemeMode().name,
      'previousMode': getPreviousThemeMode().name,
    };
  }
}
