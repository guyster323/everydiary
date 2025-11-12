import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/localization_provider.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../shared/models/attachment.dart';
import '../../../shared/models/diary_entry.dart';

/// 일기 카드 위젯
class DiaryCard extends ConsumerWidget {
  final DiaryEntry diary;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;
  final bool showActions;

  const DiaryCard({
    super.key,
    required this.diary,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleFavorite,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (날짜, 기분, 날씨)
            _buildHeader(context, ref),
            const SizedBox(height: 12),

            // 제목
            if (diary.title != null && diary.title!.isNotEmpty)
              _buildTitle(context),

            // 내용 미리보기
            _buildContentPreview(context),
            const SizedBox(height: 12),

            // 태그 및 메타 정보
            _buildFooter(context),

            // 액션 버튼들
            if (showActions) ...[
              const SizedBox(height: 12),
              _buildActions(context),
            ],
          ],
        ),
      ),
    );
  }

  /// 헤더 (날짜, 기분, 날씨)
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // 날짜
        Expanded(
          child: Text(
            _formatDate(context, ref, diary.date),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),

        // 기분 아이콘
        if (diary.mood != null) ...[
          const SizedBox(width: 8),
          _buildMoodChip(context, diary.mood!),
        ],

        // 날씨 아이콘
        if (diary.weather != null) ...[
          const SizedBox(width: 8),
          _buildWeatherChip(context, diary.weather!),
        ],
      ],
    );
  }

  /// 제목
  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (diary.attachments.isNotEmpty)
            _buildThumbnail(context, diary.attachments.first),
          if (diary.attachments.isNotEmpty) const SizedBox(width: 12),
          Expanded(
            child: Text(
              diary.title!,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, Attachment attachment) {
    final filePath = attachment.thumbnailPath ?? attachment.filePath;
    final file = File(filePath);
    final imageProvider = FileImage(file);
    PaintingBinding.instance.imageCache.evict(imageProvider);
    int? modifiedTimestamp;
    try {
      modifiedTimestamp = file.statSync().modified.millisecondsSinceEpoch;
    } catch (_) {
      modifiedTimestamp = null;
    }
    final cacheKey =
        '${attachment.id ?? attachment.filePath}_'
        '${attachment.updatedAt}_'
        '${modifiedTimestamp ?? ''}';
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image(
        key: ValueKey(cacheKey),
        image: imageProvider,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.image_not_supported,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }

  /// 내용 미리보기
  Widget _buildContentPreview(BuildContext context) {
    // Delta JSON에서 텍스트 추출 (간단한 구현)
    final content = _extractTextFromDelta(diary.content);

    return Text(
      content,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 푸터 (태그, 메타 정보)
  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        // 단어 수
        if (diary.wordCount > 0) ...[
          Icon(
            Icons.text_fields,
            size: 16,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Text(
            '${diary.wordCount}자',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 16),
        ],

        const Spacer(),

        // 즐겨찾기 아이콘
        if (diary.isFavorite)
          const Icon(Icons.favorite, size: 16, color: Colors.red),
      ],
    );
  }

  /// 액션 버튼들
  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 즐겨찾기 토글
        IconButton(
          icon: Icon(
            diary.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: diary.isFavorite ? Colors.red : null,
          ),
          onPressed: onToggleFavorite,
          tooltip: diary.isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
        ),

        // 편집
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit,
          tooltip: '편집',
        ),

        // 삭제
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
          tooltip: '삭제',
        ),
      ],
    );
  }

  /// 기분 칩
  Widget _buildMoodChip(BuildContext context, String mood) {
    final moodData = _getMoodData(mood);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (moodData['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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
            size: 16,
            color: moodData['color'] as Color,
          ),
          const SizedBox(width: 4),
          Text(
            mood,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: moodData['color'] as Color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 날씨 칩
  Widget _buildWeatherChip(BuildContext context, String weather) {
    final weatherData = _getWeatherData(weather);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (weatherData['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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
            size: 16,
            color: weatherData['color'] as Color,
          ),
          const SizedBox(width: 4),
          Text(
            weather,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: weatherData['color'] as Color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 날짜 포맷팅
  String _formatDate(BuildContext context, WidgetRef ref, String dateString) {
    try {
      final l10n = ref.read(localizationProvider);
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final diaryDate = DateTime(date.year, date.month, date.day);

      if (diaryDate == today) {
        return l10n.get('date_today');
      } else if (diaryDate == yesterday) {
        return l10n.get('date_yesterday');
      } else {
        // Get current locale from context
        final locale = Localizations.localeOf(context);
        return DateFormat('M월 d일 (E)', locale.toString()).format(date);
      }
    } catch (e) {
      return dateString;
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
