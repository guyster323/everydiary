import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/generation_count_provider.dart';
import '../../diary/widgets/image_generation_purchase_dialog.dart';

/// 이미지 생성 횟수 표시 위젯
class GenerationCountWidget extends ConsumerStatefulWidget {
  const GenerationCountWidget({super.key});

  @override
  ConsumerState<GenerationCountWidget> createState() =>
      _GenerationCountWidgetState();
}

class _GenerationCountWidgetState extends ConsumerState<GenerationCountWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 다시 표시될 때마다 횟수 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(generationCountServiceProvider).reload();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 필수
    final remainingAsync = ref.watch(remainingGenerationsProvider);
    final theme = Theme.of(context);

    return remainingAsync.when(
      data: (remaining) {
        final isLow = remaining <= 5;
        final isEmpty = remaining <= 0;

        return Card(
          elevation: 0,
          color: isEmpty
              ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
              : isLow
                  ? theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3)
                  : theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
          child: InkWell(
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (context) => const ImageGenerationPurchaseDialog(),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isEmpty
                          ? theme.colorScheme.error.withValues(alpha: 0.2)
                          : isLow
                              ? theme.colorScheme.tertiary.withValues(alpha: 0.2)
                              : theme.colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 20,
                      color: isEmpty
                          ? theme.colorScheme.error
                          : isLow
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'AI 이미지 생성',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '남은 횟수: ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          Text(
                            '$remaining회',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isEmpty
                                  ? theme.colorScheme.error
                                  : isLow
                                      ? theme.colorScheme.tertiary
                                      : theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isEmpty) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
