import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/generation_count_provider.dart';
import '../../../shared/constants/subscription_constants.dart';
import '../../../shared/services/ad_service.dart';

/// 이미지 생성 횟수 구매 다이얼로그
class ImageGenerationPurchaseDialog extends ConsumerWidget {
  const ImageGenerationPurchaseDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('AI 이미지 생성 횟수'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'AI가 생성하는 멋진 일기 이미지를 더 많이 만들어보세요!',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),

            // 광고 시청 옵션
            if (AdService.instance.isRewardedAdReady)
              Card(
                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                child: InkWell(
                  onTap: () => _watchAdForReward(context, ref),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          color: theme.colorScheme.secondary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '광고 보고 3회 받기',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '짧은 광고 시청으로 무료로 받으세요',
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
                          color: theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (AdService.instance.isRewardedAdReady) const SizedBox(height: 16),

            const Text(
              '또는 구매하기',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 10회 구매 옵션
            _buildPurchaseOption(
              context,
              icon: Icons.add_circle_outline,
              title: '10회',
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
              icon: Icons.add_circle,
              title: '30회',
              subtitle: '인기',
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
              icon: Icons.add_circle,
              title: '100회',
              subtitle: '최고 가성비',
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
          child: const Text('닫기'),
        ),
      ],
    );
  }

  Widget _buildPurchaseOption(
    BuildContext context, {
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

    print('🔵 [AdReward] 광고 시청 시작');
    AdService.instance.showRewardedAd(
      onRewarded: (amount) {
        print('🔵 [AdReward] 광고 시청 완료, 보상 지급 시작: amount=$amount');
        // 광고 시청 완료 - 3회 생성 횟수 추가
        countService.addGenerations(3).then((_) {
          print('✅ [AdReward] 보상 지급 성공');
          messenger.showSnackBar(
            const SnackBar(
              content: Text('광고 시청 완료! 3회 생성 횟수가 추가되었습니다.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }).catchError((e) {
          print('❌ [AdReward] 보상 지급 실패: $e');
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
        print('❌ [AdReward] 광고 로드 실패');
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
    Navigator.of(context).pop();

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('구매 기능은 현재 개발 중입니다.'),
        backgroundColor: Colors.orange,
      ),
    );

    // TODO: 실제 인앱 구매 로직 구현
    // 1. PaymentService를 통해 구매 요청
    // 2. 구매 완료 시 생성 횟수 추가
    // 3. 영수증 검증 및 저장
  }
}
