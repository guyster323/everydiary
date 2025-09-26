import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pwa_provider.dart';
import '../providers/pwa_install_provider.dart';

/// PWA 초기화 위젯
/// 앱 시작 시 PWA 서비스를 초기화하고 상태를 관리합니다.
class PWAInitializer extends ConsumerStatefulWidget {
  const PWAInitializer({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PWAInitializer> createState() => _PWAInitializerState();
}

class _PWAInitializerState extends ConsumerState<PWAInitializer> {
  @override
  void initState() {
    super.initState();

    // PWA 초기화를 다음 프레임에서 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePWA();
    });
  }

  Future<void> _initializePWA() async {
    try {
      final pwaNotifier = ref.read(pwaProvider.notifier);
      await pwaNotifier.initialize();
      
      // PWA 설치 서비스도 초기화
      ref.read(pWAInstallStateProvider);
      
      debugPrint('✅ PWA 초기화 완료');
    } catch (e) {
      debugPrint('❌ PWA 초기화 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // PWA 초기화 상태를 감시
    ref.listen<AsyncValue<void>>(pwaInitializationProvider, (previous, next) {
      next.when(
        data: (_) => debugPrint('✅ PWA 초기화 완료'),
        error: (error, _) => debugPrint('❌ PWA 초기화 실패: $error'),
        loading: () => debugPrint('🔄 PWA 초기화 중...'),
      );
    });

    return widget.child;
  }
}
