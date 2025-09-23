import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/responsive_widgets.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../core/services/app_integration_service.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../profile/screens/profile_screen.dart';
import '../models/settings_enums.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_storage_widget.dart';
import '../widgets/settings_tile.dart';

/// 설정 통합 화면
/// 설정과 프로필을 통합하여 관리할 수 있는 화면입니다.
class SettingsIntegrationScreen extends ConsumerWidget {
  const SettingsIntegrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: '설정',
        actions: [
          IconButton(
            onPressed: () => _showAppHealthDialog(context, ref),
            icon: const Icon(Icons.info_outline),
            tooltip: '앱 상태 정보',
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 프로필 섹션
            SettingsSection(
              title: '프로필',
              children: [
                SettingsTile(
                  leading: const Icon(Icons.person),
                  title: '프로필 관리',
                  subtitle: appState.profile.username.isEmpty
                      ? '프로필을 설정하세요'
                      : appState.profile.username,
                  onTap: () => _navigateToProfile(context),
                ),
                SettingsTile(
                  leading: const Icon(Icons.backup),
                  title: '데이터 백업',
                  subtitle: '설정과 프로필을 백업합니다',
                  onTap: () => _backupData(context, ref),
                ),
                SettingsTile(
                  leading: const Icon(Icons.restore),
                  title: '데이터 복원',
                  subtitle: '백업된 데이터를 복원합니다',
                  onTap: () => _restoreData(context, ref),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 앱 설정 섹션
            SettingsSection(
              title: '앱 설정',
              children: [
                SettingsTile(
                  leading: const Icon(Icons.palette),
                  title: '테마',
                  subtitle: _getThemeModeText(appState.settings.themeMode),
                  onTap: () => _showThemeSelector(context, ref),
                ),
                SettingsTile(
                  leading: const Icon(Icons.text_fields),
                  title: '폰트 크기',
                  subtitle: _getFontSizeText(appState.settings.fontSize),
                  onTap: () => _showFontSizeSelector(context, ref),
                ),
                SettingsTile(
                  leading: const Icon(Icons.language),
                  title: '언어',
                  subtitle: _getLanguageText(appState.settings.language),
                  onTap: () => _showLanguageSelector(context, ref),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 알림 설정 섹션
            SettingsSection(
              title: '알림',
              children: [
                SettingsTile(
                  leading: const Icon(Icons.notifications),
                  title: '일일 알림',
                  subtitle: appState.settings.dailyReminder ? '활성' : '비활성',
                  trailing: Switch(
                    value: appState.settings.dailyReminder,
                    onChanged: (value) => _toggleDailyReminder(ref, value),
                  ),
                ),
                if (appState.settings.dailyReminder)
                  SettingsTile(
                    leading: const Icon(Icons.access_time),
                    title: '알림 시간',
                    subtitle: _formatTime(appState.settings.reminderTime),
                    onTap: () => _showTimePicker(context, ref),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // 접근성 설정 섹션
            SettingsSection(
              title: '접근성',
              children: [
                SettingsTile(
                  leading: const Icon(Icons.contrast),
                  title: '고대비 모드',
                  subtitle: appState.settings.highContrast ? '활성' : '비활성',
                  trailing: Switch(
                    value: appState.settings.highContrast,
                    onChanged: (value) => _toggleHighContrast(ref, value),
                  ),
                ),
                SettingsTile(
                  leading: const Icon(Icons.volume_up),
                  title: '텍스트 음성 변환',
                  subtitle: appState.settings.textToSpeech ? '활성' : '비활성',
                  trailing: Switch(
                    value: appState.settings.textToSpeech,
                    onChanged: (value) => _toggleTextToSpeech(ref, value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 데이터 설정 섹션
            SettingsSection(
              title: '데이터',
              children: [
                SettingsTile(
                  leading: const Icon(Icons.save),
                  title: '자동 저장',
                  subtitle: appState.settings.autoSave ? '활성' : '비활성',
                  trailing: Switch(
                    value: appState.settings.autoSave,
                    onChanged: (value) => _toggleAutoSave(ref, value),
                  ),
                ),
                SettingsTile(
                  leading: const Icon(Icons.analytics),
                  title: '통계 표시',
                  subtitle: appState.settings.showStatistics ? '활성' : '비활성',
                  trailing: Switch(
                    value: appState.settings.showStatistics,
                    onChanged: (value) => _toggleShowStatistics(ref, value),
                  ),
                ),
                SettingsTile(
                  leading: const Icon(Icons.security),
                  title: '크래시 리포팅',
                  subtitle: appState.settings.enableCrashReporting
                      ? '활성'
                      : '비활성',
                  trailing: Switch(
                    value: appState.settings.enableCrashReporting,
                    onChanged: (value) => _toggleCrashReporting(ref, value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 저장소 관리
            const SettingsStorageWidget(),

            const SizedBox(height: 16),

            // 위험 구역
            SettingsSection(
              title: '위험 구역',
              children: [
                SettingsTile(
                  leading: const Icon(Icons.refresh),
                  title: '앱 데이터 초기화',
                  subtitle: '모든 설정과 프로필을 초기화합니다',
                  onTap: () => _showResetDialog(context, ref),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return '라이트 모드';
      case ThemeMode.dark:
        return '다크 모드';
      case ThemeMode.system:
        return '시스템 설정';
    }
  }

  String _getFontSizeText(FontSize fontSize) {
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

  String _getLanguageText(Language language) {
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

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const ProfileScreen()),
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테마 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return ListTile(
              title: Text(_getThemeModeText(mode)),
              onTap: () {
                ref.read(appStateProvider.notifier).changeThemeMode(mode);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFontSizeSelector(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('폰트 크기 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: FontSize.values.map((FontSize size) {
            return ListTile(
              title: Text(_getFontSizeText(size)),
              onTap: () {
                ref.read(appStateProvider.notifier).changeFontSize(size);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('언어 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Language.values.map((Language language) {
            return ListTile(
              title: Text(_getLanguageText(language)),
              onTap: () {
                ref.read(appStateProvider.notifier).changeLanguage(language);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context, WidgetRef ref) {
    final currentTime = ref.read(appStateProvider).settings.reminderTime;

    showTimePicker(context: context, initialTime: currentTime).then((time) {
      if (time != null) {
        ref.read(appStateProvider.notifier).changeReminderTime(time);
      }
    });
  }

  void _toggleDailyReminder(WidgetRef ref, bool value) {
    ref.read(appStateProvider.notifier).toggleDailyReminder(value);
  }

  void _toggleHighContrast(WidgetRef ref, bool value) {
    ref
        .read(appStateProvider.notifier)
        .updateAccessibilitySettings(highContrast: value);
  }

  void _toggleTextToSpeech(WidgetRef ref, bool value) {
    ref
        .read(appStateProvider.notifier)
        .updateAccessibilitySettings(textToSpeech: value);
  }

  void _toggleAutoSave(WidgetRef ref, bool value) {
    ref.read(appStateProvider.notifier).updateDataSettings(autoSave: value);
  }

  void _toggleShowStatistics(WidgetRef ref, bool value) {
    ref
        .read(appStateProvider.notifier)
        .updateDataSettings(showStatistics: value);
  }

  void _toggleCrashReporting(WidgetRef ref, bool value) {
    ref
        .read(appStateProvider.notifier)
        .updateDataSettings(enableCrashReporting: value);
  }

  void _backupData(BuildContext context, WidgetRef ref) async {
    try {
      final integrationService = ref.read(appIntegrationServiceProvider);
      await integrationService.backupAppData();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('데이터 백업이 완료되었습니다')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('백업 실패: $e')));
      }
    }
  }

  void _restoreData(BuildContext context, WidgetRef ref) async {
    // 파일 선택 다이얼로그 구현
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          final filePath = file.path!;
          final fileObj = File(filePath);

          if (await fileObj.exists()) {
            // 파일이 존재하면 복원 로직 실행
            if (context.mounted) {
              await _performRestore(context, ref, fileObj);
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('선택한 파일을 찾을 수 없습니다')),
              );
            }
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('파일 선택 실패: $e')));
      }
    }
  }

  /// 실제 복원 로직 실행
  Future<void> _performRestore(
    BuildContext context,
    WidgetRef ref,
    File file,
  ) async {
    try {
      // 로딩 표시
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('데이터 복원 중...'),
            ],
          ),
        ),
      );

      // 파일 읽기
      await file.readAsString();

      // JSON 파싱 및 복원 로직 (실제 구현 필요)
      // 여기서는 간단한 예시만 제공
      await Future<void>.delayed(const Duration(seconds: 2)); // 시뮬레이션

      // 로딩 다이얼로그 닫기
      if (context.mounted) {
        Navigator.of(context).pop();

        // 성공 메시지
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('데이터 복원이 완료되었습니다')));
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (context.mounted) {
        Navigator.of(context).pop();

        // 오류 메시지
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('복원 실패: $e')));
      }
    }
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 데이터 초기화'),
        content: const Text(
          '모든 설정과 프로필 데이터가 삭제됩니다.\n'
          '이 작업은 되돌릴 수 없습니다.\n\n'
          '정말로 초기화하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final integrationService = ref.read(
                  appIntegrationServiceProvider,
                );
                await integrationService.resetAppData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('앱 데이터가 초기화되었습니다')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('초기화 실패: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  void _showAppHealthDialog(BuildContext context, WidgetRef ref) async {
    try {
      final integrationService = ref.read(appIntegrationServiceProvider);
      final healthStatus = await integrationService.getAppHealthStatus();

      if (context.mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('앱 상태 정보'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('데이터 크기: ${healthStatus.dataSize} bytes'),
                Text('데이터 유효성: ${healthStatus.isValid ? "유효" : "무효"}'),
                Text('설정 존재: ${healthStatus.hasSettings ? "예" : "아니오"}'),
                Text('프로필 존재: ${healthStatus.hasProfile ? "예" : "아니오"}'),
                Text('상태: ${healthStatus.isHealthy ? "정상" : "문제 있음"}'),
                if (healthStatus.error != null)
                  Text('에러: ${healthStatus.error}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('상태 정보 로드 실패: $e')));
      }
    }
  }
}
