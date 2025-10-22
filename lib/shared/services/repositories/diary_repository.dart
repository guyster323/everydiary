import '../../../core/utils/logger.dart';
import '../../models/attachment.dart';
import '../../models/diary_entry.dart';
import '../../models/tag.dart';
import '../database_service.dart';
import '../thumbnail_cache_service.dart';

/// 일기 리포지토리
class DiaryRepository {
  final DatabaseService _databaseService;

  DiaryRepository(this._databaseService);

  /// 일기 생성
  Future<DiaryEntry> createDiaryEntry(CreateDiaryEntryDto dto) async {
    try {
      final db = await _databaseService.database;
      final now = DateTime.now().toIso8601String();
      final id = await db.insert('diary_entries', {
        'user_id': dto.userId,
        'title': dto.title,
        'content': dto.content,
        'date': dto.date,
        'mood': dto.mood,
        'weather': dto.weather,
        'location': null,
        'latitude': null,
        'longitude': null,
        'is_private': 0,
        'is_favorite': 0,
        'word_count': 0,
        'reading_time': 0,
        'created_at': now,
        'updated_at': now,
        'is_deleted': 0,
      });

      final attachments = await _databaseService.getAttachmentsByDiaryId(id);

      final diaryEntry = DiaryEntry(
        id: id,
        userId: dto.userId,
        title: dto.title,
        content: dto.content,
        date: dto.date,
        mood: dto.mood,
        weather: dto.weather,
        location: null,
        latitude: null,
        longitude: null,
        isPrivate: false,
        isFavorite: false,
        wordCount: 0,
        readingTime: 0,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
        attachments: attachments
            .map((map) => Attachment.fromJson(_convertAttachmentMap(map)))
            .toList(),
        tags: [],
      );
      return diaryEntry;
    } catch (e) {
      Logger.error(
        'DiaryRepository.createDiaryEntry 실패',
        tag: 'DiaryRepository',
        error: e,
      );
      rethrow;
    }
  }

  /// 일기 조회 (ID로)
  Future<DiaryEntry?> getDiaryEntryById(int id) async {
    final db = await _databaseService.database;
    final maps = await db.query(
      'diary_entries',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final diary = DiaryEntry.fromJson(_convertDbMapToJson(maps.first));
      final attachments = await _databaseService.getAttachmentsByDiaryId(
        diary.id!,
      );
      final enrichedAttachments = await _buildAttachmentModels(
        attachments,
        diary,
      );
      return diary.copyWith(attachments: enrichedAttachments);
    }
    return null;
  }

  /// 사용자의 일기 목록 조회
  Future<List<DiaryEntry>> getDiaryEntriesByUserId(
    int userId, {
    int? limit,
    int? offset,
  }) async {
    final db = await _databaseService.database;

    String query = '''
      SELECT * FROM diary_entries
      WHERE user_id = ? AND is_deleted = 0
      ORDER BY created_at DESC
    ''';

    final List<dynamic> whereArgs = [userId];

    if (limit != null) {
      query += ' LIMIT ?';
      whereArgs.add(limit);

      if (offset != null) {
        query += ' OFFSET ?';
        whereArgs.add(offset);
      }
    }

    final maps = await db.rawQuery(query, whereArgs);
    final diaries = maps
        .map((map) => DiaryEntry.fromJson(_convertDbMapToJson(map)))
        .toList();

    for (var i = 0; i < diaries.length; i++) {
      final attachments = await _databaseService.getAttachmentsByDiaryId(
        diaries[i].id!,
      );
      final enrichedAttachments = await _buildAttachmentModels(
        attachments,
        diaries[i],
      );
      diaries[i] = diaries[i].copyWith(attachments: enrichedAttachments);
    }

    return diaries;
  }

  /// 필터링된 일기 목록 조회
  Future<List<DiaryEntry>> getDiaryEntriesWithFilter(
    DiaryEntryFilter filter,
  ) async {
    final db = await _databaseService.database;

    String whereClause = 'is_deleted = 0';
    final List<dynamic> whereArgs = [];

    if (filter.userId != null) {
      whereClause += ' AND user_id = ?';
      whereArgs.add(filter.userId);
    }

    if (filter.mood != null) {
      whereClause += ' AND mood = ?';
      whereArgs.add(filter.mood);
    }

    if (filter.weather != null) {
      whereClause += ' AND weather = ?';
      whereArgs.add(filter.weather);
    }

    if (filter.startDate != null) {
      whereClause += ' AND date >= ?';
      whereArgs.add(filter.startDate);
    }

    if (filter.endDate != null) {
      whereClause += ' AND date <= ?';
      whereArgs.add(filter.endDate);
    }

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      whereClause += ' AND (title LIKE ? OR content LIKE ?)';
      final searchPattern = '%${filter.searchQuery}%';
      whereArgs.addAll([searchPattern, searchPattern]);
    }

    String query =
        'SELECT * FROM diary_entries WHERE $whereClause ORDER BY created_at DESC';

    if (filter.limit != null) {
      query += ' LIMIT ?';
      whereArgs.add(filter.limit);

      if (filter.offset != null) {
        query += ' OFFSET ?';
        whereArgs.add(filter.offset);
      }
    }

    final maps = await db.rawQuery(query, whereArgs);
    final diaries = maps
        .map((map) => DiaryEntry.fromJson(_convertDbMapToJson(map)))
        .toList();

    for (var i = 0; i < diaries.length; i++) {
      final attachments = await _databaseService.getAttachmentsByDiaryId(
        diaries[i].id!,
      );
      final enrichedAttachments = await _buildAttachmentModels(
        attachments,
        diaries[i],
      );
      diaries[i] = diaries[i].copyWith(attachments: enrichedAttachments);
    }

    return diaries;
  }

  /// 특정 날짜의 일기 조회
  Future<DiaryEntry?> getDiaryEntryByDate(int userId, DateTime date) async {
    final db = await _databaseService.database;
    final startOfDay = DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
    ).toIso8601String();

    final maps = await db.query(
      'diary_entries',
      where:
          'user_id = ? AND created_at >= ? AND created_at <= ? AND is_deleted = 0',
      whereArgs: [userId, startOfDay, endOfDay],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return DiaryEntry.fromJson(_convertDbMapToJson(maps.first));
    }
    return null;
  }

  /// 일기 업데이트
  Future<DiaryEntry?> updateDiaryEntry(int id, UpdateDiaryEntryDto dto) async {
    final db = await _databaseService.database;
    final now = DateTime.now().toIso8601String();

    final updateData = <String, dynamic>{'updated_at': now};

    if (dto.title != null) updateData['title'] = dto.title;
    if (dto.content != null) updateData['content'] = dto.content;
    if (dto.date != null) updateData['date'] = dto.date;
    if (dto.mood != null) updateData['mood'] = dto.mood;
    if (dto.weather != null) updateData['weather'] = dto.weather;

    final rowsAffected = await db.update(
      'diary_entries',
      updateData,
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    if (rowsAffected > 0) {
      return await getDiaryEntryById(id);
    }
    return null;
  }

  /// 일기 삭제 (소프트 삭제)
  Future<bool> deleteDiaryEntry(int id) async {
    final db = await _databaseService.database;
    final now = DateTime.now().toIso8601String();

    final rowsAffected = await db.update(
      'diary_entries',
      {'is_deleted': 1, 'updated_at': now},
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    return rowsAffected > 0;
  }

  /// 일기 완전 삭제
  Future<bool> permanentlyDeleteDiaryEntry(int id) async {
    final db = await _databaseService.database;

    final rowsAffected = await db.delete(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );

    return rowsAffected > 0;
  }

  /// 사용자의 일기 수 조회
  Future<int> getDiaryEntryCountByUserId(int userId) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM diary_entries WHERE user_id = ? AND is_deleted = 0',
      [userId],
    );

    return result.first['count'] as int;
  }

  /// 일기 존재 여부 확인
  Future<bool> diaryEntryExists(int id) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM diary_entries WHERE id = ? AND is_deleted = 0',
      [id],
    );

    return result.first['count'] as int > 0;
  }

  /// 최근 일기 조회
  Future<List<DiaryEntry>> getRecentDiaryEntries(int userId, int limit) async {
    return await getDiaryEntriesByUserId(userId, limit: limit);
  }

  /// 월별 일기 조회
  Future<List<DiaryEntry>> getDiaryEntriesByMonth(
    int userId,
    int year,
    int month,
  ) async {
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();

    final filter = DiaryEntryFilter(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    return await getDiaryEntriesWithFilter(filter);
  }

  Future<List<Attachment>> _buildAttachmentModels(
    List<Map<String, dynamic>> attachmentRecords,
    DiaryEntry diary,
  ) async {
    if (attachmentRecords.isEmpty) {
      return const [];
    }

    final cacheService = ThumbnailCacheService();
    await cacheService.initialize();

    final List<Attachment> result = [];
    for (final record in attachmentRecords) {
      final attachment = Attachment.fromJson(_convertAttachmentMap(record));

      if (attachment.fileType != FileType.image.value) {
        result.add(attachment);
        continue;
      }

      final resolvedPath = await cacheService.resolveForAttachment(
        attachment,
        diary: diary,
      );

      if (resolvedPath != null) {
        result.add(attachment.copyWith(thumbnailPath: resolvedPath));
      } else {
        result.add(attachment);
      }
    }

    return result;
  }

  /// 데이터베이스 맵을 JSON으로 변환 (snake_case -> camelCase)
  Map<String, dynamic> _convertDbMapToJson(Map<String, dynamic> dbMap) {
    return {
      'id': dbMap['id'],
      'userId': dbMap['user_id'],
      'title': dbMap['title'],
      'content': dbMap['content'],
      'date': dbMap['date'],
      'mood': dbMap['mood'],
      'weather': dbMap['weather'],
      'location': dbMap['location'],
      'latitude': dbMap['latitude'],
      'longitude': dbMap['longitude'],
      'isPrivate': dbMap['is_private'] == 1,
      'isFavorite': dbMap['is_favorite'] == 1,
      'wordCount': dbMap['word_count'],
      'readingTime': dbMap['reading_time'],
      'createdAt': dbMap['created_at'],
      'updatedAt': dbMap['updated_at'],
      'isDeleted': dbMap['is_deleted'] == 1,
      'attachments': <Attachment>[], // 첨부파일은 별도 조회 필요
      'tags': <Tag>[], // 태그는 별도 조회 필요
    };
  }

  /// 첨부파일 맵을 JSON으로 변환 (snake_case -> camelCase)
  Map<String, dynamic> _convertAttachmentMap(Map<String, dynamic> dbMap) {
    final filePath = dbMap['file_path'] as String? ?? '';
    return {
      'id': dbMap['id'],
      'diaryId': dbMap['diary_id'],
      'filePath': filePath,
      'fileName': _safeFileName(filePath),
      'fileType': dbMap['file_type'],
      'fileSize': dbMap['file_size'],
      'mimeType': dbMap['mime_type'],
      'thumbnailPath': dbMap['thumbnail_path'],
      'width': dbMap['width'],
      'height': dbMap['height'],
      'duration': dbMap['duration'],
      'createdAt': dbMap['created_at'],
      'updatedAt': dbMap['updated_at'],
      'isDeleted': dbMap['is_deleted'] == 1,
    };
  }

  String _safeFileName(String path) {
    if (path.trim().isEmpty) {
      return 'attachment';
    }
    final segments = path.split('/');
    final name = segments.isNotEmpty ? segments.last : path;
    return name.isEmpty ? 'attachment' : name;
  }
}
