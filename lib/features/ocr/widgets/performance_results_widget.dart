import 'package:flutter/material.dart';

import '../services/ocr_performance_service.dart';

/// 성능 결과 위젯
/// OCR 성능 테스트 결과를 표시합니다.
class PerformanceResultsWidget extends StatelessWidget {
  final List<OCRPerformanceResult> results;
  final OCRPerformanceStats? stats;
  final List<PerformanceOptimization> optimizations;

  const PerformanceResultsWidget({
    super.key,
    required this.results,
    this.stats,
    required this.optimizations,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // 탭 바
          Container(
            color: Theme.of(context).cardColor,
            child: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.analytics), text: '통계'),
                Tab(icon: Icon(Icons.list), text: '결과'),
                Tab(icon: Icon(Icons.lightbulb), text: '최적화'),
              ],
            ),
          ),

          // 탭 내용
          Expanded(
            child: TabBarView(
              children: [
                _buildStatsTab(),
                _buildResultsTab(),
                _buildOptimizationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 탭 빌드
  Widget _buildStatsTab() {
    if (stats == null) {
      return const Center(child: Text('통계 데이터가 없습니다.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전체 통계 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '전체 성능 통계',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('총 테스트 수', '${stats!.totalTests}개'),
                  _buildStatRow(
                    '평균 처리 시간',
                    '${(stats!.averageTime / 1000).toStringAsFixed(2)}초',
                  ),
                  _buildStatRow(
                    '최소 처리 시간',
                    '${(stats!.minTime / 1000).toStringAsFixed(2)}초',
                  ),
                  _buildStatRow(
                    '최대 처리 시간',
                    '${(stats!.maxTime / 1000).toStringAsFixed(2)}초',
                  ),
                  _buildStatRow(
                    '평균 신뢰도',
                    '${(stats!.averageConfidence * 100).toStringAsFixed(1)}%',
                  ),
                  _buildStatRow(
                    '평균 텍스트 길이',
                    '${stats!.averageTextLength.toStringAsFixed(0)}자',
                  ),
                  _buildStatRow(
                    '성공률',
                    '${(stats!.successRate * 100).toStringAsFixed(1)}%',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 성능 차트 (간단한 막대 차트)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '처리 시간 분포',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTimeChart(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 결과 탭 빌드
  Widget _buildResultsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      result.success ? Icons.check_circle : Icons.error,
                      color: result.success ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.metric.testName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${(result.metric.totalTime / 1000).toStringAsFixed(2)}초',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildResultRow('처리 시간', '${result.metric.totalTime}ms'),
                _buildResultRow(
                  '전처리 시간',
                  '${result.metric.preprocessingTime}ms',
                ),
                _buildResultRow('OCR 시간', '${result.metric.ocrTime}ms'),
                _buildResultRow(
                  '이미지 크기',
                  _formatBytes(result.metric.imageSize),
                ),
                _buildResultRow('텍스트 길이', '${result.metric.textLength}자'),
                _buildResultRow(
                  '신뢰도',
                  '${(result.metric.confidence * 100).toStringAsFixed(1)}%',
                ),
                _buildResultRow('텍스트 블록', '${result.metric.textBlocks}개'),
                if (result.metric.error != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '오류: ${result.metric.error}',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// 최적화 탭 빌드
  Widget _buildOptimizationsTab() {
    if (optimizations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              '최적화 제안이 없습니다',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '현재 성능이 양호합니다!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: optimizations.length,
      itemBuilder: (context, index) {
        final optimization = optimizations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getOptimizationIcon(optimization.type),
                      color: _getPriorityColor(optimization.priority),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        optimization.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(optimization.priority),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        optimization.priority.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  optimization.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 12),
                const Text(
                  '제안사항:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...optimization.suggestions.map(
                  (suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 통계 행 빌드
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// 결과 행 빌드
  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// 시간 차트 빌드
  Widget _buildTimeChart() {
    final maxTime = results.fold<int>(
      0,
      (max, result) =>
          result.metric.totalTime > max ? result.metric.totalTime : max,
    );

    return Column(
      children: results.asMap().entries.map((entry) {
        final index = entry.key;
        final result = entry.value;
        final percentage = maxTime > 0
            ? result.metric.totalTime / maxTime
            : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  '테스트 ${index + 1}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getTimeColor(result.metric.totalTime),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(result.metric.totalTime / 1000).toStringAsFixed(1)}s',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 시간에 따른 색상 반환
  Color _getTimeColor(int timeMs) {
    if (timeMs < 1000) return Colors.green;
    if (timeMs < 3000) return Colors.orange;
    return Colors.red;
  }

  /// 최적화 타입에 따른 아이콘 반환
  IconData _getOptimizationIcon(OptimizationType type) {
    switch (type) {
      case OptimizationType.performance:
        return Icons.speed;
      case OptimizationType.accuracy:
        return Icons.gps_fixed;
      case OptimizationType.reliability:
        return Icons.security;
      case OptimizationType.memory:
        return Icons.memory;
    }
  }

  /// 우선순위에 따른 색상 반환
  Color _getPriorityColor(OptimizationPriority priority) {
    switch (priority) {
      case OptimizationPriority.low:
        return Colors.green;
      case OptimizationPriority.medium:
        return Colors.orange;
      case OptimizationPriority.high:
        return Colors.red;
      case OptimizationPriority.critical:
        return Colors.purple;
    }
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
