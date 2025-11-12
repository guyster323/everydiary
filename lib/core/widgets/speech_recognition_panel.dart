import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/localization_provider.dart';
import '../providers/speech_recognition_provider.dart';
import '../services/speech_recognition_service.dart';
import 'offline_speech_widgets.dart';
import 'speech_recognition_widgets.dart';

/// 음성 인식 패널 위젯
/// 음성 인식 관련 모든 UI 요소를 통합하여 제공합니다.
class SpeechRecognitionPanel extends ConsumerWidget {
  const SpeechRecognitionPanel({
    super.key,
    this.onResult,
    this.onError,
    this.showWaveform = true,
    this.showTimer = true,
    this.showStatus = true,
    this.compact = false,
  });

  final void Function(String)? onResult;
  final void Function(String)? onError;
  final bool showWaveform;
  final bool showTimer;
  final bool showStatus;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechState = ref.watch(speechRecognitionProvider);
    final isListening = speechState.status == SpeechRecognitionStatus.listening;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 오프라인 모드 상태 표시
          if (showStatus && !compact) ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SpeechRecognitionStatusWidget(),
                OfflineSpeechStatusWidget(),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // 메인 컨트롤 영역
          Row(
            children: [
              Expanded(child: _SpeechLocaleSelector(compact: compact)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (showTimer) ...[
                const SpeechRecognitionTimerWidget(),
                const SizedBox(width: 16),
              ],
              SpeechRecognitionButton(
                onResult: onResult,
                onError: onError,
                size: compact ? 60.0 : 80.0,
              ),
              if (showWaveform && isListening) ...[
                const SizedBox(width: 16),
                const SpeechWaveformWidget(height: 40, barCount: 3),
              ],
            ],
          ),

          // 컴팩트 모드가 아닐 때 추가 정보 표시
          if (!compact) ...[
            const SizedBox(height: 16),
            _buildInfoText(context, speechState, ref),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoText(BuildContext context, SpeechRecognitionState state, WidgetRef ref) {
    final l10n = ref.read(localizationProvider);
    String infoText;
    Color infoColor;

    switch (state.status) {
      case SpeechRecognitionStatus.uninitialized:
        infoText = l10n.get('speech_initializing');
        infoColor = Colors.orange;
        break;
      case SpeechRecognitionStatus.initialized:
        infoText = l10n.get('speech_ready');
        infoColor = Colors.green;
        break;
      case SpeechRecognitionStatus.listening:
        infoText = l10n.get('speech_listening');
        infoColor = Colors.blue;
        break;
      case SpeechRecognitionStatus.stopped:
        infoText = l10n.get('speech_processing');
        infoColor = Colors.purple;
        break;
      case SpeechRecognitionStatus.completed:
        infoText = l10n.get('speech_completed');
        infoColor = Colors.green;
        break;
      case SpeechRecognitionStatus.error:
      case SpeechRecognitionStatus.initializationFailed:
      case SpeechRecognitionStatus.permissionDenied:
      case SpeechRecognitionStatus.permissionPermanentlyDenied:
      case SpeechRecognitionStatus.startFailed:
      case SpeechRecognitionStatus.stopFailed:
      case SpeechRecognitionStatus.cancelFailed:
        infoText = l10n.get('speech_error');
        infoColor = Colors.red;
        break;
      case SpeechRecognitionStatus.cancelled:
        infoText = l10n.get('speech_cancelled');
        infoColor = Colors.grey;
        break;
    }

    return Text(
      infoText,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: infoColor,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _SpeechLocaleSelector extends ConsumerWidget {
  const _SpeechLocaleSelector({required this.compact});

  final bool compact;

  String _getLocalizedLanguageLabel(SpeechLocaleOption option, WidgetRef ref) {
    final l10n = ref.read(localizationProvider);
    switch (option.code) {
      case 'ko-KR':
        return l10n.get('speech_language_korean');
      case 'en-US':
        return l10n.get('speech_language_english');
      case 'ja-JP':
        return l10n.get('speech_language_japanese');
      case 'zh-CN':
        return l10n.get('speech_language_chinese');
      default:
        return option.label;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeOptions = ref.watch(speechLocaleOptionsProvider);
    final speechState = ref.watch(speechRecognitionProvider);
    final notifier = ref.watch(speechRecognitionProvider.notifier);

    final selectedCode =
        localeOptions.any((option) => option.code == speechState.currentLocale)
        ? speechState.currentLocale
        : localeOptions.first.code;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: compact ? 0.3 : 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.language,
            size: compact ? 16 : 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCode,
                dropdownColor: Theme.of(context).colorScheme.surfaceBright,
                isExpanded: true,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                items: localeOptions
                    .map(
                      (option) => DropdownMenuItem<String>(
                        value: option.code,
                        child: Text(_getLocalizedLanguageLabel(option, ref)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null || value == speechState.currentLocale) {
                    return;
                  }
                  final selectedOption = localeOptions.firstWhere(
                    (option) => option.code == value,
                    orElse: () => localeOptions.first,
                  );
                  notifier.setLocaleOption(selectedOption);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 음성 인식 결과 전용 패널
class SpeechRecognitionResultPanel extends ConsumerWidget {
  const SpeechRecognitionResultPanel({
    super.key,
    this.onTextUpdate,
    this.maxHeight = 200,
  });

  final void Function(String)? onTextUpdate;
  final double maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechState = ref.watch(speechRecognitionProvider);

    // 음성 인식이 활성화되지 않았거나 결과가 없으면 숨김
    if (speechState.status == SpeechRecognitionStatus.initialized ||
        speechState.status == SpeechRecognitionStatus.uninitialized) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SpeechRecognitionTextWidget(onTextUpdate: onTextUpdate),
    );
  }
}

/// 음성 인식 에러 다이얼로그
class SpeechRecognitionErrorDialog extends StatelessWidget {
  const SpeechRecognitionErrorDialog({
    super.key,
    required this.error,
    this.onRetry,
    this.onCancel,
  });

  final String error;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    // Consumer를 사용하여 localization 접근
    return Consumer(
      builder: (context, ref, child) {
        final l10n = ref.read(localizationProvider);
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              Text(l10n.get('speech_error_title')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(error),
              const SizedBox(height: 16),
              _buildErrorSuggestions(context, l10n),
            ],
          ),
          actions: [
            if (onCancel != null)
              TextButton(onPressed: onCancel, child: Text(l10n.get('speech_cancel'))),
            if (onRetry != null)
              ElevatedButton(onPressed: onRetry, child: Text(l10n.get('speech_retry'))),
          ],
        );
      },
    );
  }

  Widget _buildErrorSuggestions(BuildContext context, dynamic l10n) {
    return Container(
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
            '${l10n.get('speech_error_solutions')}',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('${l10n.get('speech_error_check_permission')}'),
          Text('${l10n.get('speech_error_check_internet')}'),
          Text('${l10n.get('speech_error_quiet_environment')}'),
          Text('${l10n.get('speech_error_check_microphone')}'),
        ],
      ),
    );
  }
}

/// 음성 인식 권한 요청 다이얼로그
class SpeechRecognitionPermissionDialog extends StatelessWidget {
  const SpeechRecognitionPermissionDialog({
    super.key,
    this.onGrant,
    this.onDeny,
  });

  final VoidCallback? onGrant;
  final VoidCallback? onDeny;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final l10n = ref.read(localizationProvider);
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.mic, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(l10n.get('speech_permission_title')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.get('speech_permission_description')),
              const SizedBox(height: 16),
              Text(l10n.get('speech_permission_usage')),
              const SizedBox(height: 8),
              Text(l10n.get('speech_permission_convert')),
              Text(l10n.get('speech_permission_diary')),
              Text(l10n.get('speech_permission_accuracy')),
            ],
          ),
          actions: [
            if (onDeny != null)
              TextButton(onPressed: onDeny, child: Text(l10n.get('speech_permission_deny'))),
            if (onGrant != null)
              ElevatedButton(onPressed: onGrant, child: Text(l10n.get('speech_permission_allow'))),
          ],
        );
      },
    );
  }
}
