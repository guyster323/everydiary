import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/logger.dart';
import '../../../shared/models/diary_entry.dart';

/// 공유 형식
enum ShareFormat {
  text, // 텍스트
  image, // 이미지
  pdf, // PDF
  markdown, // 마크다운
}

/// 일기 공유 서비스
class DiaryShareService {
  /// 텍스트로 공유
  Future<String> shareAsText(DiaryEntry diary) async {
    try {
      final buffer = StringBuffer();

      // 제목
      if (diary.title != null && diary.title!.isNotEmpty) {
        buffer.writeln(diary.title);
        buffer.writeln('=' * diary.title!.length);
        buffer.writeln();
      }

      // 날짜
      buffer.writeln('작성일: ${_formatDate(diary.createdAt)}');

      // 기분과 날씨
      if (diary.mood != null || diary.weather != null) {
        buffer.write('기분: ${diary.mood ?? '미설정'}');
        if (diary.weather != null) {
          buffer.write(' | 날씨: ${diary.weather}');
        }
        buffer.writeln();
        buffer.writeln();
      }

      // 내용
      final content = _extractTextFromDelta(diary.content);
      buffer.writeln(content);

      // 메타 정보
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln('단어 수: ${diary.wordCount}자');

      return buffer.toString();
    } catch (e) {
      Logger.error('텍스트 공유 생성 실패', tag: 'DiaryShareService', error: e);
      rethrow;
    }
  }

  /// 마크다운으로 공유
  Future<String> shareAsMarkdown(DiaryEntry diary) async {
    try {
      final buffer = StringBuffer();

      // 제목
      if (diary.title != null && diary.title!.isNotEmpty) {
        buffer.writeln('# ${diary.title}');
        buffer.writeln();
      }

      // 메타 정보
      buffer.writeln('**작성일:** ${_formatDate(diary.createdAt)}');

      if (diary.mood != null) {
        buffer.writeln('**기분:** ${diary.mood}');
      }

      if (diary.weather != null) {
        buffer.writeln('**날씨:** ${diary.weather}');
      }

      buffer.writeln();

      // 내용
      final content = _extractTextFromDelta(diary.content);
      buffer.writeln(content);

      // 태그
      if (diary.tags.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('**태그:**');
        for (final tag in diary.tags) {
          buffer.write('`${tag.name}` ');
        }
        buffer.writeln();
      }

      // 푸터
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln('*단어 수: ${diary.wordCount}자*');

      return buffer.toString();
    } catch (e) {
      Logger.error('마크다운 공유 생성 실패', tag: 'DiaryShareService', error: e);
      rethrow;
    }
  }

  /// 이미지로 공유 (일기 내용을 이미지로 변환)
  Future<File> shareAsImage(DiaryEntry diary) async {
    try {
      // 향후 실제 이미지 생성 로직 구현 예정
      // 현재는 임시 파일 생성
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/diary_${diary.id}_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      // 임시 파일 생성 (실제로는 일기 내용을 이미지로 렌더링)
      await file.writeAsString('Image placeholder for diary ${diary.id}');

      Logger.info('이미지 공유 생성: ${file.path}', tag: 'DiaryShareService');
      return file;
    } catch (e) {
      Logger.error('이미지 공유 생성 실패', tag: 'DiaryShareService', error: e);
      rethrow;
    }
  }

  /// PDF로 공유
  Future<File> shareAsPdf(DiaryEntry diary) async {
    try {
      // 향후 실제 PDF 생성 로직 구현 예정
      // 현재는 임시 파일 생성
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/diary_${diary.id}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      // 임시 파일 생성 (실제로는 일기 내용을 PDF로 변환)
      await file.writeAsString('PDF placeholder for diary ${diary.id}');

      Logger.info('PDF 공유 생성: ${file.path}', tag: 'DiaryShareService');
      return file;
    } catch (e) {
      Logger.error('PDF 공유 생성 실패', tag: 'DiaryShareService', error: e);
      rethrow;
    }
  }

  /// 시스템 공유 시트 열기
  Future<void> shareDiary(DiaryEntry diary, ShareFormat format) async {
    try {
      String? text;
      File? file;

      switch (format) {
        case ShareFormat.text:
          text = await shareAsText(diary);
          break;
        case ShareFormat.markdown:
          text = await shareAsMarkdown(diary);
          break;
        case ShareFormat.image:
          file = await shareAsImage(diary);
          break;
        case ShareFormat.pdf:
          file = await shareAsPdf(diary);
          break;
      }

      if (file != null) {
        // 파일 공유
        await _shareFile(file);
      } else if (text != null) {
        // 텍스트 공유
        await _shareText(text);
      }

      Logger.info('일기 공유 완료: 형식 $format', tag: 'DiaryShareService');
    } catch (e) {
      Logger.error('일기 공유 실패', tag: 'DiaryShareService', error: e);
      rethrow;
    }
  }

  /// 텍스트 공유
  Future<void> _shareText(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      Logger.info('텍스트가 클립보드에 복사되었습니다', tag: 'DiaryShareService');
    } catch (e) {
      Logger.error('텍스트 공유 실패', tag: 'DiaryShareService', error: e);
      rethrow;
    }
  }

  /// 파일 공유
  Future<void> _shareFile(File file) async {
    try {
      // 향후 실제 파일 공유 로직 구현 예정
      // 현재는 파일 경로만 로그
      Logger.info('파일 공유: ${file.path}', tag: 'DiaryShareService');
    } catch (e) {
      Logger.error('파일 공유 실패', tag: 'DiaryShareService', error: e);
      rethrow;
    }
  }

  /// 공유 가능한 형식 목록
  List<ShareFormat> getAvailableFormats() {
    return ShareFormat.values;
  }

  /// 형식 이름 가져오기
  String getFormatName(ShareFormat format) {
    switch (format) {
      case ShareFormat.text:
        return '텍스트';
      case ShareFormat.markdown:
        return '마크다운';
      case ShareFormat.image:
        return '이미지';
      case ShareFormat.pdf:
        return 'PDF';
    }
  }

  /// 형식 설명 가져오기
  String getFormatDescription(ShareFormat format) {
    switch (format) {
      case ShareFormat.text:
        return '일기 내용을 일반 텍스트로 공유합니다';
      case ShareFormat.markdown:
        return '일기 내용을 마크다운 형식으로 공유합니다';
      case ShareFormat.image:
        return '일기 내용을 이미지로 변환하여 공유합니다';
      case ShareFormat.pdf:
        return '일기 내용을 PDF 문서로 공유합니다';
    }
  }

  /// 날짜 포맷팅
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}년 ${date.month}월 ${date.day}일';
    } catch (e) {
      return dateString;
    }
  }

  /// Delta JSON에서 텍스트 추출
  String _extractTextFromDelta(String deltaJson) {
    try {
      if (deltaJson.isEmpty || deltaJson == '[]') return '';

      // 간단한 텍스트 추출 (실제로는 Delta JSON 파싱 필요)
      return deltaJson
          .replaceAll(RegExp(r'[^\w\s가-힣]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    } catch (e) {
      return deltaJson;
    }
  }
}
