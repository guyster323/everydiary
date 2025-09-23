import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';

/// 태그 관리 서비스
class TagService extends ChangeNotifier {
  static const String _tagsKey = 'diary_tags';
  static const String _recentTagsKey = 'recent_tags';

  List<DiaryTag> _allTags = [];
  List<DiaryTag> _recentTags = [];
  List<DiaryTag> _selectedTags = [];

  List<DiaryTag> get allTags => List.unmodifiable(_allTags);
  List<DiaryTag> get recentTags => List.unmodifiable(_recentTags);
  List<DiaryTag> get selectedTags => List.unmodifiable(_selectedTags);

  int get selectedTagCount => _selectedTags.length;

  /// 서비스 초기화
  Future<void> initialize() async {
    await _loadTags();
    await _loadRecentTags();
  }

  /// 태그 추가
  Future<void> addTag(String name, {String? color, String? description}) async {
    // 중복 확인
    if (_allTags.any((tag) => tag.name.toLowerCase() == name.toLowerCase())) {
      Logger.warning('태그가 이미 존재합니다: $name');
      return;
    }

    final tag = DiaryTag(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      color: color ?? _getRandomColor(),
      description: description,
      createdAt: DateTime.now(),
      usageCount: 0,
    );

    _allTags.add(tag);
    await _saveTags();
    notifyListeners();

    Logger.info('태그 추가됨: $name');
  }

  /// 태그 선택/해제
  void toggleTagSelection(String tagId) {
    final tagIndex = _allTags.indexWhere((tag) => tag.id == tagId);
    if (tagIndex == -1) return;

    final tag = _allTags[tagIndex];
    final selectedIndex = _selectedTags.indexWhere((t) => t.id == tagId);

    if (selectedIndex == -1) {
      // 선택
      _selectedTags.add(tag);
      _updateTagUsage(tagId);
      _addToRecentTags(tag);
    } else {
      // 해제
      _selectedTags.removeAt(selectedIndex);
    }

    notifyListeners();
  }

  /// 태그 선택
  void selectTag(String tagId) {
    final tag = _allTags.firstWhere((tag) => tag.id == tagId);
    if (!_selectedTags.any((t) => t.id == tagId)) {
      _selectedTags.add(tag);
      _updateTagUsage(tagId);
      _addToRecentTags(tag);
      notifyListeners();
    }
  }

  /// 태그 해제
  void deselectTag(String tagId) {
    _selectedTags.removeWhere((tag) => tag.id == tagId);
    notifyListeners();
  }

  /// 모든 태그 선택 해제
  void clearSelection() {
    _selectedTags.clear();
    notifyListeners();
  }

  /// 태그 삭제
  Future<void> deleteTag(String tagId) async {
    _allTags.removeWhere((tag) => tag.id == tagId);
    _selectedTags.removeWhere((tag) => tag.id == tagId);
    _recentTags.removeWhere((tag) => tag.id == tagId);

    await _saveTags();
    await _saveRecentTags();
    notifyListeners();

    Logger.info('태그 삭제됨: $tagId');
  }

  /// 태그 수정
  Future<void> updateTag(
    String tagId, {
    String? name,
    String? color,
    String? description,
  }) async {
    final tagIndex = _allTags.indexWhere((tag) => tag.id == tagId);
    if (tagIndex == -1) return;

    final tag = _allTags[tagIndex];
    _allTags[tagIndex] = tag.copyWith(
      name: name ?? tag.name,
      color: color ?? tag.color,
      description: description ?? tag.description,
    );

    // 선택된 태그도 업데이트
    final selectedIndex = _selectedTags.indexWhere((t) => t.id == tagId);
    if (selectedIndex != -1) {
      _selectedTags[selectedIndex] = _allTags[tagIndex];
    }

    await _saveTags();
    notifyListeners();

    Logger.info('태그 수정됨: $tagId');
  }

  /// 태그 검색
  List<DiaryTag> searchTags(String query) {
    if (query.isEmpty) return _allTags;

    final lowercaseQuery = query.toLowerCase();
    return _allTags
        .where(
          (tag) =>
              tag.name.toLowerCase().contains(lowercaseQuery) ||
              (tag.description?.toLowerCase().contains(lowercaseQuery) ??
                  false),
        )
        .toList();
  }

  /// 인기 태그 가져오기 (사용 빈도 기준)
  List<DiaryTag> getPopularTags({int limit = 10}) {
    final sortedTags = List<DiaryTag>.from(_allTags);
    sortedTags.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return sortedTags.take(limit).toList();
  }

  /// 태그 사용 빈도 업데이트
  void _updateTagUsage(String tagId) {
    final tagIndex = _allTags.indexWhere((tag) => tag.id == tagId);
    if (tagIndex != -1) {
      _allTags[tagIndex] = _allTags[tagIndex].copyWith(
        usageCount: _allTags[tagIndex].usageCount + 1,
      );
      _saveTags();
    }
  }

  /// 최근 사용 태그에 추가
  void _addToRecentTags(DiaryTag tag) {
    _recentTags.removeWhere((t) => t.id == tag.id);
    _recentTags.insert(0, tag);

    // 최대 10개까지만 유지
    if (_recentTags.length > 10) {
      _recentTags = _recentTags.take(10).toList();
    }

    _saveRecentTags();
  }

  /// 태그 데이터를 JSON으로 변환
  List<Map<String, dynamic>> toJson() {
    return _selectedTags.map((tag) => tag.toJson()).toList();
  }

  /// JSON에서 태그 데이터 복원
  void fromJson(List<Map<String, dynamic>> jsonList) {
    _selectedTags = jsonList.map((json) => DiaryTag.fromJson(json)).toList();
    notifyListeners();
  }

  /// 태그 저장
  Future<void> _saveTags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tagsJson = _allTags.map((tag) => tag.toJson()).toList();
      await prefs.setString(_tagsKey, jsonEncode(tagsJson));
    } catch (e) {
      Logger.error('태그 저장 실패: $e');
    }
  }

  /// 태그 로드
  Future<void> _loadTags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tagsString = prefs.getString(_tagsKey);
      if (tagsString != null) {
        final tagsJson = jsonDecode(tagsString) as List;
        _allTags = tagsJson
            .map((json) => DiaryTag.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      Logger.error('태그 로드 실패: $e');
    }
  }

  /// 최근 태그 저장
  Future<void> _saveRecentTags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentTagsJson = _recentTags.map((tag) => tag.toJson()).toList();
      await prefs.setString(_recentTagsKey, jsonEncode(recentTagsJson));
    } catch (e) {
      Logger.error('최근 태그 저장 실패: $e');
    }
  }

  /// 최근 태그 로드
  Future<void> _loadRecentTags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentTagsString = prefs.getString(_recentTagsKey);
      if (recentTagsString != null) {
        final recentTagsJson = jsonDecode(recentTagsString) as List;
        _recentTags = recentTagsJson
            .map((json) => DiaryTag.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      Logger.error('최근 태그 로드 실패: $e');
    }
  }

  /// 랜덤 색상 생성
  String _getRandomColor() {
    final colors = [
      '#FF6B6B',
      '#4ECDC4',
      '#45B7D1',
      '#96CEB4',
      '#FFEAA7',
      '#DDA0DD',
      '#98D8C8',
      '#F7DC6F',
      '#BB8FCE',
      '#85C1E9',
      '#F8C471',
      '#82E0AA',
      '#F1948A',
      '#85C1E9',
      '#D7BDE2',
    ];
    return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
  }
}

/// 일기 태그 모델
class DiaryTag {
  final String id;
  final String name;
  final String color;
  final String? description;
  final DateTime createdAt;
  final int usageCount;

  const DiaryTag({
    required this.id,
    required this.name,
    required this.color,
    this.description,
    required this.createdAt,
    this.usageCount = 0,
  });

  DiaryTag copyWith({
    String? id,
    String? name,
    String? color,
    String? description,
    DateTime? createdAt,
    int? usageCount,
  }) {
    return DiaryTag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'usageCount': usageCount,
    };
  }

  factory DiaryTag.fromJson(Map<String, dynamic> json) {
    return DiaryTag(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      usageCount: json['usageCount'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiaryTag && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DiaryTag(id: $id, name: $name)';
}


