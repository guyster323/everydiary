import 'package:flutter/material.dart';
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  child: _StyleRadioList(
                    l10n: l10n,
                    selected: data.preferredStyle,
                    onChanged: notifier.updateStyle,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.get('style_select_title'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: ImageStyle.values.length,
                itemBuilder: (context, index) {
                  final style = ImageStyle.values[index];
                  return _StyleOptionGridTile(
                    l10n: l10n,
                    style: style,
                    selected: style == selected,
                    onTap: () {
                      if (style != selected) {
                        onChanged(style);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleOptionGridTile extends StatelessWidget {
  const _StyleOptionGridTile({
    required this.l10n,
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final ImageStyle style;
  final bool selected;
  final VoidCallback onTap;

  String _getStyleIconPath(ImageStyle style) {
    final Map<ImageStyle, String> iconPaths = {
      ImageStyle.chibi: 'assets/icons/Styles/chibi.png',
      ImageStyle.cute: 'assets/icons/Styles/cute.png',
      ImageStyle.pixelGame: 'assets/icons/Styles/pixel_game.png',
      ImageStyle.realistic: 'assets/icons/Styles/realistic.png',
      ImageStyle.cartoon: 'assets/icons/Styles/cartoon.png',
      ImageStyle.watercolor: 'assets/icons/Styles/watercolor.png',
      ImageStyle.oil: 'assets/icons/Styles/oil.png',
      ImageStyle.sketch: 'assets/icons/Styles/sketch.png',
      ImageStyle.digital: 'assets/icons/Styles/digital.png',
      ImageStyle.vintage: 'assets/icons/Styles/vintage.png',
      ImageStyle.modern: 'assets/icons/Styles/modern.png',
      ImageStyle.santaTogether: 'assets/icons/Styles/santa_together.png',
      ImageStyle.childDraw: 'assets/icons/Styles/Child_draw.png',
      ImageStyle.figure: 'assets/icons/Styles/Figure.png',
    };
    return iconPaths[style] ?? 'assets/icons/Styles/chibi.png';
  }

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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: backgroundColor,
          border: Border.all(color: borderColor, width: selected ? 2.5 : 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 선택 체크 아이콘
            if (selected)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
            // 스타일 아이콘 이미지
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    _getStyleIconPath(style),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported,
                          color: colorScheme.onSurfaceVariant,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // 스타일명
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
              child: Text(
                l10n.get(style.localizationKey),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

