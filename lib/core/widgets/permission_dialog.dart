import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/permission_service.dart';

/// 권한 요청 다이얼로그
class PermissionDialog extends StatelessWidget {
  final Permission permission;
  final VoidCallback? onGranted;
  final VoidCallback? onDenied;

  const PermissionDialog({
    super.key,
    required this.permission,
    this.onGranted,
    this.onDenied,
  });

  @override
  Widget build(BuildContext context) {
    final dialogInfo = PermissionService.instance.getPermissionDialogInfo(
      permission,
    );

    return AlertDialog(
      title: Text(dialogInfo.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dialogInfo.message),
          const SizedBox(height: 16),
          _buildPermissionIcon(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDenied?.call();
          },
          child: Text(dialogInfo.denyText),
        ),
        ElevatedButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            navigator.pop();
            final action = await PermissionService.instance
                .handleMicrophonePermission();

            if (action == PermissionAction.granted) {
              onGranted?.call();
            } else if (action == PermissionAction.permanentlyDenied) {
              // 설정 다이얼로그는 별도 처리
              onDenied?.call();
            } else {
              onDenied?.call();
            }
          },
          child: Text(dialogInfo.allowText),
        ),
      ],
    );
  }

  Widget _buildPermissionIcon() {
    switch (permission) {
      case Permission.microphone:
        return const Row(
          children: [
            Icon(Icons.mic, size: 24, color: Colors.blue),
            SizedBox(width: 8),
            Text('마이크 접근'),
          ],
        );
      case Permission.storage:
        return const Row(
          children: [
            Icon(Icons.storage, size: 24, color: Colors.green),
            SizedBox(width: 8),
            Text('저장소 접근'),
          ],
        );
      case Permission.photos:
        return const Row(
          children: [
            Icon(Icons.photo_library, size: 24, color: Colors.orange),
            SizedBox(width: 8),
            Text('사진 접근'),
          ],
        );
      default:
        return const Row(
          children: [
            Icon(Icons.security, size: 24, color: Colors.grey),
            SizedBox(width: 8),
            Text('권한 접근'),
          ],
        );
    }
  }

  /// 권한 다이얼로그 표시
  static Future<void> show({
    required BuildContext context,
    required Permission permission,
    VoidCallback? onGranted,
    VoidCallback? onDenied,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        permission: permission,
        onGranted: onGranted,
        onDenied: onDenied,
      ),
    );
  }
}

/// 권한 상태 표시 위젯
class PermissionStatusWidget extends StatelessWidget {
  final Permission permission;
  final Widget? child;
  final Widget? deniedChild;

  const PermissionStatusWidget({
    super.key,
    required this.permission,
    this.child,
    this.deniedChild,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PermissionStatus>(
      future: permission.status,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final status = snapshot.data!;

        if (status.isGranted) {
          return child ?? const SizedBox.shrink();
        } else {
          return deniedChild ?? _buildDeniedWidget(context);
        }
      },
    );
  }

  Widget _buildDeniedWidget(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.block,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('권한이 필요합니다', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              PermissionService.instance.getPermissionDescription(permission),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _requestPermission(context),
              child: const Text('권한 요청'),
            ),
          ],
        ),
      ),
    );
  }

  void _requestPermission(BuildContext context) {
    PermissionDialog.show(
      context: context,
      permission: permission,
      onGranted: () {
        // 권한이 허용되면 위젯이 자동으로 다시 빌드됩니다
      },
    );
  }
}
