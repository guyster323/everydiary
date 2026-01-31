import '../../../features/settings/models/settings_enums.dart';

/// 앱 다국어 지원 클래스
/// 각 언어별 번역 문자열을 제공합니다
class AppLocalizations {
  final Language language;

  AppLocalizations(this.language);

  /// 현재 언어에 해당하는 번역 문자열 가져오기
  String get(String key) {
    return _translations[language]?[key] ?? _translations[Language.korean]?[key] ?? key;
  }

  /// 모든 언어별 번역 문자열
  static final Map<Language, Map<String, String>> _translations = {
    // 한국어
    Language.korean: _korean,
    // 영어
    Language.english: _english,
    // 일본어
    Language.japanese: _japanese,
    // 중국어 (간체)
    Language.chineseSimplified: _chineseSimplified,
    // 중국어 (번체)
    Language.chineseTraditional: _chineseTraditional,
  };

  // ============== 한국어 ==============
  static const Map<String, String> _korean = {
    // 공통
    'app_name': 'EveryDiary',
    'ok': '확인',
    'confirm': '확인',
    'cancel': '취소',
    'save': '저장',
    'delete': '삭제',
    'edit': '수정',
    'close': '닫기',
    'yes': '예',
    'no': '아니오',
    'dont_show_again': '다시 보지 않기',

    // 새 스타일 안내 팝업
    'new_style_announcement_title': '새로운 스타일이 추가되었어요!',
    'new_style_announcement_description': '색연필로 그린 동화책 느낌의 일러스트 스타일을 사용해보세요.\n설정에서 변경할 수 있어요.',

    // AdMob 정책 공지
    'ad_policy_notice_title': '서비스 안내',
    'ad_policy_notice_message': 'AdMob 정책 검토로 인해 광고 시청 기능이 일시적으로 제한됩니다. 1월 30일까지 매일 무료 AI 이미지 생성 횟수가 2회로 초기화되며, 정책 검토 완료 후 정상화될 예정입니다.',
    'ad_policy_notice_count_info': '매일 무료 AI 이미지 생성: 2회 (자동 초기화)',

    // 설정
    'settings': '설정',
    'settings_reset': '설정 초기화',
    'app_settings': '앱 설정',
    'thumbnail_style': '썸네일 스타일',
    'thumbnail_style_subtitle': 'AI 썸네일 스타일과 키워드를 설정합니다',
    'theme': '테마',
    'font_size': '폰트 크기',
    'language': '언어',
    'language_select': '언어 선택',
    'security_management': 'EveryDiary 보안 및 관리',
    'username': '사용자 이름',
    'username_not_set': '설정되지 않음',
    'pin_lock': 'PIN 잠금',
    'pin_lock_enabled': '앱 실행 시 PIN 요구',
    'pin_lock_disabled': '사용 안 함',
    'pin_change': 'PIN 변경',
    'pin_change_subtitle': '현재 PIN을 입력하고 새 PIN으로 변경합니다',
    'recovery_question': '비상 복구 질문',
    'recovery_question_set': '설정됨',
    'recovery_question_not_set': '설정되지 않음',

    // PIN 관련
    'pin_setup': 'PIN 잠금 설정',
    'pin_new': '새 PIN (4자리 숫자)',
    'pin_confirm': 'PIN 확인',
    'pin_current': '현재 PIN',
    'pin_change_title': 'PIN 변경',
    'pin_disable': 'PIN 잠금 해제',
    'pin_disable_message': 'PIN 잠금을 비활성화하면 앱 실행 시 인증이 필요하지 않습니다.',
    'pin_disable_button': '비활성화',
    'pin_error_length': '4자리 숫자를 입력해 주세요',
    'pin_error_mismatch': 'PIN이 일치하지 않습니다',
    'pin_error_new_mismatch': '새 PIN이 일치하지 않습니다',
    'pin_enabled_message': 'PIN 잠금이 활성화되었습니다.',
    'pin_disabled_message': 'PIN 잠금이 비활성화되었습니다.',
    'pin_changed_message': 'PIN이 변경되었습니다.',
    'pin_change_failed': 'PIN 변경에 실패했습니다',

    // PIN 잠금 해제 화면
    'pin_unlock_title': '잠금 해제',
    'pin_unlock_subtitle': '앱에 다시 접속하려면 4자리 PIN을 입력해 주세요.',
    'pin_unlock_button': '잠금 해제',
    'pin_unlock_clear': '지우기',
    'pin_unlock_recovery': '비상 복구',
    'pin_unlock_error_length': '4자리 PIN을 입력해 주세요',
    'pin_unlock_error_incorrect': 'PIN이 일치하지 않습니다. 다시 시도해 주세요.',
    'pin_unlock_error_locked': '너무 많은 시도로 잠금되었습니다.',
    'pin_unlock_locked_until': '잠금됨: {time}까지 시도할 수 없어요.',
    'pin_unlock_remaining_attempts': '남은 시도 횟수: {count}회',
    'pin_unlock_unlocked': '잠금 해제됨',
    'pin_unlock_time_minutes': '{minutes}분 {seconds}초',
    'pin_unlock_time_seconds': '{seconds}초',
    'pin_unlock_recovery_warning_title': '⚠️ 비상 복구 질문 미설정',
    'pin_unlock_recovery_warning_message': 'PIN을 잊으면 앱에 접근할 수 없습니다.\n설정에서 비상 복구 질문을 등록하세요.',

    // 복구 질문
    'recovery_question_setup': '비상 복구 질문 설정',
    'recovery_question_label': '보안 질문',
    'recovery_question_hint': '예: 나만 아는 장소는?',
    'recovery_answer': '답변',
    'recovery_answer_confirm': '답변 확인',
    'recovery_question_error_empty': '보안 질문을 입력해 주세요',
    'recovery_answer_error_empty': '답변을 입력해 주세요',
    'recovery_answer_error_mismatch': '답변이 일치하지 않습니다',
    'recovery_question_saved': '비상 복구 질문이 저장되었습니다.',
    'recovery_question_deleted': '비상 복구 질문이 삭제되었습니다.',
    'recovery_question_delete': '삭제',

    // PIN 복구 다이얼로그
    'pin_recovery_title': '비상 복구',
    'pin_recovery_question_label': '보안 질문',
    'pin_recovery_answer_input': '답변 입력',
    'pin_recovery_new_pin': '새 PIN (4자리)',
    'pin_recovery_confirm_pin': '새 PIN 확인',
    'pin_recovery_error_answer_empty': '보안 질문 답변을 입력해 주세요',
    'pin_recovery_error_pin_length': '4자리 숫자 PIN을 입력해 주세요',
    'pin_recovery_error_pin_mismatch': '새 PIN이 일치하지 않습니다',
    'pin_recovery_success': '새 PIN이 설정되었습니다.',
    'pin_recovery_failed': '복구에 실패했습니다: {error}',

    // 사용자 이름
    'username_change': '사용자 이름 변경',
    'username_label': '이름',
    'username_hint': '예: 홍길동',
    'username_error_empty': '이름을 입력해 주세요',
    'username_updated': '사용자 이름이 업데이트되었습니다.',

    // 테마
    'theme_system': '시스템 설정',
    'theme_light': '라이트 모드',
    'theme_dark': '다크 모드',

    // 폰트 크기
    'font_small': '작게',
    'font_medium': '보통',
    'font_large': '크게',
    'font_extra_large': '매우 크게',

    // 인트로 영상
    'show_intro_video': '앱 시작 시 인트로 영상',
    'show_intro_video_subtitle': '앱을 실행할 때 인트로 영상을 표시합니다',

    // 이미지 생성
    'image_generation_count': 'AI 이미지 생성 횟수',
    'image_generation_description': 'AI가 생성하는 멋진 일기 이미지를 더 많이 만들어보세요!',
    'watch_ad_for_1_time': '광고 보고 1회 더 받기',
    'watch_ad_subtitle': '짧은 광고 시청으로 무료로 받으세요',
    'ad_loading': '광고 준비 중...',
    'ad_wait': '잠시만 기다려주세요',
    'ad_reward_success': '광고 시청 완료! 2회 생성 횟수가 추가되었습니다.',

    // 회상 (Memory)
    'memory_type_all': '전체',
    'memory_type_yesterday': '어제',
    'memory_type_one_week_ago': '일주일 전',
    'memory_type_one_month_ago': '한달 전',
    'memory_type_one_year_ago': '1년 전',
    'memory_type_past_today': '과거의 오늘',
    'memory_type_same_time': '같은 시간',
    'memory_type_seasonal': '계절별',
    'memory_type_special_date': '특별한 날',
    'memory_type_similar_tags': '관련 태그',
    'memory_reason_yesterday': '어제의 기록',
    'memory_reason_one_week_ago': '일주일 전의 기록',
    'memory_reason_one_month_ago': '한달 전의 기록',
    'memory_reason_one_year_ago': '1년 전의 기록',
    'memory_reason_past_today': '과거 이날의 기록',
    'memory_reason_same_time': '이 시간의 기록',
    'memory_reason_seasonal': '계절의 기록',
    'memory_reason_special_date': '특별한 날의 기록',
    'memory_reason_similar_tags': '비슷한 태그의 기록',
    'memory_bookmark': '북마크',
    'memory_bookmark_remove': '북마크 해제',

    // OCR
    'ocr_camera_title': '사진 촬영',
    'ocr_auto_detect': '자동 감지',
    'ocr_language_korean': '한국어',
    'ocr_language_english': 'English',
    'ocr_language_japanese': '日本語',
    'ocr_language_chinese': '中文',

    // 음성 인식 (Speech Recognition)
    'speech_language_korean': '한국어',
    'speech_language_english': 'English',
    'speech_language_japanese': '日本語',
    'speech_language_chinese': '中文',
    'speech_initializing': '음성 인식을 초기화하고 있습니다...',
    'speech_ready': '마이크 버튼을 눌러 음성 인식을 시작하세요',
    'speech_listening': '말씀해 주세요. 완료되면 다시 버튼을 눌러주세요',
    'speech_processing': '음성을 텍스트로 변환하고 있습니다...',
    'speech_completed': '음성 인식이 완료되었습니다',
    'speech_error': '음성 인식 중 오류가 발생했습니다. 다시 시도해 주세요',
    'speech_cancelled': '음성 인식이 취소되었습니다',
    'speech_error_title': '음성 인식 오류',
    'speech_cancel': '취소',
    'speech_retry': '다시 시도',
    'speech_error_solutions': '해결 방법:',
    'speech_error_check_permission': '• 마이크 권한이 허용되었는지 확인하세요',
    'speech_error_check_internet': '• 인터넷 연결을 확인하세요',
    'speech_error_quiet_environment': '• 조용한 환경에서 다시 시도해 보세요',
    'speech_error_check_microphone': '• 마이크가 정상 작동하는지 확인하세요',
    'speech_permission_title': '마이크 권한 필요',
    'speech_permission_description': '음성 인식 기능을 사용하려면 마이크 권한이 필요합니다.',
    'speech_permission_usage': '이 권한은 다음 목적으로만 사용됩니다:',
    'speech_permission_convert': '• 음성을 텍스트로 변환',
    'speech_permission_diary': '• 일기 작성 시 음성 입력',
    'speech_permission_accuracy': '• 음성 인식 정확도 향상',
    'speech_permission_deny': '거부',
    'speech_permission_allow': '허용',
    'speech_init_failed': '음성 인식 서비스 초기화에 실패했습니다.',
    'speech_init_error': '초기화 중 오류가 발생했습니다',
    'speech_permission_required': '마이크 권한이 필요합니다.',
    'speech_start_failed': '음성 인식 시작에 실패했습니다.',
    'speech_start_error': '음성 인식 시작 중 오류가 발생했습니다',
    'speech_stop_error': '음성 인식 중지 중 오류가 발생했습니다',
    'speech_cancel_error': '음성 인식 취소 중 오류가 발생했습니다',

    // 음성 녹음 (Voice Recording)
    'voice_recording_title': '음성녹음',
    'voice_recording_init_failed': '음성인식 서비스를 초기화할 수 없습니다.',
    'voice_recording_start_failed': '음성녹음을 시작할 수 없습니다.',
    'voice_recording_recording': '녹음 중...',
    'voice_recording_paused': '일시정지 중',
    'voice_recording_resume_prompt': '녹음을 재개하세요',
    'voice_recording_start_prompt': '녹음을 시작하세요',
    'voice_recording_recognized_text': '인식된 텍스트:',
    'voice_recording_stop': '녹음 중지',
    'voice_recording_resume': '녹음 재개',
    'voice_recording_start': '녹음 시작',
    'voice_recording_cancel': '취소',
    'voice_recording_confirm': '확인',

    // 권한 요청 (Permission Request)
    'permission_request_title': '권한 설정',
    'permission_request_subtitle': '앱 기능을 사용하기 위해 다음 권한이 필요합니다',
    'permission_camera_title': '카메라 권한',
    'permission_camera_description': 'OCR 텍스트 인식 기능을 사용하기 위해 카메라 접근 권한이 필요합니다.',
    'permission_microphone_title': '마이크 권한',
    'permission_microphone_description': '음성으로 일기를 작성하기 위해 마이크 접근 권한이 필요합니다.',
    'permission_allow_all': '모두 허용',
    'permission_skip': '나중에 설정',
    'permission_continue': '계속하기',
    'permission_granted': '허용됨',
    'permission_denied': '거부됨',
    'permission_open_settings': '설정으로 이동',
    'permission_required_features': '일부 기능에 권한이 필요합니다',
    'permission_camera_rationale': '사진을 촬영하여 텍스트를 인식하려면 카메라 권한이 필요합니다.',
    'permission_microphone_rationale': '음성으로 일기를 작성하려면 마이크 권한이 필요합니다.',
    'permission_settings_guide': '권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.',

    // 날짜 표시
    'date_today': '오늘',
    'date_yesterday': '어제',

    // 알림
    'notifications': '알림',
    'daily_reminder': '일기 작성 알림',
    'daily_reminder_subtitle': '매일 일기 작성을 알려드립니다',
    'reminder_time': '알림 시간',

    // 데이터 관리
    'data_management': '데이터 관리',

    // 정보
    'info': '정보',
    'app_version': '앱 버전',
    'privacy_policy': '개인정보 처리방침',
    'privacy_policy_subtitle': '개인정보 보호 정책을 확인하세요',
    'terms_of_service': '이용약관',
    'terms_of_service_subtitle': '서비스 이용약관을 확인하세요',
    'app_description': '매일의 소중한 순간을 AI가 그린 아름다운 이미지와 함께 기록하세요.',
    'app_developer': '개발자: EveryDiary',
    'app_contact': '문의: window98se@gmail.com',

    // 버전 1.0.3 변경사항
    'version_1_0_3_title': 'v1.0.3 업데이트 내용',
    'version_1_0_3_change_1': 'Android 15 화면 표시 호환성 개선',
    'version_1_0_3_change_2': '회상 알림 시간 지정 기능 수정',
    'version_1_0_3_change_3': 'OCR 카메라 화질 개선 (기기 기본 카메라 사용)',
    'version_1_0_3_change_4': '게임 캐릭터 썸네일 스타일 추가 (픽셀 아트)',
    'version_1_0_3_change_5': 'UI 간소화 및 안정성 개선',

    // 버전 1.0.4 변경사항
    'version_1_0_4_title': 'v1.0.4 업데이트 내용',
    'version_1_0_4_change_1': '일기 작성 폰트 색상 개선으로 가독성 향상',
    'version_1_0_4_change_2': '새로운 "산타와 함께" 썸네일 스타일 추가',
    'version_1_0_4_change_3': '썸네일 스타일 선택기 3열 그리드 UI 개편',
    'version_1_0_4_change_4': '일기 작성 페이지 썸네일 스타일 버튼 추가',
    'version_1_0_4_change_5': '광고 보상 1회 → 2회 증가',
    'version_1_0_4_change_6': 'Android 15 edge-to-edge 호환성 개선',

    // 성별 관련
    'user_gender': '성별',
    'select_gender': '성별 선택',
    'gender_male': '남성',
    'gender_female': '여성',
    'gender_none': '선택 안함',

    // 색연필 스타일
    'style_color_pencil': '색연필',

    // 털실인형 스타일
    'style_felted_wool': '털실인형',

    // 3D 애니메이션 스타일
    'style_3d_animation': '3D 애니메이션',

    // 새로운 스타일 알림 팝업
    'new_styles_popup_title': '새로운 스타일 추가!',
    'new_styles_popup_message': '털실인형과 3D 애니메이션 스타일이 추가되었습니다. 설정에서 확인해 보세요!',
    'new_styles_popup_dont_show': '다시 보지 않기',
    'new_styles_popup_check': '확인하기',

    // 버전 1.1.1 변경사항
    'version_1_1_1_title': 'v1.1.1 업데이트 내용',
    'version_1_1_1_change_1': '새로운 썸네일 스타일 추가: 털실인형',
    'version_1_1_1_change_2': '새로운 썸네일 스타일 추가: 3D 애니메이션',

    // 버전 1.1.0 변경사항
    'version_1_1_0_title': 'v1.1.0 업데이트 내용',
    'version_1_1_0_change_1': '사용자 성별 설정 추가 (AI 이미지 반영)',
    'version_1_1_0_change_2': '새로운 썸네일 스타일 추가: 색연필',
    'version_1_1_0_change_3': '자잘한 버그를 수정했습니다',

    // 버전 1.0.9 변경사항
    'version_1_0_9_title': 'v1.0.9 업데이트 내용',
    'version_1_0_9_change_1': '새로운 썸네일 스타일 추가: 어린이 그림',
    'version_1_0_9_change_2': '새로운 썸네일 스타일 추가: 피규어',

    // 버전 1.0.8 변경사항
    'version_1_0_8_title': 'v1.0.8 업데이트 내용',
    'version_1_0_8_change_1': 'AI 생성 콘텐츠 정책 반영',

    // 버전 1.0.7 변경사항
    'version_1_0_7_title': 'v1.0.7 업데이트 내용',
    'version_1_0_7_change_1': '홈 화면 배경 이미지 갱신 시 UI가 사라지는 버그 수정',

    // AI 콘텐츠 신고 기능
    'report_ai_content': 'AI 생성 콘텐츠 신고',
    'report_description': '부적절하거나 불쾌감을 주는 AI 생성 콘텐츠를 발견하셨나요? 아래에서 신고 사유를 선택해 주세요.',
    'report_select_reason': '신고 사유 선택',
    'report_reason_inappropriate': '부적절한 콘텐츠',
    'report_reason_offensive': '불쾌감을 주는 콘텐츠',
    'report_reason_misleading': '오해를 불러일으키는 콘텐츠',
    'report_reason_copyright': '저작권 침해',
    'report_reason_other': '기타',
    'report_additional_details': '추가 설명 (선택)',
    'report_details_hint': '신고에 대한 추가 설명을 입력해 주세요...',
    'report_submit': '신고하기',
    'report_submitted': '신고가 접수되었습니다. 검토 후 조치하겠습니다.',
    'report_error': '신고 처리 중 오류가 발생했습니다',
    'report_email_error': '이메일 앱을 열 수 없습니다. window98se@gmail.com으로 직접 연락해 주세요.',
    'report_email_subject': '[EveryDiary] AI 콘텐츠 신고',
    'report_reason': '신고 사유',
    'report_details': '추가 설명',
    'report_no_details': '추가 설명 없음',
    'report_image_info': '이미지 정보',
    'report_image_preview': '신고 대상 이미지',
    'report_prompt_label': '생성 프롬프트',
    'report_agree_share_image': '신고를 위해 이미지와 프롬프트를 공유하는 것에 동의합니다',
    'report_send_to': '신고 접수처',

    // 버전 1.0.6 변경사항
    'version_1_0_6_title': 'v1.0.6 업데이트 내용',
    'version_1_0_6_change_1': '앱 실행 시 인트로 영상 추가',
    'version_1_0_6_change_2': 'AdMob 정책 검토 기간 중 매일 AI 이미지 생성 2회 자동 초기화',
    'version_1_0_6_change_3': '코드 최적화 및 안정성 개선',

    // 버전 1.0.5 변경사항
    'version_1_0_5_title': 'v1.0.5 업데이트 내용',
    'version_1_0_5_change_1': '일기 작성 폰트 색상 개선으로 가독성 향상',
    'version_1_0_5_change_2': '새로운 "산타와 함께" 썸네일 스타일 추가',
    'version_1_0_5_change_3': '썸네일 스타일 선택기 3열 그리드 UI 개편',
    'version_1_0_5_change_4': '일기 작성 페이지 썸네일 스타일 버튼 추가',
    'version_1_0_5_change_5': '광고 보상 1회 → 2회 증가',
    'version_1_0_5_change_6': 'Android 15 edge-to-edge 호환성 개선',
    'version_1_0_5_change_7': '앱 용량을 최적화 하였습니다',
    'version_1_0_5_change_8': '전 한/영/일 외의 언어권 국가 총 177개 국가를 Targeting 합니다',

    // ===== NEW TRANSLATIONS =====

    // Onboarding (14 keys)
    'welcome_title': 'EveryDiary에 오신 것을 환영해요!',
    'setup_subtitle': '앱에서 사용할 이름과 잠금 옵션을 먼저 설정해 주세요.',
    'name_label': '이름',
    'name_hint': '예: 홍길동',
    'name_required': '이름을 입력해 주세요',
    'name_max_length': '이름은 24자 이하로 입력해 주세요',
    'pin_lock_title': '앱 실행 시 PIN 잠금 사용',
    'pin_lock_subtitle': '앱을 열 때 4자리 PIN을 입력하도록 설정합니다.',
    'pin_label': 'PIN (4자리 숫자)',
    'pin_required': '4자리 숫자를 입력해 주세요',
    'pin_numbers_only': '숫자만 입력할 수 있습니다',
    'pin_confirm_label': 'PIN 확인',
    'pin_mismatch': 'PIN이 일치하지 않습니다',
    'start_button': '시작하기',
    'setup_save_failed': '설정 저장에 실패했습니다',

    // Home Screen (11 keys)
    'home_greeting': '{name}님, 반가워요 👋',
    'home_subtitle': '오늘의 순간을 기록하고 AI 이미지로 감정을 남겨보세요.',
    'quick_actions_title': '빠른 작업',
    'new_diary': '새 일기 쓰기',
    'view_diaries': '내 일기 보기',
    'statistics_action': '일기 통계',
    'memory_notifications': '추억 알림 설정',
    'app_intro_title': '앱 소개',
    'fallback_features_title': 'EveryDiary 주요 기능',
    'fallback_features_list': 'OCR · 음성 녹음 · 감정 분석 · AI 이미지 · 백업 관리 · PIN 보안 · 화면 숨김',
    'diary_author': '일기 작성자',

    // Error Page (4 keys)
    'error_title': '오류',
    'page_not_found': '페이지를 찾을 수 없습니다',
    'page_not_found_subtitle': '요청하신 페이지가 존재하지 않습니다',
    'back_to_home': '홈으로 돌아가기',

    // Privacy & Terms (2 keys)
    'privacy_policy_title': '개인정보 처리방침',
    'terms_of_service_title': '이용약관',

    // Diary Write Screen (49 keys)
    'diary_write_title': '일기 작성',
    'save_tooltip': '저장',
    'thumbnail_style_tooltip': '썸네일 스타일 설정',
    'exit_without_save_title': '저장하지 않고 나가시겠습니까?',
    'exit_without_save_message': '작성 중인 내용이 저장되지 않습니다.',
    'exit': '나가기',
    'title_label': '제목',
    'title_hint': '오늘의 일기 제목을 입력하세요',
    'title_required': '제목을 입력해주세요',
    'date_label': '날짜',
    'emotion_analysis_label': '감정 분석',
    'emotion_analyzing': '감정을 분석 중...',
    'ocr_button': 'OCR',
    'voice_recording_button': '음성녹음',
    'save_button': '일기 저장',
    'saved_success': '일기가 저장되었습니다.',
    'save_failed': '저장 실패',
    'load_error': '일기를 불러오는 중 오류가 발생했습니다',
    'load_timeout': '일기 로딩 시간이 초과되었습니다. 다시 시도해주세요.',
    'retry': '다시 시도',
    'text_add_error': '텍스트 추가 중 오류가 발생했습니다',
    'thumbnail_empty_content': '내용이 비어 있어 썸네일을 생성할 수 없습니다.',
    'thumbnail_no_diary': '편집 중인 일기가 없어 재생성을 건너뜁니다.',
    'thumbnail_regenerating': '썸네일을 재생성 중입니다. 잠시만 기다려주세요.',
    'ocr_success': '텍스트 인식 완료',
    'ocr_cancelled': '텍스트 인식이 취소되었습니다',
    'ocr_unavailable': 'OCR 기능을 사용할 수 없습니다',
    'camera_permission_error': '카메라에 접근할 수 없습니다. 권한을 확인해주세요.',
    'camera_permission_required': '카메라 권한이 필요합니다.',
    'voice_error': '음성녹음 오류',
    'voice_text_added': '음성 텍스트가 추가되었습니다.',
    'voice_text_add_failed': '음성 텍스트 추가에 실패했습니다.',
    'invalid_diary_id': '잘못된 일기 ID입니다',
    'content_placeholder': '여기에 내용을 입력하세요...',
    'characters': '자',
    'diary_content_placeholder': '오늘의 이야기를 기록해 보세요...',
    'editor_undo_tooltip': '실행 취소',
    'editor_redo_tooltip': '다시 실행',
    'editor_bold_tooltip': '굵게',
    'editor_italic_tooltip': '기울임',
    'editor_underline_tooltip': '밑줄',
    'editor_bulleted_list_tooltip': '글머리 기호 목록',
    'editor_numbered_list_tooltip': '번호 목록',
    'editor_align_left_tooltip': '왼쪽 정렬',
    'editor_align_center_tooltip': '가운데 정렬',
    'editor_align_right_tooltip': '오른쪽 정렬',

    // Thumbnail Style (24 keys)
    'thumbnail_dialog_title': '썸네일 스타일 커스터마이징',
    'thumbnail_dialog_subtitle': 'AI 썸네일 스타일과 보정 값을 조정해 사용자 취향을 반영하세요.',
    'style_select_title': '스타일 선택',
    'detail_adjust_title': '상세 조정',
    'brightness_label': '밝기',
    'contrast_label': '대비',
    'saturation_label': '포화도',
    'blur_radius_label': '블러 반경',
    'overlay_color_label': '오버레이 색상',
    'overlay_opacity_label': '오버레이 투명도',
    'auto_optimization_title': '자동 최적화',
    'auto_optimization_subtitle': '분석 결과 기반으로 프롬프트를 자동 보정합니다',
    'manual_keyword_title': '사용자 지정 키워드',
    'manual_keyword_subtitle': 'AI 프롬프트에 항상 포함될 키워드를 최대 5개까지 추가할 수 있습니다.',
    'keyword_label': '수동 키워드',
    'keyword_hint': '예: 파스텔 톤, 야경',
    'keyword_add_button': '추가',
    'keyword_required': '키워드를 입력해 주세요.',
    'keyword_max_length': '키워드는 24자 이내로 입력해 주세요.',
    'keyword_duplicate': '이미 추가된 키워드입니다.',
    'keyword_max_count': '키워드는 최대 5개까지 등록할 수 있습니다.',
    'keyword_save_failed': '키워드를 저장하지 못했습니다. 다시 시도해 주세요.',
    'keyword_empty_list': '등록된 키워드가 없습니다.',
    'keyword_clear_all': '모두 삭제',
    'style_chibi': '3등신 만화',
    'style_cute': '귀여운',
    'style_pixel_game': '게임 캐릭터',
    'style_realistic': '사실적',
    'style_cartoon': '만화',
    'style_watercolor': '수채화',
    'style_oil': '유화',
    'style_sketch': '스케치',
    'style_digital': '디지털 아트',
    'style_vintage': '빈티지',
    'style_modern': '모던',
    'style_santa_together': '산타와 함께',
    'style_child_draw': '어린이 그림',
    'style_figure': '피규어',

    // Memory Notification Settings (25 keys)
    'memory_notification_settings_title': '회상 알림 설정',
    'memory_notification_settings_loading': '설정을 불러오는 중...',
    'memory_notification_settings_load_error': '설정을 불러오는데 실패했습니다',
    'memory_notification_permission_granted': '알림 권한이 허용되었습니다',
    'memory_notification_permission_denied': '알림 권한이 거부되었습니다',
    'memory_notification_scheduled': '회상 알림이 설정되었습니다',
    'memory_notification_schedule_error': '알림 설정 중 오류가 발생했습니다',
    'memory_notification_toggle_title': '회상 알림',
    'memory_notification_toggle_description': '과거 일기를 회상하도록 알림을 받습니다',
    'memory_notification_time_title': '알림 시간',
    'memory_notification_time_label': '알림 받을 시간',
    'memory_notification_types_title': '알림 유형',
    'memory_notification_yesterday_title': '어제의 기록',
    'memory_notification_yesterday_description': '어제 작성한 일기를 회상합니다',
    'memory_notification_one_week_ago_title': '일주일 전의 기록',
    'memory_notification_one_week_ago_description': '일주일 전 작성한 일기를 회상합니다',
    'memory_notification_one_month_ago_title': '한달 전의 기록',
    'memory_notification_one_month_ago_description': '한달 전 작성한 일기를 회상합니다',
    'memory_notification_one_year_ago_title': '1년 전의 기록',
    'memory_notification_one_year_ago_description': '1년 전 작성한 일기를 회상합니다',
    'memory_notification_past_today_title': '과거의 오늘',
    'memory_notification_past_today_description': '작년, 재작년 같은 날의 기록을 회상합니다',
    'memory_notification_permission_title': '알림 권한',
    'memory_notification_permission_granted_status': '알림 권한이 허용되었습니다',
    'memory_notification_permission_required': '알림 권한이 필요합니다',
    'memory_notification_permission_request_button': '권한 요청',
    'memory_notification_time_selection_title': '알림 시간 선택',
    'cancel_button': '취소',
    'confirm_button': '확인',

    // Diary List (21 keys)
    'my_diary': '내 일기',
    'back_tooltip': '뒤로가기',
    'calendar_tooltip': '캘린더 보기',
    'filter_tooltip': '필터',
    'sort_tooltip': '정렬',
    'new_diary_fab': '새 일기 작성',
    'delete_title': '일기 삭제',
    'delete_message': '이 일기를 삭제하시겠습니까?\n삭제된 일기는 복구할 수 없습니다.',
    'delete_button': '삭제',
    // 이미지 저장
    'image_save_title': '이미지 저장',
    'image_save_message': '이 이미지를 갤러리에 저장하시겠습니까?',
    'image_save_success': '이미지가 갤러리에 저장되었습니다',
    'image_save_failed': '이미지를 저장할 수 없습니다',
    'image_save_error': '이미지 저장 중 오류가 발생했습니다',
    'image_save_hint': '이미지를 길게 눌러 갤러리에 저장할 수 있습니다',
    // 네트워크 알림
    'network_offline_title': '오프라인 모드',
    'network_offline_message': 'AI이미지 생성이 실패할 수 있습니다.',
    // 일기 상세 페이지
    'diary_detail_title': '일기 상세',
    'tab_detail': '상세 내용',
    'tab_history': '편집 히스토리',
    'tooltip_favorite_add': '즐겨찾기 추가',
    'tooltip_favorite_remove': '즐겨찾기 해제',
    'tooltip_edit': '편집',
    'tooltip_share': '공유',
    'tooltip_delete': '삭제',
    'favorite_added': '즐겨찾기에 추가되었습니다',
    'favorite_removed': '즐겨찾기에서 제거되었습니다',
    'favorite_error': '즐겨찾기 상태 변경 중 오류가 발생했습니다',
    'diary_deleted': '일기가 삭제되었습니다',
    'diary_delete_failed': '일기 삭제에 실패했습니다',
    'diary_delete_error': '일기 삭제 중 오류가 발생했습니다',
    'diary_not_found': '일기를 찾을 수 없습니다',
    'diary_not_found_message': '요청하신 일기가 존재하지 않거나 삭제되었습니다',
    'diary_load_error': '일기를 불러오는 중 오류가 발생했습니다',
    'association_image_title': '일기 연상 이미지',
    'association_image_generating': '일기 연상 이미지 생성 중...',
    'association_image_generating_message': '일기 내용을 기반으로 AI 이미지를 생성하고 있습니다.',
    'association_image_error': '일기 연상 이미지를 표시할 수 없습니다',
    'association_image_load_error': '이미지를 불러올 수 없습니다',
    'image_generation_failed': '이미지 생성에 실패했습니다',
    'image_load_error': '이미지를 불러오는 중 오류가 발생했습니다',
    'generation_prompt': '생성 프롬프트',
    'emotion_label': '감정',
    'style_label': '스타일',
    'topic_label': '주제',
    'generated_date': '생성일',
    'info_title': '정보',
    'word_count': '단어 수',
    'created_date': '작성일',
    'modified_date': '수정일',
    'tags_title': '태그',
    'time_morning': '아침',
    'time_day': '낮',
    'time_evening': '저녁',
    'time_night': '밤',
    'retry_button': '다시 시도',
    'back_to_list': '목록으로 돌아가기',

    // 편집 히스토리 (2 keys)
    'edit_history_empty': '편집 히스토리가 없습니다',
    'edit_history_empty_message': '일기를 편집하면 히스토리가 기록됩니다',

    // 일기 저장 (1 key)
    'diary_saved': '일기가 저장되었습니다',

    // 기분 (16 keys)
    'mood_happy': '행복',
    'mood_sad': '슬픔',
    'mood_angry': '화남',
    'mood_calm': '평온',
    'mood_excited': '설렘',
    'mood_worried': '걱정',
    'mood_tired': '피곤',
    'mood_satisfied': '만족',
    'mood_disappointed': '실망',
    'mood_grateful': '감사',
    'mood_lonely': '외로움',
    'mood_thrilled': '흥분',
    'mood_depressed': '우울',
    'mood_nervous': '긴장',
    'mood_comfortable': '편안',
    'mood_other': '기타',

    // 날씨 (9 keys)
    'weather_sunny': '맑음',
    'weather_cloudy': '흐림',
    'weather_rainy': '비',
    'weather_snowy': '눈',
    'weather_windy': '바람',
    'weather_foggy': '안개',
    'weather_hot': '폭염',
    'weather_cold': '한파',
    'weather_other': '기타',

    'sort_dialog_title': '정렬 기준',
    'sort_date_desc': '최신순',
    'sort_date_asc': '오래된순',
    'sort_title_asc': '제목순 (A-Z)',
    'sort_title_desc': '제목순 (Z-A)',
    'sort_mood': '기분순',
    'sort_weather': '날씨순',
    'error_load_diaries': '일기를 불러올 수 없습니다',
    'error_unknown': '알 수 없는 오류가 발생했습니다',
    'empty_diaries_title': '아직 작성한 일기가 없습니다',
    'empty_diaries_subtitle': '첫 번째 일기를 작성해보세요',
    'empty_diaries_action': '일기 작성하기',

    // Statistics (7 keys)
    'statistics_title': '일기 통계',
    'date_range_tooltip': '날짜 범위 선택',
    'period_title': '분석 기간',
    'preset_week': '최근 1주',
    'preset_month': '최근 1개월',
    'preset_quarter': '최근 3개월',
    'preset_year': '최근 1년',

    // Backup & Restore (49 keys)
    'backup_section_title': '백업 및 복원',
    'create_backup_button': '백업 생성',
    'restore_from_file_button': '파일에서 복원',
    'auto_backup_title': '자동 백업',
    'backup_interval_label': '백업 주기: ',
    'interval_daily': '매일',
    'interval_3days': '3일마다',
    'interval_weekly': '주간',
    'interval_biweekly': '2주마다',
    'interval_monthly': '월간',
    'max_backups_label': '최대 백업 수: ',
    'max_3': '3개',
    'max_5': '5개',
    'max_10': '10개',
    'max_20': '20개',
    'no_backups_title': '백업이 없습니다',
    'no_backups_subtitle': '첫 번째 백업을 생성해보세요',
    'available_backups_title': '사용 가능한 백업',
    'created_date_label': '생성일',
    'size_label': '크기',
    'includes_label': '포함',
    'includes_settings': '설정',
    'includes_profile': '프로필',
    'includes_diary': '일기',
    'restore_action': '복원',
    'delete_action': '삭제',
    'backup_success': '백업이 성공적으로 생성되었습니다.',
    'backup_failed': '백업 생성에 실패했습니다.',
    'backup_error': '백업 생성 중 오류가 발생했습니다',
    'restore_success': '복원이 성공적으로 완료되었습니다.',
    'restore_failed': '복원에 실패했습니다.',
    'restore_error': '복원 중 오류가 발생했습니다',
    'delete_success': '백업이 삭제되었습니다.',
    'delete_failed': '백업 삭제에 실패했습니다.',
    'delete_error': '백업 삭제 중 오류가 발생했습니다',
    'load_error_backup': '데이터 로드 중 오류가 발생했습니다',
    'file_picker_error': '파일 선택 중 오류가 발생했습니다',
    'auto_backup_update_error': '자동 백업 설정 업데이트 중 오류가 발생했습니다',
    'interval_update_error': '백업 주기 설정 중 오류가 발생했습니다',
    'max_backups_update_error': '최대 백업 수 설정 중 오류가 발생했습니다',
    'restore_confirm_title': '데이터 복원',
    'restore_confirm_message': '현재 데이터가 백업 데이터로 덮어씌워집니다.\n이 작업은 되돌릴 수 없습니다.\n\n계속하시겠습니까?',
    'delete_confirm_title': '백업 삭제',
    'delete_confirm_message': '백업을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
    'count_suffix': '개',

    // Calendar (16 keys)
    'calendar': '캘린더',
    'back': '뒤로가기',
    'diary_statistics': '일기 통계',
    'weekly_view': '주간 보기',
    'monthly_view': '월간 보기',
    'today': '오늘',
    'write_new_diary': '새 일기 작성',
    'calendar_legend_multiple_entries': '주황색 점은 2개 이상의 일기가 있습니다.',
    'please_select_date': '날짜를 선택해주세요',
    'diary_count': '{count}개의 일기',
    'no_diary_on_this_day': '이 날에는 일기가 없습니다',
    'write_diary': '일기 작성하기',
    'diary_search_hint': '일기 검색...',
    'clear_search_tooltip': '검색 취소',
    'today_with_date': '오늘 ({month}월 {day}일)',
    'yesterday_with_date': '어제 ({month}월 {day}일)',
    'tomorrow_with_date': '내일 ({month}월 {day}일)',
    'full_date': '{year}년 {month}월 {day}일',

    // Statistics Widget (25 keys)
    'stats_overall_title': '전체 통계',
    'stats_total_diaries': '총 일기 수',
    'stats_total_diaries_unit': '{count}개',
    'stats_current_streak': '현재 연속',
    'stats_current_streak_unit': '{count}일',
    'stats_longest_streak': '최장 연속',
    'stats_longest_streak_unit': '{count}일',
    'stats_daily_average': '일평균',
    'stats_daily_average_unit': '{count}개',
    'stats_most_active_day': '가장 활발한 요일',
    'stats_most_active_day_unit': '{day}요일',
    'stats_most_active_month': '가장 활발한 월',
    'stats_monthly_frequency': '월별 작성 빈도',
    'stats_weekly_frequency': '주별 작성 빈도',
    'stats_no_data': '데이터가 없습니다',
    'stats_count_unit': '{count}개',
    'stats_content_length_title': '일기 길이 통계',
    'stats_average_characters': '평균 글자 수',
    'stats_characters_unit': '{count}자',
    'stats_average_words': '평균 단어 수',
    'stats_words_unit': '{count}개',
    'stats_max_characters': '최대 글자 수',
    'stats_min_characters': '최소 글자 수',
    'stats_writing_time_title': '작성 시간대 통계',
    'stats_time_count_unit': '{count}회',

    // Generation Count Widget (3 keys)
    'ai_image_generation': 'AI 이미지 생성',
    'remaining_count_label': '남은 횟수: ',
    'count_times': '회',

    // Memory Screen (14 keys)
    'memory_title': '회상',
    'memory_back_tooltip': '뒤로가기',
    'memory_notifications_tooltip': '알림 설정',
    'memory_filter_tooltip': '필터',
    'memory_refresh_tooltip': '새로고침',
    'memory_loading': '회상을 불러오는 중...',
    'memory_load_failed': '회상을 불러오는데 실패했습니다',
    'memory_unknown_error': '알 수 없는 오류가 발생했습니다',
    'memory_retry_button': '다시 시도',
    'memory_empty_title': '아직 회상할 일기가 없습니다',
    'memory_empty_description': '일기를 작성하면 과거 기록을 회상할 수 있습니다',
    'memory_write_diary_button': '일기 작성하기',
    'memory_bookmarked': '{title}을(를) 북마크했습니다',
    'memory_bookmark_removed': '{title} 북마크를 해제했습니다',

    // App Intro Features (16 keys)
    'feature_ocr_title': 'OCR 텍스트 추출',
    'feature_ocr_desc': '종이에 적은 기록을 촬영해 텍스트로 곧바로 변환해요.',
    'feature_voice_title': '음성 녹음',
    'feature_voice_desc': '말로 남긴 하루를 자연스럽게 일기로 전환합니다.',
    'feature_emotion_title': '감정 분석',
    'feature_emotion_desc': '일기에 담긴 감정을 스스로 정리하고 통계로 보여줘요.',
    'feature_ai_image_title': 'AI 이미지 생성',
    'feature_ai_image_desc': '일기 분위기에 맞는 감성 배경 이미지를 만들어 드려요.',
    'feature_search_title': '일기 검색',
    'feature_search_desc': '키워드와 날짜로 원하는 일기를 빠르게 찾아요.',
    'feature_backup_title': '백업 파일 관리',
    'feature_backup_desc': '백업 파일을 내보내고 다시 불러와 언제든 안전하게 보관해요.',
    'feature_pin_title': 'PIN 보안',
    'feature_pin_desc': 'PIN 잠금으로 개인 일기를 안전하게 지켜 드립니다.',
    'feature_privacy_title': '배경 화면 숨김',
    'feature_privacy_desc': '백그라운드에서도 화면을 흐리게 처리해 사생활을 보호해요.',

    // Emotion Arrow
    'emotion_arrow': '→',

    // Emotion Names
    'emotion_joy': '기쁨',
    'emotion_default': '기본',
    'emotion_sadness': '슬픔',
    'emotion_anger': '화남',
    'emotion_fear': '두려움',
    'emotion_surprise': '놀람',
    'emotion_disgust': '혐오',
    'emotion_anticipation': '기대',
    'emotion_trust': '신뢰',

    // Privacy Policy Content
    'privacy_policy_content': '''**Privacy Policy**

This privacy policy applies to the Everydiary app (hereby referred to as "Application") for mobile devices that was created by Sunnydevstory (hereby referred to as "Service Provider") as a Freemium service. This service is intended for use "AS IS".

**Information Collection and Use**

The Application collects information when you download and use it. This information may include information such as

*   Your device's Internet Protocol address (e.g. IP address)

*   The pages of the Application that you visit, the time and date of your visit, the time spent on those pages

*   The time spent on the Application

*   The operating system you use on your mobile device

The Application does not gather precise information about the location of your mobile device.

The Application collects your device's location, which helps the Service Provider determine your approximate geographical location and make use of in below ways:

*   Geolocation Services: The Service Provider utilizes location data to provide features such as personalized content, relevant recommendations, and location-based services.

*   Analytics and Improvements: Aggregated and anonymized location data helps the Service Provider to analyze user behavior, identify trends, and improve the overall performance and functionality of the Application.

*   Third-Party Services: Periodically, the Service Provider may transmit anonymized location data to external services. These services assist them in enhancing the Application and optimizing their offerings.

The Service Provider may use the information you provided to contact you from time to time to provide you with important information, required notices and marketing promotions.

For a better experience, while using the Application, the Service Provider may require you to provide us with certain personally identifiable information, including but not limited to window98se@gmail.com. The information that the Service Provider request will be retained by them and used as described in this privacy policy.

**Third Party Access**

Only aggregated, anonymized data is periodically transmitted to external services to aid the Service Provider in improving the Application and their service. The Service Provider may share your information with third parties in the ways that are described in this privacy statement.

Please note that the Application utilizes third-party services that have their own Privacy Policy about handling data. Below are the links to the Privacy Policy of the third-party service providers used by the Application:

*   [Google Play Services](https://www.google.com/policies/privacy/)

*   [AdMob](https://support.google.com/admob/answer/6128543?hl=en)

The Service Provider may disclose User Provided and Automatically Collected Information:

*   as required by law, such as to comply with a subpoena, or similar legal process;

*   when they believe in good faith that disclosure is necessary to protect their rights, protect your safety or the safety of others, investigate fraud, or respond to a government request;

*   with their trusted services providers who work on their behalf, do not have an independent use of the information we disclose to them, and have agreed to adhere to the rules set forth in this privacy statement.

**Opt-Out Rights**

You can stop all collection of information by the Application easily by uninstalling it. You may use the standard uninstall processes as may be available as part of your mobile device or via the mobile application marketplace or network.

**Data Retention Policy**

The Service Provider will retain User Provided data for as long as you use the Application and for a reasonable time thereafter. If you'd like them to delete User Provided Data that you have provided via the Application, please contact them at window98se@gmail.com and they will respond in a reasonable time.

**Children**

The Service Provider does not use the Application to knowingly solicit data from or market to children under the age of 13.

The Application does not address anyone under the age of 13. The Service Provider does not knowingly collect personally identifiable information from children under 13 years of age. In the case the Service Provider discover that a child under 13 has provided personal information, the Service Provider will immediately delete this from their servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact the Service Provider (window98se@gmail.com) so that they will be able to take the necessary actions.

**Security**

The Service Provider is concerned about safeguarding the confidentiality of your information. The Service Provider provides physical, electronic, and procedural safeguards to protect information the Service Provider processes and maintains.

**Changes**

This Privacy Policy may be updated from time to time for any reason. The Service Provider will notify you of any changes to the Privacy Policy by updating this page with the new Privacy Policy. You are advised to consult this Privacy Policy regularly for any changes, as continued use is deemed approval of all changes.

This privacy policy is effective as of 2025-11-12

**Your Consent**

By using the Application, you are consenting to the processing of your information as set forth in this Privacy Policy now and as amended by us.

**Contact Us**

If you have any questions regarding privacy while using the Application, or have questions about the practices, please contact the Service Provider via email at window98se@gmail.com.

* * *

This privacy policy page was generated by [App Privacy Policy Generator](https://app-privacy-policy-generator.nisrulz.com/)''',

    // Terms of Service Content
    'terms_of_service_content': '''**Terms & Conditions**

These terms and conditions apply to the Everydiary app (hereby referred to as "Application") for mobile devices that was created by Sunnydevstory (hereby referred to as "Service Provider") as a Freemium service.

Upon downloading or utilizing the Application, you are automatically agreeing to the following terms. It is strongly advised that you thoroughly read and understand these terms prior to using the Application.

Unauthorized copying, modification of the Application, any part of the Application, or our trademarks is strictly prohibited. Any attempts to extract the source code of the Application, translate the Application into other languages, or create derivative versions are not permitted. All trademarks, copyrights, database rights, and other intellectual property rights related to the Application remain the property of the Service Provider.

The Service Provider is dedicated to ensuring that the Application is as beneficial and efficient as possible. As such, they reserve the right to modify the Application or charge for their services at any time and for any reason. The Service Provider assures you that any charges for the Application or its services will be clearly communicated to you.

The Application stores and processes personal data that you have provided to the Service Provider in order to provide the Service. It is your responsibility to maintain the security of your phone and access to the Application. The Service Provider strongly advise against jailbreaking or rooting your phone, which involves removing software restrictions and limitations imposed by the official operating system of your device. Such actions could expose your phone to malware, viruses, malicious programs, compromise your phone's security features, and may result in the Application not functioning correctly or at all.

Please note that the Application utilizes third-party services that have their own Terms and Conditions. Below are the links to the Terms and Conditions of the third-party service providers used by the Application:

*   [Google Play Services](https://policies.google.com/terms)

*   [AdMob](https://developers.google.com/admob/terms)

Please be aware that the Service Provider does not assume responsibility for certain aspects. Some functions of the Application require an active internet connection, which can be Wi-Fi or provided by your mobile network provider. The Service Provider cannot be held responsible if the Application does not function at full capacity due to lack of access to Wi-Fi or if you have exhausted your data allowance.

If you are using the application outside of a Wi-Fi area, please be aware that your mobile network provider's agreement terms still apply. Consequently, you may incur charges from your mobile provider for data usage during the connection to the application, or other third-party charges. By using the application, you accept responsibility for any such charges, including roaming data charges if you use the application outside of your home territory (i.e., region or country) without disabling data roaming. If you are not the bill payer for the device on which you are using the application, they assume that you have obtained permission from the bill payer.

Similarly, the Service Provider cannot always assume responsibility for your usage of the application. For instance, it is your responsibility to ensure that your device remains charged. If your device runs out of battery and you are unable to access the Service, the Service Provider cannot be held responsible.

In terms of the Service Provider's responsibility for your use of the application, it is important to note that while they strive to ensure that it is updated and accurate at all times, they do rely on third parties to provide information to them so that they can make it available to you. The Service Provider accepts no liability for any loss, direct or indirect, that you experience as a result of relying entirely on this functionality of the application.

The Service Provider may wish to update the application at some point. The application is currently available as per the requirements for the operating system (and for any additional systems they decide to extend the availability of the application to) may change, and you will need to download the updates if you want to continue using the application. The Service Provider does not guarantee that it will always update the application so that it is relevant to you and/or compatible with the particular operating system version installed on your device. However, you agree to always accept updates to the application when offered to you. The Service Provider may also wish to cease providing the application and may terminate its use at any time without providing termination notice to you. Unless they inform you otherwise, upon any termination, (a) the rights and licenses granted to you in these terms will end; (b) you must cease using the application, and (if necessary) delete it from your device.

**Changes to These Terms and Conditions**

The Service Provider may periodically update their Terms and Conditions. Therefore, you are advised to review this page regularly for any changes. The Service Provider will notify you of any changes by posting the new Terms and Conditions on this page.

These terms and conditions are effective as of 2025-11-12

**Contact Us**

If you have any questions or suggestions about the Terms and Conditions, please do not hesitate to contact the Service Provider at window98se@gmail.com.

* * *

This Terms and Conditions page was generated by [App Privacy Policy Generator](https://app-privacy-policy-generator.nisrulz.com/)''',
  };

  // ============== 영어 ==============
  static const Map<String, String> _english = {
    // Common
    'app_name': 'EveryDiary',
    'ok': 'OK',
    'confirm': 'Confirm',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'close': 'Close',
    'yes': 'Yes',
    'no': 'No',
    'dont_show_again': 'Don\'t show again',

    // New Style Announcement
    'new_style_announcement_title': 'New Style Added!',
    'new_style_announcement_description': 'Try the Color Pencil style with storybook illustration vibes.\nYou can change it in Settings.',

    // AdMob Policy Notice
    'ad_policy_notice_title': 'Service Notice',
    'ad_policy_notice_message': 'The ad viewing feature is temporarily limited due to AdMob policy review. Until January 30th, free AI image generation will reset to 2 times daily. It will return to normal after the policy review is complete.',
    'ad_policy_notice_count_info': 'Daily free AI image generation: 2 times (auto-reset)',

    // Settings
    'settings': 'Settings',
    'settings_reset': 'Reset Settings',
    'app_settings': 'App Settings',
    'thumbnail_style': 'Thumbnail Style',
    'thumbnail_style_subtitle': 'Set AI thumbnail style and keywords',
    'theme': 'Theme',
    'font_size': 'Font Size',
    'language': 'Language',
    'language_select': 'Select Language',
    'security_management': 'EveryDiary Security & Management',
    'username': 'Username',
    'username_not_set': 'Not set',
    'pin_lock': 'PIN Lock',
    'pin_lock_enabled': 'PIN required on app launch',
    'pin_lock_disabled': 'Disabled',
    'pin_change': 'Change PIN',
    'pin_change_subtitle': 'Enter current PIN and set new PIN',
    'recovery_question': 'Emergency Recovery Question',
    'recovery_question_set': 'Set',
    'recovery_question_not_set': 'Not set',

    // PIN Related
    'pin_setup': 'PIN Lock Setup',
    'pin_new': 'New PIN (4 digits)',
    'pin_confirm': 'Confirm PIN',
    'pin_current': 'Current PIN',
    'pin_change_title': 'Change PIN',
    'pin_disable': 'Disable PIN Lock',
    'pin_disable_message': 'Disabling PIN lock will no longer require authentication on app launch.',
    'pin_disable_button': 'Disable',
    'pin_error_length': 'Please enter 4 digits',
    'pin_error_mismatch': 'PINs do not match',
    'pin_error_new_mismatch': 'New PINs do not match',
    'pin_enabled_message': 'PIN lock has been enabled.',
    'pin_disabled_message': 'PIN lock has been disabled.',
    'pin_changed_message': 'PIN has been changed.',
    'pin_change_failed': 'Failed to change PIN',

    // PIN Unlock Screen
    'pin_unlock_title': 'Unlock',
    'pin_unlock_subtitle': 'Please enter your 4-digit PIN to access the app.',
    'pin_unlock_button': 'Unlock',
    'pin_unlock_clear': 'Clear',
    'pin_unlock_recovery': 'Emergency Recovery',
    'pin_unlock_error_length': 'Please enter a 4-digit PIN',
    'pin_unlock_error_incorrect': 'PIN is incorrect. Please try again.',
    'pin_unlock_error_locked': 'Locked due to too many attempts.',
    'pin_unlock_locked_until': 'Locked: Cannot attempt until {time}.',
    'pin_unlock_remaining_attempts': 'Remaining attempts: {count}',
    'pin_unlock_unlocked': 'Unlocked',
    'pin_unlock_time_minutes': '{minutes}m {seconds}s',
    'pin_unlock_time_seconds': '{seconds}s',
    'pin_unlock_recovery_warning_title': '⚠️ Emergency Recovery Question Not Set',
    'pin_unlock_recovery_warning_message': 'If you forget your PIN, you cannot access the app.\nPlease set up an emergency recovery question in settings.',

    // Recovery Question
    'recovery_question_setup': 'Emergency Recovery Question Setup',
    'recovery_question_label': 'Security Question',
    'recovery_question_hint': 'e.g., My secret place?',
    'recovery_answer': 'Answer',
    'recovery_answer_confirm': 'Confirm Answer',
    'recovery_question_error_empty': 'Please enter a security question',
    'recovery_answer_error_empty': 'Please enter an answer',
    'recovery_answer_error_mismatch': 'Answers do not match',
    'recovery_question_saved': 'Emergency recovery question has been saved.',
    'recovery_question_deleted': 'Emergency recovery question has been deleted.',
    'recovery_question_delete': 'Delete',

    // PIN Recovery Dialog
    'pin_recovery_title': 'Emergency Recovery',
    'pin_recovery_question_label': 'Security Question',
    'pin_recovery_answer_input': 'Enter Answer',
    'pin_recovery_new_pin': 'New PIN (4 digits)',
    'pin_recovery_confirm_pin': 'Confirm New PIN',
    'pin_recovery_error_answer_empty': 'Please enter your security question answer',
    'pin_recovery_error_pin_length': 'Please enter a 4-digit numeric PIN',
    'pin_recovery_error_pin_mismatch': 'New PINs do not match',
    'pin_recovery_success': 'New PIN has been set.',
    'pin_recovery_failed': 'Recovery failed: {error}',

    // Username
    'username_change': 'Change Username',
    'username_label': 'Name',
    'username_hint': 'e.g., John Doe',
    'username_error_empty': 'Please enter a name',
    'username_updated': 'Username has been updated.',

    // Theme
    'theme_system': 'System',
    'theme_light': 'Light Mode',
    'theme_dark': 'Dark Mode',

    // Font Size
    'font_small': 'Small',
    'font_medium': 'Medium',
    'font_large': 'Large',
    'font_extra_large': 'Extra Large',

    // Intro Video
    'show_intro_video': 'Show Intro Video on Start',
    'show_intro_video_subtitle': 'Display intro video when app launches',

    // Image Generation
    'image_generation_count': 'AI Image Generation Count',
    'image_generation_description': 'Create more amazing diary images generated by AI!',
    'watch_ad_for_1_time': 'Watch Ad for 1 More Time',
    'watch_ad_subtitle': 'Get it for free by watching a short ad',
    'ad_loading': 'Loading Ad...',
    'ad_wait': 'Please wait',
    'ad_reward_success': 'Ad viewing complete! 2 generation counts have been added.',

    // Memory
    'memory_type_all': 'All',
    'memory_type_yesterday': 'Yesterday',
    'memory_type_one_week_ago': 'A Week Ago',
    'memory_type_one_month_ago': 'A Month Ago',
    'memory_type_one_year_ago': '1 Year Ago',
    'memory_type_past_today': 'Past Today',
    'memory_type_same_time': 'Same Time',
    'memory_type_seasonal': 'Seasonal',
    'memory_type_special_date': 'Special Date',
    'memory_type_similar_tags': 'Similar Tags',
    'memory_reason_yesterday': "Yesterday's Memory",
    'memory_reason_one_week_ago': "A Week Ago's Memory",
    'memory_reason_one_month_ago': "A Month Ago's Memory",
    'memory_reason_one_year_ago': "A Year Ago's Memory",
    'memory_reason_past_today': "Past Today's Memory",
    'memory_reason_same_time': "Same Time's Memory",
    'memory_reason_seasonal': 'Seasonal Memory',
    'memory_reason_special_date': 'Special Memory',
    'memory_reason_similar_tags': 'Similar Tags Memory',
    'memory_bookmark': 'Bookmark',
    'memory_bookmark_remove': 'Remove Bookmark',

    // OCR
    'ocr_camera_title': 'Take Photo',
    'ocr_auto_detect': 'Auto Detect',
    'ocr_language_korean': 'Korean',
    'ocr_language_english': 'English',
    'ocr_language_japanese': 'Japanese',
    'ocr_language_chinese': 'Chinese',

    // Speech Recognition
    'speech_language_korean': 'Korean',
    'speech_language_english': 'English',
    'speech_language_japanese': 'Japanese',
    'speech_language_chinese': 'Chinese',
    'speech_initializing': 'Initializing speech recognition...',
    'speech_ready': 'Tap the microphone button to start speech recognition',
    'speech_listening': 'Please speak. Tap the button again when finished',
    'speech_processing': 'Converting speech to text...',
    'speech_completed': 'Speech recognition completed',
    'speech_error': 'An error occurred during speech recognition. Please try again',
    'speech_cancelled': 'Speech recognition cancelled',
    'speech_error_title': 'Speech Recognition Error',
    'speech_cancel': 'Cancel',
    'speech_retry': 'Retry',
    'speech_error_solutions': 'Solutions:',
    'speech_error_check_permission': '• Check if microphone permission is granted',
    'speech_error_check_internet': '• Check your internet connection',
    'speech_error_quiet_environment': '• Try again in a quieter environment',
    'speech_error_check_microphone': '• Check if the microphone is working properly',
    'speech_permission_title': 'Microphone Permission Required',
    'speech_permission_description': 'Microphone permission is required to use speech recognition.',
    'speech_permission_usage': 'This permission will only be used for:',
    'speech_permission_convert': '• Converting speech to text',
    'speech_permission_diary': '• Voice input when writing diary',
    'speech_permission_accuracy': '• Improving speech recognition accuracy',
    'speech_permission_deny': 'Deny',
    'speech_permission_allow': 'Allow',
    'speech_init_failed': 'Failed to initialize speech recognition service.',
    'speech_init_error': 'An error occurred during initialization',
    'speech_permission_required': 'Microphone permission is required.',
    'speech_start_failed': 'Failed to start speech recognition.',
    'speech_start_error': 'An error occurred while starting speech recognition',
    'speech_stop_error': 'An error occurred while stopping speech recognition',
    'speech_cancel_error': 'An error occurred while cancelling speech recognition',

    // Voice Recording
    'voice_recording_title': 'Voice Recording',
    'voice_recording_init_failed': 'Unable to initialize speech recognition service.',
    'voice_recording_start_failed': 'Unable to start voice recording.',
    'voice_recording_recording': 'Recording...',
    'voice_recording_paused': 'Paused',
    'voice_recording_resume_prompt': 'Resume recording',
    'voice_recording_start_prompt': 'Start recording',
    'voice_recording_recognized_text': 'Recognized Text:',
    'voice_recording_stop': 'Stop Recording',
    'voice_recording_resume': 'Resume Recording',
    'voice_recording_start': 'Start Recording',
    'voice_recording_cancel': 'Cancel',
    'voice_recording_confirm': 'Confirm',

    // Permission Request
    'permission_request_title': 'Permission Settings',
    'permission_request_subtitle': 'The following permissions are required to use app features',
    'permission_camera_title': 'Camera Permission',
    'permission_camera_description': 'Camera access is required to use the OCR text recognition feature.',
    'permission_microphone_title': 'Microphone Permission',
    'permission_microphone_description': 'Microphone access is required to write diary entries with voice.',
    'permission_allow_all': 'Allow All',
    'permission_skip': 'Set Later',
    'permission_continue': 'Continue',
    'permission_granted': 'Granted',
    'permission_denied': 'Denied',
    'permission_open_settings': 'Open Settings',
    'permission_required_features': 'Some features require permissions',
    'permission_camera_rationale': 'Camera permission is required to capture photos and recognize text.',
    'permission_microphone_rationale': 'Microphone permission is required to write diary entries with voice.',
    'permission_settings_guide': 'Permission has been permanently denied. Please allow permission in settings.',

    // Date Display
    'date_today': 'Today',
    'date_yesterday': 'Yesterday',

    // Notifications
    'notifications': 'Notifications',
    'daily_reminder': 'Daily Diary Reminder',
    'daily_reminder_subtitle': 'Reminds you to write in your diary every day',
    'reminder_time': 'Reminder Time',

    // Data Management
    'data_management': 'Data Management',

    // Info
    'info': 'Information',
    'app_version': 'App Version',
    'privacy_policy': 'Privacy Policy',
    'privacy_policy_subtitle': 'Check our privacy policy',
    'terms_of_service': 'Terms of Service',
    'terms_of_service_subtitle': 'Check our terms of service',
    'app_description': 'Record your precious moments with beautiful AI-generated images.',
    'app_developer': 'Developer: EveryDiary',
    'app_contact': 'Contact: window98se@gmail.com',

    // Version 1.0.3 Changelog
    'version_1_0_3_title': 'v1.0.3 Updates',
    'version_1_0_3_change_1': 'Improved Android 15 display compatibility',
    'version_1_0_3_change_2': 'Fixed memory reminder time settings',
    'version_1_0_3_change_3': 'Enhanced OCR camera quality (using device camera)',
    'version_1_0_3_change_4': 'Added game character thumbnail style (pixel art)',
    'version_1_0_3_change_5': 'UI simplification and stability improvements',

    // Version 1.0.4 Changelog
    'version_1_0_4_title': 'v1.0.4 Updates',
    'version_1_0_4_change_1': 'Improved diary text readability with better font colors',
    'version_1_0_4_change_2': 'Added new "Santa Together" thumbnail style',
    'version_1_0_4_change_3': 'Redesigned thumbnail style selector with 3-column grid UI',
    'version_1_0_4_change_4': 'Added thumbnail style button on diary write page',
    'version_1_0_4_change_5': 'Increased ad reward from 1 to 2 generations',
    'version_1_0_4_change_6': 'Improved Android 15 edge-to-edge compatibility',

    // Gender related
    'user_gender': 'Gender',
    'select_gender': 'Select Gender',
    'gender_male': 'Male',
    'gender_female': 'Female',
    'gender_none': 'Not specified',

    // Color Pencil style
    'style_color_pencil': 'Color Pencil',

    // Felted Wool style
    'style_felted_wool': 'Felted Wool',

    // 3D Animation style
    'style_3d_animation': '3D Animation',

    // New styles popup
    'new_styles_popup_title': 'New Styles Added!',
    'new_styles_popup_message': 'Felted Wool and 3D Animation styles have been added. Check them out in Settings!',
    'new_styles_popup_dont_show': "Don't show again",
    'new_styles_popup_check': 'Check it out',

    // Version 1.1.1 Changelog
    'version_1_1_1_title': 'v1.1.1 Updates',
    'version_1_1_1_change_1': 'New thumbnail style: Felted Wool',
    'version_1_1_1_change_2': 'New thumbnail style: 3D Animation',

    // Version 1.1.0 Changelog
    'version_1_1_0_title': 'v1.1.0 Updates',
    'version_1_1_0_change_1': 'Added user gender setting (reflected in AI images)',
    'version_1_1_0_change_2': 'New thumbnail style: Color Pencil',
    'version_1_1_0_change_3': 'Fixed minor bugs',

    // Version 1.0.9 Changelog
    'version_1_0_9_title': 'v1.0.9 Updates',
    'version_1_0_9_change_1': 'New thumbnail style: Child Drawing',
    'version_1_0_9_change_2': 'New thumbnail style: Figure',

    // Version 1.0.8 Changelog
    'version_1_0_8_title': 'v1.0.8 Updates',
    'version_1_0_8_change_1': 'AI-generated content policy compliance',

    // Version 1.0.7 Changelog
    'version_1_0_7_title': 'v1.0.7 Updates',
    'version_1_0_7_change_1': 'Fixed bug where UI disappeared when home screen background image updated',

    // AI Content Report Feature
    'report_ai_content': 'Report AI Content',
    'report_description': 'Found inappropriate or offensive AI-generated content? Please select a reason below.',
    'report_select_reason': 'Select Report Reason',
    'report_reason_inappropriate': 'Inappropriate content',
    'report_reason_offensive': 'Offensive content',
    'report_reason_misleading': 'Misleading content',
    'report_reason_copyright': 'Copyright infringement',
    'report_reason_other': 'Other',
    'report_additional_details': 'Additional Details (Optional)',
    'report_details_hint': 'Please provide additional details about your report...',
    'report_submit': 'Submit Report',
    'report_submitted': 'Report submitted. We will review and take action.',
    'report_error': 'Error processing report',
    'report_email_error': 'Cannot open email app. Please contact window98se@gmail.com directly.',
    'report_email_subject': '[EveryDiary] AI Content Report',
    'report_reason': 'Report Reason',
    'report_details': 'Additional Details',
    'report_no_details': 'No additional details',
    'report_image_info': 'Image Information',
    'report_image_preview': 'Image to Report',
    'report_prompt_label': 'Generation Prompt',
    'report_agree_share_image': 'I agree to share the image and prompt for this report',
    'report_send_to': 'Report to',

    // Version 1.0.6 Changelog
    'version_1_0_6_title': 'v1.0.6 Updates',
    'version_1_0_6_change_1': 'Added intro video on app launch',
    'version_1_0_6_change_2': 'Daily auto-reset of 2 free AI image generations during AdMob policy review',
    'version_1_0_6_change_3': 'Code optimization and stability improvements',

    // Version 1.0.5 Changelog
    'version_1_0_5_title': 'v1.0.5 Updates',
    'version_1_0_5_change_1': 'Improved diary text readability with better font colors',
    'version_1_0_5_change_2': 'Added new "Santa Together" thumbnail style',
    'version_1_0_5_change_3': 'Redesigned thumbnail style selector with 3-column grid UI',
    'version_1_0_5_change_4': 'Added thumbnail style button on diary write page',
    'version_1_0_5_change_5': 'Increased ad reward from 1 to 2 generations',
    'version_1_0_5_change_6': 'Improved Android 15 edge-to-edge compatibility',
    'version_1_0_5_change_7': 'Optimized app size for better performance',
    'version_1_0_5_change_8': 'Now targeting 177 countries beyond Korean/English/Japanese',

    // ===== NEW TRANSLATIONS =====

    // Onboarding (14 keys)
    'welcome_title': 'Welcome to EveryDiary!',
    'setup_subtitle': 'Please set up your name and lock options for the app.',
    'name_label': 'Name',
    'name_hint': 'e.g., John Smith',
    'name_required': 'Please enter your name',
    'name_max_length': 'Name must be 24 characters or less',
    'pin_lock_title': 'Use PIN lock on app launch',
    'pin_lock_subtitle': 'Require a 4-digit PIN when opening the app.',
    'pin_label': 'PIN (4 digits)',
    'pin_required': 'Please enter 4 digits',
    'pin_numbers_only': 'Only numbers are allowed',
    'pin_confirm_label': 'Confirm PIN',
    'pin_mismatch': 'PINs do not match',
    'start_button': 'Get Started',
    'setup_save_failed': 'Failed to save settings',

    // Home Screen (11 keys)
    'home_greeting': 'Hello, {name}! 👋',
    'home_subtitle': 'Record today\'s moments and preserve emotions with AI images.',
    'quick_actions_title': 'Quick Actions',
    'new_diary': 'Write New Entry',
    'view_diaries': 'View My Diaries',
    'statistics_action': 'Diary Statistics',
    'memory_notifications': 'Memory Notifications',
    'app_intro_title': 'App Introduction',
    'fallback_features_title': 'EveryDiary Key Features',
    'fallback_features_list': 'OCR · Voice Recording · Emotion Analysis · AI Images · Backup · PIN Security · Screen Privacy',
    'diary_author': 'Diary Author',

    // Error Page (4 keys)
    'error_title': 'Error',
    'page_not_found': 'Page Not Found',
    'page_not_found_subtitle': 'The page you requested does not exist',
    'back_to_home': 'Back to Home',

    // Privacy & Terms (2 keys)
    'privacy_policy_title': 'Privacy Policy',
    'terms_of_service_title': 'Terms of Service',

    // Diary Write Screen (49 keys)
    'diary_write_title': 'Write Diary',
    'save_tooltip': 'Save',
    'thumbnail_style_tooltip': 'Thumbnail Style Settings',
    'exit_without_save_title': 'Exit without saving?',
    'exit_without_save_message': 'Your changes will not be saved.',
    'exit': 'Exit',
    'title_label': 'Title',
    'title_hint': 'Enter today\'s diary title',
    'title_required': 'Please enter a title',
    'date_label': 'Date',
    'emotion_analysis_label': 'Emotion Analysis',
    'emotion_analyzing': 'Analyzing emotions...',
    'ocr_button': 'OCR',
    'voice_recording_button': 'Voice Recording',
    'save_button': 'Save Diary',
    'saved_success': 'Diary has been saved.',
    'save_failed': 'Failed to save',
    'load_error': 'An error occurred while loading the diary',
    'load_timeout': 'Loading timeout. Please try again.',
    'retry': 'Retry',
    'text_add_error': 'An error occurred while adding text',
    'thumbnail_empty_content': 'Cannot generate thumbnail because content is empty.',
    'thumbnail_no_diary': 'No diary being edited, skipping regeneration.',
    'thumbnail_regenerating': 'Regenerating thumbnail. Please wait.',
    'ocr_success': 'Text recognition complete',
    'ocr_cancelled': 'Text recognition cancelled',
    'ocr_unavailable': 'OCR feature is unavailable',
    'camera_permission_error': 'Cannot access camera. Please check permissions.',
    'camera_permission_required': 'Camera permission is required.',
    'voice_error': 'Voice recording error',
    'voice_text_added': 'Voice text has been added.',
    'voice_text_add_failed': 'Failed to add voice text.',
    'invalid_diary_id': 'Invalid diary ID',
    'content_placeholder': 'Enter content here...',
    'characters': 'characters',
    'diary_content_placeholder': 'Record today\'s story...',
    'editor_undo_tooltip': 'Undo',
    'editor_redo_tooltip': 'Redo',
    'editor_bold_tooltip': 'Bold',
    'editor_italic_tooltip': 'Italic',
    'editor_underline_tooltip': 'Underline',
    'editor_bulleted_list_tooltip': 'Bulleted List',
    'editor_numbered_list_tooltip': 'Numbered List',
    'editor_align_left_tooltip': 'Align Left',
    'editor_align_center_tooltip': 'Align Center',
    'editor_align_right_tooltip': 'Align Right',

    // Thumbnail Style (24 keys)
    'thumbnail_dialog_title': 'Customize Thumbnail Style',
    'thumbnail_dialog_subtitle': 'Adjust AI thumbnail style and correction values to reflect your preferences.',
    'style_select_title': 'Select Style',
    'detail_adjust_title': 'Fine Tuning',
    'brightness_label': 'Brightness',
    'contrast_label': 'Contrast',
    'saturation_label': 'Saturation',
    'blur_radius_label': 'Blur Radius',
    'overlay_color_label': 'Overlay Color',
    'overlay_opacity_label': 'Overlay Opacity',
    'auto_optimization_title': 'Auto Optimization',
    'auto_optimization_subtitle': 'Automatically corrects prompts based on analysis results',
    'manual_keyword_title': 'Custom Keywords',
    'manual_keyword_subtitle': 'Add up to 5 keywords that will always be included in AI prompts.',
    'keyword_label': 'Manual Keyword',
    'keyword_hint': 'e.g., Pastel tone, Night view',
    'keyword_add_button': 'Add',
    'keyword_required': 'Please enter a keyword.',
    'keyword_max_length': 'Keyword must be within 24 characters.',
    'keyword_duplicate': 'This keyword has already been added.',
    'keyword_max_count': 'You can register up to 5 keywords.',
    'keyword_save_failed': 'Failed to save keyword. Please try again.',
    'keyword_empty_list': 'No keywords registered.',
    'keyword_clear_all': 'Clear All',

    // Thumbnail Styles (12 keys)
    'style_chibi': 'Chibi Cartoon',
    'style_cute': 'Cute',
    'style_pixel_game': 'Game Character',
    'style_realistic': 'Realistic',
    'style_cartoon': 'Cartoon',
    'style_watercolor': 'Watercolor',
    'style_oil': 'Oil Painting',
    'style_sketch': 'Sketch',
    'style_digital': 'Digital Art',
    'style_vintage': 'Vintage',
    'style_modern': 'Modern',
    'style_santa_together': 'Santa Together',
    'style_child_draw': 'Child Drawing',
    'style_figure': 'Figure',

    // Memory Notification Settings (25 keys)
    'memory_notification_settings_title': 'Memory Notification Settings',
    'memory_notification_settings_loading': 'Loading settings...',
    'memory_notification_settings_load_error': 'Failed to load settings',
    'memory_notification_permission_granted': 'Notification permission granted',
    'memory_notification_permission_denied': 'Notification permission denied',
    'memory_notification_scheduled': 'Memory notifications have been scheduled',
    'memory_notification_schedule_error': 'Error occurred while setting up notifications',
    'memory_notification_toggle_title': 'Memory Notifications',
    'memory_notification_toggle_description': 'Receive notifications to reminisce about past diary entries',
    'memory_notification_time_title': 'Notification Time',
    'memory_notification_time_label': 'When to receive notifications',
    'memory_notification_types_title': 'Notification Types',
    'memory_notification_yesterday_title': 'Yesterday\'s Memories',
    'memory_notification_yesterday_description': 'Reminisce about yesterday\'s diary',
    'memory_notification_one_week_ago_title': 'One Week Ago',
    'memory_notification_one_week_ago_description': 'Reminisce about diary from a week ago',
    'memory_notification_one_month_ago_title': 'One Month Ago',
    'memory_notification_one_month_ago_description': 'Reminisce about diary from a month ago',
    'memory_notification_one_year_ago_title': 'One Year Ago',
    'memory_notification_one_year_ago_description': 'Reminisce about diary from a year ago',
    'memory_notification_past_today_title': 'This Day in the Past',
    'memory_notification_past_today_description': 'Reminisce about diary entries from the same day in past years',
    'memory_notification_permission_title': 'Notification Permission',
    'memory_notification_permission_granted_status': 'Notification permission granted',
    'memory_notification_permission_required': 'Notification permission required',
    'memory_notification_permission_request_button': 'Request Permission',
    'memory_notification_time_selection_title': 'Select Notification Time',
    'cancel_button': 'Cancel',
    'confirm_button': 'Confirm',

    // Diary List (21 keys)
    'my_diary': 'My Diary',
    'back_tooltip': 'Back',
    'calendar_tooltip': 'Calendar View',
    'filter_tooltip': 'Filter',
    'sort_tooltip': 'Sort',
    'new_diary_fab': 'New Diary Entry',
    'delete_title': 'Delete Diary',
    'delete_message': 'Are you sure you want to delete this diary?\nDeleted diaries cannot be recovered.',
    'delete_button': 'Delete',
    // Image Save
    'image_save_title': 'Save Image',
    'image_save_message': 'Would you like to save this image to your gallery?',
    'image_save_success': 'Image saved to gallery',
    'image_save_failed': 'Unable to save image',
    'image_save_error': 'Error occurred while saving image',
    'image_save_hint': 'Press and hold the image to save it to your gallery',
    // Network Notification
    'network_offline_title': 'Offline Mode',
    'network_offline_message': 'AI image generation may fail.',
    // Diary Detail Page
    'diary_detail_title': 'Diary Detail',
    'tab_detail': 'Detail',
    'tab_history': 'Edit History',
    'tooltip_favorite_add': 'Add to Favorites',
    'tooltip_favorite_remove': 'Remove from Favorites',
    'tooltip_edit': 'Edit',
    'tooltip_share': 'Share',
    'tooltip_delete': 'Delete',
    'favorite_added': 'Added to favorites',
    'favorite_removed': 'Removed from favorites',
    'favorite_error': 'Error occurred while changing favorite status',
    'diary_deleted': 'Diary deleted',
    'diary_delete_failed': 'Failed to delete diary',
    'diary_delete_error': 'Error occurred while deleting diary',
    'diary_not_found': 'Diary not found',
    'diary_not_found_message': 'The requested diary does not exist or has been deleted',
    'diary_load_error': 'Error occurred while loading diary',
    'association_image_title': 'Associated Image',
    'association_image_generating': 'Generating associated image...',
    'association_image_generating_message': 'AI is generating an image based on your diary content.',
    'association_image_error': 'Unable to display associated image',
    'association_image_load_error': 'Unable to load image',
    'image_generation_failed': 'Image generation failed',
    'image_load_error': 'Error occurred while loading image',
    'generation_prompt': 'Generation Prompt',
    'emotion_label': 'Emotion',
    'style_label': 'Style',
    'topic_label': 'Topic',
    'generated_date': 'Generated',
    'info_title': 'Information',
    'word_count': 'Word Count',
    'created_date': 'Created',
    'modified_date': 'Modified',
    'tags_title': 'Tags',
    'time_morning': 'Morning',
    'time_day': 'Day',
    'time_evening': 'Evening',
    'time_night': 'Night',
    'retry_button': 'Retry',
    'back_to_list': 'Back to List',

    // Edit History (2 keys)
    'edit_history_empty': 'No edit history',
    'edit_history_empty_message': 'History will be recorded when you edit the diary',

    // Diary Save (1 key)
    'diary_saved': 'Diary saved successfully',

    // Mood (16 keys)
    'mood_happy': 'Happy',
    'mood_sad': 'Sad',
    'mood_angry': 'Angry',
    'mood_calm': 'Calm',
    'mood_excited': 'Excited',
    'mood_worried': 'Worried',
    'mood_tired': 'Tired',
    'mood_satisfied': 'Satisfied',
    'mood_disappointed': 'Disappointed',
    'mood_grateful': 'Grateful',
    'mood_lonely': 'Lonely',
    'mood_thrilled': 'Thrilled',
    'mood_depressed': 'Depressed',
    'mood_nervous': 'Nervous',
    'mood_comfortable': 'Comfortable',
    'mood_other': 'Other',

    // Weather (9 keys)
    'weather_sunny': 'Sunny',
    'weather_cloudy': 'Cloudy',
    'weather_rainy': 'Rainy',
    'weather_snowy': 'Snowy',
    'weather_windy': 'Windy',
    'weather_foggy': 'Foggy',
    'weather_hot': 'Hot',
    'weather_cold': 'Cold',
    'weather_other': 'Other',

    'sort_dialog_title': 'Sort By',
    'sort_date_desc': 'Newest First',
    'sort_date_asc': 'Oldest First',
    'sort_title_asc': 'Title (A-Z)',
    'sort_title_desc': 'Title (Z-A)',
    'sort_mood': 'By Mood',
    'sort_weather': 'By Weather',
    'error_load_diaries': 'Unable to load diaries',
    'error_unknown': 'An unknown error occurred',
    'empty_diaries_title': 'No diaries yet',
    'empty_diaries_subtitle': 'Write your first diary entry',
    'empty_diaries_action': 'Write Diary',

    // Statistics (7 keys)
    'statistics_title': 'Diary Statistics',
    'date_range_tooltip': 'Select Date Range',
    'period_title': 'Analysis Period',
    'preset_week': 'Last 1 Week',
    'preset_month': 'Last 1 Month',
    'preset_quarter': 'Last 3 Months',
    'preset_year': 'Last 1 Year',

    // Backup & Restore (49 keys)
    'backup_section_title': 'Backup & Restore',
    'create_backup_button': 'Create Backup',
    'restore_from_file_button': 'Restore from File',
    'auto_backup_title': 'Auto Backup',
    'backup_interval_label': 'Backup Interval: ',
    'interval_daily': 'Daily',
    'interval_3days': 'Every 3 Days',
    'interval_weekly': 'Weekly',
    'interval_biweekly': 'Bi-weekly',
    'interval_monthly': 'Monthly',
    'max_backups_label': 'Max Backups: ',
    'max_3': '3',
    'max_5': '5',
    'max_10': '10',
    'max_20': '20',
    'no_backups_title': 'No backups available',
    'no_backups_subtitle': 'Create your first backup',
    'available_backups_title': 'Available Backups',
    'created_date_label': 'Created',
    'size_label': 'Size',
    'includes_label': 'Includes',
    'includes_settings': 'Settings',
    'includes_profile': 'Profile',
    'includes_diary': 'Diary',
    'restore_action': 'Restore',
    'delete_action': 'Delete',
    'backup_success': 'Backup created successfully.',
    'backup_failed': 'Failed to create backup.',
    'backup_error': 'An error occurred while creating backup',
    'restore_success': 'Restore completed successfully.',
    'restore_failed': 'Failed to restore.',
    'restore_error': 'An error occurred during restore',
    'delete_success': 'Backup has been deleted.',
    'delete_failed': 'Failed to delete backup.',
    'delete_error': 'An error occurred while deleting backup',
    'load_error_backup': 'An error occurred while loading data',
    'file_picker_error': 'An error occurred while selecting file',
    'auto_backup_update_error': 'An error occurred while updating auto backup settings',
    'interval_update_error': 'An error occurred while setting backup interval',
    'max_backups_update_error': 'An error occurred while setting max backups',
    'restore_confirm_title': 'Restore Data',
    'restore_confirm_message': 'Current data will be overwritten with backup data.\nThis action cannot be undone.\n\nContinue?',
    'delete_confirm_title': 'Delete Backup',
    'delete_confirm_message': 'Are you sure you want to delete this backup?\nThis action cannot be undone.',
    'count_suffix': '',

    // Calendar (16 keys)
    'calendar': 'Calendar',
    'back': 'Back',
    'diary_statistics': 'Diary Statistics',
    'weekly_view': 'Weekly View',
    'monthly_view': 'Monthly View',
    'today': 'Today',
    'write_new_diary': 'Write New Diary',
    'calendar_legend_multiple_entries': 'Orange dots indicate 2 or more diary entries.',
    'please_select_date': 'Please select a date',
    'diary_count': '{count} diaries',
    'no_diary_on_this_day': 'No diary entries on this day',
    'write_diary': 'Write Diary',
    'diary_search_hint': 'Search diary...',
    'clear_search_tooltip': 'Clear search',
    'today_with_date': 'Today ({month}/{day})',
    'yesterday_with_date': 'Yesterday ({month}/{day})',
    'tomorrow_with_date': 'Tomorrow ({month}/{day})',
    'full_date': '{month}/{day}/{year}',

    // Statistics Widget (25 keys)
    'stats_overall_title': 'Overall Statistics',
    'stats_total_diaries': 'Total Diaries',
    'stats_total_diaries_unit': '{count}',
    'stats_current_streak': 'Current Streak',
    'stats_current_streak_unit': '{count} days',
    'stats_longest_streak': 'Longest Streak',
    'stats_longest_streak_unit': '{count} days',
    'stats_daily_average': 'Daily Average',
    'stats_daily_average_unit': '{count}',
    'stats_most_active_day': 'Most Active Day',
    'stats_most_active_day_unit': '{day}',
    'stats_most_active_month': 'Most Active Month',
    'stats_monthly_frequency': 'Monthly Frequency',
    'stats_weekly_frequency': 'Weekly Frequency',
    'stats_no_data': 'No data available',
    'stats_count_unit': '{count}',
    'stats_content_length_title': 'Content Length Statistics',
    'stats_average_characters': 'Average Characters',
    'stats_characters_unit': '{count} chars',
    'stats_average_words': 'Average Words',
    'stats_words_unit': '{count}',
    'stats_max_characters': 'Max Characters',
    'stats_min_characters': 'Min Characters',
    'stats_writing_time_title': 'Writing Time Statistics',
    'stats_time_count_unit': '{count} times',

    // Generation Count Widget (3 keys)
    'ai_image_generation': 'AI Image Generation',
    'remaining_count_label': 'Remaining: ',
    'count_times': 'times',

    // Memory Screen (14 keys)
    'memory_title': 'Memories',
    'memory_back_tooltip': 'Back',
    'memory_notifications_tooltip': 'Notification Settings',
    'memory_filter_tooltip': 'Filter',
    'memory_refresh_tooltip': 'Refresh',
    'memory_loading': 'Loading memories...',
    'memory_load_failed': 'Failed to load memories',
    'memory_unknown_error': 'An unknown error occurred',
    'memory_retry_button': 'Retry',
    'memory_empty_title': 'No memories yet',
    'memory_empty_description': 'Write diary entries to reminisce about past moments',
    'memory_write_diary_button': 'Write Diary',
    'memory_bookmarked': 'Bookmarked {title}',
    'memory_bookmark_removed': 'Removed bookmark from {title}',

    // App Intro Features (16 keys)
    'feature_ocr_title': 'OCR Text Extraction',
    'feature_ocr_desc': 'Capture handwritten notes and instantly convert them to text.',
    'feature_voice_title': 'Voice Recording',
    'feature_voice_desc': 'Transform your spoken thoughts into journal entries naturally.',
    'feature_emotion_title': 'Emotion Analysis',
    'feature_emotion_desc': 'Organize emotions from your entries and view them as statistics.',
    'feature_ai_image_title': 'AI Image Generation',
    'feature_ai_image_desc': 'Create emotional background images that match your diary mood.',
    'feature_search_title': 'Diary Search',
    'feature_search_desc': 'Quickly find entries by keywords and dates.',
    'feature_backup_title': 'Backup File Management',
    'feature_backup_desc': 'Export and import backup files to keep your data safe.',
    'feature_pin_title': 'PIN Security',
    'feature_pin_desc': 'Protect your personal diary with PIN lock security.',
    'feature_privacy_title': 'Privacy Screen',
    'feature_privacy_desc': 'Blur screen in background to protect your privacy.',

    // Emotion Arrow
    'emotion_arrow': '→',

    // Emotion Names
    'emotion_joy': 'Joy',
    'emotion_default': 'Default',
    'emotion_sadness': 'Sadness',
    'emotion_anger': 'Anger',
    'emotion_fear': 'Fear',
    'emotion_surprise': 'Surprise',
    'emotion_disgust': 'Disgust',
    'emotion_anticipation': 'Anticipation',
    'emotion_trust': 'Trust',

    // Privacy Policy Content
    'privacy_policy_content': '''**Privacy Policy**

This privacy policy applies to the Everydiary app (hereby referred to as "Application") for mobile devices that was created by Sunnydevstory (hereby referred to as "Service Provider") as a Freemium service. This service is intended for use "AS IS".

**Information Collection and Use**

The Application collects information when you download and use it. This information may include information such as

*   Your device's Internet Protocol address (e.g. IP address)

*   The pages of the Application that you visit, the time and date of your visit, the time spent on those pages

*   The time spent on the Application

*   The operating system you use on your mobile device

The Application does not gather precise information about the location of your mobile device.

The Application collects your device's location, which helps the Service Provider determine your approximate geographical location and make use of in below ways:

*   Geolocation Services: The Service Provider utilizes location data to provide features such as personalized content, relevant recommendations, and location-based services.

*   Analytics and Improvements: Aggregated and anonymized location data helps the Service Provider to analyze user behavior, identify trends, and improve the overall performance and functionality of the Application.

*   Third-Party Services: Periodically, the Service Provider may transmit anonymized location data to external services. These services assist them in enhancing the Application and optimizing their offerings.

The Service Provider may use the information you provided to contact you from time to time to provide you with important information, required notices and marketing promotions.

For a better experience, while using the Application, the Service Provider may require you to provide us with certain personally identifiable information, including but not limited to window98se@gmail.com. The information that the Service Provider request will be retained by them and used as described in this privacy policy.

**Third Party Access**

Only aggregated, anonymized data is periodically transmitted to external services to aid the Service Provider in improving the Application and their service. The Service Provider may share your information with third parties in the ways that are described in this privacy statement.

Please note that the Application utilizes third-party services that have their own Privacy Policy about handling data. Below are the links to the Privacy Policy of the third-party service providers used by the Application:

*   [Google Play Services](https://www.google.com/policies/privacy/)

*   [AdMob](https://support.google.com/admob/answer/6128543?hl=en)

The Service Provider may disclose User Provided and Automatically Collected Information:

*   as required by law, such as to comply with a subpoena, or similar legal process;

*   when they believe in good faith that disclosure is necessary to protect their rights, protect your safety or the safety of others, investigate fraud, or respond to a government request;

*   with their trusted services providers who work on their behalf, do not have an independent use of the information we disclose to them, and have agreed to adhere to the rules set forth in this privacy statement.

**Opt-Out Rights**

You can stop all collection of information by the Application easily by uninstalling it. You may use the standard uninstall processes as may be available as part of your mobile device or via the mobile application marketplace or network.

**Data Retention Policy**

The Service Provider will retain User Provided data for as long as you use the Application and for a reasonable time thereafter. If you'd like them to delete User Provided Data that you have provided via the Application, please contact them at window98se@gmail.com and they will respond in a reasonable time.

**Children**

The Service Provider does not use the Application to knowingly solicit data from or market to children under the age of 13.

The Application does not address anyone under the age of 13. The Service Provider does not knowingly collect personally identifiable information from children under 13 years of age. In the case the Service Provider discover that a child under 13 has provided personal information, the Service Provider will immediately delete this from their servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact the Service Provider (window98se@gmail.com) so that they will be able to take the necessary actions.

**Security**

The Service Provider is concerned about safeguarding the confidentiality of your information. The Service Provider provides physical, electronic, and procedural safeguards to protect information the Service Provider processes and maintains.

**Changes**

This Privacy Policy may be updated from time to time for any reason. The Service Provider will notify you of any changes to the Privacy Policy by updating this page with the new Privacy Policy. You are advised to consult this Privacy Policy regularly for any changes, as continued use is deemed approval of all changes.

This privacy policy is effective as of 2025-11-12

**Your Consent**

By using the Application, you are consenting to the processing of your information as set forth in this Privacy Policy now and as amended by us.

**Contact Us**

If you have any questions regarding privacy while using the Application, or have questions about the practices, please contact the Service Provider via email at window98se@gmail.com.

* * *

This privacy policy page was generated by [App Privacy Policy Generator](https://app-privacy-policy-generator.nisrulz.com/)''',

    // Terms of Service Content
    'terms_of_service_content': '''**Terms & Conditions**

These terms and conditions apply to the Everydiary app (hereby referred to as "Application") for mobile devices that was created by Sunnydevstory (hereby referred to as "Service Provider") as a Freemium service.

Upon downloading or utilizing the Application, you are automatically agreeing to the following terms. It is strongly advised that you thoroughly read and understand these terms prior to using the Application.

Unauthorized copying, modification of the Application, any part of the Application, or our trademarks is strictly prohibited. Any attempts to extract the source code of the Application, translate the Application into other languages, or create derivative versions are not permitted. All trademarks, copyrights, database rights, and other intellectual property rights related to the Application remain the property of the Service Provider.

The Service Provider is dedicated to ensuring that the Application is as beneficial and efficient as possible. As such, they reserve the right to modify the Application or charge for their services at any time and for any reason. The Service Provider assures you that any charges for the Application or its services will be clearly communicated to you.

The Application stores and processes personal data that you have provided to the Service Provider in order to provide the Service. It is your responsibility to maintain the security of your phone and access to the Application. The Service Provider strongly advise against jailbreaking or rooting your phone, which involves removing software restrictions and limitations imposed by the official operating system of your device. Such actions could expose your phone to malware, viruses, malicious programs, compromise your phone's security features, and may result in the Application not functioning correctly or at all.

Please note that the Application utilizes third-party services that have their own Terms and Conditions. Below are the links to the Terms and Conditions of the third-party service providers used by the Application:

*   [Google Play Services](https://policies.google.com/terms)

*   [AdMob](https://developers.google.com/admob/terms)

Please be aware that the Service Provider does not assume responsibility for certain aspects. Some functions of the Application require an active internet connection, which can be Wi-Fi or provided by your mobile network provider. The Service Provider cannot be held responsible if the Application does not function at full capacity due to lack of access to Wi-Fi or if you have exhausted your data allowance.

If you are using the application outside of a Wi-Fi area, please be aware that your mobile network provider's agreement terms still apply. Consequently, you may incur charges from your mobile provider for data usage during the connection to the application, or other third-party charges. By using the application, you accept responsibility for any such charges, including roaming data charges if you use the application outside of your home territory (i.e., region or country) without disabling data roaming. If you are not the bill payer for the device on which you are using the application, they assume that you have obtained permission from the bill payer.

Similarly, the Service Provider cannot always assume responsibility for your usage of the application. For instance, it is your responsibility to ensure that your device remains charged. If your device runs out of battery and you are unable to access the Service, the Service Provider cannot be held responsible.

In terms of the Service Provider's responsibility for your use of the application, it is important to note that while they strive to ensure that it is updated and accurate at all times, they do rely on third parties to provide information to them so that they can make it available to you. The Service Provider accepts no liability for any loss, direct or indirect, that you experience as a result of relying entirely on this functionality of the application.

The Service Provider may wish to update the application at some point. The application is currently available as per the requirements for the operating system (and for any additional systems they decide to extend the availability of the application to) may change, and you will need to download the updates if you want to continue using the application. The Service Provider does not guarantee that it will always update the application so that it is relevant to you and/or compatible with the particular operating system version installed on your device. However, you agree to always accept updates to the application when offered to you. The Service Provider may also wish to cease providing the application and may terminate its use at any time without providing termination notice to you. Unless they inform you otherwise, upon any termination, (a) the rights and licenses granted to you in these terms will end; (b) you must cease using the application, and (if necessary) delete it from your device.

**Changes to These Terms and Conditions**

The Service Provider may periodically update their Terms and Conditions. Therefore, you are advised to review this page regularly for any changes. The Service Provider will notify you of any changes by posting the new Terms and Conditions on this page.

These terms and conditions are effective as of 2025-11-12

**Contact Us**

If you have any questions or suggestions about the Terms and Conditions, please do not hesitate to contact the Service Provider at window98se@gmail.com.

* * *

This Terms and Conditions page was generated by [App Privacy Policy Generator](https://app-privacy-policy-generator.nisrulz.com/)''',
  };

  // ============== 일본어 ==============
  static const Map<String, String> _japanese = {
    // 共通
    'app_name': 'EveryDiary',
    'ok': 'OK',
    'confirm': '確認',
    'cancel': 'キャンセル',
    'save': '保存',
    'delete': '削除',
    'edit': '編集',
    'close': '閉じる',
    'yes': 'はい',
    'no': 'いいえ',
    'dont_show_again': '再表示しない',

    // 新スタイルのお知らせ
    'new_style_announcement_title': '新しいスタイルが追加されました！',
    'new_style_announcement_description': '絵本のような色鉛筆イラストスタイルを試してみてください。\n設定で変更できます。',

    // AdMobポリシー通知
    'ad_policy_notice_title': 'サービスのお知らせ',
    'ad_policy_notice_message': 'AdMobポリシー審査のため、広告視聴機能が一時的に制限されています。1月30日まで、毎日無料AI画像生成が2回にリセットされます。ポリシー審査完了後に通常に戻ります。',
    'ad_policy_notice_count_info': '毎日の無料AI画像生成：2回（自動リセット）',

    // 設定
    'settings': '設定',
    'settings_reset': '設定をリセット',
    'app_settings': 'アプリ設定',
    'thumbnail_style': 'サムネイルスタイル',
    'thumbnail_style_subtitle': 'AIサムネイルスタイルとキーワードを設定',
    'theme': 'テーマ',
    'font_size': 'フォントサイズ',
    'language': '言語',
    'language_select': '言語選択',
    'security_management': 'EveryDiaryセキュリティと管理',
    'username': 'ユーザー名',
    'username_not_set': '未設定',
    'pin_lock': 'PINロック',
    'pin_lock_enabled': 'アプリ起動時にPIN要求',
    'pin_lock_disabled': '無効',
    'pin_change': 'PIN変更',
    'pin_change_subtitle': '現在のPINを入力して新しいPINに変更',
    'recovery_question': '緊急復旧質問',
    'recovery_question_set': '設定済み',
    'recovery_question_not_set': '未設定',

    // PIN関連
    'pin_setup': 'PINロック設定',
    'pin_new': '新しいPIN（4桁の数字）',
    'pin_confirm': 'PIN確認',
    'pin_current': '現在のPIN',
    'pin_change_title': 'PIN変更',
    'pin_disable': 'PINロック解除',
    'pin_disable_message': 'PINロックを無効にすると、アプリ起動時の認証が不要になります。',
    'pin_disable_button': '無効化',
    'pin_error_length': '4桁の数字を入力してください',
    'pin_error_mismatch': 'PINが一致しません',
    'pin_error_new_mismatch': '新しいPINが一致しません',
    'pin_enabled_message': 'PINロックが有効になりました。',
    'pin_disabled_message': 'PINロックが無効になりました。',
    'pin_changed_message': 'PINが変更されました。',
    'pin_change_failed': 'PINの変更に失敗しました',

    // PINロック解除画面
    'pin_unlock_title': 'ロック解除',
    'pin_unlock_subtitle': 'アプリにアクセスするには4桁のPINを入力してください。',
    'pin_unlock_button': 'ロック解除',
    'pin_unlock_clear': 'クリア',
    'pin_unlock_recovery': '緊急復旧',
    'pin_unlock_error_length': '4桁のPINを入力してください',
    'pin_unlock_error_incorrect': 'PINが正しくありません。もう一度お試しください。',
    'pin_unlock_error_locked': '試行回数が多すぎてロックされました。',
    'pin_unlock_locked_until': 'ロック中: {time}まで試行できません。',
    'pin_unlock_remaining_attempts': '残り試行回数: {count}回',
    'pin_unlock_unlocked': 'ロック解除済み',
    'pin_unlock_time_minutes': '{minutes}分{seconds}秒',
    'pin_unlock_time_seconds': '{seconds}秒',
    'pin_unlock_recovery_warning_title': '⚠️ 緊急復旧質問未設定',
    'pin_unlock_recovery_warning_message': 'PINを忘れるとアプリにアクセスできません。\n設定で緊急復旧質問を登録してください。',

    // 復旧質問
    'recovery_question_setup': '緊急復旧質問設定',
    'recovery_question_label': 'セキュリティ質問',
    'recovery_question_hint': '例：私だけが知っている場所は？',
    'recovery_answer': '答え',
    'recovery_answer_confirm': '答えの確認',
    'recovery_question_error_empty': 'セキュリティ質問を入力してください',
    'recovery_answer_error_empty': '答えを入力してください',
    'recovery_answer_error_mismatch': '答えが一致しません',
    'recovery_question_saved': '緊急復旧質問が保存されました。',
    'recovery_question_deleted': '緊急復旧質問が削除されました。',
    'recovery_question_delete': '削除',

    // PIN復旧ダイアログ
    'pin_recovery_title': '緊急復旧',
    'pin_recovery_question_label': 'セキュリティ質問',
    'pin_recovery_answer_input': '答えを入力',
    'pin_recovery_new_pin': '新しいPIN（4桁）',
    'pin_recovery_confirm_pin': '新しいPINの確認',
    'pin_recovery_error_answer_empty': 'セキュリティ質問の答えを入力してください',
    'pin_recovery_error_pin_length': '4桁の数字PINを入力してください',
    'pin_recovery_error_pin_mismatch': '新しいPINが一致しません',
    'pin_recovery_success': '新しいPINが設定されました。',
    'pin_recovery_failed': '復旧に失敗しました: {error}',

    // ユーザー名
    'username_change': 'ユーザー名変更',
    'username_label': '名前',
    'username_hint': '例：山田太郎',
    'username_error_empty': '名前を入力してください',
    'username_updated': 'ユーザー名が更新されました。',

    // テーマ
    'theme_system': 'システム設定',
    'theme_light': 'ライト',
    'theme_dark': 'ダーク',

    // フォントサイズ
    'font_small': '小',
    'font_medium': '中',
    'font_large': '大',
    'font_extra_large': '特大',

    // イントロ動画
    'show_intro_video': '起動時にイントロ動画を表示',
    'show_intro_video_subtitle': 'アプリ起動時にイントロ動画を表示します',

    // 画像生成
    'image_generation_count': 'AI画像生成回数',
    'image_generation_description': 'AIが生成する素晴らしい日記画像をもっと作りましょう！',
    'watch_ad_for_1_time': '広告を見てもう1回ゲット',
    'watch_ad_subtitle': '短い広告を見て無料でゲット',
    'ad_loading': '広告読み込み中...',
    'ad_wait': 'しばらくお待ちください',
    'ad_reward_success': '広告視聴完了！2回の生成回数が追加されました。',

    // 思い出
    'memory_type_all': '全体',
    'memory_type_yesterday': '昨日',
    'memory_type_one_week_ago': '1週間前',
    'memory_type_one_month_ago': '1ヶ月前',
    'memory_type_one_year_ago': '1年前',
    'memory_type_past_today': '過去の今日',
    'memory_type_same_time': '同じ時間',
    'memory_type_seasonal': '季節別',
    'memory_type_special_date': '特別な日',
    'memory_type_similar_tags': '関連タグ',
    'memory_reason_yesterday': '昨日の記録',
    'memory_reason_one_week_ago': '1週間前の記録',
    'memory_reason_one_month_ago': '1ヶ月前の記録',
    'memory_reason_one_year_ago': '1年前の記録',
    'memory_reason_past_today': '過去のこの日の記録',
    'memory_reason_same_time': 'この時間の記録',
    'memory_reason_seasonal': '季節の記録',
    'memory_reason_special_date': '特別な日の記録',
    'memory_reason_similar_tags': '似たタグの記録',
    'memory_bookmark': 'ブックマーク',
    'memory_bookmark_remove': 'ブックマーク解除',

    // OCR
    'ocr_camera_title': '写真撮影',
    'ocr_auto_detect': '自動検出',
    'ocr_language_korean': '韓国語',
    'ocr_language_english': 'English',
    'ocr_language_japanese': '日本語',
    'ocr_language_chinese': '中国語',

    // 音声認識
    'speech_language_korean': '韓国語',
    'speech_language_english': 'English',
    'speech_language_japanese': '日本語',
    'speech_language_chinese': '中国語',
    'speech_initializing': '音声認識を初期化しています...',
    'speech_ready': 'マイクボタンをタップして音声認識を開始してください',
    'speech_listening': '話してください。終わったらもう一度ボタンをタップしてください',
    'speech_processing': '音声をテキストに変換しています...',
    'speech_completed': '音声認識が完了しました',
    'speech_error': '音声認識中にエラーが発生しました。もう一度お試しください',
    'speech_cancelled': '音声認識がキャンセルされました',
    'speech_error_title': '音声認識エラー',
    'speech_cancel': 'キャンセル',
    'speech_retry': '再試行',
    'speech_error_solutions': '解決方法:',
    'speech_error_check_permission': '• マイクの権限が許可されているか確認してください',
    'speech_error_check_internet': '• インターネット接続を確認してください',
    'speech_error_quiet_environment': '• 静かな環境で再試行してください',
    'speech_error_check_microphone': '• マイクが正常に動作しているか確認してください',
    'speech_permission_title': 'マイク権限が必要',
    'speech_permission_description': '音声認識機能を使用するにはマイク権限が必要です。',
    'speech_permission_usage': 'この権限は次の目的でのみ使用されます:',
    'speech_permission_convert': '• 音声をテキストに変換',
    'speech_permission_diary': '• 日記作成時の音声入力',
    'speech_permission_accuracy': '• 音声認識精度の向上',
    'speech_permission_deny': '拒否',
    'speech_permission_allow': '許可',
    'speech_init_failed': '音声認識サービスの初期化に失敗しました。',
    'speech_init_error': '初期化中にエラーが発生しました',
    'speech_permission_required': 'マイク権限が必要です。',
    'speech_start_failed': '音声認識の開始に失敗しました。',
    'speech_start_error': '音声認識の開始中にエラーが発生しました',
    'speech_stop_error': '音声認識の停止中にエラーが発生しました',
    'speech_cancel_error': '音声認識のキャンセル中にエラーが発生しました',

    // 音声録音
    'voice_recording_title': '音声録音',
    'voice_recording_init_failed': '音声認識サービスを初期化できません。',
    'voice_recording_start_failed': '音声録音を開始できません。',
    'voice_recording_recording': '録音中...',
    'voice_recording_paused': '一時停止中',
    'voice_recording_resume_prompt': '録音を再開してください',
    'voice_recording_start_prompt': '録音を開始してください',
    'voice_recording_recognized_text': '認識されたテキスト:',
    'voice_recording_stop': '録音停止',
    'voice_recording_resume': '録音再開',
    'voice_recording_start': '録音開始',
    'voice_recording_cancel': 'キャンセル',
    'voice_recording_confirm': '確認',

    // 権限リクエスト (Permission Request)
    'permission_request_title': '権限設定',
    'permission_request_subtitle': 'アプリ機能を使用するために以下の権限が必要です',
    'permission_camera_title': 'カメラ権限',
    'permission_camera_description': 'OCRテキスト認識機能を使用するためにカメラアクセスが必要です。',
    'permission_microphone_title': 'マイク権限',
    'permission_microphone_description': '音声で日記を作成するためにマイクアクセスが必要です。',
    'permission_allow_all': 'すべて許可',
    'permission_skip': '後で設定',
    'permission_continue': '続ける',
    'permission_granted': '許可済み',
    'permission_denied': '拒否',
    'permission_open_settings': '設定を開く',
    'permission_required_features': '一部の機能には権限が必要です',
    'permission_camera_rationale': '写真を撮影してテキストを認識するにはカメラ権限が必要です。',
    'permission_microphone_rationale': '音声で日記を作成するにはマイク権限が必要です。',
    'permission_settings_guide': '権限が永久に拒否されました。設定から権限を許可してください。',

    // 日付表示
    'date_today': '今日',
    'date_yesterday': '昨日',

    // 通知
    'notifications': '通知',
    'daily_reminder': '日記作成リマインダー',
    'daily_reminder_subtitle': '毎日日記を書くことをお知らせします',
    'reminder_time': 'リマインダー時間',

    // データ管理
    'data_management': 'データ管理',

    // 情報
    'info': '情報',
    'app_version': 'アプリバージョン',
    'privacy_policy': 'プライバシーポリシー',
    'privacy_policy_subtitle': 'プライバシーポリシーを確認',
    'terms_of_service': '利用規約',
    'terms_of_service_subtitle': 'サービス利用規約を確認',
    'app_description': 'AIが描く美しい画像と共に、大切な瞬間を記録しましょう。',
    'app_developer': '開発者: EveryDiary',
    'app_contact': 'お問い合わせ: window98se@gmail.com',

    // バージョン1.0.3 更新内容
    'version_1_0_3_title': 'v1.0.3 更新内容',
    'version_1_0_3_change_1': 'Android 15 画面表示の互換性を改善',
    'version_1_0_3_change_2': '回想リマインダーの時間設定を修正',
    'version_1_0_3_change_3': 'OCRカメラの画質を向上（デバイスカメラを使用）',
    'version_1_0_3_change_4': 'ゲームキャラクターのサムネイルスタイルを追加（ピクセルアート）',
    'version_1_0_3_change_5': 'UIの簡素化と安定性の向上',

    // バージョン1.0.4 更新内容
    'version_1_0_4_title': 'v1.0.4 更新内容',
    'version_1_0_4_change_1': '日記テキストの読みやすさを向上（フォント色改善）',
    'version_1_0_4_change_2': '新しい「サンタと一緒に」サムネイルスタイルを追加',
    'version_1_0_4_change_3': 'サムネイルスタイル選択画面を3列グリッドUIに改編',
    'version_1_0_4_change_4': '日記作成ページにサムネイルスタイルボタンを追加',
    'version_1_0_4_change_5': '広告報酬を1回から2回に増加',
    'version_1_0_4_change_6': 'Android 15 エッジ・トゥ・エッジ互換性を改善',

    // 性別関連
    'user_gender': '性別',
    'select_gender': '性別を選択',
    'gender_male': '男性',
    'gender_female': '女性',
    'gender_none': '指定なし',

    // 色鉛筆スタイル
    'style_color_pencil': '色鉛筆',

    // フェルトウールスタイル
    'style_felted_wool': 'フェルトウール',

    // 3Dアニメーションスタイル
    'style_3d_animation': '3Dアニメーション',

    // 新スタイル追加ポップアップ
    'new_styles_popup_title': '新しいスタイル追加！',
    'new_styles_popup_message': 'フェルトウールと3Dアニメーションスタイルが追加されました。設定で確認してみてください！',
    'new_styles_popup_dont_show': '次回から表示しない',
    'new_styles_popup_check': '確認する',

    // バージョン1.1.1 更新内容
    'version_1_1_1_title': 'v1.1.1 更新内容',
    'version_1_1_1_change_1': '新しいサムネイルスタイル追加：フェルトウール',
    'version_1_1_1_change_2': '新しいサムネイルスタイル追加：3Dアニメーション',

    // バージョン1.1.0 更新内容
    'version_1_1_0_title': 'v1.1.0 更新内容',
    'version_1_1_0_change_1': 'ユーザー性別設定を追加（AI画像に反映）',
    'version_1_1_0_change_2': '新しいサムネイルスタイル追加：色鉛筆',
    'version_1_1_0_change_3': '軽微なバグを修正しました',

    // バージョン1.0.9 更新内容
    'version_1_0_9_title': 'v1.0.9 更新内容',
    'version_1_0_9_change_1': '新しいサムネイルスタイル追加：子供の絵',
    'version_1_0_9_change_2': '新しいサムネイルスタイル追加：フィギュア',

    // バージョン1.0.8 更新内容
    'version_1_0_8_title': 'v1.0.8 更新内容',
    'version_1_0_8_change_1': 'AI生成コンテンツポリシー対応',

    // バージョン1.0.7 更新内容
    'version_1_0_7_title': 'v1.0.7 更新内容',
    'version_1_0_7_change_1': 'ホーム画面の背景画像更新時にUIが消えるバグを修正',

    // AI コンテンツ報告機能
    'report_ai_content': 'AIコンテンツを報告',
    'report_description': '不適切または不快なAI生成コンテンツを見つけましたか？以下から報告理由を選択してください。',
    'report_select_reason': '報告理由を選択',
    'report_reason_inappropriate': '不適切なコンテンツ',
    'report_reason_offensive': '不快なコンテンツ',
    'report_reason_misleading': '誤解を招くコンテンツ',
    'report_reason_copyright': '著作権侵害',
    'report_reason_other': 'その他',
    'report_additional_details': '追加説明（任意）',
    'report_details_hint': '報告に関する追加説明を入力してください...',
    'report_submit': '報告する',
    'report_submitted': '報告が受理されました。確認後、対応いたします。',
    'report_error': '報告処理中にエラーが発生しました',
    'report_email_error': 'メールアプリを開けません。window98se@gmail.comに直接ご連絡ください。',
    'report_email_subject': '[EveryDiary] AIコンテンツ報告',
    'report_reason': '報告理由',
    'report_details': '追加説明',
    'report_no_details': '追加説明なし',
    'report_image_info': '画像情報',
    'report_image_preview': '報告対象の画像',
    'report_prompt_label': '生成プロンプト',
    'report_agree_share_image': '報告のために画像とプロンプトを共有することに同意します',
    'report_send_to': '報告先',

    // バージョン1.0.6 更新内容
    'version_1_0_6_title': 'v1.0.6 更新内容',
    'version_1_0_6_change_1': 'アプリ起動時にイントロ動画を追加',
    'version_1_0_6_change_2': 'AdMobポリシー審査期間中、毎日2回のAI画像生成が自動リセット',
    'version_1_0_6_change_3': 'コード最適化と安定性の改善',

    // バージョン1.0.5 更新内容
    'version_1_0_5_title': 'v1.0.5 更新内容',
    'version_1_0_5_change_1': '日記テキストの読みやすさを向上（フォント色改善）',
    'version_1_0_5_change_2': '新しい「サンタと一緒に」サムネイルスタイルを追加',
    'version_1_0_5_change_3': 'サムネイルスタイル選択画面を3列グリッドUIに改編',
    'version_1_0_5_change_4': '日記作成ページにサムネイルスタイルボタンを追加',
    'version_1_0_5_change_5': '広告報酬を1回から2回に増加',
    'version_1_0_5_change_6': 'Android 15 エッジ・トゥ・エッジ互換性を改善',
    'version_1_0_5_change_7': 'アプリのサイズを最適化しました',
    'version_1_0_5_change_8': '韓国語/英語/日本語以外の177カ国をターゲットに追加しました',

    // ===== NEW TRANSLATIONS =====

    // Onboarding (14 keys)
    'welcome_title': 'EveryDiaryへようこそ！',
    'setup_subtitle': 'アプリで使用する名前とロックオプションを設定してください。',
    'name_label': '名前',
    'name_hint': '例：山田太郎',
    'name_required': '名前を入力してください',
    'name_max_length': '名前は24文字以内で入力してください',
    'pin_lock_title': 'アプリ起動時にPINロックを使用',
    'pin_lock_subtitle': 'アプリを開く際に4桁のPINを入力するように設定します。',
    'pin_label': 'PIN（4桁の数字）',
    'pin_required': '4桁の数字を入力してください',
    'pin_numbers_only': '数字のみ入力できます',
    'pin_confirm_label': 'PIN確認',
    'pin_mismatch': 'PINが一致しません',
    'start_button': '始める',
    'setup_save_failed': '設定の保存に失敗しました',

    // Home Screen (11 keys)
    'home_greeting': '{name}さん、こんにちは 👋',
    'home_subtitle': '今日の瞬間を記録し、AI画像で感情を残しましょう。',
    'quick_actions_title': 'クイックアクション',
    'new_diary': '新しい日記を書く',
    'view_diaries': '日記を見る',
    'statistics_action': '日記統計',
    'memory_notifications': '思い出通知設定',
    'app_intro_title': 'アプリ紹介',
    'fallback_features_title': 'EveryDiary主な機能',
    'fallback_features_list': 'OCR · 音声録音 · 感情分析 · AI画像 · バックアップ · PINセキュリティ · 画面プライバシー',
    'diary_author': '日記作成者',

    // Error Page (4 keys)
    'error_title': 'エラー',
    'page_not_found': 'ページが見つかりません',
    'page_not_found_subtitle': 'リクエストされたページは存在しません',
    'back_to_home': 'ホームに戻る',

    // Privacy & Terms (2 keys)
    'privacy_policy_title': 'プライバシーポリシー',
    'terms_of_service_title': '利用規約',

    // Diary Write Screen (49 keys)
    'diary_write_title': '日記作成',
    'save_tooltip': '保存',
    'thumbnail_style_tooltip': 'サムネイルスタイル設定',
    'exit_without_save_title': '保存せずに終了しますか？',
    'exit_without_save_message': '作成中の内容は保存されません。',
    'exit': '終了',
    'title_label': 'タイトル',
    'title_hint': '今日の日記タイトルを入力',
    'title_required': 'タイトルを入力してください',
    'date_label': '日付',
    'emotion_analysis_label': '感情分析',
    'emotion_analyzing': '感情を分析中...',
    'ocr_button': 'OCR',
    'voice_recording_button': '音声録音',
    'save_button': '日記を保存',
    'saved_success': '日記が保存されました。',
    'save_failed': '保存失敗',
    'load_error': '日記の読み込み中にエラーが発生しました',
    'load_timeout': '日記の読み込みがタイムアウトしました。もう一度お試しください。',
    'retry': '再試行',
    'text_add_error': 'テキスト追加中にエラーが発生しました',
    'thumbnail_empty_content': '内容が空のためサムネイルを生成できません。',
    'thumbnail_no_diary': '編集中の日記がないため再生成をスキップします。',
    'thumbnail_regenerating': 'サムネイルを再生成中です。お待ちください。',
    'ocr_success': 'テキスト認識完了',
    'ocr_cancelled': 'テキスト認識がキャンセルされました',
    'ocr_unavailable': 'OCR機能を使用できません',
    'camera_permission_error': 'カメラにアクセスできません。権限を確認してください。',
    'camera_permission_required': 'カメラ権限が必要です。',
    'voice_error': '音声録音エラー',
    'voice_text_added': '音声テキストが追加されました。',
    'voice_text_add_failed': '音声テキストの追加に失敗しました。',
    'invalid_diary_id': '無効な日記IDです',
    'content_placeholder': 'ここに内容を入力してください...',
    'characters': '文字',
    'diary_content_placeholder': '今日の物語を記録してみてください...',
    'editor_undo_tooltip': '元に戻す',
    'editor_redo_tooltip': 'やり直す',
    'editor_bold_tooltip': '太字',
    'editor_italic_tooltip': '斜体',
    'editor_underline_tooltip': '下線',
    'editor_bulleted_list_tooltip': '箇条書きリスト',
    'editor_numbered_list_tooltip': '番号付きリスト',
    'editor_align_left_tooltip': '左揃え',
    'editor_align_center_tooltip': '中央揃え',
    'editor_align_right_tooltip': '右揃え',

    // Thumbnail Style (24 keys)
    'thumbnail_dialog_title': 'サムネイルスタイルのカスタマイズ',
    'thumbnail_dialog_subtitle': 'AIサムネイルスタイルと補正値を調整して好みを反映させます。',
    'style_select_title': 'スタイル選択',
    'detail_adjust_title': '詳細調整',
    'brightness_label': '明るさ',
    'contrast_label': 'コントラスト',
    'saturation_label': '彩度',
    'blur_radius_label': 'ぼかし半径',
    'overlay_color_label': 'オーバーレイ色',
    'overlay_opacity_label': 'オーバーレイ透明度',
    'auto_optimization_title': '自動最適化',
    'auto_optimization_subtitle': '分析結果に基づいてプロンプトを自動補正します',
    'manual_keyword_title': 'カスタムキーワード',
    'manual_keyword_subtitle': 'AIプロンプトに常に含まれるキーワードを最大5個まで追加できます。',
    'keyword_label': '手動キーワード',
    'keyword_hint': '例：パステルトーン、夜景',
    'keyword_add_button': '追加',
    'keyword_required': 'キーワードを入力してください。',
    'keyword_max_length': 'キーワードは24文字以内で入力してください。',
    'keyword_duplicate': '既に追加されたキーワードです。',
    'keyword_max_count': 'キーワードは最大5個まで登録できます。',
    'keyword_save_failed': 'キーワードを保存できませんでした。もう一度お試しください。',
    'keyword_empty_list': '登録されたキーワードがありません。',
    'keyword_clear_all': 'すべて削除',

    // Thumbnail Styles (12 keys)
    'style_chibi': '3等身漫画',
    'style_cute': 'かわいい',
    'style_pixel_game': 'ゲームキャラクター',
    'style_realistic': 'リアル',
    'style_cartoon': '漫画',
    'style_watercolor': '水彩画',
    'style_oil': '油絵',
    'style_sketch': 'スケッチ',
    'style_digital': 'デジタルアート',
    'style_vintage': 'ビンテージ',
    'style_modern': 'モダン',
    'style_santa_together': 'サンタと一緒に',
    'style_child_draw': '子供の絵',
    'style_figure': 'フィギュア',

    // Memory Notification Settings (25 keys)
    'memory_notification_settings_title': '思い出通知設定',
    'memory_notification_settings_loading': '設定を読み込み中...',
    'memory_notification_settings_load_error': '設定の読み込みに失敗しました',
    'memory_notification_permission_granted': '通知権限が許可されました',
    'memory_notification_permission_denied': '通知権限が拒否されました',
    'memory_notification_scheduled': '思い出通知が設定されました',
    'memory_notification_schedule_error': '通知設定中にエラーが発生しました',
    'memory_notification_toggle_title': '思い出通知',
    'memory_notification_toggle_description': '過去の日記を思い出すための通知を受け取ります',
    'memory_notification_time_title': '通知時刻',
    'memory_notification_time_label': '通知を受け取る時刻',
    'memory_notification_types_title': '通知タイプ',
    'memory_notification_yesterday_title': '昨日の記録',
    'memory_notification_yesterday_description': '昨日書いた日記を思い出します',
    'memory_notification_one_week_ago_title': '一週間前の記録',
    'memory_notification_one_week_ago_description': '一週間前に書いた日記を思い出します',
    'memory_notification_one_month_ago_title': '一ヶ月前の記録',
    'memory_notification_one_month_ago_description': '一ヶ月前に書いた日記を思い出します',
    'memory_notification_one_year_ago_title': '一年前の記録',
    'memory_notification_one_year_ago_description': '一年前に書いた日記を思い出します',
    'memory_notification_past_today_title': '過去の今日',
    'memory_notification_past_today_description': '昨年、一昨年の同じ日の記録を思い出します',
    'memory_notification_permission_title': '通知権限',
    'memory_notification_permission_granted_status': '通知権限が許可されました',
    'memory_notification_permission_required': '通知権限が必要です',
    'memory_notification_permission_request_button': '権限をリクエスト',
    'memory_notification_time_selection_title': '通知時刻を選択',
    'cancel_button': 'キャンセル',
    'confirm_button': '確認',

    // Diary List (21 keys)
    'my_diary': '私の日記',
    'back_tooltip': '戻る',
    'calendar_tooltip': 'カレンダー表示',
    'filter_tooltip': 'フィルター',
    'sort_tooltip': '並び替え',
    'new_diary_fab': '新しい日記を作成',
    'delete_title': '日記削除',
    'delete_message': 'この日記を削除しますか？\n削除した日記は復元できません。',
    'delete_button': '削除',
    // 画像保存
    'image_save_title': '画像保存',
    'image_save_message': 'この画像をギャラリーに保存しますか？',
    'image_save_success': '画像がギャラリーに保存されました',
    'image_save_failed': '画像を保存できません',
    'image_save_error': '画像保存中にエラーが発生しました',
    'image_save_hint': '画像を長押ししてギャラリーに保存できます',
    // ネットワーク通知
    'network_offline_title': 'オフラインモード',
    'network_offline_message': 'AI画像生成が失敗する可能性があります。',
    // 日記詳細ページ
    'diary_detail_title': '日記詳細',
    'tab_detail': '詳細内容',
    'tab_history': '編集履歴',
    'tooltip_favorite_add': 'お気に入りに追加',
    'tooltip_favorite_remove': 'お気に入りから削除',
    'tooltip_edit': '編集',
    'tooltip_share': '共有',
    'tooltip_delete': '削除',
    'favorite_added': 'お気に入りに追加されました',
    'favorite_removed': 'お気に入りから削除されました',
    'favorite_error': 'お気に入り状態の変更中にエラーが発生しました',
    'diary_deleted': '日記が削除されました',
    'diary_delete_failed': '日記の削除に失敗しました',
    'diary_delete_error': '日記削除中にエラーが発生しました',
    'diary_not_found': '日記が見つかりません',
    'diary_not_found_message': 'ご要望の日記が存在しないか、削除されました',
    'diary_load_error': '日記の読み込み中にエラーが発生しました',
    'association_image_title': '日記連想画像',
    'association_image_generating': '日記連想画像を生成中...',
    'association_image_generating_message': '日記の内容に基づいてAI画像を生成しています。',
    'association_image_error': '日記連想画像を表示できません',
    'association_image_load_error': '画像を読み込めません',
    'image_generation_failed': '画像生成に失敗しました',
    'image_load_error': '画像の読み込み中にエラーが発生しました',
    'generation_prompt': '生成プロンプト',
    'emotion_label': '感情',
    'style_label': 'スタイル',
    'topic_label': 'トピック',
    'generated_date': '生成日',
    'info_title': '情報',
    'word_count': '単語数',
    'created_date': '作成日',
    'modified_date': '修正日',
    'tags_title': 'タグ',
    'time_morning': '朝',
    'time_day': '昼',
    'time_evening': '夕方',
    'time_night': '夜',
    'retry_button': '再試行',
    'back_to_list': 'リストに戻る',

    // 編集履歴 (2 keys)
    'edit_history_empty': '編集履歴がありません',
    'edit_history_empty_message': '日記を編集すると履歴が記録されます',

    // 日記保存 (1 key)
    'diary_saved': '日記が保存されました',

    // 気分 (16 keys)
    'mood_happy': '幸せ',
    'mood_sad': '悲しい',
    'mood_angry': '怒り',
    'mood_calm': '穏やか',
    'mood_excited': 'ときめき',
    'mood_worried': '心配',
    'mood_tired': '疲れた',
    'mood_satisfied': '満足',
    'mood_disappointed': '失望',
    'mood_grateful': '感謝',
    'mood_lonely': '寂しい',
    'mood_thrilled': '興奮',
    'mood_depressed': '憂鬱',
    'mood_nervous': '緊張',
    'mood_comfortable': '快適',
    'mood_other': 'その他',

    // 天気 (9 keys)
    'weather_sunny': '晴れ',
    'weather_cloudy': '曇り',
    'weather_rainy': '雨',
    'weather_snowy': '雪',
    'weather_windy': '風',
    'weather_foggy': '霧',
    'weather_hot': '猛暑',
    'weather_cold': '寒波',
    'weather_other': 'その他',

    'sort_dialog_title': '並び替え基準',
    'sort_date_desc': '最新順',
    'sort_date_asc': '古い順',
    'sort_title_asc': 'タイトル順（A-Z）',
    'sort_title_desc': 'タイトル順（Z-A）',
    'sort_mood': '気分順',
    'sort_weather': '天気順',
    'error_load_diaries': '日記を読み込めません',
    'error_unknown': '不明なエラーが発生しました',
    'empty_diaries_title': 'まだ日記がありません',
    'empty_diaries_subtitle': '最初の日記を書いてみましょう',
    'empty_diaries_action': '日記を書く',

    // Statistics (7 keys)
    'statistics_title': '日記統計',
    'date_range_tooltip': '日付範囲選択',
    'period_title': '分析期間',
    'preset_week': '最近1週間',
    'preset_month': '最近1ヶ月',
    'preset_quarter': '最近3ヶ月',
    'preset_year': '最近1年',

    // Backup & Restore (49 keys)
    'backup_section_title': 'バックアップと復元',
    'create_backup_button': 'バックアップ作成',
    'restore_from_file_button': 'ファイルから復元',
    'auto_backup_title': '自動バックアップ',
    'backup_interval_label': 'バックアップ周期: ',
    'interval_daily': '毎日',
    'interval_3days': '3日ごと',
    'interval_weekly': '週間',
    'interval_biweekly': '2週間ごと',
    'interval_monthly': '月間',
    'max_backups_label': '最大バックアップ数: ',
    'max_3': '3個',
    'max_5': '5個',
    'max_10': '10個',
    'max_20': '20個',
    'no_backups_title': 'バックアップがありません',
    'no_backups_subtitle': '最初のバックアップを作成してみましょう',
    'available_backups_title': '利用可能なバックアップ',
    'created_date_label': '作成日',
    'size_label': 'サイズ',
    'includes_label': '含む',
    'includes_settings': '設定',
    'includes_profile': 'プロフィール',
    'includes_diary': '日記',
    'restore_action': '復元',
    'delete_action': '削除',
    'backup_success': 'バックアップが正常に作成されました。',
    'backup_failed': 'バックアップの作成に失敗しました。',
    'backup_error': 'バックアップ作成中にエラーが発生しました',
    'restore_success': '復元が正常に完了しました。',
    'restore_failed': '復元に失敗しました。',
    'restore_error': '復元中にエラーが発生しました',
    'delete_success': 'バックアップが削除されました。',
    'delete_failed': 'バックアップの削除に失敗しました。',
    'delete_error': 'バックアップ削除中にエラーが発生しました',
    'load_error_backup': 'データ読み込み中にエラーが発生しました',
    'file_picker_error': 'ファイル選択中にエラーが発生しました',
    'auto_backup_update_error': '自動バックアップ設定の更新中にエラーが発生しました',
    'interval_update_error': 'バックアップ周期設定中にエラーが発生しました',
    'max_backups_update_error': '最大バックアップ数設定中にエラーが発生しました',
    'restore_confirm_title': 'データ復元',
    'restore_confirm_message': '現在のデータがバックアップデータで上書きされます。\nこの操作は元に戻せません。\n\n続けますか？',
    'delete_confirm_title': 'バックアップ削除',
    'delete_confirm_message': 'バックアップを削除しますか？\nこの操作は元に戻せません。',
    'count_suffix': '個',

    // Calendar (16 keys)
    'calendar': 'カレンダー',
    'back': '戻る',
    'diary_statistics': '日記統計',
    'weekly_view': '週間表示',
    'monthly_view': '月間表示',
    'today': '今日',
    'write_new_diary': '新しい日記を作成',
    'calendar_legend_multiple_entries': 'オレンジ色の点は2件以上の日記があります。',
    'please_select_date': '日付を選択してください',
    'diary_count': '{count}件の日記',
    'no_diary_on_this_day': 'この日には日記がありません',
    'write_diary': '日記を書く',
    'diary_search_hint': '日記を検索...',
    'clear_search_tooltip': '検索をクリア',
    'today_with_date': '今日（{month}月{day}日）',
    'yesterday_with_date': '昨日（{month}月{day}日）',
    'tomorrow_with_date': '明日（{month}月{day}日）',
    'full_date': '{year}年{month}月{day}日',

    // Statistics Widget (25 keys)
    'stats_overall_title': '全体統計',
    'stats_total_diaries': '総日記数',
    'stats_total_diaries_unit': '{count}件',
    'stats_current_streak': '現在の連続',
    'stats_current_streak_unit': '{count}日',
    'stats_longest_streak': '最長連続',
    'stats_longest_streak_unit': '{count}日',
    'stats_daily_average': '1日平均',
    'stats_daily_average_unit': '{count}件',
    'stats_most_active_day': '最も活発な曜日',
    'stats_most_active_day_unit': '{day}曜日',
    'stats_most_active_month': '最も活発な月',
    'stats_monthly_frequency': '月別作成頻度',
    'stats_weekly_frequency': '週別作成頻度',
    'stats_no_data': 'データがありません',
    'stats_count_unit': '{count}件',
    'stats_content_length_title': '日記の長さ統計',
    'stats_average_characters': '平均文字数',
    'stats_characters_unit': '{count}文字',
    'stats_average_words': '平均単語数',
    'stats_words_unit': '{count}個',
    'stats_max_characters': '最大文字数',
    'stats_min_characters': '最小文字数',
    'stats_writing_time_title': '作成時間帯統計',
    'stats_time_count_unit': '{count}回',

    // Generation Count Widget (3 keys)
    'ai_image_generation': 'AI画像生成',
    'remaining_count_label': '残り回数: ',
    'count_times': '回',

    // Memory Screen (14 keys)
    'memory_title': '思い出',
    'memory_back_tooltip': '戻る',
    'memory_notifications_tooltip': '通知設定',
    'memory_filter_tooltip': 'フィルター',
    'memory_refresh_tooltip': '更新',
    'memory_loading': '思い出を読み込んでいます...',
    'memory_load_failed': '思い出の読み込みに失敗しました',
    'memory_unknown_error': '不明なエラーが発生しました',
    'memory_retry_button': '再試行',
    'memory_empty_title': 'まだ思い出がありません',
    'memory_empty_description': '日記を書いて過去の記録を振り返りましょう',
    'memory_write_diary_button': '日記を書く',
    'memory_bookmarked': '{title}をブックマークしました',
    'memory_bookmark_removed': '{title}のブックマークを解除しました',

    // App Intro Features (16 keys)
    'feature_ocr_title': 'OCRテキスト抽出',
    'feature_ocr_desc': '紙に書いた記録を撮影してすぐにテキストに変換します。',
    'feature_voice_title': '音声録音',
    'feature_voice_desc': '言葉で残した一日を自然に日記に変換します。',
    'feature_emotion_title': '感情分析',
    'feature_emotion_desc': '日記に込められた感情を自分で整理し、統計で表示します。',
    'feature_ai_image_title': 'AI画像生成',
    'feature_ai_image_desc': '日記の雰囲気に合った感情的な背景画像を作成します。',
    'feature_search_title': '日記検索',
    'feature_search_desc': 'キーワードと日付で希望の日記を素早く探せます。',
    'feature_backup_title': 'バックアップファイル管理',
    'feature_backup_desc': 'バックアップファイルをエクスポートして再度読み込み、いつでも安全に保管します。',
    'feature_pin_title': 'PINセキュリティ',
    'feature_pin_desc': 'PINロックで個人の日記を安全に守ります。',
    'feature_privacy_title': '背景画面隠し',
    'feature_privacy_desc': 'バックグラウンドでも画面をぼかして処理し、プライバシーを保護します。',

    // Emotion Arrow
    'emotion_arrow': '→',

    // Emotion Names
    'emotion_joy': '喜び',
    'emotion_default': 'デフォルト',
    'emotion_sadness': '悲しみ',
    'emotion_anger': '怒り',
    'emotion_fear': '恐れ',
    'emotion_surprise': '驚き',
    'emotion_disgust': '嫌悪',
    'emotion_anticipation': '期待',
    'emotion_trust': '信頼',

    // Privacy Policy Content
    'privacy_policy_content': '''EveryDiary プライバシーポリシー

1. 個人情報の処理目的
EveryDiary（以下「アプリ」）は、以下の目的のために個人情報を処理します。

- 日記作成・管理サービスの提供
- ユーザー設定とカスタマイズ機能の提供
- サービス改善とユーザーエクスペリエンスの向上

2. 収集する個人情報項目
アプリは以下の個人情報を収集します：

- ユーザー名（任意）
- PINロック設定情報（任意）
- 日記内容および関連データ（ローカル保存）
- アプリ設定情報

3. 個人情報の保有・利用期間
アプリは、ユーザーが直接削除するか、アプリをアンインストールするまで個人情報を保有します。

すべてのデータはユーザーのデバイスにローカルに保存され、外部サーバーに送信されません。

4. 個人情報の第三者提供
アプリはユーザーの個人情報を第三者に提供しません。

5. 個人情報の破棄
ユーザーがアプリを削除するか、データを削除すると、すべての個人情報は直ちに破棄されます。

6. 個人情報自動収集装置の設置・運営および拒否に関する事項
アプリはCookieや類似の追跡技術を使用しません。

7. 個人情報保護責任者
個人情報に関するお問い合わせは、以下までご連絡ください：
メール: support@everydiary.app

8. プライバシーポリシーの変更
本プライバシーポリシーは法令および方針に従って変更される場合があり、変更時にはアプリ内で通知されます。

施行日: 2025年1月1日''',

    // Terms of Service Content
    'terms_of_service_content': '''EveryDiary 利用規約

第1条（目的）
本規約は、EveryDiary（以下「アプリ」）の利用に関して、アプリ運営者とユーザーの権利、義務、責任事項を規定することを目的とします。

第2条（定義）
1. 「アプリ」とは、ユーザーが日記を作成・管理できるモバイルアプリケーションを意味します。
2. 「ユーザー」とは、本規約に従ってアプリを使用する者を意味します。
3. 「コンテンツ」とは、ユーザーがアプリを通じて作成する日記および関連データを意味します。

第3条（規約の効力および変更）
1. 本規約は、アプリをダウンロードして使用するすべてのユーザーに適用されます。
2. 本規約は必要に応じて変更される場合があり、変更された規約はアプリ内で通知されます。

第4条（サービスの提供）
1. アプリは、ユーザーに日記作成、管理、バックアップなどの機能を提供します。
2. アプリは無料で提供され、一部の機能はアプリ内購入を通じて利用できます。

第5条（ユーザーの義務）
1. ユーザーは本規約および関連法令を遵守しなければなりません。
2. ユーザーはアプリを違法な目的で使用してはなりません。
3. ユーザーは自分のアカウント情報およびPIN番号を安全に管理する責任があります。

第6条（コンテンツの管理）
1. ユーザーが作成したコンテンツは、ユーザーのデバイスにローカルに保存されます。
2. ユーザーは自分が作成したコンテンツに対するすべての権利と責任を持ちます。
3. アプリ運営者はユーザーのコンテンツにアクセスせず、第三者に提供しません。

第7条（サービスの中断）
アプリ運営者は以下の場合にサービス提供を中断できます：
1. システムメンテナンスが必要な場合
2. 不可抗力の事由が発生した場合

第8条（免責条項）
1. アプリ運営者は、ユーザーのデバイスエラー、データ損失などによる損害について責任を負いません。
2. ユーザーは定期的にバックアップを実行してデータ損失を防止する必要があります。

第9条（紛争解決）
本規約に関連する紛争は、大韓民国の法律に従って解決されます。

施行日: 2025年1月1日''',
  };

  // ============== 중국어 (간체) ==============
  static const Map<String, String> _chineseSimplified = {
    // 通用
    'app_name': 'EveryDiary',
    'ok': '确定',
    'confirm': '确认',
    'cancel': '取消',
    'save': '保存',
    'delete': '删除',
    'edit': '编辑',
    'close': '关闭',
    'yes': '是',
    'no': '否',
    'dont_show_again': '不再显示',

    // 新风格公告
    'new_style_announcement_title': '新增了一种风格！',
    'new_style_announcement_description': '试试童话书风格的彩色铅笔插图吧。\n可以在设置中更改。',

    // AdMob政策通知
    'ad_policy_notice_title': '服务通知',
    'ad_policy_notice_message': '由于AdMob政策审核，广告观看功能暂时受限。在1月30日之前，每天免费AI图像生成将重置为2次。政策审核完成后将恢复正常。',
    'ad_policy_notice_count_info': '每日免费AI图像生成：2次（自动重置）',

    // 设置
    'settings': '设置',
    'settings_reset': '重置设置',
    'app_settings': '应用设置',
    'thumbnail_style': '缩略图样式',
    'thumbnail_style_subtitle': '设置AI缩略图样式和关键词',
    'theme': '主题',
    'font_size': '字体大小',
    'language': '语言',
    'language_select': '选择语言',
    'security_management': 'EveryDiary安全与管理',
    'username': '用户名',
    'username_not_set': '未设置',
    'pin_lock': 'PIN锁定',
    'pin_lock_enabled': '应用启动时需要PIN',
    'pin_lock_disabled': '已禁用',
    'pin_change': '更改PIN',
    'pin_change_subtitle': '输入当前PIN并设置新PIN',
    'recovery_question': '紧急恢复问题',
    'recovery_question_set': '已设置',
    'recovery_question_not_set': '未设置',

    // PIN相关
    'pin_setup': 'PIN锁定设置',
    'pin_new': '新PIN（4位数字）',
    'pin_confirm': '确认PIN',
    'pin_current': '当前PIN',
    'pin_change_title': '更改PIN',
    'pin_disable': '禁用PIN锁定',
    'pin_disable_message': '禁用PIN锁定后，应用启动时将不再需要身份验证。',
    'pin_disable_button': '禁用',
    'pin_error_length': '请输入4位数字',
    'pin_error_mismatch': 'PIN不匹配',
    'pin_error_new_mismatch': '新PIN不匹配',
    'pin_enabled_message': 'PIN锁定已启用。',
    'pin_disabled_message': 'PIN锁定已禁用。',
    'pin_changed_message': 'PIN已更改。',
    'pin_change_failed': 'PIN更改失败',

    // PIN解锁画面
    'pin_unlock_title': '解锁',
    'pin_unlock_subtitle': '请输入4位PIN码以重新访问应用。',
    'pin_unlock_button': '解锁',
    'pin_unlock_clear': '清除',
    'pin_unlock_recovery': '紧急恢复',
    'pin_unlock_error_length': '请输入4位PIN码',
    'pin_unlock_error_incorrect': 'PIN不正确。请重试。',
    'pin_unlock_error_locked': '由于尝试次数过多，已锁定。',
    'pin_unlock_locked_until': '已锁定：无法尝试直到 {time}',
    'pin_unlock_remaining_attempts': '剩余尝试次数：{count}次',
    'pin_unlock_unlocked': '已解锁',
    'pin_unlock_time_minutes': '{minutes}分 {seconds}秒',
    'pin_unlock_time_seconds': '{seconds}秒',
    'pin_unlock_recovery_warning_title': '⚠️ 未设置紧急恢复问题',
    'pin_unlock_recovery_warning_message': '如果忘记PIN，将无法访问应用。\n请在设置中注册紧急恢复问题。',

    // PIN恢复对话框
    'pin_recovery_title': '紧急恢复',
    'pin_recovery_question_label': '安全问题',
    'pin_recovery_answer_input': '输入答案',
    'pin_recovery_new_pin': '新PIN（4位数字）',
    'pin_recovery_confirm_pin': '确认新PIN',
    'pin_recovery_error_answer_empty': '请输入安全问题答案',
    'pin_recovery_error_pin_length': '请输入4位数字PIN',
    'pin_recovery_error_pin_mismatch': '新PIN不匹配',
    'pin_recovery_success': '新PIN已设置。',
    'pin_recovery_failed': '恢复失败：{error}',

    // 恢复问题
    'recovery_question_setup': '紧急恢复问题设置',
    'recovery_question_label': '安全问题',
    'recovery_question_hint': '例如：只有我知道的地方？',
    'recovery_answer': '答案',
    'recovery_answer_confirm': '确认答案',
    'recovery_question_error_empty': '请输入安全问题',
    'recovery_answer_error_empty': '请输入答案',
    'recovery_answer_error_mismatch': '答案不匹配',
    'recovery_question_saved': '紧急恢复问题已保存。',
    'recovery_question_deleted': '紧急恢复问题已删除。',
    'recovery_question_delete': '删除',

    // 用户名
    'username_change': '更改用户名',
    'username_label': '姓名',
    'username_hint': '例如：张三',
    'username_error_empty': '请输入姓名',
    'username_updated': '用户名已更新。',

    // 主题
    'theme_system': '系统设置',
    'theme_light': '浅色',
    'theme_dark': '深色',

    // 字体大小
    'font_small': '小',
    'font_medium': '中',
    'font_large': '大',
    'font_extra_large': '超大',

    // 介绍视频
    'show_intro_video': '启动时显示介绍视频',
    'show_intro_video_subtitle': '应用启动时显示介绍视频',

    // 图像生成
    'image_generation_count': 'AI图像生成次数',
    'image_generation_description': '创建更多由AI生成的精美日记图像！',
    'watch_ad_for_1_time': '观看广告再获得1次',
    'watch_ad_subtitle': '观看短广告免费获取',
    'ad_loading': '广告加载中...',
    'ad_wait': '请稍候',
    'ad_reward_success': '广告观看完成！已添加2次生成次数。',

    // 回忆
    'memory_type_all': '全部',
    'memory_type_yesterday': '昨天',
    'memory_type_one_week_ago': '一周前',
    'memory_type_one_month_ago': '一个月前',
    'memory_type_one_year_ago': '一年前',
    'memory_type_past_today': '过去的今天',
    'memory_type_same_time': '同一时间',
    'memory_type_seasonal': '季节性',
    'memory_type_special_date': '特殊日期',
    'memory_type_similar_tags': '相似标签',
    'memory_reason_yesterday': '昨天的记录',
    'memory_reason_one_week_ago': '一周前的记录',
    'memory_reason_one_month_ago': '一个月前的记录',
    'memory_reason_one_year_ago': '一年前的记录',
    'memory_reason_past_today': '过去这一天的记录',
    'memory_reason_same_time': '这个时间的记录',
    'memory_reason_seasonal': '季节记录',
    'memory_reason_special_date': '特殊日期的记录',
    'memory_reason_similar_tags': '相似标签的记录',
    'memory_bookmark': '书签',
    'memory_bookmark_remove': '取消书签',

    // OCR
    'ocr_camera_title': '拍照',
    'ocr_auto_detect': '自动检测',
    'ocr_language_korean': '韩语',
    'ocr_language_english': 'English',
    'ocr_language_japanese': '日语',
    'ocr_language_chinese': '中文',

    // 语音识别
    'speech_language_korean': '韩语',
    'speech_language_english': 'English',
    'speech_language_japanese': '日语',
    'speech_language_chinese': '中文',
    'speech_initializing': '正在初始化语音识别...',
    'speech_ready': '点击麦克风按钮开始语音识别',
    'speech_listening': '请说话。完成后再次点击按钮',
    'speech_processing': '正在将语音转换为文字...',
    'speech_completed': '语音识别已完成',
    'speech_error': '语音识别过程中发生错误。请重试',
    'speech_cancelled': '语音识别已取消',
    'speech_error_title': '语音识别错误',
    'speech_cancel': '取消',
    'speech_retry': '重试',
    'speech_error_solutions': '解决方法:',
    'speech_error_check_permission': '• 检查麦克风权限是否已授予',
    'speech_error_check_internet': '• 检查网络连接',
    'speech_error_quiet_environment': '• 在更安静的环境中重试',
    'speech_error_check_microphone': '• 检查麦克风是否正常工作',
    'speech_permission_title': '需要麦克风权限',
    'speech_permission_description': '使用语音识别功能需要麦克风权限。',
    'speech_permission_usage': '此权限仅用于:',
    'speech_permission_convert': '• 将语音转换为文字',
    'speech_permission_diary': '• 写日记时的语音输入',
    'speech_permission_accuracy': '• 提高语音识别准确性',
    'speech_permission_deny': '拒绝',
    'speech_permission_allow': '允许',
    'speech_init_failed': '语音识别服务初始化失败。',
    'speech_init_error': '初始化过程中发生错误',
    'speech_permission_required': '需要麦克风权限。',
    'speech_start_failed': '启动语音识别失败。',
    'speech_start_error': '启动语音识别时发生错误',
    'speech_stop_error': '停止语音识别时发生错误',
    'speech_cancel_error': '取消语音识别时发生错误',

    // 语音录音
    'voice_recording_title': '语音录音',
    'voice_recording_init_failed': '无法初始化语音识别服务。',
    'voice_recording_start_failed': '无法开始语音录音。',
    'voice_recording_recording': '录音中...',
    'voice_recording_paused': '已暂停',
    'voice_recording_resume_prompt': '恢复录音',
    'voice_recording_start_prompt': '开始录音',
    'voice_recording_recognized_text': '识别的文字:',
    'voice_recording_stop': '停止录音',
    'voice_recording_resume': '恢复录音',
    'voice_recording_start': '开始录音',
    'voice_recording_cancel': '取消',
    'voice_recording_confirm': '确认',

    // 权限请求 (Permission Request)
    'permission_request_title': '权限设置',
    'permission_request_subtitle': '使用应用功能需要以下权限',
    'permission_camera_title': '相机权限',
    'permission_camera_description': '使用OCR文字识别功能需要相机访问权限。',
    'permission_microphone_title': '麦克风权限',
    'permission_microphone_description': '使用语音记录日记需要麦克风访问权限。',
    'permission_allow_all': '全部允许',
    'permission_skip': '稍后设置',
    'permission_continue': '继续',
    'permission_granted': '已允许',
    'permission_denied': '已拒绝',
    'permission_open_settings': '打开设置',
    'permission_required_features': '某些功能需要权限',
    'permission_camera_rationale': '拍照识别文字需要相机权限。',
    'permission_microphone_rationale': '使用语音记录日记需要麦克风权限。',
    'permission_settings_guide': '权限已被永久拒绝。请在设置中允许权限。',

    // 日期显示
    'date_today': '今天',
    'date_yesterday': '昨天',

    // 通知
    'notifications': '通知',
    'daily_reminder': '日记提醒',
    'daily_reminder_subtitle': '每天提醒您写日记',
    'reminder_time': '提醒时间',

    // 数据管理
    'data_management': '数据管理',

    // 信息
    'info': '信息',
    'app_version': '应用版本',
    'privacy_policy': '隐私政策',
    'privacy_policy_subtitle': '查看我们的隐私政策',
    'terms_of_service': '服务条款',
    'terms_of_service_subtitle': '查看我们的服务条款',
    'app_description': '用AI绘制的精美图像记录您的珍贵时刻。',
    'app_developer': '开发者: EveryDiary',
    'app_contact': '联系方式: window98se@gmail.com',

    // 版本1.0.3 更新内容
    'version_1_0_3_title': 'v1.0.3 更新内容',
    'version_1_0_3_change_1': '改进Android 15显示兼容性',
    'version_1_0_3_change_2': '修复回忆提醒时间设置',
    'version_1_0_3_change_3': '提升OCR相机画质（使用设备相机）',
    'version_1_0_3_change_4': '添加游戏角色缩略图样式（像素艺术）',
    'version_1_0_3_change_5': 'UI简化和稳定性改进',

    // 版本1.0.4 更新内容
    'version_1_0_4_title': 'v1.0.4 更新内容',
    'version_1_0_4_change_1': '改进日记文本可读性（优化字体颜色）',
    'version_1_0_4_change_2': '添加新的"与圣诞老人一起"缩略图样式',
    'version_1_0_4_change_3': '重新设计缩略图样式选择器为3列网格UI',
    'version_1_0_4_change_4': '在日记编写页面添加缩略图样式按钮',
    'version_1_0_4_change_5': '广告奖励从1次增加到2次',
    'version_1_0_4_change_6': '改进Android 15边到边兼容性',

    // 性别相关
    'user_gender': '性别',
    'select_gender': '选择性别',
    'gender_male': '男性',
    'gender_female': '女性',
    'gender_none': '未指定',

    // 彩色铅笔风格
    'style_color_pencil': '彩色铅笔',

    // 毛线玩偶风格
    'style_felted_wool': '毛线玩偶',

    // 3D动画风格
    'style_3d_animation': '3D动画',

    // 新样式添加弹窗
    'new_styles_popup_title': '新样式添加！',
    'new_styles_popup_message': '毛线玩偶和3D动画样式已添加。请在设置中查看！',
    'new_styles_popup_dont_show': '不再显示',
    'new_styles_popup_check': '查看',

    // 版本1.1.1 更新内容
    'version_1_1_1_title': 'v1.1.1 更新内容',
    'version_1_1_1_change_1': '新增缩略图样式：毛线玩偶',
    'version_1_1_1_change_2': '新增缩略图样式：3D动画',

    // 版本1.1.0 更新内容
    'version_1_1_0_title': 'v1.1.0 更新内容',
    'version_1_1_0_change_1': '添加用户性别设置（反映在AI图像中）',
    'version_1_1_0_change_2': '新增缩略图样式：彩色铅笔',
    'version_1_1_0_change_3': '修复了一些小问题',

    // 版本1.0.9 更新内容
    'version_1_0_9_title': 'v1.0.9 更新内容',
    'version_1_0_9_change_1': '新增缩略图样式：儿童画',
    'version_1_0_9_change_2': '新增缩略图样式：手办',

    // 版本1.0.8 更新内容
    'version_1_0_8_title': 'v1.0.8 更新内容',
    'version_1_0_8_change_1': 'AI生成内容政策合规',

    // 版本1.0.7 更新内容
    'version_1_0_7_title': 'v1.0.7 更新内容',
    'version_1_0_7_change_1': '修复主页背景图像更新时UI消失的问题',

    // AI内容举报功能
    'report_ai_content': '举报AI内容',
    'report_description': '发现不当或令人不适的AI生成内容？请选择举报原因。',
    'report_select_reason': '选择举报原因',
    'report_reason_inappropriate': '不当内容',
    'report_reason_offensive': '令人不适的内容',
    'report_reason_misleading': '误导性内容',
    'report_reason_copyright': '侵犯版权',
    'report_reason_other': '其他',
    'report_additional_details': '补充说明（可选）',
    'report_details_hint': '请输入关于此举报的补充说明...',
    'report_submit': '提交举报',
    'report_submitted': '举报已提交。我们将审核并采取措施。',
    'report_error': '处理举报时出错',
    'report_email_error': '无法打开邮件应用。请直接联系window98se@gmail.com。',
    'report_email_subject': '[EveryDiary] AI内容举报',
    'report_reason': '举报原因',
    'report_details': '补充说明',
    'report_no_details': '无补充说明',
    'report_image_info': '图像信息',
    'report_image_preview': '举报对象图像',
    'report_prompt_label': '生成提示词',
    'report_agree_share_image': '我同意为此举报共享图像和提示词',
    'report_send_to': '举报接收处',

    // 版本1.0.6 更新内容
    'version_1_0_6_title': 'v1.0.6 更新内容',
    'version_1_0_6_change_1': '应用启动时添加介绍视频',
    'version_1_0_6_change_2': 'AdMob政策审核期间，每日自动重置2次免费AI图像生成',
    'version_1_0_6_change_3': '代码优化和稳定性改进',

    // 版本1.0.5 更新内容
    'version_1_0_5_title': 'v1.0.5 更新内容',
    'version_1_0_5_change_1': '改进日记文本可读性（优化字体颜色）',
    'version_1_0_5_change_2': '添加新的"与圣诞老人一起"缩略图样式',
    'version_1_0_5_change_3': '重新设计缩略图样式选择器为3列网格UI',
    'version_1_0_5_change_4': '在日记编写页面添加缩略图样式按钮',
    'version_1_0_5_change_5': '广告奖励从1次增加到2次',
    'version_1_0_5_change_6': '改进Android 15边到边兼容性',
    'version_1_0_5_change_7': '优化了应用程序大小',
    'version_1_0_5_change_8': '现在支持韩语/英语/日语以外的177个国家',

    // ===== NEW TRANSLATIONS =====

    // Onboarding (14 keys)
    'welcome_title': '欢迎来到EveryDiary！',
    'setup_subtitle': '请先设置应用中使用的姓名和锁定选项。',
    'name_label': '姓名',
    'name_hint': '例如：张三',
    'name_required': '请输入姓名',
    'name_max_length': '姓名必须在24个字符以内',
    'pin_lock_title': '应用启动时使用PIN锁定',
    'pin_lock_subtitle': '设置打开应用时输入4位PIN。',
    'pin_label': 'PIN（4位数字）',
    'pin_required': '请输入4位数字',
    'pin_numbers_only': '只能输入数字',
    'pin_confirm_label': '确认PIN',
    'pin_mismatch': 'PIN不匹配',
    'start_button': '开始',
    'setup_save_failed': '设置保存失败',

    // Home Screen (11 keys)
    'home_greeting': '{name}，您好 👋',
    'home_subtitle': '记录今天的瞬间，用AI图像保留情感。',
    'quick_actions_title': '快速操作',
    'new_diary': '写新日记',
    'view_diaries': '查看我的日记',
    'statistics_action': '日记统计',
    'memory_notifications': '回忆通知设置',
    'app_intro_title': '应用介绍',
    'fallback_features_title': 'EveryDiary主要功能',
    'fallback_features_list': 'OCR · 语音录制 · 情感分析 · AI图像 · 备份管理 · PIN安全 · 屏幕隐私',
    'diary_author': '日记作者',

    // Error Page (4 keys)
    'error_title': '错误',
    'page_not_found': '找不到页面',
    'page_not_found_subtitle': '您请求的页面不存在',
    'back_to_home': '返回主页',

    // Privacy & Terms (2 keys)
    'privacy_policy_title': '隐私政策',
    'terms_of_service_title': '服务条款',

    // Diary Write Screen (49 keys)
    'diary_write_title': '写日记',
    'save_tooltip': '保存',
    'thumbnail_style_tooltip': '缩略图样式设置',
    'exit_without_save_title': '不保存退出吗？',
    'exit_without_save_message': '正在编写的内容将不会保存。',
    'exit': '退出',
    'title_label': '标题',
    'title_hint': '输入今天的日记标题',
    'title_required': '请输入标题',
    'date_label': '日期',
    'emotion_analysis_label': '情感分析',
    'emotion_analyzing': '正在分析情感...',
    'ocr_button': 'OCR',
    'voice_recording_button': '语音录制',
    'save_button': '保存日记',
    'saved_success': '日记已保存。',
    'save_failed': '保存失败',
    'load_error': '加载日记时发生错误',
    'load_timeout': '日记加载超时。请重试。',
    'retry': '重试',
    'text_add_error': '添加文本时发生错误',
    'thumbnail_empty_content': '内容为空，无法生成缩略图。',
    'thumbnail_no_diary': '没有正在编辑的日记，跳过重新生成。',
    'thumbnail_regenerating': '正在重新生成缩略图。请稍候。',
    'ocr_success': '文字识别完成',
    'ocr_cancelled': '文字识别已取消',
    'ocr_unavailable': 'OCR功能不可用',
    'camera_permission_error': '无法访问相机。请检查权限。',
    'camera_permission_required': '需要相机权限。',
    'voice_error': '语音录制错误',
    'voice_text_added': '语音文本已添加。',
    'voice_text_add_failed': '语音文本添加失败。',
    'invalid_diary_id': '无效的日记ID',
    'content_placeholder': '在此输入内容...',
    'characters': '字',
    'diary_content_placeholder': '记录今天的故事...',
    'editor_undo_tooltip': '撤销',
    'editor_redo_tooltip': '重做',
    'editor_bold_tooltip': '粗体',
    'editor_italic_tooltip': '斜体',
    'editor_underline_tooltip': '下划线',
    'editor_bulleted_list_tooltip': '项目符号列表',
    'editor_numbered_list_tooltip': '编号列表',
    'editor_align_left_tooltip': '左对齐',
    'editor_align_center_tooltip': '居中对齐',
    'editor_align_right_tooltip': '右对齐',

    // Thumbnail Style (24 keys)
    'thumbnail_dialog_title': '自定义缩略图样式',
    'thumbnail_dialog_subtitle': '调整AI缩略图样式和校正值以反映您的偏好。',
    'style_select_title': '选择样式',
    'detail_adjust_title': '详细调整',
    'brightness_label': '亮度',
    'contrast_label': '对比度',
    'saturation_label': '饱和度',
    'blur_radius_label': '模糊半径',
    'overlay_color_label': '叠加颜色',
    'overlay_opacity_label': '叠加不透明度',
    'auto_optimization_title': '自动优化',
    'auto_optimization_subtitle': '根据分析结果自动校正提示',
    'manual_keyword_title': '自定义关键词',
    'manual_keyword_subtitle': '添加最多5个始终包含在AI提示中的关键词。',
    'keyword_label': '手动关键词',
    'keyword_hint': '例如：柔和色调，夜景',
    'keyword_add_button': '添加',
    'keyword_required': '请输入关键词。',
    'keyword_max_length': '关键词必须在24个字符以内。',
    'keyword_duplicate': '此关键词已添加。',
    'keyword_max_count': '最多可注册5个关键词。',
    'keyword_save_failed': '无法保存关键词。请重试。',
    'keyword_empty_list': '没有注册的关键词。',
    'keyword_clear_all': '全部清除',

    // Thumbnail Styles (12 keys)
    'style_chibi': '三头身漫画',
    'style_cute': '可爱',
    'style_pixel_game': '游戏角色',
    'style_realistic': '写实',
    'style_cartoon': '卡通',
    'style_watercolor': '水彩',
    'style_oil': '油画',
    'style_sketch': '素描',
    'style_digital': '数字艺术',
    'style_vintage': '复古',
    'style_modern': '现代',
    'style_santa_together': '与圣诞老人一起',
    'style_child_draw': '儿童画',
    'style_figure': '手办',

    // Memory Notification Settings (25 keys)
    'memory_notification_settings_title': '回忆通知设置',
    'memory_notification_settings_loading': '正在加载设置...',
    'memory_notification_settings_load_error': '加载设置失败',
    'memory_notification_permission_granted': '通知权限已授予',
    'memory_notification_permission_denied': '通知权限被拒绝',
    'memory_notification_scheduled': '回忆通知已设置',
    'memory_notification_schedule_error': '设置通知时发生错误',
    'memory_notification_toggle_title': '回忆通知',
    'memory_notification_toggle_description': '接收通知以回忆过去的日记',
    'memory_notification_time_title': '通知时间',
    'memory_notification_time_label': '接收通知的时间',
    'memory_notification_types_title': '通知类型',
    'memory_notification_yesterday_title': '昨天的记录',
    'memory_notification_yesterday_description': '回忆昨天写的日记',
    'memory_notification_one_week_ago_title': '一周前的记录',
    'memory_notification_one_week_ago_description': '回忆一周前写的日记',
    'memory_notification_one_month_ago_title': '一个月前的记录',
    'memory_notification_one_month_ago_description': '回忆一个月前写的日记',
    'memory_notification_one_year_ago_title': '一年前的记录',
    'memory_notification_one_year_ago_description': '回忆一年前写的日记',
    'memory_notification_past_today_title': '过去的今天',
    'memory_notification_past_today_description': '回忆去年、前年同一天的记录',
    'memory_notification_permission_title': '通知权限',
    'memory_notification_permission_granted_status': '通知权限已授予',
    'memory_notification_permission_required': '需要通知权限',
    'memory_notification_permission_request_button': '请求权限',
    'memory_notification_time_selection_title': '选择通知时间',
    'cancel_button': '取消',
    'confirm_button': '确认',

    // Diary List (21 keys)
    'my_diary': '我的日记',
    'back_tooltip': '返回',
    'calendar_tooltip': '日历视图',
    'filter_tooltip': '筛选',
    'sort_tooltip': '排序',
    'new_diary_fab': '写新日记',
    'delete_title': '删除日记',
    'delete_message': '确定要删除此日记吗？\n已删除的日记无法恢复。',
    'delete_button': '删除',
    // 保存图片
    'image_save_title': '保存图片',
    'image_save_message': '是否将此图片保存到相册？',
    'image_save_success': '图片已保存到相册',
    'image_save_failed': '无法保存图片',
    'image_save_error': '保存图片时发生错误',
    'image_save_hint': '长按图片即可保存到相册',
    // 网络通知
    'network_offline_title': '离线模式',
    'network_offline_message': 'AI图片生成可能失败。',
    // 日记详情页面
    'diary_detail_title': '日记详情',
    'tab_detail': '详细内容',
    'tab_history': '编辑历史',
    'tooltip_favorite_add': '添加到收藏',
    'tooltip_favorite_remove': '从收藏中移除',
    'tooltip_edit': '编辑',
    'tooltip_share': '分享',
    'tooltip_delete': '删除',
    'favorite_added': '已添加到收藏',
    'favorite_removed': '已从收藏中移除',
    'favorite_error': '更改收藏状态时发生错误',
    'diary_deleted': '日记已删除',
    'diary_delete_failed': '删除日记失败',
    'diary_delete_error': '删除日记时发生错误',
    'diary_not_found': '找不到日记',
    'diary_not_found_message': '您请求的日记不存在或已被删除',
    'diary_load_error': '加载日记时发生错误',
    'association_image_title': '日记联想图片',
    'association_image_generating': '正在生成日记联想图片...',
    'association_image_generating_message': '正在根据日记内容生成AI图片。',
    'association_image_error': '无法显示日记联想图片',
    'association_image_load_error': '无法加载图片',
    'image_generation_failed': '图片生成失败',
    'image_load_error': '加载图片时发生错误',
    'generation_prompt': '生成提示',
    'emotion_label': '情感',
    'style_label': '风格',
    'topic_label': '主题',
    'generated_date': '生成日期',
    'info_title': '信息',
    'word_count': '字数',
    'created_date': '创建日期',
    'modified_date': '修改日期',
    'tags_title': '标签',
    'time_morning': '早上',
    'time_day': '白天',
    'time_evening': '晚上',
    'time_night': '夜晚',
    'retry_button': '重试',
    'back_to_list': '返回列表',

    // 编辑历史 (2 keys)
    'edit_history_empty': '没有编辑历史',
    'edit_history_empty_message': '编辑日记后将记录历史',

    // 日记保存 (1 key)
    'diary_saved': '日记已保存',

    // 心情 (16 keys)
    'mood_happy': '快乐',
    'mood_sad': '悲伤',
    'mood_angry': '生气',
    'mood_calm': '平静',
    'mood_excited': '兴奋',
    'mood_worried': '担心',
    'mood_tired': '疲倦',
    'mood_satisfied': '满意',
    'mood_disappointed': '失望',
    'mood_grateful': '感激',
    'mood_lonely': '孤独',
    'mood_thrilled': '激动',
    'mood_depressed': '抑郁',
    'mood_nervous': '紧张',
    'mood_comfortable': '舒适',
    'mood_other': '其他',

    // 天气 (9 keys)
    'weather_sunny': '晴朗',
    'weather_cloudy': '多云',
    'weather_rainy': '雨',
    'weather_snowy': '雪',
    'weather_windy': '风',
    'weather_foggy': '雾',
    'weather_hot': '酷热',
    'weather_cold': '寒冷',
    'weather_other': '其他',

    'sort_dialog_title': '排序依据',
    'sort_date_desc': '最新优先',
    'sort_date_asc': '最早优先',
    'sort_title_asc': '标题（A-Z）',
    'sort_title_desc': '标题（Z-A）',
    'sort_mood': '按心情',
    'sort_weather': '按天气',
    'error_load_diaries': '无法加载日记',
    'error_unknown': '发生未知错误',
    'empty_diaries_title': '还没有日记',
    'empty_diaries_subtitle': '写下您的第一篇日记',
    'empty_diaries_action': '写日记',

    // Statistics (7 keys)
    'statistics_title': '日记统计',
    'date_range_tooltip': '选择日期范围',
    'period_title': '分析期间',
    'preset_week': '最近1周',
    'preset_month': '最近1个月',
    'preset_quarter': '最近3个月',
    'preset_year': '最近1年',

    // Backup & Restore (49 keys)
    'backup_section_title': '备份与恢复',
    'create_backup_button': '创建备份',
    'restore_from_file_button': '从文件恢复',
    'auto_backup_title': '自动备份',
    'backup_interval_label': '备份周期：',
    'interval_daily': '每天',
    'interval_3days': '每3天',
    'interval_weekly': '每周',
    'interval_biweekly': '每两周',
    'interval_monthly': '每月',
    'max_backups_label': '最大备份数：',
    'max_3': '3个',
    'max_5': '5个',
    'max_10': '10个',
    'max_20': '20个',
    'no_backups_title': '没有备份',
    'no_backups_subtitle': '创建您的第一个备份',
    'available_backups_title': '可用备份',
    'created_date_label': '创建日期',
    'size_label': '大小',
    'includes_label': '包含',
    'includes_settings': '设置',
    'includes_profile': '个人资料',
    'includes_diary': '日记',
    'restore_action': '恢复',
    'delete_action': '删除',
    'backup_success': '备份创建成功。',
    'backup_failed': '备份创建失败。',
    'backup_error': '创建备份时发生错误',
    'restore_success': '恢复成功完成。',
    'restore_failed': '恢复失败。',
    'restore_error': '恢复过程中发生错误',
    'delete_success': '备份已删除。',
    'delete_failed': '备份删除失败。',
    'delete_error': '删除备份时发生错误',
    'load_error_backup': '加载数据时发生错误',
    'file_picker_error': '选择文件时发生错误',
    'auto_backup_update_error': '更新自动备份设置时发生错误',
    'interval_update_error': '设置备份周期时发生错误',
    'max_backups_update_error': '设置最大备份数时发生错误',
    'restore_confirm_title': '恢复数据',
    'restore_confirm_message': '当前数据将被备份数据覆盖。\n此操作无法撤消。\n\n继续吗？',
    'delete_confirm_title': '删除备份',
    'delete_confirm_message': '确定要删除此备份吗？\n此操作无法撤消。',
    'count_suffix': '个',

    // Calendar (16 keys)
    'calendar': '日历',
    'back': '返回',
    'diary_statistics': '日记统计',
    'weekly_view': '周视图',
    'monthly_view': '月视图',
    'today': '今天',
    'write_new_diary': '撰写新日记',
    'calendar_legend_multiple_entries': '橙色圆点表示有2篇或更多日记。',
    'please_select_date': '请选择日期',
    'diary_count': '{count}篇日记',
    'no_diary_on_this_day': '这一天没有日记',
    'write_diary': '写日记',
    'diary_search_hint': '搜索日记...',
    'clear_search_tooltip': '清除搜索',
    'today_with_date': '今天（{month}月{day}日）',
    'yesterday_with_date': '昨天（{month}月{day}日）',
    'tomorrow_with_date': '明天（{month}月{day}日）',
    'full_date': '{year}年{month}月{day}日',

    // Statistics Widget (25 keys)
    'stats_overall_title': '整体统计',
    'stats_total_diaries': '总日记数',
    'stats_total_diaries_unit': '{count}篇',
    'stats_current_streak': '当前连续',
    'stats_current_streak_unit': '{count}天',
    'stats_longest_streak': '最长连续',
    'stats_longest_streak_unit': '{count}天',
    'stats_daily_average': '日平均',
    'stats_daily_average_unit': '{count}篇',
    'stats_most_active_day': '最活跃的星期',
    'stats_most_active_day_unit': '星期{day}',
    'stats_most_active_month': '最活跃的月份',
    'stats_monthly_frequency': '月度写作频率',
    'stats_weekly_frequency': '周度写作频率',
    'stats_no_data': '暂无数据',
    'stats_count_unit': '{count}篇',
    'stats_content_length_title': '日记长度统计',
    'stats_average_characters': '平均字数',
    'stats_characters_unit': '{count}字',
    'stats_average_words': '平均词数',
    'stats_words_unit': '{count}个',
    'stats_max_characters': '最大字数',
    'stats_min_characters': '最小字数',
    'stats_writing_time_title': '写作时段统计',
    'stats_time_count_unit': '{count}次',

    // Generation Count Widget (3 keys)
    'ai_image_generation': 'AI图像生成',
    'remaining_count_label': '剩余次数: ',
    'count_times': '次',

    // Memory Screen (14 keys)
    'memory_title': '回忆',
    'memory_back_tooltip': '返回',
    'memory_notifications_tooltip': '通知设置',
    'memory_filter_tooltip': '筛选',
    'memory_refresh_tooltip': '刷新',
    'memory_loading': '正在加载回忆...',
    'memory_load_failed': '加载回忆失败',
    'memory_unknown_error': '发生未知错误',
    'memory_retry_button': '重试',
    'memory_empty_title': '暂无回忆',
    'memory_empty_description': '写下日记以回顾过去的记录',
    'memory_write_diary_button': '写日记',
    'memory_bookmarked': '已收藏 {title}',
    'memory_bookmark_removed': '已取消收藏 {title}',

    // App Intro Features (16 keys)
    'feature_ocr_title': 'OCR文字提取',
    'feature_ocr_desc': '拍摄纸上记录，立即转换为文本。',
    'feature_voice_title': '语音录音',
    'feature_voice_desc': '将您说的话自然地转换为日记。',
    'feature_emotion_title': '情绪分析',
    'feature_emotion_desc': '整理日记中的情绪并以统计形式呈现。',
    'feature_ai_image_title': 'AI图像生成',
    'feature_ai_image_desc': '创建与日记氛围相匹配的情感背景图像。',
    'feature_search_title': '日记搜索',
    'feature_search_desc': '通过关键词和日期快速查找日记。',
    'feature_backup_title': '备份文件管理',
    'feature_backup_desc': '导出和导入备份文件，随时安全保存。',
    'feature_pin_title': 'PIN安全',
    'feature_pin_desc': '通过PIN锁定安全保护您的个人日记。',
    'feature_privacy_title': '背景屏幕隐藏',
    'feature_privacy_desc': '在后台模糊处理屏幕以保护隐私。',

    // Emotion Arrow
    'emotion_arrow': '→',

    // Emotion Names
    'emotion_joy': '快乐',
    'emotion_default': '默认',
    'emotion_sadness': '悲伤',
    'emotion_anger': '愤怒',
    'emotion_fear': '恐惧',
    'emotion_surprise': '惊讶',
    'emotion_disgust': '厌恶',
    'emotion_anticipation': '期待',
    'emotion_trust': '信任',

    // Privacy Policy Content
    'privacy_policy_content': '''EveryDiary 隐私政策

1. 个人信息处理目的
EveryDiary（以下简称"应用程序"）为以下目的处理个人信息：

- 提供日记写作和管理服务
- 提供用户设置和自定义功能
- 改进服务和提升用户体验

2. 收集的个人信息项目
应用程序收集以下个人信息：

- 用户名（可选）
- PIN锁定设置信息（可选）
- 日记内容及相关数据（本地存储）
- 应用程序设置信息

3. 个人信息的保留和使用期限
应用程序保留个人信息，直到用户直接删除或卸载应用程序。

所有数据都在用户设备上本地存储，不会传输到外部服务器。

4. 向第三方提供个人信息
应用程序不会向第三方提供用户的个人信息。

5. 个人信息的销毁
当用户卸载应用程序或删除数据时，所有个人信息将立即销毁。

6. 自动收集个人信息装置的安装、操作及拒绝
应用程序不使用Cookie或类似的跟踪技术。

7. 个人信息保护负责人
如有个人信息相关问题，请联系我们：
电子邮件: support@everydiary.app

8. 隐私政策的变更
本隐私政策可能根据法律法规和政策进行变更，变更时将在应用程序内通知。

生效日期: 2025年1月1日''',

    // Terms of Service Content
    'terms_of_service_content': '''EveryDiary 服务条款

第1条（目的）
本条款旨在规定应用程序运营者和用户关于使用EveryDiary（以下简称"应用程序"）的权利、义务和责任事项。

第2条（定义）
1. "应用程序"是指允许用户编写和管理日记的移动应用程序。
2. "用户"是指根据本条款使用应用程序的人。
3. "内容"是指用户通过应用程序创建的日记和相关数据。

第3条（条款的效力和修改）
1. 本条款适用于所有下载和使用应用程序的用户。
2. 本条款可根据需要进行修改，修改后的条款将在应用程序内通知。

第4条（服务提供）
1. 应用程序为用户提供日记编写、管理、备份等功能。
2. 应用程序免费提供，部分功能可通过应用内购买使用。

第5条（用户义务）
1. 用户必须遵守本条款和相关法律。
2. 用户不得将应用程序用于非法目的。
3. 用户有责任安全管理其账户信息和PIN码。

第6条（内容管理）
1. 用户创建的内容存储在用户设备的本地。
2. 用户对其创建的内容拥有所有权利和责任。
3. 应用程序运营者不访问用户内容，也不向第三方提供。

第7条（服务中断）
应用程序运营者可在以下情况下中断服务提供：
1. 需要系统维护时
2. 发生不可抗力情况时

第8条（免责条款）
1. 应用程序运营者对用户设备错误、数据丢失等造成的损害不承担责任。
2. 用户应定期执行备份以防止数据丢失。

第9条（争议解决）
与本条款相关的争议应根据大韩民国法律解决。

生效日期: 2025年1月1日''',
  };

  // ============== 중국어 (번체) ==============
  static const Map<String, String> _chineseTraditional = {
    // 通用
    'app_name': 'EveryDiary',
    'ok': '確定',
    'confirm': '確認',
    'cancel': '取消',
    'save': '儲存',
    'delete': '刪除',
    'edit': '編輯',
    'close': '關閉',
    'yes': '是',
    'no': '否',
    'dont_show_again': '不再顯示',

    // 新風格公告
    'new_style_announcement_title': '新增了一種風格！',
    'new_style_announcement_description': '試試童話書風格的彩色鉛筆插圖吧。\n可以在設定中更改。',

    // AdMob政策通知
    'ad_policy_notice_title': '服務通知',
    'ad_policy_notice_message': '由於AdMob政策審核，廣告觀看功能暫時受限。在1月30日之前，每天免費AI圖像生成將重置為2次。政策審核完成後將恢復正常。',
    'ad_policy_notice_count_info': '每日免費AI圖像生成：2次（自動重置）',

    // 設定
    'settings': '設定',
    'settings_reset': '重置設定',
    'app_settings': '應用程式設定',
    'thumbnail_style': '縮圖樣式',
    'thumbnail_style_subtitle': '設定AI縮圖樣式和關鍵字',
    'theme': '主題',
    'font_size': '字體大小',
    'language': '語言',
    'language_select': '選擇語言',
    'security_management': 'EveryDiary安全與管理',
    'username': '使用者名稱',
    'username_not_set': '未設定',
    'pin_lock': 'PIN鎖定',
    'pin_lock_enabled': '應用程式啟動時需要PIN',
    'pin_lock_disabled': '已停用',
    'pin_change': '變更PIN',
    'pin_change_subtitle': '輸入目前PIN並設定新PIN',
    'recovery_question': '緊急復原問題',
    'recovery_question_set': '已設定',
    'recovery_question_not_set': '未設定',

    // PIN相關
    'pin_setup': 'PIN鎖定設定',
    'pin_new': '新PIN（4位數字）',
    'pin_confirm': '確認PIN',
    'pin_current': '目前PIN',
    'pin_change_title': '變更PIN',
    'pin_disable': '停用PIN鎖定',
    'pin_disable_message': '停用PIN鎖定後，應用程式啟動時將不再需要驗證。',
    'pin_disable_button': '停用',
    'pin_error_length': '請輸入4位數字',
    'pin_error_mismatch': 'PIN不符',
    'pin_error_new_mismatch': '新PIN不符',
    'pin_enabled_message': 'PIN鎖定已啟用。',
    'pin_disabled_message': 'PIN鎖定已停用。',
    'pin_changed_message': 'PIN已變更。',
    'pin_change_failed': 'PIN變更失敗',

    // PIN解鎖畫面
    'pin_unlock_title': '解鎖',
    'pin_unlock_subtitle': '請輸入4位PIN碼以重新存取應用程式。',
    'pin_unlock_button': '解鎖',
    'pin_unlock_clear': '清除',
    'pin_unlock_recovery': '緊急復原',
    'pin_unlock_error_length': '請輸入4位PIN碼',
    'pin_unlock_error_incorrect': 'PIN不正確。請重試。',
    'pin_unlock_error_locked': '由於嘗試次數過多，已鎖定。',
    'pin_unlock_locked_until': '已鎖定：無法嘗試直到 {time}',
    'pin_unlock_remaining_attempts': '剩餘嘗試次數：{count}次',
    'pin_unlock_unlocked': '已解鎖',
    'pin_unlock_time_minutes': '{minutes}分 {seconds}秒',
    'pin_unlock_time_seconds': '{seconds}秒',
    'pin_unlock_recovery_warning_title': '⚠️ 未設定緊急復原問題',
    'pin_unlock_recovery_warning_message': '如果忘記PIN，將無法存取應用程式。\n請在設定中註冊緊急復原問題。',

    // PIN復原對話框
    'pin_recovery_title': '緊急復原',
    'pin_recovery_question_label': '安全問題',
    'pin_recovery_answer_input': '輸入答案',
    'pin_recovery_new_pin': '新PIN（4位數字）',
    'pin_recovery_confirm_pin': '確認新PIN',
    'pin_recovery_error_answer_empty': '請輸入安全問題答案',
    'pin_recovery_error_pin_length': '請輸入4位數字PIN',
    'pin_recovery_error_pin_mismatch': '新PIN不符',
    'pin_recovery_success': '新PIN已設定。',
    'pin_recovery_failed': '復原失敗：{error}',

    // 復原問題
    'recovery_question_setup': '緊急復原問題設定',
    'recovery_question_label': '安全問題',
    'recovery_question_hint': '例如：只有我知道的地方？',
    'recovery_answer': '答案',
    'recovery_answer_confirm': '確認答案',
    'recovery_question_error_empty': '請輸入安全問題',
    'recovery_answer_error_empty': '請輸入答案',
    'recovery_answer_error_mismatch': '答案不符',
    'recovery_question_saved': '緊急復原問題已儲存。',
    'recovery_question_deleted': '緊急復原問題已刪除。',
    'recovery_question_delete': '刪除',

    // 使用者名稱
    'username_change': '變更使用者名稱',
    'username_label': '姓名',
    'username_hint': '例如：張三',
    'username_error_empty': '請輸入姓名',
    'username_updated': '使用者名稱已更新。',

    // 主題
    'theme_system': '系統設定',
    'theme_light': '淺色',
    'theme_dark': '深色',

    // 字體大小
    'font_small': '小',
    'font_medium': '中',
    'font_large': '大',
    'font_extra_large': '超大',

    // 介紹影片
    'show_intro_video': '啟動時顯示介紹影片',
    'show_intro_video_subtitle': '應用程式啟動時顯示介紹影片',

    // 圖像生成
    'image_generation_count': 'AI圖像生成次數',
    'image_generation_description': '創建更多由AI生成的精美日記圖像！',
    'watch_ad_for_1_time': '觀看廣告再獲得1次',
    'watch_ad_subtitle': '觀看短廣告免費獲取',
    'ad_loading': '廣告載入中...',
    'ad_wait': '請稍候',
    'ad_reward_success': '廣告觀看完成！已添加2次生成次數。',

    // 回憶
    'memory_type_all': '全部',
    'memory_type_yesterday': '昨天',
    'memory_type_one_week_ago': '一週前',
    'memory_type_one_month_ago': '一個月前',
    'memory_type_one_year_ago': '一年前',
    'memory_type_past_today': '過去的今天',
    'memory_type_same_time': '同一時間',
    'memory_type_seasonal': '季節性',
    'memory_type_special_date': '特殊日期',
    'memory_type_similar_tags': '相似標籤',
    'memory_reason_yesterday': '昨天的記錄',
    'memory_reason_one_week_ago': '一週前的記錄',
    'memory_reason_one_month_ago': '一個月前的記錄',
    'memory_reason_one_year_ago': '一年前的記錄',
    'memory_reason_past_today': '過去這一天的記錄',
    'memory_reason_same_time': '這個時間的記錄',
    'memory_reason_seasonal': '季節記錄',
    'memory_reason_special_date': '特殊日期的記錄',
    'memory_reason_similar_tags': '相似標籤的記錄',
    'memory_bookmark': '書籤',
    'memory_bookmark_remove': '取消書籤',

    // OCR
    'ocr_camera_title': '拍照',
    'ocr_auto_detect': '自動檢測',
    'ocr_language_korean': '韓語',
    'ocr_language_english': 'English',
    'ocr_language_japanese': '日語',
    'ocr_language_chinese': '中文',

    // 語音識別
    'speech_language_korean': '韓語',
    'speech_language_english': 'English',
    'speech_language_japanese': '日語',
    'speech_language_chinese': '中文',
    'speech_initializing': '正在初始化語音識別...',
    'speech_ready': '點擊麥克風按鈕開始語音識別',
    'speech_listening': '請說話。完成後再次點擊按鈕',
    'speech_processing': '正在將語音轉換為文字...',
    'speech_completed': '語音識別已完成',
    'speech_error': '語音識別過程中發生錯誤。請重試',
    'speech_cancelled': '語音識別已取消',
    'speech_error_title': '語音識別錯誤',
    'speech_cancel': '取消',
    'speech_retry': '重試',
    'speech_error_solutions': '解決方法:',
    'speech_error_check_permission': '• 檢查麥克風權限是否已授予',
    'speech_error_check_internet': '• 檢查網路連線',
    'speech_error_quiet_environment': '• 在更安靜的環境中重試',
    'speech_error_check_microphone': '• 檢查麥克風是否正常工作',
    'speech_permission_title': '需要麥克風權限',
    'speech_permission_description': '使用語音識別功能需要麥克風權限。',
    'speech_permission_usage': '此權限僅用於:',
    'speech_permission_convert': '• 將語音轉換為文字',
    'speech_permission_diary': '• 寫日記時的語音輸入',
    'speech_permission_accuracy': '• 提高語音識別準確性',
    'speech_permission_deny': '拒絕',
    'speech_permission_allow': '允許',
    'speech_init_failed': '語音識別服務初始化失敗。',
    'speech_init_error': '初始化過程中發生錯誤',
    'speech_permission_required': '需要麥克風權限。',
    'speech_start_failed': '啟動語音識別失敗。',
    'speech_start_error': '啟動語音識別時發生錯誤',
    'speech_stop_error': '停止語音識別時發生錯誤',
    'speech_cancel_error': '取消語音識別時發生錯誤',

    // 語音錄音
    'voice_recording_title': '語音錄音',
    'voice_recording_init_failed': '無法初始化語音識別服務。',
    'voice_recording_start_failed': '無法開始語音錄音。',
    'voice_recording_recording': '錄音中...',
    'voice_recording_paused': '已暫停',
    'voice_recording_resume_prompt': '恢復錄音',
    'voice_recording_start_prompt': '開始錄音',
    'voice_recording_recognized_text': '識別的文字:',
    'voice_recording_stop': '停止錄音',
    'voice_recording_resume': '恢復錄音',
    'voice_recording_start': '開始錄音',
    'voice_recording_cancel': '取消',
    'voice_recording_confirm': '確認',

    // 權限請求 (Permission Request)
    'permission_request_title': '權限設定',
    'permission_request_subtitle': '使用應用程式功能需要以下權限',
    'permission_camera_title': '相機權限',
    'permission_camera_description': '使用OCR文字識別功能需要相機存取權限。',
    'permission_microphone_title': '麥克風權限',
    'permission_microphone_description': '使用語音記錄日記需要麥克風存取權限。',
    'permission_allow_all': '全部允許',
    'permission_skip': '稍後設定',
    'permission_continue': '繼續',
    'permission_granted': '已允許',
    'permission_denied': '已拒絕',
    'permission_open_settings': '開啟設定',
    'permission_required_features': '某些功能需要權限',
    'permission_camera_rationale': '拍照識別文字需要相機權限。',
    'permission_microphone_rationale': '使用語音記錄日記需要麥克風權限。',
    'permission_settings_guide': '權限已被永久拒絕。請在設定中允許權限。',

    // 日期顯示
    'date_today': '今天',
    'date_yesterday': '昨天',

    // 通知
    'notifications': '通知',
    'daily_reminder': '日記提醒',
    'daily_reminder_subtitle': '每天提醒您寫日記',
    'reminder_time': '提醒時間',

    // 資料管理
    'data_management': '資料管理',

    // 資訊
    'info': '資訊',
    'app_version': '應用程式版本',
    'privacy_policy': '隱私權政策',
    'privacy_policy_subtitle': '查看我們的隱私權政策',
    'terms_of_service': '服務條款',
    'terms_of_service_subtitle': '查看我們的服務條款',
    'app_description': '用AI繪製的精美圖像記錄您的珍貴時刻。',
    'app_developer': '開發者: EveryDiary',
    'app_contact': '聯絡方式: window98se@gmail.com',

    // 版本1.0.3 更新內容
    'version_1_0_3_title': 'v1.0.3 更新內容',
    'version_1_0_3_change_1': '改進Android 15顯示相容性',
    'version_1_0_3_change_2': '修復回憶提醒時間設定',
    'version_1_0_3_change_3': '提升OCR相機畫質（使用裝置相機）',
    'version_1_0_3_change_4': '新增遊戲角色縮圖樣式（像素藝術）',
    'version_1_0_3_change_5': 'UI簡化和穩定性改進',

    // 版本1.0.4 更新內容
    'version_1_0_4_title': 'v1.0.4 更新內容',
    'version_1_0_4_change_1': '改進日記文字可讀性（優化字型顏色）',
    'version_1_0_4_change_2': '新增「與聖誕老人一起」縮圖樣式',
    'version_1_0_4_change_3': '重新設計縮圖樣式選擇器為3列網格UI',
    'version_1_0_4_change_4': '在日記編寫頁面新增縮圖樣式按鈕',
    'version_1_0_4_change_5': '廣告獎勵從1次增加到2次',
    'version_1_0_4_change_6': '改進Android 15邊到邊相容性',

    // 性別相關
    'user_gender': '性別',
    'select_gender': '選擇性別',
    'gender_male': '男性',
    'gender_female': '女性',
    'gender_none': '未指定',

    // 彩色鉛筆風格
    'style_color_pencil': '彩色鉛筆',

    // 毛線玩偶風格
    'style_felted_wool': '毛線玩偶',

    // 3D動畫風格
    'style_3d_animation': '3D動畫',

    // 新樣式添加彈窗
    'new_styles_popup_title': '新樣式添加！',
    'new_styles_popup_message': '毛線玩偶和3D動畫樣式已添加。請在設定中查看！',
    'new_styles_popup_dont_show': '不再顯示',
    'new_styles_popup_check': '查看',

    // 版本1.1.1 更新內容
    'version_1_1_1_title': 'v1.1.1 更新內容',
    'version_1_1_1_change_1': '新增縮圖樣式：毛線玩偶',
    'version_1_1_1_change_2': '新增縮圖樣式：3D動畫',

    // 版本1.1.0 更新內容
    'version_1_1_0_title': 'v1.1.0 更新內容',
    'version_1_1_0_change_1': '添加用戶性別設置（反映在AI圖像中）',
    'version_1_1_0_change_2': '新增縮圖樣式：彩色鉛筆',
    'version_1_1_0_change_3': '修復了一些小問題',

    // 版本1.0.9 更新內容
    'version_1_0_9_title': 'v1.0.9 更新內容',
    'version_1_0_9_change_1': '新增縮圖樣式：兒童畫',
    'version_1_0_9_change_2': '新增縮圖樣式：公仔',

    // 版本1.0.8 更新內容
    'version_1_0_8_title': 'v1.0.8 更新內容',
    'version_1_0_8_change_1': 'AI生成內容政策合規',

    // 版本1.0.7 更新內容
    'version_1_0_7_title': 'v1.0.7 更新內容',
    'version_1_0_7_change_1': '修復主頁背景圖像更新時UI消失的問題',

    // AI內容檢舉功能
    'report_ai_content': '檢舉AI內容',
    'report_description': '發現不當或令人不適的AI生成內容？請選擇檢舉原因。',
    'report_select_reason': '選擇檢舉原因',
    'report_reason_inappropriate': '不當內容',
    'report_reason_offensive': '令人不適的內容',
    'report_reason_misleading': '誤導性內容',
    'report_reason_copyright': '侵犯版權',
    'report_reason_other': '其他',
    'report_additional_details': '補充說明（可選）',
    'report_details_hint': '請輸入關於此檢舉的補充說明...',
    'report_submit': '提交檢舉',
    'report_submitted': '檢舉已提交。我們將審核並採取措施。',
    'report_error': '處理檢舉時出錯',
    'report_email_error': '無法開啟郵件應用程式。請直接聯繫window98se@gmail.com。',
    'report_email_subject': '[EveryDiary] AI內容檢舉',
    'report_reason': '檢舉原因',
    'report_details': '補充說明',
    'report_no_details': '無補充說明',
    'report_image_info': '圖像資訊',
    'report_image_preview': '檢舉對象圖像',
    'report_prompt_label': '生成提示詞',
    'report_agree_share_image': '我同意為此檢舉共享圖像和提示詞',
    'report_send_to': '檢舉接收處',

    // 版本1.0.6 更新內容
    'version_1_0_6_title': 'v1.0.6 更新內容',
    'version_1_0_6_change_1': '應用程式啟動時新增介紹影片',
    'version_1_0_6_change_2': 'AdMob政策審核期間，每日自動重置2次免費AI圖像生成',
    'version_1_0_6_change_3': '程式碼優化和穩定性改進',

    // 版本1.0.5 更新內容
    'version_1_0_5_title': 'v1.0.5 更新內容',
    'version_1_0_5_change_1': '改進日記文字可讀性（優化字型顏色）',
    'version_1_0_5_change_2': '新增「與聖誕老人一起」縮圖樣式',
    'version_1_0_5_change_3': '重新設計縮圖樣式選擇器為3列網格UI',
    'version_1_0_5_change_4': '在日記編寫頁面新增縮圖樣式按鈕',
    'version_1_0_5_change_5': '廣告獎勵從1次增加到2次',
    'version_1_0_5_change_6': '改進Android 15邊到邊相容性',
    'version_1_0_5_change_7': '優化了應用程式大小',
    'version_1_0_5_change_8': '現在支援韓語/英語/日語以外的177個國家',

    // ===== NEW TRANSLATIONS =====

    // Onboarding (14 keys)
    'welcome_title': '歡迎來到EveryDiary！',
    'setup_subtitle': '請先設定應用程式中使用的姓名和鎖定選項。',
    'name_label': '姓名',
    'name_hint': '例如：張三',
    'name_required': '請輸入姓名',
    'name_max_length': '姓名必須在24個字元以內',
    'pin_lock_title': '應用程式啟動時使用PIN鎖定',
    'pin_lock_subtitle': '設定開啟應用程式時輸入4位PIN。',
    'pin_label': 'PIN（4位數字）',
    'pin_required': '請輸入4位數字',
    'pin_numbers_only': '只能輸入數字',
    'pin_confirm_label': '確認PIN',
    'pin_mismatch': 'PIN不符',
    'start_button': '開始',
    'setup_save_failed': '設定儲存失敗',

    // Home Screen (11 keys)
    'home_greeting': '{name}，您好 👋',
    'home_subtitle': '記錄今天的瞬間，用AI圖像保留情感。',
    'quick_actions_title': '快速操作',
    'new_diary': '寫新日記',
    'view_diaries': '查看我的日記',
    'statistics_action': '日記統計',
    'memory_notifications': '回憶通知設定',
    'app_intro_title': '應用程式介紹',
    'fallback_features_title': 'EveryDiary主要功能',
    'fallback_features_list': 'OCR · 語音錄製 · 情感分析 · AI圖像 · 備份管理 · PIN安全 · 螢幕隱私',
    'diary_author': '日記作者',

    // Error Page (4 keys)
    'error_title': '錯誤',
    'page_not_found': '找不到頁面',
    'page_not_found_subtitle': '您請求的頁面不存在',
    'back_to_home': '返回主頁',

    // Privacy & Terms (2 keys)
    'privacy_policy_title': '隱私權政策',
    'terms_of_service_title': '服務條款',

    // Diary Write Screen (49 keys)
    'diary_write_title': '寫日記',
    'save_tooltip': '儲存',
    'thumbnail_style_tooltip': '縮圖樣式設定',
    'exit_without_save_title': '不儲存退出嗎？',
    'exit_without_save_message': '正在編寫的內容將不會儲存。',
    'exit': '退出',
    'title_label': '標題',
    'title_hint': '輸入今天的日記標題',
    'title_required': '請輸入標題',
    'date_label': '日期',
    'emotion_analysis_label': '情感分析',
    'emotion_analyzing': '正在分析情感...',
    'ocr_button': 'OCR',
    'voice_recording_button': '語音錄製',
    'save_button': '儲存日記',
    'saved_success': '日記已儲存。',
    'save_failed': '儲存失敗',
    'load_error': '載入日記時發生錯誤',
    'load_timeout': '日記載入逾時。請重試。',
    'retry': '重試',
    'text_add_error': '新增文字時發生錯誤',
    'thumbnail_empty_content': '內容為空，無法產生縮圖。',
    'thumbnail_no_diary': '沒有正在編輯的日記，跳過重新產生。',
    'thumbnail_regenerating': '正在重新產生縮圖。請稍候。',
    'ocr_success': '文字辨識完成',
    'ocr_cancelled': '文字辨識已取消',
    'ocr_unavailable': 'OCR功能不可用',
    'camera_permission_error': '無法存取相機。請檢查權限。',
    'camera_permission_required': '需要相機權限。',
    'voice_error': '語音錄製錯誤',
    'voice_text_added': '語音文字已新增。',
    'voice_text_add_failed': '語音文字新增失敗。',
    'invalid_diary_id': '無效的日記ID',
    'content_placeholder': '在此輸入內容...',
    'characters': '字',
    'diary_content_placeholder': '記錄今天的故事...',
    'editor_undo_tooltip': '復原',
    'editor_redo_tooltip': '重做',
    'editor_bold_tooltip': '粗體',
    'editor_italic_tooltip': '斜體',
    'editor_underline_tooltip': '底線',
    'editor_bulleted_list_tooltip': '項目符號清單',
    'editor_numbered_list_tooltip': '編號清單',
    'editor_align_left_tooltip': '靠左對齊',
    'editor_align_center_tooltip': '置中對齊',
    'editor_align_right_tooltip': '靠右對齊',

    // Thumbnail Style (24 keys)
    'thumbnail_dialog_title': '自訂縮圖樣式',
    'thumbnail_dialog_subtitle': '調整AI縮圖樣式和校正值以反映您的偏好。',
    'style_select_title': '選擇樣式',
    'detail_adjust_title': '詳細調整',
    'brightness_label': '亮度',
    'contrast_label': '對比度',
    'saturation_label': '飽和度',
    'blur_radius_label': '模糊半徑',
    'overlay_color_label': '疊加顏色',
    'overlay_opacity_label': '疊加不透明度',
    'auto_optimization_title': '自動最佳化',
    'auto_optimization_subtitle': '根據分析結果自動校正提示',
    'manual_keyword_title': '自訂關鍵字',
    'manual_keyword_subtitle': '新增最多5個始終包含在AI提示中的關鍵字。',
    'keyword_label': '手動關鍵字',
    'keyword_hint': '例如：柔和色調，夜景',
    'keyword_add_button': '新增',
    'keyword_required': '請輸入關鍵字。',
    'keyword_max_length': '關鍵字必須在24個字元以內。',
    'keyword_duplicate': '此關鍵字已新增。',
    'keyword_max_count': '最多可註冊5個關鍵字。',
    'keyword_save_failed': '無法儲存關鍵字。請重試。',
    'keyword_empty_list': '沒有註冊的關鍵字。',
    'keyword_clear_all': '全部清除',

    // Thumbnail Styles (12 keys)
    'style_chibi': '三頭身漫畫',
    'style_cute': '可愛',
    'style_pixel_game': '遊戲角色',
    'style_realistic': '寫實',
    'style_cartoon': '卡通',
    'style_watercolor': '水彩',
    'style_oil': '油畫',
    'style_sketch': '素描',
    'style_digital': '數位藝術',
    'style_vintage': '復古',
    'style_modern': '現代',
    'style_santa_together': '與聖誕老人一起',
    'style_child_draw': '兒童畫',
    'style_figure': '公仔',

    // Diary List (21 keys)
    'my_diary': '我的日記',
    'back_tooltip': '返回',
    'calendar_tooltip': '日曆檢視',
    'filter_tooltip': '篩選',
    'sort_tooltip': '排序',
    'new_diary_fab': '寫新日記',
    'delete_title': '刪除日記',
    'delete_message': '確定要刪除此日記嗎？\n已刪除的日記無法復原。',
    'delete_button': '刪除',
    // 保存圖片
    'image_save_title': '保存圖片',
    'image_save_message': '是否將此圖片保存到相冊？',
    'image_save_success': '圖片已保存到相冊',
    'image_save_failed': '無法保存圖片',
    'image_save_error': '保存圖片時發生錯誤',
    'image_save_hint': '長按圖片即可保存到相冊',
    // 網路通知
    'network_offline_title': '離線模式',
    'network_offline_message': 'AI圖片生成可能失敗。',
    // 日記詳情頁面
    'diary_detail_title': '日記詳情',
    'tab_detail': '詳細內容',
    'tab_history': '編輯歷史',
    'tooltip_favorite_add': '添加到收藏',
    'tooltip_favorite_remove': '從收藏中移除',
    'tooltip_edit': '編輯',
    'tooltip_share': '分享',
    'tooltip_delete': '刪除',
    'favorite_added': '已添加到收藏',
    'favorite_removed': '已從收藏中移除',
    'favorite_error': '更改收藏狀態時發生錯誤',
    'diary_deleted': '日記已刪除',
    'diary_delete_failed': '刪除日記失敗',
    'diary_delete_error': '刪除日記時發生錯誤',
    'diary_not_found': '找不到日記',
    'diary_not_found_message': '您請求的日記不存在或已被刪除',
    'diary_load_error': '加載日記時發生錯誤',
    'association_image_title': '日記聯想圖片',
    'association_image_generating': '正在生成日記聯想圖片...',
    'association_image_generating_message': '正在根據日記內容生成AI圖片。',
    'association_image_error': '無法顯示日記聯想圖片',
    'association_image_load_error': '無法加載圖片',
    'image_generation_failed': '圖片生成失敗',
    'image_load_error': '加載圖片時發生錯誤',
    'generation_prompt': '生成提示',
    'emotion_label': '情感',
    'style_label': '風格',
    'topic_label': '主題',
    'generated_date': '生成日期',
    'info_title': '信息',
    'word_count': '字數',
    'created_date': '創建日期',
    'modified_date': '修改日期',
    'tags_title': '標籤',
    'time_morning': '早上',
    'time_day': '白天',
    'time_evening': '晚上',
    'time_night': '夜晚',
    'retry_button': '重試',
    'back_to_list': '返回列表',

    // 編輯歷史 (2 keys)
    'edit_history_empty': '沒有編輯歷史',
    'edit_history_empty_message': '編輯日記後將記錄歷史',

    // 日記保存 (1 key)
    'diary_saved': '日記已保存',

    // 心情 (16 keys)
    'mood_happy': '快樂',
    'mood_sad': '悲傷',
    'mood_angry': '生氣',
    'mood_calm': '平靜',
    'mood_excited': '興奮',
    'mood_worried': '擔心',
    'mood_tired': '疲倦',
    'mood_satisfied': '滿意',
    'mood_disappointed': '失望',
    'mood_grateful': '感激',
    'mood_lonely': '孤獨',
    'mood_thrilled': '激動',
    'mood_depressed': '抑鬱',
    'mood_nervous': '緊張',
    'mood_comfortable': '舒適',
    'mood_other': '其他',

    // 天氣 (9 keys)
    'weather_sunny': '晴朗',
    'weather_cloudy': '多雲',
    'weather_rainy': '雨',
    'weather_snowy': '雪',
    'weather_windy': '風',
    'weather_foggy': '霧',
    'weather_hot': '酷熱',
    'weather_cold': '寒冷',
    'weather_other': '其他',

    'sort_dialog_title': '排序依據',
    'sort_date_desc': '最新優先',
    'sort_date_asc': '最早優先',
    'sort_title_asc': '標題（A-Z）',
    'sort_title_desc': '標題（Z-A）',
    'sort_mood': '按心情',
    'sort_weather': '按天氣',
    'error_load_diaries': '無法載入日記',
    'error_unknown': '發生未知錯誤',
    'empty_diaries_title': '還沒有日記',
    'empty_diaries_subtitle': '寫下您的第一篇日記',
    'empty_diaries_action': '寫日記',

    // Statistics (7 keys)
    'statistics_title': '日記統計',
    'date_range_tooltip': '選擇日期範圍',
    'period_title': '分析期間',
    'preset_week': '最近1週',
    'preset_month': '最近1個月',
    'preset_quarter': '最近3個月',
    'preset_year': '最近1年',

    // Backup & Restore (49 keys)
    'backup_section_title': '備份與復原',
    'create_backup_button': '建立備份',
    'restore_from_file_button': '從檔案復原',
    'auto_backup_title': '自動備份',
    'backup_interval_label': '備份週期：',
    'interval_daily': '每天',
    'interval_3days': '每3天',
    'interval_weekly': '每週',
    'interval_biweekly': '每兩週',
    'interval_monthly': '每月',
    'max_backups_label': '最大備份數：',
    'max_3': '3個',
    'max_5': '5個',
    'max_10': '10個',
    'max_20': '20個',
    'no_backups_title': '沒有備份',
    'no_backups_subtitle': '建立您的第一個備份',
    'available_backups_title': '可用備份',
    'created_date_label': '建立日期',
    'size_label': '大小',
    'includes_label': '包含',
    'includes_settings': '設定',
    'includes_profile': '個人資料',
    'includes_diary': '日記',
    'restore_action': '復原',
    'delete_action': '刪除',
    'backup_success': '備份建立成功。',
    'backup_failed': '備份建立失敗。',
    'backup_error': '建立備份時發生錯誤',
    'restore_success': '復原成功完成。',
    'restore_failed': '復原失敗。',
    'restore_error': '復原過程中發生錯誤',
    'delete_success': '備份已刪除。',
    'delete_failed': '備份刪除失敗。',
    'delete_error': '刪除備份時發生錯誤',
    'load_error_backup': '載入資料時發生錯誤',
    'file_picker_error': '選擇檔案時發生錯誤',
    'auto_backup_update_error': '更新自動備份設定時發生錯誤',
    'interval_update_error': '設定備份週期時發生錯誤',
    'max_backups_update_error': '設定最大備份數時發生錯誤',
    'restore_confirm_title': '復原資料',
    'restore_confirm_message': '目前資料將被備份資料覆蓋。\n此操作無法撤銷。\n\n繼續嗎？',
    'delete_confirm_title': '刪除備份',
    'delete_confirm_message': '確定要刪除此備份嗎？\n此操作無法撤銷。',
    'count_suffix': '個',

    // Calendar (16 keys)
    'calendar': '日曆',
    'back': '返回',
    'diary_statistics': '日記統計',
    'weekly_view': '週視圖',
    'monthly_view': '月視圖',
    'today': '今天',
    'write_new_diary': '撰寫新日記',
    'calendar_legend_multiple_entries': '橙色圓點表示有2篇或更多日記。',
    'please_select_date': '請選擇日期',
    'diary_count': '{count}篇日記',
    'no_diary_on_this_day': '這一天沒有日記',
    'write_diary': '寫日記',
    'diary_search_hint': '搜尋日記...',
    'clear_search_tooltip': '清除搜尋',
    'today_with_date': '今天（{month}月{day}日）',
    'yesterday_with_date': '昨天（{month}月{day}日）',
    'tomorrow_with_date': '明天（{month}月{day}日）',
    'full_date': '{year}年{month}月{day}日',

    // Statistics Widget (25 keys)
    'stats_overall_title': '整體統計',
    'stats_total_diaries': '總日記數',
    'stats_total_diaries_unit': '{count}篇',
    'stats_current_streak': '當前連續',
    'stats_current_streak_unit': '{count}天',
    'stats_longest_streak': '最長連續',
    'stats_longest_streak_unit': '{count}天',
    'stats_daily_average': '日平均',
    'stats_daily_average_unit': '{count}篇',
    'stats_most_active_day': '最活躍的星期',
    'stats_most_active_day_unit': '星期{day}',
    'stats_most_active_month': '最活躍的月份',
    'stats_monthly_frequency': '月度寫作頻率',
    'stats_weekly_frequency': '週度寫作頻率',
    'stats_no_data': '暫無數據',
    'stats_count_unit': '{count}篇',
    'stats_content_length_title': '日記長度統計',
    'stats_average_characters': '平均字數',
    'stats_characters_unit': '{count}字',
    'stats_average_words': '平均詞數',
    'stats_words_unit': '{count}個',
    'stats_max_characters': '最大字數',
    'stats_min_characters': '最小字數',
    'stats_writing_time_title': '寫作時段統計',
    'stats_time_count_unit': '{count}次',

    // Generation Count Widget (3 keys)
    'ai_image_generation': 'AI圖像生成',
    'remaining_count_label': '剩餘次數: ',
    'count_times': '次',

    // Memory Screen (14 keys)
    'memory_title': '回憶',
    'memory_back_tooltip': '返回',
    'memory_notifications_tooltip': '通知設定',
    'memory_filter_tooltip': '篩選',
    'memory_refresh_tooltip': '重新整理',
    'memory_loading': '正在載入回憶...',
    'memory_load_failed': '載入回憶失敗',
    'memory_unknown_error': '發生未知錯誤',
    'memory_retry_button': '重試',
    'memory_empty_title': '暫無回憶',
    'memory_empty_description': '寫下日記以回顧過去的記錄',
    'memory_write_diary_button': '寫日記',
    'memory_bookmarked': '已收藏 {title}',
    'memory_bookmark_removed': '已取消收藏 {title}',

    // App Intro Features (16 keys)
    'feature_ocr_title': 'OCR文字提取',
    'feature_ocr_desc': '拍攝紙上記錄，立即轉換為文字。',
    'feature_voice_title': '語音錄音',
    'feature_voice_desc': '將您說的話自然地轉換為日記。',
    'feature_emotion_title': '情緒分析',
    'feature_emotion_desc': '整理日記中的情緒並以統計形式呈現。',
    'feature_ai_image_title': 'AI圖像生成',
    'feature_ai_image_desc': '創建與日記氛圍相匹配的情感背景圖像。',
    'feature_search_title': '日記搜尋',
    'feature_search_desc': '透過關鍵詞和日期快速查找日記。',
    'feature_backup_title': '備份檔案管理',
    'feature_backup_desc': '匯出和匯入備份檔案，隨時安全保存。',
    'feature_pin_title': 'PIN安全',
    'feature_pin_desc': '透過PIN鎖定安全保護您的個人日記。',
    'feature_privacy_title': '背景螢幕隱藏',
    'feature_privacy_desc': '在背景模糊處理螢幕以保護隱私。',

    // Emotion Arrow
    'emotion_arrow': '→',

    // Emotion Names
    'emotion_joy': '快樂',
    'emotion_default': '預設',
    'emotion_sadness': '悲傷',
    'emotion_anger': '憤怒',
    'emotion_fear': '恐懼',
    'emotion_surprise': '驚訝',
    'emotion_disgust': '厭惡',
    'emotion_anticipation': '期待',
    'emotion_trust': '信任',

    // Privacy Policy Content
    'privacy_policy_content': '''EveryDiary 隱私政策

1. 個人資訊處理目的
EveryDiary（以下簡稱「應用程式」）為以下目的處理個人資訊：

- 提供日記撰寫和管理服務
- 提供使用者設定和自訂功能
- 改進服務和提升使用者體驗

2. 收集的個人資訊項目
應用程式收集以下個人資訊：

- 使用者名稱（可選）
- PIN鎖定設定資訊（可選）
- 日記內容及相關資料（本地儲存）
- 應用程式設定資訊

3. 個人資訊的保留和使用期限
應用程式保留個人資訊，直到使用者直接刪除或解除安裝應用程式。

所有資料都在使用者裝置上本地儲存，不會傳輸到外部伺服器。

4. 向第三方提供個人資訊
應用程式不會向第三方提供使用者的個人資訊。

5. 個人資訊的銷毀
當使用者解除安裝應用程式或刪除資料時，所有個人資訊將立即銷毀。

6. 自動收集個人資訊裝置的安裝、操作及拒絕
應用程式不使用Cookie或類似的追蹤技術。

7. 個人資訊保護負責人
如有個人資訊相關問題，請聯絡我們：
電子郵件: support@everydiary.app

8. 隱私政策的變更
本隱私政策可能根據法律法規和政策進行變更，變更時將在應用程式內通知。

生效日期: 2025年1月1日''',

    // Terms of Service Content
    'terms_of_service_content': '''EveryDiary 服務條款

第1條（目的）
本條款旨在規定應用程式營運者和使用者關於使用EveryDiary（以下簡稱「應用程式」）的權利、義務和責任事項。

第2條（定義）
1. 「應用程式」是指允許使用者撰寫和管理日記的行動應用程式。
2. 「使用者」是指根據本條款使用應用程式的人。
3. 「內容」是指使用者透過應用程式建立的日記和相關資料。

第3條（條款的效力和修改）
1. 本條款適用於所有下載和使用應用程式的使用者。
2. 本條款可根據需要進行修改，修改後的條款將在應用程式內通知。

第4條（服務提供）
1. 應用程式為使用者提供日記撰寫、管理、備份等功能。
2. 應用程式免費提供，部分功能可透過應用程式內購買使用。

第5條（使用者義務）
1. 使用者必須遵守本條款和相關法律。
2. 使用者不得將應用程式用於非法目的。
3. 使用者有責任安全管理其帳戶資訊和PIN碼。

第6條（內容管理）
1. 使用者建立的內容儲存在使用者裝置的本地。
2. 使用者對其建立的內容擁有所有權利和責任。
3. 應用程式營運者不存取使用者內容，也不向第三方提供。

第7條（服務中斷）
應用程式營運者可在以下情況下中斷服務提供：
1. 需要系統維護時
2. 發生不可抗力情況時

第8條（免責條款）
1. 應用程式營運者對使用者裝置錯誤、資料遺失等造成的損害不承擔責任。
2. 使用者應定期執行備份以防止資料遺失。

第9條（爭議解決）
與本條款相關的爭議應根據大韓民國法律解決。

生效日期: 2025年1月1日''',
  };
}
