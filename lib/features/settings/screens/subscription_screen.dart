import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/payment_error_dialog.dart';
import '../../../shared/constants/subscription_constants.dart';
import '../../../shared/data/subscription_plans_data.dart';
import '../../../shared/models/payment_error_model.dart';
import '../../../shared/models/subscription_model.dart' as models;
import '../../../shared/providers/subscription_provider.dart';
import '../../../shared/services/payment_error_handler.dart';

/// 구독 화면
///
/// 사용자가 구독 플랜을 비교하고 결제할 수 있는 화면입니다.
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<models.SubscriptionPlan> _plans = [];
  String? _promoCode;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  /// 화면 초기화
  Future<void> _initializeScreen() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 구독 상태 확인
      await ref.read(subscriptionProvider.notifier).checkSubscriptionStatus();

      // 구독 플랜 로드
      _loadSubscriptionPlans();
    } catch (e) {
      setState(() {
        _errorMessage = '화면 초기화 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 구독 플랜 로드
  void _loadSubscriptionPlans() {
    if (_promoCode != null && _promoCode!.isNotEmpty) {
      _plans = SubscriptionPlansData.getPromotionalPlans(_promoCode!);
    } else {
      _plans = SubscriptionPlansData.defaultPlans;
    }
  }

  /// 제품 구매 처리
  Future<void> _handlePurchase(String productId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bool success = await ref
          .read(subscriptionProvider.notifier)
          .purchaseProduct(productId);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('구매가 시작되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // 구매 실패 시 오류 다이얼로그 표시
        if (mounted) {
          const error = PaymentError(
            type: PaymentErrorType.unknownError,
            message: '구매 처리 중 오류가 발생했습니다.',
            details: '결제 서비스를 다시 시도해주세요.',
            isRetryable: true,
            retryAction: '다시 시도',
          );

          await PaymentErrorDialog.show(
            context,
            error,
            onRetry: () => _handlePurchase(productId),
          );
        }
      }
    } catch (e) {
      // 예외 발생 시 오류 다이얼로그 표시
      if (mounted) {
        final error = PaymentErrorHandler().handleNetworkError(e as Exception);

        await PaymentErrorDialog.show(
          context,
          error,
          onRetry: () => _handlePurchase(productId),
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

  /// 프로모션 코드 적용
  void _applyPromoCode(String code) {
    if (SubscriptionConstants.isValidPromoCode(code)) {
      setState(() {
        _promoCode = code;
        _loadSubscriptionPlans();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로모션 코드가 적용되었습니다: $code'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('유효하지 않은 프로모션 코드입니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionProvider);
    final hasPremiumAccess = ref.watch(hasPremiumAccessProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '프리미엄 구독',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: LoadingWidget())
          : _errorMessage != null
          ? Center(
              child: AppErrorWidget(
                message: _errorMessage!,
                onRetry: _initializeScreen,
              ),
            )
          : _buildContent(subscription, hasPremiumAccess),
    );
  }

  /// 메인 콘텐츠 빌드
  Widget _buildContent(SubscriptionStatus subscription, bool hasPremiumAccess) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 현재 구독 상태
          if (hasPremiumAccess) _buildCurrentSubscriptionStatus(subscription),

          // 프로모션 코드 입력
          _buildPromoCodeSection(),

          const SizedBox(height: 24),

          // 구독 플랜 카드들
          _buildSubscriptionPlans(),

          const SizedBox(height: 24),

          // 구매 복원 버튼
          _buildRestoreButton(),

          const SizedBox(height: 16),

          // 이용약관 링크
          _buildTermsAndConditions(),
        ],
      ),
    );
  }

  /// 현재 구독 상태 표시
  Widget _buildCurrentSubscriptionStatus(SubscriptionStatus subscription) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '프리미엄 구독 활성',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '플랜: ${_getPlanDisplayName(subscription.planType)}',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          if (subscription.expiryDate != null &&
              subscription.planType != 'lifetime')
            Text(
              '만료일: ${_formatDate(subscription.expiryDate!)}',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  /// 구독 플랜 카드들
  Widget _buildSubscriptionPlans() {
    return Column(
      children: _plans.map((plan) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildPlanCard(plan),
        );
      }).toList(),
    );
  }

  /// 구독 플랜 카드
  Widget _buildPlanCard(models.SubscriptionPlan plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plan.isPopular ? AppColors.primary : AppColors.border,
          width: plan.isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 인기 배지
          if (plan.isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '인기',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

          // 할인 배지
          if (plan.discountPercentage != null && plan.discountPercentage! > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                plan.discountPercentageText ?? '',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

          // 제목과 가격
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (plan.description.isNotEmpty)
                      Text(
                        plan.description,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        plan.formattedDiscountedPrice,
                        style: GoogleFonts.notoSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        plan.period == 'lifetime' ? '' : '/${plan.period}',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (plan.originalPrice != null &&
                      plan.originalPrice! > plan.price)
                    Text(
                      plan.formattedPrice,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  if (plan.monthlyPrice != null)
                    Text(
                      '월 ${plan.formattedMonthlyPrice}',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 기능 목록
          ...plan.benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(benefit.icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          benefit.title,
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (benefit.description.isNotEmpty)
                          Text(
                            benefit.description,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (benefit.isExclusive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '독점',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 구매 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _handlePurchase(plan.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: plan.isPopular
                    ? AppColors.primary
                    : AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      plan.planType == models.SubscriptionPlanType.lifetime
                          ? '구매하기'
                          : '구독하기',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// 구매 복원 버튼
  Widget _buildRestoreButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _restorePurchases,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          '구매 복원',
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  /// 프로모션 코드 섹션
  Widget _buildPromoCodeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '프로모션 코드',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '프로모션 코드를 입력하세요',
                    hintStyle: GoogleFonts.notoSans(
                      color: AppColors.textTertiary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _promoCode = value.trim();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _promoCode != null && _promoCode!.isNotEmpty
                    ? () => _applyPromoCode(_promoCode!)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '적용',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (_promoCode != null && _promoCode!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '프로모션 코드가 적용되었습니다: $_promoCode',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: AppColors.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 이용약관 링크
  Widget _buildTermsAndConditions() {
    return Center(
      child: TextButton(
        onPressed: () {
          // 이용약관 화면으로 이동
          context.go('/settings/terms-of-service');
        },
        child: Text(
          '이용약관 및 개인정보처리방침',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: AppColors.textSecondary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  /// 구매 복원
  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bool success = await ref
          .read(subscriptionProvider.notifier)
          .restorePurchases();

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('구매 복원이 완료되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('복원할 구매 내역이 없습니다.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      // 예외 발생 시 오류 다이얼로그 표시
      if (mounted) {
        final error = PaymentErrorHandler().handleNetworkError(e as Exception);

        await PaymentErrorDialog.show(
          context,
          error,
          onRetry: _restorePurchases,
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

  /// 플랜 표시 이름 반환
  String _getPlanDisplayName(String? planType) {
    switch (planType) {
      case 'monthly':
        return '월간 구독';
      case 'yearly':
        return '연간 구독';
      case 'lifetime':
        return '평생 이용권';
      default:
        return '알 수 없음';
    }
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}
