import 'package:flutter/foundation.dart';

import '../models/subscription_model.dart';
import 'local_storage_service.dart';
import 'receipt_verification_service.dart';

/// 결제 테스트 서비스
///
/// 개발 및 테스트 환경에서 결제 기능을 테스트하기 위한 서비스입니다.
class PaymentTestService {
  static final PaymentTestService _instance = PaymentTestService._internal();
  factory PaymentTestService() => _instance;
  PaymentTestService._internal();

  final LocalStorageService _localStorage = LocalStorageService();

  /// 테스트 모드 활성화 여부
  bool _isTestMode = false;
  bool get isTestMode => _isTestMode;

  /// 테스트 모드 활성화/비활성화
  void setTestMode(bool enabled) {
    _isTestMode = enabled;
    debugPrint('Payment Test Mode: ${enabled ? 'Enabled' : 'Disabled'}');
  }

  /// 테스트용 구독 생성
  Future<SubscriptionModel> createTestSubscription({
    required SubscriptionPlanType planType,
    int durationDays = 30,
  }) async {
    if (!_isTestMode) {
      throw Exception('Test mode is not enabled');
    }

    final now = DateTime.now();
    final expiryDate = now.add(Duration(days: durationDays));

    final testSubscription = SubscriptionModel(
      id: 'test_subscription_${DateTime.now().millisecondsSinceEpoch}',
      productId: _getTestProductId(planType),
      userId: 'test_user',
      status: SubscriptionStatus.active.name,
      planType: planType.name,
      createdAt: now,
      updatedAt: now,
      expiresAt: expiryDate,
      isActive: true,
    );

    // 로컬 저장소에 테스트 구독 저장
    await _localStorage.saveSubscriptionInfo(testSubscription);

    debugPrint('Test subscription created: ${testSubscription.id}');
    return testSubscription;
  }

  /// 테스트용 구매 기록 생성
  Future<PurchaseRecord> createTestPurchase({
    required SubscriptionPlanType planType,
    bool isSuccessful = true,
  }) async {
    if (!_isTestMode) {
      throw Exception('Test mode is not enabled');
    }

    final testPurchase = PurchaseRecord(
      id: 'test_purchase_${DateTime.now().millisecondsSinceEpoch}',
      productId: _getTestProductId(planType),
      transactionId:
          'test_transaction_${DateTime.now().millisecondsSinceEpoch}',
      purchaseTime: DateTime.now(),
      price: 9.99,
      currency: 'USD',
      status: isSuccessful ? 'completed' : 'failed',
    );

    // 로컬 저장소에 테스트 구매 기록 저장
    await _localStorage.addPurchaseRecord(testPurchase);

    debugPrint('Test purchase created: ${testPurchase.id}');
    return testPurchase;
  }

  /// 테스트용 영수증 검증 시뮬레이션
  Future<ReceiptVerificationResult> simulateReceiptVerification({
    required String purchaseToken,
    required String productId,
    bool shouldSucceed = true,
    String? errorMessage,
  }) async {
    if (!_isTestMode) {
      throw Exception('Test mode is not enabled');
    }

    await Future<void>.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션

    if (shouldSucceed) {
      return ReceiptVerificationResult.success(
        subscriptionType: _getPlanTypeFromProductId(productId).name,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        isTestEnvironment: true,
      );
    } else {
      return ReceiptVerificationResult.failure(
        errorMessage ?? 'Test verification failed',
      );
    }
  }

  /// 테스트용 구독 상태 확인 시뮬레이션
  Future<SubscriptionStatusResult> simulateSubscriptionStatusCheck({
    required String userId,
    bool hasActiveSubscription = true,
    SubscriptionPlanType? planType,
  }) async {
    if (!_isTestMode) {
      throw Exception('Test mode is not enabled');
    }

    await Future<void>.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션

    if (hasActiveSubscription) {
      final plan = planType ?? SubscriptionPlanType.monthly;
      return SubscriptionStatusResult.success(
        isActive: true,
        subscriptionType: plan.name,
        expiresAt: DateTime.now().add(const Duration(days: 15)),
        isTestEnvironment: true,
      );
    } else {
      return SubscriptionStatusResult.success(
        isActive: false,
        isTestEnvironment: true,
      );
    }
  }

  /// 테스트 데이터 초기화
  Future<void> resetTestData() async {
    if (!_isTestMode) {
      throw Exception('Test mode is not enabled');
    }

    await _localStorage.clearSubscriptionInfo();
    await _localStorage.clearPurchaseHistory();
    await _localStorage.clearPromoCode();

    debugPrint('Test data reset completed');
  }

  /// 테스트 시나리오 실행
  Future<void> runTestScenario(String scenarioName) async {
    if (!_isTestMode) {
      throw Exception('Test mode is not enabled');
    }

    debugPrint('Running test scenario: $scenarioName');

    switch (scenarioName) {
      case 'successful_monthly_purchase':
        await _testSuccessfulMonthlyPurchase();
        break;
      case 'failed_purchase':
        await _testFailedPurchase();
        break;
      case 'expired_subscription':
        await _testExpiredSubscription();
        break;
      case 'network_error':
        await _testNetworkError();
        break;
      case 'receipt_verification_failure':
        await _testReceiptVerificationFailure();
        break;
      default:
        throw Exception('Unknown test scenario: $scenarioName');
    }

    debugPrint('Test scenario completed: $scenarioName');
  }

  /// 성공적인 월간 구독 구매 테스트
  Future<void> _testSuccessfulMonthlyPurchase() async {
    await resetTestData();

    final subscription = await createTestSubscription(
      planType: SubscriptionPlanType.monthly,
      durationDays: 30,
    );

    await createTestPurchase(
      planType: SubscriptionPlanType.monthly,
      isSuccessful: true,
    );

    debugPrint('Monthly subscription test completed: ${subscription.id}');
  }

  /// 실패한 구매 테스트
  Future<void> _testFailedPurchase() async {
    await resetTestData();

    final purchase = await createTestPurchase(
      planType: SubscriptionPlanType.monthly,
      isSuccessful: false,
    );

    debugPrint('Failed purchase test completed: ${purchase.id}');
  }

  /// 만료된 구독 테스트
  Future<void> _testExpiredSubscription() async {
    await resetTestData();

    final subscription = await createTestSubscription(
      planType: SubscriptionPlanType.monthly,
      durationDays: -1, // 이미 만료된 구독
    );

    debugPrint('Expired subscription test completed: ${subscription.id}');
  }

  /// 네트워크 오류 테스트
  Future<void> _testNetworkError() async {
    await resetTestData();

    final result = await simulateReceiptVerification(
      purchaseToken: 'test_token',
      productId: 'monthly_subscription',
      shouldSucceed: false,
      errorMessage: 'Network error',
    );

    debugPrint('Network error test completed: ${result.errorMessage}');
  }

  /// 영수증 검증 실패 테스트
  Future<void> _testReceiptVerificationFailure() async {
    await resetTestData();

    final result = await simulateReceiptVerification(
      purchaseToken: 'invalid_token',
      productId: 'monthly_subscription',
      shouldSucceed: false,
      errorMessage: 'Invalid receipt',
    );

    debugPrint(
      'Receipt verification failure test completed: ${result.errorMessage}',
    );
  }

  /// 테스트용 상품 ID 생성
  String _getTestProductId(SubscriptionPlanType planType) {
    switch (planType) {
      case SubscriptionPlanType.monthly:
        return 'test_monthly_subscription';
      case SubscriptionPlanType.yearly:
        return 'test_yearly_subscription';
      case SubscriptionPlanType.lifetime:
        return 'test_lifetime_subscription';
    }
  }

  /// 상품 ID에서 플랜 타입 추출
  SubscriptionPlanType _getPlanTypeFromProductId(String productId) {
    if (productId.contains('monthly')) {
      return SubscriptionPlanType.monthly;
    } else if (productId.contains('yearly')) {
      return SubscriptionPlanType.yearly;
    } else if (productId.contains('lifetime')) {
      return SubscriptionPlanType.lifetime;
    }
    return SubscriptionPlanType.monthly;
  }

  /// 테스트 결과 리포트 생성
  Future<Map<String, dynamic>> generateTestReport() async {
    if (!_isTestMode) {
      throw Exception('Test mode is not enabled');
    }

    final subscriptionInfo = await _localStorage.loadSubscriptionInfo();
    final purchaseHistory = await _localStorage.loadPurchaseHistory();

    return {
      'testMode': _isTestMode,
      'timestamp': DateTime.now().toIso8601String(),
      'subscriptionInfo': subscriptionInfo?.toJson(),
      'purchaseHistory': purchaseHistory.map((p) => p.toJson()).toList(),
      'totalPurchases': purchaseHistory.length,
      'activeSubscription': subscriptionInfo?.isActive ?? false,
    };
  }
}
