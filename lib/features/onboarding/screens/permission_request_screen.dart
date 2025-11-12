import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/localization_provider.dart';
import '../../../core/services/permission_service.dart';

/// 권한 요청 화면
/// 앱 최초 실행 시 카메라와 마이크 권한을 요청합니다
class PermissionRequestScreen extends ConsumerStatefulWidget {
  const PermissionRequestScreen({super.key});

  @override
  ConsumerState<PermissionRequestScreen> createState() => _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends ConsumerState<PermissionRequestScreen> {
  final _permissionService = PermissionService.instance;
  PermissionStatus _cameraStatus = PermissionStatus.denied;
  PermissionStatus _microphoneStatus = PermissionStatus.denied;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await _permissionService.checkCameraPermission();
    final micStatus = await _permissionService.checkMicrophonePermission();
    if (mounted) {
      setState(() {
        _cameraStatus = cameraStatus;
        _microphoneStatus = micStatus;
      });
    }
  }

  Future<void> _requestAllPermissions() async {
    if (_isRequesting) return;

    setState(() {
      _isRequesting = true;
    });

    try {
      // 카메라 권한 요청
      final cameraStatus = await _permissionService.requestCameraPermission();

      // 마이크 권한 요청
      final micStatus = await _permissionService.requestMicrophonePermission();

      if (mounted) {
        setState(() {
          _cameraStatus = cameraStatus;
          _microphoneStatus = micStatus;
          _isRequesting = false;
        });

        // 모든 권한이 허용되면 다음 화면으로 이동
        if (cameraStatus.isGranted && micStatus.isGranted) {
          _navigateToNextScreen();
        } else if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
          _showSettingsDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await _permissionService.requestCameraPermission();
    if (mounted) {
      setState(() {
        _cameraStatus = status;
      });
      if (status.isPermanentlyDenied) {
        _showSettingsDialog();
      }
    }
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await _permissionService.requestMicrophonePermission();
    if (mounted) {
      setState(() {
        _microphoneStatus = status;
      });
      if (status.isPermanentlyDenied) {
        _showSettingsDialog();
      }
    }
  }

  void _showSettingsDialog() {
    final l10n = ref.read(localizationProvider);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('permission_required_features')),
        content: Text(l10n.get('permission_settings_guide')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.get('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(l10n.get('permission_open_settings')),
          ),
        ],
      ),
    );
  }

  void _navigateToNextScreen() {
    context.go(AppConstants.homeRoute);
  }

  void _skipPermissions() {
    context.go(AppConstants.homeRoute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(localizationProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    l10n.get('permission_request_title'),
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.get('permission_request_subtitle'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 카메라 권한 카드
                  _PermissionCard(
                    icon: Icons.camera_alt,
                    title: l10n.get('permission_camera_title'),
                    description: l10n.get('permission_camera_description'),
                    status: _cameraStatus,
                    onTap: _isRequesting ? null : _requestCameraPermission,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 16),

                  // 마이크 권한 카드
                  _PermissionCard(
                    icon: Icons.mic,
                    title: l10n.get('permission_microphone_title'),
                    description: l10n.get('permission_microphone_description'),
                    status: _microphoneStatus,
                    onTap: _isRequesting ? null : _requestMicrophonePermission,
                    l10n: l10n,
                  ),

                  const Spacer(),

                  // 모두 허용 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isRequesting ? null : _requestAllPermissions,
                      child: _isRequesting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.get('permission_allow_all')),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 나중에 설정 버튼
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isRequesting ? null : _skipPermissions,
                      child: Text(l10n.get('permission_skip')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.onTap,
    required this.l10n,
  });

  final IconData icon;
  final String title;
  final String description;
  final PermissionStatus status;
  final VoidCallback? onTap;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGranted = status.isGranted;
    final isPermanentlyDenied = status.isPermanentlyDenied;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isGranted) {
      statusColor = Colors.green;
      statusText = l10n.get('permission_granted') as String;
      statusIcon = Icons.check_circle;
    } else if (isPermanentlyDenied) {
      statusColor = Colors.red;
      statusText = l10n.get('permission_denied') as String;
      statusIcon = Icons.block;
    } else {
      statusColor = Colors.orange;
      statusText = l10n.get('permission_denied') as String;
      statusIcon = Icons.warning;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: isGranted ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          statusIcon,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
