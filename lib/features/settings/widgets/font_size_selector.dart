import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/settings_enums.dart';
import '../providers/settings_provider.dart';

/// 폰트 크기 선택기 위젯
/// 사용자가 앱의 폰트 크기를 선택할 수 있는 위젯입니다.
class FontSizeSelector extends ConsumerWidget {
  const FontSizeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '폰트 크기',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFontSizeOption(
            context,
            ref,
            FontSize.small,
            '작게',
            '작은 폰트 크기',
            settings.fontSize == FontSize.small,
          ),
          const SizedBox(height: 12),
          _buildFontSizeOption(
            context,
            ref,
            FontSize.medium,
            '보통',
            '기본 폰트 크기',
            settings.fontSize == FontSize.medium,
          ),
          const SizedBox(height: 12),
          _buildFontSizeOption(
            context,
            ref,
            FontSize.large,
            '크게',
            '큰 폰트 크기',
            settings.fontSize == FontSize.large,
          ),
          const SizedBox(height: 12),
          _buildFontSizeOption(
            context,
            ref,
            FontSize.extraLarge,
            '매우 크게',
            '매우 큰 폰트 크기',
            settings.fontSize == FontSize.extraLarge,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFontSizeOption(
    BuildContext context,
    WidgetRef ref,
    FontSize fontSize,
    String title,
    String subtitle,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        ref.read(settingsProvider.notifier).setFontSize(fontSize);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.text_fields,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // 폰트 크기 미리보기
            Text(
              'Aa',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: _getFontSizeValue(fontSize),
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  double _getFontSizeValue(FontSize fontSize) {
    switch (fontSize) {
      case FontSize.small:
        return 16;
      case FontSize.medium:
        return 20;
      case FontSize.large:
        return 24;
      case FontSize.extraLarge:
        return 28;
    }
  }
}
