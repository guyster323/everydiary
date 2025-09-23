import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/speech_integration_manager.dart';

/// 음성 인식 통합 관리 패널
class SpeechIntegrationPanel extends ConsumerStatefulWidget {
  const SpeechIntegrationPanel({
    super.key,
    this.onResult,
    this.onError,
    this.showAdvancedSettings = false,
  });

  final void Function(String)? onResult;
  final void Function(String)? onError;
  final bool showAdvancedSettings;

  @override
  ConsumerState<SpeechIntegrationPanel> createState() =>
      _SpeechIntegrationPanelState();
}

class _SpeechIntegrationPanelState
    extends ConsumerState<SpeechIntegrationPanel> {
  final SpeechIntegrationManager _integrationManager =
      SpeechIntegrationManager();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeIntegration();
  }

  Future<void> _initializeIntegration() async {
    try {
      await _integrationManager.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('통합 관리 초기화 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildStatusOverview(),
            const SizedBox(height: 16),
            _buildQuickActions(),
            if (widget.showAdvancedSettings) ...[
              const SizedBox(height: 16),
              _buildAdvancedSettings(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.integration_instructions,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '음성 인식 통합 관리',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        _buildStatusIndicator(),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    final isOptimized = _integrationManager.isOptimized;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOptimized ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isOptimized ? '최적화됨' : '최적화 중',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusOverview() {
    final stats = _integrationManager.integrationStats;
    final serviceStatus = _integrationManager.getServiceStatus();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '서비스 상태',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: serviceStatus.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: entry.value
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: entry.value
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.red.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                entry.key,
                style: TextStyle(
                  fontSize: 10,
                  color: entry.value ? Colors.green : Colors.red,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Text(
          '현재 모드: ${stats['currentMode'] ?? 'unknown'}',
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          '네트워크: ${stats['networkStatus'] ?? 'unknown'}',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 작업',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _startIntegratedRecognition,
                icon: const Icon(Icons.mic),
                label: const Text('인식 시작'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _stopIntegratedRecognition,
                icon: const Icon(Icons.stop),
                label: const Text('인식 중지'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _refreshStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('상태 새로고침'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showStats,
                icon: const Icon(Icons.analytics),
                label: const Text('통계 보기'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _runCompatibilityTest,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('호환성 테스트 실행'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '고급 설정',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.speed),
          title: const Text('성능 최적화'),
          subtitle: const Text('시스템 성능을 최적화합니다'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showPerformanceSettings,
        ),
        ListTile(
          leading: const Icon(Icons.feedback),
          title: const Text('피드백 관리'),
          subtitle: const Text('사용자 피드백을 확인합니다'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showFeedbackSettings,
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('통합 설정'),
          subtitle: const Text('전체 시스템 설정을 관리합니다'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showIntegrationSettings,
        ),
      ],
    );
  }

  Future<void> _startIntegratedRecognition() async {
    try {
      final success = await _integrationManager
          .startIntegratedSpeechRecognition();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '음성 인식이 시작되었습니다' : '음성 인식 시작에 실패했습니다'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _stopIntegratedRecognition() async {
    try {
      await _integrationManager.stopIntegratedSpeechRecognition();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('음성 인식이 중지되었습니다'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _refreshStatus() async {
    try {
      await _integrationManager.refreshIntegrationStatus();
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('상태가 새로고침되었습니다'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showStats() {
    final stats = _integrationManager.integrationStats;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('통합 통계'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatItem(
                '초기화 상태',
                stats['isInitialized']?.toString() ?? 'unknown',
              ),
              _buildStatItem(
                '최적화 상태',
                stats['isOptimized']?.toString() ?? 'unknown',
              ),
              _buildStatItem(
                '현재 모드',
                stats['currentMode']?.toString() ?? 'unknown',
              ),
              _buildStatItem(
                '네트워크 상태',
                stats['networkStatus']?.toString() ?? 'unknown',
              ),
              _buildStatItem(
                '마지막 업데이트',
                stats['lastUpdated']?.toString() ?? 'unknown',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Future<void> _runCompatibilityTest() async {
    // 로딩 다이얼로그 표시
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('호환성 테스트 실행 중...'),
          ],
        ),
      ),
    );

    try {
      // 호환성 테스트 실행
      final testResults = await _integrationManager.runCompatibilityTest();

      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop();
      }

      // 결과 다이얼로그 표시
      if (mounted) {
        _showCompatibilityTestResults(testResults);
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop();
      }

      // 에러 다이얼로그 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('호환성 테스트 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCompatibilityTestResults(Map<String, dynamic> results) {
    final totalScore = (results['totalScore'] as num?)?.toDouble() ?? 0.0;
    final isCompatible = results['isCompatible'] as bool? ?? false;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isCompatible ? Icons.check_circle : Icons.warning,
              color: isCompatible ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            const Text('호환성 테스트 결과'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompatible
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCompatible ? Colors.green : Colors.orange,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '전체 호환성 점수: ${(totalScore * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCompatible ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompatible ? '✅ 호환성 테스트 통과' : '⚠️ 일부 호환성 문제 발견',
                      style: TextStyle(
                        color: isCompatible ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '세부 테스트 결과:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._buildTestResultItems(results),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTestResultItems(Map<String, dynamic> results) {
    final items = <Widget>[];

    for (final entry in results.entries) {
      if (entry.key == 'totalScore' || entry.key == 'isCompatible') continue;

      final testName = _getTestDisplayName(entry.key);
      final testResult = entry.value as Map<String, dynamic>;
      final success = testResult['success'] as bool? ?? false;

      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                size: 16,
                color: success ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  testName,
                  style: TextStyle(color: success ? Colors.green : Colors.red),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return items;
  }

  String _getTestDisplayName(String key) {
    switch (key) {
      case 'speechRecognition':
        return '음성 인식 서비스';
      case 'offlineMode':
        return '오프라인 모드';
      case 'performanceOptimization':
        return '성능 최적화';
      case 'networkMonitoring':
        return '네트워크 모니터링';
      case 'integration':
        return '통합 시스템';
      default:
        return key;
    }
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showPerformanceSettings() {
    // 성능 설정 다이얼로그 표시
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('성능 설정'),
        content: const Text('성능 최적화 설정을 관리합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackSettings() {
    // 피드백 설정 다이얼로그 표시
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('피드백 관리'),
        content: const Text('사용자 피드백을 확인하고 관리합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _showIntegrationSettings() {
    // 통합 설정 다이얼로그 표시
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('통합 설정'),
        content: const Text('전체 시스템 설정을 관리합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}
