import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/auth_token.dart';
import '../../../shared/services/auto_login_service.dart';
import '../providers/auth_providers.dart';
import 'auto_login_widgets.dart';
import 'token_refresh_widgets.dart';

/// 향상된 로그인 폼 (자동 로그인 및 토큰 갱신 기능 포함)
class EnhancedLoginForm extends ConsumerStatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onRegisterPressed;

  const EnhancedLoginForm({
    super.key,
    this.onLoginSuccess,
    this.onRegisterPressed,
  });

  @override
  ConsumerState<EnhancedLoginForm> createState() => _EnhancedLoginFormState();
}

class _EnhancedLoginFormState extends ConsumerState<EnhancedLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLastLoginEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 마지막 로그인 이메일 로드
  Future<void> _loadLastLoginEmail() async {
    try {
      final autoLoginService = ref.read(autoLoginServiceProvider);
      final lastEmail = await autoLoginService.getLastLoginEmail();
      if (lastEmail != null && mounted) {
        _emailController.text = lastEmail;
      }
    } catch (e) {
      // 에러는 무시
    }
  }

  /// 로그인 처리
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final request = LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      await ref
          .read(authStateProvider.notifier)
          .login(request);

      if (mounted) {
        widget.onLoginSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 제목
              Text(
                '로그인',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 자동 로그인 상태 표시
              const AutoLoginStatusWidget(),
              if (authState.isAuthenticated) ...[
                const SizedBox(height: 16),
                const TokenRefreshStatusWidget(),
              ],
              const SizedBox(height: 16),

              // 이메일 입력
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return '올바른 이메일 형식을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 비밀번호 입력
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleLogin(),
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요';
                  }
                  if (value.length < 6) {
                    return '비밀번호는 6자 이상이어야 합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 로그인 상태 유지 체크박스
              CheckboxListTile(
                title: const Text('로그인 상태 유지'),
                subtitle: const Text('앱을 다시 열 때 자동으로 로그인됩니다'),
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              // 로그인 버튼
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('로그인'),
              ),
              const SizedBox(height: 16),

              // 회원가입 링크
              TextButton(
                onPressed: widget.onRegisterPressed,
                child: const Text('계정이 없으신가요? 회원가입'),
              ),

              // 자동 로그인 버튼 (로그인 상태 유지가 활성화된 경우)
              if (_rememberMe) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const AutoLoginButton(),
              ],

              // 토큰 갱신 버튼 (인증된 상태인 경우)
              if (authState.isAuthenticated) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TokenRefreshButton(
                        onPressed: () {
                          ref.read(authStateProvider.notifier).refreshToken();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ForceTokenRefreshButton(
                        onPressed: () {
                          ref
                              .read(authStateProvider.notifier)
                              .forceRefreshToken();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const AutoTokenRefreshToggle(),
              ],

              // 자동 로그인 설정 (인증된 상태인 경우)
              if (authState.isAuthenticated) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const RememberMeToggle(),
                const AutoLoginToggle(),
                const SizedBox(height: 16),
                const ClearAutoLoginSettingsButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 로그인 상태 표시 위젯
class LoginStatusWidget extends ConsumerWidget {
  const LoginStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (!authState.isInitialized) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('인증 상태를 확인하고 있습니다...'),
            ],
          ),
        ),
      );
    }

    if (authState.isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('처리 중...'),
            ],
          ),
        ),
      );
    }

    if (authState.error != null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  authState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              IconButton(
                onPressed: () {
                  ref.read(authStateProvider.notifier).clearError();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      );
    }

    if (authState.isAuthenticated && authState.user != null) {
      return Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '로그인됨: ${authState.user?.name ?? 'Unknown'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      authState.user?.email ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
