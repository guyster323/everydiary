import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
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
                  Text('잠금 해제', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Text(
                    '앱에 다시 접속하려면 4자리 PIN을 입력해 주세요.',
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
                                  '⚠️ 비상 복구 질문 미설정',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'PIN을 잊으면 앱에 접근할 수 없습니다.\n설정에서 비상 복구 질문을 등록하세요.',
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
                      '잠금됨: ${_formatLockMessage(lockExpiresAt)}까지 시도할 수 없어요.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Text('남은 시도 횟수: $remainingAttempts회', style: attemptStyle),
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
                          : const Text('잠금 해제'),
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
                        child: const Text('지우기'),
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
                        child: const Text('비상 복구'),
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
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      setState(() => _errorMessage = '4자리 PIN을 입력해 주세요');
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
          _errorMessage = '너무 많은 시도로 잠금되었습니다.';
        } else {
          _errorMessage = 'PIN이 일치하지 않습니다. 다시 시도해 주세요.';
        }
      });
    }
  }

  String _formatLockMessage(DateTime lockUntil) {
    final remaining = lockUntil.difference(DateTime.now());
    if (remaining.isNegative) return '잠금 해제됨';
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    if (minutes > 0) {
      return '$minutes분 ${seconds.toString().padLeft(2, '0')}초';
    }
    return '$seconds초';
  }

  Future<void> _showRecoveryDialog(
    BuildContext context,
    String recoveryQuestion,
  ) async {
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
              title: const Text('비상 복구'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '보안 질문',
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
                      decoration: const InputDecoration(labelText: '답변 입력'),
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
                      decoration: const InputDecoration(
                        labelText: '새 PIN (4자리)',
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
                        labelText: '새 PIN 확인',
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
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final answer = answerController.text.trim();
                    final newPin = newPinController.text.trim();
                    final confirmPin = confirmPinController.text.trim();

                    if (answer.isEmpty) {
                      setState(() => error = '보안 질문 답변을 입력해 주세요');
                      return;
                    }
                    if (newPin.length != 4 ||
                        !RegExp(r'^\d{4}$').hasMatch(newPin)) {
                      setState(() => error = '4자리 숫자 PIN을 입력해 주세요');
                      return;
                    }
                    if (newPin != confirmPin) {
                      setState(() => error = '새 PIN이 일치하지 않습니다');
                      return;
                    }

                    Navigator.of(context).pop(true);
                  },
                  child: const Text('확인'),
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
      print('❌ [PinRecovery] 다이얼로그 취소됨');
      return;
    }

    if (!mounted) {
      answerController.dispose();
      newPinController.dispose();
      confirmPinController.dispose();
      return;
    }

    setState(() => _isSubmitting = true);

    print('🔵 [PinRecovery] PIN 복구 시작');
    try {
      await ref
          .read(pinLockProvider.notifier)
          .resetPinWithRecovery(
            answer: answerController.text.trim(),
            newPin: newPinController.text.trim(),
          );

      print('✅ [PinRecovery] PIN 복구 성공');

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
        const SnackBar(content: Text('새 PIN이 설정되었습니다.')),
      );

      // 약간의 지연 후 화면 이동
      await Future.delayed(const Duration(milliseconds: 300));

      if (!context.mounted) {
        answerController.dispose();
        newPinController.dispose();
        confirmPinController.dispose();
        return;
      }

      final redirectPath = widget.redirectPath?.isNotEmpty == true
          ? widget.redirectPath!
          : AppConstants.homeRoute;

      print('🔵 [PinRecovery] 화면 이동: $redirectPath');
      context.go(redirectPath);
    } catch (error, stackTrace) {
      print('❌ [PinRecovery] PIN 복구 실패: $error');
      print('❌ [PinRecovery] StackTrace: $stackTrace');

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
        SnackBar(content: Text('복구에 실패했습니다: $error')),
      );
    } finally {
      answerController.dispose();
      newPinController.dispose();
      confirmPinController.dispose();
    }
  }
}
