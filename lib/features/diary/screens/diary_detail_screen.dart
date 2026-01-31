import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/providers/localization_provider.dart';
import '../../../core/services/image_generation_service.dart';
import '../../../features/settings/providers/settings_provider.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_loading.dart';
import '../../../shared/models/attachment.dart';
import '../../../shared/models/diary_entry.dart';
import '../../../shared/models/tag.dart';
import '../../../shared/services/database_service.dart';
import '../../../shared/services/repositories/diary_repository.dart';
import '../services/diary_history_service.dart';
import '../services/diary_list_service.dart';
import '../services/emotion_analysis_service.dart';
import '../widgets/ai_content_report_dialog.dart';
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
  late ImageGenerationService _imageGenerationService;
  StreamSubscription<void>? _refreshSubscription;

  // AI 생성 이미지 관련
  bool _isGeneratingImage = false;
  ImageGenerationResult? _generatedImage;
  String? _imageError;

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
    _imageGenerationService = ImageGenerationService();

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

  /// AI 생성 이미지 로드
  Future<void> _loadGeneratedImage() async {
    if (_diary == null || _diary!.content.isEmpty) {
      setState(() {
        _generatedImage = null;
        _imageError = null;
      });
      return;
    }

    if (_diary!.attachments.isNotEmpty) {
      setState(() {
        _generatedImage = null;
        _imageError = null;
      });
      return;
    }

    try {
      final text = _extractTextFromDelta(_diary!.content);

      if (text.isEmpty) {
        setState(() {
          _generatedImage = null;
          _imageError = null;
        });
        return;
      }

      setState(() {
        _isGeneratingImage = true;
        _imageError = null;
      });

      await _imageGenerationService.initialize();

      ImageGenerationHints? hints;
      if (_diary != null) {
        DateTime? diaryDate;
        try {
          diaryDate = DateTime.tryParse(_diary!.date);
        } catch (_) {
          diaryDate = null;
        }

        DateTime? createdAt;
        try {
          createdAt = DateTime.tryParse(_diary!.createdAt);
        } catch (_) {
          createdAt = null;
        }

        hints = ImageGenerationHints(
          title: _diary!.title,
          mood: _diary!.mood,
          weather: _diary!.weather,
          location: _diary!.location,
          date: diaryDate ?? createdAt,
          timeOfDay: createdAt != null ? _timeOfDayLabel(createdAt) : null,
          tags: _diary!.tags
              .map((tag) => tag.name.trim())
              .where((name) => name.isNotEmpty)
              .toList(),
        );
      }

      final cachedImage = _imageGenerationService.getCachedResult(
        text,
        hints: hints,
      );

      if (cachedImage != null) {
        setState(() {
          _generatedImage = cachedImage;
          _isGeneratingImage = false;
        });
        debugPrint('✅ 캐시된 AI 생성 이미지 로드 완료');
        return;
      }

      final generatedImage = await _imageGenerationService
          .generateImageFromText(text, hints: hints);

      if (generatedImage != null) {
        setState(() {
          _generatedImage = generatedImage;
          _isGeneratingImage = false;
        });
        debugPrint('✅ AI 이미지 생성 완료 및 로드');
      } else {
        final l10n = ref.read(localizationProvider);
        setState(() {
          _generatedImage = null;
          _isGeneratingImage = false;
          _imageError = l10n.get('image_generation_failed');
        });
        debugPrint('❌ AI 생성 이미지 생성 실패');
      }
    } catch (e) {
      final l10n = ref.read(localizationProvider);
      debugPrint('❌ AI 생성 이미지 로드 실패: $e');
      setState(() {
        _generatedImage = null;
        _isGeneratingImage = false;
        _imageError = l10n.get('image_load_error');
      });
    }
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

  String? _timeOfDayLabel(DateTime dateTime) {
    final l10n = ref.read(localizationProvider);
    final hour = dateTime.hour;
    if (hour >= 5 && hour < 11) {
      return l10n.get('time_morning');
    }
    if (hour >= 11 && hour < 15) {
      return l10n.get('time_day');
    }
    if (hour >= 15 && hour < 19) {
      return l10n.get('time_evening');
    }
    return l10n.get('time_night');
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

        // AI 생성 이미지 확인
        await _loadGeneratedImage();

        // 애니메이션 시작
        _contentAnimationController.forward();

        // 히스토리 로드
        await _historyService.loadHistory(widget.diaryId);
      } else {
        final l10n = ref.read(localizationProvider);
        setState(() {
          _error = l10n.get('diary_not_found');
          _isLoading = false;
        });
      }
    } catch (e) {
      final l10n = ref.read(localizationProvider);
      setState(() {
        _error = '${l10n.get('diary_load_error')}: $e';
        _isLoading = false;
      });
    }
  }

  /// AI 생성 이미지를 갤러리에 저장
  Future<void> _saveImageToGallery() async {
    if (_generatedImage == null) return;

    final l10n = ref.read(localizationProvider);

    try {
      // 저장 확인 다이얼로그 표시
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.get('image_save_title')),
          content: Text(l10n.get('image_save_message')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.get('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.get('save')),
            ),
          ],
        ),
      );

      if (confirm != true || !mounted) return;

      String? imagePath;

      // 로컬 이미지 경로가 있으면 직접 사용
      if (_generatedImage!.localImagePath != null) {
        imagePath = _generatedImage!.localImagePath;
      } else {
        // 네트워크에서 이미지 다운로드
        final response = await http.get(Uri.parse(_generatedImage!.imageUrl));
        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final fileName = 'diary_ai_image_${DateTime.now().millisecondsSinceEpoch}.png';
          final file = File('${tempDir.path}/$fileName');
          await file.writeAsBytes(response.bodyBytes);
          imagePath = file.path;
        }
      }

      if (imagePath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.get('image_save_failed')),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // 갤러리에 저장
      await Gal.putImage(imagePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.get('image_save_success')),
            backgroundColor: Colors.green,
          ),
        );
      }

      debugPrint('✅ AI 생성 이미지가 갤러리에 저장되었습니다: $imagePath');
    } catch (e) {
      debugPrint('❌ 이미지 저장 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.get('image_save_error')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

    final l10n = ref.read(localizationProvider);

    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('delete_title')),
        content: Text(l10n.get('delete_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.get('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteDiary();
            },
            child: Text(l10n.get('delete_button'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 일기 삭제
  Future<void> _deleteDiary() async {
    if (_diary == null) return;

    final l10n = ref.read(localizationProvider);

    try {
      final success = await _diaryRepository.deleteDiaryEntry(_diary!.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.get('diary_deleted')),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.get('diary_delete_failed')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.get('diary_delete_error')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 즐겨찾기 토글
  Future<void> _toggleFavorite() async {
    if (_diary == null) return;

    final l10n = ref.read(localizationProvider);

    try {
      // 향후 즐겨찾기 상태 업데이트 로직 구현 예정
      // 현재 DiaryEntry 모델에 isFavorite 필드가 없음

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _diary!.isFavorite ? l10n.get('favorite_removed') : l10n.get('favorite_added'),
          ),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.get('favorite_error')}: $e'),
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
    final l10n = ref.watch(localizationProvider);

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
          title: l10n.get('diary_detail_title'),
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
                tooltip: _diary!.isFavorite ? l10n.get('tooltip_favorite_remove') : l10n.get('tooltip_favorite_add'),
              ),

              // 편집 버튼
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editDiary,
                tooltip: l10n.get('tooltip_edit'),
              ),

              // 공유 버튼
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareDiary,
                tooltip: l10n.get('tooltip_share'),
              ),

              // 삭제 버튼
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _confirmDeleteDiary,
                tooltip: l10n.get('tooltip_delete'),
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
    final l10n = ref.read(localizationProvider);

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
        tabs: [
          Tab(icon: const Icon(Icons.article, size: 20), text: l10n.get('tab_detail')),
          Tab(icon: const Icon(Icons.history, size: 20), text: l10n.get('tab_history')),
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

              // 첨부 파일 (AI 생성 이미지 포함)
              if (_diary!.attachments.isNotEmpty)
                _buildSavedAssociationImages(),

              // AI 생성 이미지 (저장된 이미지가 없을 때 백그라운드 생성)
              if (_diary!.attachments.isEmpty)
                Builder(
                  builder: (context) {
                    if (_isGeneratingImage) {
                      return _buildAssociationImageLoading();
                    }
                    if (_generatedImage != null) {
                      return _buildAssociationImage();
                    }
                    if (_imageError != null) {
                      return _buildAssociationImageError();
                    }
                    return const SizedBox.shrink();
                  },
                ),

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
              child: Text(
                _formatDate(_diary!.date),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
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

  /// 일기 연상 이미지 (AI 생성 이미지)
  Widget _buildAssociationImage() {
    if (_generatedImage == null) return const SizedBox.shrink();

    final l10n = ref.read(localizationProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 및 신고 버튼
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.get('association_image_title'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // AI 콘텐츠 신고 버튼 (빨간색)
                  IconButton(
                    icon: Icon(
                      Icons.flag,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => _showReportDialog(),
                    tooltip: l10n.get('report_ai_content'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // AI 생성 이미지 (long press로 저장)
              GestureDetector(
                onLongPress: _saveImageToGallery,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _generatedImage!.localImagePath != null
                      ? Image.file(
                          File(_generatedImage!.localImagePath!),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildAssociationImageNetworkFallback();
                          },
                        )
                      : _buildAssociationImageNetworkFallback(),
                ),
              ),
              const SizedBox(height: 8),

              // 힌트 텍스트
              Text(
                l10n.get('image_save_hint'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // 이미지 정보
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.get('generation_prompt'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _generatedImage!.prompt,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildImageInfoChip(l10n.get('emotion_label'), _generatedImage!.emotion),
                        const SizedBox(width: 8),
                        _buildImageInfoChip(l10n.get('style_label'), _generatedImage!.style),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildImageInfoChip(l10n.get('topic_label'), _generatedImage!.topic),
                        const Spacer(),
                        Text(
                          '${l10n.get('generated_date')}: ${_formatDateTime(_generatedImage!.generatedAt.toIso8601String())}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssociationImageLoading() {
    final l10n = ref.read(localizationProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.get('association_image_generating'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.get('association_image_generating_message'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssociationImageError() {
    final l10n = ref.read(localizationProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.get('association_image_error'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _imageError ?? l10n.get('memory_unknown_error'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  children: [
                    const TextSpan(
                      text: 'Gemini 또는 Hugging Face API 키를 설정하거나 ',
                    ),
                    TextSpan(
                      text: l10n.get('retry'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _loadGeneratedImage(),
                    ),
                    const TextSpan(text: ' 해보세요.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 이미지 정보 칩
  Widget _buildImageInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 태그
  Widget _buildTags() {
    final l10n = ref.read(localizationProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.get('tags_title'),
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
    final l10n = ref.read(localizationProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.get('info_title'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildMetaItem(
                l10n.get('word_count'),
                '${_calculateWordCount(_diary!.content)}',
              ),
              _buildMetaItem(l10n.get('created_date'), _formatDateTime(_diary!.createdAt)),
              if (_diary!.updatedAt != _diary!.createdAt)
                _buildMetaItem(l10n.get('modified_date'), _formatDateTime(_diary!.updatedAt)),
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
    final localizedMood = _getLocalizedMood(mood);

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
            localizedMood,
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
    final localizedWeather = _getLocalizedWeather(weather);

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
            localizedWeather,
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
    final l10n = ref.read(localizationProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(l10n.get('load_error'), style: Theme.of(context).textTheme.titleLarge),
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
          ElevatedButton(onPressed: _loadDiary, child: Text(l10n.get('retry_button'))),
        ],
      ),
    );
  }

  /// 찾을 수 없음 위젯
  Widget _buildNotFoundWidget() {
    final l10n = ref.read(localizationProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l10n.get('diary_not_found'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            l10n.get('diary_not_found_message'),
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
            child: Text(l10n.get('back_to_list')),
          ),
        ],
      ),
    );
  }

  /// 날짜 포맷팅 (locale-aware)
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final settings = ref.read(settingsProvider);
      final locale = getLocaleFromLanguage(settings.language);
      return DateFormat.yMMMEd(locale.toString()).format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// 날짜시간 포맷팅 (locale-aware)
  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final settings = ref.read(settingsProvider);
      final locale = getLocaleFromLanguage(settings.language);
      return DateFormat.yMMMd(locale.toString()).add_Hm().format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// 기분 이름 로컬라이즈
  String _getLocalizedMood(String mood) {
    final l10n = ref.read(localizationProvider);
    const moodKeyMap = {
      '행복': 'mood_happy',
      '슬픔': 'mood_sad',
      '화남': 'mood_angry',
      '평온': 'mood_calm',
      '설렘': 'mood_excited',
      '걱정': 'mood_worried',
      '피곤': 'mood_tired',
      '만족': 'mood_satisfied',
      '실망': 'mood_disappointed',
      '감사': 'mood_grateful',
      '외로움': 'mood_lonely',
      '흥분': 'mood_thrilled',
      '우울': 'mood_depressed',
      '긴장': 'mood_nervous',
      '편안': 'mood_comfortable',
      '기타': 'mood_other',
    };
    final key = moodKeyMap[mood];
    return key != null ? l10n.get(key) : mood;
  }

  /// 날씨 이름 로컬라이즈
  String _getLocalizedWeather(String weather) {
    final l10n = ref.read(localizationProvider);
    const weatherKeyMap = {
      '맑음': 'weather_sunny',
      '흐림': 'weather_cloudy',
      '비': 'weather_rainy',
      '눈': 'weather_snowy',
      '바람': 'weather_windy',
      '안개': 'weather_foggy',
      '폭염': 'weather_hot',
      '한파': 'weather_cold',
      '기타': 'weather_other',
    };
    final key = weatherKeyMap[weather];
    return key != null ? l10n.get(key) : weather;
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

  Widget _buildAssociationImageNetworkFallback() {
    final l10n = ref.read(localizationProvider);

    return Image.network(
      _generatedImage!.imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 48,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.get('association_image_load_error'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedAssociationImages() {
    final l10n = ref.read(localizationProvider);
    final imageAttachments = _diary!.attachments
        .where((attachment) => attachment.fileType == FileType.image.value)
        .toList();

    if (imageAttachments.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.get('association_image_title'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // AI 콘텐츠 신고 버튼 (빨간색)
                  IconButton(
                    icon: Icon(
                      Icons.flag,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => _showReportDialogForSavedImage(),
                    tooltip: l10n.get('report_ai_content'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...imageAttachments.asMap().entries.map((entry) {
                final index = entry.key;
                final attachment = entry.value;
                final filePath = attachment.filePath;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == imageAttachments.length - 1 ? 0 : 12,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(filePath),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        final l10n = ref.read(localizationProvider);
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.get('association_image_load_error'),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// AI 콘텐츠 신고 다이얼로그 표시
  void _showReportDialog() {
    debugPrint('🚨 [DiaryDetailScreen] _showReportDialog called');
    debugPrint('   _generatedImage: ${_generatedImage != null ? "exists" : "null"}');
    if (_generatedImage != null) {
      debugPrint('   imageUrl: ${_generatedImage!.imageUrl}');
      debugPrint('   prompt: ${_generatedImage!.prompt}');
      debugPrint('   localImagePath: ${_generatedImage!.localImagePath}');
    }

    AIContentReportDialog.show(
      context,
      imageUrl: _generatedImage?.imageUrl,
      prompt: _generatedImage?.prompt,
      diaryId: widget.diaryId.toString(),
      localImagePath: _generatedImage?.localImagePath,
    );
  }

  /// 저장된 AI 이미지에 대한 신고 다이얼로그 표시
  void _showReportDialogForSavedImage() {
    // 첫 번째 이미지 첨부파일의 경로 가져오기
    String? imagePath;
    String? prompt;

    if (_diary != null && _diary!.attachments.isNotEmpty) {
      final imageAttachment = _diary!.attachments.firstWhere(
        (a) => a.fileType == FileType.image.value,
        orElse: () => _diary!.attachments.first,
      );
      imagePath = imageAttachment.filePath;

      // 생성 이력에서 프롬프트 찾기
      if (imagePath.contains('generated_images')) {
        final history = _imageGenerationService.getGenerationHistory();
        for (final entry in history.reversed) {
          final result = entry['result'] as Map<String, dynamic>?;
          if (result != null) {
            final localPath = result['local_image_path'] as String?;
            if (localPath == imagePath) {
              prompt = result['prompt'] as String?;
              debugPrint('🔍 [DiaryDetailScreen] Found prompt from history: $prompt');
              break;
            }
          }
        }

        // 히스토리에서 못 찾으면 캐시에서 일기 내용 기반으로 검색
        if (prompt == null) {
          final diaryText = _extractTextFromDelta(_diary!.content);
          final cachedResult = _imageGenerationService.getCachedResult(diaryText);
          if (cachedResult != null) {
            prompt = cachedResult.prompt;
            debugPrint('🔍 [DiaryDetailScreen] Found prompt from cache: $prompt');
          }
        }
      }
    }

    debugPrint('🚨 [DiaryDetailScreen] _showReportDialogForSavedImage called');
    debugPrint('   imagePath: $imagePath');
    debugPrint('   prompt: $prompt');

    AIContentReportDialog.show(
      context,
      diaryId: widget.diaryId.toString(),
      localImagePath: imagePath,
      prompt: prompt,
    );
  }
}
