import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/diary_memory.dart';
import '../models/memory_filter.dart';

/// 회상 시스템의 핵심 서비스
class MemoryService {
  static final MemoryService _instance = MemoryService._internal();
  factory MemoryService() => _instance;
  MemoryService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Supabase 연결 상태 확인
  Future<bool> _checkSupabaseAvailability() async {
    try {
      // 연결 상태 확인 로직
      return _supabase.auth.currentUser != null ||
          await _supabase
              .from('diaries')
              .select('id')
              .limit(1)
              .then((_) => true)
              .catchError((_) => false);
    } catch (e) {
      debugPrint('Supabase 연결 확인 실패: $e');
      return false;
    }
  }

  /// 회상 결과를 생성합니다
  Future<MemoryResult> generateMemories({
    required String userId,
    MemoryFilter? filter,
    MemorySettings? settings,
  }) async {
    try {
      // Supabase 연결 상태 확인
      if (!await _checkSupabaseAvailability()) {
        throw Exception('Supabase 연결에 문제가 있습니다. 네트워크 연결을 확인해주세요.');
      }

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

      final response = await _supabase
          .from('diaries')
          .select('*')
          .eq('user_id', userId)
          .gte('created_at', startOfYesterday.toIso8601String())
          .lt('created_at', endOfYesterday.toIso8601String())
          .order('created_at', ascending: false)
          .limit(settings.maxMemoriesPerType);

      return response.map<DiaryMemory>((diary) {
        return DiaryMemory(
          id: 'yesterday_${diary['id'] as String}',
          diaryId: diary['id'] as String,
          title: (diary['title'] as String?) ?? '제목 없음',
          content: (diary['content'] as String?) ?? '',
          createdAt: DateTime.parse(diary['created_at'] as String),
          originalDate: DateTime.parse(diary['created_at'] as String),
          reason: MemoryReason(
            type: MemoryType.yesterday,
            description: '어제 작성한 일기입니다',
            displayText: '어제의 기록',
            metadata: {'original_date': diary['created_at'] as String},
          ),
          relevance: _calculateYesterdayRelevance(diary),
          tags: List<String>.from((diary['tags'] as List<dynamic>?) ?? []),
          imageUrl: diary['image_url'] as String?,
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

      final response = await _supabase
          .from('diaries')
          .select('*')
          .eq('user_id', userId)
          .gte('created_at', startOfWeek.toIso8601String())
          .lt('created_at', endOfWeek.toIso8601String())
          .order('created_at', ascending: false)
          .limit(settings.maxMemoriesPerType);

      return response.map<DiaryMemory>((diary) {
        return DiaryMemory(
          id: 'one_week_ago_${diary['id'] as String}',
          diaryId: diary['id'] as String,
          title: (diary['title'] as String?) ?? '제목 없음',
          content: (diary['content'] as String?) ?? '',
          createdAt: DateTime.parse(diary['created_at'] as String),
          originalDate: DateTime.parse(diary['created_at'] as String),
          reason: MemoryReason(
            type: MemoryType.oneWeekAgo,
            description: '일주일 전 작성한 일기입니다',
            displayText: '일주일 전의 기록',
            metadata: {'original_date': diary['created_at'] as String},
          ),
          relevance: _calculateOneWeekAgoRelevance(diary),
          tags: List<String>.from((diary['tags'] as List<dynamic>?) ?? []),
          imageUrl: diary['image_url'] as String?,
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

      final response = await _supabase
          .from('diaries')
          .select('*')
          .eq('user_id', userId)
          .gte('created_at', startOfMonth.toIso8601String())
          .lt('created_at', endOfMonth.toIso8601String())
          .order('created_at', ascending: false)
          .limit(settings.maxMemoriesPerType);

      return response.map<DiaryMemory>((diary) {
        return DiaryMemory(
          id: 'one_month_ago_${diary['id'] as String}',
          diaryId: diary['id'] as String,
          title: (diary['title'] as String?) ?? '제목 없음',
          content: (diary['content'] as String?) ?? '',
          createdAt: DateTime.parse(diary['created_at'] as String),
          originalDate: DateTime.parse(diary['created_at'] as String),
          reason: MemoryReason(
            type: MemoryType.oneMonthAgo,
            description: '한달 전 작성한 일기입니다',
            displayText: '한달 전의 기록',
            metadata: {'original_date': diary['created_at'] as String},
          ),
          relevance: _calculateOneMonthAgoRelevance(diary),
          tags: List<String>.from((diary['tags'] as List<dynamic>?) ?? []),
          imageUrl: diary['image_url'] as String?,
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

      final response = await _supabase
          .from('diaries')
          .select('*')
          .eq('user_id', userId)
          .gte('created_at', startOfYear.toIso8601String())
          .lt('created_at', endOfYear.toIso8601String())
          .order('created_at', ascending: false)
          .limit(settings.maxMemoriesPerType);

      return response.map<DiaryMemory>((diary) {
        return DiaryMemory(
          id: 'one_year_ago_${diary['id'] as String}',
          diaryId: diary['id'] as String,
          title: (diary['title'] as String?) ?? '제목 없음',
          content: (diary['content'] as String?) ?? '',
          createdAt: DateTime.parse(diary['created_at'] as String),
          originalDate: DateTime.parse(diary['created_at'] as String),
          reason: MemoryReason(
            type: MemoryType.oneYearAgo,
            description: '1년 전 작성한 일기입니다',
            displayText: '1년 전의 기록',
            metadata: {'original_date': diary['created_at'] as String},
          ),
          relevance: _calculateOneYearAgoRelevance(diary),
          tags: List<String>.from((diary['tags'] as List<dynamic>?) ?? []),
          imageUrl: diary['image_url'] as String?,
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
      final currentMonth = now.month;
      final currentDay = now.day;

      // 작년과 재작년의 같은 날짜 찾기
      final lastYear = DateTime(now.year - 1, currentMonth, currentDay);
      final twoYearsAgo = DateTime(now.year - 2, currentMonth, currentDay);

      final memories = <DiaryMemory>[];

      // 작년 기록
      final lastYearStart = DateTime(
        lastYear.year,
        lastYear.month,
        lastYear.day,
      );
      final lastYearEnd = lastYearStart.add(const Duration(days: 1));

      final lastYearResponse = await _supabase
          .from('diaries')
          .select('*')
          .eq('user_id', userId)
          .gte('created_at', lastYearStart.toIso8601String())
          .lt('created_at', lastYearEnd.toIso8601String())
          .limit(settings.maxMemoriesPerType ~/ 2);

      for (final diary in lastYearResponse) {
        memories.add(
          DiaryMemory(
            id: 'past_today_${diary['id'] as String}',
            diaryId: diary['id'] as String,
            title: (diary['title'] as String?) ?? '제목 없음',
            content: (diary['content'] as String?) ?? '',
            createdAt: DateTime.parse(diary['created_at'] as String),
            originalDate: DateTime.parse(diary['created_at'] as String),
            reason: MemoryReason(
              type: MemoryType.pastToday,
              description: '작년 같은 날 작성한 일기입니다',
              displayText: '작년 이맘때',
              metadata: {
                'year_difference': 1,
                'original_date': diary['created_at'] as String,
              },
            ),
            relevance: _calculatePastTodayRelevance(diary, 1),
            tags: List<String>.from((diary['tags'] as List<dynamic>?) ?? []),
            imageUrl: diary['image_url'] as String?,
            location: diary['location'] as String?,
          ),
        );
      }

      // 재작년 기록
      final twoYearsAgoStart = DateTime(
        twoYearsAgo.year,
        twoYearsAgo.month,
        twoYearsAgo.day,
      );
      final twoYearsAgoEnd = twoYearsAgoStart.add(const Duration(days: 1));

      final twoYearsAgoResponse = await _supabase
          .from('diaries')
          .select('*')
          .eq('user_id', userId)
          .gte('created_at', twoYearsAgoStart.toIso8601String())
          .lt('created_at', twoYearsAgoEnd.toIso8601String())
          .limit(settings.maxMemoriesPerType ~/ 2);

      for (final diary in twoYearsAgoResponse) {
        memories.add(
          DiaryMemory(
            id: 'past_today_${diary['id'] as String}',
            diaryId: diary['id'] as String,
            title: (diary['title'] as String?) ?? '제목 없음',
            content: (diary['content'] as String?) ?? '',
            createdAt: DateTime.parse(diary['created_at'] as String),
            originalDate: DateTime.parse(diary['created_at'] as String),
            reason: MemoryReason(
              type: MemoryType.pastToday,
              description: '재작년 같은 날 작성한 일기입니다',
              displayText: '재작년 이맘때',
              metadata: {
                'year_difference': 2,
                'original_date': diary['created_at'] as String,
              },
            ),
            relevance: _calculatePastTodayRelevance(diary, 2),
            tags: List<String>.from((diary['tags'] as List<dynamic>?) ?? []),
            imageUrl: diary['image_url'] as String?,
            location: diary['location'] as String?,
          ),
        );
      }

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
      final currentHour = now.hour;
      final currentMinute = now.minute;

      // 최근 30일 내에서 같은 시간대 기록 찾기
      final thirtyDaysAgo = now.subtract(
        Duration(days: settings.maxDaysToLookBack),
      );

      final response = await _supabase
          .from('diaries')
          .select('*')
          .eq('user_id', userId)
          .gte('created_at', thirtyDaysAgo.toIso8601String())
          .order('created_at', ascending: false);

      final sameTimeMemories = <DiaryMemory>[];

      for (final diary in response) {
        final diaryTime = DateTime.parse(diary['created_at'] as String);
        final diaryHour = diaryTime.hour;
        final diaryMinute = diaryTime.minute;

        // 시간대가 비슷한지 확인 (±1시간 범위)
        if ((diaryHour - currentHour).abs() <= 1) {
          sameTimeMemories.add(
            DiaryMemory(
              id: 'same_time_${diary['id'] as String}',
              diaryId: diary['id'] as String,
              title: (diary['title'] as String?) ?? '제목 없음',
              content: (diary['content'] as String?) ?? '',
              createdAt: DateTime.parse(diary['created_at'] as String),
              originalDate: DateTime.parse(diary['created_at'] as String),
              reason: MemoryReason(
                type: MemoryType.sameTimeOfDay,
                description: '비슷한 시간에 작성한 과거 기록입니다',
                displayText: '이 시간의 기록',
                metadata: {
                  'original_time':
                      '${diaryHour.toString().padLeft(2, '0')}:${diaryMinute.toString().padLeft(2, '0')}',
                  'current_time':
                      '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}',
                },
              ),
              relevance: _calculateSameTimeRelevance(
                diary,
                currentHour,
                currentMinute,
              ),
              tags: List<String>.from((diary['tags'] as List<dynamic>?) ?? []),
              imageUrl: diary['image_url'] as String?,
              location: diary['location'] as String?,
            ),
          );
        }

        if (sameTimeMemories.length >= settings.maxMemoriesPerType) {
          break;
        }
      }

      return sameTimeMemories;
    } catch (e) {
      debugPrint('Error getting same time recommendations: $e');
      return [];
    }
  }

  /// 비슷한 태그를 가진 일기 회상
  Future<List<DiaryMemory>> _getSimilarTagsMemories({
    required String userId,
    required MemorySettings settings,
  }) async {
    try {
      // 최근 일기들의 태그를 분석하여 인기 태그 찾기
      final recentDiaries = await _supabase
          .from('diaries')
          .select('tags')
          .eq('user_id', userId)
          .gte(
            'created_at',
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          )
          .limit(50);

      final tagFrequency = <String, int>{};
      for (final diary in recentDiaries) {
        final tags = List<String>.from((diary['tags'] as List<dynamic>?) ?? []);
        for (final tag in tags) {
          tagFrequency[tag] = (tagFrequency[tag] ?? 0) + 1;
        }
      }

      // 인기 태그 상위 5개 선택
      final popularTags = tagFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (popularTags.isEmpty) return [];

      final topTags = popularTags.take(3).map((e) => e.key).toList();

      // 해당 태그들을 포함한 과거 일기들 찾기
      final response = await _supabase
          .from('diaries')
          .select('*')
          .eq('user_id', userId)
          .contains('tags', topTags)
          .order('created_at', ascending: false)
          .limit(settings.maxMemoriesPerType);

      return response.map<DiaryMemory>((diary) {
        final diaryTags = List<String>.from(
          (diary['tags'] as List<dynamic>?) ?? [],
        );
        final commonTags = diaryTags
            .where((tag) => topTags.contains(tag))
            .toList();

        return DiaryMemory(
          id: 'similar_tags_${diary['id'] as String}',
          diaryId: diary['id'] as String,
          title: (diary['title'] as String?) ?? '제목 없음',
          content: (diary['content'] as String?) ?? '',
          createdAt: DateTime.parse(diary['created_at'] as String),
          originalDate: DateTime.parse(diary['created_at'] as String),
          reason: MemoryReason(
            type: MemoryType.similarTags,
            description: '비슷한 태그를 가진 과거 일기입니다',
            displayText: '관련 태그: ${commonTags.join(', ')}',
            metadata: {
              'common_tags': commonTags,
              'tag_count': commonTags.length,
            },
          ),
          relevance: _calculateSimilarTagsRelevance(diary, commonTags),
          tags: diaryTags,
          imageUrl: diary['image_url'] as String?,
          location: diary['location'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting similar tags recommendations: $e');
      return [];
    }
  }

  /// 특별한 날짜 회상
  Future<List<DiaryMemory>> _getSpecialDateMemories({
    required String userId,
    required MemorySettings settings,
  }) async {
    try {
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentDay = now.day;

      // 특별한 날짜들 (생일, 기념일 등) - 실제로는 사용자 설정에서 가져와야 함
      final specialDates = [
        DateTime(now.year - 1, currentMonth, currentDay), // 작년 생일
        DateTime(now.year - 2, currentMonth, currentDay), // 재작년 생일
      ];

      final memories = <DiaryMemory>[];

      for (final specialDate in specialDates) {
        final startDate = DateTime(
          specialDate.year,
          specialDate.month,
          specialDate.day,
        );
        final endDate = startDate.add(const Duration(days: 1));

        final response = await _supabase
            .from('diaries')
            .select('*')
            .eq('user_id', userId)
            .gte('created_at', startDate.toIso8601String())
            .lt('created_at', endDate.toIso8601String())
            .limit(1);

        if (response.isNotEmpty) {
          final diary = response.first;
          memories.add(
            DiaryMemory(
              id: 'special_date_${diary['id'] as String}',
              diaryId: diary['id'] as String,
              title: (diary['title'] as String?) ?? '제목 없음',
              content: (diary['content'] as String?) ?? '',
              createdAt: DateTime.parse(diary['created_at'] as String),
              originalDate: DateTime.parse(diary['created_at'] as String),
              reason: MemoryReason(
                type: MemoryType.specialDate,
                description: '특별한 날짜에 작성한 일기입니다',
                displayText: '특별한 날의 기록',
                metadata: {
                  'special_date': specialDate.toIso8601String(),
                  'year_difference': now.year - specialDate.year,
                },
              ),
              relevance: _calculateSpecialDateRelevance(
                diary,
                now.year - specialDate.year,
              ),
              tags: List<String>.from((diary['tags'] as List<dynamic>?) ?? []),
              imageUrl: diary['image_url'] as String?,
              location: diary['location'] as String?,
            ),
          );
        }
      }

      return memories;
    } catch (e) {
      debugPrint('Error getting special date recommendations: $e');
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

      // 현재 계절 결정
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

      // 작년 같은 계절의 일기들 찾기
      final lastYearSeasonStart = _getSeasonStartDate(
        now.year - 1,
        currentSeason,
      );
      final lastYearSeasonEnd = _getSeasonEndDate(now.year - 1, currentSeason);

      final response = await _supabase
          .from('diaries')
          .select('*')
          .eq('user_id', userId)
          .gte('created_at', lastYearSeasonStart.toIso8601String())
          .lt('created_at', lastYearSeasonEnd.toIso8601String())
          .order('created_at', ascending: false)
          .limit(settings.maxMemoriesPerType);

      return response.map<DiaryMemory>((diary) {
        return DiaryMemory(
          id: 'seasonal_${diary['id'] as String}',
          diaryId: diary['id'] as String,
          title: (diary['title'] as String?) ?? '제목 없음',
          content: (diary['content'] as String?) ?? '',
          createdAt: DateTime.parse(diary['created_at'] as String),
          originalDate: DateTime.parse(diary['created_at'] as String),
          reason: MemoryReason(
            type: MemoryType.seasonal,
            description: '작년 같은 계절에 작성한 일기입니다',
            displayText: '작년 ${_getSeasonDisplayName(currentSeason)}',
            metadata: {'season': currentSeason, 'year_difference': 1},
          ),
          relevance: _calculateSeasonalRelevance(diary, currentSeason),
          tags: List<String>.from((diary['tags'] as List<dynamic>?) ?? []),
          imageUrl: diary['image_url'] as String?,
          location: diary['location'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting seasonal recommendations: $e');
      return [];
    }
  }

  /// 회상 관련성 계산 메서드들
  double _calculateYesterdayRelevance(Map<String, dynamic> diary) {
    double relevance = 0.9; // 어제 일기는 높은 관련성

    // 내용 길이에 따른 관련성 조정
    final contentLength = ((diary['content'] as String?) ?? '').length;
    if (contentLength > 100) relevance += 0.05;
    if (contentLength > 500) relevance += 0.05;

    // 태그 개수에 따른 관련성 조정
    final tags = List<String>.from((diary['tags'] as List<dynamic>?) ?? []);
    relevance += (tags.length * 0.02).clamp(0.0, 0.1);

    return relevance.clamp(0.0, 1.0);
  }

  double _calculateOneWeekAgoRelevance(Map<String, dynamic> diary) {
    double relevance = 0.8; // 일주일 전 일기는 높은 관련성

    // 내용 길이에 따른 관련성 조정
    final contentLength = ((diary['content'] as String?) ?? '').length;
    if (contentLength > 100) relevance += 0.05;
    if (contentLength > 500) relevance += 0.05;

    // 태그 개수에 따른 관련성 조정
    final tags = List<String>.from((diary['tags'] as List<dynamic>?) ?? []);
    relevance += (tags.length * 0.02).clamp(0.0, 0.1);

    return relevance.clamp(0.0, 1.0);
  }

  double _calculateOneMonthAgoRelevance(Map<String, dynamic> diary) {
    double relevance = 0.7; // 한달 전 일기는 중간 관련성

    // 내용 길이에 따른 관련성 조정
    final contentLength = ((diary['content'] as String?) ?? '').length;
    if (contentLength > 100) relevance += 0.05;
    if (contentLength > 500) relevance += 0.05;

    // 태그 개수에 따른 관련성 조정
    final tags = List<String>.from((diary['tags'] as List<dynamic>?) ?? []);
    relevance += (tags.length * 0.02).clamp(0.0, 0.1);

    return relevance.clamp(0.0, 1.0);
  }

  double _calculateOneYearAgoRelevance(Map<String, dynamic> diary) {
    double relevance = 0.6; // 1년 전 일기는 중간 관련성

    // 내용 길이에 따른 관련성 조정
    final contentLength = ((diary['content'] as String?) ?? '').length;
    if (contentLength > 100) relevance += 0.05;
    if (contentLength > 500) relevance += 0.05;

    // 태그 개수에 따른 관련성 조정
    final tags = List<String>.from((diary['tags'] as List<dynamic>?) ?? []);
    relevance += (tags.length * 0.02).clamp(0.0, 0.1);

    return relevance.clamp(0.0, 1.0);
  }

  double _calculatePastTodayRelevance(
    Map<String, dynamic> diary,
    int yearDifference,
  ) {
    double relevance = 0.8; // 과거의 오늘은 높은 관련성

    // 년도 차이에 따른 관련성 조정
    relevance -= (yearDifference * 0.1).clamp(0.0, 0.3);

    // 내용 길이에 따른 관련성 조정
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

    double relevance = 0.7; // 기본 관련성

    // 시간 차이에 따른 관련성 조정
    final hourDiff = (diaryHour - currentHour).abs();
    relevance -= (hourDiff * 0.1).clamp(0.0, 0.3);

    // 분 차이에 따른 관련성 조정
    final minuteDiff = (diaryMinute - currentMinute).abs();
    relevance -= (minuteDiff * 0.01).clamp(0.0, 0.1);

    return relevance.clamp(0.0, 1.0);
  }

  double _calculateSimilarTagsRelevance(
    Map<String, dynamic> diary,
    List<String> commonTags,
  ) {
    double relevance = 0.5; // 기본 관련성

    // 공통 태그 개수에 따른 관련성 조정
    relevance += (commonTags.length * 0.15).clamp(0.0, 0.4);

    return relevance.clamp(0.0, 1.0);
  }

  double _calculateSpecialDateRelevance(
    Map<String, dynamic> diary,
    int yearDifference,
  ) {
    double relevance = 0.9; // 특별한 날짜는 높은 관련성

    // 년도 차이에 따른 관련성 조정
    relevance -= (yearDifference * 0.05).clamp(0.0, 0.2);

    return relevance.clamp(0.0, 1.0);
  }

  double _calculateSeasonalRelevance(
    Map<String, dynamic> diary,
    String season,
  ) {
    double relevance = 0.6; // 기본 관련성

    // 계절 관련 키워드가 있는지 확인
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
      // 회상 유형 필터
      if (filter.allowedTypes.isNotEmpty &&
          !filter.allowedTypes.contains(memory.reason.type)) {
        return false;
      }

      if (filter.excludedTypes.contains(memory.reason.type)) {
        return false;
      }

      // 관련성 필터
      if (memory.relevance < filter.minRelevance ||
          memory.relevance > filter.maxRelevance) {
        return false;
      }

      // 날짜 필터
      if (filter.startDate != null &&
          memory.originalDate.isBefore(filter.startDate!)) {
        return false;
      }

      if (filter.endDate != null &&
          memory.originalDate.isAfter(filter.endDate!)) {
        return false;
      }

      // 태그 필터
      if (filter.requiredTags.isNotEmpty) {
        final hasRequiredTags = filter.requiredTags.every(
          (tag) => memory.tags.contains(tag),
        );
        if (!hasRequiredTags) return false;
      }

      if (filter.excludedTags.isNotEmpty) {
        final hasExcludedTags = filter.excludedTags.any(
          (tag) => memory.tags.contains(tag),
        );
        if (hasExcludedTags) return false;
      }

      // 조회/북마크 필터
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
