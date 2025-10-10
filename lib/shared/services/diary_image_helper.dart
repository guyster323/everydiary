import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path/path.dart' as p;

import '../../core/services/image_generation_service.dart';
import '../models/attachment.dart';
import '../models/diary_entry.dart';
import 'database_service.dart';
import 'safe_delta_converter.dart';
import 'thumbnail_cache_service.dart';

/// 일기와 연결된 AI 이미지 경로를 보장하는 헬퍼
class DiaryImageHelper {
  DiaryImageHelper({
    DatabaseService? databaseService,
    ImageGenerationService? imageGenerationService,
    ThumbnailCacheService? thumbnailCacheService,
    Connectivity? connectivity,
  }) : _databaseService = databaseService ?? DatabaseService(),
       _imageService = imageGenerationService ?? ImageGenerationService(),
       _thumbnailCacheService =
           thumbnailCacheService ?? ThumbnailCacheService(),
       _connectivity = connectivity ?? Connectivity();

  final DatabaseService _databaseService;
  final ImageGenerationService _imageService;
  final ThumbnailCacheService _thumbnailCacheService;
  final Connectivity _connectivity;

  /// 일기에 연결된 이미지 첨부를 확보하고 반환합니다.
  Future<Attachment?> ensureAttachment(
    DiaryEntry diary, {
    bool forceRegenerate = false,
  }) async {
    await _imageService.initialize();
    await _thumbnailCacheService.initialize();

    final Attachment? existingAttachment = _findExistingAttachment(diary);

    if (existingAttachment != null && !forceRegenerate) {
      final resolved = await _thumbnailCacheService.resolveForAttachment(
        existingAttachment,
        diary: diary,
      );
      if (resolved != null) {
        return existingAttachment.copyWith(thumbnailPath: resolved);
      }
      return existingAttachment;
    }

    final String plainText = SafeDeltaConverter.extractTextFromDelta(
      diary.content,
    ).trim();

    if (plainText.isEmpty) {
      return _buildPlaceholderAttachment(diary);
    }

    final hints = _buildImageHints(diary);

    String? imagePath = await _resolveCachedImagePath(plainText, hints);

    final cacheKey = _buildCacheKey(diary);

    final bool shouldAttemptGeneration =
        imagePath == null || !(await _pathExists(imagePath));

    if (shouldAttemptGeneration && await _imageService.canGenerateTodayAsync) {
      if (await _isNetworkAvailable()) {
        final generated = await _imageService.generateImageFromText(
          plainText,
          hints: hints,
        );
        imagePath = generated?.localImagePath;
      }
    }

    if (imagePath == null || !(await _pathExists(imagePath))) {
      return _buildPlaceholderAttachment(diary, cacheKey: cacheKey);
    }

    final String resolvedImagePath = imagePath;

    if (forceRegenerate && existingAttachment != null) {
      await _thumbnailCacheService.invalidate(cacheKey);
      if (existingAttachment.id != null) {
        await _thumbnailCacheService.invalidate(
          'attachment_${existingAttachment.id}',
        );
      }
      if (existingAttachment.filePath != resolvedImagePath) {
        await _deleteFileIfExists(existingAttachment.filePath);
      }
      if (existingAttachment.thumbnailPath != null &&
          existingAttachment.thumbnailPath != resolvedImagePath) {
        await _deleteFileIfExists(existingAttachment.thumbnailPath!);
      }
    }

    final thumbnailPath = await _thumbnailCacheService.ensureThumbnail(
      cacheKey: cacheKey,
      sourcePath: resolvedImagePath,
      diary: diary,
    );

    final attachment = Attachment(
      id: existingAttachment?.id,
      diaryId: diary.id ?? 0,
      filePath: resolvedImagePath,
      fileName: p.basename(resolvedImagePath),
      fileType: FileType.image.value,
      fileSize: await _getFileSize(resolvedImagePath),
      mimeType: 'image/png',
      thumbnailPath: thumbnailPath ?? resolvedImagePath,
      width: null,
      height: null,
      duration: null,
      createdAt: diary.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
      isDeleted: false,
    );

    if (diary.id != null) {
      if (forceRegenerate && existingAttachment != null) {
        await _updateAttachmentRecord(existingAttachment, attachment);
      } else {
        await _upsertAttachmentRecord(
          diary.id!,
          attachment,
          replaceExisting: forceRegenerate,
        );
      }
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

  Future<String?> _resolveCachedImagePath(
    String plainText,
    ImageGenerationHints hints,
  ) async {
    final cached = _imageService.getCachedResult(plainText, hints: hints);
    final path = cached?.localImagePath;
    if (path == null) {
      return null;
    }
    return await _pathExists(path) ? path : null;
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

  Future<void> _upsertAttachmentRecord(
    int diaryId,
    Attachment attachment, {
    bool replaceExisting = false,
  }) async {
    final db = await _databaseService.database;
    if (replaceExisting) {
      await db.delete(
        'attachments',
        where: 'diary_id = ?',
        whereArgs: [diaryId],
      );
    } else {
      final existing = await db.query(
        'attachments',
        where: 'diary_id = ? AND file_path = ?',
        whereArgs: [diaryId, attachment.filePath],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        return;
      }
    }

    final now = DateTime.now().toIso8601String();

    await db.insert('attachments', {
      'diary_id': diaryId,
      'file_path': attachment.filePath,
      'file_type': attachment.fileType,
      'file_size': attachment.fileSize,
      'created_at': now,
      'updated_at': now,
      'is_deleted': 0,
    });
  }

  Future<void> _updateAttachmentRecord(
    Attachment existing,
    Attachment updated,
  ) async {
    if (existing.id == null) {
      await _upsertAttachmentRecord(
        existing.diaryId,
        updated,
        replaceExisting: true,
      );
      return;
    }

    final db = await _databaseService.database;
    final now = DateTime.now().toIso8601String();

    await db.update(
      'attachments',
      {
        'file_path': updated.filePath,
        'file_type': updated.fileType,
        'file_size': updated.fileSize,
        'updated_at': now,
        'is_deleted': 0,
      },
      where: 'id = ?',
      whereArgs: [existing.id],
    );
  }

  Future<void> _deleteFileIfExists(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // ignore file deletion errors
    }
  }

  Future<Attachment> _buildPlaceholderAttachment(
    DiaryEntry diary, {
    String? cacheKey,
  }) async {
    final resolvedKey = cacheKey ?? _buildCacheKey(diary);
    final placeholderPath = await _thumbnailCacheService.getPlaceholder(
      cacheKey: resolvedKey,
      diary: diary,
    );

    return Attachment(
      id: null,
      diaryId: diary.id ?? 0,
      filePath: placeholderPath,
      fileName: p.basename(placeholderPath),
      fileType: FileType.image.value,
      fileSize: await _getFileSize(placeholderPath),
      mimeType: 'image/png',
      thumbnailPath: placeholderPath,
      width: null,
      height: null,
      duration: null,
      createdAt: diary.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
      isDeleted: false,
    );
  }

  ImageGenerationHints _buildImageHints(DiaryEntry diary) {
    DateTime? diaryDate;
    try {
      diaryDate = DateTime.tryParse(diary.date);
    } catch (_) {
      diaryDate = null;
    }

    DateTime? creationDate;
    try {
      creationDate = DateTime.tryParse(diary.createdAt);
    } catch (_) {
      creationDate = null;
    }

    final tags = diary.tags.map((tag) => tag.name).where((name) {
      return name.trim().isNotEmpty;
    }).toList();

    return ImageGenerationHints(
      title: diary.title,
      mood: diary.mood,
      weather: diary.weather,
      location: diary.location,
      date: diaryDate ?? creationDate,
      timeOfDay: creationDate != null ? _timeOfDayLabel(creationDate) : null,
      tags: tags,
    );
  }

  String? _timeOfDayLabel(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour >= 5 && hour < 11) {
      return '아침';
    }
    if (hour >= 11 && hour < 15) {
      return '낮';
    }
    if (hour >= 15 && hour < 19) {
      return '저녁';
    }
    return '밤';
  }

  Future<bool> _isNetworkAvailable() async {
    try {
      final List<ConnectivityResult> results = await _connectivity
          .checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  String _buildCacheKey(DiaryEntry diary) {
    if (diary.id != null) {
      return 'diary_${diary.id}';
    }
    final base = '${diary.date}_${diary.title}_${diary.createdAt}';
    return 'temp_${base.hashCode.abs()}';
  }
}
