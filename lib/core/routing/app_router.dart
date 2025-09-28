import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/diary/screens/calendar_view_screen.dart';
import '../../features/diary/screens/diary_detail_screen.dart';
import '../../features/diary/screens/diary_list_screen.dart';
import '../../features/diary/screens/diary_write_screen.dart';
import '../../features/diary/screens/statistics_screen.dart';
import '../../features/recommendations/screens/memory_notification_settings_screen.dart';
import '../../features/recommendations/screens/memory_screen.dart';
import '../config/config.dart';
import '../constants/app_constants.dart';
import '../providers/google_auth_provider.dart';

class AppRouter {
  static GoRouter buildRouter(ProviderContainer container) {
    final googleNotifier = container.read(googleAuthProvider.notifier);

    return GoRouter(
      initialLocation: AppConstants.loginRoute,
      routes: _routes,
      redirect: (context, state) {
        final googleState = container.read(googleAuthProvider);
        final authState = container.read(authStateProvider);
        final isSignedIn = googleState.isSignedIn || authState.isAuthenticated;
        final path = state.uri.path;

        if (!isSignedIn && AppConstants.protectedPaths.contains(path)) {
          return AppConstants.loginRoute;
        }

        if (isSignedIn && path == AppConstants.loginRoute) {
          return AppConstants.homeRoute;
        }

        return null;
      },
      refreshListenable: AuthRefreshListenable(
        googleNotifier.authEvents,
        container,
      ),
      errorBuilder: (context, state) => const ErrorPage(),
    );
  }

  static List<RouteBase> get _routes => [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const EveryDiaryHomePage(),
    ),
    GoRoute(
      path: AppConstants.loginRoute,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
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
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) {
              return const Scaffold(body: Center(child: Text('잘못된 일기 ID입니다')));
            }
            return DiaryDetailScreen(diaryId: id);
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

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오류'),
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
              '페이지를 찾을 수 없습니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '요청하신 페이지가 존재하지 않습니다',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(
    Stream<User?> googleAuthStream,
    ProviderContainer container,
  ) {
    _googleSubscription = googleAuthStream.listen((_) => notifyListeners());

    _emailAuthSubscription = container.listen<AuthState>(authStateProvider, (
      previous,
      next,
    ) {
      if (previous?.isAuthenticated != next.isAuthenticated) {
        notifyListeners();
      }
    }, fireImmediately: false);
  }

  late final StreamSubscription<User?> _googleSubscription;
  late final ProviderSubscription<AuthState> _emailAuthSubscription;

  @override
  void dispose() {
    _googleSubscription.cancel();
    _emailAuthSubscription.close();
    super.dispose();
  }
}

class EveryDiaryHomePage extends ConsumerWidget {
  const EveryDiaryHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleState = ref.watch(googleAuthProvider);
    final authState = ref.watch(authStateProvider);
    final displayName = googleState.user?.displayName?.trim();
    final email = googleState.user?.email?.trim();
    final fallbackName = authState.user?.name?.trim();

    final greetingName = displayName?.isNotEmpty == true
        ? displayName!
        : (fallbackName?.isNotEmpty == true
            ? fallbackName!
            : (email?.split('@').first ?? '일기 작성자'));

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(ConfigManager.instance.config.appName),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _HomeGreetingCard(greetingName: greetingName),
            const SizedBox(height: 24),
            _QuickActionsSection(),
            const SizedBox(height: 24),
            _HomeInfoSection(theme: theme),
          ],
        ),
      ),
    );
  }
}

class _HomeGreetingCard extends StatelessWidget {
  const _HomeGreetingCard({required this.greetingName});

  final String greetingName;

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
              '$greetingName님, 반가워요 👋',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '오늘의 순간을 기록하고 AI 이미지로 감정을 남겨보세요.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 작업',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _QuickActionButton(
              icon: Icons.edit,
              label: '새 일기 쓰기',
              onTap: () => context.go('/diary/write'),
            ),
            _QuickActionButton(
              icon: Icons.menu_book,
              label: '내 일기 보기',
              onTap: () => context.go('/diary'),
            ),
            _QuickActionButton(
              icon: Icons.bar_chart,
              label: '감정 통계',
              onTap: () => context.go('/diary/statistics'),
            ),
            _QuickActionButton(
              icon: Icons.notifications,
              label: '추억 알림 설정',
              onTap: () => context.go('/memory/notification-settings'),
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

class _HomeInfoSection extends StatelessWidget {
  const _HomeInfoSection({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('도움말', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _InfoRow(
                  icon: Icons.palette,
                  title: 'AI 이미지 생성',
                  description: '일기를 저장하면 감정과 키워드를 분석해 수채화 느낌의 이미지를 만들어 드려요.',
                ),
                SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.cloud_done,
                  title: 'Firebase 백업',
                  description: '작성한 일기는 Google 계정과 연동되어 안전하게 백업됩니다.',
                ),
                SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.lock,
                  title: '로그인 유지',
                  description: '로그인 상태 유지 옵션을 선택하면 다음 방문 때 바로 홈에서 이어서 작성할 수 있어요.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
