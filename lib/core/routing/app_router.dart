import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/diary/screens/calendar_view_screen.dart';
import '../../features/diary/screens/diary_detail_screen.dart';
import '../../features/diary/screens/diary_list_screen.dart';
import '../../features/diary/screens/diary_write_screen.dart';
import '../../features/diary/screens/statistics_screen.dart';
import '../../features/recommendations/screens/memory_notification_settings_screen.dart';
import '../../features/recommendations/screens/memory_screen.dart';
import '../config/config.dart';
import '../providers/pwa_provider.dart';
import '../widgets/cache_info_widget.dart';
import '../widgets/debug_log_widget.dart';
import '../widgets/pwa_install_button.dart';
import '../widgets/pwa_install_prompt.dart';

/// 앱 라우터 설정
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      // 홈 화면
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const EveryDiaryHomePage(),
      ),

      // /home 라우트 추가 (Back 키 문제 해결)
      GoRoute(
        path: '/home',
        name: 'home-alt',
        builder: (context, state) => const DiaryListScreen(),
      ),

      // 일기 관련 라우트
      GoRoute(
        path: '/diary',
        name: 'diary',
        builder: (context, state) => const DiaryListScreen(),
        routes: [
          // 일기 작성
          GoRoute(
            path: 'write',
            name: 'diary-write',
            builder: (context, state) {
              // 쿼리 파라미터가 있으면 편집 모드로 처리
              if (state.uri.queryParameters.isNotEmpty) {
                return DiaryWriteScreen.fromQuery(state.uri.queryParameters);
              }
              return const DiaryWriteScreen();
            },
          ),

          // 일기 상세 보기
          GoRoute(
            path: 'detail/:id',
            name: 'diary-detail',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) {
                return const Scaffold(
                  body: Center(child: Text('잘못된 일기 ID입니다')),
                );
              }
              return DiaryDetailScreen(diaryId: id);
            },
          ),

          // 일기 편집 (일기 작성 화면으로 리다이렉트)
          GoRoute(
            path: 'edit/:id',
            name: 'diary-edit',
            redirect: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return '/diary/write?editId=$id';
            },
          ),

          // 캘린더 뷰
          GoRoute(
            path: 'calendar',
            name: 'diary-calendar',
            builder: (context, state) => const CalendarViewScreen(),
          ),

          // 통계 화면
          GoRoute(
            path: 'statistics',
            name: 'diary-statistics',
            builder: (context, state) => const StatisticsScreen(),
          ),
        ],
      ),

      // 회상 화면
      GoRoute(
        path: '/memory',
        name: 'memory',
        builder: (context, state) => const MemoryScreen(),
        routes: [
          // 회상 알림 설정
          GoRoute(
            path: 'notification-settings',
            name: 'memory-notification-settings',
            builder: (context, state) =>
                const MemoryNotificationSettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const ErrorPage(),
  );

  static GoRouter get router => _router;
}

/// 404 오류 처리 및 안전한 Home 이동
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

/// 홈 페이지 (임시)
class EveryDiaryHomePage extends ConsumerStatefulWidget {
  const EveryDiaryHomePage({super.key});

  @override
  ConsumerState<EveryDiaryHomePage> createState() => _EveryDiaryHomePageState();
}

class _EveryDiaryHomePageState extends ConsumerState<EveryDiaryHomePage> {
  @override
  void initState() {
    super.initState();
    // PWA 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pwaProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ConfigManager.instance.config.appName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.book, size: 100, color: Colors.deepPurple),
                const SizedBox(height: 20),
                Text(
                  'Welcome to ${ConfigManager.instance.config.appName}!',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Environment: ${EnvironmentConfig.environmentName}',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => context.go('/diary'),
                  icon: const Icon(Icons.list),
                  label: const Text('일기 목록'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.go('/diary/write'),
                  icon: const Icon(Icons.edit),
                  label: const Text('일기 작성하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // PWA 설치 프롬프트
                const PWAInstallPrompt(),
                const SizedBox(height: 10),
                // PWA 설치 버튼
                const PWAInstallButton(),
                const SizedBox(height: 20),
                // 캐시 정보
                const CacheInfoWidget(),
                const SizedBox(height: 20),
                // 디버그 로그
                const DebugLogWidget(),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.go('/diary/calendar'),
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('캘린더 보기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.go('/diary/statistics'),
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('통계 보기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.go('/memory'),
                  icon: const Icon(Icons.memory),
                  label: const Text('추억 리마인더'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
