import 'package:flutter/foundation.dart';

import '../../../core/utils/logger.dart';
import '../../../shared/models/diary_entry.dart';

/// 일기 편집 히스토리 항목
class DiaryHistoryEntry {
  final String id;
  final int diaryId;
  final String title;
  final String content;
  final String? mood;
  final String? weather;
  final DateTime editedAt;
  final String changeDescription;

  const DiaryHistoryEntry({
    required this.id,
    required this.diaryId,
    required this.title,
    required this.content,
    this.mood,
    this.weather,
    required this.editedAt,
    required this.changeDescription,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'diaryId': diaryId,
    'title': title,
    'content': content,
    'mood': mood,
    'weather': weather,
    'editedAt': editedAt.toIso8601String(),
    'changeDescription': changeDescription,
  };

  factory DiaryHistoryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryHistoryEntry(
      id: json['id'] as String,
      diaryId: json['diaryId'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      mood: json['mood'] as String?,
      weather: json['weather'] as String?,
      editedAt: DateTime.parse(json['editedAt'] as String),
      changeDescription: json['changeDescription'] as String,
    );
  }
}

/// 일기 편집 히스토리 서비스
class DiaryHistoryService extends ChangeNotifier {
  final List<DiaryHistoryEntry> _history = [];
  static const int _maxHistoryEntries = 50; // 최대 히스토리 항목 수

  List<DiaryHistoryEntry> get history => List.unmodifiable(_history);

  /// 히스토리 로드
  Future<void> loadHistory(int diaryId) async {
    try {
      // 향후 SharedPreferences나 데이터베이스에서 로드 예정
      // 현재는 메모리에서만 관리
      _history.clear();
      notifyListeners();

      Logger.info('일기 히스토리 로드: ID $diaryId', tag: 'DiaryHistoryService');
    } catch (e) {
      Logger.error('일기 히스토리 로드 실패', tag: 'DiaryHistoryService', error: e);
    }
  }

  /// 편집 히스토리 추가
  Future<void> addHistoryEntry({
    required int diaryId,
    required String title,
    required String content,
    String? mood,
    String? weather,
    required String changeDescription,
  }) async {
    try {
      final entry = DiaryHistoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        diaryId: diaryId,
        title: title,
        content: content,
        mood: mood,
        weather: weather,
        editedAt: DateTime.now(),
        changeDescription: changeDescription,
      );

      _history.insert(0, entry); // 최신 항목을 맨 앞에 추가

      // 최대 히스토리 항목 수 제한
      if (_history.length > _maxHistoryEntries) {
        _history.removeRange(_maxHistoryEntries, _history.length);
      }

      notifyListeners();

      Logger.info('편집 히스토리 추가: $changeDescription', tag: 'DiaryHistoryService');
    } catch (e) {
      Logger.error('편집 히스토리 추가 실패', tag: 'DiaryHistoryService', error: e);
    }
  }

  /// 변경사항 분석
  String analyzeChanges({
    required DiaryEntry original,
    required DiaryEntry updated,
  }) {
    final changes = <String>[];

    // 제목 변경
    if (original.title != updated.title) {
      changes.add('제목 변경');
    }

    // 내용 변경
    if (original.content != updated.content) {
      changes.add('내용 수정');
    }

    // 기분 변경
    if (original.mood != updated.mood) {
      changes.add('기분 변경');
    }

    // 날씨 변경
    if (original.weather != updated.weather) {
      changes.add('날씨 변경');
    }

    // 단어 수 변경
    if (original.wordCount != updated.wordCount) {
      changes.add('단어 수 변경');
    }

    if (changes.isEmpty) {
      return '변경사항 없음';
    }

    return changes.join(', ');
  }

  /// 특정 일기의 히스토리 가져오기
  List<DiaryHistoryEntry> getHistoryForDiary(int diaryId) {
    return _history.where((entry) => entry.diaryId == diaryId).toList();
  }

  /// 히스토리 항목 삭제
  Future<void> removeHistoryEntry(String historyId) async {
    try {
      _history.removeWhere((entry) => entry.id == historyId);
      notifyListeners();

      Logger.info('히스토리 항목 삭제: $historyId', tag: 'DiaryHistoryService');
    } catch (e) {
      Logger.error('히스토리 항목 삭제 실패', tag: 'DiaryHistoryService', error: e);
    }
  }

  /// 특정 일기의 모든 히스토리 삭제
  Future<void> clearHistoryForDiary(int diaryId) async {
    try {
      _history.removeWhere((entry) => entry.diaryId == diaryId);
      notifyListeners();

      Logger.info('일기 히스토리 전체 삭제: ID $diaryId', tag: 'DiaryHistoryService');
    } catch (e) {
      Logger.error('일기 히스토리 삭제 실패', tag: 'DiaryHistoryService', error: e);
    }
  }

  /// 히스토리 통계
  Map<String, dynamic> getHistoryStats(int diaryId) {
    final diaryHistory = getHistoryForDiary(diaryId);

    return {
      'totalEdits': diaryHistory.length,
      'lastEdit': diaryHistory.isNotEmpty ? diaryHistory.first.editedAt : null,
      'firstEdit': diaryHistory.isNotEmpty ? diaryHistory.last.editedAt : null,
      'averageEditInterval': _calculateAverageEditInterval(diaryHistory),
    };
  }

  /// 평균 편집 간격 계산 (일 단위)
  double _calculateAverageEditInterval(List<DiaryHistoryEntry> history) {
    if (history.length < 2) return 0.0;

    final intervals = <int>[];
    for (int i = 0; i < history.length - 1; i++) {
      final interval = history[i].editedAt
          .difference(history[i + 1].editedAt)
          .inDays;
      intervals.add(interval);
    }

    return intervals.reduce((a, b) => a + b) / intervals.length;
  }
}
