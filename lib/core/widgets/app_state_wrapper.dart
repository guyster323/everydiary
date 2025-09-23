import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state_provider.dart';
import '../services/app_integration_service.dart';

/// 앱 상태 래퍼 위젯
/// 앱의 전체 상태를 관리하고 초기화하는 최상위 위젯입니다.
class AppStateWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AppStateWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppStateWrapper> createState() => _AppStateWrapperState();
}

class _AppStateWrapperState extends ConsumerState<AppStateWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// 앱 초기화
  Future<void> _initializeApp() async {
    try {
      final integrationService = ref.read(appIntegrationServiceProvider);
      await integrationService.initializeApp(ref);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('앱 초기화 실패: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true; // 에러가 있어도 앱은 계속 실행
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);

    // 초기화 중일 때
    if (!_isInitialized || appState.isLoading) {
      return const AppLoadingScreen();
    }

    // 에러가 있을 때
    if (appState.error != null) {
      return AppErrorScreen(
        error: appState.error!,
        onRetry: () {
          ref.read(appStateProvider.notifier).clearError();
          _initializeApp();
        },
      );
    }

    // 정상 상태
    return widget.child;
  }
}

/// 앱 로딩 화면
class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 로고 또는 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.book_outlined,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 40,
              ),
            ),

            const SizedBox(height: 24),

            // 앱 이름
            Text(
              'EveryDiary',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 8),

            // 부제목
            Text(
              '당신의 일상을 기록하세요',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 48),

            // 로딩 인디케이터
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 16),

            // 로딩 메시지
            Text(
              '앱을 초기화하는 중...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 앱 에러 화면
class AppErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const AppErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 에러 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              // 에러 제목
              Text(
                '앱 초기화 실패',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),

              const SizedBox(height: 16),

              // 에러 메시지
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  error,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),

              // 재시도 버튼
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 앱 정보
              Text(
                '문제가 지속되면 앱을 재시작해주세요.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 앱 상태 모니터 위젯
/// 앱의 상태를 모니터링하고 표시하는 위젯입니다.
class AppStateMonitor extends ConsumerWidget {
  const AppStateMonitor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '앱 상태',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '로딩: ${appState.isLoading ? "예" : "아니오"}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '에러: ${appState.error ?? "없음"}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '설정 로드: ${appState.settings.themeMode.name}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '프로필 로드: ${appState.profile.username.isEmpty ? "없음" : appState.profile.username}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
