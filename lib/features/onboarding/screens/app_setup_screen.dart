import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_profile_provider.dart';
import '../../../core/providers/localization_provider.dart';
import '../../../core/providers/pin_lock_provider.dart';
import '../../settings/models/settings_enums.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/widgets/language_selector.dart';

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
  String _selectedGender = 'none';

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
    final l10n = ref.watch(localizationProvider);
    final settings = ref.watch(settingsProvider);

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
                      l10n.get('welcome_title'),
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.get('setup_subtitle'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Language selector at the top
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(l10n.get('language')),
                        subtitle: Text(_getLanguageDisplayName(settings.language)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _showLanguageSelector(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.get('name_label'),
                        hintText: l10n.get('name_hint'),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.get('name_required');
                        }
                        if (value.trim().length > 24) {
                          return l10n.get('name_max_length');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // 성별 선택
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Icon(_getGenderIcon(_selectedGender), color: theme.colorScheme.primary),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.get('user_gender'), style: theme.textTheme.bodyLarge),
                                  Text(
                                    _getGenderDisplayName(_selectedGender, l10n),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DropdownButton<String>(
                              value: _selectedGender,
                              underline: const SizedBox(),
                              items: [
                                DropdownMenuItem(value: 'male', child: Text(l10n.get('gender_male'))),
                                DropdownMenuItem(value: 'female', child: Text(l10n.get('gender_female'))),
                                DropdownMenuItem(value: 'none', child: Text(l10n.get('gender_none'))),
                              ],
                              onChanged: _isSubmitting ? null : (value) {
                                if (value != null) {
                                  setState(() => _selectedGender = value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _usePin,
                      title: Text(l10n.get('pin_lock_title')),
                      subtitle: Text(l10n.get('pin_lock_subtitle')),
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
                        decoration: InputDecoration(
                          labelText: l10n.get('pin_label'),
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        enableSuggestions: false,
                        autocorrect: false,
                        smartDashesType: SmartDashesType.disabled,
                        smartQuotesType: SmartQuotesType.disabled,
                        validator: (value) {
                          if (!_usePin) {
                            return null;
                          }
                          if (value == null || value.length != 4) {
                            return l10n.get('pin_required');
                          }
                          if (!RegExp(r'^\d{4}$').hasMatch(value)) {
                            return l10n.get('pin_numbers_only');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pinConfirmController,
                        decoration: InputDecoration(
                          labelText: l10n.get('pin_confirm_label'),
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        enableSuggestions: false,
                        autocorrect: false,
                        smartDashesType: SmartDashesType.disabled,
                        smartQuotesType: SmartQuotesType.disabled,
                        validator: (value) {
                          if (!_usePin) {
                            return null;
                          }
                          if (value != _pinController.text) {
                            return l10n.get('pin_mismatch');
                          }
                          return null;
                        },
                      ),
                    ],
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _submit(context),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.get('start_button')),
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

  String _getLanguageDisplayName(Language language) {
    switch (language) {
      case Language.korean:
        return '한국어';
      case Language.english:
        return 'English';
      case Language.japanese:
        return '日本語';
      case Language.chineseSimplified:
        return '简体中文';
      case Language.chineseTraditional:
        return '繁體中文';
    }
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => const LanguageSelector(),
    );
  }

  IconData _getGenderIcon(String gender) {
    switch (gender) {
      case 'male':
        return Icons.male;
      case 'female':
        return Icons.female;
      default:
        return Icons.person_outline;
    }
  }

  String _getGenderDisplayName(String gender, AppLocalizations l10n) {
    switch (gender) {
      case 'male':
        return l10n.get('gender_male');
      case 'female':
        return l10n.get('gender_female');
      default:
        return l10n.get('gender_none');
    }
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
        await profileNotifier.completeOnboarding(
          userName: userName,
          pinEnabled: true,
          userGender: _selectedGender,
        );
      } else {
        await pinNotifier.disablePin();
        await profileNotifier.completeOnboarding(
          userName: userName,
          pinEnabled: false,
          userGender: _selectedGender,
        );
      }
      if (!mounted) return;
      // 온보딩 완료 후 권한 요청 화면으로 이동
      router.go(AppConstants.permissionRoute);
    } catch (error) {
      if (!mounted) return;
      final l10n = ref.read(localizationProvider);
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.get('setup_save_failed')}: $error')),
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
