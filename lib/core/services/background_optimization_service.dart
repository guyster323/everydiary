import 'dart:async';
import 'dart:convert';

import 'package:everydiary/core/services/image_generation_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 배경 최적화 설정 모델
class BackgroundOptimizationSettings {
  final double blurRadius;
  final double brightness;
  final double contrast;
  final double saturation;
  final Color overlayColor;
  final double overlayOpacity;
  final bool enableAutoContrast;
  final bool enableTextReadability;

  const BackgroundOptimizationSettings({
    this.blurRadius = 10.0,
    this.brightness = 0.3,
    this.contrast = 1.2,
    this.saturation = 0.8,
    this.overlayColor = Colors.black,
    this.overlayOpacity = 0.3,
    this.enableAutoContrast = true,
    this.enableTextReadability = true,
  });

  Map<String, dynamic> toJson() => {
    'blur_radius': blurRadius,
    'brightness': brightness,
    'contrast': contrast,
    'saturation': saturation,
    'overlay_color': overlayColor.value,
    'overlay_opacity': overlayOpacity,
    'enable_auto_contrast': enableAutoContrast,
    'enable_text_readability': enableTextReadability,
  };

  factory BackgroundOptimizationSettings.fromJson(Map<String, dynamic> json) {
    return BackgroundOptimizationSettings(
      blurRadius: (json['blur_radius'] as num).toDouble(),
      brightness: (json['brightness'] as num).toDouble(),
      contrast: (json['contrast'] as num).toDouble(),
      saturation: (json['saturation'] as num).toDouble(),
      overlayColor: Color(json['overlay_color'] as int),
      overlayOpacity: (json['overlay_opacity'] as num).toDouble(),
      enableAutoContrast: json['enable_auto_contrast'] as bool,
      enableTextReadability: json['enable_text_readability'] as bool,
    );
  }

  BackgroundOptimizationSettings copyWith({
    double? blurRadius,
    double? brightness,
    double? contrast,
    double? saturation,
    Color? overlayColor,
    double? overlayOpacity,
    bool? enableAutoContrast,
    bool? enableTextReadability,
  }) {
    return BackgroundOptimizationSettings(
      blurRadius: blurRadius ?? this.blurRadius,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      overlayColor: overlayColor ?? this.overlayColor,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      enableAutoContrast: enableAutoContrast ?? this.enableAutoContrast,
      enableTextReadability:
          enableTextReadability ?? this.enableTextReadability,
    );
  }
}

/// 배경 최적화 서비스
/// 생성된 이미지를 일기 배경으로 적용하고 가독성과 사용자 경험을 최적화합니다.
class BackgroundOptimizationService {
  static final BackgroundOptimizationService _instance =
      BackgroundOptimizationService._internal();
  factory BackgroundOptimizationService() => _instance;
  BackgroundOptimizationService._internal();

  bool _isInitialized = false;
  BackgroundOptimizationSettings _settings =
      const BackgroundOptimizationSettings();
  final Map<String, ImageGenerationResult> _backgroundCache = {};
  final List<Map<String, dynamic>> _optimizationHistory = [];

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 배경 최적화 서비스 초기화 시작');

      // 설정 로드
      await _loadSettings();

      // 배경 캐시 로드
      await _loadBackgroundCache();

      // 최적화 이력 로드
      await _loadOptimizationHistory();

      _isInitialized = true;
      debugPrint('✅ 배경 최적화 서비스 초기화 완료');
    } catch (e) {
      debugPrint('❌ 배경 최적화 서비스 초기화 실패: $e');
    }
  }

  /// 배경 이미지 최적화
  Future<Map<String, dynamic>?> optimizeBackground(
    ImageGenerationResult imageResult,
    Size screenSize,
  ) async {
    if (!_isInitialized) {
      debugPrint('❌ 배경 최적화 서비스가 초기화되지 않았습니다.');
      return null;
    }

    try {
      debugPrint('🎨 배경 이미지 최적화 시작');

      // 캐시 확인
      final cacheKey = _generateCacheKey(imageResult, screenSize);
      if (_backgroundCache.containsKey(cacheKey)) {
        debugPrint('📋 캐시된 배경 최적화 결과 사용');
        return _backgroundCache[cacheKey]!.metadata;
      }

      // 최적화 설정 적용
      final optimizedSettings = await _calculateOptimalSettings(
        imageResult,
        screenSize,
      );

      // 최적화된 배경 정보 생성
      final optimizedBackground = {
        'original_url': imageResult.imageUrl,
        'optimized_url': imageResult.imageUrl, // 실제로는 이미지 처리 후 새 URL
        'blur_radius': optimizedSettings.blurRadius,
        'brightness': optimizedSettings.brightness,
        'contrast': optimizedSettings.contrast,
        'saturation': optimizedSettings.saturation,
        'overlay_color': optimizedSettings.overlayColor.value,
        'overlay_opacity': optimizedSettings.overlayOpacity,
        'screen_size': {'width': screenSize.width, 'height': screenSize.height},
        'optimization_timestamp': DateTime.now().toIso8601String(),
        'readability_score': await _calculateReadabilityScore(
          imageResult,
          optimizedSettings,
        ),
      };

      // 캐시에 저장
      final cachedResult = ImageGenerationResult(
        imageUrl: imageResult.imageUrl,
        prompt: imageResult.prompt,
        style: imageResult.style,
        topic: imageResult.topic,
        emotion: imageResult.emotion,
        generatedAt: imageResult.generatedAt,
        metadata: optimizedBackground,
      );
      _backgroundCache[cacheKey] = cachedResult;
      await _saveBackgroundCache();

      // 최적화 이력에 추가
      _optimizationHistory.add({
        'image_result': imageResult.toJson(),
        'optimized_background': optimizedBackground,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await _saveOptimizationHistory();

      debugPrint('✅ 배경 이미지 최적화 완료');
      return optimizedBackground;
    } catch (e) {
      debugPrint('❌ 배경 이미지 최적화 실패: $e');
      return null;
    }
  }

  /// 최적 설정 계산
  Future<BackgroundOptimizationSettings> _calculateOptimalSettings(
    ImageGenerationResult imageResult,
    Size screenSize,
  ) async {
    try {
      // 기본 설정에서 시작
      var settings = _settings;

      // 자동 대비 조정이 활성화된 경우
      if (settings.enableAutoContrast) {
        settings = await _adjustContrastForReadability(
          settings,
          imageResult,
          screenSize,
        );
      }

      // 텍스트 가독성이 활성화된 경우
      if (settings.enableTextReadability) {
        settings = await _adjustForTextReadability(
          settings,
          imageResult,
          screenSize,
        );
      }

      // 화면 크기에 따른 조정
      settings = _adjustForScreenSize(settings, screenSize);

      return settings;
    } catch (e) {
      debugPrint('❌ 최적 설정 계산 실패: $e');
      return _settings;
    }
  }

  /// 가독성을 위한 대비 조정
  Future<BackgroundOptimizationSettings> _adjustContrastForReadability(
    BackgroundOptimizationSettings settings,
    ImageGenerationResult imageResult,
    Size screenSize,
  ) async {
    try {
      // 감정에 따른 대비 조정
      double contrastMultiplier = 1.0;
      double brightnessAdjustment = 0.0;

      switch (imageResult.emotion) {
        case '긍정':
          contrastMultiplier = 1.1;
          brightnessAdjustment = 0.1;
          break;
        case '부정':
          contrastMultiplier = 1.3;
          brightnessAdjustment = -0.1;
          break;
        case '중립':
          contrastMultiplier = 1.0;
          brightnessAdjustment = 0.0;
          break;
      }

      // 주제에 따른 추가 조정
      switch (imageResult.topic) {
        case '여행':
          contrastMultiplier *= 1.1;
          break;
        case '음식':
          contrastMultiplier *= 1.05;
          break;
        case '운동':
          contrastMultiplier *= 1.15;
          break;
        case '감정':
          contrastMultiplier *= 1.2;
          break;
      }

      return settings.copyWith(
        contrast: (settings.contrast * contrastMultiplier).clamp(0.5, 2.0),
        brightness: (settings.brightness + brightnessAdjustment).clamp(
          -0.5,
          0.5,
        ),
      );
    } catch (e) {
      debugPrint('❌ 대비 조정 실패: $e');
      return settings;
    }
  }

  /// 텍스트 가독성을 위한 조정
  Future<BackgroundOptimizationSettings> _adjustForTextReadability(
    BackgroundOptimizationSettings settings,
    ImageGenerationResult imageResult,
    Size screenSize,
  ) async {
    try {
      // 화면 크기에 따른 블러 반경 조정
      final screenDiagonal = screenSize.width + screenSize.height;
      final blurRadius = (screenDiagonal / 200).clamp(5.0, 20.0);

      // 오버레이 투명도 조정
      final overlayOpacity = (screenDiagonal / 1000).clamp(0.2, 0.6);

      return settings.copyWith(
        blurRadius: blurRadius,
        overlayOpacity: overlayOpacity,
      );
    } catch (e) {
      debugPrint('❌ 텍스트 가독성 조정 실패: $e');
      return settings;
    }
  }

  /// 화면 크기에 따른 조정
  BackgroundOptimizationSettings _adjustForScreenSize(
    BackgroundOptimizationSettings settings,
    Size screenSize,
  ) {
    try {
      // 작은 화면에서는 블러를 줄이고 대비를 높임
      if (screenSize.width < 400 || screenSize.height < 600) {
        return settings.copyWith(
          blurRadius: (settings.blurRadius * 0.8).clamp(3.0, 15.0),
          contrast: (settings.contrast * 1.1).clamp(0.5, 2.0),
        );
      }

      // 큰 화면에서는 블러를 늘리고 대비를 조정
      if (screenSize.width > 800 || screenSize.height > 1200) {
        return settings.copyWith(
          blurRadius: (settings.blurRadius * 1.2).clamp(5.0, 25.0),
          contrast: (settings.contrast * 0.95).clamp(0.5, 2.0),
        );
      }

      return settings;
    } catch (e) {
      debugPrint('❌ 화면 크기 조정 실패: $e');
      return settings;
    }
  }

  /// 가독성 점수 계산
  Future<double> _calculateReadabilityScore(
    ImageGenerationResult imageResult,
    BackgroundOptimizationSettings settings,
  ) async {
    try {
      double score = 1.0;

      // 대비 점수 (0.0 ~ 1.0)
      final contrastScore = (settings.contrast - 0.5) / 1.5;
      score *= contrastScore.clamp(0.1, 1.0);

      // 밝기 점수 (0.0 ~ 1.0)
      final brightnessScore = 1.0 - (settings.brightness.abs() * 2);
      score *= brightnessScore.clamp(0.1, 1.0);

      // 블러 점수 (0.0 ~ 1.0)
      final blurScore = 1.0 - ((settings.blurRadius - 5) / 20);
      score *= blurScore.clamp(0.1, 1.0);

      // 오버레이 점수 (0.0 ~ 1.0)
      final overlayScore = 1.0 - (settings.overlayOpacity * 2);
      score *= overlayScore.clamp(0.1, 1.0);

      return score.clamp(0.0, 1.0);
    } catch (e) {
      debugPrint('❌ 가독성 점수 계산 실패: $e');
      return 0.5;
    }
  }

  /// 설정 업데이트
  Future<void> updateSettings(
    BackgroundOptimizationSettings newSettings,
  ) async {
    try {
      _settings = newSettings;
      await _saveSettings();
      debugPrint('✅ 배경 최적화 설정 업데이트 완료');
    } catch (e) {
      debugPrint('❌ 설정 업데이트 실패: $e');
    }
  }

  /// 현재 설정 가져오기
  BackgroundOptimizationSettings get currentSettings => _settings;

  /// 캐시 키 생성
  String _generateCacheKey(ImageGenerationResult imageResult, Size screenSize) {
    return '${imageResult.imageUrl.hashCode}_${screenSize.width.toInt()}_${screenSize.height.toInt()}';
  }

  /// 설정 로드
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('background_optimization_settings');

      if (settingsJson != null) {
        final settingsData = jsonDecode(settingsJson) as Map<String, dynamic>;
        _settings = BackgroundOptimizationSettings.fromJson(settingsData);
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
        'background_optimization_settings',
        jsonEncode(_settings.toJson()),
      );
    } catch (e) {
      debugPrint('❌ 설정 저장 실패: $e');
    }
  }

  /// 배경 캐시 로드
  Future<void> _loadBackgroundCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString('background_optimization_cache');

      if (cacheJson != null) {
        final cacheData = jsonDecode(cacheJson) as Map<String, dynamic>;
        _backgroundCache.clear();

        for (final entry in cacheData.entries) {
          final resultData = entry.value as Map<String, dynamic>;
          _backgroundCache[entry.key] = ImageGenerationResult.fromJson(
            resultData,
          );
        }
      }
    } catch (e) {
      debugPrint('❌ 배경 캐시 로드 실패: $e');
    }
  }

  /// 배경 캐시 저장
  Future<void> _saveBackgroundCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = <String, dynamic>{};

      for (final entry in _backgroundCache.entries) {
        cacheData[entry.key] = entry.value.toJson();
      }

      await prefs.setString(
        'background_optimization_cache',
        jsonEncode(cacheData),
      );
    } catch (e) {
      debugPrint('❌ 배경 캐시 저장 실패: $e');
    }
  }

  /// 최적화 이력 로드
  Future<void> _loadOptimizationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('background_optimization_history');

      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List<dynamic>;
        _optimizationHistory.clear();
        _optimizationHistory.addAll(
          historyList.map((item) => item as Map<String, dynamic>),
        );
      }
    } catch (e) {
      debugPrint('❌ 최적화 이력 로드 실패: $e');
    }
  }

  /// 최적화 이력 저장
  Future<void> _saveOptimizationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'background_optimization_history',
        jsonEncode(_optimizationHistory),
      );
    } catch (e) {
      debugPrint('❌ 최적화 이력 저장 실패: $e');
    }
  }

  /// 캐시된 최적화 결과 가져오기
  Map<String, dynamic>? getCachedOptimization(
    ImageGenerationResult imageResult,
    Size screenSize,
  ) {
    final cacheKey = _generateCacheKey(imageResult, screenSize);
    final cachedResult = _backgroundCache[cacheKey];
    return cachedResult?.metadata;
  }

  /// 최적화 이력 가져오기
  List<Map<String, dynamic>> getOptimizationHistory() {
    return List.from(_optimizationHistory);
  }

  /// 캐시 초기화
  Future<void> clearCache() async {
    try {
      _backgroundCache.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('background_optimization_cache');
      debugPrint('✅ 배경 최적화 캐시 초기화 완료');
    } catch (e) {
      debugPrint('❌ 캐시 초기화 실패: $e');
    }
  }

  /// 최적화 이력 초기화
  Future<void> clearHistory() async {
    try {
      _optimizationHistory.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('background_optimization_history');
      debugPrint('✅ 배경 최적화 이력 초기화 완료');
    } catch (e) {
      debugPrint('❌ 이력 초기화 실패: $e');
    }
  }

  /// 서비스 정리
  void dispose() {
    _backgroundCache.clear();
    _optimizationHistory.clear();
    _isInitialized = false;
    debugPrint('🗑️ 배경 최적화 서비스 정리 완료');
  }
}
