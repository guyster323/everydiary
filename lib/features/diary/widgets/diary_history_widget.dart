import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/diary_history_service.dart';

/// 일기 편집 히스토리 위젯
class DiaryHistoryWidget extends StatelessWidget {
  final DiaryHistoryService historyService;
  final int diaryId;

  const DiaryHistoryWidget({
    super.key,
    required this.historyService,
    required this.diaryId,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: historyService,
      builder: (context, child) {
        final history = historyService.getHistoryForDiary(diaryId);

        if (history.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '편집 히스토리 (${history.length}개)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 히스토리 목록
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];
                return _buildHistoryItem(context, entry);
              },
            ),
          ],
        );
      },
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '편집 히스토리가 없습니다',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '일기를 편집하면 히스토리가 기록됩니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 히스토리 항목 위젯
  Widget _buildHistoryItem(BuildContext context, DiaryHistoryEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (시간, 변경사항)
            Row(
              children: [
                Icon(
                  Icons.edit,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.changeDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  _formatTime(entry.editedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 제목 미리보기
            if (entry.title.isNotEmpty) ...[
              Text(
                entry.title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],

            // 내용 미리보기
            Text(
              _extractTextFromDelta(entry.content),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // 메타 정보
            Row(
              children: [
                if (entry.mood != null) ...[
                  _buildMetaChip(
                    context,
                    entry.mood!,
                    Icons.sentiment_satisfied,
                  ),
                  const SizedBox(width: 8),
                ],
                if (entry.weather != null) ...[
                  _buildMetaChip(context, entry.weather!, Icons.wb_sunny),
                  const SizedBox(width: 8),
                ],
                const Spacer(),
                Text(
                  _formatDate(entry.editedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 메타 정보 칩
  Widget _buildMetaChip(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// 시간 포맷팅
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('M월 d일', 'ko_KR').format(dateTime);
    }
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime dateTime) {
    return DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR').format(dateTime);
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
}
