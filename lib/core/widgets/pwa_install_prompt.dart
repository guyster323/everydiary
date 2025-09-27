import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pwa_install_provider.dart';
import '../providers/pwa_provider.dart';

/// PWA 설치 프롬프트 위젯
class PWAInstallPrompt extends ConsumerWidget {
  const PWAInstallPrompt({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installState = ref.watch(pwaInstallStateNotifierProvider);
    final isInstallable = ref.watch(pwaInstallableProvider);

    debugPrint(
      '🔍 PWA Install Prompt - isInstalled: ${installState.isInstalled}, isInstallable: $isInstallable',
    );

    // 설치된 경우 숨김 (설치 불가능한 경우는 표시)
    if (installState.isInstalled) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.install_desktop, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  '앱 설치',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _dismissPrompt(ref),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '이 앱을 홈 화면에 설치하여 더 빠르고 편리하게 사용하세요.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _installPWA(context, ref),
                  icon: const Icon(Icons.install_desktop, size: 16),
                  label: const Text('설치'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _dismissPrompt(ref),
                  child: const Text('나중에'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// PWA 설치
  Future<void> _installPWA(BuildContext context, WidgetRef ref) async {
    try {
      final installService = ref.read(pwaInstallServiceProvider);
      final success = await installService.installPWA();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? '앱이 성공적으로 설치되었습니다!' : '앱 설치에 실패했습니다. 다시 시도해주세요.',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ PWA 설치 오류: $e');
    }
  }

  /// 프롬프트 닫기
  void _dismissPrompt(WidgetRef ref) {
    ref
        .read(pwaInstallServiceProvider)
        .trackInstallEvent('prompt_dismissed', <String, dynamic>{});
  }
}

/// PWA 업데이트 알림 위젯
class PWAUpdateNotification extends ConsumerWidget {
  const PWAUpdateNotification({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installState = ref.watch(pwaInstallStateNotifierProvider);

    // 업데이트가 없는 경우 숨김
    if (!installState.isUpdateAvailable) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.system_update, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  '업데이트 사용 가능',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _dismissUpdateNotification(ref),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '새 버전 (${installState.latestVersion ?? '-'})이 사용 가능합니다.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _updatePWA(context, ref),
                  icon: const Icon(Icons.system_update, size: 16),
                  label: const Text('업데이트'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _dismissUpdateNotification(ref),
                  child: const Text('나중에'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// PWA 업데이트
  Future<void> _updatePWA(BuildContext context, WidgetRef ref) async {
    try {
      final installService = ref.read(pwaInstallServiceProvider);
      final success = await installService.updatePWA();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? '업데이트가 완료되었습니다!' : '업데이트에 실패했습니다. 다시 시도해주세요.',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ PWA 업데이트 오류: $e');
    }
  }

  /// 업데이트 알림 닫기
  void _dismissUpdateNotification(WidgetRef ref) {
    ref
        .read(pwaInstallServiceProvider)
        .trackUpdateEvent('update_prompt_dismissed', <String, dynamic>{});
  }
}

/// PWA 설치 상태 표시 위젯
class PWAInstallStatusWidget extends ConsumerWidget {
  const PWAInstallStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installState = ref.watch(pwaInstallStateNotifierProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PWA 설치 상태',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatusRow(
              '설치 상태',
              installState.isInstalled ? '설치됨' : '설치 안됨',
            ),
            _buildStatusRow('설치 가능', installState.isInstallable ? '가능' : '불가능'),
            _buildStatusRow(
              '업데이트',
              installState.isUpdateAvailable ? '사용 가능' : '없음',
            ),
            if (installState.currentVersion != null)
              _buildStatusRow('현재 버전', installState.currentVersion!),
            if (installState.latestVersion != null)
              _buildStatusRow('최신 버전', installState.latestVersion!),
            const SizedBox(height: 16),
            if (installState.isInstallable)
              ElevatedButton.icon(
                onPressed: () => _showInstallDialog(context, ref),
                icon: const Icon(Icons.install_desktop, size: 16),
                label: const Text('앱 설치'),
              ),
            if (installState.isUpdateAvailable)
              ElevatedButton.icon(
                onPressed: () => _showUpdateDialog(context, ref),
                icon: const Icon(Icons.system_update, size: 16),
                label: const Text('앱 업데이트'),
              ),
          ],
        ),
      ),
    );
  }

  /// 상태 행 빌드
  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  /// 설치 다이얼로그 표시
  void _showInstallDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 설치'),
        content: const Text('이 앱을 홈 화면에 설치하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _installPWA(context, ref);
            },
            child: const Text('설치'),
          ),
        ],
      ),
    );
  }

  /// 업데이트 다이얼로그 표시
  void _showUpdateDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 업데이트'),
        content: const Text('새 버전으로 업데이트하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updatePWA(context, ref);
            },
            child: const Text('업데이트'),
          ),
        ],
      ),
    );
  }

  /// PWA 설치
  Future<void> _installPWA(BuildContext context, WidgetRef ref) async {
    try {
      final installService = ref.read(pwaInstallServiceProvider);
      final success = await installService.installPWA();

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('앱이 성공적으로 설치되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ PWA 설치 오류: $e');
    }
  }

  /// PWA 업데이트
  Future<void> _updatePWA(BuildContext context, WidgetRef ref) async {
    try {
      final installService = ref.read(pwaInstallServiceProvider);
      final success = await installService.updatePWA();

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('앱이 성공적으로 업데이트되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ PWA 업데이트 오류: $e');
    }
  }
}
