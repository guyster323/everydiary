import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/subscription_constants.dart';
import '../models/subscription_model.dart';
import '../services/local_storage_service.dart';
import '../services/payment_service.dart';
import '../services/receipt_verification_service.dart';

/// 구독 상태 모델
class SubscriptionStatus {
  final bool isActive;
  final String? productId;
  final DateTime? expiryDate;
  final String? planType; // 'monthly', 'yearly', 'lifetime'

  const SubscriptionStatus({
    required this.isActive,
    this.productId,
    this.expiryDate,
    this.planType,
  });

  SubscriptionStatus copyWith({
    bool? isActive,
    String? productId,
    DateTime? expiryDate,
    String? planType,
  }) {
    return SubscriptionStatus(
      isActive: isActive ?? this.isActive,
      productId: productId ?? this.productId,
      expiryDate: expiryDate ?? this.expiryDate,
      planType: planType ?? this.planType,
    );
  }

  @override
  String toString() {
    return 'SubscriptionStatus(isActive: $isActive, productId: $productId, expiryDate: $expiryDate, planType: $planType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionStatus &&
        other.isActive == isActive &&
        other.productId == productId &&
        other.expiryDate == expiryDate &&
        other.planType == planType;
  }

  @override
  int get hashCode {
    return isActive.hashCode ^
        productId.hashCode ^
        expiryDate.hashCode ^
        planType.hashCode;
  }
}

/// 구독 상태 관리 Provider
class SubscriptionNotifier extends StateNotifier<SubscriptionStatus> {
  final PaymentService _paymentService;
  final LocalStorageService _storageService;
  final ReceiptVerificationService _receiptService;

  SubscriptionNotifier(
    this._paymentService,
    this._storageService,
    this._receiptService,
  ) : super(const SubscriptionStatus(isActive: false)) {
    _initialize();
  }

  /// 초기화
  Future<void> _initialize() async {
    try {
      // 결제 서비스 초기화
      final bool initialized = await _paymentService.initialize();
      if (!initialized) {
        debugPrint('Failed to initialize payment service');
        return;
      }

      // 로컬 저장소에서 구독 정보 로드
      await _loadLocalSubscription();

      // 구독 상태 확인
      await checkSubscriptionStatus();
    } catch (e) {
      debugPrint('Error initializing subscription provider: $e');
    }
  }

  /// 로컬 구독 정보 로드
  Future<void> _loadLocalSubscription() async {
    try {
      final subscription = await _storageService.loadSubscriptionInfo();
      if (subscription != null) {
        _updateStateFromModel(subscription);
      }
    } catch (e) {
      debugPrint('Error loading local subscription: $e');
    }
  }

  /// 모델에서 상태 업데이트
  void _updateStateFromModel(SubscriptionModel subscription) {
    state = state.copyWith(
      isActive: subscription.isCurrentlyActive,
      productId: subscription.productId,
      planType: subscription.planType,
      expiryDate: subscription.expiresAt,
    );
  }

  /// 구독 상태 확인
  Future<void> checkSubscriptionStatus() async {
    try {
      // 로컬 저장소에서 먼저 확인
      final localSubscription = await _storageService.loadSubscriptionInfo();
      if (localSubscription != null && localSubscription.isCurrentlyActive) {
        _updateStateFromModel(localSubscription);
        debugPrint(
          'Local subscription is active: ${localSubscription.productId}',
        );
        return;
      }

      // 서버에서 구독 상태 확인
      final result = await _receiptService.checkSubscriptionStatus(
        'current_user',
      );
      if (result.isSuccess &&
          result.isActive &&
          result.subscriptionType != null) {
        // 서버에서 활성 구독을 찾았으면 로컬에 저장
        final serverSubscription = SubscriptionModel(
          id: 'server_sync_${DateTime.now().millisecondsSinceEpoch}',
          productId: _getProductIdByType(result.subscriptionType!),
          userId: 'current_user',
          status: SubscriptionConstants.activeStatus,
          planType: result.subscriptionType!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          expiresAt: result.expiresAt,
          isActive: true,
          isExpired: false,
          isCanceled: false,
        );

        await _storageService.saveSubscriptionInfo(serverSubscription);
        _updateStateFromModel(serverSubscription);
        debugPrint('Server subscription synced: ${result.subscriptionType}');
      } else {
        // 구독이 비활성화된 경우
        state = const SubscriptionStatus(isActive: false);
        debugPrint('No active subscription found');
      }
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
    }
  }

  /// 구독 타입으로 제품 ID 가져오기
  String _getProductIdByType(String subscriptionType) {
    switch (subscriptionType) {
      case SubscriptionConstants.monthlyType:
        return SubscriptionConstants.monthlySubscriptionId;
      case SubscriptionConstants.yearlyType:
        return SubscriptionConstants.yearlySubscriptionId;
      case SubscriptionConstants.lifetimeType:
        return SubscriptionConstants.lifetimePurchaseId;
      default:
        return SubscriptionConstants.monthlySubscriptionId;
    }
  }

  /// 제품 구매
  Future<bool> purchaseProduct(String productId) async {
    try {
      final bool success = await _paymentService.purchaseProduct(productId);

      if (success) {
        // 구매 성공 시 상태 업데이트
        await checkSubscriptionStatus();

        // 구매 성공 알림
        debugPrint('Purchase successful: $productId');
      } else {
        debugPrint('Purchase failed: $productId');
      }

      return success;
    } catch (e) {
      debugPrint('Error purchasing product: $e');
      return false;
    }
  }

  /// 구매 복원
  Future<bool> restorePurchases() async {
    try {
      await _paymentService.restorePurchases();

      // 복원 후 상태 업데이트
      await checkSubscriptionStatus();

      debugPrint('Purchases restored successfully');
      return true;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }

  /// 구독 활성화
  Future<void> activateSubscription({
    required String productId,
    required String planType,
    DateTime? expiryDate,
  }) async {
    try {
      // 구독 모델 생성
      final subscription = SubscriptionModel(
        id: 'activated_${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        userId: 'current_user',
        status: SubscriptionConstants.activeStatus,
        planType: planType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        expiresAt: expiryDate,
        isActive: true,
        isExpired: false,
        isCanceled: false,
      );

      // 로컬 저장소에 저장
      await _storageService.saveSubscriptionInfo(subscription);

      // 상태 업데이트
      _updateStateFromModel(subscription);
      debugPrint('Subscription activated: $productId');
    } catch (e) {
      debugPrint('Error activating subscription: $e');
    }
  }

  /// 구독 비활성화
  Future<void> deactivateSubscription() async {
    try {
      // 로컬 저장소에서 구독 정보 삭제
      await _storageService.clearSubscriptionInfo();

      // 상태 업데이트
      state = const SubscriptionStatus(isActive: false);
      debugPrint('Subscription deactivated');
    } catch (e) {
      debugPrint('Error deactivating subscription: $e');
    }
  }

  /// 구독 만료 확인
  bool get isExpired {
    if (state.planType == 'lifetime') return false;
    if (state.expiryDate == null) return true;
    return DateTime.now().isAfter(state.expiryDate!);
  }

  /// 프리미엄 기능 접근 가능 여부
  bool get hasPremiumAccess {
    return state.isActive && !isExpired;
  }
}

/// 구독 Provider
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionStatus>((ref) {
      return SubscriptionNotifier(
        PaymentService(),
        LocalStorageService(),
        ReceiptVerificationService(),
      );
    });

/// 구독 상태 확인용 Provider
final hasPremiumAccessProvider = Provider<bool>((ref) {
  final subscription = ref.watch(subscriptionProvider);
  return subscription.isActive &&
      (subscription.planType == 'lifetime' ||
          (subscription.expiryDate != null &&
              DateTime.now().isBefore(subscription.expiryDate!)));
});

/// 구독 플랜 타입 Provider
final subscriptionPlanProvider = Provider<String?>((ref) {
  final subscription = ref.watch(subscriptionProvider);
  return subscription.planType;
});
