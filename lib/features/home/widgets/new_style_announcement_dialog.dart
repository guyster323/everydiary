import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/l10n/app_localizations.dart';

/// 새로운 썸네일 스타일 안내 팝업
class NewStyleAnnouncementDialog extends StatelessWidget {
  const NewStyleAnnouncementDialog({
    super.key,
    required this.l10n,
  });

  final AppLocalizations l10n;

  static const String _prefKey = 'new_style_announcement_v1_dismissed';

  /// 팝업을 표시해야 하는지 확인
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_prefKey) ?? false);
  }

  /// 다시 보지 않기 설정
  static Future<void> dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  /// 팝업 표시
  static Future<void> showIfNeeded(BuildContext context, AppLocalizations l10n) async {
    if (!await shouldShow()) return;

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => NewStyleAnnouncementDialog(l10n: l10n),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더 아이콘
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 32,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),

              // 타이틀
              Text(
                l10n.get('new_style_announcement_title'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // 설명
              Text(
                l10n.get('new_style_announcement_description'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // 스타일 카드들
              Row(
                children: [
                  Expanded(
                    child: _StyleCard(
                      iconPath: 'assets/icons/Styles/Child_draw.png',
                      label: l10n.get('style_child_draw'),
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StyleCard(
                      iconPath: 'assets/icons/Styles/Figure.png',
                      label: l10n.get('style_figure'),
                      theme: theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 확인 버튼
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.get('confirm')),
                ),
              ),
              const SizedBox(height: 8),

              // 다시 보지 않기 버튼
              TextButton(
                onPressed: () async {
                  await dismiss();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  l10n.get('dont_show_again'),
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StyleCard extends StatelessWidget {
  const _StyleCard({
    required this.iconPath,
    required this.label,
    required this.theme,
  });

  final String iconPath;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              iconPath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.image_not_supported,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
