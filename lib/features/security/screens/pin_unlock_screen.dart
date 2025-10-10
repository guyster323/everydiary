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

class _PinUnlockScreenState extends ConsumerState<PinUnlockScreen> {
  final _pinController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinLockProvider);
    final theme = Theme.of(context);

    final lockExpiresAt = pinState.lockExpiresAt;
    final remainingAttempts = pinState.remainingAttempts;

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
                  Text(
                    '잠금 해제',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '앱에 다시 접속하려면 4자리 PIN을 입력해 주세요.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: 'PIN',
                      errorText: _errorMessage,
                      counterText: '',
                    ),
                    enabled: !_isSubmitting && !(pinState.lockExpiresAt != null),
                  ),
                  const SizedBox(height: 16),
                  if (lockExpiresAt != null)
                    Text(
                      '잠금됨: ${_formatLockMessage(lockExpiresAt)}까지 시도할 수 없어요.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    )
                  else
                    Text(
                      '남은 시도 횟수: $remainingAttempts회',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
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
                          : const Text('잠금 해제'),
                    ),
                  ),
                  const SizedBox(height: 12),
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
}

