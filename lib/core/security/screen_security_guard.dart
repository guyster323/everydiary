import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../providers/pin_lock_provider.dart';
import '../routing/app_router.dart';
import '../services/screen_security_service.dart';
import '../utils/logger.dart';

class ScreenSecurityGuard extends ConsumerStatefulWidget {
  const ScreenSecurityGuard({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ScreenSecurityGuard> createState() =>
      _ScreenSecurityGuardState();
}

class _ScreenSecurityGuardState extends ConsumerState<ScreenSecurityGuard>
    with WidgetsBindingObserver {
  bool _blurFromLifecycle = false;
  bool _navigateScheduled = false;
  late final ProviderSubscription<PinLockState> _pinSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pinSubscription = ref.listenManual<PinLockState>(
      pinLockProvider,
      (previous, next) => unawaited(_applySecureFlag(next)),
      fireImmediately: true,
    );
    unawaited(_applySecureFlag(ref.read(pinLockProvider)));
  }

  Future<void> _applySecureFlag(PinLockState state) async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }
    // Debug 모드에서는 스크린샷 허용 (플레이스토어 홍보 이미지 제작용)
    if (kDebugMode) {
      try {
        await ScreenSecurityService.instance.setSecure(false);
      } catch (error) {
        Logger.warning(
          '스크린 보안 플래그 해제에 실패했습니다: $error',
          tag: 'ScreenSecurityGuard',
        );
      }
      return;
    }
    try {
      await ScreenSecurityService.instance.setSecure(state.isPinEnabled);
    } catch (error) {
      Logger.warning(
        '스크린 보안 플래그 적용에 실패했습니다: $error',
        tag: 'ScreenSecurityGuard',
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pinSubscription.close();
    if (!kIsWeb && Platform.isAndroid) {
      unawaited(ScreenSecurityService.instance.setSecure(false));
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final pinNotifier = ref.read(pinLockProvider.notifier);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        pinNotifier.requireUnlock();
        if (!_blurFromLifecycle) {
          setState(() => _blurFromLifecycle = true);
        }
        break;
      case AppLifecycleState.resumed:
        if (_blurFromLifecycle) {
          setState(() => _blurFromLifecycle = false);
        }
        break;
    }
  }

  bool _shouldBlur(PinLockState state, String routePath) {
    if (!state.isPinEnabled) {
      return false;
    }

    if (routePath == AppConstants.pinRoute) {
      return false;
    }

    if (routePath == AppConstants.homeRoute && !state.isUnlocked) {
      return true;
    }

    return _blurFromLifecycle || !state.isUnlocked;
  }

  void _queueNavigateToPin(String redirectTarget) {
    if (_navigateScheduled) {
      return;
    }

    _navigateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateScheduled = false;
      if (!mounted) {
        return;
      }
      _navigateToPin(redirectOverride: redirectTarget);
    });
  }

  void _navigateToPin({String? redirectOverride}) {
    if (!mounted) {
      return;
    }

    final router = GoRouter.maybeOf(context);
    final currentUri =
        router?.routeInformationProvider.value.uri ??
        AppRouter.instance.routeInformationProvider.value.uri;
    final currentLocation = redirectOverride ?? currentUri.toString();
    final currentPath = currentUri.path;

    if (currentPath == AppConstants.pinRoute && redirectOverride == null) {
      return;
    }

    final redirectTarget = currentLocation.isEmpty
        ? AppConstants.homeRoute
        : currentLocation;
    final encoded = Uri.encodeComponent(redirectTarget);

    debugPrint(
      '[ScreenSecurityGuard] navigate to PIN (from: $currentLocation, override: ${redirectOverride != null})',
    );

    ref.read(pinLockProvider.notifier).requireUnlock();

    final targetRouter = router ?? AppRouter.instance;
    targetRouter.go('${AppConstants.pinRoute}?from=$encoded');

    if (_blurFromLifecycle) {
      setState(() {
        _blurFromLifecycle = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinLockProvider);
    final router = GoRouter.maybeOf(context);
    final currentPath =
        router?.routeInformationProvider.value.uri.path ??
        AppRouter.instance.routeInformationProvider.value.uri.path;
    final currentLocation =
        router?.routeInformationProvider.value.uri.toString() ??
        AppRouter.instance.routeInformationProvider.value.uri.toString();
    final shouldBlur = _shouldBlur(pinState, currentPath);
    final showUnlockButton =
        pinState.isPinEnabled &&
        !pinState.isUnlocked &&
        currentPath != AppConstants.pinRoute;

    if (showUnlockButton) {
      _queueNavigateToPin(currentLocation);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: shouldBlur ? 1 : 0,
          child: IgnorePointer(
            ignoring: !shouldBlur,
            child: _BlurOverlay(
              isAndroid: !kIsWeb && Platform.isAndroid,
              showUnlockAction: showUnlockButton,
              onUnlockPressed: showUnlockButton ? () => _navigateToPin() : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _BlurOverlay extends StatelessWidget {
  const _BlurOverlay({
    required this.isAndroid,
    required this.showUnlockAction,
    this.onUnlockPressed,
  });

  final bool isAndroid;
  final bool showUnlockAction;
  final VoidCallback? onUnlockPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overlayColor = theme.colorScheme.surface.withValues(alpha: 0.75);

    return DecoratedBox(
      decoration: BoxDecoration(color: overlayColor),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text('EveryDiary 보호 중', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  isAndroid
                      ? '앱이 백그라운드에 있을 때 화면을 안전하게 숨깁니다.'
                      : 'iOS에서는 시스템 제한으로 화면 캡처 차단이 제한적입니다.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (showUnlockAction && onUnlockPressed != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onUnlockPressed,
                  icon: const Icon(Icons.vpn_key),
                  label: const Text('잠금 해제 화면으로 이동'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
