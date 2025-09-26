import 'package:everydiary/core/providers/text_analysis_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 시작 시 텍스트 분석 서비스를 초기화하는 서비스
class TextAnalysisInitializer {
  final ProviderContainer _container;
  bool _isInitialized = false;

  TextAnalysisInitializer(this._container);

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ TextAnalysisInitializer 이미 초기화됨');
      return;
    }

    debugPrint('🔄 TextAnalysisInitializer 초기화 시작');
    try {
      // 텍스트 분석 서비스 초기화
      await _container.read(textAnalysisInitializationProvider.future);
      _isInitialized = true;
      debugPrint('✅ TextAnalysisInitializer 초기화 완료');
    } catch (e) {
      debugPrint('❌ TextAnalysisInitializer 초기화 실패: $e');
    }
  }
}
