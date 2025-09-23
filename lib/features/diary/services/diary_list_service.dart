import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/logger.dart';
import '../../../shared/models/diary_entry.dart';
import '../../../shared/services/database_service.dart';
import '../../../shared/services/repositories/diary_repository.dart';

/// 일기 목록 새로고침 이벤트 스트림
class DiaryListRefreshNotifier {
  static final DiaryListRefreshNotifier _instance =
      DiaryListRefreshNotifier._internal();
  factory DiaryListRefreshNotifier() => _instance;
  DiaryListRefreshNotifier._internal();

  final StreamController<void> _refreshController =
      StreamController<void>.broadcast();

  Stream<void> get refreshStream => _refreshController.stream;

  void notifyRefresh() {
    _refreshController.add(null);
  }

  void dispose() {
    _refreshController.close();
  }
}

/// 일기 목록 정렬 옵션
enum DiarySortOption {
  dateDesc, // 최신순
  dateAsc, // 오래된순
  titleAsc, // 제목순
  titleDesc, // 제목역순
  mood, // 기분순
  weather, // 날씨순
}

/// 일기 목록 필터 옵션
class DiaryListFilter {
  final String? searchQuery;
  final String? mood;
  final String? weather;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? tags;
  final bool? isFavorite;
  final bool? isPrivate;

  const DiaryListFilter({
    this.searchQuery,
    this.mood,
    this.weather,
    this.startDate,
    this.endDate,
    this.tags,
    this.isFavorite,
    this.isPrivate,
  });

  DiaryListFilter copyWith({
    String? searchQuery,
    String? mood,
    String? weather,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    bool? isFavorite,
    bool? isPrivate,
  }) {
    return DiaryListFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      mood: mood ?? this.mood,
      weather: weather ?? this.weather,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  bool get hasActiveFilters {
    return searchQuery != null ||
        mood != null ||
        weather != null ||
        startDate != null ||
        endDate != null ||
        (tags != null && tags!.isNotEmpty) ||
        isFavorite != null ||
        isPrivate != null;
  }
}

/// 일기 목록 서비스
class DiaryListService extends ChangeNotifier {
  final DiaryRepository _diaryRepository;
  final DiaryListRefreshNotifier _refreshNotifier = DiaryListRefreshNotifier();
  StreamSubscription<void>? _refreshSubscription;

  List<DiaryEntry> _diaries = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 20;

  // 필터 및 정렬
  DiaryListFilter _filter = const DiaryListFilter();
  DiarySortOption _sortOption = DiarySortOption.dateDesc;

  // 검색 관련
  String _searchQuery = '';
  Timer? _searchTimer;

  DiaryListService({
    required DatabaseService databaseService,
    required DiaryRepository diaryRepository,
  }) : _diaryRepository = diaryRepository {
    // 새로고침 이벤트 리스너 등록
    _refreshSubscription = _refreshNotifier.refreshStream.listen((_) {
      loadDiaries(refresh: true);
    });
  }

  // Getters
  List<DiaryEntry> get diaries => List.unmodifiable(_diaries);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  DiaryListFilter get filter => _filter;
  DiarySortOption get sortOption => _sortOption;
  String get searchQuery => _searchQuery;

  /// 일기 목록 로드
  Future<void> loadDiaries({bool refresh = false}) async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      if (refresh) {
        _currentPage = 0;
        _diaries.clear();
        _hasMore = true;
      }

      final filter = DiaryEntryFilter(
        userId: 1, // 임시 사용자 ID (저장 시와 동일하게 설정)
        mood: _filter.mood,
        weather: _filter.weather,
        startDate: _filter.startDate?.toIso8601String(),
        endDate: _filter.endDate?.toIso8601String(),
        searchQuery: _filter.searchQuery,
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      final newDiaries = await _diaryRepository.getDiaryEntriesWithFilter(
        filter,
      );

      if (refresh) {
        _diaries = newDiaries;
      } else {
        _diaries.addAll(newDiaries);
      }

      _hasMore = newDiaries.length == _pageSize;
      _currentPage++;

      // 정렬 적용
      _applySorting();

      Logger.info('일기 목록 로드 완료: ${_diaries.length}개', tag: 'DiaryListService');
    } catch (e) {
      _setError('일기 목록을 불러오는 중 오류가 발생했습니다: $e');
      Logger.error('일기 목록 로드 실패', tag: 'DiaryListService', error: e);
    } finally {
      _setLoading(false);
    }
  }

  /// 더 많은 일기 로드 (페이지네이션)
  Future<void> loadMoreDiaries() async {
    if (!_hasMore || _isLoading) return;
    await loadDiaries();
  }

  /// 검색
  void searchDiaries(String query) {
    _searchQuery = query;

    // 디바운스 처리 (300ms 후 검색 실행)
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      _filter = _filter.copyWith(searchQuery: query.isEmpty ? null : query);
      loadDiaries(refresh: true);
    });
  }

  /// 필터 적용
  void applyFilter(DiaryListFilter filter) {
    _filter = filter;
    loadDiaries(refresh: true);
  }

  /// 필터 초기화
  void clearFilter() {
    _filter = const DiaryListFilter();
    _searchQuery = '';
    loadDiaries(refresh: true);
  }

  /// 정렬 옵션 변경
  void setSortOption(DiarySortOption option) {
    _sortOption = option;
    _applySorting();
    notifyListeners();
  }

  /// 정렬 적용
  void _applySorting() {
    switch (_sortOption) {
      case DiarySortOption.dateDesc:
        _diaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case DiarySortOption.dateAsc:
        _diaries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case DiarySortOption.titleAsc:
        _diaries.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
        break;
      case DiarySortOption.titleDesc:
        _diaries.sort((a, b) => (b.title ?? '').compareTo(a.title ?? ''));
        break;
      case DiarySortOption.mood:
        _diaries.sort((a, b) => (a.mood ?? '').compareTo(b.mood ?? ''));
        break;
      case DiarySortOption.weather:
        _diaries.sort((a, b) => (a.weather ?? '').compareTo(b.weather ?? ''));
        break;
    }
  }

  /// 특정 일기 삭제
  Future<bool> deleteDiary(int diaryId) async {
    try {
      final success = await _diaryRepository.deleteDiaryEntry(diaryId);
      if (success) {
        _diaries.removeWhere((diary) => diary.id == diaryId);
        notifyListeners();
        Logger.info('일기 삭제 완료: ID $diaryId', tag: 'DiaryListService');
      }
      return success;
    } catch (e) {
      _setError('일기 삭제 중 오류가 발생했습니다: $e');
      Logger.error('일기 삭제 실패', tag: 'DiaryListService', error: e);
      return false;
    }
  }

  /// 일기 즐겨찾기 토글
  Future<bool> toggleFavorite(int diaryId) async {
    try {
      // 향후 즐겨찾기 상태 업데이트 로직 구현 예정
      // 현재 DiaryEntry 모델에 isFavorite 필드가 없음

      Logger.info('일기 즐겨찾기 토글: ID $diaryId', tag: 'DiaryListService');
      return true;
    } catch (e) {
      _setError('즐겨찾기 상태 변경 중 오류가 발생했습니다: $e');
      Logger.error('즐겨찾기 토글 실패', tag: 'DiaryListService', error: e);
      return false;
    }
  }

  /// 일기 통계 조회
  Future<Map<String, dynamic>> getDiaryStats() async {
    try {
      final totalCount = await _diaryRepository.getDiaryEntryCountByUserId(1);

      // 기분별 통계
      final moodStats = <String, int>{};
      for (final diary in _diaries) {
        if (diary.mood != null) {
          moodStats[diary.mood!] = (moodStats[diary.mood!] ?? 0) + 1;
        }
      }

      // 날씨별 통계
      final weatherStats = <String, int>{};
      for (final diary in _diaries) {
        if (diary.weather != null) {
          weatherStats[diary.weather!] =
              (weatherStats[diary.weather!] ?? 0) + 1;
        }
      }

      return {
        'totalCount': totalCount,
        'moodStats': moodStats,
        'weatherStats': weatherStats,
        'averageWordsPerDay': _calculateAverageWordsPerDay(),
      };
    } catch (e) {
      Logger.error('일기 통계 조회 실패', tag: 'DiaryListService', error: e);
      return {};
    }
  }

  /// 일일 평균 단어 수 계산
  double _calculateAverageWordsPerDay() {
    if (_diaries.isEmpty) return 0.0;

    final totalWords = _diaries.fold<int>(
      0,
      (sum, diary) => sum + diary.wordCount,
    );
    final days = _diaries.length;

    return days > 0 ? totalWords / days : 0.0;
  }

  /// 상태 설정
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

  /// 새로고침
  Future<void> refresh() async {
    await loadDiaries(refresh: true);
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _refreshSubscription?.cancel();
    super.dispose();
  }
}
