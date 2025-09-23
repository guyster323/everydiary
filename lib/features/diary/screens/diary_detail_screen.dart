import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_loading.dart';
import '../../../shared/models/diary_entry.dart';
import '../../../shared/models/tag.dart';
import '../../../shared/services/database_service.dart';
import '../../../shared/services/repositories/diary_repository.dart';
import '../services/diary_history_service.dart';
import '../services/diary_list_service.dart';
import '../services/emotion_analysis_service.dart';
import '../widgets/diary_history_widget.dart';
import '../widgets/diary_share_widget.dart';

/// 일기 상세 보기 화면
class DiaryDetailScreen extends ConsumerStatefulWidget {
  final int diaryId;

  const DiaryDetailScreen({super.key, required this.diaryId});

  @override
  ConsumerState<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends ConsumerState<DiaryDetailScreen>
    with TickerProviderStateMixin {
  DiaryEntry? _diary;
  bool _isLoading = true;
  String? _error;
  late DiaryRepository _diaryRepository;
  late DiaryHistoryService _historyService;
  StreamSubscription<void>? _refreshSubscription;

  // 탭 상태
  int _selectedTabIndex = 0;

  // 감정 분석 관련
  List<Color> _watercolorBackground = [
    const Color(0xFFE3F2FD), // 연한 파란색
    const Color(0xFFF3E5F5), // 연한 보라색
  ];

  // 애니메이션 컨트롤러들
  late AnimationController _contentAnimationController;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  @override
  void initState() {
    super.initState();
    _diaryRepository = DiaryRepository(DatabaseService()); // 향후 싱글톤 인스턴스 사용 예정
    _historyService = DiaryHistoryService();

    // 애니메이션 컨트롤러 초기화
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _contentSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // 일기 목록 새로고침 이벤트 구독
    _refreshSubscription = DiaryListRefreshNotifier().refreshStream.listen((_) {
      _loadDiary();
    });

    _loadDiary();
  }

  /// 감정 분석 수행
  void _analyzeEmotion() {
    if (_diary == null || _diary!.content.isEmpty) {
      setState(() {
        _watercolorBackground = [
          const Color(0xFFF5F5F5).withValues(alpha: 0.4), // 밝은 기본 배경
          const Color(0xFFFAFAFA).withValues(alpha: 0.3), // 더 밝은 기본 배경
        ];
      });
      return;
    }

    try {
      // Delta JSON에서 텍스트 추출
      final text = _extractTextFromDelta(_diary!.content);

      if (text.isEmpty) {
        setState(() {
          _watercolorBackground = [
            const Color(0xFFF5F5F5).withValues(alpha: 0.4), // 밝은 기본 배경
            const Color(0xFFFAFAFA).withValues(alpha: 0.3), // 더 밝은 기본 배경
          ];
        });
        return;
      }

      // 감정 분석 수행
      final emotion = EmotionAnalysisService.analyzeEmotion(text);

      setState(() {
        _watercolorBackground = emotion.watercolorBackgroundColors;
      });
    } catch (e) {
      debugPrint('감정 분석 실패: $e');
      setState(() {
        _watercolorBackground = [
          const Color(0xFFF5F5F5).withValues(alpha: 0.4), // 밝은 기본 배경
          const Color(0xFFFAFAFA).withValues(alpha: 0.3), // 더 밝은 기본 배경
        ];
      });
    }
  }

  /// Delta JSON에서 텍스트 추출
  String _extractTextFromDelta(String deltaJson) {
    try {
      if (deltaJson.isEmpty || deltaJson == '[]') return '';

      // Delta JSON 파싱
      final deltaList = jsonDecode(deltaJson) as List;
      final textBuffer = StringBuffer();

      for (final operation in deltaList) {
        if (operation is Map<String, dynamic> &&
            operation.containsKey('insert')) {
          final insert = operation['insert'];
          if (insert is String) {
            textBuffer.write(insert);
          }
        }
      }

      return textBuffer.toString().trim();
    } catch (e) {
      debugPrint('Delta JSON 파싱 실패: $e');
      // 파싱 실패 시 간단한 텍스트 추출로 폴백
      return deltaJson
          .replaceAll(RegExp(r'[^\w\s가-힣]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    }
  }

  /// 단어 수 계산
  int _calculateWordCount(String content) {
    if (content.isEmpty) return 0;

    // Delta JSON에서 텍스트 추출
    final text = _extractTextFromDelta(content);
    if (text.isEmpty) return 0;

    // 한글, 영문, 숫자만 추출하여 단어 수 계산
    final words = text
        .replaceAll(RegExp(r'[^\w\s가-힣]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    return words.length;
  }

  /// 일기 데이터 로드
  Future<void> _loadDiary() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final diary = await _diaryRepository.getDiaryEntryById(widget.diaryId);

      if (diary != null) {
        setState(() {
          _diary = diary;
          _isLoading = false;
        });

        // 감정 분석 수행
        _analyzeEmotion();

        // 애니메이션 시작
        _contentAnimationController.forward();

        // 히스토리 로드
        await _historyService.loadHistory(widget.diaryId);
      } else {
        setState(() {
          _error = '일기를 찾을 수 없습니다';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '일기를 불러오는 중 오류가 발생했습니다: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _contentAnimationController.dispose();
    _refreshSubscription?.cancel();
    super.dispose();
  }

  /// 일기 편집
  void _editDiary() {
    if (_diary != null) {
      context.push('/diary/edit/${_diary!.id}');
    }
  }

  /// 일기 삭제 확인
  void _confirmDeleteDiary() {
    if (_diary == null) return;

    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일기 삭제'),
        content: const Text('이 일기를 삭제하시겠습니까?\n삭제된 일기는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteDiary();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 일기 삭제
  Future<void> _deleteDiary() async {
    if (_diary == null) return;

    try {
      final success = await _diaryRepository.deleteDiaryEntry(_diary!.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('일기가 삭제되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('일기 삭제에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('일기 삭제 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 즐겨찾기 토글
  Future<void> _toggleFavorite() async {
    if (_diary == null) return;

    try {
      // 향후 즐겨찾기 상태 업데이트 로직 구현 예정
      // 현재 DiaryEntry 모델에 isFavorite 필드가 없음

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _diary!.isFavorite ? '즐겨찾기에서 제거되었습니다' : '즐겨찾기에 추가되었습니다',
          ),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('즐겨찾기 상태 변경 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 공유 기능
  void _shareDiary() {
    if (_diary != null) {
      DiaryShareDialog.show(context, _diary!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _watercolorBackground,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          title: '일기 상세',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            if (_diary != null) ...[
              // 즐겨찾기 버튼
              IconButton(
                icon: Icon(
                  _diary!.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _diary!.isFavorite ? Colors.red : null,
                ),
                onPressed: _toggleFavorite,
                tooltip: _diary!.isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
              ),

              // 편집 버튼
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editDiary,
                tooltip: '편집',
              ),

              // 공유 버튼
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareDiary,
                tooltip: '공유',
              ),

              // 삭제 버튼
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _confirmDeleteDiary,
                tooltip: '삭제',
              ),
            ],
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  /// 본문 빌드
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CustomLoading());
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_diary == null) {
      return _buildNotFoundWidget();
    }

    return Column(
      children: [
        // 탭 바
        _buildTabBar(),

        // 탭 내용
        Expanded(
          child: _selectedTabIndex == 0
              ? _buildDetailContent()
              : _buildHistoryContent(),
        ),
      ],
    );
  }

  /// 탭 바
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: TabController(
          length: 2,
          vsync: this,
          initialIndex: _selectedTabIndex,
        ),
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        tabs: const [
          Tab(icon: Icon(Icons.article, size: 20), text: '상세 내용'),
          Tab(icon: Icon(Icons.history, size: 20), text: '편집 히스토리'),
        ],
      ),
    );
  }

  /// 상세 내용 탭
  Widget _buildDetailContent() {
    return FadeTransition(
      opacity: _contentFadeAnimation,
      child: SlideTransition(
        position: _contentSlideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 정보
              _buildHeader(),
              const SizedBox(height: 24),

              // 제목
              if (_diary!.title != null && _diary!.title!.isNotEmpty)
                _buildTitle(),

              // 내용
              _buildContent(),

              // 첨부 파일
              if (_diary!.attachments.isNotEmpty) _buildAttachments(),

              // 태그
              if (_diary!.tags.isNotEmpty) _buildTags(),

              // 메타 정보
              _buildMetaInfo(),
            ],
          ),
        ),
      ),
    );
  }

  /// 히스토리 내용 탭
  Widget _buildHistoryContent() {
    return DiaryHistoryWidget(
      historyService: _historyService,
      diaryId: widget.diaryId,
    );
  }

  /// 헤더 정보 (날짜, 기분, 날씨)
  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 날짜
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(_diary!.date),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    _formatTime(_diary!.date),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // 기분
            if (_diary!.mood != null) ...[
              const SizedBox(width: 16),
              _buildMoodChip(_diary!.mood!),
            ],

            // 날씨
            if (_diary!.weather != null) ...[
              const SizedBox(width: 8),
              _buildWeatherChip(_diary!.weather!),
            ],
          ],
        ),
      ),
    );
  }

  /// 제목
  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        _diary!.title!,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  /// 내용
  Widget _buildContent() {
    // Delta JSON에서 텍스트 추출 (간단한 구현)
    final content = _extractTextFromDelta(_diary!.content);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
      ),
    );
  }

  /// 첨부 파일
  Widget _buildAttachments() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '첨부 파일',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // 향후 첨부 파일 표시 구현 예정
              Text(
                '첨부 파일 ${_diary!.attachments.length}개',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 태그
  Widget _buildTags() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '태그',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _diary!.tags
                    .map<Widget>(
                      (Tag tag) => Chip(
                        label: Text(tag.name),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 메타 정보
  Widget _buildMetaInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '정보',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildMetaItem(
                '단어 수',
                '${_calculateWordCount(_diary!.content)}자',
              ),
              _buildMetaItem('작성일', _formatDateTime(_diary!.createdAt)),
              if (_diary!.updatedAt != _diary!.createdAt)
                _buildMetaItem('수정일', _formatDateTime(_diary!.updatedAt)),
            ],
          ),
        ),
      ),
    );
  }

  /// 메타 정보 항목
  Widget _buildMetaItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  /// 기분 칩
  Widget _buildMoodChip(String mood) {
    final moodData = _getMoodData(mood);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (moodData['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (moodData['color'] as Color).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            moodData['icon'] as IconData,
            size: 18,
            color: moodData['color'] as Color,
          ),
          const SizedBox(width: 6),
          Text(
            mood,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: moodData['color'] as Color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 날씨 칩
  Widget _buildWeatherChip(String weather) {
    final weatherData = _getWeatherData(weather);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (weatherData['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (weatherData['color'] as Color).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            weatherData['icon'] as IconData,
            size: 18,
            color: weatherData['color'] as Color,
          ),
          const SizedBox(width: 6),
          Text(
            weather,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: weatherData['color'] as Color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 에러 위젯
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('일기를 불러올 수 없습니다', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadDiary, child: const Text('다시 시도')),
        ],
      ),
    );
  }

  /// 찾을 수 없음 위젯
  Widget _buildNotFoundWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('일기를 찾을 수 없습니다', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '요청하신 일기가 존재하지 않거나 삭제되었습니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('목록으로 돌아가기'),
          ),
        ],
      ),
    );
  }

  /// 날짜 포맷팅
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// 시간 포맷팅
  String _formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('HH:mm', 'ko_KR').format(date);
    } catch (e) {
      return '';
    }
  }

  /// 날짜시간 포맷팅
  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR').format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// 기분 데이터
  Map<String, dynamic> _getMoodData(String mood) {
    const moodMap = {
      '행복': {'icon': Icons.sentiment_very_satisfied, 'color': Colors.orange},
      '슬픔': {'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.blue},
      '화남': {'icon': Icons.sentiment_dissatisfied, 'color': Colors.red},
      '평온': {'icon': Icons.sentiment_neutral, 'color': Colors.green},
      '설렘': {'icon': Icons.sentiment_satisfied, 'color': Colors.pink},
      '걱정': {'icon': Icons.sentiment_dissatisfied, 'color': Colors.amber},
      '피곤': {'icon': Icons.sentiment_neutral, 'color': Colors.grey},
      '만족': {
        'icon': Icons.sentiment_very_satisfied,
        'color': Colors.lightGreen,
      },
      '실망': {'icon': Icons.sentiment_dissatisfied, 'color': Colors.deepOrange},
      '감사': {'icon': Icons.sentiment_very_satisfied, 'color': Colors.purple},
      '외로움': {'icon': Icons.sentiment_dissatisfied, 'color': Colors.indigo},
      '흥분': {'icon': Icons.sentiment_very_satisfied, 'color': Colors.redAccent},
      '우울': {
        'icon': Icons.sentiment_very_dissatisfied,
        'color': Colors.blueGrey,
      },
      '긴장': {
        'icon': Icons.sentiment_dissatisfied,
        'color': Colors.orangeAccent,
      },
      '편안': {'icon': Icons.sentiment_satisfied, 'color': Colors.lightBlue},
      '기타': {'icon': Icons.sentiment_neutral, 'color': Colors.grey},
    };

    return moodMap[mood] ??
        {'icon': Icons.sentiment_neutral, 'color': Colors.grey};
  }

  /// 날씨 데이터
  Map<String, dynamic> _getWeatherData(String weather) {
    const weatherMap = {
      '맑음': {'icon': Icons.wb_sunny, 'color': Colors.orange},
      '흐림': {'icon': Icons.wb_cloudy, 'color': Colors.grey},
      '비': {'icon': Icons.grain, 'color': Colors.blue},
      '눈': {'icon': Icons.ac_unit, 'color': Colors.lightBlue},
      '바람': {'icon': Icons.air, 'color': Colors.cyan},
      '안개': {'icon': Icons.blur_on, 'color': Colors.grey},
      '폭염': {'icon': Icons.wb_sunny, 'color': Colors.red},
      '한파': {'icon': Icons.ac_unit, 'color': Colors.blue},
      '기타': {'icon': Icons.wb_cloudy, 'color': Colors.grey},
    };

    return weatherMap[weather] ??
        {'icon': Icons.wb_cloudy, 'color': Colors.grey};
  }
}
