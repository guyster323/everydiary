import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PIN 사용 시 비상 복구 질문이 없을 때 표시되는 경고 다이얼로그
class RecoveryQuestionWarningDialog extends StatefulWidget {
  const RecoveryQuestionWarningDialog({super.key});

  static const String _dontShowAgainKey = 'pin_recovery_warning_dismissed';

  /// 다시 보지 않기 설정을 확인
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_dontShowAgainKey) ?? false);
  }

  /// 다시 보지 않기 설정을 저장
  static Future<void> setDontShowAgain(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dontShowAgainKey, value);
  }

  @override
  State<RecoveryQuestionWarningDialog> createState() =>
      _RecoveryQuestionWarningDialogState();
}

class _RecoveryQuestionWarningDialogState
    extends State<RecoveryQuestionWarningDialog> {
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: theme.colorScheme.error,
        size: 48,
      ),
      title: const Text('비상 복구 질문 미설정'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PIN을 잊어버렸을 때를 대비해 비상 복구 질문을 설정하는 것을 권장합니다.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            '비상 복구 질문이 없으면 PIN을 잊어버렸을 때 앱에 접근할 수 없게 됩니다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
            value: _dontShowAgain,
            onChanged: (value) {
              setState(() => _dontShowAgain = value ?? false);
            },
            title: const Text('다시 보지 않기'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (_dontShowAgain) {
              await RecoveryQuestionWarningDialog.setDontShowAgain(true);
            }
            if (context.mounted) {
              Navigator.of(context).pop(false);
            }
          },
          child: const Text('나중에'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_dontShowAgain) {
              await RecoveryQuestionWarningDialog.setDontShowAgain(true);
            }
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          },
          child: const Text('설정하러 가기'),
        ),
      ],
    );
  }
}

/// 비상 복구 질문 경고 다이얼로그를 표시하고 설정 페이지로 이동할지 여부를 반환
Future<void> showRecoveryQuestionWarningIfNeeded(
  BuildContext context, {
  required bool isPinEnabled,
  required String? recoveryQuestion,
}) async {
  // PIN이 비활성화되어 있거나 이미 복구 질문이 있으면 표시하지 않음
  if (!isPinEnabled || (recoveryQuestion != null && recoveryQuestion.isNotEmpty)) {
    return;
  }

  // 다시 보지 않기 설정 확인
  final shouldShow = await RecoveryQuestionWarningDialog.shouldShow();
  if (!shouldShow) {
    return;
  }

  if (!context.mounted) return;

  // 다이얼로그 표시
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const RecoveryQuestionWarningDialog(),
  );

  // 설정 페이지로 이동
  if (result == true && context.mounted) {
    context.push('/settings');
  }
}
