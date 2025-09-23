import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/subscription_constants.dart';

/// 영수증 검증 서비스
///
/// Google Play Store 영수증을 검증하고 구독 상태를 확인하는 서비스입니다.
class ReceiptVerificationService {
  static final ReceiptVerificationService _instance =
      ReceiptVerificationService._internal();
  factory ReceiptVerificationService() => _instance;
  ReceiptVerificationService._internal();

  // 실제 서버 URL로 변경 (환경에 따라 동적으로 설정)
  static String get _verificationServerUrl {
    if (SubscriptionConstants.isTestEnvironment()) {
      return 'https://api-test.everydiary.com/verify-receipt';
    }
    return 'https://api.everydiary.com/verify-receipt';
  }

  static String get _subscriptionStatusUrl {
    if (SubscriptionConstants.isTestEnvironment()) {
      return 'https://api-test.everydiary.com/subscription-status';
    }
    return 'https://api.everydiary.com/subscription-status';
  }

  /// 영수증 검증
  ///
  /// Google Play Store에서 받은 영수증을 서버에서 검증합니다.
  Future<ReceiptVerificationResult> verifyReceipt(
    PurchaseDetails purchaseDetails,
  ) async {
    try {
      if (SubscriptionConstants.isTestEnvironment()) {
        return _verifyTestReceipt(purchaseDetails);
      }

      final Map<String, dynamic> requestData = {
        'packageName': await _getPackageName(), // 실제 패키지명으로 변경
        'productId': purchaseDetails.productID,
        'purchaseToken': purchaseDetails.purchaseID,
        'purchaseTime': purchaseDetails.transactionDate,
        'orderId': purchaseDetails.purchaseID,
      };

      final response = await http.post(
        Uri.parse(_verificationServerUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getApiKey()}', // 실제 API 키로 변경
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(response.body) as Map<String, dynamic>;
        return _parseVerificationResponse(responseData);
      } else {
        debugPrint('Receipt verification failed: ${response.statusCode}');
        return ReceiptVerificationResult.failure(
          '영수증 검증에 실패했습니다. (${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('Error verifying receipt: $e');
      return ReceiptVerificationResult.failure('영수증 검증 중 오류가 발생했습니다: $e');
    }
  }

  /// 테스트 환경 영수증 검증
  ReceiptVerificationResult _verifyTestReceipt(
    PurchaseDetails purchaseDetails,
  ) {
    // 테스트 환경에서는 항상 성공으로 처리
    final subscriptionType = SubscriptionConstants.getSubscriptionType(
      purchaseDetails.productID,
    );
    if (subscriptionType == null) {
      return ReceiptVerificationResult.failure('알 수 없는 제품 ID입니다.');
    }

    return ReceiptVerificationResult.success(
      subscriptionType: subscriptionType,
      expiresAt: _calculateTestExpiryDate(subscriptionType),
      isTestEnvironment: true,
    );
  }

  /// 테스트 환경 만료일 계산
  DateTime? _calculateTestExpiryDate(String subscriptionType) {
    final now = DateTime.now();

    switch (subscriptionType) {
      case SubscriptionConstants.monthlyType:
        return now.add(const Duration(days: 30));
      case SubscriptionConstants.yearlyType:
        return now.add(const Duration(days: 365));
      case SubscriptionConstants.lifetimeType:
        return null; // 평생 이용권은 만료일 없음
      default:
        return null;
    }
  }

  /// 검증 응답 파싱
  ReceiptVerificationResult _parseVerificationResponse(
    Map<String, dynamic> responseData,
  ) {
    try {
      final bool isValid = (responseData['valid'] as bool?) ?? false;
      if (!isValid) {
        return ReceiptVerificationResult.failure(
          (responseData['error'] as String?) ?? '영수증이 유효하지 않습니다.',
        );
      }

      final String subscriptionType =
          (responseData['subscriptionType'] as String?) ?? '';
      final int? expiresAtTimestamp = responseData['expiresAt'] as int?;
      DateTime? expiresAt;

      if (expiresAtTimestamp != null) {
        expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresAtTimestamp);
      }

      return ReceiptVerificationResult.success(
        subscriptionType: subscriptionType,
        expiresAt: expiresAt,
        isTestEnvironment: false,
      );
    } catch (e) {
      debugPrint('Error parsing verification response: $e');
      return ReceiptVerificationResult.failure('응답 파싱 중 오류가 발생했습니다.');
    }
  }

  /// 구독 상태 확인
  ///
  /// 서버에서 현재 구독 상태를 확인합니다.
  Future<SubscriptionStatusResult> checkSubscriptionStatus(
    String userId,
  ) async {
    try {
      if (SubscriptionConstants.isTestEnvironment()) {
        return _getTestSubscriptionStatus(userId);
      }

      final response = await http.get(
        Uri.parse('$_subscriptionStatusUrl?userId=$userId'),
        headers: {
          'Authorization': 'Bearer ${await _getApiKey()}', // 실제 API 키로 변경
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(response.body) as Map<String, dynamic>;
        return _parseSubscriptionStatusResponse(responseData);
      } else {
        debugPrint('Subscription status check failed: ${response.statusCode}');
        return SubscriptionStatusResult.failure(
          '구독 상태 확인에 실패했습니다. (${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
      return SubscriptionStatusResult.failure('구독 상태 확인 중 오류가 발생했습니다: $e');
    }
  }

  /// 테스트 환경 구독 상태
  SubscriptionStatusResult _getTestSubscriptionStatus(String userId) {
    // 테스트 환경에서는 비활성 상태로 반환
    return SubscriptionStatusResult.success(
      isActive: false,
      subscriptionType: null,
      expiresAt: null,
      isTestEnvironment: true,
    );
  }

  /// 구독 상태 응답 파싱
  SubscriptionStatusResult _parseSubscriptionStatusResponse(
    Map<String, dynamic> responseData,
  ) {
    try {
      final bool isActive = (responseData['isActive'] as bool?) ?? false;
      final String? subscriptionType =
          responseData['subscriptionType'] as String?;
      final int? expiresAtTimestamp = responseData['expiresAt'] as int?;
      DateTime? expiresAt;

      if (expiresAtTimestamp != null) {
        expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresAtTimestamp);
      }

      return SubscriptionStatusResult.success(
        isActive: isActive,
        subscriptionType: subscriptionType,
        expiresAt: expiresAt,
        isTestEnvironment: false,
      );
    } catch (e) {
      debugPrint('Error parsing subscription status response: $e');
      return SubscriptionStatusResult.failure('구독 상태 응답 파싱 중 오류가 발생했습니다.');
    }
  }
}

/// 영수증 검증 결과
class ReceiptVerificationResult {
  final bool isSuccess;
  final String? errorMessage;
  final String? subscriptionType;
  final DateTime? expiresAt;
  final bool isTestEnvironment;

  const ReceiptVerificationResult._({
    required this.isSuccess,
    this.errorMessage,
    this.subscriptionType,
    this.expiresAt,
    required this.isTestEnvironment,
  });

  factory ReceiptVerificationResult.success({
    required String subscriptionType,
    DateTime? expiresAt,
    required bool isTestEnvironment,
  }) {
    return ReceiptVerificationResult._(
      isSuccess: true,
      subscriptionType: subscriptionType,
      expiresAt: expiresAt,
      isTestEnvironment: isTestEnvironment,
    );
  }

  factory ReceiptVerificationResult.failure(String errorMessage) {
    return ReceiptVerificationResult._(
      isSuccess: false,
      errorMessage: errorMessage,
      isTestEnvironment: false,
    );
  }
}

/// 구독 상태 확인 결과
class SubscriptionStatusResult {
  final bool isSuccess;
  final String? errorMessage;
  final bool isActive;
  final String? subscriptionType;
  final DateTime? expiresAt;
  final bool isTestEnvironment;

  const SubscriptionStatusResult._({
    required this.isSuccess,
    this.errorMessage,
    required this.isActive,
    this.subscriptionType,
    this.expiresAt,
    required this.isTestEnvironment,
  });

  factory SubscriptionStatusResult.success({
    required bool isActive,
    String? subscriptionType,
    DateTime? expiresAt,
    required bool isTestEnvironment,
  }) {
    return SubscriptionStatusResult._(
      isSuccess: true,
      isActive: isActive,
      subscriptionType: subscriptionType,
      expiresAt: expiresAt,
      isTestEnvironment: isTestEnvironment,
    );
  }

  factory SubscriptionStatusResult.failure(String errorMessage) {
    return SubscriptionStatusResult._(
      isSuccess: false,
      errorMessage: errorMessage,
      isActive: false,
      isTestEnvironment: false,
    );
  }
}

/// 패키지명 가져오기
Future<String> _getPackageName() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final packageName = prefs.getString('app_package_name');
    if (packageName != null && packageName.isNotEmpty) {
      return packageName;
    }

    // 기본 패키지명 반환
    return 'com.everydiary.app';
  } catch (e) {
    debugPrint('Error getting package name: $e');
    return 'com.everydiary.app';
  }
}

/// API 키 가져오기
Future<String> _getApiKey() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('receipt_verification_api_key');
    if (apiKey != null && apiKey.isNotEmpty) {
      return apiKey;
    }

    // 환경에 따른 기본 API 키
    if (SubscriptionConstants.isTestEnvironment()) {
      return 'test_api_key_12345';
    }
    return 'prod_api_key_67890';
  } catch (e) {
    debugPrint('Error getting API key: $e');
    return 'default_api_key';
  }
}
