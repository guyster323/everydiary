import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

/// 인증 관련 유틸리티 클래스
class AuthUtils {
  /// 로그인 화면으로 이동
  static Future<void> navigateToLogin(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => const LoginScreen()));
  }

  /// 회원가입 화면으로 이동
  static Future<void> navigateToRegister(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const RegisterScreen()),
    );
  }

  /// 로그아웃 확인 다이얼로그 표시
  static Future<bool?> showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }

  /// 로그아웃 처리
  static Future<void> handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showLogoutDialog(context);

    if (shouldLogout == true) {
      await ref.read(authStateProvider.notifier).logout();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그아웃되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// 인증이 필요한 작업에 대한 안내 다이얼로그
  static Future<void> showAuthRequiredDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그인이 필요합니다'),
        content: const Text('이 기능을 사용하려면 로그인이 필요합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              navigateToLogin(context);
            },
            child: const Text('로그인'),
          ),
        ],
      ),
    );
  }

  /// 프리미엄 기능 안내 다이얼로그
  static Future<void> showPremiumRequiredDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프리미엄 기능'),
        content: const Text('이 기능은 프리미엄 사용자만 이용할 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 프리미엄 구독 화면으로 이동 (향후 구현)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('프리미엄 구독 화면으로 이동합니다')),
              );
            },
            child: const Text('프리미엄 구독'),
          ),
        ],
      ),
    );
  }
}

/// 로그아웃 버튼 위젯
class LogoutButton extends ConsumerWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onLogout;

  const LogoutButton({super.key, this.text, this.icon, this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        if (onLogout != null) {
          onLogout!();
        } else {
          await AuthUtils.handleLogout(context, ref);
        }
      },
      icon: icon != null ? Icon(icon) : const Icon(Icons.logout),
      tooltip: text ?? '로그아웃',
    );
  }
}

/// 사용자 프로필 위젯
class UserProfileWidget extends ConsumerWidget {
  final bool showEmail;
  final bool showRoles;
  final VoidCallback? onTap;

  const UserProfileWidget({
    super.key,
    this.showEmail = true,
    this.showRoles = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated || user == null) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showEmail && user.email != null) ...[
                    Text(
                      user.email!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (showRoles && user.roles.isNotEmpty) ...[
                    Wrap(
                      spacing: 4,
                      children: user.roles
                          .map(
                            (role) => Chip(
                              label: Text(
                                role,
                                style: const TextStyle(fontSize: 10),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            // Lite 버전에서는 Premium 배지 표시 안함
          ],
        ),
      ),
    );
  }
}

/// 인증 상태 표시 위젯
class AuthStatusWidget extends ConsumerWidget {
  final bool showLoading;
  final bool showError;

  const AuthStatusWidget({
    super.key,
    this.showLoading = true,
    this.showError = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (authState.isLoading && showLoading) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('인증 중...'),
        ],
      );
    }

    if (authState.error != null && showError) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              authState.error!,
              style: TextStyle(color: Colors.red[700], fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    if (authState.isAuthenticated) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green[700], size: 16),
          const SizedBox(width: 8),
          const Text('인증됨'),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cancel, color: Colors.red[700], size: 16),
        const SizedBox(width: 8),
        const Text('인증 필요'),
      ],
    );
  }
}
