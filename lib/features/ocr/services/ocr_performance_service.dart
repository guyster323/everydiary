import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../shared/services/ocr_service.dart' as ocr_service;

/// OCR 성능 모니터링 및 최적화 서비스
class OCRPerformanceService {
  static final OCRPerformanceService _instance =
      OCRPerformanceService._internal();
  factory OCRPerformanceService() => _instance;
  OCRPerformanceService._internal();

  final List<OCRPerformanceMetric> _metrics = [];
  final ocr_service.OCRService _ocrService = ocr_service.OCRService();

  /// 성능 메트릭 기록
  Future<OCRPerformanceResult> measureOCRPerformance({
    required Uint8List imageBytes,
    required String testName,
    bool enablePreprocessing = true,
    TextRecognitionScript script = TextRecognitionScript.korean,
  }) async {
    final stopwatch = Stopwatch()..start();
    final startTime = DateTime.now();

    try {
      // 이미지 전처리 시간 측정
      Uint8List processedBytes = imageBytes;
      int preprocessingTime = 0;

      if (enablePreprocessing) {
        final preprocessStopwatch = Stopwatch()..start();
        processedBytes = await _ocrService.preprocessImage(imageBytes);
        preprocessStopwatch.stop();
        preprocessingTime = preprocessStopwatch.elapsedMilliseconds;
      }

      // OCR 처리 시간 측정
      final ocrStopwatch = Stopwatch()..start();
      final result = await _ocrService.extractTextFromBytes(processedBytes);
      ocrStopwatch.stop();

      stopwatch.stop();

      final metric = OCRPerformanceMetric(
        testName: testName,
        startTime: startTime,
        endTime: DateTime.now(),
        totalTime: stopwatch.elapsedMilliseconds,
        preprocessingTime: preprocessingTime,
        ocrTime: ocrStopwatch.elapsedMilliseconds,
        imageSize: imageBytes.length,
        processedImageSize: processedBytes.length,
        textLength: result.fullText.length,
        confidence: result.confidence,
        textBlocks: result.textBlocks.length,
        script: script,
        enablePreprocessing: enablePreprocessing,
      );

      _metrics.add(metric);

      return OCRPerformanceResult(
        metric: metric,
        ocrResult: result,
        success: true,
      );
    } catch (e) {
      stopwatch.stop();

      final metric = OCRPerformanceMetric(
        testName: testName,
        startTime: startTime,
        endTime: DateTime.now(),
        totalTime: stopwatch.elapsedMilliseconds,
        preprocessingTime: 0,
        ocrTime: 0,
        imageSize: imageBytes.length,
        processedImageSize: 0,
        textLength: 0,
        confidence: 0.0,
        textBlocks: 0,
        script: script,
        enablePreprocessing: enablePreprocessing,
        error: e.toString(),
      );

      _metrics.add(metric);

      return OCRPerformanceResult(
        metric: metric,
        ocrResult: null,
        success: false,
        error: e.toString(),
      );
    }
  }

  /// 배치 성능 테스트
  Future<List<OCRPerformanceResult>> runBatchTest({
    required List<Uint8List> imageBytes,
    required String testSuiteName,
    bool enablePreprocessing = true,
    TextRecognitionScript script = TextRecognitionScript.korean,
  }) async {
    final results = <OCRPerformanceResult>[];

    for (int i = 0; i < imageBytes.length; i++) {
      final result = await measureOCRPerformance(
        imageBytes: imageBytes[i],
        testName: '$testSuiteName - Image ${i + 1}',
        enablePreprocessing: enablePreprocessing,
        script: script,
      );
      results.add(result);
    }

    return results;
  }

  /// 성능 통계 계산
  OCRPerformanceStats calculateStats({String? testName}) {
    final filteredMetrics = testName != null
        ? _metrics.where((m) => m.testName.contains(testName)).toList()
        : _metrics;

    if (filteredMetrics.isEmpty) {
      return OCRPerformanceStats.empty();
    }

    final totalTime = filteredMetrics.fold<int>(
      0,
      (sum, m) => sum + m.totalTime,
    );
    final avgTime = totalTime / filteredMetrics.length;
    final avgConfidence =
        filteredMetrics.fold<double>(0, (sum, m) => sum + m.confidence) /
        filteredMetrics.length;
    final avgTextLength =
        filteredMetrics.fold<int>(0, (sum, m) => sum + m.textLength) /
        filteredMetrics.length;

    final sortedByTime = List<OCRPerformanceMetric>.from(filteredMetrics)
      ..sort((a, b) => a.totalTime.compareTo(b.totalTime));

    return OCRPerformanceStats(
      totalTests: filteredMetrics.length,
      averageTime: avgTime,
      minTime: sortedByTime.first.totalTime,
      maxTime: sortedByTime.last.totalTime,
      averageConfidence: avgConfidence,
      averageTextLength: avgTextLength,
      successRate:
          filteredMetrics.where((m) => m.error == null).length /
          filteredMetrics.length,
      totalTime: totalTime,
    );
  }

  /// 메모리 사용량 모니터링
  Future<MemoryUsage> measureMemoryUsage() async {
    // Flutter에서는 직접적인 메모리 측정이 제한적이므로
    // 이미지 크기와 처리 결과를 기반으로 추정
    final totalImageSize = _metrics.fold<int>(0, (sum, m) => sum + m.imageSize);
    final totalProcessedSize = _metrics.fold<int>(
      0,
      (sum, m) => sum + m.processedImageSize,
    );

    return MemoryUsage(
      estimatedImageMemory: totalImageSize,
      estimatedProcessedMemory: totalProcessedSize,
      estimatedTotalMemory: totalImageSize + totalProcessedSize,
      timestamp: DateTime.now(),
    );
  }

  /// 성능 최적화 제안
  List<PerformanceOptimization> getOptimizationSuggestions() {
    final suggestions = <PerformanceOptimization>[];
    final stats = calculateStats();

    // 평균 처리 시간이 3초를 초과하는 경우
    if (stats.averageTime > 3000) {
      suggestions.add(
        PerformanceOptimization(
          type: OptimizationType.performance,
          priority: OptimizationPriority.high,
          title: '처리 시간 최적화',
          description:
              '평균 처리 시간이 ${(stats.averageTime / 1000).toStringAsFixed(1)}초로 느립니다.',
          suggestions: [
            '이미지 크기를 줄여보세요 (최대 1920x1080 권장)',
            '전처리 옵션을 비활성화해보세요',
            '배치 처리를 고려해보세요',
          ],
        ),
      );
    }

    // 평균 신뢰도가 0.6 미만인 경우
    if (stats.averageConfidence < 0.6) {
      suggestions.add(
        PerformanceOptimization(
          type: OptimizationType.accuracy,
          priority: OptimizationPriority.medium,
          title: '인식 정확도 개선',
          description:
              '평균 신뢰도가 ${(stats.averageConfidence * 100).toStringAsFixed(1)}%로 낮습니다.',
          suggestions: ['이미지 전처리를 활성화해보세요', '더 선명한 이미지를 사용해보세요', '조명을 개선해보세요'],
        ),
      );
    }

    // 성공률이 90% 미만인 경우
    if (stats.successRate < 0.9) {
      suggestions.add(
        PerformanceOptimization(
          type: OptimizationType.reliability,
          priority: OptimizationPriority.high,
          title: '안정성 개선',
          description:
              '성공률이 ${(stats.successRate * 100).toStringAsFixed(1)}%로 낮습니다.',
          suggestions: [
            '이미지 형식을 확인해보세요 (JPEG, PNG 권장)',
            '이미지 크기가 너무 크지 않은지 확인해보세요',
            '네트워크 연결을 확인해보세요',
          ],
        ),
      );
    }

    return suggestions;
  }

  /// 성능 메트릭 초기화
  void clearMetrics() {
    _metrics.clear();
  }

  /// 성능 메트릭 내보내기
  List<OCRPerformanceMetric> exportMetrics() {
    return List.from(_metrics);
  }

  /// 성능 리포트 생성
  String generatePerformanceReport() {
    final stats = calculateStats();
    final memoryUsage = _metrics.isNotEmpty ? _measureMemoryUsage() : null;
    final suggestions = getOptimizationSuggestions();

    final buffer = StringBuffer();
    buffer.writeln('=== OCR 성능 리포트 ===');
    buffer.writeln('생성 시간: ${DateTime.now()}');
    buffer.writeln();

    buffer.writeln('📊 성능 통계:');
    buffer.writeln('  총 테스트 수: ${stats.totalTests}');
    buffer.writeln(
      '  평균 처리 시간: ${(stats.averageTime / 1000).toStringAsFixed(2)}초',
    );
    buffer.writeln('  최소 처리 시간: ${(stats.minTime / 1000).toStringAsFixed(2)}초');
    buffer.writeln('  최대 처리 시간: ${(stats.maxTime / 1000).toStringAsFixed(2)}초');
    buffer.writeln(
      '  평균 신뢰도: ${(stats.averageConfidence * 100).toStringAsFixed(1)}%',
    );
    buffer.writeln(
      '  평균 텍스트 길이: ${stats.averageTextLength.toStringAsFixed(0)}자',
    );
    buffer.writeln('  성공률: ${(stats.successRate * 100).toStringAsFixed(1)}%');
    buffer.writeln();

    if (memoryUsage != null) {
      buffer.writeln('💾 메모리 사용량:');
      buffer.writeln(
        '  예상 이미지 메모리: ${_formatBytes(memoryUsage.estimatedImageMemory)}',
      );
      buffer.writeln(
        '  예상 처리 메모리: ${_formatBytes(memoryUsage.estimatedProcessedMemory)}',
      );
      buffer.writeln(
        '  예상 총 메모리: ${_formatBytes(memoryUsage.estimatedTotalMemory)}',
      );
      buffer.writeln();
    }

    if (suggestions.isNotEmpty) {
      buffer.writeln('💡 최적화 제안:');
      for (int i = 0; i < suggestions.length; i++) {
        final suggestion = suggestions[i];
        buffer.writeln(
          '  ${i + 1}. ${suggestion.title} (${suggestion.priority.name})',
        );
        buffer.writeln('     ${suggestion.description}');
        for (final item in suggestion.suggestions) {
          buffer.writeln('     - $item');
        }
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  /// 메모리 사용량 측정 (내부용)
  MemoryUsage _measureMemoryUsage() {
    final totalImageSize = _metrics.fold<int>(0, (sum, m) => sum + m.imageSize);
    final totalProcessedSize = _metrics.fold<int>(
      0,
      (sum, m) => sum + m.processedImageSize,
    );

    return MemoryUsage(
      estimatedImageMemory: totalImageSize,
      estimatedProcessedMemory: totalProcessedSize,
      estimatedTotalMemory: totalImageSize + totalProcessedSize,
      timestamp: DateTime.now(),
    );
  }

  /// 바이트를 사람이 읽기 쉬운 형태로 변환
  String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }
}

/// OCR 성능 메트릭
class OCRPerformanceMetric {
  final String testName;
  final DateTime startTime;
  final DateTime endTime;
  final int totalTime; // milliseconds
  final int preprocessingTime; // milliseconds
  final int ocrTime; // milliseconds
  final int imageSize; // bytes
  final int processedImageSize; // bytes
  final int textLength;
  final double confidence;
  final int textBlocks;
  final TextRecognitionScript script;
  final bool enablePreprocessing;
  final String? error;

  const OCRPerformanceMetric({
    required this.testName,
    required this.startTime,
    required this.endTime,
    required this.totalTime,
    required this.preprocessingTime,
    required this.ocrTime,
    required this.imageSize,
    required this.processedImageSize,
    required this.textLength,
    required this.confidence,
    required this.textBlocks,
    required this.script,
    required this.enablePreprocessing,
    this.error,
  });
}

/// OCR 성능 결과
class OCRPerformanceResult {
  final OCRPerformanceMetric metric;
  final ocr_service.OCRResult? ocrResult;
  final bool success;
  final String? error;

  const OCRPerformanceResult({
    required this.metric,
    this.ocrResult,
    required this.success,
    this.error,
  });
}

/// OCR 성능 통계
class OCRPerformanceStats {
  final int totalTests;
  final double averageTime;
  final int minTime;
  final int maxTime;
  final double averageConfidence;
  final double averageTextLength;
  final double successRate;
  final int totalTime;

  const OCRPerformanceStats({
    required this.totalTests,
    required this.averageTime,
    required this.minTime,
    required this.maxTime,
    required this.averageConfidence,
    required this.averageTextLength,
    required this.successRate,
    required this.totalTime,
  });

  factory OCRPerformanceStats.empty() {
    return const OCRPerformanceStats(
      totalTests: 0,
      averageTime: 0,
      minTime: 0,
      maxTime: 0,
      averageConfidence: 0,
      averageTextLength: 0,
      successRate: 0,
      totalTime: 0,
    );
  }
}

/// 메모리 사용량
class MemoryUsage {
  final int estimatedImageMemory;
  final int estimatedProcessedMemory;
  final int estimatedTotalMemory;
  final DateTime timestamp;

  const MemoryUsage({
    required this.estimatedImageMemory,
    required this.estimatedProcessedMemory,
    required this.estimatedTotalMemory,
    required this.timestamp,
  });
}

/// 성능 최적화 제안
class PerformanceOptimization {
  final OptimizationType type;
  final OptimizationPriority priority;
  final String title;
  final String description;
  final List<String> suggestions;

  const PerformanceOptimization({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.suggestions,
  });
}

/// 최적화 타입
enum OptimizationType { performance, accuracy, reliability, memory }

/// 최적화 우선순위
enum OptimizationPriority { low, medium, high, critical }
