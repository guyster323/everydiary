import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_profile_provider.dart';
import '../../../core/providers/pin_lock_provider.dart';

class AppSetupScreen extends ConsumerStatefulWidget {
  const AppSetupScreen({super.key});

  @override
  ConsumerState<AppSetupScreen> createState() => _AppSetupScreenState();
}

class _AppSetupScreenState extends ConsumerState<AppSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final _pinConfirmController = TextEditingController();
  bool _usePin = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _pinConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EveryDiary에 오신 것을 환영해요!',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '앱에서 사용할 이름과 잠금 옵션을 먼저 설정해 주세요.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: '이름',
                        hintText: '예: 홍길동',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '이름을 입력해 주세요';
                        }
                        if (value.trim().length > 24) {
                          return '이름은 24자 이하로 입력해 주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _usePin,
                      title: const Text('앱 실행 시 PIN 잠금 사용'),
                      subtitle: const Text('앱을 열 때 4자리 PIN을 입력하도록 설정합니다.'),
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              setState(() {
                                _usePin = value;
                              });
                            },
                    ),
                    if (_usePin) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _pinController,
                        decoration: const InputDecoration(
                          labelText: 'PIN (4자리 숫자)',
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        validator: (value) {
                          if (!_usePin) {
                            return null;
                          }
                          if (value == null || value.length != 4) {
                            return '4자리 숫자를 입력해 주세요';
                          }
                          if (!RegExp(r'^\d{4}$').hasMatch(value)) {
                            return '숫자만 입력할 수 있습니다';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pinConfirmController,
                        decoration: const InputDecoration(
                          labelText: 'PIN 확인',
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        validator: (value) {
                          if (!_usePin) {
                            return null;
                          }
                          if (value != _pinController.text) {
                            return 'PIN이 일치하지 않습니다';
                          }
                          return null;
                        },
                      ),
                    ],
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : () => _submit(context),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('시작하기'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profileNotifier = ref.read(appProfileProvider.notifier);
    final pinNotifier = ref.read(pinLockProvider.notifier);
    final userName = _nameController.text.trim();
    final usePin = _usePin;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (usePin) {
        await pinNotifier.enablePin(_pinController.text.trim());
      } else {
        await pinNotifier.disablePin();
      }

      await profileNotifier.completeOnboarding(
        userName: userName,
        pinEnabled: usePin,
      );

      if (!mounted) return;
      if (usePin) {
        ref.read(pinLockProvider.notifier).requireUnlock();
      }
      router.go(AppConstants.homeRoute);
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('설정 저장에 실패했습니다: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

