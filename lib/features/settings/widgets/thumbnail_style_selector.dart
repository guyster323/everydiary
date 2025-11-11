import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/localization_provider.dart';
import '../../../core/providers/user_customization_provider.dart';
import '../../../core/services/user_customization_service.dart';

class ThumbnailStyleSelector extends HookConsumerWidget {
  const ThumbnailStyleSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(localizationProvider);
    final settings = ref.watch(userCustomizationSettingsNotifierProvider);
    final notifier = ref.watch(
      userCustomizationSettingsNotifierProvider.notifier,
    );

    return settings.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('${l10n.get('settings_load_error')}: $error')),
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
                            l10n.get('thumbnail_dialog_title'),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.get('thumbnail_dialog_subtitle'),
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
                                      l10n: l10n,
                                      selected: data.preferredStyle,
                                      onChanged: notifier.updateStyle,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    flex: 3,
                                    child: _AdjustmentControls(
                                      l10n: l10n,
                                      settings: data,
                                      notifier: notifier,
                                    ),
                                  ),
                                ],
                              )
                            : ListView(
                                children: [
                                  _StyleRadioList(
                                    l10n: l10n,
                                    selected: data.preferredStyle,
                                    onChanged: notifier.updateStyle,
                                  ),
                                  const SizedBox(height: 16),
                                  _AdjustmentControls(
                                    l10n: l10n,
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
                            child: Text(l10n.get('close')),
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
  const _StyleRadioList({
    required this.l10n,
    required this.selected,
    required this.onChanged,
  });

  final AppLocalizations l10n;
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
              l10n.get('style_select_title'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...ImageStyle.values.map(
              (style) => _StyleOptionTile(
                l10n: l10n,
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
    required this.l10n,
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final AppLocalizations l10n;
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
                      l10n.get(style.localizationKey),
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
  const _AdjustmentControls({
    required this.l10n,
    required this.settings,
    required this.notifier,
  });

  final AppLocalizations l10n;
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
              l10n.get('detail_adjust_title'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _LabeledSlider(
              label: l10n.get('brightness_label'),
              value: settings.brightness,
              min: -0.5,
              max: 0.5,
              onChanged: notifier.updateBrightness,
            ),
            _LabeledSlider(
              label: l10n.get('contrast_label'),
              value: settings.contrast,
              min: 0.5,
              max: 1.5,
              onChanged: notifier.updateContrast,
            ),
            _LabeledSlider(
              label: l10n.get('saturation_label'),
              value: settings.saturation,
              min: 0.5,
              max: 1.5,
              onChanged: notifier.updateSaturation,
            ),
            _LabeledSlider(
              label: l10n.get('blur_radius_label'),
              value: settings.blurRadius,
              min: 0,
              max: 30,
              onChanged: notifier.updateBlurRadius,
            ),
            const SizedBox(height: 12),
            Text(l10n.get('overlay_color_label'), style: Theme.of(context).textTheme.bodyMedium),
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
              label: l10n.get('overlay_opacity_label'),
              value: settings.overlayOpacity,
              min: 0,
              max: 0.8,
              onChanged: notifier.updateOverlayOpacity,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: settings.enableAutoOptimization,
              title: Text(l10n.get('auto_optimization_title')),
              subtitle: Text(l10n.get('auto_optimization_subtitle')),
              onChanged: (_) => notifier.toggleAutoOptimization(),
            ),
            const SizedBox(height: 16),
            _ManualKeywordEditor(l10n: l10n, settings: settings, notifier: notifier),
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
  const _ManualKeywordEditor({
    required this.l10n,
    required this.settings,
    required this.notifier,
  });

  final AppLocalizations l10n;
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
        keywordError.value = l10n.get('keyword_required');
        return;
      }

      if (normalized.length > 24) {
        keywordError.value = l10n.get('keyword_max_length');
        return;
      }

      if (settings.manualKeywords.contains(normalized)) {
        keywordError.value = l10n.get('keyword_duplicate');
        return;
      }

      if (settings.manualKeywords.length >= 5) {
        keywordError.value = l10n.get('keyword_max_count');
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
          keywordError.value = l10n.get('keyword_max_count');
        }
      } catch (_) {
        if (context.mounted) {
          keywordError.value = l10n.get('keyword_save_failed');
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
          l10n.get('manual_keyword_title'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.get('manual_keyword_subtitle'),
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
                decoration: InputDecoration(
                  labelText: l10n.get('keyword_label'),
                  hintText: l10n.get('keyword_hint'),
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
              label: Text(l10n.get('keyword_add_button')),
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
            l10n.get('keyword_empty_list'),
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
                label: Text(l10n.get('keyword_clear_all')),
              ),
            ),
          ),
      ],
    );
  }
}
