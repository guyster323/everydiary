import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_input_field.dart';
import '../../../shared/models/diary_entry.dart';
import '../../../shared/services/database_service.dart';
import '../../../shared/services/repositories/diary_repository.dart';
import '../../../shared/services/safe_delta_converter.dart';
import '../../ocr/screens/simple_camera_screen.dart';
import '../services/diary_list_service.dart';
import '../services/diary_save_service.dart';
import '../services/dual_emotion_analysis_service.dart';
import '../services/emotion_analysis_service.dart';
import '../services/image_attachment_service.dart';
import '../services/tag_service.dart';
import '../widgets/diary_rich_text_editor.dart';
import '../widgets/improved_dual_emotion_watercolor_background.dart';
import '../widgets/voice_recording_dialog.dart';

/// 일기 작성 화면 (편집 모드 지원)
class DiaryWriteScreen extends ConsumerStatefulWidget {
  final int? diaryId; // 편집 모드일 때 사용할 일기 ID
  final String? initialTitle; // 편집 모드일 때 사용할 초기 제목
  final String? initialContent; // 편집 모드일 때 사용할 초기 내용
  final DateTime? initialDate; // 편집 모드일 때 사용할 초기 날짜
  final String? initialWeather; // 편집 모드일 때 사용할 초기 날씨
  final String? initialMood; // 편집 모드일 때 사용할 초기 감정

  const DiaryWriteScreen({
    super.key,
    this.diaryId,
    this.initialTitle,
    this.initialContent,
    this.initialDate,
    this.initialWeather,
    this.initialMood,
  });

  /// URL 쿼리 파라미터로부터 편집 모드 생성
  factory DiaryWriteScreen.fromQuery(Map<String, String> queryParams) {
    final editId = queryParams['editId'];
    return DiaryWriteScreen(
      diaryId: editId != null ? int.tryParse(editId) : null,
    );
  }

  @override
  ConsumerState<DiaryWriteScreen> createState() => _DiaryWriteScreenState();
}

class _DiaryWriteScreenState extends ConsumerState<DiaryWriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _editorKey = GlobalKey<DiaryRichTextEditorState>();
  DateTime _selectedDate = DateTime.now();
  String? _selectedWeather;
  String _contentDelta = '[]';

  // 감정 분석 관련
  DualEmotionAnalysisResult? _currentDualEmotion;
  List<String> _detectedKeywords = [];
  bool _isLoading = false;
  bool _isDirty = false;

  // 일기 저장 서비스
  late DiarySaveService _diarySaveService;

  // Debounce를 위한 타이머들
  Timer? _debounceTimer;
  Timer? _emotionAnalysisTimer;

  // 날씨 옵션
  final List<String> _weatherOptions = [
    '맑음',
    '흐림',
    '비',
    '눈',
    '바람',
    '안개',
    '폭염',
    '한파',
    '기타',
  ];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy년 MM월 dd일').format(_selectedDate);
    _titleController.addListener(_onTitleChanged);

    // 서비스들 초기화
    final databaseService = DatabaseService();
    final diaryRepository = DiaryRepository(databaseService);
    final imageService = ImageAttachmentService();
    final tagService = TagService();

    _diarySaveService = DiarySaveService(
      databaseService: databaseService,
      diaryRepository: diaryRepository,
      imageService: imageService,
      tagService: tagService,
    );

    // 편집 모드인지 확인하고 데이터 로드
    if (widget.diaryId != null) {
      _loadExistingDiary();
    } else {
      // 기본 감정을 기분 좋음으로 설정
      _setDefaultEmotion();

      // OCR에서 전달된 내용 처리
      if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
        debugPrint('📝 OCR에서 전달된 초기 내용 처리: ${widget.initialContent!.length}자');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _addOCRTextToContent(widget.initialContent!);
        });
      }
    }
  }

  /// 기존 일기 데이터 로드 - 최적화된 버전
  Future<void> _loadExistingDiary() async {
    if (widget.diaryId == null) return;
    debugPrint('📝 편집 모드: 일기 ID ${widget.diaryId} 로드 시작');

    try {
      setState(() {
        _isLoading = true;
      });

      // 데이터베이스에서 일기 데이터 로드
      final databaseService = DatabaseService();
      final diaryRepository = DiaryRepository(databaseService);

      // 로딩 최적화: 타임아웃 설정
      final diary = await diaryRepository
          .getDiaryEntryById(widget.diaryId!)
          .timeout(const Duration(seconds: 5));

      if (diary != null && mounted) {
        debugPrint('📝 일기 데이터 로드 성공: ${diary.title}');
        debugPrint('📝 내용 길이: ${diary.content.length}');
        debugPrint('📝 내용 원본: "${diary.content}"');

        // 안전한 Delta 변환 - 캐시된 변환 사용
        final String contentToUse = OptimizedDeltaConverter.textToDelta(
          diary.content,
        );

        debugPrint('📝 변환된 Delta JSON: $contentToUse');

        // UI 업데이트를 먼저 수행 (로딩 속도 향상)
        setState(() {
          _titleController.text = diary.title ?? '';
          _selectedDate = DateTime.parse(diary.date);
          _dateController.text = DateFormat(
            'yyyy년 MM월 dd일',
          ).format(_selectedDate);
          _contentDelta = contentToUse;
          _selectedWeather = diary.weather;
          _isDirty = false;
        });

        // 에디터에 내용 로드 - 강화된 재시도 로직
        _loadContentToEditorWithRetry(contentToUse, diary.content, 0);

        // 기존 일기 내용으로 감정 분석 수행
        if (contentToUse != '[{"insert":"\\n"}]') {
          debugPrint('📝 기존 내용으로 감정 분석 시작');
          _analyzeEmotionDebounced();
        } else {
          debugPrint('📝 빈 내용이므로 기본 감정 설정');
          _setDefaultEmotion();
        }

        debugPrint('📝 편집 모드 초기화 완료');
      } else if (mounted) {
        debugPrint('📝 일기를 찾을 수 없음');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('일기를 찾을 수 없습니다'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('📝 기존 일기 데이터 로드 실패: $e');
      if (mounted) {
        String errorMessage = '일기를 불러오는 중 오류가 발생했습니다';
        if (e.toString().contains('timeout')) {
          errorMessage = '일기 로딩 시간이 초과되었습니다. 다시 시도해주세요.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '다시 시도',
              onPressed: _loadExistingDiary,
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 에디터에 내용 로드 - 강화된 재시도 로직
  void _loadContentToEditorWithRetry(
    String contentDelta,
    String plainText,
    int retryCount,
  ) {
    if (!mounted || retryCount > 5) return;

    if (_editorKey.currentState != null) {
      try {
        _editorKey.currentState!.loadContent(contentDelta);
        debugPrint('📝 에디터에 내용 로드 성공 (재시도 $retryCount)');
      } catch (e) {
        debugPrint('📝 에디터 로드 실패 (재시도 $retryCount): $e');
        // Delta 실패 시 평문 텍스트로 대안
        if (retryCount > 2) {
          try {
            final fallbackDelta = SafeDeltaConverter.textToDelta(plainText);
            _editorKey.currentState!.loadContent(fallbackDelta);
            debugPrint('📝 대안 Delta로 에디터 로드 성공');
          } catch (fallbackError) {
            debugPrint('📝 대안 Delta 로드도 실패: $fallbackError');
          }
        }
        // 실패 시 100ms 후 재시도
        Future.delayed(const Duration(milliseconds: 100), () {
          _loadContentToEditorWithRetry(
            contentDelta,
            plainText,
            retryCount + 1,
          );
        });
      }
    } else {
      // 에디터가 아직 준비되지 않았으면 100ms 후 재시도
      Future.delayed(const Duration(milliseconds: 100), () {
        _loadContentToEditorWithRetry(contentDelta, plainText, retryCount + 1);
      });
    }
  }

  /// OCR 텍스트를 일기 내용에 추가 - 개선된 버전
  void _addOCRTextToContent(String text) {
    if (text.isEmpty) {
      debugPrint('🔍 OCR 텍스트가 비어있음 - 추가하지 않음');
      return;
    }

    // 테스트 메시지 필터링
    final testMessages = [
      '감정 분석과 일기 작성 기능이 잘 통합되어 작동하고 있습니다',
      '이미지에서 텍스트를 추출하는 기능이 정상적으로 작동 중입니다',
      'OCR 기능이 정상적으로 작동하고 있습니다',
      '텍스트 인식이 완료되었습니다',
      '이미지 처리 중입니다',
      '텍스트 추출 중입니다',
    ];

    final bool isTestMessage = testMessages.any((msg) => text.contains(msg));
    if (isTestMessage) {
      debugPrint('🔍 테스트 메시지 감지 - 추가하지 않음: "$text"');
      return;
    }

    debugPrint('🔍 OCR 텍스트 추가 시작: ${text.length}자');
    debugPrint('🔍 OCR 텍스트 내용: "$text"');
    debugPrint('🔍 현재 _contentDelta: $_contentDelta');

    try {
      // 현재 에디터 내용 가져오기
      final String currentContent = _extractTextFromDelta(_contentDelta);

      // 새로운 내용 생성 및 에디터에 로드
      final String newContent = currentContent.isEmpty
          ? text
          : '$currentContent\n\n$text';
      final newContentDelta = SafeDeltaConverter.textToDelta(newContent);

      setState(() {
        _contentDelta = newContentDelta;
        _isDirty = true;
      });

      // 재시도 로직으로 안정적으로 로드
      _loadContentToEditorWithRetry(newContentDelta, newContent, 0);

      // 감정 분석 수행 (debounced)
      _analyzeEmotionDebounced();

      debugPrint('🔍 OCR 텍스트 추가 완료');
    } catch (e) {
      debugPrint('🔍 OCR 텍스트 추가 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('텍스트 추가 중 오류가 발생했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 기본 감정을 기분 좋음으로 설정
  void _setDefaultEmotion() {
    setState(() {
      _currentDualEmotion = const DualEmotionAnalysisResult(
        firstHalf: EmotionAnalysisResult(
          primaryEmotion: '기쁨',
          confidence: 0.8,
          detectedEmotions: ['기쁨'],
          emotionScores: {'기쁨': 0.8},
        ),
        secondHalf: EmotionAnalysisResult(
          primaryEmotion: '기쁨',
          confidence: 0.8,
          detectedEmotions: ['기쁨'],
          emotionScores: {'기쁨': 0.8},
        ),
        primaryEmotion: '기쁨',
        confidence: 0.8,
      );
      _detectedKeywords = ['기본', '기쁨'];
    });
  }

  /// 제목 변경 감지
  void _onTitleChanged() {
    setState(() {
      _isDirty = true;
    });
  }

  /// 콘텐츠 변경 감지 (debounced)
  void _onContentChanged(String deltaJson) {
    if (deltaJson == _contentDelta) {
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _contentDelta = deltaJson;
          _isDirty = true;
        });
        _analyzeEmotionDebounced();
      }
    });
  }

  /// 날짜 선택
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _isDirty = true;
      });
      _dateController.text = DateFormat('yyyy년 MM월 dd일').format(_selectedDate);
    }
  }

  /// 뒤로가기 처리
  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('저장하지 않고 나가시겠습니까?'),
        content: const Text('작성 중인 내용이 저장되지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('나가기'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// 일기 업데이트 (편집 모드)
  Future<DiarySaveResult> _updateDiary() async {
    if (widget.diaryId == null) {
      return DiarySaveResult.validationError;
    }

    try {
      // 텍스트 내용 추출
      final content = _extractTextFromDelta(_contentDelta);

      debugPrint('📝 업데이트할 내용: "$content"');
      debugPrint('📝 내용 길이: ${content.length}');

      // 데이터베이스에서 일기 업데이트
      final databaseService = DatabaseService();
      final diaryRepository = DiaryRepository(databaseService);

      // 빈 내용인 경우 기존 내용 유지 (제목은 업데이트)
      if (content.trim().isEmpty) {
        debugPrint('📝 내용이 비어있음 - 제목만 업데이트하고 내용은 유지');

        // 제목만 업데이트
        final updateDto = UpdateDiaryEntryDto(
          title: _titleController.text.trim(),
          content: null, // 내용은 업데이트하지 않음
          date: _selectedDate.toIso8601String(),
          mood: _currentDualEmotion?.primaryEmotion,
          weather: _selectedWeather,
        );

        final updatedDiary = await diaryRepository.updateDiaryEntry(
          widget.diaryId!,
          updateDto,
        );

        if (updatedDiary != null) {
          debugPrint('📝 일기 제목 업데이트 성공: ID ${updatedDiary.id}');
          return DiarySaveResult.success;
        } else {
          debugPrint('📝 일기 제목 업데이트 실패: 일기를 찾을 수 없음');
          return DiarySaveResult.databaseError;
        }
      }

      final updateDto = UpdateDiaryEntryDto(
        title: _titleController.text.trim(),
        content: content,
        date: _selectedDate.toIso8601String(),
        mood: _currentDualEmotion?.primaryEmotion,
        weather: _selectedWeather,
      );

      final updatedDiary = await diaryRepository.updateDiaryEntry(
        widget.diaryId!,
        updateDto,
      );

      if (updatedDiary != null) {
        debugPrint('📝 일기 업데이트 성공: ID ${updatedDiary.id}');
        return DiarySaveResult.success;
      } else {
        debugPrint('📝 일기 업데이트 실패: 일기를 찾을 수 없음');
        return DiarySaveResult.databaseError;
      }
    } catch (e) {
      debugPrint('📝 일기 업데이트 중 오류: $e');
      return DiarySaveResult.unknownError;
    }
  }

  /// 일기 저장
  Future<void> _saveDiary() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 텍스트 내용 추출
      final content = _extractTextFromDelta(_contentDelta);

      DiarySaveResult result;

      if (widget.diaryId != null) {
        // 편집 모드: 기존 일기 업데이트
        debugPrint('📝 편집 모드: 일기 ID ${widget.diaryId} 업데이트');
        result = await _updateDiary();
      } else {
        // 새로 작성 모드: 새 일기 생성
        debugPrint('📝 새로 작성 모드: 새 일기 생성');
        result = await _diarySaveService.saveDiary(
          userId: 1, // 임시 사용자 ID
          title: _titleController.text.trim(),
          content: content,
          date: _selectedDate,
          mood: _currentDualEmotion?.primaryEmotion,
          weather: _selectedWeather,
        );
      }

      if (mounted) {
        if (result == DiarySaveResult.success) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('일기가 저장되었습니다.')));

          // 일기 목록 새로고침을 위한 이벤트 발생
          try {
            final refreshNotifier = DiaryListRefreshNotifier();
            refreshNotifier.notifyRefresh();
            debugPrint('일기 목록 새로고침 이벤트 발생');
          } catch (e) {
            debugPrint('일기 목록 새로고침 이벤트 발생 실패: $e');
          }

          // ignore: use_build_context_synchronously
          context.pop(true); // true를 반환하여 새로고침 신호 전달
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '저장 실패: ${_diarySaveService.lastError ?? "알 수 없는 오류"}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 이중 감정 분석 수행
  void _analyzeEmotion() {
    debugPrint('이중 감정 분석 시작 - _contentDelta: $_contentDelta');
    if (_contentDelta.isEmpty || _contentDelta == '[]') {
      debugPrint('콘텐츠가 비어있음 - 감정 분석 중단');
      setState(() {
        _currentDualEmotion = null;
        _detectedKeywords = [];
      });
      return;
    }

    try {
      final text = _extractTextFromDelta(_contentDelta);
      debugPrint('추출된 텍스트: $text');
      if (text.isEmpty) {
        debugPrint('추출된 텍스트가 비어있음 - 감정 분석 중단');
        setState(() {
          _currentDualEmotion = null;
          _detectedKeywords = [];
        });
        return;
      }

      // 이중 감정 분석 수행
      final dualEmotion = DualEmotionAnalysisService.analyzeDualEmotion(text);

      // 감지된 키워드 추출 (1단계와 2단계 모두)
      final firstHalfKeywords = EmotionAnalysisService.getDetectedKeywords(
        text.split(' ').take((text.split(' ').length / 2).ceil()).join(' '),
        dualEmotion.firstHalf.primaryEmotion,
      );
      final secondHalfKeywords = EmotionAnalysisService.getDetectedKeywords(
        text.split(' ').skip((text.split(' ').length / 2).ceil()).join(' '),
        dualEmotion.secondHalf.primaryEmotion,
      );

      final allKeywords = [...firstHalfKeywords, ...secondHalfKeywords];

      debugPrint(
        '이중 감정 분석 결과 - 1단계: ${dualEmotion.firstHalf.primaryEmotion} (${dualEmotion.firstHalf.confidence.toStringAsFixed(2)}), 2단계: ${dualEmotion.secondHalf.primaryEmotion} (${dualEmotion.secondHalf.confidence.toStringAsFixed(2)})',
      );
      debugPrint('감지된 키워드: $allKeywords');

      setState(() {
        _currentDualEmotion = dualEmotion;
        _detectedKeywords = allKeywords;
      });

      debugPrint('이중 감정 분석 완료');
    } catch (e) {
      debugPrint('이중 감정 분석 실패: $e');
    }
  }

  /// 감정 분석을 debounce하여 수행
  void _analyzeEmotionDebounced() {
    _emotionAnalysisTimer?.cancel();
    _emotionAnalysisTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _analyzeEmotion();
      }
    });
  }

  /// Delta JSON에서 텍스트 추출
  String _extractTextFromDelta(String deltaJson) {
    return SafeDeltaConverter.extractTextFromDelta(deltaJson);
  }

  /// 감정 키워드 표시용 텍스트 생성
  String _getEmotionDisplayText() {
    if (_currentDualEmotion == null) return '감정을 분석 중...';

    final dualEmotion = _currentDualEmotion!;

    if (_detectedKeywords.isEmpty) {
      return '${dualEmotion.firstHalf.primaryEmotion} → ${dualEmotion.secondHalf.primaryEmotion}';
    }

    final contextParts = <String>[];
    if (_detectedKeywords.length > 3) {
      contextParts.addAll(_detectedKeywords.take(3));
      contextParts.add('...');
    } else {
      contextParts.addAll(_detectedKeywords);
    }

    return '${dualEmotion.firstHalf.primaryEmotion} → ${dualEmotion.secondHalf.primaryEmotion} (${contextParts.join(', ')})';
  }

  /// OCR 기능 열기 - 수정된 버전
  Future<void> _openOCR() async {
    try {
      setState(() {
        _isLoading = true;
      });

      debugPrint('🔍 OCR 화면 열기 시작');

      final result = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (context) => const SimpleCameraScreen()),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result != null && result.isNotEmpty) {
          debugPrint('🔍 OCR 결과 수신: ${result.length}자');
          debugPrint(
            '🔍 OCR 결과 내용: "${result.substring(0, result.length > 50 ? 50 : result.length)}..."',
          );

          // 실제 OCR 결과를 일기 내용에 추가
          _addOCRTextToContent(result);

          // 성공 메시지 표시
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('텍스트 인식 완료: ${result.length}자'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          debugPrint('🔍 OCR 결과가 비어있거나 취소됨');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('텍스트 인식이 취소되었습니다'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('🔍 OCR 화면 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = 'OCR 기능을 사용할 수 없습니다';
        if (e.toString().contains('camera')) {
          errorMessage = '카메라에 접근할 수 없습니다. 권한을 확인해주세요.';
        } else if (e.toString().contains('permission')) {
          errorMessage = '카메라 권한이 필요합니다.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            action: SnackBarAction(label: '다시 시도', onPressed: _openOCR),
          ),
        );
      }
    }
  }

  /// 음성녹음 시작
  Future<void> _startVoiceRecording() async {
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => const VoiceRecordingDialog(),
      );

      if (result != null && result.isNotEmpty) {
        // 음성으로 인식된 텍스트를 일기 내용에 추가
        _addVoiceTextToContent(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('음성녹음 오류: $e')));
      }
    }
  }

  /// 음성 텍스트를 일기 내용에 추가
  void _addVoiceTextToContent(String voiceText) {
    try {
      // 기존 방식 사용 (Delta JSON 직접 업데이트)
      _addVoiceTextToContentFallback(voiceText);
    } catch (e) {
      debugPrint('음성 텍스트 추가 실패: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('음성 텍스트 추가에 실패했습니다.')));
    }
  }

  /// 음성 텍스트 추가 폴백 메서드 (기존 방식)
  void _addVoiceTextToContentFallback(String voiceText) {
    try {
      // 현재 Delta JSON 파싱
      List<dynamic> deltaList = [];
      if (_contentDelta.isNotEmpty && _contentDelta != '[]') {
        deltaList = jsonDecode(_contentDelta) as List;
      }

      // 음성 텍스트를 Delta 형식으로 추가
      if (deltaList.isNotEmpty) {
        // 기존 내용이 있으면 줄바꿈 추가
        deltaList.add({'insert': '\n\n'});
      }
      deltaList.add({'insert': voiceText});

      // 새로운 Delta JSON 생성
      final newDeltaJson = jsonEncode(deltaList);

      setState(() {
        _contentDelta = newDeltaJson;
        _isDirty = true;
      });

      // 감정 분석 수행
      _analyzeEmotionDebounced();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('음성 텍스트가 추가되었습니다.')));
    } catch (e) {
      debugPrint('음성 텍스트 추가 실패: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('음성 텍스트 추가에 실패했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            // ignore: use_build_context_synchronously
            context.pop();
          }
        }
      },
      child: _currentDualEmotion != null
          ? ImprovedDualEmotionWatercolorBackground(
              emotionResult: _currentDualEmotion!,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: CustomAppBar(
                  title: '일기 작성',
                  backgroundColor: Colors.transparent,
                  actions: [
                    IconButton(
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.save),
                      onPressed: _isLoading ? null : _saveDiary,
                      tooltip: '저장',
                    ),
                  ],
                ),
                body: _buildBody(),
              ),
            )
          : Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              appBar: CustomAppBar(
                title: '일기 작성',
                actions: [
                  IconButton(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.save),
                    onPressed: _isLoading ? null : _saveDiary,
                    tooltip: '저장',
                  ),
                ],
              ),
              body: _buildBody(),
            ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 제목 입력 - 시인성 개선
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CustomInputField(
                controller: _titleController,
                labelText: '제목',
                hintText: '오늘의 일기 제목을 입력하세요',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),

            // 날짜 및 감정 분석 결과 - 시인성 개선
            Row(
              children: [
                // 날짜 선택
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CustomInputField(
                      controller: _dateController,
                      labelText: '날짜',
                      readOnly: true,
                      onTap: _selectDate,
                      suffixIcon: Icons.calendar_today,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // 감정 분석 결과 표시 - 시인성 개선
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '감정 분석',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87, // 감정 분석 라벨을 검정색으로 변경
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getEmotionDisplayText(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black, // 감정 분석 텍스트를 검정색으로 변경
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 날씨 선택 - 시인성 개선
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedWeather,
                items: _weatherOptions.map((weather) {
                  return DropdownMenuItem(
                    value: weather,
                    child: Text(
                      weather,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWeather = value;
                    _isDirty = true;
                  });
                },
                decoration: InputDecoration(
                  labelText: '날씨',
                  hintText: '날씨를 선택하세요',
                  labelStyle: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.all(16),
                ),
                dropdownColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // OCR 및 음성녹음 버튼 - 시인성 개선
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openOCR,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('OCR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: Colors.blue.withValues(alpha: 0.3),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _startVoiceRecording,
                    icon: const Icon(Icons.mic),
                    label: const Text('음성녹음'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: Colors.green.withValues(alpha: 0.3),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 일기 내용 입력 - 시인성 개선
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: DiaryRichTextEditor(
                  key: _editorKey,
                  initialContent: _contentDelta,
                  onContentChanged: _onContentChanged,
                  height: 300,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 저장 버튼 - 시인성 개선
            ElevatedButton(
              onPressed: _isLoading ? null : _saveDiary,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
                shadowColor: Colors.indigo.withValues(alpha: 0.3),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text('일기 저장'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _debounceTimer?.cancel();
    _emotionAnalysisTimer?.cancel();
    _diarySaveService.dispose();
    super.dispose();
  }
}

/// 성능 최적화된 Delta 변환
class OptimizedDeltaConverter {
  static final Map<String, String> _textToDeltaCache = {};
  static final Map<String, String> _deltaToTextCache = {};

  static String textToDelta(String text) {
    if (_textToDeltaCache.containsKey(text)) {
      return _textToDeltaCache[text]!;
    }

    final result = SafeDeltaConverter.textToDelta(text);

    // 캐시 크기 제한 (메모리 관리)
    if (_textToDeltaCache.length > 50) {
      _textToDeltaCache.clear();
    }

    _textToDeltaCache[text] = result;
    return result;
  }

  static String extractTextFromDelta(String deltaJson) {
    if (_deltaToTextCache.containsKey(deltaJson)) {
      return _deltaToTextCache[deltaJson]!;
    }

    final result = SafeDeltaConverter.extractTextFromDelta(deltaJson);

    // 캐시 크기 제한
    if (_deltaToTextCache.length > 50) {
      _deltaToTextCache.clear();
    }

    _deltaToTextCache[deltaJson] = result;
    return result;
  }

  static void clearCache() {
    _textToDeltaCache.clear();
    _deltaToTextCache.clear();
  }
}
