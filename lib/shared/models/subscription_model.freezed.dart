// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) {
  return _SubscriptionModel.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionModel {
  String get id => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get planType => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  DateTime? get canceledAt => throw _privateConstructorUsedError;
  String? get transactionId => throw _privateConstructorUsedError;
  String? get originalTransactionId => throw _privateConstructorUsedError;
  String? get promoCode => throw _privateConstructorUsedError;
  double? get discountAmount => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isExpired => throw _privateConstructorUsedError;
  bool get isCanceled => throw _privateConstructorUsedError;

  /// Serializes this SubscriptionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionModelCopyWith<SubscriptionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionModelCopyWith<$Res> {
  factory $SubscriptionModelCopyWith(
    SubscriptionModel value,
    $Res Function(SubscriptionModel) then,
  ) = _$SubscriptionModelCopyWithImpl<$Res, SubscriptionModel>;
  @useResult
  $Res call({
    String id,
    String productId,
    String userId,
    String status,
    String planType,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? expiresAt,
    DateTime? canceledAt,
    String? transactionId,
    String? originalTransactionId,
    String? promoCode,
    double? discountAmount,
    bool isActive,
    bool isExpired,
    bool isCanceled,
  });
}

/// @nodoc
class _$SubscriptionModelCopyWithImpl<$Res, $Val extends SubscriptionModel>
    implements $SubscriptionModelCopyWith<$Res> {
  _$SubscriptionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? userId = null,
    Object? status = null,
    Object? planType = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? expiresAt = freezed,
    Object? canceledAt = freezed,
    Object? transactionId = freezed,
    Object? originalTransactionId = freezed,
    Object? promoCode = freezed,
    Object? discountAmount = freezed,
    Object? isActive = null,
    Object? isExpired = null,
    Object? isCanceled = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            planType: null == planType
                ? _value.planType
                : planType // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            canceledAt: freezed == canceledAt
                ? _value.canceledAt
                : canceledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            transactionId: freezed == transactionId
                ? _value.transactionId
                : transactionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            originalTransactionId: freezed == originalTransactionId
                ? _value.originalTransactionId
                : originalTransactionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            promoCode: freezed == promoCode
                ? _value.promoCode
                : promoCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            discountAmount: freezed == discountAmount
                ? _value.discountAmount
                : discountAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            isExpired: null == isExpired
                ? _value.isExpired
                : isExpired // ignore: cast_nullable_to_non_nullable
                      as bool,
            isCanceled: null == isCanceled
                ? _value.isCanceled
                : isCanceled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionModelImplCopyWith<$Res>
    implements $SubscriptionModelCopyWith<$Res> {
  factory _$$SubscriptionModelImplCopyWith(
    _$SubscriptionModelImpl value,
    $Res Function(_$SubscriptionModelImpl) then,
  ) = __$$SubscriptionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String productId,
    String userId,
    String status,
    String planType,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? expiresAt,
    DateTime? canceledAt,
    String? transactionId,
    String? originalTransactionId,
    String? promoCode,
    double? discountAmount,
    bool isActive,
    bool isExpired,
    bool isCanceled,
  });
}

/// @nodoc
class __$$SubscriptionModelImplCopyWithImpl<$Res>
    extends _$SubscriptionModelCopyWithImpl<$Res, _$SubscriptionModelImpl>
    implements _$$SubscriptionModelImplCopyWith<$Res> {
  __$$SubscriptionModelImplCopyWithImpl(
    _$SubscriptionModelImpl _value,
    $Res Function(_$SubscriptionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? userId = null,
    Object? status = null,
    Object? planType = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? expiresAt = freezed,
    Object? canceledAt = freezed,
    Object? transactionId = freezed,
    Object? originalTransactionId = freezed,
    Object? promoCode = freezed,
    Object? discountAmount = freezed,
    Object? isActive = null,
    Object? isExpired = null,
    Object? isCanceled = null,
  }) {
    return _then(
      _$SubscriptionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        planType: null == planType
            ? _value.planType
            : planType // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        canceledAt: freezed == canceledAt
            ? _value.canceledAt
            : canceledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        transactionId: freezed == transactionId
            ? _value.transactionId
            : transactionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        originalTransactionId: freezed == originalTransactionId
            ? _value.originalTransactionId
            : originalTransactionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        promoCode: freezed == promoCode
            ? _value.promoCode
            : promoCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        discountAmount: freezed == discountAmount
            ? _value.discountAmount
            : discountAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        isExpired: null == isExpired
            ? _value.isExpired
            : isExpired // ignore: cast_nullable_to_non_nullable
                  as bool,
        isCanceled: null == isCanceled
            ? _value.isCanceled
            : isCanceled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionModelImpl implements _SubscriptionModel {
  const _$SubscriptionModelImpl({
    required this.id,
    required this.productId,
    required this.userId,
    required this.status,
    required this.planType,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
    this.canceledAt,
    this.transactionId,
    this.originalTransactionId,
    this.promoCode,
    this.discountAmount,
    this.isActive = false,
    this.isExpired = false,
    this.isCanceled = false,
  });

  factory _$SubscriptionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String productId;
  @override
  final String userId;
  @override
  final String status;
  @override
  final String planType;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? expiresAt;
  @override
  final DateTime? canceledAt;
  @override
  final String? transactionId;
  @override
  final String? originalTransactionId;
  @override
  final String? promoCode;
  @override
  final double? discountAmount;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isExpired;
  @override
  @JsonKey()
  final bool isCanceled;

  @override
  String toString() {
    return 'SubscriptionModel(id: $id, productId: $productId, userId: $userId, status: $status, planType: $planType, createdAt: $createdAt, updatedAt: $updatedAt, expiresAt: $expiresAt, canceledAt: $canceledAt, transactionId: $transactionId, originalTransactionId: $originalTransactionId, promoCode: $promoCode, discountAmount: $discountAmount, isActive: $isActive, isExpired: $isExpired, isCanceled: $isCanceled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.planType, planType) ||
                other.planType == planType) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.canceledAt, canceledAt) ||
                other.canceledAt == canceledAt) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.originalTransactionId, originalTransactionId) ||
                other.originalTransactionId == originalTransactionId) &&
            (identical(other.promoCode, promoCode) ||
                other.promoCode == promoCode) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isExpired, isExpired) ||
                other.isExpired == isExpired) &&
            (identical(other.isCanceled, isCanceled) ||
                other.isCanceled == isCanceled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    productId,
    userId,
    status,
    planType,
    createdAt,
    updatedAt,
    expiresAt,
    canceledAt,
    transactionId,
    originalTransactionId,
    promoCode,
    discountAmount,
    isActive,
    isExpired,
    isCanceled,
  );

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionModelImplCopyWith<_$SubscriptionModelImpl> get copyWith =>
      __$$SubscriptionModelImplCopyWithImpl<_$SubscriptionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionModelImplToJson(this);
  }
}

abstract class _SubscriptionModel implements SubscriptionModel {
  const factory _SubscriptionModel({
    required final String id,
    required final String productId,
    required final String userId,
    required final String status,
    required final String planType,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? expiresAt,
    final DateTime? canceledAt,
    final String? transactionId,
    final String? originalTransactionId,
    final String? promoCode,
    final double? discountAmount,
    final bool isActive,
    final bool isExpired,
    final bool isCanceled,
  }) = _$SubscriptionModelImpl;

  factory _SubscriptionModel.fromJson(Map<String, dynamic> json) =
      _$SubscriptionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get productId;
  @override
  String get userId;
  @override
  String get status;
  @override
  String get planType;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get expiresAt;
  @override
  DateTime? get canceledAt;
  @override
  String? get transactionId;
  @override
  String? get originalTransactionId;
  @override
  String? get promoCode;
  @override
  double? get discountAmount;
  @override
  bool get isActive;
  @override
  bool get isExpired;
  @override
  bool get isCanceled;

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionModelImplCopyWith<_$SubscriptionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubscriptionBenefit _$SubscriptionBenefitFromJson(Map<String, dynamic> json) {
  return _SubscriptionBenefit.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionBenefit {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  bool get isExclusive => throw _privateConstructorUsedError;

  /// Serializes this SubscriptionBenefit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionBenefit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionBenefitCopyWith<SubscriptionBenefit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionBenefitCopyWith<$Res> {
  factory $SubscriptionBenefitCopyWith(
    SubscriptionBenefit value,
    $Res Function(SubscriptionBenefit) then,
  ) = _$SubscriptionBenefitCopyWithImpl<$Res, SubscriptionBenefit>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String icon,
    bool isExclusive,
  });
}

/// @nodoc
class _$SubscriptionBenefitCopyWithImpl<$Res, $Val extends SubscriptionBenefit>
    implements $SubscriptionBenefitCopyWith<$Res> {
  _$SubscriptionBenefitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionBenefit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? icon = null,
    Object? isExclusive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            isExclusive: null == isExclusive
                ? _value.isExclusive
                : isExclusive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionBenefitImplCopyWith<$Res>
    implements $SubscriptionBenefitCopyWith<$Res> {
  factory _$$SubscriptionBenefitImplCopyWith(
    _$SubscriptionBenefitImpl value,
    $Res Function(_$SubscriptionBenefitImpl) then,
  ) = __$$SubscriptionBenefitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String icon,
    bool isExclusive,
  });
}

/// @nodoc
class __$$SubscriptionBenefitImplCopyWithImpl<$Res>
    extends _$SubscriptionBenefitCopyWithImpl<$Res, _$SubscriptionBenefitImpl>
    implements _$$SubscriptionBenefitImplCopyWith<$Res> {
  __$$SubscriptionBenefitImplCopyWithImpl(
    _$SubscriptionBenefitImpl _value,
    $Res Function(_$SubscriptionBenefitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionBenefit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? icon = null,
    Object? isExclusive = null,
  }) {
    return _then(
      _$SubscriptionBenefitImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        isExclusive: null == isExclusive
            ? _value.isExclusive
            : isExclusive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionBenefitImpl implements _SubscriptionBenefit {
  const _$SubscriptionBenefitImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isExclusive = false,
  });

  factory _$SubscriptionBenefitImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionBenefitImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String icon;
  @override
  @JsonKey()
  final bool isExclusive;

  @override
  String toString() {
    return 'SubscriptionBenefit(id: $id, title: $title, description: $description, icon: $icon, isExclusive: $isExclusive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionBenefitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.isExclusive, isExclusive) ||
                other.isExclusive == isExclusive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, description, icon, isExclusive);

  /// Create a copy of SubscriptionBenefit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionBenefitImplCopyWith<_$SubscriptionBenefitImpl> get copyWith =>
      __$$SubscriptionBenefitImplCopyWithImpl<_$SubscriptionBenefitImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionBenefitImplToJson(this);
  }
}

abstract class _SubscriptionBenefit implements SubscriptionBenefit {
  const factory _SubscriptionBenefit({
    required final String id,
    required final String title,
    required final String description,
    required final String icon,
    final bool isExclusive,
  }) = _$SubscriptionBenefitImpl;

  factory _SubscriptionBenefit.fromJson(Map<String, dynamic> json) =
      _$SubscriptionBenefitImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get icon;
  @override
  bool get isExclusive;

  /// Create a copy of SubscriptionBenefit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionBenefitImplCopyWith<_$SubscriptionBenefitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubscriptionPlan _$SubscriptionPlanFromJson(Map<String, dynamic> json) {
  return _SubscriptionPlan.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionPlan {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get period => throw _privateConstructorUsedError;
  SubscriptionPlanType get planType => throw _privateConstructorUsedError;
  List<SubscriptionBenefit> get benefits => throw _privateConstructorUsedError;
  bool get isPopular => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  String? get promoCode => throw _privateConstructorUsedError;
  double? get discountPercentage => throw _privateConstructorUsedError;
  int? get originalPrice => throw _privateConstructorUsedError;

  /// Serializes this SubscriptionPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionPlanCopyWith<SubscriptionPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionPlanCopyWith<$Res> {
  factory $SubscriptionPlanCopyWith(
    SubscriptionPlan value,
    $Res Function(SubscriptionPlan) then,
  ) = _$SubscriptionPlanCopyWithImpl<$Res, SubscriptionPlan>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    int price,
    String currency,
    String period,
    SubscriptionPlanType planType,
    List<SubscriptionBenefit> benefits,
    bool isPopular,
    bool isAvailable,
    String? promoCode,
    double? discountPercentage,
    int? originalPrice,
  });
}

/// @nodoc
class _$SubscriptionPlanCopyWithImpl<$Res, $Val extends SubscriptionPlan>
    implements $SubscriptionPlanCopyWith<$Res> {
  _$SubscriptionPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? price = null,
    Object? currency = null,
    Object? period = null,
    Object? planType = null,
    Object? benefits = null,
    Object? isPopular = null,
    Object? isAvailable = null,
    Object? promoCode = freezed,
    Object? discountPercentage = freezed,
    Object? originalPrice = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as int,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            period: null == period
                ? _value.period
                : period // ignore: cast_nullable_to_non_nullable
                      as String,
            planType: null == planType
                ? _value.planType
                : planType // ignore: cast_nullable_to_non_nullable
                      as SubscriptionPlanType,
            benefits: null == benefits
                ? _value.benefits
                : benefits // ignore: cast_nullable_to_non_nullable
                      as List<SubscriptionBenefit>,
            isPopular: null == isPopular
                ? _value.isPopular
                : isPopular // ignore: cast_nullable_to_non_nullable
                      as bool,
            isAvailable: null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
            promoCode: freezed == promoCode
                ? _value.promoCode
                : promoCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            discountPercentage: freezed == discountPercentage
                ? _value.discountPercentage
                : discountPercentage // ignore: cast_nullable_to_non_nullable
                      as double?,
            originalPrice: freezed == originalPrice
                ? _value.originalPrice
                : originalPrice // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionPlanImplCopyWith<$Res>
    implements $SubscriptionPlanCopyWith<$Res> {
  factory _$$SubscriptionPlanImplCopyWith(
    _$SubscriptionPlanImpl value,
    $Res Function(_$SubscriptionPlanImpl) then,
  ) = __$$SubscriptionPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    int price,
    String currency,
    String period,
    SubscriptionPlanType planType,
    List<SubscriptionBenefit> benefits,
    bool isPopular,
    bool isAvailable,
    String? promoCode,
    double? discountPercentage,
    int? originalPrice,
  });
}

/// @nodoc
class __$$SubscriptionPlanImplCopyWithImpl<$Res>
    extends _$SubscriptionPlanCopyWithImpl<$Res, _$SubscriptionPlanImpl>
    implements _$$SubscriptionPlanImplCopyWith<$Res> {
  __$$SubscriptionPlanImplCopyWithImpl(
    _$SubscriptionPlanImpl _value,
    $Res Function(_$SubscriptionPlanImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? price = null,
    Object? currency = null,
    Object? period = null,
    Object? planType = null,
    Object? benefits = null,
    Object? isPopular = null,
    Object? isAvailable = null,
    Object? promoCode = freezed,
    Object? discountPercentage = freezed,
    Object? originalPrice = freezed,
  }) {
    return _then(
      _$SubscriptionPlanImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as int,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        period: null == period
            ? _value.period
            : period // ignore: cast_nullable_to_non_nullable
                  as String,
        planType: null == planType
            ? _value.planType
            : planType // ignore: cast_nullable_to_non_nullable
                  as SubscriptionPlanType,
        benefits: null == benefits
            ? _value._benefits
            : benefits // ignore: cast_nullable_to_non_nullable
                  as List<SubscriptionBenefit>,
        isPopular: null == isPopular
            ? _value.isPopular
            : isPopular // ignore: cast_nullable_to_non_nullable
                  as bool,
        isAvailable: null == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
        promoCode: freezed == promoCode
            ? _value.promoCode
            : promoCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        discountPercentage: freezed == discountPercentage
            ? _value.discountPercentage
            : discountPercentage // ignore: cast_nullable_to_non_nullable
                  as double?,
        originalPrice: freezed == originalPrice
            ? _value.originalPrice
            : originalPrice // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionPlanImpl implements _SubscriptionPlan {
  const _$SubscriptionPlanImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.period,
    required this.planType,
    required final List<SubscriptionBenefit> benefits,
    this.isPopular = false,
    this.isAvailable = false,
    this.promoCode,
    this.discountPercentage,
    this.originalPrice,
  }) : _benefits = benefits;

  factory _$SubscriptionPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionPlanImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final int price;
  @override
  final String currency;
  @override
  final String period;
  @override
  final SubscriptionPlanType planType;
  final List<SubscriptionBenefit> _benefits;
  @override
  List<SubscriptionBenefit> get benefits {
    if (_benefits is EqualUnmodifiableListView) return _benefits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_benefits);
  }

  @override
  @JsonKey()
  final bool isPopular;
  @override
  @JsonKey()
  final bool isAvailable;
  @override
  final String? promoCode;
  @override
  final double? discountPercentage;
  @override
  final int? originalPrice;

  @override
  String toString() {
    return 'SubscriptionPlan(id: $id, name: $name, description: $description, price: $price, currency: $currency, period: $period, planType: $planType, benefits: $benefits, isPopular: $isPopular, isAvailable: $isAvailable, promoCode: $promoCode, discountPercentage: $discountPercentage, originalPrice: $originalPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.planType, planType) ||
                other.planType == planType) &&
            const DeepCollectionEquality().equals(other._benefits, _benefits) &&
            (identical(other.isPopular, isPopular) ||
                other.isPopular == isPopular) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.promoCode, promoCode) ||
                other.promoCode == promoCode) &&
            (identical(other.discountPercentage, discountPercentage) ||
                other.discountPercentage == discountPercentage) &&
            (identical(other.originalPrice, originalPrice) ||
                other.originalPrice == originalPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    price,
    currency,
    period,
    planType,
    const DeepCollectionEquality().hash(_benefits),
    isPopular,
    isAvailable,
    promoCode,
    discountPercentage,
    originalPrice,
  );

  /// Create a copy of SubscriptionPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionPlanImplCopyWith<_$SubscriptionPlanImpl> get copyWith =>
      __$$SubscriptionPlanImplCopyWithImpl<_$SubscriptionPlanImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionPlanImplToJson(this);
  }
}

abstract class _SubscriptionPlan implements SubscriptionPlan {
  const factory _SubscriptionPlan({
    required final String id,
    required final String name,
    required final String description,
    required final int price,
    required final String currency,
    required final String period,
    required final SubscriptionPlanType planType,
    required final List<SubscriptionBenefit> benefits,
    final bool isPopular,
    final bool isAvailable,
    final String? promoCode,
    final double? discountPercentage,
    final int? originalPrice,
  }) = _$SubscriptionPlanImpl;

  factory _SubscriptionPlan.fromJson(Map<String, dynamic> json) =
      _$SubscriptionPlanImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  int get price;
  @override
  String get currency;
  @override
  String get period;
  @override
  SubscriptionPlanType get planType;
  @override
  List<SubscriptionBenefit> get benefits;
  @override
  bool get isPopular;
  @override
  bool get isAvailable;
  @override
  String? get promoCode;
  @override
  double? get discountPercentage;
  @override
  int? get originalPrice;

  /// Create a copy of SubscriptionPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionPlanImplCopyWith<_$SubscriptionPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
