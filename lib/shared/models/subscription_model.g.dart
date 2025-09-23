// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionModelImpl _$$SubscriptionModelImplFromJson(
  Map<String, dynamic> json,
) => _$SubscriptionModelImpl(
  id: json['id'] as String,
  productId: json['productId'] as String,
  userId: json['userId'] as String,
  status: json['status'] as String,
  planType: json['planType'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  canceledAt: json['canceledAt'] == null
      ? null
      : DateTime.parse(json['canceledAt'] as String),
  transactionId: json['transactionId'] as String?,
  originalTransactionId: json['originalTransactionId'] as String?,
  promoCode: json['promoCode'] as String?,
  discountAmount: (json['discountAmount'] as num?)?.toDouble(),
  isActive: json['isActive'] as bool? ?? false,
  isExpired: json['isExpired'] as bool? ?? false,
  isCanceled: json['isCanceled'] as bool? ?? false,
);

Map<String, dynamic> _$$SubscriptionModelImplToJson(
  _$SubscriptionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'userId': instance.userId,
  'status': instance.status,
  'planType': instance.planType,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'canceledAt': instance.canceledAt?.toIso8601String(),
  'transactionId': instance.transactionId,
  'originalTransactionId': instance.originalTransactionId,
  'promoCode': instance.promoCode,
  'discountAmount': instance.discountAmount,
  'isActive': instance.isActive,
  'isExpired': instance.isExpired,
  'isCanceled': instance.isCanceled,
};

_$SubscriptionBenefitImpl _$$SubscriptionBenefitImplFromJson(
  Map<String, dynamic> json,
) => _$SubscriptionBenefitImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  icon: json['icon'] as String,
  isExclusive: json['isExclusive'] as bool? ?? false,
);

Map<String, dynamic> _$$SubscriptionBenefitImplToJson(
  _$SubscriptionBenefitImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'icon': instance.icon,
  'isExclusive': instance.isExclusive,
};

_$SubscriptionPlanImpl _$$SubscriptionPlanImplFromJson(
  Map<String, dynamic> json,
) => _$SubscriptionPlanImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toInt(),
  currency: json['currency'] as String,
  period: json['period'] as String,
  planType: $enumDecode(_$SubscriptionPlanTypeEnumMap, json['planType']),
  benefits: (json['benefits'] as List<dynamic>)
      .map((e) => SubscriptionBenefit.fromJson(e as Map<String, dynamic>))
      .toList(),
  isPopular: json['isPopular'] as bool? ?? false,
  isAvailable: json['isAvailable'] as bool? ?? false,
  promoCode: json['promoCode'] as String?,
  discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
  originalPrice: (json['originalPrice'] as num?)?.toInt(),
);

Map<String, dynamic> _$$SubscriptionPlanImplToJson(
  _$SubscriptionPlanImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'currency': instance.currency,
  'period': instance.period,
  'planType': _$SubscriptionPlanTypeEnumMap[instance.planType]!,
  'benefits': instance.benefits,
  'isPopular': instance.isPopular,
  'isAvailable': instance.isAvailable,
  'promoCode': instance.promoCode,
  'discountPercentage': instance.discountPercentage,
  'originalPrice': instance.originalPrice,
};

const _$SubscriptionPlanTypeEnumMap = {
  SubscriptionPlanType.monthly: 'monthly',
  SubscriptionPlanType.yearly: 'yearly',
  SubscriptionPlanType.lifetime: 'lifetime',
};
