import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/generation_count_provider.dart';
import '../../../core/providers/localization_provider.dart';
import '../../../shared/constants/subscription_constants.dart';
import '../../../shared/services/ad_service.dart';
import '../../../shared/services/payment_service.dart';

/// 이미지 생성 횟수 구매 다이얼로그
class ImageGenerationPurchaseDialog extends ConsumerWidget {
  const ImageGenerationPurchaseDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(localizationProvider);

    return AlertDialog(
      title: Text(l10n.get('image_generation_count')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.get('image_generation_description'),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),

            // 광고 시청 옵션 (항상 표시)
            Card(
              color: AdService.instance.isRewardedAdReady
                  ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.3)
                  : theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
              child: InkWell(
                onTap: AdService.instance.isRewardedAdReady
                    ? () => _watchAdForReward(context, ref)
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        AdService.instance.isRewardedAdReady
                            ? Icons.play_circle_outline
                            : Icons.hourglass_empty,
                        color: AdService.instance.isRewardedAdReady
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AdService.instance.isRewardedAdReady
                                  ? l10n.get('watch_ad_for_1_time')
                                  : l10n.get('ad_loading'),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AdService.instance.isRewardedAdReady
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AdService.instance.isRewardedAdReady
                                  ? l10n.get('watch_ad_subtitle')
                                  : l10n.get('ad_wait'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AdService.instance.isRewardedAdReady
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              l10n.get('or_purchase'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 10회 구매 옵션
            _buildPurchaseOption(
              context,
              l10n,
              icon: Icons.add_circle_outline,
              title: l10n.get('purchase_10_times'),
              price: SubscriptionConstants.formatPrice(
                SubscriptionConstants.imageGen10Price,
              ),
              onTap: () => _handlePurchase(
                context,
                ref,
                SubscriptionConstants.imageGen10Id,
              ),
            ),
            const SizedBox(height: 12),

            // 30회 구매 옵션 (인기)
            _buildPurchaseOption(
              context,
              l10n,
              icon: Icons.add_circle,
              title: l10n.get('purchase_30_times'),
              subtitle: l10n.get('purchase_popular'),
              price: SubscriptionConstants.formatPrice(
                SubscriptionConstants.imageGen30Price,
              ),
              onTap: () => _handlePurchase(
                context,
                ref,
                SubscriptionConstants.imageGen30Id,
              ),
              isHighlighted: true,
            ),
            const SizedBox(height: 12),

            // 100회 구매 옵션 (최고 가성비)
            _buildPurchaseOption(
              context,
              l10n,
              icon: Icons.add_circle,
              title: l10n.get('purchase_100_times'),
              subtitle: l10n.get('purchase_best_value'),
              price: SubscriptionConstants.formatPrice(
                SubscriptionConstants.imageGen100Price,
              ),
              onTap: () => _handlePurchase(
                context,
                ref,
                SubscriptionConstants.imageGen100Id,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.get('close')),
        ),
      ],
    );
  }

  Widget _buildPurchaseOption(
    BuildContext context,
    AppLocalizations l10n, {
    required IconData icon,
    required String title,
    String? subtitle,
    required String price,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: isHighlighted ? 2 : 0,
      color: isHighlighted
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isHighlighted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isHighlighted
                                ? theme.colorScheme.primary
                                : null,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              subtitle,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isHighlighted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 광고 시청하고 보상 받기
  Future<void> _watchAdForReward(BuildContext context, WidgetRef ref) async {
    // context를 미리 저장
    if (!context.mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // ref도 미리 저장
    final countService = ref.read(generationCountServiceProvider);

    // 다이얼로그 닫기
    navigator.pop();

    debugPrint('🔵 [AdReward] 광고 시청 시작');

    // l10n도 미리 저장
    final l10n = ref.read(localizationProvider);

    AdService.instance.showRewardedAd(
      onRewarded: (amount) {
        debugPrint('🔵 [AdReward] 광고 시청 완료, 보상 지급 시작: amount=$amount');
        // 광고 시청 완료 - 1회 생성 횟수 추가
        countService.addGenerations(1).then((_) {
          debugPrint('✅ [AdReward] 보상 지급 성공');
          messenger.showSnackBar(
            SnackBar(
              content: Text(l10n.get('ad_reward_success')),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }).catchError((Object e) {
          debugPrint('❌ [AdReward] 보상 지급 실패: $e');
          messenger.showSnackBar(
            SnackBar(
              content: Text('보상 지급 실패: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        });
      },
      onFailed: () {
        debugPrint('❌ [AdReward] 광고 로드 실패');
        messenger.showSnackBar(
          const SnackBar(
            content: Text('광고를 불러올 수 없습니다. 나중에 다시 시도해주세요.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      },
    );
  }

  /// 구매 처리
  Future<void> _handlePurchase(
    BuildContext context,
    WidgetRef ref,
    String productId,
  ) async {
    if (!context.mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // 다이얼로그 닫기
    navigator.pop();

    try {
      debugPrint('🔵 [Purchase] 구매 시작: $productId');

      // PaymentService를 통해 구매 시작
      final paymentService = PaymentService();

      // 인앱 구매 사용 가능 여부 확인
      if (!paymentService.isAvailable) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('인앱 구매를 사용할 수 없습니다.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 구매 시작
      final purchased = await paymentService.purchaseProduct(productId);

      if (purchased) {
        debugPrint('✅ [Purchase] 구매 성공: $productId');

        // GenerationCountProvider 새로고침
        await ref.read(generationCountServiceProvider).reload();

        messenger.showSnackBar(
          const SnackBar(
            content: Text('구매가 완료되었습니다!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        debugPrint('❌ [Purchase] 구매 취소 또는 실패: $productId');
        messenger.showSnackBar(
          const SnackBar(
            content: Text('구매가 취소되었습니다.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ [Purchase] 구매 오류: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text('구매 중 오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
