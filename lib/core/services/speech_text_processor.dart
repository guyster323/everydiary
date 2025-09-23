import 'package:flutter/foundation.dart';

import 'speech_accuracy_enhancer.dart';

/// 음성 인식 텍스트 후처리 서비스
class SpeechTextProcessor {
  static final SpeechTextProcessor _instance = SpeechTextProcessor._internal();
  factory SpeechTextProcessor() => _instance;
  SpeechTextProcessor._internal();

  /// 음성 인식 결과를 후처리하여 자연스러운 텍스트로 변환
  String processSpeechText(String rawText, {String? context}) {
    if (rawText.isEmpty) return rawText;

    String processedText = rawText;

    // 1. 기본 정리
    processedText = _cleanBasicText(processedText);

    // 2. 정확도 향상 알고리즘 적용
    processedText = _applyAccuracyEnhancement(processedText, context);

    // 3. 문장 부호 자동 추가
    processedText = _addPunctuation(processedText);

    // 4. 줄바꿈 처리
    processedText = _processLineBreaks(processedText);

    // 5. 한국어 특화 처리
    processedText = _processKoreanText(processedText);

    debugPrint('음성 인식 텍스트 후처리: "$rawText" -> "$processedText"');
    return processedText;
  }

  /// 정확도 향상 알고리즘 적용
  String _applyAccuracyEnhancement(String text, String? context) {
    try {
      final enhancer = SpeechAccuracyEnhancer();
      return enhancer.enhanceRecognitionResult(text, context: context);
    } catch (e) {
      debugPrint('정확도 향상 알고리즘 적용 실패: $e');
      return text;
    }
  }

  /// 기본 텍스트 정리
  String _cleanBasicText(String text) {
    // 앞뒤 공백 제거
    text = text.trim();

    // 연속된 공백을 하나로 통합
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    // 특수 문자 정리
    text = text.replaceAll(
      RegExp(
        r'[^\w\s가-힣.,!?;:()""'
        '-]',
      ),
      '',
    );

    return text;
  }

  /// 문장 부호 자동 추가
  String _addPunctuation(String text) {
    // 문장 끝에 마침표가 없으면 추가
    if (!text.endsWith('.') &&
        !text.endsWith('!') &&
        !text.endsWith('?') &&
        !text.endsWith(';') &&
        text.isNotEmpty) {
      text += '.';
    }

    // 문장 시작 부분의 대문자 처리 (한국어는 해당 없음)
    // 영어 문장의 경우 첫 글자를 대문자로
    if (RegExp(r'^[a-z]').hasMatch(text)) {
      text = text[0].toUpperCase() + text.substring(1);
    }

    return text;
  }

  /// 줄바꿈 처리
  String _processLineBreaks(String text) {
    // 긴 문장의 경우 적절한 위치에서 줄바꿈 추가
    if (text.length > 100) {
      // 쉼표나 마침표 뒤에서 줄바꿈 추가
      text = text.replaceAllMapped(
        RegExp(r'([.,!?;])\s+'),
        (match) => '${match.group(1)}\n',
      );
    }

    return text;
  }

  /// 한국어 특화 처리
  String _processKoreanText(String text) {
    // 한국어 조사 처리
    text = _processKoreanParticles(text);

    // 한국어 띄어쓰기 개선
    text = _improveKoreanSpacing(text);

    return text;
  }

  /// 한국어 조사 처리
  String _processKoreanParticles(String text) {
    // 자주 틀리는 조사 수정
    final particleCorrections = {
      '을를': '을',
      '이가': '이',
      '은는': '은',
      '와과': '와',
      '에의': '에',
    };

    for (final correction in particleCorrections.entries) {
      text = text.replaceAll(correction.key, correction.value);
    }

    return text;
  }

  /// 한국어 띄어쓰기 개선
  String _improveKoreanSpacing(String text) {
    // 조사와 어미는 앞 단어와 붙여쓰기
    text = text.replaceAll(RegExp(r'\s+([이가을를은는와과에의에서부터까지])\s+'), r'\1 ');

    // 어미는 앞 단어와 붙여쓰기
    text = text.replaceAll(RegExp(r'\s+([다요어아네지음임])\s+'), r'\1 ');

    return text;
  }

  /// 연속 음성 인식 결과를 하나의 텍스트로 병합
  String mergeContinuousResults(List<String> results) {
    if (results.isEmpty) return '';

    String mergedText = results.join(' ');

    // 중복된 단어나 구문 제거
    mergedText = _removeDuplicates(mergedText);

    // 최종 후처리
    return processSpeechText(mergedText);
  }

  /// 중복된 단어나 구문 제거
  String _removeDuplicates(String text) {
    // 연속된 동일한 단어 제거
    text = text.replaceAll(RegExp(r'\b(\w+)\s+\1\b'), r'\1');

    // 연속된 동일한 구문 제거 (2-3단어)
    text = text.replaceAll(RegExp(r'\b(\w+\s+\w+)\s+\1\b'), r'\1');

    return text;
  }

  /// 텍스트 품질 점수 계산 (0.0 ~ 1.0)
  double calculateTextQuality(String text) {
    if (text.isEmpty) return 0.0;

    double score = 1.0;

    // 길이 점수 (너무 짧거나 너무 길면 감점)
    if (text.length < 10) {
      score -= 0.3;
    } else if (text.length > 500) {
      score -= 0.2;
    }

    // 문장 부호 점수
    if (!text.endsWith('.') && !text.endsWith('!') && !text.endsWith('?')) {
      score -= 0.1;
    }

    // 띄어쓰기 점수
    final spaceCount = text.split(' ').length - 1;
    final wordCount = text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    if (wordCount > 0) {
      final spaceRatio = spaceCount / wordCount;
      if (spaceRatio < 0.5 || spaceRatio > 1.5) {
        score -= 0.1;
      }
    }

    // 특수 문자 점수
    final specialCharCount = text
        .split('')
        .where(
          (c) => RegExp(
            r'[^\w\s가-힣.,!?;:()""'
            '-]',
          ).hasMatch(c),
        )
        .length;
    if (specialCharCount > text.length * 0.1) {
      score -= 0.2;
    }

    return score.clamp(0.0, 1.0);
  }
}
