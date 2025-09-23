import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';

/// 자동 저장 상태 열거형
enum AutoSaveStatus {
  idle, // 대기 중
  saving, // 저장 중
  saved, // 저장 완료
  error, // 오류 발생
}

/// 자동 저장 서비스
class AutoSaveService extends ChangeNotifier {
  static const String _autoSaveKey = 'diary_auto_save';
  static const String _lastSaveTimeKey = 'diary_last_save_time';

  Timer? _saveTimer;
  Timer? _debounceTimer;

  AutoSaveStatus _status = AutoSaveStatus.idle;
  String? _lastError;
  DateTime? _lastSaveTime;

  // 자동 저장 설정
  static const Duration _autoSaveInterval = Duration(seconds: 30);
  static const Duration _debounceDelay = Duration(seconds: 3);

  AutoSaveStatus get status => _status;
  String? get lastError => _lastError;
  DateTime? get lastSaveTime => _lastSaveTime;

  /// 자동 저장 시작
  void startAutoSave() {
    _stopAutoSave();
    _saveTimer = Timer.periodic(_autoSaveInterval, (_) => _performAutoSave());
    Logger.info('자동 저장 시작됨');
  }

  /// 자동 저장 중지
  void stopAutoSave() {
    _stopAutoSave();
    Logger.info('자동 저장 중지됨');
  }

  void _stopAutoSave() {
    _saveTimer?.cancel();
    _saveTimer = null;
  }

  /// 사용자 입력 후 지연 저장 (디바운스)
  void scheduleDebouncedSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, _performAutoSave);
  }

  /// 자동 저장 수행
  Future<void> _performAutoSave() async {
    if (_status == AutoSaveStatus.saving) {
      return; // 이미 저장 중이면 건너뛰기
    }

    try {
      _setStatus(AutoSaveStatus.saving);

      // SharedPreferences에서 임시 저장된 데이터 가져오기
      final prefs = await SharedPreferences.getInstance();
      final autoSaveData = prefs.getString(_autoSaveKey);

      if (autoSaveData == null || autoSaveData.isEmpty) {
        _setStatus(AutoSaveStatus.idle);
        return; // 저장할 데이터가 없음
      }

      // 임시 저장된 데이터 파싱
      final data = jsonDecode(autoSaveData) as Map<String, dynamic>;

      // 향후 실제 데이터베이스에 저장하는 로직 구현 예정
      // 현재는 임시 저장만 수행 (이미 SharedPreferences에 저장되어 있음)
      await _saveToDatabase(data);

      // 저장 시간 업데이트
      _lastSaveTime = DateTime.now();
      await prefs.setString(_lastSaveTimeKey, _lastSaveTime!.toIso8601String());

      _setStatus(AutoSaveStatus.saved);
      Logger.info('자동 저장 완료: $_lastSaveTime');

      // 2초 후 상태를 idle로 변경
      Timer(const Duration(seconds: 2), () {
        if (_status == AutoSaveStatus.saved) {
          _setStatus(AutoSaveStatus.idle);
        }
      });
    } catch (e) {
      _setStatus(AutoSaveStatus.error, error: e.toString());
      Logger.error('자동 저장 실패: $e');

      // 3초 후 에러 상태를 idle로 변경
      Timer(const Duration(seconds: 3), () {
        if (_status == AutoSaveStatus.error) {
          _setStatus(AutoSaveStatus.idle);
        }
      });
    }
  }

  /// 데이터베이스에 저장 (임시 구현)
  Future<void> _saveToDatabase(Map<String, dynamic> data) async {
    // 향후 실제 데이터베이스 저장 로직 구현 예정
    // 현재는 지연만 시뮬레이션
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  /// 임시 저장 (로컬 스토리지)
  Future<void> saveTemporary(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data);
      await prefs.setString(_autoSaveKey, jsonString);
      Logger.debug('임시 저장 완료');
    } catch (e) {
      Logger.error('임시 저장 실패: $e');
    }
  }

  /// 임시 저장된 데이터 복원
  Future<Map<String, dynamic>?> restoreTemporary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final autoSaveData = prefs.getString(_autoSaveKey);

      if (autoSaveData == null || autoSaveData.isEmpty) {
        return null;
      }

      final data = jsonDecode(autoSaveData) as Map<String, dynamic>;
      Logger.info('임시 저장된 데이터 복원됨');
      return data;
    } catch (e) {
      Logger.error('임시 저장 데이터 복원 실패: $e');
      return null;
    }
  }

  /// 임시 저장 데이터 삭제
  Future<void> clearTemporary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_autoSaveKey);
      await prefs.remove(_lastSaveTimeKey);
      _lastSaveTime = null;
      _setStatus(AutoSaveStatus.idle);
      Logger.info('임시 저장 데이터 삭제됨');
    } catch (e) {
      Logger.error('임시 저장 데이터 삭제 실패: $e');
    }
  }

  /// 마지막 저장 시간 로드
  Future<void> loadLastSaveTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSaveTimeString = prefs.getString(_lastSaveTimeKey);

      if (lastSaveTimeString != null) {
        _lastSaveTime = DateTime.parse(lastSaveTimeString);
        notifyListeners();
      }
    } catch (e) {
      Logger.error('마지막 저장 시간 로드 실패: $e');
    }
  }

  void _setStatus(AutoSaveStatus status, {String? error}) {
    _status = status;
    _lastError = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopAutoSave();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
