import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// 이미지 선택 서비스
/// 갤러리에서 이미지를 선택하고 권한을 관리하는 기능을 제공합니다.
class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  final ImagePicker _picker = ImagePicker();

  /// 갤러리에서 이미지 선택
  Future<ImagePickerResult?> pickImageFromGallery({
    ImageQuality quality = ImageQuality.medium,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      // 권한 확인
      final hasPermission = await _checkGalleryPermission();
      if (!hasPermission) {
        return ImagePickerResult.error('갤러리 접근 권한이 필요합니다.');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: quality == ImageQuality.high ? 100 :
                     quality == ImageQuality.medium ? 80 : 60,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
      );

      if (image == null) {
        return ImagePickerResult.cancelled();
      }

      // 이미지 파일 정보 가져오기
      final file = File(image.path);
      final bytes = await file.readAsBytes();
      final size = await file.length();

      return ImagePickerResult.success(
        file: file,
        bytes: bytes,
        path: image.path,
        name: image.name,
        size: size,
      );
    } catch (e) {
      debugPrint('Image picker error: $e');
      return ImagePickerResult.error('이미지 선택 중 오류가 발생했습니다: $e');
    }
  }

  /// 카메라로 이미지 촬영
  Future<ImagePickerResult?> pickImageFromCamera({
    ImageQuality quality = ImageQuality.medium,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      // 권한 확인
      final hasPermission = await _checkCameraPermission();
      if (!hasPermission) {
        return ImagePickerResult.error('카메라 접근 권한이 필요합니다.');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: quality == ImageQuality.high ? 100 :
                     quality == ImageQuality.medium ? 80 : 60,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
      );

      if (image == null) {
        return ImagePickerResult.cancelled();
      }

      // 이미지 파일 정보 가져오기
      final file = File(image.path);
      final bytes = await file.readAsBytes();
      final size = await file.length();

      return ImagePickerResult.success(
        file: file,
        bytes: bytes,
        path: image.path,
        name: image.name,
        size: size,
      );
    } catch (e) {
      debugPrint('Camera picker error: $e');
      return ImagePickerResult.error('카메라 촬영 중 오류가 발생했습니다: $e');
    }
  }

  /// 다중 이미지 선택
  Future<List<ImagePickerResult>> pickMultipleImages({
    ImageQuality quality = ImageQuality.medium,
    int? maxWidth,
    int? maxHeight,
    int limit = 10,
  }) async {
    try {
      // 권한 확인
      final hasPermission = await _checkGalleryPermission();
      if (!hasPermission) {
        return [ImagePickerResult.error('갤러리 접근 권한이 필요합니다.')];
      }

      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: quality == ImageQuality.high ? 100 :
                     quality == ImageQuality.medium ? 80 : 60,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
      );

      if (images.isEmpty) {
        return [ImagePickerResult.cancelled()];
      }

      // 제한된 수만큼만 처리
      final limitedImages = images.take(limit).toList();
      final results = <ImagePickerResult>[];

      for (final image in limitedImages) {
        try {
          final file = File(image.path);
          final bytes = await file.readAsBytes();
          final size = await file.length();

          results.add(ImagePickerResult.success(
            file: file,
            bytes: bytes,
            path: image.path,
            name: image.name,
            size: size,
          ));
        } catch (e) {
          results.add(ImagePickerResult.error('이미지 처리 중 오류: $e'));
        }
      }

      return results;
    } catch (e) {
      debugPrint('Multiple image picker error: $e');
      return [ImagePickerResult.error('다중 이미지 선택 중 오류가 발생했습니다: $e')];
    }
  }

  /// 갤러리 권한 확인
  Future<bool> _checkGalleryPermission() async {
    final status = await Permission.photos.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.photos.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      return false;
    }

    return false;
  }

  /// 카메라 권한 확인
  Future<bool> _checkCameraPermission() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      return false;
    }

    return false;
  }

  /// 권한 설정 화면으로 이동
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}

/// 이미지 품질 열거형
enum ImageQuality {
  low,
  medium,
  high,
}

/// 이미지 선택 결과 클래스
class ImagePickerResult {
  final bool isSuccess;
  final bool isCancelled;
  final bool isError;
  final String? errorMessage;
  final File? file;
  final Uint8List? bytes;
  final String? path;
  final String? name;
  final int? size;

  const ImagePickerResult._({
    required this.isSuccess,
    required this.isCancelled,
    required this.isError,
    this.errorMessage,
    this.file,
    this.bytes,
    this.path,
    this.name,
    this.size,
  });

  /// 성공 결과 생성
  factory ImagePickerResult.success({
    required File file,
    required Uint8List bytes,
    required String path,
    required String name,
    required int size,
  }) {
    return ImagePickerResult._(
      isSuccess: true,
      isCancelled: false,
      isError: false,
      file: file,
      bytes: bytes,
      path: path,
      name: name,
      size: size,
    );
  }

  /// 취소 결과 생성
  factory ImagePickerResult.cancelled() {
    return const ImagePickerResult._(
      isSuccess: false,
      isCancelled: true,
      isError: false,
    );
  }

  /// 에러 결과 생성
  factory ImagePickerResult.error(String message) {
    return ImagePickerResult._(
      isSuccess: false,
      isCancelled: false,
      isError: true,
      errorMessage: message,
    );
  }

  /// 파일 크기를 사람이 읽기 쉬운 형태로 변환
  String get formattedSize {
    if (size == null) return '알 수 없음';

    const units = ['B', 'KB', 'MB', 'GB'];
    int unitIndex = 0;
    double fileSize = size!.toDouble();

    while (fileSize >= 1024 && unitIndex < units.length - 1) {
      fileSize /= 1024;
      unitIndex++;
    }

    return '${fileSize.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ImagePickerResult.success(path: $path, size: $formattedSize)';
    } else if (isCancelled) {
      return 'ImagePickerResult.cancelled()';
    } else {
      return 'ImagePickerResult.error($errorMessage)';
    }
  }
}

