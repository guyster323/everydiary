import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/permission_service.dart';

/// 권한 관리 위젯
/// OCR 기능에 필요한 권한을 관리하고 표시합니다.
class PermissionManagerWidget extends StatefulWidget {
  final VoidCallback? onPermissionsGranted;
  final Widget? child;

  const PermissionManagerWidget({
    super.key,
    this.onPermissionsGranted,
    this.child,
  });

  @override
  State<PermissionManagerWidget> createState() =>
      _PermissionManagerWidgetState();
}

class _PermissionManagerWidgetState extends State<PermissionManagerWidget> {
  final OCRPermissionService _permissionService = OCRPermissionService();
  PermissionSummary? _permissionSummary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  /// 권한 상태 확인
  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final summary = await _permissionService.getPermissionSummary();
      setState(() {
        _permissionSummary = summary;
        _isLoading = false;
      });

      // 모든 권한이 허용된 경우 콜백 호출
      if (summary.allGranted && widget.onPermissionsGranted != null) {
        widget.onPermissionsGranted!();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 권한 요청
  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _permissionService.requestAllPermissions();

      // 결과 확인
      final cameraGranted = _permissionService.isPermissionGranted(
        results[Permission.camera]!,
      );
      final galleryGranted = _permissionService.isPermissionGranted(
        results[Permission.photos]!,
      );

      if (cameraGranted && galleryGranted) {
        // 모든 권한이 허용된 경우
        await _checkPermissions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('모든 권한이 허용되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // 일부 권한이 거부된 경우
        await _checkPermissions();
        if (mounted) {
          _showPermissionDeniedDialog();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('권한 요청 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 권한 거부 다이얼로그 표시
  void _showPermissionDeniedDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('권한이 필요합니다'),
        content: const Text(
          'OCR 기능을 사용하려면 카메라와 갤러리 접근 권한이 필요합니다.\n\n'
          '설정에서 권한을 허용해주세요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _permissionService.openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  /// 개별 권한 요청
  Future<void> _requestIndividualPermission(Permission permission) async {
    setState(() {
      _isLoading = true;
    });

    try {
      PermissionStatus status;
      if (permission == Permission.camera) {
        status = await _permissionService.requestCameraPermission();
      } else {
        status = await _permissionService.requestGalleryPermission();
      }

      if (_permissionService.isPermissionGranted(status)) {
        await _checkPermissions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${permission == Permission.camera ? '카메라' : '갤러리'} 권한이 허용되었습니다.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (_permissionService.isPermissionPermanentlyDenied(status)) {
        await _checkPermissions();
        if (mounted) {
          await _permissionService.showPermissionSettingsDialog(
            context,
            permission: permission,
          );
        }
      } else {
        await _checkPermissions();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('권한 상태를 확인하는 중...'),
          ],
        ),
      );
    }

    if (_permissionSummary == null) {
      return const Center(child: Text('권한 상태를 확인할 수 없습니다.'));
    }

    // 모든 권한이 허용된 경우
    if (_permissionSummary!.allGranted) {
      return widget.child ?? const SizedBox.shrink();
    }

    // 권한이 필요한 경우
    return _buildPermissionRequestUI();
  }

  /// 권한 요청 UI 빌드
  Widget _buildPermissionRequestUI() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.security, size: 64, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            '권한이 필요합니다',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'OCR 기능을 사용하려면 다음 권한들이 필요합니다:',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // 카메라 권한
          _buildPermissionItem(
            icon: Icons.camera_alt,
            title: '카메라 접근',
            description: '사진 촬영을 위해 필요합니다',
            isGranted: _permissionService.isPermissionGranted(
              _permissionSummary!.cameraPermission,
            ),
            onRequest: () => _requestIndividualPermission(Permission.camera),
          ),

          const SizedBox(height: 16),

          // 갤러리 권한
          _buildPermissionItem(
            icon: Icons.photo_library,
            title: '갤러리 접근',
            description: '이미지 선택을 위해 필요합니다',
            isGranted: _permissionService.isPermissionGranted(
              _permissionSummary!.galleryPermission,
            ),
            onRequest: () => _requestIndividualPermission(Permission.photos),
          ),

          const SizedBox(height: 32),

          // 모든 권한 요청 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _requestPermissions,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(_isLoading ? '권한 요청 중...' : '모든 권한 허용'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 개별 권한 항목 빌드
  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onRequest,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isGranted ? Colors.green : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isGranted ? Colors.green.withValues(alpha: 0.1) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: isGranted ? Colors.green : Colors.grey, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isGranted ? Colors.green : null,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (isGranted)
            const Icon(Icons.check_circle, color: Colors.green)
          else
            TextButton(onPressed: onRequest, child: const Text('허용')),
        ],
      ),
    );
  }
}
