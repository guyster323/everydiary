import 'package:flutter/material.dart';

import '../../../shared/models/diary_entry.dart';
import '../services/diary_share_service.dart';

/// 일기 공유 위젯
class DiaryShareWidget extends StatelessWidget {
  final DiaryEntry diary;
  final DiaryShareService shareService;

  const DiaryShareWidget({
    super.key,
    required this.diary,
    required this.shareService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.share, size: 20),
              const SizedBox(width: 8),
              Text(
                '일기 공유',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // 공유 옵션 목록
        ...shareService.getAvailableFormats().map(
          (format) => _buildShareOption(context, format),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  /// 공유 옵션 위젯
  Widget _buildShareOption(BuildContext context, ShareFormat format) {
    return ListTile(
      leading: _getFormatIcon(format),
      title: Text(shareService.getFormatName(format)),
      subtitle: Text(shareService.getFormatDescription(format)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _shareDiary(context, format),
    );
  }

  /// 형식별 아이콘
  Widget _getFormatIcon(ShareFormat format) {
    IconData icon;
    Color color;

    switch (format) {
      case ShareFormat.text:
        icon = Icons.text_fields;
        color = Colors.blue;
        break;
      case ShareFormat.markdown:
        icon = Icons.code;
        color = Colors.green;
        break;
      case ShareFormat.image:
        icon = Icons.image;
        color = Colors.orange;
        break;
      case ShareFormat.pdf:
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  /// 일기 공유 실행
  Future<void> _shareDiary(BuildContext context, ShareFormat format) async {
    try {
      // 로딩 표시
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await shareService.shareDiary(diary, format);

      // 로딩 닫기
      if (context.mounted) {
        Navigator.of(context).pop();

        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${shareService.getFormatName(format)} 형식으로 공유되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // 로딩 닫기
      if (context.mounted) {
        Navigator.of(context).pop();

        // 에러 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('공유 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// 일기 공유 다이얼로그
class DiaryShareDialog extends StatelessWidget {
  final DiaryEntry diary;

  const DiaryShareDialog({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: DiaryShareWidget(diary: diary, shareService: DiaryShareService()),
    );
  }

  /// 공유 다이얼로그 표시
  static Future<void> show(BuildContext context, DiaryEntry diary) {
    return showDialog(
      context: context,
      builder: (context) => DiaryShareDialog(diary: diary),
    );
  }
}
