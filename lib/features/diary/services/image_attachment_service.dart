import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/logger.dart';

/// 이미지 첨부 서비스
class ImageAttachmentService extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  List<AttachedImage> _attachedImages = [];
  bool _isProcessing = false;

  List<AttachedImage> get attachedImages => List.unmodifiable(_attachedImages);
  bool get isProcessing => _isProcessing;
  int get imageCount => _attachedImages.length;

  /// 이미지 선택 (갤러리에서)
  Future<void> pickImageFromGallery() async {
    try {
      _setProcessing(true);

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _processAndAddImage(image);
      }
    } catch (e) {
      Logger.error('갤러리에서 이미지 선택 실패: $e');
      _setProcessing(false);
    }
  }

  /// 이미지 촬영 (카메라로)
  Future<void> pickImageFromCamera() async {
    try {
      _setProcessing(true);

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _processAndAddImage(image);
      }
    } catch (e) {
      Logger.error('카메라로 이미지 촬영 실패: $e');
      _setProcessing(false);
    }
  }

  /// 이미지 처리 및 추가
  Future<void> _processAndAddImage(XFile imageFile) async {
    try {
      // 이미지 파일을 앱 디렉토리로 복사
      final String localPath = await _copyImageToLocal(imageFile);

      // 이미지 정보 생성
      final attachedImage = AttachedImage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        originalPath: imageFile.path,
        localPath: localPath,
        fileName: path.basename(imageFile.path),
        fileSize: await File(imageFile.path).length(),
        createdAt: DateTime.now(),
      );

      _attachedImages.add(attachedImage);
      _setProcessing(false);
      notifyListeners();

      Logger.info('이미지 첨부 완료: ${attachedImage.fileName}');
    } catch (e) {
      Logger.error('이미지 처리 실패: $e');
      _setProcessing(false);
    }
  }

  /// 이미지를 앱 로컬 디렉토리로 복사
  Future<String> _copyImageToLocal(XFile imageFile) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String imagesDir = path.join(appDir.path, 'diary_images');

    // 이미지 디렉토리 생성
    await Directory(imagesDir).create(recursive: true);

    // 고유한 파일명 생성
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String extension = path.extension(imageFile.path);
    final String fileName = 'diary_$timestamp$extension';
    final String localPath = path.join(imagesDir, fileName);

    // 파일 복사
    await File(imageFile.path).copy(localPath);

    return localPath;
  }

  /// 이미지 삭제
  void removeImage(String imageId) {
    final imageIndex = _attachedImages.indexWhere((img) => img.id == imageId);
    if (imageIndex != -1) {
      final image = _attachedImages[imageIndex];

      // 로컬 파일 삭제
      try {
        File(image.localPath).deleteSync();
      } catch (e) {
        Logger.warning('로컬 이미지 파일 삭제 실패: $e');
      }

      _attachedImages.removeAt(imageIndex);
      notifyListeners();

      Logger.info('이미지 삭제 완료: ${image.fileName}');
    }
  }

  /// 모든 이미지 삭제
  void clearAllImages() {
    for (final image in _attachedImages) {
      try {
        File(image.localPath).deleteSync();
      } catch (e) {
        Logger.warning('로컬 이미지 파일 삭제 실패: $e');
      }
    }

    _attachedImages.clear();
    notifyListeners();

    Logger.info('모든 이미지 삭제 완료');
  }

  /// 이미지 순서 변경
  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final image = _attachedImages.removeAt(oldIndex);
    _attachedImages.insert(newIndex, image);
    notifyListeners();
  }

  /// 이미지 정보 업데이트 (캡션 등)
  void updateImageInfo(String imageId, {String? caption}) {
    final imageIndex = _attachedImages.indexWhere((img) => img.id == imageId);
    if (imageIndex != -1) {
      _attachedImages[imageIndex] = _attachedImages[imageIndex].copyWith(
        caption: caption,
      );
      notifyListeners();
    }
  }

  /// 이미지 데이터를 JSON으로 변환
  List<Map<String, dynamic>> toJson() {
    return _attachedImages.map((image) => image.toJson()).toList();
  }

  /// JSON에서 이미지 데이터 복원
  void fromJson(List<Map<String, dynamic>> jsonList) {
    _attachedImages = jsonList
        .map((json) => AttachedImage.fromJson(json))
        .toList();
    notifyListeners();
  }

  void _setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void addExternalImage({
    required String localPath,
    required String fileName,
    required int fileSize,
    required String mimeType,
  }) {
    final attachedImage = AttachedImage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      originalPath: localPath,
      localPath: localPath,
      fileName: fileName,
      fileSize: fileSize,
      createdAt: DateTime.now(),
    );

    _attachedImages.add(attachedImage);
    notifyListeners();

    Logger.info('외부 이미지 추가: $fileName');
  }

  @override
  void dispose() {
    // 메모리 정리
    _attachedImages.clear();
    super.dispose();
  }
}

/// 첨부된 이미지 정보
class AttachedImage {
  final String id;
  final String originalPath;
  final String localPath;
  final String fileName;
  final int fileSize;
  final DateTime createdAt;
  final String? caption;

  const AttachedImage({
    required this.id,
    required this.originalPath,
    required this.localPath,
    required this.fileName,
    required this.fileSize,
    required this.createdAt,
    this.caption,
  });

  AttachedImage copyWith({
    String? id,
    String? originalPath,
    String? localPath,
    String? fileName,
    int? fileSize,
    DateTime? createdAt,
    String? caption,
  }) {
    return AttachedImage(
      id: id ?? this.id,
      originalPath: originalPath ?? this.originalPath,
      localPath: localPath ?? this.localPath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      caption: caption ?? this.caption,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalPath': originalPath,
      'localPath': localPath,
      'fileName': fileName,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
      'caption': caption,
    };
  }

  factory AttachedImage.fromJson(Map<String, dynamic> json) {
    return AttachedImage(
      id: json['id'] as String,
      originalPath: json['originalPath'] as String,
      localPath: json['localPath'] as String,
      fileName: json['fileName'] as String,
      fileSize: json['fileSize'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      caption: json['caption'] as String?,
    );
  }

  /// 파일 크기를 읽기 쉬운 형태로 변환
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// 이미지가 존재하는지 확인
  bool get exists => File(localPath).existsSync();
}
