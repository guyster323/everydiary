import 'package:flutter/material.dart';

/// 앱 다국어 지원 클래스
/// Flutter의 국제화 시스템을 사용하여 다국어 지원을 제공합니다.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// 현재 로케일에 해당하는 AppLocalizations 인스턴스를 반환
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// 지원되는 로케일 목록
  static const List<Locale> supportedLocales = [
    Locale('ko', 'KR'), // 한국어
    Locale('en', 'US'), // 영어
    Locale('ja', 'JP'), // 일본어
    Locale('zh', 'CN'), // 중국어 (간체)
    Locale('zh', 'TW'), // 중국어 (번체)
    Locale('es', 'ES'), // 스페인어
    Locale('fr', 'FR'), // 프랑스어
    Locale('de', 'DE'), // 독일어
    Locale('ru', 'RU'), // 러시아어
    Locale('ar', 'SA'), // 아랍어
  ];

  /// 로케일별 리소스 번들
  static const Map<String, Map<String, String>> _localizedValues = {
    'ko': {
      // 공통
      'app_title': 'EveryDiary',
      'ok': '확인',
      'cancel': '취소',
      'save': '저장',
      'delete': '삭제',
      'edit': '편집',
      'add': '추가',
      'search': '검색',
      'loading': '로딩 중...',
      'error': '오류',
      'success': '성공',
      'warning': '경고',
      'info': '정보',

      // 네비게이션
      'nav_diary': '일기',
      'nav_calendar': '캘린더',
      'nav_settings': '설정',
      'nav_profile': '프로필',

      // 일기 관련
      'diary_title': '일기',
      'diary_new': '새 일기',
      'diary_edit': '일기 편집',
      'diary_delete': '일기 삭제',
      'diary_save': '일기 저장',
      'diary_content': '내용',
      'diary_date': '날짜',
      'diary_mood': '기분',
      'diary_weather': '날씨',
      'diary_tags': '태그',
      'diary_voice_note': '음성 메모',
      'diary_image': '이미지',

      // 캘린더 관련
      'calendar_title': '캘린더',
      'calendar_today': '오늘',
      'calendar_month': '월',
      'calendar_year': '년',
      'calendar_week': '주',
      'calendar_day': '일',

      // 설정 관련
      'settings_title': '설정',
      'settings_theme': '테마',
      'settings_language': '언어',
      'settings_font_size': '글자 크기',
      'settings_notifications': '알림',
      'settings_privacy': '개인정보',
      'settings_backup': '백업',
      'settings_about': '정보',
      'settings_theme_light': '라이트',
      'settings_theme_dark': '다크',
      'settings_theme_system': '시스템',
      'settings_font_small': '작게',
      'settings_font_medium': '보통',
      'settings_font_large': '크게',
      'settings_font_extra_large': '매우 크게',

      // 프로필 관련
      'profile_title': '프로필',
      'profile_edit': '프로필 편집',
      'profile_name': '이름',
      'profile_email': '이메일',
      'profile_bio': '소개',
      'profile_avatar': '프로필 사진',
      'profile_stats': '통계',
      'profile_total_diaries': '총 일기 수',
      'profile_consecutive_days': '연속 일기',
      'profile_total_words': '총 단어 수',

      // 접근성
      'accessibility_high_contrast': '고대비',
      'accessibility_text_to_speech': '텍스트 음성 변환',
      'accessibility_large_text': '큰 글씨',
      'accessibility_screen_reader': '화면 읽기',
      'accessibility_voice_commands': '음성 명령',
      'accessibility_keyboard_navigation': '키보드 탐색',

      // 오류 메시지
      'error_network': '네트워크 연결을 확인해주세요',
      'error_save_failed': '저장에 실패했습니다',
      'error_load_failed': '로드에 실패했습니다',
      'error_delete_failed': '삭제에 실패했습니다',
      'error_permission_denied': '권한이 거부되었습니다',
      'error_file_not_found': '파일을 찾을 수 없습니다',
      'error_invalid_format': '잘못된 형식입니다',

      // 성공 메시지
      'success_saved': '저장되었습니다',
      'success_deleted': '삭제되었습니다',
      'success_updated': '업데이트되었습니다',
      'success_backed_up': '백업되었습니다',
      'success_restored': '복원되었습니다',
    },
    'en': {
      // Common
      'app_title': 'EveryDiary',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'info': 'Info',

      // Navigation
      'nav_diary': 'Diary',
      'nav_calendar': 'Calendar',
      'nav_settings': 'Settings',
      'nav_profile': 'Profile',

      // Diary related
      'diary_title': 'Diary',
      'diary_new': 'New Diary',
      'diary_edit': 'Edit Diary',
      'diary_delete': 'Delete Diary',
      'diary_save': 'Save Diary',
      'diary_content': 'Content',
      'diary_date': 'Date',
      'diary_mood': 'Mood',
      'diary_weather': 'Weather',
      'diary_tags': 'Tags',
      'diary_voice_note': 'Voice Note',
      'diary_image': 'Image',

      // Calendar related
      'calendar_title': 'Calendar',
      'calendar_today': 'Today',
      'calendar_month': 'Month',
      'calendar_year': 'Year',
      'calendar_week': 'Week',
      'calendar_day': 'Day',

      // Settings related
      'settings_title': 'Settings',
      'settings_theme': 'Theme',
      'settings_language': 'Language',
      'settings_font_size': 'Font Size',
      'settings_notifications': 'Notifications',
      'settings_privacy': 'Privacy',
      'settings_backup': 'Backup',
      'settings_about': 'About',
      'settings_theme_light': 'Light',
      'settings_theme_dark': 'Dark',
      'settings_theme_system': 'System',
      'settings_font_small': 'Small',
      'settings_font_medium': 'Medium',
      'settings_font_large': 'Large',
      'settings_font_extra_large': 'Extra Large',

      // Profile related
      'profile_title': 'Profile',
      'profile_edit': 'Edit Profile',
      'profile_name': 'Name',
      'profile_email': 'Email',
      'profile_bio': 'Bio',
      'profile_avatar': 'Avatar',
      'profile_stats': 'Statistics',
      'profile_total_diaries': 'Total Diaries',
      'profile_consecutive_days': 'Consecutive Days',
      'profile_total_words': 'Total Words',

      // Accessibility
      'accessibility_high_contrast': 'High Contrast',
      'accessibility_text_to_speech': 'Text to Speech',
      'accessibility_large_text': 'Large Text',
      'accessibility_screen_reader': 'Screen Reader',
      'accessibility_voice_commands': 'Voice Commands',
      'accessibility_keyboard_navigation': 'Keyboard Navigation',

      // Error messages
      'error_network': 'Please check your network connection',
      'error_save_failed': 'Failed to save',
      'error_load_failed': 'Failed to load',
      'error_delete_failed': 'Failed to delete',
      'error_permission_denied': 'Permission denied',
      'error_file_not_found': 'File not found',
      'error_invalid_format': 'Invalid format',

      // Success messages
      'success_saved': 'Saved successfully',
      'success_deleted': 'Deleted successfully',
      'success_updated': 'Updated successfully',
      'success_backed_up': 'Backed up successfully',
      'success_restored': 'Restored successfully',
    },
    'ja': {
      // 共通
      'app_title': 'EveryDiary',
      'ok': 'OK',
      'cancel': 'キャンセル',
      'save': '保存',
      'delete': '削除',
      'edit': '編集',
      'add': '追加',
      'search': '検索',
      'loading': '読み込み中...',
      'error': 'エラー',
      'success': '成功',
      'warning': '警告',
      'info': '情報',

      // ナビゲーション
      'nav_diary': '日記',
      'nav_calendar': 'カレンダー',
      'nav_settings': '設定',
      'nav_profile': 'プロフィール',

      // 日記関連
      'diary_title': '日記',
      'diary_new': '新しい日記',
      'diary_edit': '日記を編集',
      'diary_delete': '日記を削除',
      'diary_save': '日記を保存',
      'diary_content': '内容',
      'diary_date': '日付',
      'diary_mood': '気分',
      'diary_weather': '天気',
      'diary_tags': 'タグ',
      'diary_voice_note': '音声メモ',
      'diary_image': '画像',

      // カレンダー関連
      'calendar_title': 'カレンダー',
      'calendar_today': '今日',
      'calendar_month': '月',
      'calendar_year': '年',
      'calendar_week': '週',
      'calendar_day': '日',

      // 設定関連
      'settings_title': '設定',
      'settings_theme': 'テーマ',
      'settings_language': '言語',
      'settings_font_size': 'フォントサイズ',
      'settings_notifications': '通知',
      'settings_privacy': 'プライバシー',
      'settings_backup': 'バックアップ',
      'settings_about': '情報',
      'settings_theme_light': 'ライト',
      'settings_theme_dark': 'ダーク',
      'settings_theme_system': 'システム',
      'settings_font_small': '小',
      'settings_font_medium': '中',
      'settings_font_large': '大',
      'settings_font_extra_large': '特大',

      // プロフィール関連
      'profile_title': 'プロフィール',
      'profile_edit': 'プロフィールを編集',
      'profile_name': '名前',
      'profile_email': 'メール',
      'profile_bio': '自己紹介',
      'profile_avatar': 'アバター',
      'profile_stats': '統計',
      'profile_total_diaries': '総日記数',
      'profile_consecutive_days': '連続日数',
      'profile_total_words': '総単語数',

      // アクセシビリティ
      'accessibility_high_contrast': '高コントラスト',
      'accessibility_text_to_speech': 'テキスト読み上げ',
      'accessibility_large_text': '大きな文字',
      'accessibility_screen_reader': 'スクリーンリーダー',
      'accessibility_voice_commands': '音声コマンド',
      'accessibility_keyboard_navigation': 'キーボードナビゲーション',

      // エラーメッセージ
      'error_network': 'ネットワーク接続を確認してください',
      'error_save_failed': '保存に失敗しました',
      'error_load_failed': '読み込みに失敗しました',
      'error_delete_failed': '削除に失敗しました',
      'error_permission_denied': '権限が拒否されました',
      'error_file_not_found': 'ファイルが見つかりません',
      'error_invalid_format': '無効な形式です',

      // 成功メッセージ
      'success_saved': '保存されました',
      'success_deleted': '削除されました',
      'success_updated': '更新されました',
      'success_backed_up': 'バックアップされました',
      'success_restored': '復元されました',
    },
  };

  /// 특정 키에 대한 번역된 문자열을 반환
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  /// 현재 로케일이 RTL(오른쪽에서 왼쪽) 언어인지 확인
  bool get isRTL {
    return locale.languageCode == 'ar' ||
        locale.languageCode == 'he' ||
        locale.languageCode == 'fa';
  }

  /// 현재 로케일의 언어 이름을 반환
  String get languageName {
    switch (locale.languageCode) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      case 'zh':
        return locale.countryCode == 'TW' ? '繁體中文' : '简体中文';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'ru':
        return 'Русский';
      case 'ar':
        return 'العربية';
      default:
        return 'Unknown';
    }
  }

  /// 현재 로케일의 날짜 형식을 반환
  String get dateFormat {
    switch (locale.languageCode) {
      case 'ko':
        return 'yyyy년 MM월 dd일';
      case 'ja':
        return 'yyyy年MM月dd日';
      case 'zh':
        return 'yyyy年MM月dd日';
      case 'en':
        return 'MMM dd, yyyy';
      case 'es':
        return 'dd/MM/yyyy';
      case 'fr':
        return 'dd/MM/yyyy';
      case 'de':
        return 'dd.MM.yyyy';
      case 'ru':
        return 'dd.MM.yyyy';
      case 'ar':
        return 'dd/MM/yyyy';
      default:
        return 'yyyy-MM-dd';
    }
  }

  /// 현재 로케일의 시간 형식을 반환
  String get timeFormat {
    switch (locale.languageCode) {
      case 'ko':
        return 'HH:mm';
      case 'ja':
        return 'HH:mm';
      case 'zh':
        return 'HH:mm';
      case 'en':
        return 'h:mm a';
      case 'es':
        return 'HH:mm';
      case 'fr':
        return 'HH:mm';
      case 'de':
        return 'HH:mm';
      case 'ru':
        return 'HH:mm';
      case 'ar':
        return 'HH:mm';
      default:
        return 'HH:mm';
    }
  }

  /// 현재 로케일의 숫자 형식을 반환
  String get numberFormat {
    switch (locale.languageCode) {
      case 'ko':
        return '#,##0';
      case 'ja':
        return '#,##0';
      case 'zh':
        return '#,##0';
      case 'en':
        return '#,##0';
      case 'es':
        return '#,##0';
      case 'fr':
        return '# ##0';
      case 'de':
        return '#.##0';
      case 'ru':
        return '# ##0';
      case 'ar':
        return '#,##0';
      default:
        return '#,##0';
    }
  }
}

/// AppLocalizationsDelegate
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
