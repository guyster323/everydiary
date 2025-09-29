import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 이미지 스타일 열거형
enum ImageStyle {
  chibi(
    '3등신 만화',
    'chibi 3-head cartoon character, cute proportions, expressive eyes, soft shading',
  ),
  cute(
    '귀여운',
    'adorable kawaii illustration, pastel palette, rounded shapes, gentle lighting',
  ),
  realistic('사실적', 'photorealistic lighting and details'),
  cartoon('만화', 'bold cartoon illustration with clean lines'),
  watercolor('수채화', 'watercolor painting with soft edges'),
  oil('유화', 'oil painting with rich textures'),
  sketch('스케치', 'pencil sketch style with fine lines'),
  digital('디지털 아트', 'digital art with smooth gradients'),
  vintage('빈티지', 'vintage style with muted colors'),
  modern('모던', 'modern minimalist composition');

  const ImageStyle(this.displayName, this.promptSuffix);
  final String displayName;
  final String promptSuffix;
}

/// 사용자 커스터마이징 설정 모델
class UserCustomizationSettings {
  final ImageStyle preferredStyle;
  final double brightness;
  final double contrast;
  final double saturation;
  final double blurRadius;
  final Color overlayColor;
  final double overlayOpacity;
  final bool enableAutoOptimization;
  final bool enableStylePresets;
  final List<String> favoriteStyles;
  final Map<String, dynamic> customPresets;

  const UserCustomizationSettings({
    this.preferredStyle = ImageStyle.chibi,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.blurRadius = 10.0,
    this.overlayColor = Colors.black,
    this.overlayOpacity = 0.3,
    this.enableAutoOptimization = true,
    this.enableStylePresets = true,
    this.favoriteStyles = const [],
    this.customPresets = const {},
  });

  Map<String, dynamic> toJson() => {
    'preferred_style': preferredStyle.name,
    'brightness': brightness,
    'contrast': contrast,
    'saturation': saturation,
    'blur_radius': blurRadius,
    'overlay_color': overlayColor.toARGB32(),
    'overlay_opacity': overlayOpacity,
    'enable_auto_optimization': enableAutoOptimization,
    'enable_style_presets': enableStylePresets,
    'favorite_styles': favoriteStyles,
    'custom_presets': customPresets,
  };

  factory UserCustomizationSettings.fromJson(Map<String, dynamic> json) {
    return UserCustomizationSettings(
      preferredStyle: ImageStyle.values.firstWhere(
        (style) => style.name == json['preferred_style'],
        orElse: () => ImageStyle.chibi,
      ),
      brightness: (json['brightness'] as num).toDouble(),
      contrast: (json['contrast'] as num).toDouble(),
      saturation: (json['saturation'] as num).toDouble(),
      blurRadius: (json['blur_radius'] as num).toDouble(),
      overlayColor: Color(json['overlay_color'] as int),
      overlayOpacity: (json['overlay_opacity'] as num).toDouble(),
      enableAutoOptimization: json['enable_auto_optimization'] as bool,
      enableStylePresets: json['enable_style_presets'] as bool,
      favoriteStyles: List<String>.from(json['favorite_styles'] as List),
      customPresets: Map<String, dynamic>.from(json['custom_presets'] as Map),
    );
  }

  UserCustomizationSettings copyWith({
    ImageStyle? preferredStyle,
    double? brightness,
    double? contrast,
    double? saturation,
    double? blurRadius,
    Color? overlayColor,
    double? overlayOpacity,
    bool? enableAutoOptimization,
    bool? enableStylePresets,
    List<String>? favoriteStyles,
    Map<String, dynamic>? customPresets,
  }) {
    return UserCustomizationSettings(
      preferredStyle: preferredStyle ?? this.preferredStyle,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      blurRadius: blurRadius ?? this.blurRadius,
      overlayColor: overlayColor ?? this.overlayColor,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      enableAutoOptimization:
          enableAutoOptimization ?? this.enableAutoOptimization,
      enableStylePresets: enableStylePresets ?? this.enableStylePresets,
      favoriteStyles: favoriteStyles ?? this.favoriteStyles,
      customPresets: customPresets ?? this.customPresets,
    );
  }
}

/// 사용자 커스터마이징 서비스
/// 사용자가 생성된 배경 이미지의 스타일, 밝기, 대비 등을 조정할 수 있는 커스터마이징 기능을 제공합니다.
class UserCustomizationService {
  static final UserCustomizationService _instance =
      UserCustomizationService._internal();
  factory UserCustomizationService() => _instance;
  UserCustomizationService._internal();

  bool _isInitialized = false;
  UserCustomizationSettings _settings = const UserCustomizationSettings();
  final List<Map<String, dynamic>> _customizationHistory = [];

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 사용자 커스터마이징 서비스 초기화 시작');

      // 설정 로드
      await _loadSettings();

      // 커스터마이징 이력 로드
      await _loadCustomizationHistory();

      _isInitialized = true;
      debugPrint('✅ 사용자 커스터마이징 서비스 초기화 완료');
    } catch (e) {
      debugPrint('❌ 사용자 커스터마이징 서비스 초기화 실패: $e');
    }
  }

  /// 설정 업데이트
  Future<void> updateSettings(UserCustomizationSettings newSettings) async {
    try {
      _settings = newSettings;
      await _saveSettings();

      // 커스터마이징 이력에 추가
      _customizationHistory.add({
        'settings': newSettings.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      await _saveCustomizationHistory();

      debugPrint('✅ 사용자 커스터마이징 설정 업데이트 완료');
    } catch (e) {
      debugPrint('❌ 설정 업데이트 실패: $e');
    }
  }

  /// 스타일 업데이트
  Future<void> updateStyle(ImageStyle style) async {
    try {
      final newSettings = _settings.copyWith(preferredStyle: style);
      await updateSettings(newSettings);
      debugPrint('✅ 이미지 스타일 업데이트: ${style.displayName}');
    } catch (e) {
      debugPrint('❌ 스타일 업데이트 실패: $e');
    }
  }

  /// 밝기 업데이트
  Future<void> updateBrightness(double brightness) async {
    try {
      final newSettings = _settings.copyWith(brightness: brightness);
      await updateSettings(newSettings);
      debugPrint('✅ 밝기 업데이트: $brightness');
    } catch (e) {
      debugPrint('❌ 밝기 업데이트 실패: $e');
    }
  }

  /// 대비 업데이트
  Future<void> updateContrast(double contrast) async {
    try {
      final newSettings = _settings.copyWith(contrast: contrast);
      await updateSettings(newSettings);
      debugPrint('✅ 대비 업데이트: $contrast');
    } catch (e) {
      debugPrint('❌ 대비 업데이트 실패: $e');
    }
  }

  /// 포화도 업데이트
  Future<void> updateSaturation(double saturation) async {
    try {
      final newSettings = _settings.copyWith(saturation: saturation);
      await updateSettings(newSettings);
      debugPrint('✅ 포화도 업데이트: $saturation');
    } catch (e) {
      debugPrint('❌ 포화도 업데이트 실패: $e');
    }
  }

  /// 블러 반경 업데이트
  Future<void> updateBlurRadius(double blurRadius) async {
    try {
      final newSettings = _settings.copyWith(blurRadius: blurRadius);
      await updateSettings(newSettings);
      debugPrint('✅ 블러 반경 업데이트: $blurRadius');
    } catch (e) {
      debugPrint('❌ 블러 반경 업데이트 실패: $e');
    }
  }

  /// 오버레이 색상 업데이트
  Future<void> updateOverlayColor(Color overlayColor) async {
    try {
      final newSettings = _settings.copyWith(overlayColor: overlayColor);
      await updateSettings(newSettings);
      debugPrint('✅ 오버레이 색상 업데이트: ${overlayColor.toARGB32()}');
    } catch (e) {
      debugPrint('❌ 오버레이 색상 업데이트 실패: $e');
    }
  }

  /// 오버레이 투명도 업데이트
  Future<void> updateOverlayOpacity(double overlayOpacity) async {
    try {
      final newSettings = _settings.copyWith(overlayOpacity: overlayOpacity);
      await updateSettings(newSettings);
      debugPrint('✅ 오버레이 투명도 업데이트: $overlayOpacity');
    } catch (e) {
      debugPrint('❌ 오버레이 투명도 업데이트 실패: $e');
    }
  }

  /// 자동 최적화 토글
  Future<void> toggleAutoOptimization() async {
    try {
      final newSettings = _settings.copyWith(
        enableAutoOptimization: !_settings.enableAutoOptimization,
      );
      await updateSettings(newSettings);
      debugPrint('✅ 자동 최적화 토글: ${newSettings.enableAutoOptimization}');
    } catch (e) {
      debugPrint('❌ 자동 최적화 토글 실패: $e');
    }
  }

  /// 스타일 프리셋 토글
  Future<void> toggleStylePresets() async {
    try {
      final newSettings = _settings.copyWith(
        enableStylePresets: !_settings.enableStylePresets,
      );
      await updateSettings(newSettings);
      debugPrint('✅ 스타일 프리셋 토글: ${newSettings.enableStylePresets}');
    } catch (e) {
      debugPrint('❌ 스타일 프리셋 토글 실패: $e');
    }
  }

  /// 즐겨찾기 스타일 추가
  Future<void> addFavoriteStyle(String styleName) async {
    try {
      if (!_settings.favoriteStyles.contains(styleName)) {
        final newFavorites = List<String>.from(_settings.favoriteStyles)
          ..add(styleName);
        final newSettings = _settings.copyWith(favoriteStyles: newFavorites);
        await updateSettings(newSettings);
        debugPrint('✅ 즐겨찾기 스타일 추가: $styleName');
      }
    } catch (e) {
      debugPrint('❌ 즐겨찾기 스타일 추가 실패: $e');
    }
  }

  /// 즐겨찾기 스타일 제거
  Future<void> removeFavoriteStyle(String styleName) async {
    try {
      if (_settings.favoriteStyles.contains(styleName)) {
        final newFavorites = List<String>.from(_settings.favoriteStyles)
          ..remove(styleName);
        final newSettings = _settings.copyWith(favoriteStyles: newFavorites);
        await updateSettings(newSettings);
        debugPrint('✅ 즐겨찾기 스타일 제거: $styleName');
      }
    } catch (e) {
      debugPrint('❌ 즐겨찾기 스타일 제거 실패: $e');
    }
  }

  /// 커스텀 프리셋 저장
  Future<void> saveCustomPreset(
    String presetName,
    Map<String, dynamic> preset,
  ) async {
    try {
      final newPresets = Map<String, dynamic>.from(_settings.customPresets);
      newPresets[presetName] = {
        ...preset,
        'created_at': DateTime.now().toIso8601String(),
      };
      final newSettings = _settings.copyWith(customPresets: newPresets);
      await updateSettings(newSettings);
      debugPrint('✅ 커스텀 프리셋 저장: $presetName');
    } catch (e) {
      debugPrint('❌ 커스텀 프리셋 저장 실패: $e');
    }
  }

  /// 커스텀 프리셋 삭제
  Future<void> deleteCustomPreset(String presetName) async {
    try {
      final newPresets = Map<String, dynamic>.from(_settings.customPresets);
      newPresets.remove(presetName);
      final newSettings = _settings.copyWith(customPresets: newPresets);
      await updateSettings(newSettings);
      debugPrint('✅ 커스텀 프리셋 삭제: $presetName');
    } catch (e) {
      debugPrint('❌ 커스텀 프리셋 삭제 실패: $e');
    }
  }

  /// 커스텀 프리셋 적용
  Future<void> applyCustomPreset(String presetName) async {
    try {
      if (_settings.customPresets.containsKey(presetName)) {
        final preset =
            _settings.customPresets[presetName] as Map<String, dynamic>;
        final newSettings = UserCustomizationSettings.fromJson(preset);
        await updateSettings(newSettings);
        debugPrint('✅ 커스텀 프리셋 적용: $presetName');
      }
    } catch (e) {
      debugPrint('❌ 커스텀 프리셋 적용 실패: $e');
    }
  }

  /// 기본 프리셋 가져오기
  List<Map<String, dynamic>> getDefaultPresets() {
    return [
      {
        'name': '포근한 캐릭터',
        'style': ImageStyle.chibi,
        'brightness': 0.05,
        'contrast': 1.05,
        'saturation': 1.1,
        'blur_radius': 6.0,
        'overlay_opacity': 0.25,
      },
      {
        'name': '밝은 귀여움',
        'style': ImageStyle.cute,
        'brightness': 0.12,
        'contrast': 0.95,
        'saturation': 1.15,
        'blur_radius': 5.0,
        'overlay_opacity': 0.2,
      },
      {
        'name': '드라마틱',
        'style': ImageStyle.oil,
        'brightness': -0.1,
        'contrast': 1.3,
        'saturation': 1.2,
        'blur_radius': 12.0,
        'overlay_opacity': 0.4,
      },
      {
        'name': '부드러운',
        'style': ImageStyle.watercolor,
        'brightness': 0.1,
        'contrast': 0.9,
        'saturation': 0.8,
        'blur_radius': 15.0,
        'overlay_opacity': 0.3,
      },
      {
        'name': '모던',
        'style': ImageStyle.modern,
        'brightness': 0.0,
        'contrast': 1.1,
        'saturation': 1.0,
        'blur_radius': 5.0,
        'overlay_opacity': 0.1,
      },
      {
        'name': '빈티지',
        'style': ImageStyle.vintage,
        'brightness': -0.2,
        'contrast': 1.2,
        'saturation': 0.7,
        'blur_radius': 10.0,
        'overlay_opacity': 0.5,
      },
    ];
  }

  /// 현재 설정 가져오기
  UserCustomizationSettings get currentSettings => _settings;

  /// 커스터마이징 이력 가져오기
  List<Map<String, dynamic>> getCustomizationHistory() {
    return List.from(_customizationHistory);
  }

  /// 설정 로드
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('user_customization_settings');

      if (settingsJson != null) {
        final settingsData = jsonDecode(settingsJson) as Map<String, dynamic>;
        _settings = UserCustomizationSettings.fromJson(settingsData);
      }
    } catch (e) {
      debugPrint('❌ 설정 로드 실패: $e');
    }
  }

  /// 설정 저장
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'user_customization_settings',
        jsonEncode(_settings.toJson()),
      );
    } catch (e) {
      debugPrint('❌ 설정 저장 실패: $e');
    }
  }

  /// 커스터마이징 이력 로드
  Future<void> _loadCustomizationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('user_customization_history');

      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List<dynamic>;
        _customizationHistory.clear();
        _customizationHistory.addAll(
          historyList.map((item) => item as Map<String, dynamic>),
        );
      }
    } catch (e) {
      debugPrint('❌ 커스터마이징 이력 로드 실패: $e');
    }
  }

  /// 커스터마이징 이력 저장
  Future<void> _saveCustomizationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'user_customization_history',
        jsonEncode(_customizationHistory),
      );
    } catch (e) {
      debugPrint('❌ 커스터마이징 이력 저장 실패: $e');
    }
  }

  /// 커스터마이징 이력 초기화
  Future<void> clearHistory() async {
    try {
      _customizationHistory.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_customization_history');
      debugPrint('✅ 사용자 커스터마이징 이력 초기화 완료');
    } catch (e) {
      debugPrint('❌ 이력 초기화 실패: $e');
    }
  }

  /// 서비스 정리
  void dispose() {
    _customizationHistory.clear();
    _isInitialized = false;
    debugPrint('🗑️ 사용자 커스터마이징 서비스 정리 완료');
  }
}
