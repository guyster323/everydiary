import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/utils/logger.dart';

/// 폼 유효성 검증 서비스
class FormValidationService extends ChangeNotifier {
  final Map<String, String> _errors = {};
  bool _isValidating = false;

  Map<String, String> get errors => Map.unmodifiable(_errors);
  bool get isValidating => _isValidating;
  bool get hasErrors => _errors.isNotEmpty;
  bool get isValid => _errors.isEmpty;

  /// 유효성 검증 시작
  void startValidation() {
    _isValidating = true;
    notifyListeners();
  }

  /// 유효성 검증 완료
  void finishValidation() {
    _isValidating = false;
    notifyListeners();
  }

  /// 에러 설정
  void setError(String field, String message) {
    _errors[field] = message;
    notifyListeners();
    Logger.warning('폼 검증 에러 [$field]: $message');
  }

  /// 에러 제거
  void clearError(String field) {
    if (_errors.containsKey(field)) {
      _errors.remove(field);
      notifyListeners();
    }
  }

  /// 모든 에러 제거
  void clearAllErrors() {
    _errors.clear();
    notifyListeners();
  }

  /// 특정 필드 에러 확인
  bool hasError(String field) => _errors.containsKey(field);

  /// 특정 필드 에러 메시지 가져오기
  String? getError(String field) => _errors[field];

  /// 제목 유효성 검증
  String? validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return '제목을 입력해주세요';
    }

    if (title.trim().length < 2) {
      return '제목은 최소 2자 이상이어야 합니다';
    }

    if (title.trim().length > 100) {
      return '제목은 최대 100자까지 입력 가능합니다';
    }

    // 특수문자 제한 (기본적인 텍스트만 허용)
    final RegExp titleRegex = RegExp(r'^[가-힣a-zA-Z0-9\s\-_.,!?]+$');
    if (!titleRegex.hasMatch(title.trim())) {
      return '제목에 사용할 수 없는 문자가 포함되어 있습니다';
    }

    return null;
  }

  /// 내용 유효성 검증
  String? validateContent(String? contentDelta) {
    if (contentDelta == null || contentDelta.trim().isEmpty) {
      return '내용을 입력해주세요';
    }

    // Delta JSON 형식 검증
    try {
      // 빈 Delta JSON인지 확인
      if (contentDelta.trim() == '[]' || contentDelta.trim() == '{}') {
        return '내용을 입력해주세요';
      }

      // JSON 파싱 가능한지 확인
      final dynamic parsed = jsonDecode(contentDelta);
      if (parsed is! List) {
        return '내용 형식이 올바르지 않습니다';
      }

      // 실제 텍스트 내용이 있는지 확인
      if (parsed.isEmpty) {
        return '내용을 입력해주세요';
      }

      // Delta 구조 검증
      for (final item in parsed) {
        if (item is! Map<String, dynamic>) {
          return '내용 형식이 올바르지 않습니다';
        }

        if (!item.containsKey('insert')) {
          return '내용 형식이 올바르지 않습니다';
        }
      }
    } catch (e) {
      return '내용 형식이 올바르지 않습니다';
    }

    return null;
  }

  /// 날짜 유효성 검증
  String? validateDate(DateTime? date) {
    if (date == null) {
      return '날짜를 선택해주세요';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    // 미래 날짜 체크
    if (selectedDate.isAfter(today)) {
      return '미래 날짜는 선택할 수 없습니다';
    }

    // 너무 오래된 날짜 체크 (예: 10년 전)
    final tenYearsAgo = DateTime(today.year - 10, today.month, today.day);
    if (selectedDate.isBefore(tenYearsAgo)) {
      return '너무 오래된 날짜입니다';
    }

    return null;
  }

  /// 기분 유효성 검증
  String? validateMood(String? mood) {
    // 기분은 선택사항이므로 null이어도 유효
    if (mood == null || mood.trim().isEmpty) {
      return null;
    }

    // 유효한 기분 옵션인지 확인
    const validMoods = [
      '행복',
      '슬픔',
      '화남',
      '걱정',
      '평온',
      '흥분',
      '피곤',
      '스트레스',
      '감사',
      '실망',
      '놀람',
      '두려움',
      '기쁨',
      '우울',
      '분노',
      '안정',
      '불안',
      '만족',
      '후회',
      '기대',
      '지루함',
      '사랑',
      '미움',
      '기타',
    ];

    if (!validMoods.contains(mood.trim())) {
      return '유효하지 않은 기분입니다';
    }

    return null;
  }

  /// 날씨 유효성 검증
  String? validateWeather(String? weather) {
    // 날씨는 선택사항이므로 null이어도 유효
    if (weather == null || weather.trim().isEmpty) {
      return null;
    }

    // 유효한 날씨 옵션인지 확인
    const validWeathers = [
      '맑음',
      '흐림',
      '비',
      '눈',
      '바람',
      '폭우',
      '폭설',
      '안개',
      '뇌우',
      '황사',
      '폭염',
      '한파',
      '기타',
    ];

    if (!validWeathers.contains(weather.trim())) {
      return '유효하지 않은 날씨입니다';
    }

    return null;
  }

  /// 이미지 유효성 검증
  String? validateImages(List<dynamic>? images) {
    // 이미지는 선택사항이므로 null이어도 유효
    if (images == null || images.isEmpty) {
      return null;
    }

    // 이미지 개수 제한
    if (images.length > 10) {
      return '이미지는 최대 10개까지 첨부할 수 있습니다';
    }

    // 각 이미지 유효성 검증
    for (int i = 0; i < images.length; i++) {
      final image = images[i];
      if (image is! Map<String, dynamic>) {
        return '이미지 정보가 올바르지 않습니다';
      }

      if (!image.containsKey('id') || !image.containsKey('fileName')) {
        return '이미지 정보가 올바르지 않습니다';
      }

      // 파일명 유효성 검증
      final fileName = image['fileName'] as String?;
      if (fileName == null || fileName.trim().isEmpty) {
        return '이미지 파일명이 올바르지 않습니다';
      }

      // 파일 확장자 검증
      final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
      final hasValidExtension = validExtensions.any(
        (ext) => fileName.toLowerCase().endsWith(ext),
      );

      if (!hasValidExtension) {
        return '지원하지 않는 이미지 형식입니다';
      }
    }

    return null;
  }

  /// 태그 유효성 검증
  String? validateTags(List<dynamic>? tags) {
    // 태그는 선택사항이므로 null이어도 유효
    if (tags == null || tags.isEmpty) {
      return null;
    }

    // 태그 개수 제한
    if (tags.length > 20) {
      return '태그는 최대 20개까지 선택할 수 있습니다';
    }

    // 각 태그 유효성 검증
    for (int i = 0; i < tags.length; i++) {
      final tag = tags[i];
      if (tag is! Map<String, dynamic>) {
        return '태그 정보가 올바르지 않습니다';
      }

      if (!tag.containsKey('id') || !tag.containsKey('name')) {
        return '태그 정보가 올바르지 않습니다';
      }

      // 태그명 유효성 검증
      final tagName = tag['name'] as String?;
      if (tagName == null || tagName.trim().isEmpty) {
        return '태그명이 올바르지 않습니다';
      }

      if (tagName.trim().length > 20) {
        return '태그명은 최대 20자까지 가능합니다';
      }
    }

    return null;
  }

  /// 전체 폼 유효성 검증
  Map<String, String> validateForm({
    String? title,
    String? content,
    DateTime? date,
    String? mood,
    String? weather,
    List<dynamic>? images,
    List<dynamic>? tags,
  }) {
    clearAllErrors();
    startValidation();

    try {
      // 제목 검증
      final titleError = validateTitle(title);
      if (titleError != null) {
        setError('title', titleError);
      }

      // 내용 검증
      final contentError = validateContent(content);
      if (contentError != null) {
        setError('content', contentError);
      }

      // 날짜 검증
      final dateError = validateDate(date);
      if (dateError != null) {
        setError('date', dateError);
      }

      // 기분 검증
      final moodError = validateMood(mood);
      if (moodError != null) {
        setError('mood', moodError);
      }

      // 날씨 검증
      final weatherError = validateWeather(weather);
      if (weatherError != null) {
        setError('weather', weatherError);
      }

      // 이미지 검증
      final imagesError = validateImages(images);
      if (imagesError != null) {
        setError('images', imagesError);
      }

      // 태그 검증
      final tagsError = validateTags(tags);
      if (tagsError != null) {
        setError('tags', tagsError);
      }
    } finally {
      finishValidation();
    }

    return Map.unmodifiable(_errors);
  }

  /// 특정 필드만 검증
  String? validateField(String fieldName, dynamic value) {
    switch (fieldName) {
      case 'title':
        return validateTitle(value as String?);
      case 'content':
        return validateContent(value as String?);
      case 'date':
        return validateDate(value as DateTime?);
      case 'mood':
        return validateMood(value as String?);
      case 'weather':
        return validateWeather(value as String?);
      case 'images':
        return validateImages(value as List<dynamic>?);
      case 'tags':
        return validateTags(value as List<dynamic>?);
      default:
        return '알 수 없는 필드입니다';
    }
  }

  /// 실시간 필드 검증 (사용자 입력 중)
  void validateFieldRealtime(String fieldName, dynamic value) {
    final error = validateField(fieldName, value);

    if (error != null) {
      setError(fieldName, error);
    } else {
      clearError(fieldName);
    }
  }

  /// 에러 메시지 포맷팅
  String getFormattedErrors() {
    if (_errors.isEmpty) return '';

    final errorMessages = _errors.entries
        .map((entry) => '• ${entry.value}')
        .join('\n');

    return '다음 오류를 수정해주세요:\n$errorMessages';
  }

  /// 첫 번째 에러 메시지 가져오기
  String? getFirstError() {
    if (_errors.isEmpty) return null;
    return _errors.values.first;
  }

  @override
  void dispose() {
    _errors.clear();
    super.dispose();
  }
}
