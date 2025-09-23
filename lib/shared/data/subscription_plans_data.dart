import '../models/subscription_model.dart';
import '../constants/subscription_constants.dart';

/// 구독 플랜 데이터
class SubscriptionPlansData {
  /// 기본 구독 플랜들
  static List<SubscriptionPlan> get defaultPlans => [
    monthlyPlan,
    yearlyPlan,
    lifetimePlan,
  ];

  /// 월간 구독 플랜
  static SubscriptionPlan get monthlyPlan => const SubscriptionPlan(
    id: 'monthly',
    name: '월간 구독',
    description: '매월 자동 갱신되는 기본 구독',
    price: 4900,
    currency: 'KRW',
    period: 'month',
    planType: SubscriptionPlanType.monthly,
    benefits: [
      SubscriptionBenefit(
        id: 'unlimited_diary',
        title: '무제한 일기 작성',
        description: '일기 작성 개수 제한 없음',
        icon: '📝',
      ),
      SubscriptionBenefit(
        id: 'premium_templates',
        title: '고급 템플릿 사용',
        description: '프리미엄 일기 템플릿 제공',
        icon: '🎨',
      ),
      SubscriptionBenefit(
        id: 'cloud_sync',
        title: '클라우드 동기화',
        description: '모든 기기에서 데이터 동기화',
        icon: '☁️',
      ),
      SubscriptionBenefit(
        id: 'priority_support',
        title: '우선 고객 지원',
        description: '빠른 고객 지원 서비스',
        icon: '🎧',
      ),
    ],
    isAvailable: true,
  );

  /// 연간 구독 플랜
  static SubscriptionPlan get yearlyPlan => const SubscriptionPlan(
    id: 'yearly',
    name: '연간 구독',
    description: '연간 구독으로 2개월 무료 혜택',
    price: 49000,
    currency: 'KRW',
    period: 'year',
    planType: SubscriptionPlanType.yearly,
    benefits: [
      SubscriptionBenefit(
        id: 'monthly_benefits',
        title: '월간 구독의 모든 기능',
        description: '월간 구독의 모든 혜택 포함',
        icon: '✅',
      ),
      SubscriptionBenefit(
        id: 'two_months_free',
        title: '2개월 무료',
        description: '월간 구독 대비 2개월 무료',
        icon: '🎁',
      ),
      SubscriptionBenefit(
        id: 'exclusive_themes',
        title: '독점 테마',
        description: '연간 구독자만의 독점 테마',
        icon: '🎨',
        isExclusive: true,
      ),
      SubscriptionBenefit(
        id: 'priority_updates',
        title: '우선 업데이트',
        description: '새로운 기능을 먼저 경험',
        icon: '⚡',
        isExclusive: true,
      ),
    ],
    isPopular: true,
    isAvailable: true,
  );

  /// 평생 이용권 플랜
  static SubscriptionPlan get lifetimePlan => const SubscriptionPlan(
    id: 'lifetime',
    name: '평생 이용권',
    description: '한 번 결제로 평생 이용',
    price: 99000,
    currency: 'KRW',
    period: 'lifetime',
    planType: SubscriptionPlanType.lifetime,
    benefits: [
      SubscriptionBenefit(
        id: 'all_premium_features',
        title: '모든 프리미엄 기능',
        description: '현재 및 미래의 모든 프리미엄 기능',
        icon: '👑',
      ),
      SubscriptionBenefit(
        id: 'lifetime_access',
        title: '평생 무제한 사용',
        description: '구독 갱신 없이 평생 이용',
        icon: '♾️',
      ),
      SubscriptionBenefit(
        id: 'future_updates',
        title: '모든 미래 업데이트',
        description: '앞으로 출시될 모든 기능 무료',
        icon: '🚀',
      ),
      SubscriptionBenefit(
        id: 'exclusive_features',
        title: '독점 기능 우선 제공',
        description: '평생 이용권 전용 기능 우선 제공',
        icon: '⭐',
        isExclusive: true,
      ),
    ],
    isAvailable: true,
  );

  /// 프로모션 코드별 할인 플랜
  static List<SubscriptionPlan> getPromotionalPlans(String promoCode) {
    if (!SubscriptionConstants.isValidPromoCode(promoCode)) {
      return defaultPlans;
    }

    // 특별 프로모션 코드 처리
    switch (promoCode.toUpperCase()) {
      case 'EVERYDIARY_LAUNCH':
        return _getLaunchPromoPlans();
      case 'EVERYDIARY_EARLY':
        return _getEarlyBirdPromoPlans();
      case 'EVERYDIARY_STUDENT':
        return _getStudentPromoPlans();
      default:
        return defaultPlans;
    }
  }

  /// 런칭 프로모션 플랜
  static List<SubscriptionPlan> _getLaunchPromoPlans() {
    return [
      monthlyPlan.copyWith(
        discountPercentage: 20.0,
        promoCode: 'EVERYDIARY_LAUNCH',
      ),
      yearlyPlan.copyWith(
        discountPercentage: 30.0,
        promoCode: 'EVERYDIARY_LAUNCH',
      ),
      lifetimePlan.copyWith(
        discountPercentage: 25.0,
        promoCode: 'EVERYDIARY_LAUNCH',
      ),
    ];
  }

  /// 얼리버드 프로모션 플랜
  static List<SubscriptionPlan> _getEarlyBirdPromoPlans() {
    return [
      monthlyPlan.copyWith(
        discountPercentage: 15.0,
        promoCode: 'EVERYDIARY_EARLY',
      ),
      yearlyPlan.copyWith(
        discountPercentage: 25.0,
        promoCode: 'EVERYDIARY_EARLY',
      ),
      lifetimePlan.copyWith(
        discountPercentage: 20.0,
        promoCode: 'EVERYDIARY_EARLY',
      ),
    ];
  }

  /// 학생 프로모션 플랜
  static List<SubscriptionPlan> _getStudentPromoPlans() {
    return [
      monthlyPlan.copyWith(
        discountPercentage: 50.0,
        promoCode: 'EVERYDIARY_STUDENT',
      ),
      yearlyPlan.copyWith(
        discountPercentage: 60.0,
        promoCode: 'EVERYDIARY_STUDENT',
      ),
      lifetimePlan.copyWith(
        discountPercentage: 40.0,
        promoCode: 'EVERYDIARY_STUDENT',
      ),
    ];
  }

  /// 제품 ID로 플랜 찾기
  static SubscriptionPlan? getPlanByProductId(String productId) {
    switch (productId) {
      case SubscriptionConstants.monthlySubscriptionId:
        return monthlyPlan;
      case SubscriptionConstants.yearlySubscriptionId:
        return yearlyPlan;
      case SubscriptionConstants.lifetimePurchaseId:
        return lifetimePlan;
      default:
        return null;
    }
  }

  /// 플랜 타입으로 플랜 찾기
  static SubscriptionPlan? getPlanByType(SubscriptionPlanType planType) {
    switch (planType) {
      case SubscriptionPlanType.monthly:
        return monthlyPlan;
      case SubscriptionPlanType.yearly:
        return yearlyPlan;
      case SubscriptionPlanType.lifetime:
        return lifetimePlan;
    }
  }

  /// 인기 플랜 가져오기
  static SubscriptionPlan get popularPlan => yearlyPlan;

  /// 가장 저렴한 플랜 가져오기
  static SubscriptionPlan get cheapestPlan => monthlyPlan;

  /// 가장 가치 있는 플랜 가져오기 (월간 가격 기준)
  static SubscriptionPlan get bestValuePlan => yearlyPlan;
}

