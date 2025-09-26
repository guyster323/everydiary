import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pwa_provider.dart';

/// PWA 설치 버튼 위젯
class PWAInstallButton extends ConsumerWidget {
  const PWAInstallButton({
    super.key,
    this.compact = false,
    this.onInstalled,
  });

  final bool compact;
  final VoidCallback? onInstalled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pwaState = ref.watch(pwaProvider);

    // PWA 설치 불가능한 경우 숨김
    if (!pwaState.canInstall) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: () => _handleInstall(context, ref),
        icon: const Icon(Icons.install_mobile),
        label: Text(compact ? '설치' : '앱 설치'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: compact
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  Future<void> _handleInstall(BuildContext context, WidgetRef ref) async {
    try {
      final pwaNotifier = ref.read(pwaProvider.notifier);
      await pwaNotifier.installPWA();

      if (onInstalled != null) {
        onInstalled!();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PWA 설치가 시작되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PWA 설치 실패: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

/// PWA 상태 표시 위젯
class PWAStatusWidget extends ConsumerWidget {
  const PWAStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pwaState = ref.watch(pwaProvider);
    final isOnline = ref.watch(onlineStatusProvider);

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 온라인 상태 표시
          Icon(
            isOnline ? Icons.wifi : Icons.wifi_off,
            size: 16,
            color: isOnline ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),

          // Service Worker 상태 표시
          if (pwaState.isServiceWorkerRegistered)
            const Icon(
              Icons.offline_bolt,
              size: 16,
              color: Colors.blue,
            ),

          const SizedBox(width: 4),

          // PWA 설치 가능 상태 표시
          if (pwaState.canInstall)
            const Icon(
              Icons.install_mobile,
              size: 16,
              color: Colors.orange,
            ),
        ],
      ),
    );
  }
}

/// PWA 디버그 정보 위젯
class PWADebugWidget extends ConsumerWidget {
  const PWADebugWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pwaState = ref.watch(pwaProvider);

    return ExpansionTile(
      title: const Text('PWA 디버그 정보'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDebugItem('Service Worker 지원', pwaState.isServiceWorkerSupported),
              _buildDebugItem('Service Worker 등록', pwaState.isServiceWorkerRegistered),
              _buildDebugItem('온라인 상태', pwaState.isOnline),
              _buildDebugItem('PWA 설치 가능', pwaState.canInstall),
              _buildDebugItem('초기화 완료', pwaState.isInitialized),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  ref.read(pwaProvider.notifier).printDebugInfo();
                },
                child: const Text('콘솔 로그'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(pwaProvider.notifier).clearCache();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('캐시가 정리되었습니다.')),
                    );
                  }
                },
                child: const Text('캐시 정리'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDebugItem(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text('$label: '),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: value ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}

/// PWA 알림 설정 위젯
class PWANotificationWidget extends ConsumerWidget {
  const PWANotificationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '알림 설정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'PWA에서 푸시 알림을 받으려면 권한을 허용해주세요.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _requestNotificationPermission(context, ref),
              icon: const Icon(Icons.notifications),
              label: const Text('알림 권한 요청'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestNotificationPermission(BuildContext context, WidgetRef ref) async {
    try {
      final granted = await ref.read(pwaProvider.notifier).requestNotificationPermission();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              granted
                ? '알림 권한이 허용되었습니다.'
                : '알림 권한이 거부되었습니다.',
            ),
            backgroundColor: granted ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('알림 권한 요청 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
