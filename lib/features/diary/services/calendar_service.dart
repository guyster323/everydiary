import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../core/services/image_generation_service.dart';
import '../../../shared/models/attachment.dart';
import '../../../shared/models/diary_entry.dart';
import '../../../shared/services/repositories/diary_repository.dart';
import '../../../shared/services/safe_delta_converter.dart';

/// 캘린더 서비스
/// 캘린더 뷰에서 필요한 일기 데이터를 관리합니다.
class CalendarService extends ChangeNotifier {
  final DiaryRepository _diaryRepository;

  // 상태 변수들
  bool _isLoading = false;
  String? _error;
  final Map<DateTime, List<DiaryEntry>> _events = {};
  List<DiaryEntry> _allDiaries = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<DateTime, List<DiaryEntry>> get events => _events;
  List<DiaryEntry> get allDiaries => _allDiaries;

  CalendarService({required DiaryRepository diaryRepository})
    : _diaryRepository = diaryRepository;

  /// 모든 일기 로드
  Future<void> loadDiaries() async {
    _setLoading(true);
    _clearError();

    try {
      // 모든 일기 로드 (삭제되지 않은 것만)
      const filter = DiaryEntryFilter(
        limit: 1000, // 충분히 큰 수로 설정
      );
      _allDiaries = await _diaryRepository.getDiaryEntriesWithFilter(filter);
      await _hydrateDiaryImages(_allDiaries);

      // 날짜별로 그룹화
      _groupDiariesByDate();
    } catch (e) {
      _setError('일기를 불러오는 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 특정 날짜의 일기 로드
  Future<void> loadDiariesForDate(DateTime date) async {
    _setLoading(true);
    _clearError();

    try {
      // 해당 날짜의 일기만 로드
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final filter = DiaryEntryFilter(
        startDate: startOfDay.toIso8601String(),
        endDate: endOfDay.toIso8601String(),
      );
      final diaries = await _diaryRepository.getDiaryEntriesWithFilter(filter);
      await _hydrateDiaryImages(diaries);

      // 해당 날짜의 이벤트 업데이트
      _events[startOfDay] = diaries;
    } catch (e) {
      _setError('일기를 불러오는 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 특정 날짜의 일기 목록 반환
  List<DiaryEntry> getDiariesForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _events[normalizedDate] ?? [];
  }

  /// 특정 날짜의 이벤트 반환 (table_calendar용)
  List<DiaryEntry> getEventsForDay(DateTime day) {
    final normalizedDate = DateTime(day.year, day.month, day.day);
    return _events[normalizedDate] ?? [];
  }

  /// 일기 추가 (새로 작성된 일기)
  void addDiary(DiaryEntry diary) {
    // 사용자가 선택한 날짜(date 필드)를 사용
    final diaryDate = DateTime.parse(diary.date);
    final date = DateTime(diaryDate.year, diaryDate.month, diaryDate.day);

    _events[date] ??= [];
    _events[date]!.add(diary);

    // 전체 목록에도 추가
    _allDiaries.add(diary);

    notifyListeners();
  }

  /// 일기 업데이트
  void updateDiary(DiaryEntry updatedDiary) {
    // 기존 일기 찾기 및 제거
    _removeDiaryFromEvents(updatedDiary.id);

    // 업데이트된 일기 추가 (사용자가 선택한 날짜 사용)
    final diaryDate = DateTime.parse(updatedDiary.date);
    final date = DateTime(diaryDate.year, diaryDate.month, diaryDate.day);

    _events[date] ??= [];
    _events[date]!.add(updatedDiary);

    // 전체 목록에서도 업데이트
    final index = _allDiaries.indexWhere((d) => d.id == updatedDiary.id);
    if (index != -1) {
      _allDiaries[index] = updatedDiary;
    }

    notifyListeners();
  }

  /// 일기 삭제
  void removeDiary(int diaryId) {
    _removeDiaryFromEvents(diaryId);

    // 전체 목록에서도 제거
    _allDiaries.removeWhere((d) => d.id == diaryId);

    notifyListeners();
  }

  /// 특정 월의 일기 통계 반환
  Map<String, int> getMonthlyStats(DateTime month) {
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    int totalDiaries = 0;
    int daysWithDiaries = 0;

    for (int day = 1; day <= endOfMonth.day; day++) {
      final date = DateTime(month.year, month.month, day);
      final diaries = getDiariesForDate(date);

      if (diaries.isNotEmpty) {
        daysWithDiaries++;
        totalDiaries += diaries.length;
      }
    }

    return {
      'totalDiaries': totalDiaries,
      'daysWithDiaries': daysWithDiaries,
      'totalDays': endOfMonth.day,
    };
  }

  /// 특정 주의 일기 통계 반환
  Map<String, int> getWeeklyStats(DateTime weekStart) {
    int totalDiaries = 0;
    int daysWithDiaries = 0;

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final diaries = getDiariesForDate(date);

      if (diaries.isNotEmpty) {
        daysWithDiaries++;
        totalDiaries += diaries.length;
      }
    }

    return {
      'totalDiaries': totalDiaries,
      'daysWithDiaries': daysWithDiaries,
      'totalDays': 7,
    };
  }

  /// 일기 작성 시간대 통계 반환
  Map<String, int> getWritingTimeStats(DateTime startDate, DateTime endDate) {
    final timeStats = <String, int>{};

    // 시간대별 초기화
    for (int hour = 0; hour < 24; hour++) {
      timeStats['${hour.toString().padLeft(2, '0')}:00'] = 0;
    }

    for (final diary in _allDiaries) {
      final createdAt = DateTime.parse(diary.createdAt);

      // 날짜 범위 확인
      if (createdAt.isBefore(startDate) || createdAt.isAfter(endDate)) {
        continue;
      }

      final hour = createdAt.hour;
      final timeKey = '${hour.toString().padLeft(2, '0')}:00';
      timeStats[timeKey] = (timeStats[timeKey] ?? 0) + 1;
    }

    return timeStats;
  }

  /// 일기 길이 통계 반환
  Map<String, dynamic> getContentLengthStats(
    DateTime startDate,
    DateTime endDate,
  ) {
    final lengths = <int>[];
    int totalCharacters = 0;
    int totalWords = 0;

    for (final diary in _allDiaries) {
      final createdAt = DateTime.parse(diary.createdAt);

      // 날짜 범위 확인
      if (createdAt.isBefore(startDate) || createdAt.isAfter(endDate)) {
        continue;
      }

      final content = diary.content;
      final characterCount = content.length;
      final wordCount = content
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .length;

      lengths.add(characterCount);
      totalCharacters += characterCount;
      totalWords += wordCount;
    }

    if (lengths.isEmpty) {
      return {
        'averageCharacters': 0,
        'averageWords': 0,
        'totalCharacters': 0,
        'totalWords': 0,
        'maxCharacters': 0,
        'minCharacters': 0,
      };
    }

    lengths.sort();
    final averageCharacters = totalCharacters / lengths.length;
    final averageWords = totalWords / lengths.length;

    return {
      'averageCharacters': averageCharacters.round(),
      'averageWords': averageWords.round(),
      'totalCharacters': totalCharacters,
      'totalWords': totalWords,
      'maxCharacters': lengths.last,
      'minCharacters': lengths.first,
    };
  }

  /// 월별 일기 작성 빈도 통계 반환
  Map<String, int> getMonthlyFrequencyStats(
    DateTime startDate,
    DateTime endDate,
  ) {
    final frequencyStats = <String, int>{};

    // 시작 날짜부터 끝 날짜까지 월별로 그룹화
    DateTime current = DateTime(startDate.year, startDate.month, 1);
    final end = DateTime(endDate.year, endDate.month, 1);

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      final monthKey =
          '${current.year}-${current.month.toString().padLeft(2, '0')}';
      frequencyStats[monthKey] = 0;
      current = DateTime(current.year, current.month + 1, 1);
    }

    for (final diary in _allDiaries) {
      final createdAt = DateTime.parse(diary.createdAt);

      // 날짜 범위 확인
      if (createdAt.isBefore(startDate) || createdAt.isAfter(endDate)) {
        continue;
      }

      final monthKey =
          '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
      frequencyStats[monthKey] = (frequencyStats[monthKey] ?? 0) + 1;
    }

    return frequencyStats;
  }

  /// 주간 일기 작성 빈도 통계 반환
  Map<String, int> getWeeklyFrequencyStats(
    DateTime startDate,
    DateTime endDate,
  ) {
    final frequencyStats = <String, int>{};

    // 시작 날짜의 주 시작일 계산 (일요일)
    DateTime current = startDate.subtract(
      Duration(days: startDate.weekday % 7),
    );

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      final weekKey = '${current.year}-W${_getWeekNumber(current)}';
      frequencyStats[weekKey] = 0;
      current = current.add(const Duration(days: 7));
    }

    for (final diary in _allDiaries) {
      final createdAt = DateTime.parse(diary.createdAt);

      // 날짜 범위 확인
      if (createdAt.isBefore(startDate) || createdAt.isAfter(endDate)) {
        continue;
      }

      final weekKey = '${createdAt.year}-W${_getWeekNumber(createdAt)}';
      frequencyStats[weekKey] = (frequencyStats[weekKey] ?? 0) + 1;
    }

    return frequencyStats;
  }

  /// 전체 통계 요약 반환
  Map<String, dynamic> getOverallStats() {
    if (_allDiaries.isEmpty) {
      return {
        'totalDiaries': 0,
        'totalDays': 0,
        'averagePerDay': 0.0,
        'longestStreak': 0,
        'currentStreak': 0,
        'mostActiveMonth': '',
        'mostActiveDay': '',
      };
    }

    final totalDiaries = _allDiaries.length;
    final dates = _allDiaries.map((d) => DateTime.parse(d.createdAt)).toList();
    dates.sort();

    final firstDate = dates.first;
    final lastDate = dates.last;
    final totalDays = lastDate.difference(firstDate).inDays + 1;
    final averagePerDay = totalDiaries / totalDays;

    // 연속 작성 일수 계산
    final streaks = _calculateStreaks(dates);
    final longestStreak = streaks.isNotEmpty
        ? streaks.reduce((a, b) => a > b ? a : b)
        : 0;
    final currentStreak = _calculateCurrentStreak(dates);

    // 가장 활발한 월과 요일 계산
    final monthlyStats = <String, int>{};
    final dailyStats = <int, int>{};

    for (final date in dates) {
      final monthKey = '${date.year}-${date.month}';
      monthlyStats[monthKey] = (monthlyStats[monthKey] ?? 0) + 1;
      dailyStats[date.weekday] = (dailyStats[date.weekday] ?? 0) + 1;
    }

    final mostActiveMonth = monthlyStats.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    final mostActiveDay = dailyStats.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    final dayNames = ['월', '화', '수', '목', '금', '토', '일'];
    final mostActiveDayName = dayNames[mostActiveDay - 1];

    return {
      'totalDiaries': totalDiaries,
      'totalDays': totalDays,
      'averagePerDay': averagePerDay,
      'longestStreak': longestStreak,
      'currentStreak': currentStreak,
      'mostActiveMonth': mostActiveMonth,
      'mostActiveDay': mostActiveDayName,
    };
  }

  /// 주차 번호 계산
  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil();
  }

  /// 연속 작성 일수 계산
  List<int> _calculateStreaks(List<DateTime> dates) {
    if (dates.isEmpty) return [];

    final streaks = <int>[];
    int currentStreak = 1;

    for (int i = 1; i < dates.length; i++) {
      final prevDate = dates[i - 1];
      final currentDate = dates[i];
      final difference = currentDate.difference(prevDate).inDays;

      if (difference == 1) {
        currentStreak++;
      } else {
        streaks.add(currentStreak);
        currentStreak = 1;
      }
    }
    streaks.add(currentStreak);

    return streaks;
  }

  /// 현재 연속 작성 일수 계산
  int _calculateCurrentStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final today = DateTime.now();
    final lastDate = dates.last;

    // 마지막 일기가 오늘 또는 어제가 아니면 연속이 끊어짐
    if (lastDate.difference(today).inDays > 1) {
      return 0;
    }

    int streak = 1;
    DateTime currentDate = lastDate;

    for (int i = dates.length - 2; i >= 0; i--) {
      final prevDate = dates[i];
      final difference = currentDate.difference(prevDate).inDays;

      if (difference == 1) {
        streak++;
        currentDate = prevDate;
      } else {
        break;
      }
    }

    return streak;
  }

  Future<void> _hydrateDiaryImages(List<DiaryEntry> diaries) async {
    if (diaries.isEmpty) {
      return;
    }

    final imageService = ImageGenerationService();
    await imageService.initialize();

    for (var index = 0; index < diaries.length; index++) {
      final diary = diaries[index];

      final filteredAttachments = diary.attachments.where((attachment) {
        final path = attachment.thumbnailPath?.isNotEmpty == true
            ? attachment.thumbnailPath!
            : attachment.filePath;

        if (path.isEmpty) {
          return false;
        }

        final file = File(path);
        return file.existsSync();
      }).toList();

      if (filteredAttachments.isNotEmpty) {
        diaries[index] = diary.copyWith(attachments: filteredAttachments);
        continue;
      }

      final plainTextContent = SafeDeltaConverter.extractTextFromDelta(
        diary.content,
      ).trim();

      if (plainTextContent.isEmpty) {
        continue;
      }

      final cachedResult = imageService.getCachedResult(plainTextContent);
      final candidatePath = cachedResult?.localImagePath;

      if (candidatePath == null || candidatePath.isEmpty) {
        continue;
      }

      final file = File(candidatePath);
      if (!file.existsSync()) {
        continue;
      }

      final attachment = Attachment(
        id: null,
        diaryId: diary.id ?? 0,
        filePath: candidatePath,
        fileName: p.basename(candidatePath),
        fileType: FileType.image.value,
        fileSize: null,
        mimeType: 'image/png',
        thumbnailPath: null,
        width: null,
        height: null,
        duration: null,
        createdAt: diary.createdAt,
        updatedAt: diary.updatedAt,
        isDeleted: false,
      );

      diaries[index] = diary.copyWith(attachments: [attachment]);
    }
  }

  /// 일기를 날짜별로 그룹화
  void _groupDiariesByDate() {
    _events.clear();

    for (final diary in _allDiaries) {
      // 사용자가 선택한 날짜(date 필드)를 사용
      final diaryDate = DateTime.parse(diary.date);
      final date = DateTime(diaryDate.year, diaryDate.month, diaryDate.day);

      _events[date] ??= [];
      _events[date]!.add(diary);
    }
  }

  /// 이벤트에서 일기 제거
  void _removeDiaryFromEvents(int? diaryId) {
    if (diaryId == null) return;

    _events.removeWhere((date, diaries) {
      diaries.removeWhere((diary) => diary.id == diaryId);
      return diaries.isEmpty;
    });
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 에러 설정
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// 에러 클리어
  void _clearError() {
    _error = null;
  }
}
