import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/animations/animations.dart';
import '../../../core/layout/responsive_widgets.dart';
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

/// 설정 화면
/// 사용자가 앱의 다양한 설정을 관리할 수 있는 화면입니다.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

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

  void _showThumbnailStyleSelector() {
    showDialog<void>(
      context: context,
      builder: (context) => const ThumbnailStyleSelector(),
    );
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
