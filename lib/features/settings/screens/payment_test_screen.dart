import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/subscription_model.dart';
import '../../../shared/services/payment_test_service.dart';

/// 결제 테스트 화면
///
/// 개발 및 테스트 환경에서 결제 기능을 테스트하기 위한 화면입니다.
class PaymentTestScreen extends ConsumerStatefulWidget {
  const PaymentTestScreen({super.key});

  @override
  ConsumerState<PaymentTestScreen> createState() => _PaymentTestScreenState();
}

class _PaymentTestScreenState extends ConsumerState<PaymentTestScreen> {
  final PaymentTestService _testService = PaymentTestService();
  bool _isTestMode = false;
  bool _isLoading = false;
  Map<String, dynamic>? _testReport;

  @override
  void initState() {
    super.initState();
    _isTestMode = _testService.isTestMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제 테스트'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 테스트 모드 토글
            _buildTestModeToggle(),
            const SizedBox(height: 24),

            if (_isTestMode) ...[
              // 테스트 시나리오 섹션
              _buildTestScenariosSection(),
              const SizedBox(height: 24),

              // 테스트 데이터 생성 섹션
              _buildTestDataSection(),
              const SizedBox(height: 24),

              // 테스트 결과 섹션
              _buildTestResultsSection(),
            ] else ...[
              // 테스트 모드 비활성화 안내
              _buildTestModeDisabledInfo(),
            ],
          ],
        ),
      ),
    );
  }

  /// 테스트 모드 토글
  Widget _buildTestModeToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('테스트 모드', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '테스트 모드를 활성화하면 실제 결제 없이 결제 기능을 테스트할 수 있습니다.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('테스트 모드 활성화'),
              subtitle: Text(_isTestMode ? '활성화됨' : '비활성화됨'),
              value: _isTestMode,
              onChanged: (value) {
                setState(() {
                  _isTestMode = value;
                });
                _testService.setTestMode(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 테스트 시나리오 섹션
  Widget _buildTestScenariosSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('테스트 시나리오', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '다양한 결제 시나리오를 테스트할 수 있습니다.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildScenarioButton(
                  '성공적인 월간 구독',
                  'successful_monthly_purchase',
                  Colors.green,
                ),
                _buildScenarioButton('실패한 구매', 'failed_purchase', Colors.red),
                _buildScenarioButton(
                  '만료된 구독',
                  'expired_subscription',
                  Colors.orange,
                ),
                _buildScenarioButton('네트워크 오류', 'network_error', Colors.blue),
                _buildScenarioButton(
                  '영수증 검증 실패',
                  'receipt_verification_failure',
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 테스트 데이터 섹션
  Widget _buildTestDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('테스트 데이터 생성', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '테스트용 구독 및 구매 데이터를 생성할 수 있습니다.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDataButton(
                  '월간 구독 생성',
                  () => _createTestSubscription(SubscriptionPlanType.monthly),
                  Colors.blue,
                ),
                _buildDataButton(
                  '연간 구독 생성',
                  () => _createTestSubscription(SubscriptionPlanType.yearly),
                  Colors.green,
                ),
                _buildDataButton(
                  '평생 구독 생성',
                  () => _createTestSubscription(SubscriptionPlanType.lifetime),
                  Colors.purple,
                ),
                _buildDataButton(
                  '성공한 구매 생성',
                  () => _createTestPurchase(SubscriptionPlanType.monthly, true),
                  Colors.green,
                ),
                _buildDataButton(
                  '실패한 구매 생성',
                  () =>
                      _createTestPurchase(SubscriptionPlanType.monthly, false),
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 테스트 결과 섹션
  Widget _buildTestResultsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('테스트 결과', style: Theme.of(context).textTheme.titleLarge),
                ElevatedButton(
                  onPressed: _generateTestReport,
                  child: const Text('리포트 생성'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_testReport != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '테스트 리포트',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '생성 시간: ${_testReport!['timestamp']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '총 구매 수: ${_testReport!['totalPurchases']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '활성 구독: ${(_testReport!['activeSubscription'] as bool) ? '예' : '아니오'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _resetTestData,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                ),
                child: const Text('테스트 데이터 초기화'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 테스트 모드 비활성화 안내
  Widget _buildTestModeDisabledInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '테스트 모드가 비활성화되어 있습니다',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '테스트 모드를 활성화하면 결제 기능을 안전하게 테스트할 수 있습니다.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 시나리오 버튼 생성
  Widget _buildScenarioButton(String title, String scenario, Color color) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _runTestScenario(scenario),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      child: Text(title),
    );
  }

  /// 데이터 버튼 생성
  Widget _buildDataButton(String title, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      child: Text(title),
    );
  }

  /// 테스트 시나리오 실행
  Future<void> _runTestScenario(String scenarioName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _testService.runTestScenario(scenarioName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('테스트 시나리오 "$scenarioName"이 완료되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // 오류 처리 (필요시 스낵바로 표시)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('테스트 시나리오 실행 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 테스트 구독 생성
  Future<void> _createTestSubscription(SubscriptionPlanType planType) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _testService.createTestSubscription(
        planType: planType,
        durationDays: 30,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getPlanTypeName(planType)} 구독이 생성되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // 오류 처리 (필요시 스낵바로 표시)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('테스트 구독 생성 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 테스트 구매 생성
  Future<void> _createTestPurchase(
    SubscriptionPlanType planType,
    bool isSuccessful,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _testService.createTestPurchase(
        planType: planType,
        isSuccessful: isSuccessful,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isSuccessful ? '성공한' : '실패한'} 구매가 생성되었습니다.'),
            backgroundColor: isSuccessful ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      // 오류 처리 (필요시 스낵바로 표시)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('테스트 구매 생성 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 테스트 리포트 생성
  Future<void> _generateTestReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final report = await _testService.generateTestReport();
      setState(() {
        _testReport = report;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('테스트 리포트가 생성되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // 오류 처리 (필요시 스낵바로 표시)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('테스트 리포트 생성 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 테스트 데이터 초기화
  Future<void> _resetTestData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테스트 데이터 초기화'),
        content: const Text('모든 테스트 데이터를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _testService.resetTestData();
        setState(() {
          _testReport = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('테스트 데이터가 초기화되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // 오류 처리 (필요시 스낵바로 표시)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('테스트 데이터 초기화 중 오류가 발생했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  /// 플랜 타입 이름 반환
  String _getPlanTypeName(SubscriptionPlanType planType) {
    switch (planType) {
      case SubscriptionPlanType.monthly:
        return '월간';
      case SubscriptionPlanType.yearly:
        return '연간';
      case SubscriptionPlanType.lifetime:
        return '평생';
    }
  }
}
