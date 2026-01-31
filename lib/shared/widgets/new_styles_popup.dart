import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers/localization_provider.dart';

/// 새로운 스타일 추가 알림 팝업
class NewStylesPopup {
  static const String _shownKey = 'new_styles_popup_v1_1_1_shown';

  /// 팝업을 표시해야 하는지 확인
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_shownKey) ?? false);
  }

  /// 다시 보지 않기 설정
  static Future<void> setDontShowAgain() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shownKey, true);
  }

  /// 팝업 표시 (필요한 경우)
  static Future<void> showIfNeeded(BuildContext context, WidgetRef ref) async {
    if (!await shouldShow()) return;

    if (!context.mounted) return;

    final l10n = ref.read(localizationProvider);

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.get('new_styles_popup_title'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 새 스타일 미리보기
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StylePreview(
                  imagePath: 'assets/icons/Styles/felted_wool.png',
                  label: l10n.get('style_felted_wool'),
                ),
                _StylePreview(
                  imagePath: 'assets/icons/Styles/3d_animation.png',
                  label: l10n.get('style_3d_animation'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.get('new_styles_popup_message'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await setDontShowAgain();
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(l10n.get('new_styles_popup_dont_show')),
          ),
          ElevatedButton(
            onPressed: () async {
              await setDontShowAgain();
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
                // 설정 화면으로 이동
                dialogContext.go('/settings');
              }
            },
            child: Text(l10n.get('new_styles_popup_check')),
          ),
        ],
      ),
    );
  }
}

class _StylePreview extends StatelessWidget {
  const _StylePreview({
    required this.imagePath,
    required this.label,
  });

  final String imagePath;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.image_not_supported,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
