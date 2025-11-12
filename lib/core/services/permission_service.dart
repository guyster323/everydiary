import 'package:permission_handler/permission_handler.dart';

/// 권한 관리 서비스
/// 앱에서 필요한 권한들을 관리합니다.
class PermissionService {
  static PermissionService? _instance;
  static PermissionService get instance => _instance ??= PermissionService._();

  PermissionService._();

  /// 카메라 권한 확인
  Future<PermissionStatus> checkCameraPermission() async {
    return await Permission.camera.status;
  }

  /// 카메라 권한 요청
  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  /// 카메라 권한이 허용되었는지 확인
  Future<bool> isCameraPermissionGranted() async {
    final status = await checkCameraPermission();
    return status.isGranted;
  }

  /// 카메라 권한이 영구적으로 거부되었는지 확인
  Future<bool> isCameraPermissionPermanentlyDenied() async {
    final status = await checkCameraPermission();
    return status.isPermanentlyDenied;
  }

  /// 마이크 권한 확인
  Future<PermissionStatus> checkMicrophonePermission() async {
    return await Permission.microphone.status;
  }

  /// 마이크 권한 요청
  Future<PermissionStatus> requestMicrophonePermission() async {
    return await Permission.microphone.request();
  }

  /// 마이크 권한이 허용되었는지 확인
  Future<bool> isMicrophonePermissionGranted() async {
    final status = await checkMicrophonePermission();
    return status.isGranted;
  }

  /// 마이크 권한이 영구적으로 거부되었는지 확인
  Future<bool> isMicrophonePermissionPermanentlyDenied() async {
    final status = await checkMicrophonePermission();
    return status.isPermanentlyDenied;
  }

  /// 앱 설정으로 이동
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// 권한 상태에 따른 적절한 액션 수행
  Future<PermissionAction> handleMicrophonePermission() async {
    final status = await checkMicrophonePermission();

    switch (status) {
      case PermissionStatus.granted:
        return PermissionAction.granted;
      case PermissionStatus.denied:
        final requestResult = await requestMicrophonePermission();
        return requestResult.isGranted
            ? PermissionAction.granted
            : PermissionAction.denied;
      case PermissionStatus.permanentlyDenied:
        return PermissionAction.permanentlyDenied;
      case PermissionStatus.restricted:
        return PermissionAction.restricted;
      case PermissionStatus.limited:
        return PermissionAction.limited;
      case PermissionStatus.provisional:
        return PermissionAction.provisional;
    }
  }

  /// 모든 필요한 권한 확인
  Future<Map<Permission, PermissionStatus>> checkAllPermissions() async {
    final permissions = [
      Permission.microphone,
      Permission.storage,
      Permission.photos,
    ];

    final statuses = <Permission, PermissionStatus>{};
    for (final permission in permissions) {
      statuses[permission] = await permission.status;
    }

    return statuses;
  }

  /// 권한 상태를 문자열로 변환
  String getPermissionStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '허용됨';
      case PermissionStatus.denied:
        return '거부됨';
      case PermissionStatus.permanentlyDenied:
        return '영구적으로 거부됨';
      case PermissionStatus.restricted:
        return '제한됨';
      case PermissionStatus.limited:
        return '제한적 허용';
      case PermissionStatus.provisional:
        return '임시 허용';
    }
  }

  /// 권한 설명 텍스트
  String getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.microphone:
        return '음성 인식 기능을 사용하기 위해 마이크 접근 권한이 필요합니다.';
      case Permission.storage:
        return '일기 데이터를 저장하기 위해 저장소 접근 권한이 필요합니다.';
      case Permission.photos:
        return '일기에 이미지를 추가하기 위해 사진 접근 권한이 필요합니다.';
      default:
        return '이 기능을 사용하기 위해 권한이 필요합니다.';
    }
  }

  /// 권한 요청 다이얼로그를 위한 정보
  PermissionDialogInfo getPermissionDialogInfo(Permission permission) {
    switch (permission) {
      case Permission.microphone:
        return const PermissionDialogInfo(
          title: '마이크 권한 필요',
          message: '음성으로 일기를 작성하기 위해 마이크 접근 권한이 필요합니다.',
          allowText: '허용',
          denyText: '거부',
        );
      case Permission.storage:
        return const PermissionDialogInfo(
          title: '저장소 권한 필요',
          message: '일기 데이터를 저장하기 위해 저장소 접근 권한이 필요합니다.',
          allowText: '허용',
          denyText: '거부',
        );
      case Permission.photos:
        return const PermissionDialogInfo(
          title: '사진 권한 필요',
          message: '일기에 이미지를 추가하기 위해 사진 접근 권한이 필요합니다.',
          allowText: '허용',
          denyText: '거부',
        );
      default:
        return const PermissionDialogInfo(
          title: '권한 필요',
          message: '이 기능을 사용하기 위해 권한이 필요합니다.',
          allowText: '허용',
          denyText: '거부',
        );
    }
  }
}

/// 권한 액션 열거형
enum PermissionAction {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
  provisional,
}

/// 권한 다이얼로그 정보 클래스
class PermissionDialogInfo {
  final String title;
  final String message;
  final String allowText;
  final String denyText;

  const PermissionDialogInfo({
    required this.title,
    required this.message,
    required this.allowText,
    required this.denyText,
  });
}
