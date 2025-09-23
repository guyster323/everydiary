import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/subscription_constants.dart';
import '../models/payment_error_model.dart';
import '../models/subscription_model.dart';
import 'local_storage_service.dart';
import 'payment_error_handler.dart';
import 'receipt_verification_service.dart';

/// Google Play 인앱 결제 서비스
///
/// 이 서비스는 Google Play Store의 인앱 결제 기능을 관리합니다.
/// 구독 상태 확인, 결제 처리, 영수증 검증 등의 기능을 제공합니다.
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final ReceiptVerificationService _receiptService =
      ReceiptVerificationService();
  final LocalStorageService _storageService = LocalStorageService();
  final PaymentErrorHandler _errorHandler = PaymentErrorHandler();
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // 구독 제품 ID들 (상수에서 가져옴)
  static const String monthlySubscriptionId =
      SubscriptionConstants.monthlySubscriptionId;
  static const String yearlySubscriptionId =
      SubscriptionConstants.yearlySubscriptionId;
  static const String lifetimePurchaseId =
      SubscriptionConstants.lifetimePurchaseId;

  // 제품 ID 리스트
  static const Set<String> _productIds = SubscriptionConstants.productIds;

  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];

  // Getters
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  List<PurchaseDetails> get purchases => _purchases;

  /// 결제 서비스 초기화
  ///
  /// Google Play Store 연결 상태를 확인하고 제품 정보를 가져옵니다.
  Future<bool> initialize() async {
    try {
      // Google Play Store 사용 가능 여부 확인
      _isAvailable = await _inAppPurchase.isAvailable();

      if (!_isAvailable) {
        debugPrint('Google Play Store is not available');
        return false;
      }

      // Android 전용 설정
      if (Platform.isAndroid) {
        // 구매 스트림 리스너 설정
        _subscription = _inAppPurchase.purchaseStream.listen(
          _onPurchaseUpdated,
          onDone: _onPurchaseStreamDone,
          onError: _onPurchaseStreamError,
        );

        // 제품 정보 가져오기
        await _loadProducts();

        // 기존 구매 복원
        await _restorePurchases();
      }

      debugPrint('Payment service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to initialize payment service: $e');
      return false;
    }
  }

  /// 제품 정보 로드
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(_productIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      debugPrint('Loaded ${_products.length} products');
    } catch (e) {
      debugPrint('Failed to load products: $e');
    }
  }

  /// 구매 업데이트 처리
  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  /// 구매 스트림 완료 처리
  void _onPurchaseStreamDone() {
    debugPrint('Purchase stream done');
  }

  /// 구매 스트림 오류 처리
  void _onPurchaseStreamError(dynamic error) {
    debugPrint('Purchase stream error: $error');
  }

  /// 구매 처리
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    try {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('Purchase pending: ${purchaseDetails.productID}');
        return;
      }

      if (purchaseDetails.status == PurchaseStatus.purchased) {
        // 구매 완료 처리
        await _processCompletedPurchase(purchaseDetails);
      }

      if (purchaseDetails.status == PurchaseStatus.error) {
        final error = _errorHandler.handlePurchaseError(purchaseDetails);
        _errorHandler.logError(error, context: '_handlePurchase');
        _errorHandler.trackError(error, context: '_handlePurchase');
      }

      if (purchaseDetails.status == PurchaseStatus.canceled) {
        final error = _errorHandler.handlePurchaseError(purchaseDetails);
        _errorHandler.logError(error, context: '_handlePurchase');
        _errorHandler.trackError(error, context: '_handlePurchase');
      }

      // 구매 완료 알림
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    } catch (e) {
      final error = _errorHandler.handleNetworkError(e as Exception);
      _errorHandler.logError(error, context: '_handlePurchase');
      _errorHandler.trackError(error, context: '_handlePurchase');
    }
  }

  /// 완료된 구매 처리
  Future<void> _processCompletedPurchase(
    PurchaseDetails purchaseDetails,
  ) async {
    try {
      // 영수증 검증 로직 (실제 구현에서는 서버에서 검증)
      final bool isValid = await _verifyReceipt(purchaseDetails);

      if (isValid) {
        // 구매 정보 저장 및 상태 업데이트
        await _savePurchaseInfo(purchaseDetails);
        debugPrint(
          'Purchase completed successfully: ${purchaseDetails.productID}',
        );
      } else {
        debugPrint('Invalid receipt for: ${purchaseDetails.productID}');
      }
    } catch (e) {
      debugPrint('Error processing completed purchase: $e');
    }
  }

  /// 영수증 검증
  Future<bool> _verifyReceipt(PurchaseDetails purchaseDetails) async {
    try {
      final result = await _receiptService.verifyReceipt(purchaseDetails);

      if (result.isSuccess) {
        // 검증 성공 시 구독 정보 저장
        await _saveVerifiedPurchase(purchaseDetails, result);
        return true;
      } else {
        debugPrint('Receipt verification failed: ${result.errorMessage}');
        return false;
      }
    } catch (e) {
      debugPrint('Error verifying receipt: $e');
      return false;
    }
  }

  /// 검증된 구매 정보 저장
  Future<void> _saveVerifiedPurchase(
    PurchaseDetails purchaseDetails,
    ReceiptVerificationResult verificationResult,
  ) async {
    try {
      final subscription = SubscriptionModel(
        id: purchaseDetails.purchaseID ?? '',
        productId: purchaseDetails.productID,
        userId: await _getCurrentUserId(), // 실제 사용자 ID로 변경
        status: SubscriptionConstants.activeStatus,
        planType: verificationResult.subscriptionType ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        expiresAt: verificationResult.expiresAt,
        transactionId: purchaseDetails.purchaseID,
        originalTransactionId: purchaseDetails.purchaseID,
        isActive: true,
        isExpired: false,
        isCanceled: false,
      );

      await _storageService.saveSubscriptionInfo(subscription);

      // 구매 기록 저장
      final purchaseRecord = PurchaseRecord(
        id: purchaseDetails.purchaseID ?? '',
        productId: purchaseDetails.productID,
        transactionId: purchaseDetails.purchaseID ?? '',
        purchaseTime: DateTime.now(),
        price:
            SubscriptionConstants.getPrice(
              purchaseDetails.productID,
            )?.toDouble() ??
            0.0,
        currency: 'KRW',
        status: 'completed',
      );

      await _storageService.addPurchaseRecord(purchaseRecord);
      debugPrint('Verified purchase saved: ${purchaseDetails.productID}');
    } catch (e) {
      debugPrint('Error saving verified purchase: $e');
    }
  }

  /// 구매 정보 저장
  Future<void> _savePurchaseInfo(PurchaseDetails purchaseDetails) async {
    // 로컬 저장소에 구매 정보 저장
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchaseData = {
        'productId': purchaseDetails.productID,
        'purchaseId': purchaseDetails.purchaseID,
        'transactionDate': purchaseDetails.transactionDate,
        'verificationData':
            purchaseDetails.verificationData.localVerificationData,
        'serverVerificationData':
            purchaseDetails.verificationData.serverVerificationData,
        'source': purchaseDetails.verificationData.source,
        'status': purchaseDetails.status.toString(),
        'pendingCompletePurchase': purchaseDetails.pendingCompletePurchase,
        'purchaseTime': DateTime.now().toIso8601String(),
      };

      final purchaseJson = jsonEncode(purchaseData);
      await prefs.setString(
        'purchase_${purchaseDetails.purchaseID}',
        purchaseJson,
      );

      // 구매 히스토리에도 추가
      const historyKey = 'purchase_history';
      final historyJson = prefs.getString(historyKey) ?? '[]';
      final history = jsonDecode(historyJson) as List<dynamic>;
      history.add(purchaseData);
      await prefs.setString(historyKey, jsonEncode(history));

      debugPrint('Purchase info saved: ${purchaseDetails.productID}');
    } catch (e) {
      debugPrint('Error saving purchase info: $e');
    }
  }

  /// 현재 사용자 ID 가져오기
  Future<String> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');
      if (userId != null && userId.isNotEmpty) {
        return userId;
      }

      // 사용자 ID가 없으면 새로 생성
      final newUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('current_user_id', newUserId);
      return newUserId;
    } catch (e) {
      debugPrint('Error getting current user ID: $e');
      return 'user_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// 구매 복원
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();

      // 복원된 구매 정보를 로컬 저장소에 동기화
      await _syncRestoredPurchases();

      debugPrint('Purchases restored and synced');
    } catch (e) {
      debugPrint('Failed to restore purchases: $e');
    }
  }

  /// 복원된 구매 정보 동기화
  Future<void> _syncRestoredPurchases() async {
    try {
      // 현재 활성 구독 확인
      final currentSubscription = await _storageService.loadSubscriptionInfo();
      if (currentSubscription != null &&
          currentSubscription.isCurrentlyActive) {
        // 이미 활성 구독이 있으면 복원 완료
        debugPrint(
          'Active subscription already exists: ${currentSubscription.productId}',
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
        final restoredSubscription = SubscriptionModel(
          id: 'restored_${DateTime.now().millisecondsSinceEpoch}',
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

        await _storageService.saveSubscriptionInfo(restoredSubscription);
        debugPrint('Restored subscription saved: ${result.subscriptionType}');
      }
    } catch (e) {
      debugPrint('Error syncing restored purchases: $e');
    }
  }

  /// 구매 복원 (내부용)
  Future<void> _restorePurchases() async {
    await restorePurchases();
  }

  /// 특정 제품 구매
  Future<bool> purchaseProduct(String productId) async {
    try {
      if (!(await _inAppPurchase.isAvailable())) {
        const error = PaymentError(
          type: PaymentErrorType.paymentDeclined,
          message: '결제 서비스를 사용할 수 없습니다.',
          details: 'Google Play Store가 설치되어 있지 않거나 업데이트가 필요합니다.',
          isRetryable: false,
        );
        _errorHandler.logError(error, context: 'purchaseProduct');
        return false;
      }

      final ProductDetails? product = _products
          .where((p) => p.id == productId)
          .firstOrNull;

      if (product == null) {
        const error = PaymentError(
          type: PaymentErrorType.invalidProduct,
          message: '해당 상품을 구매할 수 없습니다.',
          details: '상품이 Google Play Store에서 제거되었거나 비활성화되었습니다.',
          isRetryable: false,
        );
        _errorHandler.logError(error, context: 'purchaseProduct');
        return false;
      }

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (success) {
        debugPrint('Purchase initiated for: $productId');
      } else {
        debugPrint('Failed to initiate purchase for: $productId');
      }

      return success;
    } catch (e) {
      final error = _errorHandler.handleNetworkError(e as Exception);
      _errorHandler.logError(error, context: 'purchaseProduct');
      return false;
    }
  }

  /// 구독 상태 확인
  Future<bool> checkSubscriptionStatus() async {
    try {
      // 로컬 저장소에서 구독 정보 확인
      final localSubscription = await _storageService.loadSubscriptionInfo();
      if (localSubscription != null && localSubscription.isCurrentlyActive) {
        return true;
      }

      // 서버에서 구독 상태 확인
      final result = await _receiptService.checkSubscriptionStatus(
        'current_user',
      );
      if (result.isSuccess && result.isActive) {
        // 서버 상태가 활성화되어 있으면 로컬 정보 업데이트
        if (result.subscriptionType != null) {
          final updatedSubscription = SubscriptionModel(
            id: localSubscription?.id ?? 'server_sync',
            productId: _getProductIdByType(result.subscriptionType!),
            userId: 'current_user',
            status: SubscriptionConstants.activeStatus,
            planType: result.subscriptionType!,
            createdAt: localSubscription?.createdAt ?? DateTime.now(),
            updatedAt: DateTime.now(),
            expiresAt: result.expiresAt,
            transactionId: localSubscription?.transactionId,
            originalTransactionId: localSubscription?.originalTransactionId,
            isActive: true,
            isExpired: false,
            isCanceled: false,
          );
          await _storageService.saveSubscriptionInfo(updatedSubscription);
        }
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
      return false;
    }
  }

  /// 구독 타입으로 제품 ID 가져오기
  String _getProductIdByType(String subscriptionType) {
    switch (subscriptionType) {
      case SubscriptionConstants.monthlyType:
        return monthlySubscriptionId;
      case SubscriptionConstants.yearlyType:
        return yearlySubscriptionId;
      case SubscriptionConstants.lifetimeType:
        return lifetimePurchaseId;
      default:
        return monthlySubscriptionId;
    }
  }

  /// 서비스 정리
  void dispose() {
    _subscription.cancel();
  }
}
