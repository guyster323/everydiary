import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 사용자 피드백 타입
enum FeedbackType {
  recognitionAccuracy, // 인식 정확도
  processingSpeed, // 처리 속도
  userExperience, // 사용자 경험
  featureRequest, // 기능 요청
  bugReport, // 버그 리포트
}

/// 피드백 중요도
enum FeedbackPriority { low, medium, high, critical }

/// 사용자 피드백 데이터
class UserFeedback {
  final String id;
  final FeedbackType type;
  final FeedbackPriority priority;
  final String title;
  final String description;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  final String? userId;
  final bool isResolved;

  const UserFeedback({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.metadata,
    required this.timestamp,
    this.userId,
    this.isResolved = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'priority': priority.name,
    'title': title,
    'description': description,
    'metadata': metadata,
    'timestamp': timestamp.toIso8601String(),
    'userId': userId,
    'isResolved': isResolved,
  };

  factory UserFeedback.fromJson(Map<String, dynamic> json) {
    return UserFeedback(
      id: json['id'] as String,
      type: FeedbackType.values.firstWhere((e) => e.name == json['type']),
      priority: FeedbackPriority.values.firstWhere(
        (e) => e.name == json['priority'],
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String?,
      isResolved: json['isResolved'] as bool? ?? false,
    );
  }

  UserFeedback copyWith({
    String? id,
    FeedbackType? type,
    FeedbackPriority? priority,
    String? title,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    String? userId,
    bool? isResolved,
  }) {
    return UserFeedback(
      id: id ?? this.id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}

/// 음성 인식 피드백 서비스
class SpeechFeedbackService {
  static final SpeechFeedbackService _instance =
      SpeechFeedbackService._internal();

  factory SpeechFeedbackService() => _instance;

  SpeechFeedbackService._internal();

  final List<UserFeedback> _feedbacks = [];
  final StreamController<UserFeedback> _feedbackController =
      StreamController<UserFeedback>.broadcast();

  bool _isInitialized = false;
  String? _currentUserId;

  // 피드백 수집 설정
  static const int _maxLocalFeedbacks = 100;

  List<UserFeedback> get feedbacks => List.unmodifiable(_feedbacks);
  Stream<UserFeedback> get feedbackStream => _feedbackController.stream;
  bool get isInitialized => _isInitialized;

  /// 서비스 초기화
  Future<void> initialize({String? userId}) async {
    if (_isInitialized) return;

    debugPrint('SpeechFeedbackService 초기화 시작');

    _currentUserId = userId;
    await _loadFeedbacks();

    _isInitialized = true;
    debugPrint('SpeechFeedbackService 초기화 완료 - 피드백 ${_feedbacks.length}개');
  }

  /// 피드백 제출
  Future<String> submitFeedback({
    required FeedbackType type,
    required FeedbackPriority priority,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    final feedback = UserFeedback(
      id: _generateFeedbackId(),
      type: type,
      priority: priority,
      title: title,
      description: description,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
      userId: _currentUserId,
    );

    _addFeedback(feedback);
    await _saveFeedbacks();

    debugPrint('피드백 제출: ${feedback.title} (${feedback.type.name})');
    return feedback.id;
  }

  /// 인식 정확도 피드백
  Future<String> submitAccuracyFeedback({
    required String recognizedText,
    required String expectedText,
    required double confidence,
    required bool isCorrect,
    String? context,
  }) async {
    final metadata = {
      'recognizedText': recognizedText,
      'expectedText': expectedText,
      'confidence': confidence,
      'isCorrect': isCorrect,
      'context': context,
      'deviceInfo': await _getDeviceInfo(),
    };

    return await submitFeedback(
      type: FeedbackType.recognitionAccuracy,
      priority: isCorrect ? FeedbackPriority.low : FeedbackPriority.medium,
      title: '음성 인식 정확도 피드백',
      description: isCorrect
          ? '인식이 정확했습니다'
          : '인식이 부정확했습니다. 예상: "$expectedText", 인식: "$recognizedText"',
      metadata: metadata,
    );
  }

  /// 처리 속도 피드백
  Future<String> submitSpeedFeedback({
    required Duration processingTime,
    required String operation,
    required bool isAcceptable,
  }) async {
    final metadata = {
      'processingTime': processingTime.inMilliseconds,
      'operation': operation,
      'isAcceptable': isAcceptable,
      'deviceInfo': await _getDeviceInfo(),
    };

    return await submitFeedback(
      type: FeedbackType.processingSpeed,
      priority: isAcceptable ? FeedbackPriority.low : FeedbackPriority.medium,
      title: '처리 속도 피드백',
      description: isAcceptable
          ? '처리 속도가 적절했습니다 (${processingTime.inMilliseconds}ms)'
          : '처리 속도가 느렸습니다 (${processingTime.inMilliseconds}ms)',
      metadata: metadata,
    );
  }

  /// 사용자 경험 피드백
  Future<String> submitExperienceFeedback({
    required String experience,
    required int rating, // 1-5
    String? suggestion,
  }) async {
    final metadata = {
      'experience': experience,
      'rating': rating,
      'suggestion': suggestion,
      'deviceInfo': await _getDeviceInfo(),
    };

    final priority = rating <= 2
        ? FeedbackPriority.high
        : rating == 3
        ? FeedbackPriority.medium
        : FeedbackPriority.low;

    return await submitFeedback(
      type: FeedbackType.userExperience,
      priority: priority,
      title: '사용자 경험 피드백',
      description: '평점: $rating/5 - $experience',
      metadata: metadata,
    );
  }

  /// 기능 요청
  Future<String> submitFeatureRequest({
    required String feature,
    required String description,
    required FeedbackPriority priority,
  }) async {
    final metadata = {
      'feature': feature,
      'description': description,
      'deviceInfo': await _getDeviceInfo(),
    };

    return await submitFeedback(
      type: FeedbackType.featureRequest,
      priority: priority,
      title: '기능 요청: $feature',
      description: description,
      metadata: metadata,
    );
  }

  /// 버그 리포트
  Future<String> submitBugReport({
    required String bug,
    required String steps,
    required String expectedResult,
    required String actualResult,
    Map<String, dynamic>? additionalInfo,
  }) async {
    final metadata = {
      'bug': bug,
      'steps': steps,
      'expectedResult': expectedResult,
      'actualResult': actualResult,
      'additionalInfo': additionalInfo ?? {},
      'deviceInfo': await _getDeviceInfo(),
    };

    return await submitFeedback(
      type: FeedbackType.bugReport,
      priority: FeedbackPriority.high,
      title: '버그 리포트: $bug',
      description: '예상: $expectedResult, 실제: $actualResult',
      metadata: metadata,
    );
  }

  /// 피드백 추가
  void _addFeedback(UserFeedback feedback) {
    _feedbacks.insert(0, feedback);

    // 로컬 저장소 크기 제한
    if (_feedbacks.length > _maxLocalFeedbacks) {
      _feedbacks.removeRange(_maxLocalFeedbacks, _feedbacks.length);
    }

    _feedbackController.add(feedback);
  }

  /// 피드백 ID 생성
  String _generateFeedbackId() {
    return 'feedback_${DateTime.now().millisecondsSinceEpoch}_${_feedbacks.length}';
  }

  /// 피드백 저장
  Future<void> _saveFeedbacks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedbacksJson = jsonEncode(
        _feedbacks.map((feedback) => feedback.toJson()).toList(),
      );
      await prefs.setString('speech_feedbacks', feedbacksJson);
    } catch (e) {
      debugPrint('피드백 저장 실패: $e');
    }
  }

  /// 피드백 로드
  Future<void> _loadFeedbacks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedbacksJson = prefs.getString('speech_feedbacks');

      if (feedbacksJson != null) {
        final List<dynamic> feedbacksList =
            jsonDecode(feedbacksJson) as List<dynamic>;
        _feedbacks.clear();
        _feedbacks.addAll(
          feedbacksList.map(
            (json) => UserFeedback.fromJson(json as Map<String, dynamic>),
          ),
        );
        debugPrint('피드백 로드 완료: ${_feedbacks.length}개');
      }
    } catch (e) {
      debugPrint('피드백 로드 실패: $e');
    }
  }

  /// 디바이스 정보 수집
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    // 실제 구현에서는 디바이스 정보를 수집
    return {
      'platform': defaultTargetPlatform.name,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 피드백 통계
  Map<String, dynamic> getFeedbackStats() {
    if (_feedbacks.isEmpty) {
      return {'message': '수집된 피드백이 없습니다'};
    }

    final typeStats = <String, int>{};
    final priorityStats = <String, int>{};
    int resolvedCount = 0;

    for (final feedback in _feedbacks) {
      typeStats[feedback.type.name] = (typeStats[feedback.type.name] ?? 0) + 1;
      priorityStats[feedback.priority.name] =
          (priorityStats[feedback.priority.name] ?? 0) + 1;
      if (feedback.isResolved) resolvedCount++;
    }

    return {
      'totalFeedbacks': _feedbacks.length,
      'resolvedFeedbacks': resolvedCount,
      'unresolvedFeedbacks': _feedbacks.length - resolvedCount,
      'typeStats': typeStats,
      'priorityStats': priorityStats,
      'latestFeedback': _feedbacks.isNotEmpty
          ? _feedbacks.first.timestamp
          : null,
    };
  }

  /// 피드백 해결 표시
  Future<void> markAsResolved(String feedbackId) async {
    final index = _feedbacks.indexWhere((f) => f.id == feedbackId);
    if (index != -1) {
      _feedbacks[index] = _feedbacks[index].copyWith(isResolved: true);
      await _saveFeedbacks();
      debugPrint('피드백 해결 표시: $feedbackId');
    }
  }

  /// 피드백 삭제
  Future<void> deleteFeedback(String feedbackId) async {
    _feedbacks.removeWhere((f) => f.id == feedbackId);
    await _saveFeedbacks();
    debugPrint('피드백 삭제: $feedbackId');
  }

  /// 모든 피드백 삭제
  Future<void> clearAllFeedbacks() async {
    _feedbacks.clear();
    await _saveFeedbacks();
    debugPrint('모든 피드백 삭제');
  }

  /// 피드백 내보내기
  Future<String> exportFeedbacks() async {
    final feedbacksJson = jsonEncode(
      _feedbacks.map((feedback) => feedback.toJson()).toList(),
    );
    return feedbacksJson;
  }

  /// 서비스 종료
  void dispose() {
    _feedbackController.close();
  }
}
