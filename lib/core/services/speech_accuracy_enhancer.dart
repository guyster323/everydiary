import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 음성 인식 정확도 향상 서비스
class SpeechAccuracyEnhancer {
  static final SpeechAccuracyEnhancer _instance =
      SpeechAccuracyEnhancer._internal();
  factory SpeechAccuracyEnhancer() => _instance;
  SpeechAccuracyEnhancer._internal();

  // 사용자 단어 사전
  final Map<String, int> _userDictionary = {};
  final Map<String, List<String>> _contextPatterns = {};
  final Map<String, String> _correctionRules = {};

  // 자주 사용하는 단어/문구
  final Map<String, int> _frequentPhrases = {};
  final Map<String, List<String>> _similarWords = {};

  // 오인식 패턴 분석
  final Map<String, List<String>> _misrecognitionPatterns = {};

  bool _isInitialized = false;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadUserDictionary();
      await _loadContextPatterns();
      await _loadCorrectionRules();
      await _loadFrequentPhrases();
      await _loadMisrecognitionPatterns();

      _isInitialized = true;
      debugPrint('SpeechAccuracyEnhancer 초기화 완료');
    } catch (e) {
      debugPrint('SpeechAccuracyEnhancer 초기화 실패: $e');
    }
  }

  /// 음성 인식 결과를 문맥 기반으로 교정
  String enhanceRecognitionResult(String rawText, {String? context}) {
    if (!_isInitialized) {
      debugPrint('SpeechAccuracyEnhancer가 초기화되지 않음');
      return rawText;
    }

    String enhancedText = rawText;

    // 1. 사용자 사전 기반 교정
    enhancedText = _applyUserDictionary(enhancedText);

    // 2. 문맥 기반 교정
    enhancedText = _applyContextCorrection(enhancedText, context);

    // 3. 오인식 패턴 교정
    enhancedText = _applyMisrecognitionCorrection(enhancedText);

    // 4. 한국어 특화 교정
    enhancedText = _applyKoreanSpecificCorrection(enhancedText);

    // 5. 자주 사용하는 문구 교정
    enhancedText = _applyFrequentPhraseCorrection(enhancedText);

    // 6. 학습 데이터 업데이트
    _updateLearningData(rawText, enhancedText);

    debugPrint('음성 인식 정확도 향상: "$rawText" -> "$enhancedText"');
    return enhancedText;
  }

  /// 사용자 사전 기반 교정
  String _applyUserDictionary(String text) {
    final words = text.split(' ');
    final correctedWords = <String>[];

    for (final word in words) {
      if (_userDictionary.containsKey(word)) {
        // 사용자 사전에 있는 단어는 그대로 사용
        correctedWords.add(word);
      } else {
        // 비슷한 단어가 있는지 확인
        final similarWord = _findSimilarWord(word);
        if (similarWord != null) {
          correctedWords.add(similarWord);
        } else {
          correctedWords.add(word);
        }
      }
    }

    return correctedWords.join(' ');
  }

  /// 문맥 기반 교정
  String _applyContextCorrection(String text, String? context) {
    if (context == null) return text;

    // 문맥 패턴과 매칭되는 부분 찾기
    for (final pattern in _contextPatterns.keys) {
      if (text.contains(pattern)) {
        final corrections = _contextPatterns[pattern]!;
        // 가장 적절한 교정 선택 (간단한 휴리스틱)
        if (corrections.isNotEmpty) {
          text = text.replaceAll(pattern, corrections.first);
        }
      }
    }

    return text;
  }

  /// 오인식 패턴 교정
  String _applyMisrecognitionCorrection(String text) {
    for (final pattern in _misrecognitionPatterns.keys) {
      final corrections = _misrecognitionPatterns[pattern]!;
      for (final correction in corrections) {
        if (text.contains(pattern)) {
          text = text.replaceAll(pattern, correction);
        }
      }
    }
    return text;
  }

  /// 한국어 특화 교정
  String _applyKoreanSpecificCorrection(String text) {
    // 한국어 특화 교정 규칙 적용
    for (final rule in _correctionRules.entries) {
      text = text.replaceAll(rule.key, rule.value);
    }
    return text;
  }

  /// 자주 사용하는 문구 교정
  String _applyFrequentPhraseCorrection(String text) {
    // 자주 사용하는 문구와 매칭
    for (final phrase in _frequentPhrases.keys) {
      if (text.contains(phrase)) {
        // 문구의 사용 빈도 증가
        _frequentPhrases[phrase] = (_frequentPhrases[phrase] ?? 0) + 1;
      }
    }
    return text;
  }

  /// 비슷한 단어 찾기
  String? _findSimilarWord(String word) {
    if (_similarWords.containsKey(word)) {
      final similarList = _similarWords[word]!;
      if (similarList.isNotEmpty) {
        return similarList.first;
      }
    }
    return null;
  }

  /// 학습 데이터 업데이트
  void _updateLearningData(String originalText, String correctedText) {
    if (originalText != correctedText) {
      // 교정이 발생한 경우 학습 데이터 업데이트
      _addToUserDictionary(correctedText);
      _updateMisrecognitionPattern(originalText, correctedText);
    }
  }

  /// 사용자 사전에 단어 추가
  void _addToUserDictionary(String text) {
    final words = text.split(' ');
    for (final word in words) {
      if (word.isNotEmpty) {
        _userDictionary[word] = (_userDictionary[word] ?? 0) + 1;
      }
    }
  }

  /// 오인식 패턴 업데이트
  void _updateMisrecognitionPattern(String original, String corrected) {
    if (original != corrected) {
      if (!_misrecognitionPatterns.containsKey(original)) {
        _misrecognitionPatterns[original] = [];
      }
      if (!_misrecognitionPatterns[original]!.contains(corrected)) {
        _misrecognitionPatterns[original]!.add(corrected);
      }
    }
  }

  /// 사용자 사전에 단어 수동 추가
  Future<void> addToUserDictionary(String word) async {
    _userDictionary[word] = (_userDictionary[word] ?? 0) + 1;
    await _saveUserDictionary();
    debugPrint('사용자 사전에 단어 추가: $word');
  }

  /// 교정 규칙 수동 추가
  Future<void> addCorrectionRule(String pattern, String correction) async {
    _correctionRules[pattern] = correction;
    await _saveCorrectionRules();
    debugPrint('교정 규칙 추가: $pattern -> $correction');
  }

  /// 자주 사용하는 문구 추가
  Future<void> addFrequentPhrase(String phrase) async {
    _frequentPhrases[phrase] = (_frequentPhrases[phrase] ?? 0) + 1;
    await _saveFrequentPhrases();
    debugPrint('자주 사용하는 문구 추가: $phrase');
  }

  /// 정확도 통계 반환
  Map<String, dynamic> getAccuracyStats() {
    return {
      'userDictionarySize': _userDictionary.length,
      'correctionRulesCount': _correctionRules.length,
      'frequentPhrasesCount': _frequentPhrases.length,
      'misrecognitionPatternsCount': _misrecognitionPatterns.length,
      'isInitialized': _isInitialized,
    };
  }

  /// 사용자 사전 로드
  Future<void> _loadUserDictionary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('speech_user_dictionary');
      if (jsonString != null) {
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        _userDictionary.clear();
        data.forEach((key, value) {
          _userDictionary[key] = value as int;
        });
      }
    } catch (e) {
      debugPrint('사용자 사전 로드 실패: $e');
    }
  }

  /// 사용자 사전 저장
  Future<void> _saveUserDictionary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_userDictionary);
      await prefs.setString('speech_user_dictionary', jsonString);
    } catch (e) {
      debugPrint('사용자 사전 저장 실패: $e');
    }
  }

  /// 문맥 패턴 로드
  Future<void> _loadContextPatterns() async {
    // 기본 문맥 패턴 설정
    _contextPatterns['오늘'] = ['오늘은', '오늘의'];
    _contextPatterns['어제'] = ['어제는', '어제의'];
    _contextPatterns['내일'] = ['내일은', '내일의'];
    _contextPatterns['좋은'] = ['좋은 하루', '좋은 날'];
    _contextPatterns['나쁜'] = ['나쁜 하루', '나쁜 날'];
  }

  /// 교정 규칙 로드
  Future<void> _loadCorrectionRules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('speech_correction_rules');
      if (jsonString != null) {
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        _correctionRules.clear();
        data.forEach((key, value) {
          _correctionRules[key] = value as String;
        });
      } else {
        // 기본 교정 규칙 설정
        _initializeDefaultCorrectionRules();
      }
    } catch (e) {
      debugPrint('교정 규칙 로드 실패: $e');
      _initializeDefaultCorrectionRules();
    }
  }

  /// 기본 교정 규칙 초기화
  void _initializeDefaultCorrectionRules() {
    _correctionRules['을를'] = '을';
    _correctionRules['이가'] = '이';
    _correctionRules['은는'] = '은';
    _correctionRules['와과'] = '와';
    _correctionRules['에의'] = '에';
    _correctionRules['에서부터'] = '에서';
    _correctionRules['까지의'] = '까지';
  }

  /// 교정 규칙 저장
  Future<void> _saveCorrectionRules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_correctionRules);
      await prefs.setString('speech_correction_rules', jsonString);
    } catch (e) {
      debugPrint('교정 규칙 저장 실패: $e');
    }
  }

  /// 자주 사용하는 문구 로드
  Future<void> _loadFrequentPhrases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('speech_frequent_phrases');
      if (jsonString != null) {
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        _frequentPhrases.clear();
        data.forEach((key, value) {
          _frequentPhrases[key] = value as int;
        });
      }
    } catch (e) {
      debugPrint('자주 사용하는 문구 로드 실패: $e');
    }
  }

  /// 자주 사용하는 문구 저장
  Future<void> _saveFrequentPhrases() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_frequentPhrases);
      await prefs.setString('speech_frequent_phrases', jsonString);
    } catch (e) {
      debugPrint('자주 사용하는 문구 저장 실패: $e');
    }
  }

  /// 오인식 패턴 로드
  Future<void> _loadMisrecognitionPatterns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('speech_misrecognition_patterns');
      if (jsonString != null) {
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        _misrecognitionPatterns.clear();
        data.forEach((key, value) {
          _misrecognitionPatterns[key] = List<String>.from(value as List);
        });
      } else {
        // 기본 오인식 패턴 설정
        _initializeDefaultMisrecognitionPatterns();
      }
    } catch (e) {
      debugPrint('오인식 패턴 로드 실패: $e');
      _initializeDefaultMisrecognitionPatterns();
    }
  }

  /// 기본 오인식 패턴 초기화
  void _initializeDefaultMisrecognitionPatterns() {
    _misrecognitionPatterns['안녕하세요'] = ['안녕하세요', '안녕하셔요'];
    _misrecognitionPatterns['감사합니다'] = ['감사합니다', '감사해요'];
    _misrecognitionPatterns['죄송합니다'] = ['죄송합니다', '미안합니다'];
    _misrecognitionPatterns['좋은 하루'] = ['좋은 하루', '좋은 날'];
    _misrecognitionPatterns['나쁜 하루'] = ['나쁜 하루', '나쁜 날'];
  }

  /// 오인식 패턴 저장
  Future<void> _saveMisrecognitionPatterns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_misrecognitionPatterns);
      await prefs.setString('speech_misrecognition_patterns', jsonString);
    } catch (e) {
      debugPrint('오인식 패턴 저장 실패: $e');
    }
  }

  /// 모든 데이터 저장
  Future<void> saveAllData() async {
    await _saveUserDictionary();
    await _saveCorrectionRules();
    await _saveFrequentPhrases();
    await _saveMisrecognitionPatterns();
    debugPrint('모든 학습 데이터 저장 완료');
  }

  /// 학습 데이터 초기화
  Future<void> resetLearningData() async {
    _userDictionary.clear();
    _correctionRules.clear();
    _frequentPhrases.clear();
    _misrecognitionPatterns.clear();

    await saveAllData();
    debugPrint('학습 데이터 초기화 완료');
  }
}
