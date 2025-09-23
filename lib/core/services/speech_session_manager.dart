import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../shared/services/database_service.dart';
import 'speech_text_processor.dart';

/// 음성 인식 세션 모델
class SpeechSession {
  final String id;
  final DateTime? startTime;
  final DateTime? endTime;
  final Duration? totalDuration;
  final List<SpeechTextBlock>? textBlocks;

  SpeechSession({
    required this.id,
    this.startTime,
    this.endTime,
    this.totalDuration,
    this.textBlocks,
  });
}

/// 음성 텍스트 블록 모델
class SpeechTextBlock {
  final String text;
  final double confidence;
  final DateTime? timestamp;

  SpeechTextBlock({
    required this.text,
    required this.confidence,
    this.timestamp,
  });
}

/// 음성 인식 세션 관리자
class SpeechSessionManager {
  static final SpeechSessionManager _instance =
      SpeechSessionManager._internal();
  factory SpeechSessionManager() => _instance;
  SpeechSessionManager._internal();

  final List<String> _sessionResults = [];
  final StreamController<List<String>> _sessionController =
      StreamController<List<String>>.broadcast();

  Timer? _sessionTimer;
  DateTime? _sessionStartTime;
  bool _isSessionActive = false;

  // 현재 세션 관련 변수들
  String? _currentSessionId;
  SpeechSession? _currentSession;

  /// 세션 결과 스트림
  Stream<List<String>> get sessionStream => _sessionController.stream;

  /// 현재 세션 결과들
  List<String> get currentResults => List.unmodifiable(_sessionResults);

  /// 세션 활성 상태
  bool get isSessionActive => _isSessionActive;

  /// 세션 시작 시간
  DateTime? get sessionStartTime => _sessionStartTime;

  /// 세션 지속 시간
  Duration? get sessionDuration {
    if (_sessionStartTime == null) return null;
    return DateTime.now().difference(_sessionStartTime!);
  }

  /// 새 세션 시작
  void startSession() {
    if (_isSessionActive) return;

    _sessionResults.clear();
    _sessionStartTime = DateTime.now();
    _isSessionActive = true;

    // 세션 타임아웃 설정 (10분)
    _sessionTimer = Timer(const Duration(minutes: 10), () {
      endSession();
    });

    debugPrint('음성 인식 세션 시작');
    _sessionController.add(_sessionResults);
  }

  /// 세션에 결과 추가
  void addResult(String result) {
    if (!_isSessionActive) return;

    if (result.isNotEmpty) {
      _sessionResults.add(result);
      debugPrint('세션에 결과 추가: $result (총 ${_sessionResults.length}개)');
      _sessionController.add(_sessionResults);
    }
  }

  /// 세션 종료
  void endSession() {
    if (!_isSessionActive) return;

    _isSessionActive = false;
    _sessionTimer?.cancel();
    _sessionTimer = null;

    debugPrint('음성 인식 세션 종료 (총 ${_sessionResults.length}개 결과)');
    _sessionController.add(_sessionResults);
  }

  /// 세션 초기화
  void clearSession() {
    _sessionResults.clear();
    _sessionStartTime = null;
    _isSessionActive = false;
    _sessionTimer?.cancel();
    _sessionTimer = null;

    debugPrint('음성 인식 세션 초기화');
    _sessionController.add(_sessionResults);
  }

  /// 세션 결과를 하나의 텍스트로 병합
  String getMergedText() {
    if (_sessionResults.isEmpty) return '';

    return SpeechTextProcessor().mergeContinuousResults(_sessionResults);
  }

  /// 세션 통계 정보
  Map<String, dynamic> getSessionStats() {
    final duration = sessionDuration;
    final wordCount = _sessionResults
        .join(' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;

    return {
      'resultCount': _sessionResults.length,
      'wordCount': wordCount,
      'duration': duration?.inSeconds ?? 0,
      'averageWordsPerMinute': duration != null && duration.inMinutes > 0
          ? (wordCount / duration.inMinutes).round()
          : 0,
      'isActive': _isSessionActive,
    };
  }

  /// 세션 품질 점수 계산
  double getSessionQualityScore() {
    if (_sessionResults.isEmpty) return 0.0;

    final mergedText = getMergedText();
    return SpeechTextProcessor().calculateTextQuality(mergedText);
  }

  /// 세션 결과를 파일로 저장
  Future<void> saveSessionToFile(String filePath) async {
    try {
      final file = File(filePath);
      final sessionData = {
        'session_id': _currentSessionId,
        'start_time': _currentSession?.startTime?.toIso8601String(),
        'end_time': _currentSession?.endTime?.toIso8601String(),
        'total_duration': _currentSession?.totalDuration?.inSeconds,
        'text_blocks': _currentSession?.textBlocks
            ?.map(
              (block) => {
                'text': block.text,
                'confidence': block.confidence,
                'timestamp': block.timestamp?.toIso8601String(),
              },
            )
            .toList(),
        'created_at': DateTime.now().toIso8601String(),
      };

      await file.writeAsString(jsonEncode(sessionData));
      debugPrint('세션 결과를 파일로 저장 완료: $filePath');
    } catch (e) {
      debugPrint('세션 결과 파일 저장 실패: $e');
    }
  }

  /// 세션 결과를 데이터베이스에 저장
  Future<void> saveSessionToDatabase() async {
    try {
      if (_currentSession == null) return;

      final databaseService = DatabaseService();
      final db = await databaseService.database;

      await db.insert('speech_sessions', {
        'session_id': _currentSessionId,
        'start_time': _currentSession!.startTime?.toIso8601String(),
        'end_time': _currentSession!.endTime?.toIso8601String(),
        'total_duration': _currentSession!.totalDuration?.inSeconds,
        'text_blocks_count': _currentSession!.textBlocks?.length ?? 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('세션 결과를 데이터베이스에 저장 완료');
    } catch (e) {
      debugPrint('세션 결과 데이터베이스 저장 실패: $e');
    }
  }

  /// 세션 히스토리 관리
  Future<List<Map<String, dynamic>>> getSessionHistory() async {
    try {
      final databaseService = DatabaseService();
      final db = await databaseService.database;

      final sessions = await db.query(
        'speech_sessions',
        orderBy: 'created_at DESC',
        limit: 50, // 최근 50개 세션만
      );

      return sessions;
    } catch (e) {
      debugPrint('세션 히스토리 조회 실패: $e');
      return [];
    }
  }

  void dispose() {
    _sessionController.close();
    _sessionTimer?.cancel();
  }
}
