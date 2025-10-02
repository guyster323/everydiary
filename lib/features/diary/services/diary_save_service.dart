import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../core/services/image_generation_service.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/models/attachment.dart';
import '../../../shared/models/diary_entry.dart';
import '../../../shared/models/thumbnail_batch_job.dart';
import '../../../shared/services/database_service.dart';
import '../../../shared/services/repositories/diary_repository.dart';
import '../../../shared/services/thumbnail_batch_service.dart';
import 'image_attachment_service.dart';
import 'tag_service.dart';

/// 일기 저장 결과 열거형
enum DiarySaveResult {
  success,
  validationError,
  databaseError,
  fileSaveError,
  networkError,
  unknownError,
}

/// 일기 저장 서비스
/// 일기 데이터, 이미지, 태그를 통합적으로 저장하는 서비스
class DiarySaveService extends ChangeNotifier {
  final DatabaseService _databaseService;
  final DiaryRepository _diaryRepository;
  final ImageAttachmentService _imageService;
  final TagService _tagService;
  final ThumbnailBatchService _thumbnailBatchService;

  bool _isSaving = false;
  String? _lastError;
  DiarySaveResult? _lastResult;

  DiarySaveService({
    required DatabaseService databaseService,
    required DiaryRepository diaryRepository,
    required ImageAttachmentService imageService,
    required TagService tagService,
    required ThumbnailBatchService thumbnailBatchService,
  }) : _databaseService = databaseService,
       _diaryRepository = diaryRepository,
       _imageService = imageService,
       _tagService = tagService,
       _thumbnailBatchService = thumbnailBatchService;

  bool get isSaving => _isSaving;
  String? get lastError => _lastError;
  DiarySaveResult? get lastResult => _lastResult;

  /// 일기 저장 (통합 메서드)
  Future<DiarySaveResult> saveDiary({
    required int userId,
    required String title,
    required String contentDelta,
    required String contentPlainText,
    required DateTime date,
    String? mood,
    String? weather,
    String? location,
    double? latitude,
    double? longitude,
    bool isPrivate = false,
  }) async {
    Logger.info('DiarySaveService.saveDiary 시작', tag: 'DiarySaveService');
    _setSaving(true);
    _clearError();

    try {
      Logger.info('일기 저장 시작 로그', tag: 'DiarySaveService');
      Logger.info('일기 저장 시작', tag: 'DiarySaveService');

      // 1. 일기 엔트리 생성
      Logger.info('_createDiaryEntry 호출 시작', tag: 'DiarySaveService');
      final diaryEntry = await _createDiaryEntry(
        userId: userId,
        title: title,
        contentDelta: contentDelta,
        contentPlainText: contentPlainText,
        date: date,
        mood: mood,
        weather: weather,
        location: location,
        latitude: latitude,
        longitude: longitude,
        isPrivate: isPrivate,
      );
      Logger.info('_createDiaryEntry 호출 완료', tag: 'DiarySaveService');

      if (diaryEntry == null) {
        return _handleError(DiarySaveResult.databaseError, '일기 생성에 실패했습니다');
      }

      // 2-1. AI 이미지 자동 생성 (백그라운드)
      if (_imageService.imageCount > 0) {
        Logger.info('이미 첨부된 이미지가 있어 AI 자동 생성을 건너뜁니다', tag: 'DiarySaveService');
      } else {
        await _generateAndAttachAIImage(diaryEntry, contentPlainText);
      }

      // 3. 이미지 첨부파일 저장
      Logger.info('이미지 첨부파일 저장 시작', tag: 'DiarySaveService');
      final imageSaveResult = await _saveAttachments(diaryEntry.id!);
      if (imageSaveResult != DiarySaveResult.success) {
        Logger.warning('이미지 저장 실패, 일기는 저장됨', tag: 'DiarySaveService');
      }
      Logger.info('이미지 첨부파일 저장 완료', tag: 'DiarySaveService');

      // 4. 태그 연결 저장
      Logger.info('태그 연결 저장 시작', tag: 'DiarySaveService');
      final tagSaveResult = await _saveDiaryTags(diaryEntry.id!);
      if (tagSaveResult != DiarySaveResult.success) {
        Logger.warning('태그 저장 실패, 일기는 저장됨', tag: 'DiarySaveService');
      }
      Logger.info('태그 연결 저장 완료', tag: 'DiarySaveService');

      // 5. 썸네일 배치 작업 큐 등록
      try {
        await _thumbnailBatchService.enqueueForDiary(
          diaryEntry.id!,
          jobType: ThumbnailBatchJobType.initial,
        );
        debugPrint('🌀 배치 큐 등록: diaryId=${diaryEntry.id}');
        Future.microtask(() => _thumbnailBatchService.processPendingJobs());
      } catch (e) {
        Logger.warning('썸네일 배치 작업 등록 실패: $e', tag: 'DiarySaveService');
      }

      // 6. 백업 생성 (선택적) - 웹 환경에서는 건너뜀
      if (!kIsWeb) {
        Logger.info('백업 생성 시작', tag: 'DiarySaveService');
        try {
          await _createBackup(diaryEntry);
          Logger.info('백업 생성 완료', tag: 'DiarySaveService');
        } catch (e) {
          Logger.warning('백업 생성 실패, 일기는 저장됨: $e', tag: 'DiarySaveService');
          Logger.error('백업 생성 실패: $e', tag: 'DiarySaveService');
        }
      } else {
        Logger.info('웹 환경에서는 백업 생성을 건너뜁니다', tag: 'DiarySaveService');
      }

      Logger.info('일기 저장 완료 로그 시작', tag: 'DiarySaveService');
      Logger.info('일기 저장 완료: ID ${diaryEntry.id}', tag: 'DiarySaveService');
      Logger.info('_setResult 호출 시작', tag: 'DiarySaveService');
      _setResult(DiarySaveResult.success);
      Logger.info('_setResult 호출 완료', tag: 'DiarySaveService');
      Logger.info('DiarySaveResult.success 반환', tag: 'DiarySaveService');
      return DiarySaveResult.success;
    } catch (e) {
      Logger.error('일기 저장 중 오류 발생', tag: 'DiarySaveService', error: e);
      return _handleError(DiarySaveResult.unknownError, e.toString());
    } finally {
      _setSaving(false);
    }
  }

  /// 일기 엔트리 생성
  Future<DiaryEntry?> _createDiaryEntry({
    required int userId,
    required String title,
    required String contentDelta,
    required String contentPlainText,
    required DateTime date,
    String? mood,
    String? weather,
    String? location,
    double? latitude,
    double? longitude,
    bool isPrivate = false,
  }) async {
    Logger.info('_createDiaryEntry 메서드 시작', tag: 'DiarySaveService');
    try {
      Logger.info('Logger.info 호출 전', tag: 'DiarySaveService');
      Logger.info(
        '일기 엔트리 생성 시작 - userId: $userId, title: $title, content 길이: ${contentPlainText.length}',
        tag: 'DiarySaveService',
      );
      Logger.info('Logger.info 호출 완료', tag: 'DiarySaveService');

      // 단어 수 계산 (나중에 사용할 예정)
      // final wordCount = _calculateWordCount(content);

      Logger.info('DTO 생성 시작', tag: 'DiarySaveService');
      final dto = CreateDiaryEntryDto(
        userId: userId,
        title: title,
        content: contentDelta,
        date: date.toIso8601String(),
        mood: mood,
        weather: weather,
      );
      Logger.info('DTO 생성 완료', tag: 'DiarySaveService');

      Logger.info('Logger.info 호출 전 (DTO)', tag: 'DiarySaveService');
      Logger.info(
        'DTO 생성 완료 - date: ${dto.date}, mood: ${dto.mood}, weather: ${dto.weather}',
        tag: 'DiarySaveService',
      );
      Logger.info('Logger.info 호출 완료 (DTO)', tag: 'DiarySaveService');

      Logger.info(
        '_diaryRepository.createDiaryEntry 호출 시작',
        tag: 'DiarySaveService',
      );
      final diaryEntry = await _diaryRepository.createDiaryEntry(dto);
      Logger.info(
        '_diaryRepository.createDiaryEntry 호출 완료',
        tag: 'DiarySaveService',
      );

      Logger.info(
        '일기 엔트리 생성 성공 - ID: ${diaryEntry.id}',
        tag: 'DiarySaveService',
      );

      // 추가 필드 업데이트 (위치, 개인정보 등)
      if (location != null ||
          latitude != null ||
          longitude != null ||
          isPrivate) {
        // 향후 위치 정보와 개인정보 설정을 위한 업데이트 로직 구현 예정
        // 현재 DiaryEntry 모델에 location, latitude, longitude, isPrivate 필드가 없음
        // 필요시 모델 확장 또는 별도 테이블 사용 고려
        // final updateDto = UpdateDiaryEntryDto();
      }

      final enrichedEntry = diaryEntry.copyWith(
        wordCount: _calculateWordCount(contentPlainText),
        readingTime: _estimateReadingTime(contentPlainText),
      );
      return enrichedEntry;
    } catch (e) {
      Logger.error('일기 엔트리 생성 실패', tag: 'DiarySaveService', error: e);
      return null;
    }
  }

  /// 첨부파일 저장
  Future<DiarySaveResult> _saveAttachments(int diaryId) async {
    try {
      // 웹 환경에서는 첨부파일 저장을 건너뜀
      if (kIsWeb) {
        Logger.info('웹 환경에서는 첨부파일 저장을 건너뜁니다', tag: 'DiarySaveService');
        return DiarySaveResult.success;
      }

      final images = _imageService.toJson();
      if (images.isEmpty) {
        return DiarySaveResult.success;
      }

      final db = await _databaseService.database;
      final now = DateTime.now().toIso8601String();

      for (final imageData in images) {
        final attachment = CreateAttachmentDto(
          diaryId: diaryId,
          filePath: imageData['filePath'] as String,
          fileType: FileType.image.value,
          fileSize: imageData['fileSize'] as int?,
        );

        await db.insert('attachments', {
          'diary_id': attachment.diaryId,
          'file_path': attachment.filePath,
          'file_name': imageData['fileName'] as String,
          'file_type': attachment.fileType,
          'file_size': attachment.fileSize,
          'mime_type': imageData['mimeType'] as String?,
          'thumbnail_path': imageData['thumbnailPath'] as String?,
          'width': imageData['width'] as int?,
          'height': imageData['height'] as int?,
          'created_at': now,
          'updated_at': now,
          'is_deleted': 0,
        });
      }

      Logger.info('첨부파일 저장 완료: ${images.length}개', tag: 'DiarySaveService');
      return DiarySaveResult.success;
    } catch (e) {
      Logger.error('첨부파일 저장 실패', tag: 'DiarySaveService', error: e);
      return DiarySaveResult.fileSaveError;
    }
  }

  /// 일기-태그 관계 저장
  Future<DiarySaveResult> _saveDiaryTags(int diaryId) async {
    try {
      final tags = _tagService.toJson();
      if (tags.isEmpty) {
        return DiarySaveResult.success;
      }

      final db = await _databaseService.database;
      final now = DateTime.now().toIso8601String();

      for (final tagData in tags) {
        // 태그가 존재하는지 확인하고, 없으면 생성
        int tagId = tagData['id'] as int? ?? 0;

        if (tagId == 0) {
          // 새 태그 생성
          final newTagId = await db.insert('tags', {
            'user_id': tagData['userId'] as int,
            'name': tagData['name'] as String,
            'color': tagData['color'] as String? ?? '#6366F1',
            'icon': tagData['icon'] as String?,
            'description': tagData['description'] as String?,
            'usage_count': 0,
            'created_at': now,
            'updated_at': now,
            'is_deleted': 0,
          });
          tagId = newTagId;
        }

        // 일기-태그 관계 생성
        await db.insert('diary_tags', {
          'diary_id': diaryId,
          'tag_id': tagId,
          'created_at': now,
        });
      }

      Logger.info('태그 연결 저장 완료: ${tags.length}개', tag: 'DiarySaveService');
      return DiarySaveResult.success;
    } catch (e) {
      Logger.error('태그 연결 저장 실패', tag: 'DiarySaveService', error: e);
      return DiarySaveResult.databaseError;
    }
  }

  /// 백업 생성
  Future<void> _createBackup(DiaryEntry diaryEntry) async {
    try {
      // 백업 디렉토리 생성
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // 백업 파일명 생성 (날짜_시간_일기ID.json)
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupFile = File(
        '${backupDir.path}/diary_${diaryEntry.id}_$timestamp.json',
      );

      // 백업 데이터 생성
      final backupData = {
        'diary_entry': diaryEntry.toJson(),
        'attachments': await _getAttachmentsForBackup(diaryEntry.id!),
        'tags': await _getTagsForBackup(diaryEntry.id!),
        'backup_created_at': DateTime.now().toIso8601String(),
        'app_version': '1.0.1', // 향후 앱 버전을 동적으로 가져오기 예정
      };

      // 백업 파일 저장
      await backupFile.writeAsString(jsonEncode(backupData), flush: true);

      Logger.info('백업 생성 완료: ${backupFile.path}', tag: 'DiarySaveService');
    } catch (e) {
      Logger.warning('백업 생성 실패: $e', tag: 'DiarySaveService');
      // 백업 실패는 일기 저장에 영향을 주지 않음
    }
  }

  /// 백업용 첨부파일 데이터 조회
  Future<List<Map<String, dynamic>>> _getAttachmentsForBackup(
    int diaryId,
  ) async {
    try {
      final db = await _databaseService.database;
      final maps = await db.query(
        'attachments',
        where: 'diary_id = ? AND is_deleted = 0',
        whereArgs: [diaryId],
      );
      return maps;
    } catch (e) {
      Logger.warning('첨부파일 백업 데이터 조회 실패: $e', tag: 'DiarySaveService');
      return [];
    }
  }

  /// 백업용 태그 데이터 조회
  Future<List<Map<String, dynamic>>> _getTagsForBackup(int diaryId) async {
    try {
      final db = await _databaseService.database;
      final maps = await db.rawQuery(
        '''
        SELECT t.*, dt.created_at as linked_at
        FROM tags t
        INNER JOIN diary_tags dt ON t.id = dt.tag_id
        WHERE dt.diary_id = ? AND t.is_deleted = 0
      ''',
        [diaryId],
      );
      return maps;
    } catch (e) {
      Logger.warning('태그 백업 데이터 조회 실패: $e', tag: 'DiarySaveService');
      return [];
    }
  }

  /// 저장 상태 설정
  void _setSaving(bool saving) {
    _isSaving = saving;
    notifyListeners();
  }

  /// 에러 설정
  DiarySaveResult _handleError(DiarySaveResult result, String error) {
    _lastError = error;
    _lastResult = result;
    _setSaving(false);
    return result;
  }

  /// 에러 클리어
  void _clearError() {
    _lastError = null;
    _lastResult = null;
  }

  /// 결과 설정
  void _setResult(DiarySaveResult result) {
    _lastResult = result;
  }

  /// 저장 상태 리셋
  void reset() {
    _isSaving = false;
    _lastError = null;
    _lastResult = null;
    notifyListeners();
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }

  int _calculateWordCount(String content) {
    if (content.trim().isEmpty) return 0;
    return content
        .replaceAll(RegExp(r'[^ -가-힣0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  int _estimateReadingTime(String content) {
    const wordsPerMinute = 200;
    final words = _calculateWordCount(content);
    final minutes = (words / wordsPerMinute).ceil();
    return minutes.clamp(1, 60);
  }

  Future<void> _generateAndAttachAIImage(
    DiaryEntry diary,
    String plainText,
  ) async {
    try {
      if (plainText.trim().isEmpty) {
        Logger.info('일기 내용이 비어 AI 이미지 생성을 건너뜁니다', tag: 'DiarySaveService');
        return;
      }

      final imageService = ImageGenerationService();
      await imageService.initialize();

      final hints = ImageGenerationHints(
        title: diary.title,
        mood: diary.mood,
        weather: diary.weather,
        location: diary.location,
        date:
            DateTime.tryParse(diary.date) ?? DateTime.tryParse(diary.createdAt),
        timeOfDay: _timeOfDayLabel(DateTime.tryParse(diary.createdAt)),
        tags: diary.tags
            .map((tag) => tag.name.trim())
            .where((name) => name.isNotEmpty)
            .toList(),
      );

      final result = await imageService.generateImageFromText(
        plainText,
        hints: hints,
      );

      if (result == null || result.localImagePath == null) {
        Logger.info('AI 이미지 생성 실패 또는 저장 경로 없음', tag: 'DiarySaveService');
        return;
      }

      final file = File(result.localImagePath!);
      if (!await file.exists()) {
        Logger.info('AI 이미지 파일이 존재하지 않아 저장을 건너뜁니다', tag: 'DiarySaveService');
        return;
      }

      final stats = await file.stat();
      final fileName = path.basename(file.path);
      final fileSize = stats.size;

      _imageService.addExternalImage(
        localPath: file.path,
        fileName: fileName,
        fileSize: fileSize,
        mimeType: 'image/png',
      );
      final db = await _databaseService.database;
      final now = DateTime.now().toIso8601String();

      await db.insert('attachments', {
        'diary_id': diary.id!,
        'file_path': file.path,
        'file_type': FileType.image.value,
        'file_size': fileSize,
        'created_at': now,
        'updated_at': now,
        'is_deleted': 0,
      });

      Logger.info('AI 이미지 첨부 저장 완료: $fileName', tag: 'DiarySaveService');
    } catch (e) {
      Logger.warning('AI 이미지 생성/저장 중 오류: $e', tag: 'DiarySaveService');
    }
  }

  String? _timeOfDayLabel(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
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
}
