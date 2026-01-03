import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers/generation_count_provider.dart';
import '../../core/providers/localization_provider.dart';

/// AdMob 정책 공지 다이얼로그
/// 광고 정책 제한 기간 동안 앱 실행 시 표시됩니다.
class AdPolicyNoticeDialog extends ConsumerStatefulWidget {
  const AdPolicyNoticeDialog({super.key});

  static const String _dontShowAgainKey = 'ad_policy_notice_dont_show';

  /// 다이얼로그 표시 여부 확인
  static Future<bool> shouldShow() async {
    // 정책 제한 기간이 아니면 표시하지 않음
    if (!GenerationCountNotifier.isInAdPolicyLimitPeriod()) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_dontShowAgainKey) ?? false);
  }

  /// 다이얼로그 표시
  static Future<void> showIfNeeded(BuildContext context) async {
    if (await shouldShow()) {
      if (context.mounted) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AdPolicyNoticeDialog(),
        );
      }
    }
  }

  @override
  ConsumerState<AdPolicyNoticeDialog> createState() => _AdPolicyNoticeDialogState();
}

class _AdPolicyNoticeDialogState extends ConsumerState<AdPolicyNoticeDialog> {
  bool _dontShowAgain = false;

  Future<void> _saveAndClose() async {
    if (_dontShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AdPolicyNoticeDialog._dontShowAgainKey, true);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(localizationProvider);
    final theme = Theme.of(context);

    return AlertDialog(
      icon: Icon(
        Icons.info_outline,
        size: 48,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        l10n.get('ad_policy_notice_title'),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.get('ad_policy_notice_message'),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.get('ad_policy_notice_count_info'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => setState(() => _dontShowAgain = !_dontShowAgain),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _dontShowAgain,
                    onChanged: (value) => setState(() => _dontShowAgain = value ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.get('dont_show_again'),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: _saveAndClose,
          child: Text(l10n.get('confirm')),
        ),
      ],
    );
  }
}
