import 'dart:convert';

import 'package:flutter/foundation.dart';

/// 안전한 Delta JSON 변환 유틸리티
class SafeDeltaConverter {
  /// Delta JSON을 검증하고 정리합니다
  static String validateAndCleanDelta(String deltaJson) {
    if (deltaJson.isEmpty) {
      return '[{"insert":"\\n"}]';
    }

    // 이미 올바른 JSON 형식인지 확인
    try {
      final parsed = jsonDecode(deltaJson);
      if (parsed is List) {
        return deltaJson;
      }
    } catch (e) {
      // JSON이 아닌 경우 일반 텍스트로 처리
      debugPrint('Delta JSON 파싱 실패, 일반 텍스트로 변환: $e');
    }

    // 일반 텍스트를 Delta 형식으로 변환
    return _convertTextToDelta(deltaJson);
  }

  /// 일반 텍스트를 Delta JSON 형식으로 변환
  static String _convertTextToDelta(String text) {
    try {
      if (text.isEmpty) {
        return '[{"insert":"\\n"}]';
      }

      // 텍스트 정리 (특수 문자 처리)
      final cleanText = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

      // 텍스트를 줄바꿈으로 분할
      final lines = cleanText.split('\n');
      final deltaOps = <Map<String, dynamic>>[];

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];

        // 빈 줄 처리
        if (line.isEmpty) {
          deltaOps.add({'insert': '\\n'});
        } else {
          // 텍스트 줄 추가
          deltaOps.add({'insert': line});
          // 마지막 줄이 아니면 줄바꿈 추가
          if (i < lines.length - 1) {
            deltaOps.add({'insert': '\\n'});
          }
        }
      }

      // 마지막에 줄바꿈이 없으면 추가
      if (cleanText.isNotEmpty && !cleanText.endsWith('\n')) {
        deltaOps.add({'insert': '\\n'});
      }

      return jsonEncode(deltaOps);
    } catch (e) {
      debugPrint('텍스트를 Delta로 변환 실패: $e');
      debugPrint('문제가 된 텍스트: "$text"');
      return '[{"insert":"\\n"}]';
    }
  }

  /// Delta JSON에서 일반 텍스트 추출
  static String extractTextFromDelta(String deltaJson) {
    try {
      // 빈 문자열이나 null 체크
      if (deltaJson.isEmpty || deltaJson.trim().isEmpty) {
        return '';
      }

      // JSON 파싱 시도
      final deltaList = jsonDecode(deltaJson) as List<dynamic>;
      final textBuffer = StringBuffer();

      for (final op in deltaList) {
        if (op is Map<String, dynamic>) {
          final insert = op['insert'];
          if (insert is String) {
            // 줄바꿈 문자 처리
            if (insert == '\\n') {
              textBuffer.write('\n');
            } else {
              textBuffer.write(insert);
            }
          }
        }
      }

      return textBuffer.toString();
    } catch (e) {
      debugPrint('Delta JSON 파싱 실패: $e');
      debugPrint('문제가 된 Delta JSON: $deltaJson');

      // 실패 시 빈 문자열 반환 (원본 반환하면 안됨)
      return '';
    }
  }

  /// Delta JSON을 일반 텍스트로 변환 (alias)
  static String deltaToText(String deltaJson) {
    return extractTextFromDelta(deltaJson);
  }

  /// 일반 텍스트를 Delta JSON으로 변환
  static String textToDelta(String text) {
    return _convertTextToDelta(text);
  }
}
