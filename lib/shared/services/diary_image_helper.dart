import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/services/image_generation_service.dart';
import '../models/attachment.dart';
import '../models/diary_entry.dart';
import 'database_service.dart';
import 'safe_delta_converter.dart';

/// 일기와 연결된 AI 이미지 경로를 보장하는 헬퍼
class DiaryImageHelper {
  DiaryImageHelper({
    DatabaseService? databaseService,
    ImageGenerationService? imageGenerationService,
  })  : _databaseService = databaseService ?? DatabaseService(),
        _imageService = imageGenerationService ?? ImageGenerationService();

  final DatabaseService _databaseService;
  final ImageGenerationService _imageService;

  /// 일기에 연결된 이미지 첨부를 확보하고 반환합니다.
  Future<Attachment?> ensureAttachment(DiaryEntry diary) async {
    await _imageService.initialize();

    final Attachment? existingAttachment = _findExistingAttachment(diary);
    if (existingAttachment != null) {
      return existingAttachment;
    }

    final String plainText = SafeDeltaConverter.extractTextFromDelta(
      diary.content,
    ).trim();

    if (plainText.isEmpty) {
      return null;
    }

    String? imagePath = await _resolveCachedImagePath(plainText);

    final bool shouldAttemptGeneration =
        imagePath == null || !(await _pathExists(imagePath));

    if (shouldAttemptGeneration && await _imageService.canGenerateTodayAsync) {
      final generated = await _imageService.generateImageFromText(plainText);
      imagePath = generated?.localImagePath;
    }

    if (imagePath == null || !(await _pathExists(imagePath))) {
      return null;
    }

    final attachment = Attachment(
      id: null,
      diaryId: diary.id ?? 0,
      filePath: imagePath,
      fileName: p.basename(imagePath),
      fileType: FileType.image.value,
      fileSize: await _getFileSize(imagePath),
      mimeType: 'image/png',
      thumbnailPath: null,
      width: null,
      height: null,
      duration: null,
      createdAt: diary.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
      isDeleted: false,
    );

    if (diary.id != null) {
      await _upsertAttachmentRecord(diary.id!, attachment);
    }

    return attachment;
  }

  /// 일기에 연결된 이미지 경로만 반환합니다.
  Future<String?> ensureImagePath(DiaryEntry diary) async {
    final attachment = await ensureAttachment(diary);
    return attachment?.filePath;
  }

  Attachment? _findExistingAttachment(DiaryEntry diary) {
    for (final attachment in diary.attachments) {
      final path = attachment.thumbnailPath?.isNotEmpty == true
          ? attachment.thumbnailPath!
          : attachment.filePath;

      if (path.isEmpty) {
        continue;
      }

      if (File(path).existsSync()) {
        return attachment;
      }
    }

    return null;
  }

  Future<String?> _resolveCachedImagePath(String plainText) async {
    final cached = _imageService.getCachedResult(plainText);
    final path = cached?.localImagePath;
    if (path == null) {
      return null;
    }
    return path;
  }

  Future<bool> _pathExists(String path) async {
    return File(path).exists();
  }

  Future<int?> _getFileSize(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        return null;
      }
      return await file.length();
    } catch (_) {
      return null;
    }
  }

  Future<void> _upsertAttachmentRecord(int diaryId, Attachment attachment) async {
    final db = await _databaseService.database;
    final existing = await db.query(
      'attachments',
      where: 'diary_id = ? AND file_path = ?',
      whereArgs: [diaryId, attachment.filePath],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return;
    }

    final now = DateTime.now().toIso8601String();

    await db.insert('attachments', {
      'diary_id': diaryId,
      'file_path': attachment.filePath,
      'file_name': attachment.fileName,
      'file_type': attachment.fileType,
      'file_size': attachment.fileSize,
      'mime_type': attachment.mimeType,
      'thumbnail_path': attachment.thumbnailPath,
      'width': attachment.width,
      'height': attachment.height,
      'created_at': now,
      'updated_at': now,
      'is_deleted': 0,
    });
  }
}

