import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers/localization_provider.dart';

/// AI 생성 콘텐츠 신고 다이얼로그
/// Google Play AI 생성 콘텐츠 정책 준수를 위한 사용자 신고 기능
class AIContentReportDialog extends ConsumerStatefulWidget {
  final String? imageUrl;
  final String? prompt;
  final String? diaryId;

  const AIContentReportDialog({
    super.key,
    this.imageUrl,
    this.prompt,
    this.diaryId,
  });

  /// 다이얼로그 표시
  static Future<void> show(
    BuildContext context, {
    String? imageUrl,
    String? prompt,
    String? diaryId,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AIContentReportDialog(
        imageUrl: imageUrl,
        prompt: prompt,
        diaryId: diaryId,
      ),
    );
  }

  @override
  ConsumerState<AIContentReportDialog> createState() =>
      _AIContentReportDialogState();
}

class _AIContentReportDialogState extends ConsumerState<AIContentReportDialog> {
  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) return;

    setState(() => _isSubmitting = true);

    final l10n = ref.read(localizationProvider);

    try {
      // 이메일로 신고 전송
      final subject = Uri.encodeComponent(
        l10n.get('report_email_subject'),
      );

      final body = Uri.encodeComponent('''
${l10n.get('report_reason')}: ${_getLocalizedReason(_selectedReason!)}

${l10n.get('report_details')}: ${_detailsController.text.isNotEmpty ? _detailsController.text : l10n.get('report_no_details')}

${l10n.get('report_image_info')}:
- Diary ID: ${widget.diaryId ?? 'N/A'}
- Prompt: ${widget.prompt ?? 'N/A'}
- Image URL: ${widget.imageUrl ?? 'N/A'}
- Report Time: ${DateTime.now().toIso8601String()}
''');

      final emailUri = Uri.parse(
        'mailto:window98se@gmail.com?subject=$subject&body=$body',
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.get('report_submitted')),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // 이메일 앱이 없는 경우
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.get('report_email_error')),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.get('report_error')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getLocalizedReason(String reason) {
    final l10n = ref.read(localizationProvider);
    switch (reason) {
      case 'inappropriate':
        return l10n.get('report_reason_inappropriate');
      case 'offensive':
        return l10n.get('report_reason_offensive');
      case 'misleading':
        return l10n.get('report_reason_misleading');
      case 'copyright':
        return l10n.get('report_reason_copyright');
      case 'other':
        return l10n.get('report_reason_other');
      default:
        return reason;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(localizationProvider);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.flag_outlined,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.get('report_ai_content'),
              style: theme.textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.get('report_description'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.get('report_select_reason'),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildReasonOption('inappropriate', l10n.get('report_reason_inappropriate')),
            _buildReasonOption('offensive', l10n.get('report_reason_offensive')),
            _buildReasonOption('misleading', l10n.get('report_reason_misleading')),
            _buildReasonOption('copyright', l10n.get('report_reason_copyright')),
            _buildReasonOption('other', l10n.get('report_reason_other')),
            const SizedBox(height: 16),
            Text(
              l10n.get('report_additional_details'),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _detailsController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: l10n.get('report_details_hint'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.get('cancel')),
        ),
        ElevatedButton(
          onPressed: _isSubmitting || _selectedReason == null
              ? null
              : _submitReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.get('report_submit')),
        ),
      ],
    );
  }

  Widget _buildReasonOption(String value, String label) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedReason,
      onChanged: (v) => setState(() => _selectedReason = v),
      title: Text(label),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
