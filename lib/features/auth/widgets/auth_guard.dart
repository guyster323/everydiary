import 'package:everydiary/shared/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../screens/login_screen.dart';

/// 인증이 필요한 화면을 보호하는 위젯
class AuthGuard extends ConsumerWidget {
  final Widget child;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const AuthGuard({
    super.key,
    required this.child,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // 초기화 중
    if (!authState.isInitialized) {
      return loadingWidget ??
          const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 로딩 중
    if (authState.isLoading) {
      return loadingWidget ??
          const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 에러 발생
    if (authState.error != null) {
      return errorWidget ??
          Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    '인증 오류가 발생했습니다',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authState.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(authStateProvider.notifier).clearError();
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
    }

    // 인증되지 않은 경우 로그인 화면으로 이동
    if (!authState.isAuthenticated) {
      return const LoginScreen();
    }

    // 인증된 경우 자식 위젯 표시
    return child;
  }
}

/// 인증 상태에 따른 조건부 렌더링 위젯
class AuthBuilder extends ConsumerWidget {
  final Widget Function(BuildContext context, bool isAuthenticated, User? user)
  builder;
  final Widget? loadingWidget;

  const AuthBuilder({super.key, required this.builder, this.loadingWidget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // 초기화 중이거나 로딩 중
    if (!authState.isInitialized || authState.isLoading) {
      return loadingWidget ?? const Center(child: CircularProgressIndicator());
    }

    return builder(context, authState.isAuthenticated, authState.user);
  }
}

/// 인증된 사용자만 보여주는 위젯
class AuthenticatedOnly extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const AuthenticatedOnly({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (isAuthenticated) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// 인증되지 않은 사용자만 보여주는 위젯
class UnauthenticatedOnly extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const UnauthenticatedOnly({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// 관리자 권한이 있는 사용자만 보여주는 위젯
class AdminOnly extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const AdminOnly({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    if (isAdmin) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// 프리미엄 사용자만 보여주는 위젯
class PremiumOnly extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const PremiumOnly({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    if (isPremium) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// 특정 역할을 가진 사용자만 보여주는 위젯
class RoleBasedWidget extends ConsumerWidget {
  final List<String> requiredRoles;
  final Widget child;
  final Widget? fallback;

  const RoleBasedWidget({
    super.key,
    required this.requiredRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRoles = ref.watch(userRolesProvider);

    final hasRequiredRole = requiredRoles.any(
      (role) => userRoles.contains(role),
    );

    if (hasRequiredRole) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}
