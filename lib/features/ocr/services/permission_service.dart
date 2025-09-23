import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// OCR 권한 관리 서비스
/// 카메라 및 갤러리 접근 권한을 관리합니다.
class OCRPermissionService {
  static final OCRPermissionService _instance =
      OCRPermissionService._internal();
  factory OCRPermissionService() => _instance;
  OCRPermissionService._internal();

  /// 카메라 권한 확인
  Future<PermissionStatus> checkCameraPermission() async {
    return await Permission.camera.status;
  }

  /// 갤러리(사진) 권한 확인
  Future<PermissionStatus> checkGalleryPermission() async {
    return await Permission.photos.status;
  }

  /// 카메라 권한 요청
  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  /// 갤러리 권한 요청
  Future<PermissionStatus> requestGalleryPermission() async {
    return await Permission.photos.request();
  }

  /// 모든 OCR 관련 권한 확인
  Future<Map<Permission, PermissionStatus>> checkAllPermissions() async {
    final permissions = [Permission.camera, Permission.photos];
    return await permissions.request();
  }

  /// 모든 OCR 관련 권한 요청
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    final permissions = [Permission.camera, Permission.photos];
    return await permissions.request();
  }

  /// 권한이 허용되었는지 확인
  bool isPermissionGranted(PermissionStatus status) {
    return status.isGranted;
  }

  /// 권한이 거부되었는지 확인
  bool isPermissionDenied(PermissionStatus status) {
    return status.isDenied;
  }

  /// 권한이 영구적으로 거부되었는지 확인
  bool isPermissionPermanentlyDenied(PermissionStatus status) {
    return status.isPermanentlyDenied;
  }

  /// 권한 설정 화면으로 이동
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// 권한 상태에 따른 메시지 반환
  String getPermissionMessage(Permission permission, PermissionStatus status) {
    switch (permission) {
      case Permission.camera:
        return _getCameraPermissionMessage(status);
      case Permission.photos:
        return _getGalleryPermissionMessage(status);
      default:
        return '알 수 없는 권한 상태입니다.';
    }
  }

  /// 카메라 권한 메시지
  String _getCameraPermissionMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '카메라 접근 권한이 허용되었습니다.';
      case PermissionStatus.denied:
        return '카메라 접근 권한이 필요합니다.';
      case PermissionStatus.permanentlyDenied:
        return '카메라 접근 권한이 영구적으로 거부되었습니다.\n설정에서 권한을 허용해주세요.';
      case PermissionStatus.restricted:
        return '카메라 접근이 제한되었습니다.';
      case PermissionStatus.limited:
        return '카메라 접근이 제한적으로 허용되었습니다.';
      case PermissionStatus.provisional:
        return '카메라 접근이 임시적으로 허용되었습니다.';
    }
  }

  /// 갤러리 권한 메시지
  String _getGalleryPermissionMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '갤러리 접근 권한이 허용되었습니다.';
      case PermissionStatus.denied:
        return '갤러리 접근 권한이 필요합니다.';
      case PermissionStatus.permanentlyDenied:
        return '갤러리 접근 권한이 영구적으로 거부되었습니다.\n설정에서 권한을 허용해주세요.';
      case PermissionStatus.restricted:
        return '갤러리 접근이 제한되었습니다.';
      case PermissionStatus.limited:
        return '갤러리 접근이 제한적으로 허용되었습니다.';
      case PermissionStatus.provisional:
        return '갤러리 접근이 임시적으로 허용되었습니다.';
    }
  }

  /// 권한 요청 다이얼로그 표시
  Future<bool> showPermissionDialog(
    BuildContext context, {
    required Permission permission,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText ?? '취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmText ?? '확인'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// 권한 설정 안내 다이얼로그 표시
  Future<void> showPermissionSettingsDialog(
    BuildContext context, {
    required Permission permission,
  }) async {
    final message = getPermissionMessage(
      permission,
      PermissionStatus.permanentlyDenied,
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('권한 설정 필요'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  /// 권한 상태 요약 정보
  Future<PermissionSummary> getPermissionSummary() async {
    final cameraStatus = await checkCameraPermission();
    final galleryStatus = await checkGalleryPermission();

    return PermissionSummary(
      cameraPermission: cameraStatus,
      galleryPermission: galleryStatus,
      allGranted:
          isPermissionGranted(cameraStatus) &&
          isPermissionGranted(galleryStatus),
      hasDeniedPermissions:
          isPermissionDenied(cameraStatus) || isPermissionDenied(galleryStatus),
      hasPermanentlyDeniedPermissions:
          isPermissionPermanentlyDenied(cameraStatus) ||
          isPermissionPermanentlyDenied(galleryStatus),
    );
  }
}

/// 권한 상태 요약 정보
class PermissionSummary {
  final PermissionStatus cameraPermission;
  final PermissionStatus galleryPermission;
  final bool allGranted;
  final bool hasDeniedPermissions;
  final bool hasPermanentlyDeniedPermissions;

  const PermissionSummary({
    required this.cameraPermission,
    required this.galleryPermission,
    required this.allGranted,
    required this.hasDeniedPermissions,
    required this.hasPermanentlyDeniedPermissions,
  });

  @override
  String toString() {
    return 'PermissionSummary(camera: $cameraPermission, gallery: $galleryPermission, allGranted: $allGranted)';
  }
}

