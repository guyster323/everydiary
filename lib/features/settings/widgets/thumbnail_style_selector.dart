import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/providers/user_customization_provider.dart';
import '../../../core/services/user_customization_service.dart';

class ThumbnailStyleSelector extends HookConsumerWidget {
  const ThumbnailStyleSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userCustomizationSettingsNotifierProvider);
    final notifier = ref.watch(
      userCustomizationSettingsNotifierProvider.notifier,
    );

    return settings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('설정을 불러오지 못했습니다: $error')),
      data: (data) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 520;
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SizedBox(
                height: isWide ? 420 : 520,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '썸네일 스타일 커스터마이징',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AI 썸네일 스타일과 보정 값을 조정해 사용자 취향을 반영하세요.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _StyleRadioList(
                                      selected: data.preferredStyle,
                                      onChanged: notifier.updateStyle,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    flex: 3,
                                    child: _AdjustmentControls(
                                      settings: data,
                                      notifier: notifier,
                                    ),
                                  ),
                                ],
                              )
                            : ListView(
                                children: [
                                  _StyleRadioList(
                                    selected: data.preferredStyle,
                                    onChanged: notifier.updateStyle,
                                  ),
                                  const SizedBox(height: 16),
                                  _AdjustmentControls(
                                    settings: data,
                                    notifier: notifier,
                                  ),
                                ],
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('닫기'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StyleRadioList extends StatelessWidget {
  const _StyleRadioList({required this.selected, required this.onChanged});

  final ImageStyle selected;
  final ValueChanged<ImageStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '스타일 선택',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...ImageStyle.values.map(
              (style) => _StyleOptionTile(
                style: style,
                selected: style == selected,
                onTap: () {
                  if (style != selected) {
                    onChanged(style);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleOptionTile extends StatelessWidget {
  const _StyleOptionTile({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final ImageStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor = selected
        ? colorScheme.primary
        : colorScheme.outlineVariant.withValues(alpha: 0.4);
    final backgroundColor = selected
        ? colorScheme.primary.withValues(alpha: 0.08)
        : colorScheme.surface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? colorScheme.primary : colorScheme.outline,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      style.displayName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      style.promptSuffix,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdjustmentControls extends StatelessWidget {
  const _AdjustmentControls({required this.settings, required this.notifier});

  final UserCustomizationSettings settings;
  final UserCustomizationSettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '상세 조정',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _LabeledSlider(
              label: '밝기',
              value: settings.brightness,
              min: -0.5,
              max: 0.5,
              onChanged: notifier.updateBrightness,
            ),
            _LabeledSlider(
              label: '대비',
              value: settings.contrast,
              min: 0.5,
              max: 1.5,
              onChanged: notifier.updateContrast,
            ),
            _LabeledSlider(
              label: '포화도',
              value: settings.saturation,
              min: 0.5,
              max: 1.5,
              onChanged: notifier.updateSaturation,
            ),
            _LabeledSlider(
              label: '블러 반경',
              value: settings.blurRadius,
              min: 0,
              max: 30,
              onChanged: notifier.updateBlurRadius,
            ),
            const SizedBox(height: 12),
            Text('오버레이 색상', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: _overlayColors
                  .map(
                    (color) => GestureDetector(
                      onTap: () => notifier.updateOverlayColor(color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color == settings.overlayColor
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            _LabeledSlider(
              label: '오버레이 투명도',
              value: settings.overlayOpacity,
              min: 0,
              max: 0.8,
              onChanged: notifier.updateOverlayOpacity,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: settings.enableAutoOptimization,
              title: const Text('자동 최적화'),
              subtitle: const Text('분석 결과 기반으로 프롬프트를 자동 보정합니다'),
              onChanged: (_) => notifier.toggleAutoOptimization(),
            ),
            const SizedBox(height: 16),
            _ManualKeywordEditor(settings: settings, notifier: notifier),
          ],
        ),
      ),
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(value.toStringAsFixed(2)),
          ],
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}

const _overlayColors = <Color>[
  Color(0xFF000000),
  Color(0xFFFFFFFF),
  Color(0xFFFFA726),
  Color(0xFF42A5F5),
  Color(0xFF66BB6A),
  Color(0xFFAB47BC),
];

class _ManualKeywordEditor extends HookWidget {
  const _ManualKeywordEditor({required this.settings, required this.notifier});

  final UserCustomizationSettings settings;
  final UserCustomizationSettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final keywordController = useTextEditingController();
    final keywordError = useState<String?>(null);
    final isSubmitting = useState<bool>(false);

    Future<void> addKeyword() async {
      final rawValue = keywordController.text.trim();
      final normalized = rawValue.replaceAll(RegExp(r'\s+'), ' ');

      if (normalized.isEmpty) {
        keywordError.value = '키워드를 입력해 주세요.';
        return;
      }

      if (normalized.length > 24) {
        keywordError.value = '키워드는 24자 이내로 입력해 주세요.';
        return;
      }

      if (settings.manualKeywords.contains(normalized)) {
        keywordError.value = '이미 추가된 키워드입니다.';
        return;
      }

      if (settings.manualKeywords.length >= 5) {
        keywordError.value = '키워드는 최대 5개까지 등록할 수 있습니다.';
        return;
      }

      keywordError.value = null;
      isSubmitting.value = true;

      try {
        await notifier.addManualKeyword(normalized);
        if (!context.mounted) {
          return;
        }
        keywordController.clear();
      } on StateError catch (_) {
        if (context.mounted) {
          keywordError.value = '키워드는 최대 5개까지 등록할 수 있습니다.';
        }
      } catch (_) {
        if (context.mounted) {
          keywordError.value = '키워드를 저장하지 못했습니다. 다시 시도해 주세요.';
        }
      } finally {
        if (context.mounted) {
          isSubmitting.value = false;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사용자 지정 키워드',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'AI 프롬프트에 항상 포함될 키워드를 최대 5개까지 추가할 수 있습니다.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: keywordController,
                enabled: !isSubmitting.value,
                decoration: const InputDecoration(
                  labelText: '수동 키워드',
                  hintText: '예: 파스텔 톤, 야경',
                  counterText: '',
                ),
                maxLength: 24,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => addKeyword(),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: isSubmitting.value ? null : addKeyword,
              icon: const Icon(Icons.add),
              label: const Text('추가'),
            ),
          ],
        ),
        if (keywordError.value != null) ...[
          const SizedBox(height: 8),
          SelectableText.rich(
            TextSpan(
              text: keywordError.value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (settings.manualKeywords.isEmpty)
          Text(
            '등록된 키워드가 없습니다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: settings.manualKeywords
                .map(
                  (String keyword) => InputChip(
                    label: Text(keyword),
                    onDeleted: () =>
                        unawaited(notifier.removeManualKeyword(keyword)),
                  ),
                )
                .toList(),
          ),
        if (settings.manualKeywords.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => unawaited(notifier.clearManualKeywords()),
                icon: const Icon(Icons.clear_all),
                label: const Text('모두 삭제'),
              ),
            ),
          ),
      ],
    );
  }
}
