import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/providers/localization_provider.dart';

/// AI 생성 콘텐츠 신고 다이얼로그
/// Google Play AI 생성 콘텐츠 정책 준수를 위한 사용자 신고 기능
class AIContentReportDialog extends ConsumerStatefulWidget {
  final String? imageUrl;
  final String? prompt;
  final String? diaryId;
  final String? localImagePath;

  const AIContentReportDialog({
    super.key,
    this.imageUrl,
    this.prompt,
    this.diaryId,
    this.localImagePath,
  });

  /// 다이얼로그 표시
  static Future<void> show(
    BuildContext context, {
    String? imageUrl,
    String? prompt,
    String? diaryId,
    String? localImagePath,
  }) {
    debugPrint('🚨 [AIContentReportDialog] show() called');
    debugPrint('   imageUrl: $imageUrl');
    debugPrint('   prompt: $prompt');
    debugPrint('   diaryId: $diaryId');
    debugPrint('   localImagePath: $localImagePath');

    return showDialog<void>(
      context: context,
      builder: (context) => AIContentReportDialog(
        imageUrl: imageUrl,
        prompt: prompt,
        diaryId: diaryId,
        localImagePath: localImagePath,
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
  bool _agreeToShareImage = false;

  /// 로컬 파일로 공유 가능한지 확인
  bool get _hasLocalImageFile {
    if (widget.localImagePath == null || widget.localImagePath!.isEmpty) {
      return false;
    }
    try {
      final file = File(widget.localImagePath!);
      final exists = file.existsSync();
      debugPrint('🔍 [AIContentReportDialog] Local file check: ${widget.localImagePath} exists=$exists');
      return exists;
    } catch (e) {
      debugPrint('❌ [AIContentReportDialog] File check error: $e');
      return false;
    }
  }

  /// 이미지 정보가 있는지 확인 (로컬 파일 또는 URL)
  bool get _hasImageInfo =>
      _hasLocalImageFile ||
      (widget.imageUrl != null && widget.imageUrl!.isNotEmpty);

  /// 프롬프트 정보가 있는지 확인
  bool get _hasPromptInfo =>
      widget.prompt != null && widget.prompt!.isNotEmpty;

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
      // 프롬프트 정보 구성
      final promptInfo = _hasPromptInfo
          ? widget.prompt!
          : l10n.get('report_no_details');

      // 이미지 경로 정보 구성
      final imagePathInfo = _hasLocalImageFile
          ? widget.localImagePath!
          : (widget.imageUrl ?? 'N/A');

      final reportText = '''
${l10n.get('report_email_subject')}

${l10n.get('report_reason')}: ${_getLocalizedReason(_selectedReason!)}

${l10n.get('report_details')}: ${_detailsController.text.isNotEmpty ? _detailsController.text : l10n.get('report_no_details')}

${l10n.get('report_image_info')}:
- Diary ID: ${widget.diaryId ?? 'N/A'}
- Prompt: $promptInfo
- Image Path: $imagePathInfo
- Report Time: ${DateTime.now().toIso8601String()}

---
${l10n.get('report_send_to')}: window98se@gmail.com
''';

      debugPrint('📧 [AIContentReportDialog] Submitting report...');
      debugPrint('   _agreeToShareImage: $_agreeToShareImage');
      debugPrint('   _hasLocalImageFile: $_hasLocalImageFile');

      // 이미지 첨부 동의 시 share_plus로 이미지와 함께 공유
      if (_agreeToShareImage && _hasLocalImageFile) {
        debugPrint('📎 [AIContentReportDialog] Sharing with image file: ${widget.localImagePath}');
        final result = await Share.shareXFiles(
          [XFile(widget.localImagePath!)],
          text: reportText,
          subject: l10n.get('report_email_subject'),
        );

        debugPrint('📤 [AIContentReportDialog] Share result: ${result.status}');

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
        // 이미지 없이 텍스트만 공유
        debugPrint('📝 [AIContentReportDialog] Sharing text only');
        await Share.share(
          reportText,
          subject: l10n.get('report_email_subject'),
        );

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.get('report_submitted')),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [AIContentReportDialog] Error: $e');
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
            // 🔴 신고 대상 이미지와 동의 체크박스를 제일 위에 배치
            if (_hasImageInfo) ...[
              // 이미지 썸네일과 동의 체크를 가로로 배치
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 작은 썸네일 이미지 (60x60)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: _hasLocalImageFile
                          ? Image.file(
                              File(widget.localImagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildSmallImagePlaceholder(theme);
                              },
                            )
                          : (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                              ? Image.network(
                                  widget.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildSmallImagePlaceholder(theme);
                                  },
                                )
                              : _buildSmallImagePlaceholder(theme),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 동의 체크박스
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.get('report_image_preview'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_hasLocalImageFile)
                          CheckboxListTile(
                            value: _agreeToShareImage,
                            onChanged: (value) {
                              setState(() => _agreeToShareImage = value ?? false);
                            },
                            title: Text(
                              l10n.get('report_agree_share_image'),
                              style: theme.textTheme.bodySmall,
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
            ],

            // 프롬프트 정보 표시
            if (_hasPromptInfo) ...[
              Text(
                l10n.get('report_prompt_label'),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.prompt!,
                  style: theme.textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
            ],

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
              maxLines: 2,
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
    // ignore: deprecated_member_use
    return RadioListTile<String>(
      value: value,
      // ignore: deprecated_member_use
      groupValue: _selectedReason,
      // ignore: deprecated_member_use
      onChanged: (v) => setState(() => _selectedReason = v),
      title: Text(label),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildSmallImagePlaceholder(ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_outlined,
        size: 24,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
