import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animations/animations.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/layout/responsive_widgets.dart';
import '../../../core/providers/app_profile_provider.dart';
import '../../../core/providers/localization_provider.dart';
import '../../../core/providers/pin_lock_provider.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../models/settings_enums.dart';
import '../providers/settings_provider.dart';
import '../widgets/backup_restore_widget.dart';
import '../widgets/font_size_selector.dart';
import '../widgets/language_selector.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/theme_selector.dart';
import '../widgets/thumbnail_style_selector.dart';
import '../../../core/routing/app_router.dart';
import '../../onboarding/screens/video_intro_screen.dart';

/// 설정 화면
/// 사용자가 앱의 다양한 설정을 관리할 수 있는 화면입니다.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pinActionInProgress = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final profileState = ref.watch(appProfileProvider);
    final pinState = ref.watch(pinLockProvider);
    final l10n = ref.watch(localizationProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: l10n.get('settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          actions: [
            IconButton(
              onPressed: _showResetDialog,
              icon: const Icon(Icons.refresh),
              tooltip: l10n.get('settings_reset'),
            ),
          ],
        ),
      body: ResponsiveWrapper(
        child: ScrollAnimations.scrollReveal(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 앱 설정 섹션 - 언어를 맨 위로
              SettingsSection(
                title: l10n.get('app_settings'),
                children: [
                  SettingsTile(
                    leading: Icon(
                      Icons.language,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: l10n.get('language'),
                    subtitle: _getLanguageDisplayName(settings.language, l10n),
                    onTap: () => _showLanguageSelector(),
                  ),
                  SettingsTile(
                    leading: Icon(
                      Icons.image_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: l10n.get('thumbnail_style'),
                    subtitle: l10n.get('thumbnail_style_subtitle'),
                    onTap: () => _showThumbnailStyleSelector(),
                  ),
                  // 테스트 기능 제거: 썸네일 품질 리포트 항목 삭제
                  SettingsTile(
                    leading: Icon(
                      Icons.palette_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: l10n.get('theme'),
                    subtitle: _getThemeDisplayName(settings.themeMode, l10n),
                    onTap: () => _showThemeSelector(),
                  ),
                  SettingsTile(
                    leading: Icon(
                      Icons.text_fields,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: l10n.get('font_size'),
                    subtitle: _getFontSizeDisplayName(settings.fontSize, l10n),
                    onTap: () => _showFontSizeSelector(),
                  ),
                  SettingsTile(
                    leading: Icon(
                      Icons.play_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: l10n.get('show_intro_video'),
                    subtitle: l10n.get('show_intro_video_subtitle'),
                    trailing: Switch.adaptive(
                      value: settings.showIntroVideo,
                      onChanged: (value) async {
                        ref.read(settingsProvider.notifier).setShowIntroVideo(value);
                        AppRouter.resetVideoIntroCache(); // 라우터 캐시 리셋
                        if (value) {
                          // 켜면 시청 기록 및 세션 플래그 초기화
                          await VideoIntroScreen.resetWatchedStatus();
                          EveryDiaryHomePage.resetVideoSessionFlag();
                        }
                      },
                    ),
                    onTap: () async {
                      final newValue = !settings.showIntroVideo;
                      ref.read(settingsProvider.notifier).setShowIntroVideo(newValue);
                      AppRouter.resetVideoIntroCache(); // 라우터 캐시 리셋
                      if (newValue) {
                        // 켜면 시청 기록 및 세션 플래그 초기화
                        await VideoIntroScreen.resetWatchedStatus();
                        EveryDiaryHomePage.resetVideoSessionFlag();
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SettingsSection(
                title: l10n.get('security_management'),
                children: [
                  SettingsTile(
                    leading: Icon(
                      Icons.person_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: l10n.get('username'),
                    subtitle: profileState.userName?.isNotEmpty == true
                        ? profileState.userName
                        : l10n.get('username_not_set'),
                    onTap: () => _editUserName(context, profileState, l10n),
                  ),
                  SettingsTile(
                    leading: Icon(
                      Icons.lock_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: l10n.get('pin_lock'),
                    subtitle: pinState.isPinEnabled
                        ? l10n.get('pin_lock_enabled')
                        : l10n.get('pin_lock_disabled'),
                    trailing: Switch.adaptive(
                      value: pinState.isPinEnabled,
                      onChanged: _pinActionInProgress
                          ? null
                          : (value) => _handlePinToggle(context, value, l10n),
                    ),
                    onTap: () =>
                        _handlePinToggle(context, !pinState.isPinEnabled, l10n),
                  ),
                  if (pinState.isPinEnabled)
                    SettingsTile(
                      leading: Icon(
                        Icons.password,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: l10n.get('change_pin'),
                      subtitle: l10n.get('change_pin_subtitle'),
                      onTap: () => _changePin(context, l10n),
                    ),
                  SettingsTile(
                    leading: Icon(
                      Icons.help_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: l10n.get('recovery_question'),
                    subtitle: pinState.recoveryQuestion != null
                        ? l10n.get('recovery_question_set')
                        : l10n.get('recovery_question_not_set'),
                    onTap: () => _configureRecoveryQuestion(context, pinState, l10n),
                  ),
                  if (!kIsWeb && !Platform.isAndroid)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        l10n.get('ios_security_warning'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // 알림 설정 섹션
              SettingsSection(
                title: l10n.get('notifications'),
                children: [
                  SettingsTile(
                    leading: Icon(
                      Icons.notifications_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: l10n.get('diary_reminder'),
                    subtitle: l10n.get('diary_reminder_subtitle'),
                    trailing: Switch(
                      value: settings.dailyReminder,
                      onChanged: (value) {
                        ref
                            .read(settingsProvider.notifier)
                            .setDailyReminder(value);
                      },
                    ),
                  ),
                  SettingsTile(
                    leading: Icon(
                      Icons.schedule,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: l10n.get('reminder_time'),
                    subtitle: _formatTime(settings.reminderTime),
                    onTap: () => _selectReminderTime(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 데이터 관리 섹션
              const BackupRestoreWidget(),

              const SizedBox(height: 24),

              // 정보 섹션
              SettingsSection(
                title: l10n.get('info'),
                children: [
                  SettingsTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: l10n.get('app_version'),
                    subtitle: '1.0.7',
                    onTap: () => _showVersionInfo(l10n),
                  ),
                  SettingsTile(
                    leading: Icon(
                      Icons.privacy_tip_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: l10n.get('privacy_policy'),
                    subtitle: l10n.get('privacy_policy_subtitle'),
                    onTap: () => _showPrivacyPolicy(),
                  ),
                  SettingsTile(
                    leading: Icon(
                      Icons.description_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: l10n.get('terms_of_service'),
                    subtitle: l10n.get('terms_of_service_subtitle'),
                    onTap: () => _showTermsOfService(),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Future<void> _editUserName(
    BuildContext context,
    AppProfileState profileState,
    AppLocalizations l10n,
  ) async {
    final controller = TextEditingController(text: profileState.userName ?? '');
    String? error;
    final messenger = ScaffoldMessenger.of(context);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.get('change_username')),
              content: TextField(
                controller: controller,
                autofocus: true,
                maxLength: 24,
                decoration: InputDecoration(
                  labelText: l10n.get('name'),
                  hintText: l10n.get('username_hint'),
                  errorText: error,
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => Navigator.of(context).pop(controller.text),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.get('cancel')),
                ),
                ElevatedButton(
                  onPressed: () {
                    final trimmed = controller.text.trim();
                    if (trimmed.isEmpty) {
                      setState(() => error = l10n.get('username_required'));
                      return;
                    }
                    Navigator.of(context).pop(trimmed);
                  },
                  child: Text(l10n.get('save')),
                ),
              ],
            );
          },
        );
      },
    );

    if (newName != null) {
      await ref.read(appProfileProvider.notifier).updateUserName(newName);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.get('username_updated'))),
      );
    }
  }

  Future<void> _handlePinToggle(BuildContext context, bool enable, AppLocalizations l10n) async {
    if (_pinActionInProgress) return;
    setState(() => _pinActionInProgress = true);

    final pinNotifier = ref.read(pinLockProvider.notifier);
    final profileNotifier = ref.read(appProfileProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (enable) {
        final newPin = await _promptForNewPin(context, l10n);
        if (newPin == null) {
          return;
        }
        await pinNotifier.enablePin(newPin);
        await profileNotifier.setPinEnabled(true);
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.get('pin_enabled'))),
        );
      } else {
        final confirmed = await _confirmDisablePin(context, l10n);
        if (!confirmed) {
          return;
        }
        await pinNotifier.disablePin();
        await profileNotifier.setPinEnabled(false);
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.get('pin_disabled'))),
        );
      }
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.get('pin_error').replaceAll('{error}', error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _pinActionInProgress = false);
      }
    }
  }

  Future<void> _changePin(BuildContext context, AppLocalizations l10n) async {
    if (_pinActionInProgress) return;
    setState(() => _pinActionInProgress = true);

    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await _promptForPinChange(context, l10n);
      if (result == null) {
        return;
      }
      await ref
          .read(pinLockProvider.notifier)
          .changePin(currentPin: result.currentPin, newPin: result.newPin);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.get('pin_changed'))));
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.get('pin_change_failed').replaceAll('{error}', error.toString()))));
    } finally {
      if (mounted) {
        setState(() => _pinActionInProgress = false);
      }
    }
  }

  Future<void> _configureRecoveryQuestion(
    BuildContext context,
    PinLockState pinState,
    AppLocalizations l10n,
  ) async {
    if (_pinActionInProgress) return;
    setState(() => _pinActionInProgress = true);

    final questionController = TextEditingController(
      text: pinState.recoveryQuestion ?? '',
    );
    final answerController = TextEditingController();
    final confirmController = TextEditingController();
    String? error;

    Object? dialogResult;

    try {
      dialogResult = await showDialog<Object?>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: Text(l10n.get('recovery_question_setup')),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: questionController,
                        decoration: InputDecoration(
                          labelText: l10n.get('security_question'),
                          hintText: l10n.get('security_question_hint'),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: answerController,
                        decoration: InputDecoration(labelText: l10n.get('answer')),
                        obscureText: false,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmController,
                        decoration: InputDecoration(
                          labelText: l10n.get('confirm_answer'),
                          errorText: error,
                        ),
                        obscureText: false,
                      ),
                    ],
                  ),
                ),
                actions: [
                  if (pinState.recoveryQuestion != null)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop('cleared'),
                      child: Text(l10n.get('delete')),
                    ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.get('cancel')),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final question = questionController.text.trim();
                      final answer = answerController.text.trim();
                      final confirm = confirmController.text.trim();

                      if (question.isEmpty) {
                        setStateDialog(() => error = l10n.get('security_question_required'));
                        return;
                      }
                      if (answer.isEmpty) {
                        setStateDialog(() => error = l10n.get('answer_required'));
                        return;
                      }
                      if (answer != confirm) {
                        setStateDialog(() => error = l10n.get('answers_mismatch'));
                        return;
                      }

                      Navigator.of(
                        context,
                      ).pop({'question': question, 'answer': answer});
                    },
                    child: Text(l10n.get('save')),
                  ),
                ],
              );
            },
          );
        },
      );

      if (!context.mounted) return;

      final messenger = ScaffoldMessenger.of(context);

      if (dialogResult is Map) {
        final question = (dialogResult['question'] as String).trim();
        final answer = (dialogResult['answer'] as String).trim();
        await ref
            .read(pinLockProvider.notifier)
            .setRecoveryQuestion(question: question, answer: answer);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.get('recovery_question_saved'))),
        );
      } else if (dialogResult == 'cleared') {
        await ref.read(pinLockProvider.notifier).clearRecoveryQuestion();
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.get('recovery_question_deleted'))),
        );
      }
    } finally {
      questionController.dispose();
      answerController.dispose();
      confirmController.dispose();
      if (mounted) {
        setState(() => _pinActionInProgress = false);
      }
    }
  }

  Future<String?> _promptForNewPin(BuildContext context, AppLocalizations l10n) async {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    String? error;

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.get('pin_lock_setup')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    enableSuggestions: false,
                    autocorrect: false,
                    smartDashesType: SmartDashesType.disabled,
                    smartQuotesType: SmartQuotesType.disabled,
                    decoration: InputDecoration(
                      labelText: l10n.get('new_pin_4_digits'),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    enableSuggestions: false,
                    autocorrect: false,
                    smartDashesType: SmartDashesType.disabled,
                    smartQuotesType: SmartQuotesType.disabled,
                    decoration: InputDecoration(
                      labelText: l10n.get('confirm_pin'),
                      counterText: '',
                      errorText: error,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.get('cancel')),
                ),
                ElevatedButton(
                  onPressed: () {
                    final pin = pinController.text.trim();
                    final confirm = confirmController.text.trim();
                    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
                      setState(() => error = l10n.get('pin_4_digits_required'));
                      return;
                    }
                    if (pin != confirm) {
                      setState(() => error = l10n.get('pins_mismatch'));
                      return;
                    }
                    Navigator.of(context).pop(pin);
                  },
                  child: Text(l10n.get('save')),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  Future<bool> _confirmDisablePin(BuildContext context, AppLocalizations l10n) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('disable_pin_lock')),
        content: Text(l10n.get('disable_pin_lock_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.get('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.get('disable')),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<({String currentPin, String newPin})?> _promptForPinChange(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    String? error;

    final result = await showDialog<({String currentPin, String newPin})?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.get('change_pin')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    enableSuggestions: false,
                    autocorrect: false,
                    smartDashesType: SmartDashesType.disabled,
                    smartQuotesType: SmartQuotesType.disabled,
                    decoration: InputDecoration(
                      labelText: l10n.get('current_pin'),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    enableSuggestions: false,
                    autocorrect: false,
                    smartDashesType: SmartDashesType.disabled,
                    smartQuotesType: SmartQuotesType.disabled,
                    decoration: InputDecoration(
                      labelText: l10n.get('new_pin'),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    enableSuggestions: false,
                    autocorrect: false,
                    smartDashesType: SmartDashesType.disabled,
                    smartQuotesType: SmartQuotesType.disabled,
                    decoration: InputDecoration(
                      labelText: l10n.get('confirm_new_pin'),
                      counterText: '',
                      errorText: error,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.get('cancel')),
                ),
                ElevatedButton(
                  onPressed: () {
                    final current = currentController.text.trim();
                    final newPin = newController.text.trim();
                    final confirm = confirmController.text.trim();
                    if (current.length != 4 || newPin.length != 4) {
                      setState(() => error = l10n.get('pin_4_digits_input'));
                      return;
                    }
                    if (!RegExp(r'^\d{4}$').hasMatch(newPin) ||
                        !RegExp(r'^\d{4}$').hasMatch(current)) {
                      setState(() => error = l10n.get('numbers_only'));
                      return;
                    }
                    if (newPin != confirm) {
                      setState(() => error = l10n.get('new_pins_mismatch'));
                      return;
                    }
                    Navigator.of(
                      context,
                    ).pop((currentPin: current, newPin: newPin));
                  },
                  child: Text(l10n.get('change')),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  void _showThumbnailStyleSelector() {
    showDialog<void>(
      context: context,
      builder: (context) => const ThumbnailStyleSelector(),
    );
  }

  // 테스트 기능 제거됨

  String _getThemeDisplayName(ThemeMode themeMode, AppLocalizations l10n) {
    switch (themeMode) {
      case ThemeMode.system:
        return l10n.get('theme_system');
      case ThemeMode.light:
        return l10n.get('theme_light');
      case ThemeMode.dark:
        return l10n.get('theme_dark');
    }
  }

  String _getFontSizeDisplayName(FontSize fontSize, AppLocalizations l10n) {
    switch (fontSize) {
      case FontSize.small:
        return l10n.get('font_size_small');
      case FontSize.medium:
        return l10n.get('font_size_medium');
      case FontSize.large:
        return l10n.get('font_size_large');
      case FontSize.extraLarge:
        return l10n.get('font_size_extra_large');
    }
  }

  String _getLanguageDisplayName(Language language, AppLocalizations l10n) {
    switch (language) {
      case Language.korean:
        return l10n.get('language_korean');
      case Language.english:
        return l10n.get('language_english');
      case Language.japanese:
        return l10n.get('language_japanese');
      case Language.chineseSimplified:
        return l10n.get('language_chinese_simplified');
      case Language.chineseTraditional:
        return l10n.get('language_chinese_traditional');
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showThemeSelector() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => const ThemeSelector(),
    );
  }

  void _showFontSizeSelector() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => const FontSizeSelector(),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => const LanguageSelector(),
    );
  }

  void _selectReminderTime() async {
    final settings = ref.read(settingsProvider);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: settings.reminderTime,
    );

    if (picked != null) {
      ref.read(settingsProvider.notifier).setReminderTime(picked);
    }
  }

  void _showVersionInfo(AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.book_outlined, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EveryDiary'),
                  Text(
                    'v1.0.7',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.get('version_1_0_6_title'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildChangelogItem(l10n.get('version_1_0_6_change_1')),
              _buildChangelogItem(l10n.get('version_1_0_6_change_2')),
              _buildChangelogItem(l10n.get('version_1_0_6_change_3')),
              const SizedBox(height: 20),
              Text(
                l10n.get('version_1_0_5_title'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildChangelogItem(l10n.get('version_1_0_5_change_7')),
              _buildChangelogItem(l10n.get('version_1_0_5_change_8')),
              const SizedBox(height: 20),
              Text(
                l10n.get('version_1_0_4_title'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildChangelogItem(l10n.get('version_1_0_4_change_1')),
              _buildChangelogItem(l10n.get('version_1_0_4_change_2')),
              _buildChangelogItem(l10n.get('version_1_0_4_change_3')),
              _buildChangelogItem(l10n.get('version_1_0_4_change_4')),
              _buildChangelogItem(l10n.get('version_1_0_4_change_5')),
              _buildChangelogItem(l10n.get('version_1_0_4_change_6')),
              const SizedBox(height: 20),
              Text(
                l10n.get('version_1_0_3_title'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildChangelogItem(l10n.get('version_1_0_3_change_1')),
              _buildChangelogItem(l10n.get('version_1_0_3_change_2')),
              _buildChangelogItem(l10n.get('version_1_0_3_change_3')),
              _buildChangelogItem(l10n.get('version_1_0_3_change_4')),
              _buildChangelogItem(l10n.get('version_1_0_3_change_5')),
              const SizedBox(height: 16),
              Text(l10n.get('app_description')),
              const SizedBox(height: 8),
              Text(l10n.get('app_developer')),
              Text(l10n.get('app_contact')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.get('close')),
          ),
        ],
      ),
    );
  }

  Widget _buildChangelogItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    // 개인정보 처리방침 화면으로 이동
    context.go('/settings/privacy-policy');
  }

  void _showTermsOfService() {
    // 이용약관 화면으로 이동
    context.go('/settings/terms-of-service');
  }

  void _showResetDialog() {
    final l10n = ref.read(localizationProvider);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('settings_reset')),
        content: Text(l10n.get('settings_reset_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.get('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(settingsProvider.notifier).resetSettings();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.get('settings_reset_complete'))));
            },
            child: Text(l10n.get('reset')),
          ),
        ],
      ),
    );
  }
}
