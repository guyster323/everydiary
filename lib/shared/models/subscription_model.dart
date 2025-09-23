import 'package:freezed_annotation/freezed_annotation.dart';
import '../constants/subscription_constants.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

/// 구독 모델
@freezed
class SubscriptionModel with _$SubscriptionModel {
  const factory SubscriptionModel({
    required String id,
    required String productId,
    required String userId,
    required String status,
    required String planType,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? expiresAt,
    DateTime? canceledAt,
    String? transactionId,
    String? originalTransactionId,
    String? promoCode,
    double? discountAmount,
    @Default(false) bool isActive,
    @Default(false) bool isExpired,
    @Default(false) bool isCanceled,
  }) = _SubscriptionModel;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);
}

/// 구독 상태 열거형
enum SubscriptionStatus {
  @JsonValue('active')
  active,
  @JsonValue('expired')
  expired,
  @JsonValue('canceled')
  canceled,
  @JsonValue('pending')
  pending,
}

/// 구독 플랜 타입 열거형
enum SubscriptionPlanType {
  @JsonValue('monthly')
  monthly,
  @JsonValue('yearly')
  yearly,
  @JsonValue('lifetime')
  lifetime,
}

/// 구독 혜택 모델
@freezed
class SubscriptionBenefit with _$SubscriptionBenefit {
  const factory SubscriptionBenefit({
    required String id,
    required String title,
    required String description,
    required String icon,
    @Default(false) bool isExclusive,
  }) = _SubscriptionBenefit;

  factory SubscriptionBenefit.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionBenefitFromJson(json);
}

/// 구독 플랜 모델
@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,
    required String name,
    required String description,
    required int price,
    required String currency,
    required String period,
    required SubscriptionPlanType planType,
    required List<SubscriptionBenefit> benefits,
    @Default(false) bool isPopular,
    @Default(false) bool isAvailable,
    String? promoCode,
    double? discountPercentage,
    int? originalPrice,
  }) = _SubscriptionPlan;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanFromJson(json);
}

/// 구독 모델 확장 메서드
extension SubscriptionModelExtension on SubscriptionModel {
  /// 구독이 활성 상태인지 확인
  bool get isCurrentlyActive {
    if (!isActive || isCanceled) return false;
    if (planType == SubscriptionConstants.lifetimeType) return true;
    if (expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// 구독 만료까지 남은 일수
  int? get daysUntilExpiry {
    if (planType == SubscriptionConstants.lifetimeType) return null;
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return 0;
    return expiresAt!.difference(now).inDays;
  }

  /// 구독 플랜 표시 이름
  String get displayName {
    return SubscriptionConstants.getDisplayName(planType);
  }

  /// 구독 가격
  int? get price {
    return SubscriptionConstants.getPrice(productId);
  }

  /// 포맷된 가격
  String? get formattedPrice {
    final price = this.price;
    if (price == null) return null;
    return SubscriptionConstants.formatPrice(price);
  }

  /// 다음 결제일 (구독의 경우)
  DateTime? get nextBillingDate {
    if (planType == SubscriptionConstants.lifetimeType) return null;
    if (expiresAt == null) return null;
    return expiresAt;
  }

  /// 구독 취소 가능 여부
  bool get canCancel {
    return isActive &&
        !isCanceled &&
        planType != SubscriptionConstants.lifetimeType;
  }

  /// 구독 갱신 가능 여부
  bool get canRenew {
    return isActive &&
        !isCanceled &&
        planType != SubscriptionConstants.lifetimeType;
  }
}

/// 구독 플랜 확장 메서드
extension SubscriptionPlanExtension on SubscriptionPlan {
  /// 할인된 가격
  int get discountedPrice {
    if (discountPercentage != null && discountPercentage! > 0) {
      return (price * (1 - discountPercentage! / 100)).round();
    }
    return price;
  }

  /// 포맷된 가격
  String get formattedPrice {
    return SubscriptionConstants.formatPrice(price);
  }

  /// 포맷된 할인 가격
  String get formattedDiscountedPrice {
    return SubscriptionConstants.formatPrice(discountedPrice);
  }

  /// 할인 금액
  int get discountAmount {
    return price - discountedPrice;
  }

  /// 포맷된 할인 금액
  String get formattedDiscountAmount {
    return SubscriptionConstants.formatPrice(discountAmount);
  }

  /// 할인 비율 표시
  String? get discountPercentageText {
    if (discountPercentage != null && discountPercentage! > 0) {
      return '${discountPercentage!.toInt()}% 할인';
    }
    return null;
  }

  /// 월간 가격 (연간 구독의 경우)
  double? get monthlyPrice {
    if (planType == SubscriptionPlanType.yearly) {
      return discountedPrice / 12;
    }
    return null;
  }

  /// 포맷된 월간 가격
  String? get formattedMonthlyPrice {
    final monthly = monthlyPrice;
    if (monthly == null) return null;
    return SubscriptionConstants.formatPrice(monthly.round());
  }
}

