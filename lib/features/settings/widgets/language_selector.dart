import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/localization_provider.dart';
import '../models/settings_enums.dart';
import '../providers/settings_provider.dart';

/// 언어 선택기 위젯
/// 사용자가 앱의 언어를 선택할 수 있는 위젯입니다.
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = ref.watch(localizationProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.get('language_select'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildLanguageOption(
                    context,
                    ref,
                    Language.korean,
                    '한국어',
                    'Korean',
                    '🇰🇷',
                    settings.language == Language.korean,
                  ),
                  const SizedBox(height: 12),
                  _buildLanguageOption(
                    context,
                    ref,
                    Language.english,
                    'English',
                    'English',
                    '🇺🇸',
                    settings.language == Language.english,
                  ),
                  const SizedBox(height: 12),
                  _buildLanguageOption(
                    context,
                    ref,
                    Language.japanese,
                    '日本語',
                    'Japanese',
                    '🇯🇵',
                    settings.language == Language.japanese,
                  ),
                  const SizedBox(height: 12),
                  _buildLanguageOption(
                    context,
                    ref,
                    Language.chineseSimplified,
                    '简体中文',
                    'Chinese (Simplified)',
                    '🇨🇳',
                    settings.language == Language.chineseSimplified,
                  ),
                  const SizedBox(height: 12),
                  _buildLanguageOption(
                    context,
                    ref,
                    Language.chineseTraditional,
                    '繁體中文',
                    'Chinese (Traditional)',
                    '🇹🇼',
                    settings.language == Language.chineseTraditional,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    Language language,
    String title,
    String subtitle,
    String flag,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        ref.read(settingsProvider.notifier).setLanguage(language);
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
            Text(flag, style: const TextStyle(fontSize: 24)),
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
}
