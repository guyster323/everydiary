import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../shared/services/database_service.dart';
import '../models/diary_memory.dart';
import '../models/memory_filter.dart';

/// 회상 시스템의 핵심 서비스 (로컬 SQLite 버전)
class MemoryService {
  static final MemoryService _instance = MemoryService._internal();
  factory MemoryService() => _instance;
  MemoryService._internal();

  final DatabaseService _databaseService = DatabaseService();

  /// 회상 결과를 생성합니다
  Future<MemoryResult> generateMemories({
    required String userId,
    MemoryFilter? filter,
    MemorySettings? settings,
  }) async {
    try {
      final effectiveFilter = filter ?? const MemoryFilter();
      final effectiveSettings = settings ?? const MemorySettings();

      final allMemories = <DiaryMemory>[];

      // 각 회상 유형별로 회상 생성
      if (effectiveSettings.enableYesterdayMemories) {
        final yesterdayMemories = await _getYesterdayMemories(
          userId: userId,
          settings: effectiveSettings,
        );
        allMemories.addAll(yesterdayMemories);
      }

      if (effectiveSettings.enableOneWeekAgoMemories) {
        final oneWeekAgoMemories = await _getOneWeekAgoMemories(
          userId: userId,
          settings: effectiveSettings,
        );
        allMemories.addAll(oneWeekAgoMemories);
      }

      if (effectiveSettings.enableOneMonthAgoMemories) {
        final oneMonthAgoMemories = await _getOneMonthAgoMemories(
          userId: userId,
          settings: effectiveSettings,
        );
        allMemories.addAll(oneMonthAgoMemories);
      }

      if (effectiveSettings.enableOneYearAgoMemories) {
        final oneYearAgoMemories = await _getOneYearAgoMemories(
          userId: userId,
          settings: effectiveSettings,
        );
        allMemories.addAll(oneYearAgoMemories);
      }

      if (effectiveSettings.enablePastTodayMemories) {
        final pastTodayMemories = await _getPastTodayMemories(
          userId: userId,
          settings: effectiveSettings,
        );
        allMemories.addAll(pastTodayMemories);
      }

      if (effectiveSettings.enableSameTimeMemories) {
        final sameTimeMemories = await _getSameTimeMemories(
          userId: userId,
          settings: effectiveSettings,
        );
        allMemories.addAll(sameTimeMemories);
      }

      if (effectiveSettings.enableSeasonalMemories) {
        final seasonalMemories = await _getSeasonalMemories(
          userId: userId,
          settings: effectiveSettings,
        );
        allMemories.addAll(seasonalMemories);
      }

      if (effectiveSettings.enableSpecialDateMemories) {
        final specialDateMemories = await _getSpecialDateMemories(
          userId: userId,
          settings: effectiveSettings,
        );
        allMemories.addAll(specialDateMemories);
      }

      if (effectiveSettings.enableSimilarTagsMemories) {
        final similarTagsMemories = await _getSimilarTagsMemories(
          userId: userId,
          settings: effectiveSettings,
        );
        allMemories.addAll(similarTagsMemories);
      }

      // 필터링 및 정렬 적용
      final filteredMemories = _applyFilter(allMemories, effectiveFilter);
      final sortedMemories = _sortMemories(filteredMemories, effectiveFilter);

      return MemoryResult(
        memories: sortedMemories,
        generatedAt: DateTime.now(),
        userId: userId,
        totalCount: allMemories.length,
        filteredCount: sortedMemories.length,
        metadata: {
          'filter_applied': effectiveFilter.toJson(),
          'settings_used': effectiveSettings.toJson(),
        },
      );
    } catch (e) {
      debugPrint('Error generating memories: $e');
      rethrow;
    }
  }

  /// 어제 작성된 일기 회상
  Future<List<DiaryMemory>> _getYesterdayMemories({
    required String userId,
    required MemorySettings settings,
  }) async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final startOfYesterday = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
      );
      final endOfYesterday = startOfYesterday.add(const Duration(days: 1));

      final db = await _databaseService.database;
      final results = await db.query(
        'diary_entries',
        where: 'user_id = ? AND date >= ? AND date < ? AND is_deleted = 0',
        whereArgs: [
          int.parse(userId),
          startOfYesterday.toIso8601String(),
          endOfYesterday.toIso8601String(),
        ],
        orderBy: 'created_at DESC',
        limit: settings.maxMemoriesPerType,
      );

      return results.map((diary) {
        return DiaryMemory(
          id: 'yesterday_${diary['id']}',
          diaryId: diary['id'].toString(),
          title: (diary['title'] as String?) ?? '제목 없음',
          content: (diary['content'] as String?) ?? '',
          createdAt: DateTime.parse(diary['created_at'] as String),
          originalDate: DateTime.parse(diary['date'] as String),
          reason: MemoryReason(
            type: MemoryType.yesterday,
            description: '어제 작성한 일기입니다',
            displayText: '어제의 기록',
            metadata: {'original_date': diary['date'] as String},
          ),
          relevance: _calculateYesterdayRelevance(diary),
          tags: [],
          imageUrl: null,
          location: diary['location'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting yesterday memories: $e');
      return [];
    }
  }

  /// 일주일 전 작성된 일기 회상
  Future<List<DiaryMemory>> _getOneWeekAgoMemories({
    required String userId,
    required MemorySettings settings,
  }) async {
    try {
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      final startOfWeek = DateTime(
        oneWeekAgo.year,
        oneWeekAgo.month,
        oneWeekAgo.day,
      );
      final endOfWeek = startOfWeek.add(const Duration(days: 1));

      final db = await _databaseService.database;
      final results = await db.query(
        'diary_entries',
        where: 'user_id = ? AND date >= ? AND date < ? AND is_deleted = 0',
        whereArgs: [
          int.parse(userId),
          startOfWeek.toIso8601String(),
          endOfWeek.toIso8601String(),
        ],
        orderBy: 'created_at DESC',
        limit: settings.maxMemoriesPerType,
      );

      return results.map((diary) {
        return DiaryMemory(
          id: 'one_week_ago_${diary['id']}',
          diaryId: diary['id'].toString(),
          title: (diary['title'] as String?) ?? '제목 없음',
          content: (diary['content'] as String?) ?? '',
          createdAt: DateTime.parse(diary['created_at'] as String),
          originalDate: DateTime.parse(diary['date'] as String),
          reason: MemoryReason(
            type: MemoryType.oneWeekAgo,
            description: '일주일 전 작성한 일기입니다',
            displayText: '일주일 전의 기록',
            metadata: {'original_date': diary['date'] as String},
          ),
          relevance: _calculateOneWeekAgoRelevance(diary),
          tags: [],
          imageUrl: null,
          location: diary['location'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting one week ago memories: $e');
      return [];
    }
  }

  /// 한달 전 작성된 일기 회상
  Future<List<DiaryMemory>> _getOneMonthAgoMemories({
    required String userId,
    required MemorySettings settings,
  }) async {
    try {
      final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
      final startOfMonth = DateTime(
        oneMonthAgo.year,
        oneMonthAgo.month,
        oneMonthAgo.day,
      );
      final endOfMonth = startOfMonth.add(const Duration(days: 1));

      final db = await _databaseService.database;
      final results = await db.query(
        'diary_entries',
        where: 'user_id = ? AND date >= ? AND date < ? AND is_deleted = 0',
        whereArgs: [
          int.parse(userId),
          startOfMonth.toIso8601String(),
          endOfMonth.toIso8601String(),
        ],
        orderBy: 'created_at DESC',
        limit: settings.maxMemoriesPerType,
      );

      return results.map((diary) {
        return DiaryMemory(
          id: 'one_month_ago_${diary['id']}',
          diaryId: diary['id'].toString(),
          title: (diary['title'] as String?) ?? '제목 없음',
          content: (diary['content'] as String?) ?? '',
          createdAt: DateTime.parse(diary['created_at'] as String),
          originalDate: DateTime.parse(diary['date'] as String),
          reason: MemoryReason(
            type: MemoryType.oneMonthAgo,
            description: '한달 전 작성한 일기입니다',
            displayText: '한달 전의 기록',
            metadata: {'original_date': diary['date'] as String},
          ),
          relevance: _calculateOneMonthAgoRelevance(diary),
          tags: [],
          imageUrl: null,
          location: diary['location'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting one month ago memories: $e');
      return [];
    }
  }

  /// 1년 전 작성된 일기 회상
  Future<List<DiaryMemory>> _getOneYearAgoMemories({
    required String userId,
    required MemorySettings settings,
  }) async {
    try {
      final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
      final startOfYear = DateTime(
        oneYearAgo.year,
        oneYearAgo.month,
        oneYearAgo.day,
      );
      final endOfYear = startOfYear.add(const Duration(days: 1));

      final db = await _databaseService.database;
      final results = await db.query(
        'diary_entries',
        where: 'user_id = ? AND date >= ? AND date < ? AND is_deleted = 0',
        whereArgs: [
          int.parse(userId),
          startOfYear.toIso8601String(),
          endOfYear.toIso8601String(),
        ],
        orderBy: 'created_at DESC',
        limit: settings.maxMemoriesPerType,
      );

      return results.map((diary) {
        return DiaryMemory(
          id: 'one_year_ago_${diary['id']}',
          diaryId: diary['id'].toString(),
          title: (diary['title'] as String?) ?? '제목 없음',
          content: (diary['content'] as String?) ?? '',
          createdAt: DateTime.parse(diary['created_at'] as String),
          originalDate: DateTime.parse(diary['date'] as String),
          reason: MemoryReason(
            type: MemoryType.oneYearAgo,
            description: '1년 전 작성한 일기입니다',
            displayText: '1년 전의 기록',
            metadata: {'original_date': diary['date'] as String},
          ),
          relevance: _calculateOneYearAgoRelevance(diary),
          tags: [],
          imageUrl: null,
          location: diary['location'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting one year ago memories: $e');
      return [];
    }
  }

  /// 과거의 오늘 회상 (작년, 재작년 같은 날짜)
  Future<List<DiaryMemory>> _getPastTodayMemories({
    required String userId,
    required MemorySettings settings,
  }) async {
    try {
      final now = DateTime.now();
      final memories = <DiaryMemory>[];

      final db = await _databaseService.database;

      // 작년 같은 날
      final lastYear = DateTime(now.year - 1, now.month, now.day);
      final lastYearResults = await db.query(
        'diary_entries',
        where: 'user_id = ? AND date >= ? AND date < ? AND is_deleted = 0',
        whereArgs: [
          int.parse(userId),
          lastYear.toIso8601String(),
          lastYear.add(const Duration(days: 1)).toIso8601String(),
        ],
        limit: settings.maxMemoriesPerType ~/ 2,
      );

      memories.addAll(lastYearResults.map((diary) {
        return DiaryMemory(
          id: 'past_today_${diary['id']}',
          diaryId: diary['id'].toString(),
          title: (diary['title'] as String?) ?? '제목 없음',
          content: (diary['content'] as String?) ?? '',
          createdAt: DateTime.parse(diary['created_at'] as String),
          originalDate: DateTime.parse(diary['date'] as String),
          reason: MemoryReason(
            type: MemoryType.pastToday,
            description: '작년 같은 날 작성한 일기입니다',
            displayText: '작년 이맘때',
            metadata: {
              'year_difference': 1,
              'original_date': diary['date'] as String,
            },
          ),
          relevance: _calculatePastTodayRelevance(diary, 1),
          tags: [],
          imageUrl: null,
          location: diary['location'] as String?,
        );
      }));

      return memories;
    } catch (e) {
      debugPrint('Error getting past today memories: $e');
      return [];
    }
  }

  /// 같은 시간대 과거 기록 회상
  Future<List<DiaryMemory>> _getSameTimeMemories({
    required String userId,
    required MemorySettings settings,
  }) async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(
        Duration(days: settings.maxDaysToLookBack),
      );

      final db = await _databaseService.database;
      final results = await db.query(
        'diary_entries',
        where: 'user_id = ? AND date >= ? AND is_deleted = 0',
        whereArgs: [
          int.parse(userId),
          thirtyDaysAgo.toIso8601String(),
        ],
        orderBy: 'created_at DESC',
        limit: settings.maxMemoriesPerType * 2,
      );

      final sameTimeMemories = <DiaryMemory>[];
      for (final diary in results) {
        final diaryTime = DateTime.parse(diary['created_at'] as String);
        final diaryHour = diaryTime.hour;

        if ((diaryHour - now.hour).abs() <= 1) {
          sameTimeMemories.add(
            DiaryMemory(
              id: 'same_time_${diary['id']}',
              diaryId: diary['id'].toString(),
              title: (diary['title'] as String?) ?? '제목 없음',
              content: (diary['content'] as String?) ?? '',
              createdAt: DateTime.parse(diary['created_at'] as String),
              originalDate: DateTime.parse(diary['date'] as String),
              reason: MemoryReason(
                type: MemoryType.sameTimeOfDay,
                description: '비슷한 시간에 작성한 과거 기록입니다',
                displayText: '이 시간의 기록',
                metadata: {
                  'original_time': '${diaryHour.toString().padLeft(2, '0')}:00',
                  'current_time': '${now.hour.toString().padLeft(2, '0')}:00',
                },
              ),
              relevance: _calculateSameTimeRelevance(diary, now.hour, now.minute),
              tags: [],
              imageUrl: null,
              location: diary['location'] as String?,
            ),
          );
        }

        if (sameTimeMemories.length >= settings.maxMemoriesPerType) break;
      }

      return sameTimeMemories;
    } catch (e) {
      debugPrint('Error getting same time memories: $e');
      return [];
    }
  }

  /// 비슷한 태그를 가진 일기 회상
  Future<List<DiaryMemory>> _getSimilarTagsMemories({
    required String userId,
    required MemorySettings settings,
  }) async {
    try {
      // SQLite에서는 태그 기능이 구현되어 있지 않을 수 있으므로 빈 리스트 반환
      return [];
    } catch (e) {
      debugPrint('Error getting similar tags memories: $e');
      return [];
    }
  }

  /// 특별한 날짜 회상
  Future<List<DiaryMemory>> _getSpecialDateMemories({
    required String userId,
    required MemorySettings settings,
  }) async {
    try {
      // 특별한 날짜 기능은 사용자 설정이 필요하므로 일단 빈 리스트 반환
      return [];
    } catch (e) {
      debugPrint('Error getting special date memories: $e');
      return [];
    }
  }

  /// 계절별 회상
  Future<List<DiaryMemory>> _getSeasonalMemories({
    required String userId,
    required MemorySettings settings,
  }) async {
    try {
      final now = DateTime.now();
      final currentMonth = now.month;

      String currentSeason;
      if (currentMonth >= 3 && currentMonth <= 5) {
        currentSeason = 'spring';
      } else if (currentMonth >= 6 && currentMonth <= 8) {
        currentSeason = 'summer';
      } else if (currentMonth >= 9 && currentMonth <= 11) {
        currentSeason = 'autumn';
      } else {
        currentSeason = 'winter';
      }

      final lastYearSeasonStart = _getSeasonStartDate(now.year - 1, currentSeason);
      final lastYearSeasonEnd = _getSeasonEndDate(now.year - 1, currentSeason);

      final db = await _databaseService.database;
      final results = await db.query(
        'diary_entries',
        where: 'user_id = ? AND date >= ? AND date < ? AND is_deleted = 0',
        whereArgs: [
          int.parse(userId),
          lastYearSeasonStart.toIso8601String(),
          lastYearSeasonEnd.toIso8601String(),
        ],
        orderBy: 'created_at DESC',
        limit: settings.maxMemoriesPerType,
      );

      return results.map((diary) {
        return DiaryMemory(
          id: 'seasonal_${diary['id']}',
          diaryId: diary['id'].toString(),
          title: (diary['title'] as String?) ?? '제목 없음',
          content: (diary['content'] as String?) ?? '',
          createdAt: DateTime.parse(diary['created_at'] as String),
          originalDate: DateTime.parse(diary['date'] as String),
          reason: MemoryReason(
            type: MemoryType.seasonal,
            description: '작년 같은 계절에 작성한 일기입니다',
            displayText: '작년 ${_getSeasonDisplayName(currentSeason)}',
            metadata: {'season': currentSeason, 'year_difference': 1},
          ),
          relevance: _calculateSeasonalRelevance(diary, currentSeason),
          tags: [],
          imageUrl: null,
          location: diary['location'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting seasonal memories: $e');
      return [];
    }
  }

  /// 회상 관련성 계산 메서드들
  double _calculateYesterdayRelevance(Map<String, dynamic> diary) {
    double relevance = 0.9;
    final contentLength = ((diary['content'] as String?) ?? '').length;
    if (contentLength > 100) relevance += 0.05;
    if (contentLength > 500) relevance += 0.05;
    return relevance.clamp(0.0, 1.0);
  }

  double _calculateOneWeekAgoRelevance(Map<String, dynamic> diary) {
    double relevance = 0.8;
    final contentLength = ((diary['content'] as String?) ?? '').length;
    if (contentLength > 100) relevance += 0.05;
    if (contentLength > 500) relevance += 0.05;
    return relevance.clamp(0.0, 1.0);
  }

  double _calculateOneMonthAgoRelevance(Map<String, dynamic> diary) {
    double relevance = 0.7;
    final contentLength = ((diary['content'] as String?) ?? '').length;
    if (contentLength > 100) relevance += 0.05;
    if (contentLength > 500) relevance += 0.05;
    return relevance.clamp(0.0, 1.0);
  }

  double _calculateOneYearAgoRelevance(Map<String, dynamic> diary) {
    double relevance = 0.6;
    final contentLength = ((diary['content'] as String?) ?? '').length;
    if (contentLength > 100) relevance += 0.05;
    if (contentLength > 500) relevance += 0.05;
    return relevance.clamp(0.0, 1.0);
  }

  double _calculatePastTodayRelevance(
    Map<String, dynamic> diary,
    int yearDifference,
  ) {
    double relevance = 0.8;
    relevance -= (yearDifference * 0.1).clamp(0.0, 0.3);
    final contentLength = ((diary['content'] as String?) ?? '').length;
    if (contentLength > 200) relevance += 0.1;
    return relevance.clamp(0.0, 1.0);
  }

  double _calculateSameTimeRelevance(
    Map<String, dynamic> diary,
    int currentHour,
    int currentMinute,
  ) {
    final diaryTime = DateTime.parse(diary['created_at'] as String);
    final diaryHour = diaryTime.hour;
    final diaryMinute = diaryTime.minute;

    double relevance = 0.7;
    final hourDiff = (diaryHour - currentHour).abs();
    relevance -= (hourDiff * 0.1).clamp(0.0, 0.3);
    final minuteDiff = (diaryMinute - currentMinute).abs();
    relevance -= (minuteDiff * 0.01).clamp(0.0, 0.1);
    return relevance.clamp(0.0, 1.0);
  }

  double _calculateSeasonalRelevance(
    Map<String, dynamic> diary,
    String season,
  ) {
    double relevance = 0.6;
    final content = ((diary['content'] as String?) ?? '').toLowerCase();
    final seasonKeywords = _getSeasonKeywords(season);

    for (final keyword in seasonKeywords) {
      if (content.contains(keyword)) {
        relevance += 0.1;
      }
    }
    return relevance.clamp(0.0, 1.0);
  }

  /// 필터 적용
  List<DiaryMemory> _applyFilter(
    List<DiaryMemory> memories,
    MemoryFilter filter,
  ) {
    return memories.where((memory) {
      if (filter.allowedTypes.isNotEmpty &&
          !filter.allowedTypes.contains(memory.reason.type)) {
        return false;
      }

      if (filter.excludedTypes.contains(memory.reason.type)) {
        return false;
      }

      if (memory.relevance < filter.minRelevance ||
          memory.relevance > filter.maxRelevance) {
        return false;
      }

      if (filter.startDate != null &&
          memory.originalDate.isBefore(filter.startDate!)) {
        return false;
      }

      if (filter.endDate != null &&
          memory.originalDate.isAfter(filter.endDate!)) {
        return false;
      }

      if (filter.excludeViewed && memory.isViewed) return false;
      if (filter.excludeBookmarked && memory.isBookmarked) return false;

      return true;
    }).toList();
  }

  /// 회상 정렬
  List<DiaryMemory> _sortMemories(
    List<DiaryMemory> memories,
    MemoryFilter filter,
  ) {
    final sorted = List<DiaryMemory>.from(memories);

    sorted.sort((a, b) {
      int comparison = 0;

      switch (filter.sortBy) {
        case MemorySortBy.relevance:
          comparison = a.relevance.compareTo(b.relevance);
          break;
        case MemorySortBy.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case MemorySortBy.originalDate:
          comparison = a.originalDate.compareTo(b.originalDate);
          break;
        case MemorySortBy.lastViewedAt:
          final aLastViewed = a.lastViewedAt ?? DateTime(1970);
          final bLastViewed = b.lastViewedAt ?? DateTime(1970);
          comparison = aLastViewed.compareTo(bLastViewed);
          break;
        case MemorySortBy.title:
          comparison = a.title.compareTo(b.title);
          break;
      }

      return filter.sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return sorted.take(filter.maxResults).toList();
  }

  /// 계절 시작 날짜 계산
  DateTime _getSeasonStartDate(int year, String season) {
    switch (season) {
      case 'spring':
        return DateTime(year, 3, 1);
      case 'summer':
        return DateTime(year, 6, 1);
      case 'autumn':
        return DateTime(year, 9, 1);
      case 'winter':
        return DateTime(year, 12, 1);
      default:
        return DateTime(year, 1, 1);
    }
  }

  /// 계절 끝 날짜 계산
  DateTime _getSeasonEndDate(int year, String season) {
    switch (season) {
      case 'spring':
        return DateTime(year, 6, 1);
      case 'summer':
        return DateTime(year, 9, 1);
      case 'autumn':
        return DateTime(year, 12, 1);
      case 'winter':
        return DateTime(year + 1, 3, 1);
      default:
        return DateTime(year + 1, 1, 1);
    }
  }

  /// 계절 표시 이름
  String _getSeasonDisplayName(String season) {
    switch (season) {
      case 'spring':
        return '봄';
      case 'summer':
        return '여름';
      case 'autumn':
        return '가을';
      case 'winter':
        return '겨울';
      default:
        return '계절';
    }
  }

  /// 계절 키워드
  List<String> _getSeasonKeywords(String season) {
    switch (season) {
      case 'spring':
        return ['봄', '꽃', '새싹', '따뜻', '벚꽃', '개나리'];
      case 'summer':
        return ['여름', '더위', '바다', '휴가', '수박', '선풍기'];
      case 'autumn':
        return ['가을', '단풍', '감', '선선', '가을날', '단풍잎'];
      case 'winter':
        return ['겨울', '눈', '추위', '스키', '크리스마스', '연말'];
      default:
        return [];
    }
  }
}
