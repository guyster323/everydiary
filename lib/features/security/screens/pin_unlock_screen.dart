import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/localization_provider.dart';
import '../../../core/providers/pin_lock_provider.dart';

class PinUnlockScreen extends ConsumerStatefulWidget {
  const PinUnlockScreen({super.key, this.redirectPath});

  final String? redirectPath;

  @override
  ConsumerState<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends ConsumerState<PinUnlockScreen>
    with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;
  late AnimationController _flashingController;
  late Animation<double> _flashingAnimation;

  @override
  void initState() {
    super.initState();
    // 비상등 깜빡임 애니메이션
    _flashingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _flashingAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _flashingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _flashingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinLockProvider);
    final theme = Theme.of(context);
    final l10n = ref.watch(localizationProvider);

    final lockExpiresAt = pinState.lockExpiresAt;
    final remainingAttempts = pinState.remainingAttempts;
    final recoveryQuestion = pinState.recoveryQuestion;
    final canUseRecovery =
        recoveryQuestion != null && recoveryQuestion.isNotEmpty;
    final isCriticalAttempt = remainingAttempts <= 2;
    final attemptStyle = theme.textTheme.bodySmall?.copyWith(
      color: isCriticalAttempt
          ? theme.colorScheme.error
          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
      fontWeight: isCriticalAttempt ? FontWeight.w600 : FontWeight.w400,
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.get('pin_unlock_title'), style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Text(
                    l10n.get('pin_unlock_subtitle'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 비상 복구 질문 경고 (복구 질문이 없을 때만 표시)
                  if (!canUseRecovery)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // 비상등 아이콘 (깜빡임 애니메이션)
                          FadeTransition(
                            opacity: _flashingAnimation,
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: theme.colorScheme.error,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.get('pin_unlock_recovery_warning_title'),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.get('pin_unlock_recovery_warning_message'),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onErrorContainer,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    enableSuggestions: false,
                    autocorrect: false,
                    smartDashesType: SmartDashesType.disabled,
                    smartQuotesType: SmartQuotesType.disabled,
                    decoration: const InputDecoration(
                      labelText: 'PIN',
                      counterText: '',
                    ),
                    enabled: !_isSubmitting && lockExpiresAt == null,
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _errorMessage == null
                        ? const SizedBox(height: 20)
                        : Row(
                            key: ValueKey(_errorMessage),
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 18,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 4),
                  if (lockExpiresAt != null)
                    Text(
                      l10n.get('pin_unlock_locked_until').replaceAll('{time}', _formatLockMessage(lockExpiresAt)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Text(
                      l10n.get('pin_unlock_remaining_attempts').replaceAll('{count}', remainingAttempts.toString()),
                      style: attemptStyle,
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting || lockExpiresAt != null
                          ? null
                          : () => _verifyPin(context),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.get('pin_unlock_button')),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                _pinController.clear();
                                setState(() {
                                  _errorMessage = null;
                                });
                              },
                        child: Text(l10n.get('pin_unlock_clear')),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed:
                            (!_isSubmitting &&
                                lockExpiresAt == null &&
                                canUseRecovery)
                            ? () =>
                                  _showRecoveryDialog(context, recoveryQuestion)
                            : null,
                        child: Text(l10n.get('pin_unlock_recovery')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyPin(BuildContext context) async {
    final l10n = ref.read(localizationProvider);
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      setState(() => _errorMessage = l10n.get('pin_unlock_error_length'));
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final pinNotifier = ref.read(pinLockProvider.notifier);
    final router = GoRouter.of(context);
    final success = await pinNotifier.unlockWithPin(pin);

    if (!mounted) return;

    if (success) {
      final redirectPath = widget.redirectPath?.isNotEmpty == true
          ? widget.redirectPath!
          : AppConstants.homeRoute;
      router.go(redirectPath);
    } else {
      setState(() {
        _isSubmitting = false;
        final state = ref.read(pinLockProvider);
        if (state.lockExpiresAt != null) {
          _errorMessage = l10n.get('pin_unlock_error_locked');
        } else {
          _errorMessage = l10n.get('pin_unlock_error_incorrect');
        }
      });
    }
  }

  String _formatLockMessage(DateTime lockUntil) {
    final l10n = ref.read(localizationProvider);
    final remaining = lockUntil.difference(DateTime.now());
    if (remaining.isNegative) return l10n.get('pin_unlock_unlocked');
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    if (minutes > 0) {
      return l10n.get('pin_unlock_time_minutes')
          .replaceAll('{minutes}', minutes.toString())
          .replaceAll('{seconds}', seconds.toString().padLeft(2, '0'));
    }
    return l10n.get('pin_unlock_time_seconds')
        .replaceAll('{seconds}', seconds.toString());
  }

  Future<void> _showRecoveryDialog(
    BuildContext context,
    String recoveryQuestion,
  ) async {
    final l10n = ref.read(localizationProvider);
    final answerController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    String? error;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.get('pin_recovery_title')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.get('pin_recovery_question_label'),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recoveryQuestion,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: answerController,
                      decoration: InputDecoration(labelText: l10n.get('pin_recovery_answer_input')),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      enableSuggestions: false,
                      autocorrect: false,
                      smartDashesType: SmartDashesType.disabled,
                      smartQuotesType: SmartQuotesType.disabled,
                      decoration: InputDecoration(
                        labelText: l10n.get('pin_recovery_new_pin'),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      enableSuggestions: false,
                      autocorrect: false,
                      smartDashesType: SmartDashesType.disabled,
                      smartQuotesType: SmartQuotesType.disabled,
                      decoration: InputDecoration(
                        labelText: l10n.get('pin_recovery_confirm_pin'),
                        counterText: '',
                        errorText: error,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.get('cancel')),
                ),
                ElevatedButton(
                  onPressed: () {
                    final answer = answerController.text.trim();
                    final newPin = newPinController.text.trim();
                    final confirmPin = confirmPinController.text.trim();

                    if (answer.isEmpty) {
                      setState(() => error = l10n.get('pin_recovery_error_answer_empty'));
                      return;
                    }
                    if (newPin.length != 4 ||
                        !RegExp(r'^\d{4}$').hasMatch(newPin)) {
                      setState(() => error = l10n.get('pin_recovery_error_pin_length'));
                      return;
                    }
                    if (newPin != confirmPin) {
                      setState(() => error = l10n.get('pin_recovery_error_pin_mismatch'));
                      return;
                    }

                    Navigator.of(context).pop(true);
                  },
                  child: Text(l10n.get('ok')),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true || !mounted) {
      answerController.dispose();
      newPinController.dispose();
      confirmPinController.dispose();
      debugPrint('❌ [PinRecovery] 다이얼로그 취소됨');
      return;
    }

    if (!mounted) {
      answerController.dispose();
      newPinController.dispose();
      confirmPinController.dispose();
      return;
    }

    setState(() => _isSubmitting = true);

    debugPrint('🔵 [PinRecovery] PIN 복구 시작');
    try {
      await ref
          .read(pinLockProvider.notifier)
          .resetPinWithRecovery(
            answer: answerController.text.trim(),
            newPin: newPinController.text.trim(),
          );

      debugPrint('✅ [PinRecovery] PIN 복구 성공');

      if (!mounted) {
        answerController.dispose();
        newPinController.dispose();
        confirmPinController.dispose();
        return;
      }

      // setState로 _isSubmitting을 false로 설정
      setState(() => _isSubmitting = false);

      if (!context.mounted) {
        answerController.dispose();
        newPinController.dispose();
        confirmPinController.dispose();
        return;
      }

      // SnackBar 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.get('pin_recovery_success'))),
      );

      // 약간의 지연 후 화면 이동
      await Future<void>.delayed(const Duration(milliseconds: 300));

      if (!context.mounted) {
        answerController.dispose();
        newPinController.dispose();
        confirmPinController.dispose();
        return;
      }

      final redirectPath = widget.redirectPath?.isNotEmpty == true
          ? widget.redirectPath!
          : AppConstants.homeRoute;

      debugPrint('🔵 [PinRecovery] 화면 이동: $redirectPath');
      context.go(redirectPath);
    } catch (error, stackTrace) {
      debugPrint('❌ [PinRecovery] PIN 복구 실패: $error');
      debugPrint('❌ [PinRecovery] StackTrace: $stackTrace');

      if (!mounted) {
        answerController.dispose();
        newPinController.dispose();
        confirmPinController.dispose();
        return;
      }

      setState(() => _isSubmitting = false);

      if (!context.mounted) {
        answerController.dispose();
        newPinController.dispose();
        confirmPinController.dispose();
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.get('pin_recovery_failed').replaceAll('{error}', error.toString()))),
      );
    } finally {
      answerController.dispose();
      newPinController.dispose();
      confirmPinController.dispose();
    }
  }
}
