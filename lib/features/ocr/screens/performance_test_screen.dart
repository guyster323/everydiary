import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/ocr_performance_service.dart';
import '../widgets/performance_results_widget.dart';
import '../widgets/performance_test_controls.dart';

/// OCR 성능 테스트 화면
/// OCR 기능의 성능을 측정하고 최적화 제안을 제공합니다.
class PerformanceTestScreen extends StatefulWidget {
  const PerformanceTestScreen({super.key});

  @override
  State<PerformanceTestScreen> createState() => _PerformanceTestScreenState();
}

class _PerformanceTestScreenState extends State<PerformanceTestScreen> {
  final OCRPerformanceService _performanceService = OCRPerformanceService();

  List<OCRPerformanceResult> _testResults = [];
  bool _isRunning = false;
  String _currentTest = '';
  OCRPerformanceStats? _stats;
  List<PerformanceOptimization> _optimizations = [];

  @override
  void initState() {
    super.initState();
    _loadExistingResults();
  }

  /// 기존 결과 로드
  void _loadExistingResults() {
    final metrics = _performanceService.exportMetrics();
    if (metrics.isNotEmpty) {
      setState(() {
        _stats = _performanceService.calculateStats();
        _optimizations = _performanceService.getOptimizationSuggestions();
      });
    }
  }

  /// 단일 이미지 테스트
  Future<void> _runSingleImageTest() async {
    // 샘플 이미지 데이터 (실제로는 이미지 선택기에서 가져와야 함)
    final sampleImageData = _generateSampleImageData();

    setState(() {
      _isRunning = true;
      _currentTest = '단일 이미지 테스트';
    });

    try {
      final result = await _performanceService.measureOCRPerformance(
        imageBytes: sampleImageData,
        testName: '단일 이미지 테스트',
        enablePreprocessing: true,
      );

      setState(() {
        _testResults = [result];
        _stats = _performanceService.calculateStats();
        _optimizations = _performanceService.getOptimizationSuggestions();
      });
    } catch (e) {
      _showErrorDialog('테스트 실행 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isRunning = false;
        _currentTest = '';
      });
    }
  }

  /// 배치 테스트 실행
  Future<void> _runBatchTest() async {
    // 샘플 이미지 데이터들
    final sampleImages = List.generate(5, (index) => _generateSampleImageData());

    setState(() {
      _isRunning = true;
      _currentTest = '배치 테스트 (5개 이미지)';
    });

    try {
      final results = await _performanceService.runBatchTest(
        imageBytes: sampleImages,
        testSuiteName: '배치 테스트',
        enablePreprocessing: true,
      );

      setState(() {
        _testResults = results;
        _stats = _performanceService.calculateStats();
        _optimizations = _performanceService.getOptimizationSuggestions();
      });
    } catch (e) {
      _showErrorDialog('배치 테스트 실행 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isRunning = false;
        _currentTest = '';
      });
    }
  }

  /// 전처리 비교 테스트
  Future<void> _runPreprocessingComparisonTest() async {
    final sampleImageData = _generateSampleImageData();

    setState(() {
      _isRunning = true;
      _currentTest = '전처리 비교 테스트';
    });

    try {
      // 전처리 없이 테스트
      final resultWithoutPreprocessing = await _performanceService.measureOCRPerformance(
        imageBytes: sampleImageData,
        testName: '전처리 없음',
        enablePreprocessing: false,
      );

      // 전처리와 함께 테스트
      final resultWithPreprocessing = await _performanceService.measureOCRPerformance(
        imageBytes: sampleImageData,
        testName: '전처리 있음',
        enablePreprocessing: true,
      );

      setState(() {
        _testResults = [resultWithoutPreprocessing, resultWithPreprocessing];
        _stats = _performanceService.calculateStats();
        _optimizations = _performanceService.getOptimizationSuggestions();
      });
    } catch (e) {
      _showErrorDialog('전처리 비교 테스트 실행 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isRunning = false;
        _currentTest = '';
      });
    }
  }

  /// 성능 리포트 생성 및 공유
  void _generateAndShareReport() {
    final report = _performanceService.generatePerformanceReport();

    // 클립보드에 복사
    Clipboard.setData(ClipboardData(text: report));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('성능 리포트가 클립보드에 복사되었습니다.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// 테스트 결과 초기화
  void _clearResults() {
    _performanceService.clearMetrics();
    setState(() {
      _testResults.clear();
      _stats = null;
      _optimizations.clear();
    });
  }

  /// 샘플 이미지 데이터 생성 (실제로는 이미지 선택기에서 가져와야 함)
  Uint8List _generateSampleImageData() {
    // 실제 구현에서는 이미지 선택기나 카메라에서 가져온 데이터를 사용
    // 여기서는 더미 데이터를 생성
    return Uint8List.fromList(List.generate(1024 * 100, (index) => index % 256));
  }

  /// 에러 다이얼로그 표시
  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR 성능 테스트'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_testResults.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _generateAndShareReport,
              tooltip: '리포트 공유',
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearResults,
              tooltip: '결과 초기화',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // 테스트 컨트롤
          PerformanceTestControls(
            isRunning: _isRunning,
            currentTest: _currentTest,
            onSingleTest: _runSingleImageTest,
            onBatchTest: _runBatchTest,
            onPreprocessingTest: _runPreprocessingComparisonTest,
          ),

          // 테스트 결과
          Expanded(
            child: _testResults.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '성능 테스트를 실행해보세요',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '단일 이미지, 배치, 전처리 비교 테스트를 지원합니다',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : PerformanceResultsWidget(
                    results: _testResults,
                    stats: _stats,
                    optimizations: _optimizations,
                  ),
          ),
        ],
      ),
    );
  }
}

