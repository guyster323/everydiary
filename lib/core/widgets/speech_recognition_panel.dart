import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            _buildInfoText(context, speechState),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoText(BuildContext context, SpeechRecognitionState state) {
    String infoText;
    Color infoColor;

    switch (state.status) {
      case SpeechRecognitionStatus.uninitialized:
        infoText = '음성 인식을 초기화하고 있습니다...';
        infoColor = Colors.orange;
        break;
      case SpeechRecognitionStatus.initialized:
        infoText = '마이크 버튼을 눌러 음성 인식을 시작하세요';
        infoColor = Colors.green;
        break;
      case SpeechRecognitionStatus.listening:
        infoText = '말씀해 주세요. 완료되면 다시 버튼을 눌러주세요';
        infoColor = Colors.blue;
        break;
      case SpeechRecognitionStatus.stopped:
        infoText = '음성을 텍스트로 변환하고 있습니다...';
        infoColor = Colors.purple;
        break;
      case SpeechRecognitionStatus.completed:
        infoText = '음성 인식이 완료되었습니다';
        infoColor = Colors.green;
        break;
      case SpeechRecognitionStatus.error:
      case SpeechRecognitionStatus.initializationFailed:
      case SpeechRecognitionStatus.permissionDenied:
      case SpeechRecognitionStatus.permissionPermanentlyDenied:
      case SpeechRecognitionStatus.startFailed:
      case SpeechRecognitionStatus.stopFailed:
      case SpeechRecognitionStatus.cancelFailed:
        infoText = '음성 인식 중 오류가 발생했습니다. 다시 시도해 주세요';
        infoColor = Colors.red;
        break;
      case SpeechRecognitionStatus.cancelled:
        infoText = '음성 인식이 취소되었습니다';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeOptions = ref.watch(speechLocaleOptionsProvider);
    final speechState = ref.watch(speechRecognitionProvider);
    final notifier = ref.watch(speechRecognitionProvider.notifier);

    final selectedCode = localeOptions.any(
      (option) => option.code == speechState.currentLocale,
    )
        ? speechState.currentLocale
        : localeOptions.first.code;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface
            .withValues(alpha: compact ? 0.3 : 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outline
              .withValues(alpha: 0.2),
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
                        child: Text(option.label),
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
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          const Text('음성 인식 오류'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(error),
          const SizedBox(height: 16),
          _buildErrorSuggestions(context),
        ],
      ),
      actions: [
        if (onCancel != null)
          TextButton(onPressed: onCancel, child: const Text('취소')),
        if (onRetry != null)
          ElevatedButton(onPressed: onRetry, child: const Text('다시 시도')),
      ],
    );
  }

  Widget _buildErrorSuggestions(BuildContext context) {
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
            '해결 방법:',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text('• 마이크 권한이 허용되었는지 확인하세요'),
          const Text('• 인터넷 연결을 확인하세요'),
          const Text('• 조용한 환경에서 다시 시도해 보세요'),
          const Text('• 마이크가 정상 작동하는지 확인하세요'),
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
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.mic, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('마이크 권한 필요'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('음성 인식 기능을 사용하려면 마이크 권한이 필요합니다.'),
          SizedBox(height: 16),
          Text('이 권한은 다음 목적으로만 사용됩니다:'),
          SizedBox(height: 8),
          Text('• 음성을 텍스트로 변환'),
          Text('• 일기 작성 시 음성 입력'),
          Text('• 음성 인식 정확도 향상'),
        ],
      ),
      actions: [
        if (onDeny != null)
          TextButton(onPressed: onDeny, child: const Text('거부')),
        if (onGrant != null)
          ElevatedButton(onPressed: onGrant, child: const Text('허용')),
      ],
    );
  }
}
