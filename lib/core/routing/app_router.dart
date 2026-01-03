import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_profile_provider.dart';
import '../../core/providers/pin_lock_provider.dart';
import '../../core/services/image_generation_service.dart';
import '../../features/diary/screens/calendar_view_screen.dart';
import '../../features/diary/screens/diary_detail_screen.dart';
import '../../features/diary/screens/diary_list_screen.dart';
import '../../features/diary/screens/diary_write_screen.dart';
import '../../features/diary/screens/statistics_screen.dart';
import '../../features/diary/services/diary_list_service.dart';
import '../../features/home/widgets/app_intro_section.dart';
import '../../features/home/widgets/generation_count_widget.dart';
import '../../features/onboarding/screens/app_setup_screen.dart';
import '../../features/onboarding/screens/permission_request_screen.dart';
import '../../features/onboarding/screens/video_intro_screen.dart';
import '../../features/recommendations/screens/memory_notification_settings_screen.dart';
import '../../features/recommendations/screens/memory_screen.dart';
import '../../features/security/screens/pin_unlock_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
// import 제거: 구독 화면 및 썸네일 품질 리포트 화면 비활성화
import '../../shared/models/diary_entry.dart';
import '../../shared/widgets/ad_policy_notice_dialog.dart';
import '../../shared/services/database_service.dart';
import '../../shared/services/diary_image_helper.dart';
import '../../shared/services/repositories/diary_repository.dart';
import '../config/config.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../providers/localization_provider.dart';

Future<String?> _loadLatestDiaryImagePath(Ref ref) async {
  try {
    final databaseService = DatabaseService();
    final repository = DiaryRepository(databaseService);
    final imageService = ImageGenerationService();
    await imageService.initialize();
    final helper = DiaryImageHelper(
      databaseService: databaseService,
      imageGenerationService: imageService,
    );

    const primaryFilter = DiaryEntryFilter(limit: 20);

    final diaries = await repository.getDiaryEntriesWithFilter(primaryFilter);

    for (final diary in diaries) {
      final path = await helper.ensureImagePath(diary);
      if (path != null && path.isNotEmpty && await File(path).exists()) {
        return path;
      }
    }

    final history = imageService.getGenerationHistory();
    for (final entry in history.reversed) {
      final result = entry['result'] as Map<String, dynamic>?;
      final localPath = result?['local_image_path'] as String?;
      if (localPath != null && await File(localPath).exists()) {
        return localPath;
      }
    }
  } catch (e, stackTrace) {
    debugPrint('❌ 최신 일기 이미지 로딩 실패: $e\n$stackTrace');
  }

  return null;
}

final latestDiaryImageProvider = StreamProvider.autoDispose<String?>((
  ref,
) async* {
  if (kIsWeb) {
    yield null;
    return;
  }

  final controller = StreamController<String?>();

  Future<void> emitLatest() async {
    try {
      final latestPath = await _loadLatestDiaryImagePath(ref);
      if (!controller.isClosed) {
        controller.add(latestPath);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ 홈 배경 이미지 스트림 갱신 실패: $e\n$stackTrace');
      if (!controller.isClosed) {
        controller.add(null);
      }
    }
  }

  await emitLatest();

  final refreshNotifier = DiaryListRefreshNotifier();
  final refreshSubscription = refreshNotifier.refreshStream.listen((_) {
    unawaited(emitLatest());
  });

  ref.onDispose(() {
    refreshSubscription.cancel();
    if (!controller.isClosed) {
      controller.close();
    }
  });

  yield* controller.stream;
});

class AppRouter {
  static GoRouter? _router;

  static GoRouter get instance {
    final router = _router;
    if (router == null) {
      throw StateError('GoRouter has not been initialized yet');
    }
    return router;
  }

  // 비디오 인트로 표시 여부 캐시 (앱 실행 중 한 번만 확인)
  static bool? _shouldShowVideoCache;
  static bool _videoCheckDone = false;

  /// 비디오 인트로 캐시 리셋 (설정 변경 시 호출)
  static void resetVideoIntroCache() {
    _shouldShowVideoCache = null;
    _videoCheckDone = false;
  }

  /// 비디오 인트로 체크를 백그라운드에서 실행
  static Future<void> _checkVideoIntroAsync() async {
    if (_videoCheckDone) return;
    try {
      _shouldShowVideoCache = await VideoIntroScreen.shouldShowIntro();
      _videoCheckDone = true;
      debugPrint('🎬 [Router] 비디오 인트로 체크 완료: $_shouldShowVideoCache');
    } catch (e) {
      debugPrint('🎬 [Router] 비디오 인트로 체크 오류: $e');
      _videoCheckDone = true;
      _shouldShowVideoCache = false;
    }
  }

  static GoRouter buildRouter(ProviderContainer container) {
    // 비디오 인트로 체크 (라우터 빌드 전에 동기적으로 시작)
    if (!_videoCheckDone) {
      _checkVideoIntroAsync();
    }

    final router = GoRouter(
      initialLocation: AppConstants.homeRoute,
      routes: _routes,
      redirect: (context, state) {
        final profile = container.read(appProfileProvider);
        final pinState = container.read(pinLockProvider);
        final path = state.uri.path;

        // 초기화 미완료 시 대기
        if (!profile.isInitialized || !pinState.isInitialized) {
          return null;
        }

        // 온보딩 완료된 경우: 인트로/비디오 화면에서 홈으로
        if (profile.onboardingComplete) {
          if (path == AppConstants.introRoute) {
            if (pinState.isPinEnabled && !pinState.isUnlocked) {
              return AppConstants.pinRoute;
            }
            return AppConstants.homeRoute;
          }
          // 비디오 인트로 화면은 그대로 허용 (홈에서 체크 후 이동)
        }

        // 온보딩 미완료 시
        if (!profile.onboardingComplete) {
          if (path != AppConstants.introRoute && path != AppConstants.videoIntroRoute) {
            return AppConstants.introRoute;
          }
        }

        // PIN 잠금 처리
        if (pinState.isPinEnabled && !pinState.isUnlocked) {
          if (path != AppConstants.pinRoute && path != AppConstants.videoIntroRoute) {
            final redirectTarget = state.uri.toString();
            return '${AppConstants.pinRoute}?from=${Uri.encodeComponent(redirectTarget)}';
          }
        } else if (path == AppConstants.pinRoute) {
          return AppConstants.homeRoute;
        }

        return null;
      },
      refreshListenable: AppStateRefreshListenable(container),
      errorBuilder: (context, state) => const ErrorPage(),
    );
    _router = router;
    return router;
  }

  static List<RouteBase> get _routes => [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const EveryDiaryHomePage(),
    ),
    GoRoute(
      path: AppConstants.videoIntroRoute,
      name: 'video-intro',
      builder: (context, state) => const VideoIntroScreen(),
    ),
    GoRoute(
      path: AppConstants.introRoute,
      name: 'intro',
      builder: (context, state) => const AppSetupScreen(),
    ),
    GoRoute(
      path: AppConstants.permissionRoute,
      name: 'permission',
      builder: (context, state) => const PermissionRequestScreen(),
    ),
    GoRoute(
      path: AppConstants.pinRoute,
      name: 'pin-unlock',
      builder: (context, state) =>
          PinUnlockScreen(redirectPath: state.uri.queryParameters['from']),
    ),
    GoRoute(
      path: '/diary',
      name: 'diary',
      builder: (context, state) => const DiaryListScreen(),
      routes: [
        GoRoute(
          path: 'write',
          name: 'diary-write',
          builder: (context, state) {
            if (state.uri.queryParameters.isNotEmpty) {
              return DiaryWriteScreen.fromQuery(state.uri.queryParameters);
            }
            return const DiaryWriteScreen();
          },
        ),
        GoRoute(
          path: 'detail/:id',
          name: 'diary-detail',
          builder: (context, state) {
            return Consumer(builder: (context, ref, _) {
              final l10n = ref.watch(localizationProvider);
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) {
                return Scaffold(
                  body: Center(child: Text(l10n.get('invalid_diary_id'))),
                );
              }
              return DiaryDetailScreen(diaryId: id);
            });
          },
        ),
        GoRoute(
          path: 'edit/:id',
          name: 'diary-edit',
          redirect: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return '/diary/write?editId=$id';
          },
        ),
        GoRoute(
          path: 'calendar',
          name: 'diary-calendar',
          builder: (context, state) => const CalendarViewScreen(),
        ),
        GoRoute(
          path: 'statistics',
          name: 'diary-statistics',
          builder: (context, state) => const StatisticsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
      routes: [
        // 무료 버전: 구독 및 테스트 기능 제거
        GoRoute(
          path: 'privacy-policy',
          name: 'settings-privacy-policy',
          builder: (context, state) => const _SettingsDocumentPlaceholder(
            isPrivacyPolicy: true,
          ),
        ),
        GoRoute(
          path: 'terms-of-service',
          name: 'settings-terms-of-service',
          builder: (context, state) => const _SettingsDocumentPlaceholder(
            isPrivacyPolicy: false,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/memory',
      name: 'memory',
      builder: (context, state) => const MemoryScreen(),
      routes: [
        GoRoute(
          path: 'notification-settings',
          name: 'memory-notification-settings',
          builder: (context, state) => const MemoryNotificationSettingsScreen(),
        ),
      ],
    ),
  ];
}

class ErrorPage extends ConsumerWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(localizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('error_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.get('page_not_found'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.get('page_not_found_subtitle'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: Text(l10n.get('back_to_home')),
            ),
          ],
        ),
      ),
    );
  }
}

class AppStateRefreshListenable extends ChangeNotifier {
  AppStateRefreshListenable(this._container) {
    _profileSubscription = _container.listen<AppProfileState>(
      appProfileProvider,
      (previous, next) {
        if (previous == null ||
            previous.onboardingComplete != next.onboardingComplete ||
            previous.pinEnabled != next.pinEnabled ||
            previous.isInitialized != next.isInitialized ||
            previous.userName != next.userName) {
          notifyListeners();
        }
      },
      fireImmediately: false,
    );

    _pinSubscription = _container.listen<PinLockState>(pinLockProvider, (
      previous,
      next,
    ) {
      if (previous == null ||
          previous.isUnlocked != next.isUnlocked ||
          previous.isPinEnabled != next.isPinEnabled ||
          previous.lockExpiresAt != next.lockExpiresAt ||
          previous.isInitialized != next.isInitialized) {
        notifyListeners();
      }
    }, fireImmediately: false);
  }

  final ProviderContainer _container;
  late final ProviderSubscription<AppProfileState> _profileSubscription;
  late final ProviderSubscription<PinLockState> _pinSubscription;

  @override
  void dispose() {
    _profileSubscription.close();
    _pinSubscription.close();
    super.dispose();
  }
}

class EveryDiaryHomePage extends ConsumerStatefulWidget {
  const EveryDiaryHomePage({super.key});

  // 세션 레벨 플래그 (앱 실행 중 한 번만 비디오 표시)
  static bool _videoShownThisSession = false;

  /// 세션 플래그 리셋 (설정 변경 시 호출)
  static void resetVideoSessionFlag() {
    _videoShownThisSession = false;
    debugPrint('🎬 [Home] 비디오 세션 플래그 리셋됨');
  }

  @override
  ConsumerState<EveryDiaryHomePage> createState() => _EveryDiaryHomePageState();
}

class _EveryDiaryHomePageState extends ConsumerState<EveryDiaryHomePage> {
  bool _dialogChecked = false;

  @override
  void initState() {
    super.initState();
    // 인트로 영상 체크 및 표시
    _checkAndShowVideoIntro();
    // 앱 시작 시 AdMob 정책 공지 다이얼로그 표시 (지연)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _showAdPolicyNoticeIfNeeded();
    });
  }

  Future<void> _checkAndShowVideoIntro() async {
    // 이미 이번 세션에서 비디오를 봤으면 스킵
    if (EveryDiaryHomePage._videoShownThisSession) return;

    try {
      final shouldShow = await VideoIntroScreen.shouldShowIntro();
      debugPrint('🎬 [Home] shouldShowIntro 결과: $shouldShow');
      if (shouldShow && mounted) {
        EveryDiaryHomePage._videoShownThisSession = true; // 세션 플래그 설정
        context.go(AppConstants.videoIntroRoute);
      }
    } catch (e) {
      debugPrint('🎬 [Home] 비디오 인트로 체크 오류: $e');
    }
  }

  Future<void> _showAdPolicyNoticeIfNeeded() async {
    if (_dialogChecked || !mounted) return;
    _dialogChecked = true;
    await AdPolicyNoticeDialog.showIfNeeded(context);
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(appProfileProvider);
    final l10n = ref.watch(localizationProvider);
    final theme = Theme.of(context);

    // 프로필 로딩 중에도 UI 표시 (기본값 사용)
    final resolvedName = profileState.userName?.trim();
    final greetingName = (resolvedName != null && resolvedName.isNotEmpty)
        ? resolvedName
        : l10n.get('diary_author');

    return Scaffold(
      appBar: AppBar(title: Text(ConfigManager.instance.config.appName)),
      body: SafeArea(
        child: Stack(
          children: [
            // 배경 - 단색 (기본)
            Positioned.fill(
              child: Container(color: theme.colorScheme.surface),
            ),
            // 배경 이미지 지연 로딩 (콘텐츠 아래에 위치)
            _DelayedBackgroundImage(theme: theme),
            // 그라디언트 오버레이 (배경 이미지 위, 콘텐츠 아래)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.surface.withValues(alpha: 0.1),
                      theme.colorScheme.surface.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),
            // 콘텐츠 (최상단)
            Positioned.fill(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _HomeGreetingCard(greetingName: greetingName, l10n: l10n),
                  const SizedBox(height: 24),
                  const GenerationCountWidget(),
                  const SizedBox(height: 24),
                  _QuickActionsSection(l10n: l10n),
                  const SizedBox(height: 24),
                  const AppIntroSection(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 배경 이미지 지연 로딩 위젯
class _DelayedBackgroundImage extends ConsumerStatefulWidget {
  final ThemeData theme;

  const _DelayedBackgroundImage({required this.theme});

  @override
  ConsumerState<_DelayedBackgroundImage> createState() => _DelayedBackgroundImageState();
}

class _DelayedBackgroundImageState extends ConsumerState<_DelayedBackgroundImage> {
  bool _shouldLoad = false;

  @override
  void initState() {
    super.initState();
    // UI가 먼저 표시된 후 배경 이미지 로딩
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _shouldLoad = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldLoad) return const SizedBox.shrink();

    final latestImageAsync = ref.watch(latestDiaryImageProvider);

    return Positioned.fill(
      child: latestImageAsync.when(
        data: (path) {
          if (path == null || path.isEmpty) {
            return const SizedBox.shrink();
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Stack(
              key: ValueKey(path),
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, _, __) => const SizedBox.shrink(),
                ),
                Container(
                  color: widget.theme.colorScheme.surface.withValues(alpha: 0.3),
                ),
              ],
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _HomeGreetingCard extends StatelessWidget {
  const _HomeGreetingCard({
    required this.greetingName,
    required this.l10n,
  });

  final String greetingName;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.get('home_greeting').replaceAll('{name}', greetingName),
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.get('home_subtitle'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.get('quick_actions_title'), style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _QuickActionButton(
              icon: Icons.edit,
              label: l10n.get('new_diary'),
              onTap: () => context.go('/diary/write'),
            ),
            _QuickActionButton(
              icon: Icons.menu_book,
              label: l10n.get('view_diaries'),
              onTap: () => context.go('/diary'),
            ),
            _QuickActionButton(
              icon: Icons.bar_chart,
              label: l10n.get('statistics_action'),
              onTap: () => context.go('/diary/statistics'),
            ),
            _QuickActionButton(
              icon: Icons.notifications,
              label: l10n.get('memory_notifications'),
              onTap: () => context.go('/memory/notification-settings'),
            ),
            _QuickActionButton(
              icon: Icons.settings,
              label: l10n.get('settings'),
              onTap: () => context.go('/settings'),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: FilledButton.tonalIcon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

class _SettingsDocumentPlaceholder extends ConsumerWidget {
  const _SettingsDocumentPlaceholder({required this.isPrivacyPolicy});

  final bool isPrivacyPolicy;

  String _getContent(WidgetRef ref) {
    final l10n = ref.read(localizationProvider);
    if (isPrivacyPolicy) {
      return l10n.get('privacy_policy_content');
    } else {
      return l10n.get('terms_of_service_content');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(localizationProvider);
    final title = isPrivacyPolicy
        ? l10n.get('privacy_policy_title')
        : l10n.get('terms_of_service_title');

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SelectableText(
          _getContent(ref),
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
        ),
      ),
    );
  }
}
