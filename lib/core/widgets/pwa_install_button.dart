import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pwa_provider.dart';

/// PWA 설치 버튼 위젯
class PWAInstallButton extends ConsumerWidget {
  const PWAInstallButton({super.key, this.compact = false, this.onInstalled});

  final bool compact;
  final VoidCallback? onInstalled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pwaState = ref.watch(pwaProvider);

    debugPrint('🔍 PWA Install Button - canInstall: ${pwaState.canInstall}');

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
      final notifier = ref.read(pwaProvider.notifier);
      await notifier.installPWA();

      onInstalled?.call();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('앱 설치가 진행됩니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('설치 실패: $e'),
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

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            pwaState.canInstall ? Icons.install_mobile : Icons.mobile_friendly,
            size: 16,
            color: pwaState.canInstall ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(pwaState.canInstall ? '설치 가능' : '설치 완료'),
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
              _buildDebugItem('설치 가능', pwaState.canInstall),
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
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '알림 설정',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '네이티브 앱 알림을 사용하려면 시스템 설정에서 권한을 허용해주세요.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
