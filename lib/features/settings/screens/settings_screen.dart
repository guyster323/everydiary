import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animations/animations.dart';
import '../../../core/layout/responsive_widgets.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/providers/app_profile_provider.dart';
import '../../../core/providers/pin_lock_provider.dart';
import '../models/settings_enums.dart';
import '../providers/settings_provider.dart';
import '../widgets/backup_restore_widget.dart';
import '../widgets/font_size_selector.dart';
import '../widgets/language_selector.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/theme_selector.dart';
import '../widgets/thumbnail_style_selector.dart';

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

    return Scaffold(
      appBar: CustomAppBar(
        title: '설정',
        actions: [
          IconButton(
            onPressed: _showResetDialog,
            icon: const Icon(Icons.refresh),
            tooltip: '설정 초기화',
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: ScrollAnimations.scrollReveal(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 앱 설정 섹션
              SettingsSection(
                title: '앱 설정',
                children: [
                  SettingsTile(
                    leading: Icon(
                      Icons.image_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: '썸네일 스타일',
                    subtitle: 'AI 썸네일 스타일과 키워드를 설정합니다',
                    onTap: () => _showThumbnailStyleSelector(),
                  ),
                  SettingsTile(
                    leading: Icon(
                      Icons.analytics_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: '썸네일 품질 리포트',
                    subtitle: 'AI 생성 품질 지표와 회귀 테스트를 확인합니다',
                    onTap: _openThumbnailMonitoring,
                  ),
                  SettingsTile(
                    leading: Icon(
                      Icons.palette_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: '테마',
                    subtitle: _getThemeDisplayName(settings.themeMode),
                    onTap: () => _showThemeSelector(),
                  ),
                  SettingsTile(
                    leading: Icon(
                      Icons.text_fields,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: '폰트 크기',
                    subtitle: _getFontSizeDisplayName(settings.fontSize),
                    onTap: () => _showFontSizeSelector(),
                  ),
                  SettingsTile(
                    leading: Icon(
                      Icons.language,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: '언어',
                    subtitle: _getLanguageDisplayName(settings.language),
                    onTap: () => _showLanguageSelector(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SettingsSection(
                title: 'EveryDiary 보안 및 관리',
                children: [
                  SettingsTile(
                    leading: Icon(
                      Icons.person_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: '사용자 이름',
                    subtitle: profileState.userName?.isNotEmpty == true
                        ? profileState.userName
                        : '설정되지 않음',
                    onTap: () => _editUserName(context, profileState),
                  ),
                  SettingsTile(
                    leading: Icon(
                      Icons.lock_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: 'PIN 잠금',
                    subtitle:
                        pinState.isPinEnabled ? '앱 실행 시 PIN 요구' : '사용 안 함',
                    trailing: Switch.adaptive(
                      value: pinState.isPinEnabled,
                      onChanged: _pinActionInProgress
                          ? null
                          : (value) => _handlePinToggle(
                                context,
                                value,
                              ),
                    ),
                    onTap: () => _handlePinToggle(
                      context,
                      !pinState.isPinEnabled,
                    ),
                  ),
                  if (pinState.isPinEnabled)
                    SettingsTile(
                      leading: Icon(
                        Icons.password,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: 'PIN 변경',
                      subtitle: '현재 PIN을 입력하고 새 PIN으로 변경합니다',
                      onTap: () => _changePin(context),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // 알림 설정 섹션
              SettingsSection(
                title: '알림',
                children: [
                  SettingsTile(
                    leading: Icon(
                      Icons.notifications_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: '일기 작성 알림',
                    subtitle: '매일 일기 작성을 알려드립니다',
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
                    title: '알림 시간',
                    subtitle: _formatTime(settings.reminderTime),
                    onTap: () => _selectReminderTime(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 데이터 관리 섹션
              const BackupRestoreWidget(),

              const SizedBox(height: 24),

              // 접근성 설정 섹션
              SettingsSection(
                title: '접근성',
                children: [
                  SettingsTile(
                    leading: Icon(
                      Icons.contrast_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: '고대비 모드',
                    subtitle: '텍스트와 배경의 대비를 높입니다',
                    trailing: Switch(
                      value: settings.highContrast,
                      onChanged: (value) {
                        ref
                            .read(settingsProvider.notifier)
                            .setHighContrast(value);
                      },
                    ),
                  ),
                  SettingsTile(
                    leading: Icon(
                      Icons.volume_up_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: '텍스트 읽기',
                    subtitle: '일기 내용을 음성으로 읽어드립니다',
                    trailing: Switch(
                      value: settings.textToSpeech,
                      onChanged: (value) {
                        ref
                            .read(settingsProvider.notifier)
                            .setTextToSpeech(value);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 정보 섹션
              SettingsSection(
                title: '정보',
                children: [
                  SettingsTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: '앱 버전',
                    subtitle: '1.0.0',
                    onTap: () => _showAppInfo(),
                  ),
                  SettingsTile(
                    leading: Icon(
                      Icons.privacy_tip_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: '개인정보 처리방침',
                    subtitle: '개인정보 보호 정책을 확인하세요',
                    onTap: () => _showPrivacyPolicy(),
                  ),
                  SettingsTile(
                    leading: Icon(
                      Icons.description_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: '이용약관',
                    subtitle: '서비스 이용약관을 확인하세요',
                    onTap: () => _showTermsOfService(),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editUserName(
    BuildContext context,
    AppProfileState profileState,
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
              title: const Text('사용자 이름 변경'),
              content: TextField(
                controller: controller,
                autofocus: true,
                maxLength: 24,
                decoration: InputDecoration(
                  labelText: '이름',
                  hintText: '예: 홍길동',
                  errorText: error,
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => Navigator.of(context).pop(controller.text),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final trimmed = controller.text.trim();
                    if (trimmed.isEmpty) {
                      setState(() => error = '이름을 입력해 주세요');
                      return;
                    }
                    Navigator.of(context).pop(trimmed);
                  },
                  child: const Text('저장'),
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
        const SnackBar(content: Text('사용자 이름이 업데이트되었습니다.')),
      );
    }
  }

  Future<void> _handlePinToggle(
    BuildContext context,
    bool enable,
  ) async {
    if (_pinActionInProgress) return;
    setState(() => _pinActionInProgress = true);

    final pinNotifier = ref.read(pinLockProvider.notifier);
    final profileNotifier = ref.read(appProfileProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (enable) {
        final newPin = await _promptForNewPin(context);
        if (newPin == null) {
          return;
        }
        await pinNotifier.enablePin(newPin);
        await profileNotifier.setPinEnabled(true);
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('PIN 잠금이 활성화되었습니다.')),
        );
      } else {
        final confirmed = await _confirmDisablePin(context);
        if (!confirmed) {
          return;
        }
        await pinNotifier.disablePin();
        await profileNotifier.setPinEnabled(false);
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('PIN 잠금이 비활성화되었습니다.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('PIN 설정 중 오류가 발생했습니다: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _pinActionInProgress = false);
      }
    }
  }

  Future<void> _changePin(BuildContext context) async {
    if (_pinActionInProgress) return;
    setState(() => _pinActionInProgress = true);

    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await _promptForPinChange(context);
      if (result == null) {
        return;
      }
      await ref
          .read(pinLockProvider.notifier)
          .changePin(currentPin: result.currentPin, newPin: result.newPin);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('PIN이 변경되었습니다.')),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('PIN 변경에 실패했습니다: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _pinActionInProgress = false);
      }
    }
  }

  Future<String?> _promptForNewPin(BuildContext context) async {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    String? error;

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('PIN 잠금 설정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: '새 PIN (4자리 숫자)',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: 'PIN 확인',
                      counterText: '',
                      errorText: error,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final pin = pinController.text.trim();
                    final confirm = confirmController.text.trim();
                    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
                      setState(() => error = '4자리 숫자를 입력해 주세요');
                      return;
                    }
                    if (pin != confirm) {
                      setState(() => error = 'PIN이 일치하지 않습니다');
                      return;
                    }
                    Navigator.of(context).pop(pin);
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  Future<bool> _confirmDisablePin(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PIN 잠금 해제'),
        content:
            const Text('PIN 잠금을 비활성화하면 앱 실행 시 인증이 필요하지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('비활성화'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<({String currentPin, String newPin})?> _promptForPinChange(
    BuildContext context,
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
              title: const Text('PIN 변경'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: '현재 PIN',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: '새 PIN',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: '새 PIN 확인',
                      counterText: '',
                      errorText: error,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final current = currentController.text.trim();
                    final newPin = newController.text.trim();
                    final confirm = confirmController.text.trim();
                    if (current.length != 4 || newPin.length != 4) {
                      setState(() => error = '4자리 PIN을 입력해 주세요');
                      return;
                    }
                    if (!RegExp(r'^\d{4}$').hasMatch(newPin) ||
                        !RegExp(r'^\d{4}$').hasMatch(current)) {
                      setState(() => error = '숫자만 입력해 주세요');
                      return;
                    }
                    if (newPin != confirm) {
                      setState(() => error = '새 PIN이 일치하지 않습니다');
                      return;
                    }
                    Navigator.of(context).pop((currentPin: current, newPin: newPin));
                  },
                  child: const Text('변경'),
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

  void _openThumbnailMonitoring() {
    context.push('/settings/thumbnail-monitoring');
  }

  String _getThemeDisplayName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return '시스템 설정';
      case ThemeMode.light:
        return '라이트 모드';
      case ThemeMode.dark:
        return '다크 모드';
    }
  }

  String _getFontSizeDisplayName(FontSize fontSize) {
    switch (fontSize) {
      case FontSize.small:
        return '작게';
      case FontSize.medium:
        return '보통';
      case FontSize.large:
        return '크게';
      case FontSize.extraLarge:
        return '매우 크게';
    }
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
      case Language.spanish:
        return 'Español';
      case Language.french:
        return 'Français';
      case Language.german:
        return 'Deutsch';
      case Language.russian:
        return 'Русский';
      case Language.arabic:
        return 'العربية';
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

  void _showAppInfo() {
    showAboutDialog(
      context: context,
      applicationName: 'EveryDiary',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.book_outlined, size: 48),
      children: [
        const Text('일기를 통해 마음을 정리하고 성장하는 앱입니다.'),
        const SizedBox(height: 16),
        const Text('개발: EveryDiary Team'),
        const Text('문의: support@everydiary.com'),
      ],
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
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('설정 초기화'),
        content: const Text('모든 설정을 기본값으로 초기화하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(settingsProvider.notifier).resetSettings();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('설정이 초기화되었습니다')));
            },
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }
}
