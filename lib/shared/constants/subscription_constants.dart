import 'package:flutter/foundation.dart';

/// 구독 관련 상수 정의
class SubscriptionConstants {
  // 제품 ID들
  static const String monthlySubscriptionId = 'subscription_monthly';
  static const String yearlySubscriptionId = 'subscription_yearly';
  static const String lifetimePurchaseId = 'lifetime_access';

  // 제품 ID 리스트
  static const Set<String> productIds = {
    monthlySubscriptionId,
    yearlySubscriptionId,
    lifetimePurchaseId,
  };

  // 가격 정보 (한국 원화)
  static const int monthlyPrice = 4900; // ₩4,900
  static const int yearlyPrice = 49000; // ₩49,000
  static const int lifetimePrice = 99000; // ₩99,000

  // 구독 기간 (일 단위)
  static const int monthlyPeriodDays = 30;
  static const int yearlyPeriodDays = 365;

  // 구독 타입
  static const String monthlyType = 'monthly';
  static const String yearlyType = 'yearly';
  static const String lifetimeType = 'lifetime';

  // 구독 상태
  static const String activeStatus = 'active';
  static const String expiredStatus = 'expired';
  static const String canceledStatus = 'canceled';
  static const String pendingStatus = 'pending';

  // 프로모션 코드 관련
  static const String promoCodePrefix = 'EVERYDIARY_';
  static const int maxPromoCodeLength = 20;
  static const int minPromoCodeLength = 8;

  // 테스트 계정 관련
  static const String testAccountSuffix = '@test.com';
  static const List<String> testPromoCodes = [
    'EVERYDIARY_TEST',
    'EVERYDIARY_DEV',
    'EVERYDIARY_FREE',
  ];

  /// 제품 ID로 구독 타입 가져오기
  static String? getSubscriptionType(String productId) {
    switch (productId) {
      case monthlySubscriptionId:
        return monthlyType;
      case yearlySubscriptionId:
        return yearlyType;
      case lifetimePurchaseId:
        return lifetimeType;
      default:
        return null;
    }
  }

  /// 제품 ID로 가격 가져오기
  static int? getPrice(String productId) {
    switch (productId) {
      case monthlySubscriptionId:
        return monthlyPrice;
      case yearlySubscriptionId:
        return yearlyPrice;
      case lifetimePurchaseId:
        return lifetimePrice;
      default:
        return null;
    }
  }

  /// 제품 ID로 기간 가져오기 (일 단위)
  static int? getPeriodDays(String productId) {
    switch (productId) {
      case monthlySubscriptionId:
        return monthlyPeriodDays;
      case yearlySubscriptionId:
        return yearlyPeriodDays;
      case lifetimePurchaseId:
        return null; // 평생 이용권은 기간 없음
      default:
        return null;
    }
  }

  /// 구독 타입으로 표시 이름 가져오기
  static String getDisplayName(String subscriptionType) {
    switch (subscriptionType) {
      case monthlyType:
        return '월간 구독';
      case yearlyType:
        return '연간 구독';
      case lifetimeType:
        return '평생 이용권';
      default:
        return '알 수 없음';
    }
  }

  /// 가격을 포맷된 문자열로 변환
  static String formatPrice(int price) {
    return '₩${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  /// 프로모션 코드 유효성 검사
  static bool isValidPromoCode(String code) {
    if (code.length < minPromoCodeLength || code.length > maxPromoCodeLength) {
      return false;
    }

    if (!code.startsWith(promoCodePrefix)) {
      return false;
    }

    // 영문자, 숫자, 언더스코어만 허용
    return RegExp(r'^[A-Za-z0-9_]+$').hasMatch(code);
  }

  /// 테스트 환경인지 확인
  static bool isTestEnvironment() {
    // 실제 환경 구분 로직 구현
    // 1. Flutter의 kDebugMode를 확인
    if (kDebugMode) {
      return true;
    }

    // 2. 환경 변수 확인 (빌드 시 설정)
    const environment = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'production',
    );
    if (environment == 'test' || environment == 'development') {
      return true;
    }

    // 3. 패키지명으로 구분 (테스트용 패키지명)
    const packageName = String.fromEnvironment(
      'PACKAGE_NAME',
      defaultValue: 'com.everydiary.app',
    );
    if (packageName.contains('test') || packageName.contains('debug')) {
      return true;
    }

    // 4. 기본값은 프로덕션 환경
    return false;
  }
}
