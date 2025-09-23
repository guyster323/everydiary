import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/speech_recognition_provider.dart';
import '../services/speech_recognition_service.dart';

/// 음성 인식 마이크 버튼 위젯
class SpeechRecognitionButton extends ConsumerStatefulWidget {
  const SpeechRecognitionButton({
    super.key,
    this.onResult,
    this.onError,
    this.size = 80.0,
    this.color,
    this.disabledColor,
  });

  final void Function(String)? onResult;
  final void Function(String)? onError;
  final double size;
  final Color? color;
  final Color? disabledColor;

  @override
  ConsumerState<SpeechRecognitionButton> createState() =>
      _SpeechRecognitionButtonState();
}

class _SpeechRecognitionButtonState
    extends ConsumerState<SpeechRecognitionButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  StreamSubscription<SpeechRecognitionResultWrapper>? _resultSubscription;
  StreamSubscription<SpeechRecognitionStatus>? _statusSubscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _resultSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speechNotifier = ref.watch(speechRecognitionProvider.notifier);
    final speechState = ref.watch(speechRecognitionProvider);
    final speechService = ref.watch(speechRecognitionServiceProvider);

    // 음성 인식 상태에 따른 애니메이션
    if (speechState.status == SpeechRecognitionStatus.listening) {
      _animationController.forward();
      _pulseController.repeat();
    } else {
      _animationController.reverse();
      _pulseController.stop();
      _pulseController.reset();
    }

    // 음성 인식 결과 처리
    _resultSubscription ??= speechService.resultStream.listen((result) {
      if (result.isFinal && widget.onResult != null) {
        widget.onResult!(result.recognizedWords);
      }
    });

    // 에러 처리
    _statusSubscription ??= speechService.statusStream.listen((status) {
      if (status == SpeechRecognitionStatus.error && widget.onError != null) {
        widget.onError!('음성 인식 중 오류가 발생했습니다.');
      }
    });

    final isListening = speechState.status == SpeechRecognitionStatus.listening;
    final isAvailable = speechState.status != SpeechRecognitionStatus.error;

    return GestureDetector(
      onTap: isAvailable ? () => _handleTap(speechNotifier, isListening) : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_animationController, _pulseController]),
        builder: (context, child) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isListening
                  ? (widget.color ?? Theme.of(context).colorScheme.primary)
                  : (widget.disabledColor ??
                        Theme.of(context).colorScheme.surface),
              boxShadow: isListening
                  ? [
                      BoxShadow(
                        color:
                            (widget.color ??
                                    Theme.of(context).colorScheme.primary)
                                .withValues(alpha: 0.3),
                        blurRadius: 20 * _pulseController.value,
                        spreadRadius: 5 * _pulseController.value,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              size: widget.size * 0.4,
              color: isListening
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleTap(
    SpeechRecognitionNotifier notifier,
    bool isListening,
  ) async {
    if (isListening) {
      await notifier.stopListening();
    } else {
      await notifier.startListening();
    }
  }
}

/// 음성 인식 상태 표시 위젯
class SpeechRecognitionStatusWidget extends ConsumerWidget {
  const SpeechRecognitionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechState = ref.watch(speechRecognitionProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildStatusContent(context, speechState),
    );
  }

  Widget _buildStatusContent(
    BuildContext context,
    SpeechRecognitionState state,
  ) {
    switch (state.status) {
      case SpeechRecognitionStatus.uninitialized:
        return _buildStatusItem(
          context,
          '음성 인식 초기화 중...',
          Icons.settings_voice,
          Colors.orange,
        );
      case SpeechRecognitionStatus.initialized:
        return _buildStatusItem(
          context,
          '음성 인식 준비 완료',
          Icons.mic,
          Colors.green,
        );
      case SpeechRecognitionStatus.listening:
        return _buildStatusItem(
          context,
          '듣고 있습니다...',
          Icons.hearing,
          Colors.blue,
        );
      case SpeechRecognitionStatus.stopped:
        return _buildStatusItem(
          context,
          '처리 중...',
          Icons.autorenew,
          Colors.purple,
        );
      case SpeechRecognitionStatus.completed:
        return _buildStatusItem(
          context,
          '인식 완료',
          Icons.check_circle,
          Colors.green,
        );
      case SpeechRecognitionStatus.error:
      case SpeechRecognitionStatus.initializationFailed:
      case SpeechRecognitionStatus.permissionDenied:
      case SpeechRecognitionStatus.permissionPermanentlyDenied:
      case SpeechRecognitionStatus.startFailed:
      case SpeechRecognitionStatus.stopFailed:
      case SpeechRecognitionStatus.cancelFailed:
        return _buildStatusItem(context, '오류 발생', Icons.error, Colors.red);
      case SpeechRecognitionStatus.cancelled:
        return _buildStatusItem(context, '취소됨', Icons.cancel, Colors.grey);
    }
  }

  Widget _buildStatusItem(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
  ) {
    return Container(
      key: ValueKey(text),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// 음성 파형 애니메이션 위젯
class SpeechWaveformWidget extends StatefulWidget {
  const SpeechWaveformWidget({
    super.key,
    this.height = 60.0,
    this.color,
    this.barCount = 5,
  });

  final double height;
  final Color? color;
  final int barCount;

  @override
  State<SpeechWaveformWidget> createState() => _SpeechWaveformWidgetState();
}

class _SpeechWaveformWidgetState extends State<SpeechWaveformWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.barCount, (index) {
              final delay = index / widget.barCount;
              final animationValue = (_animationController.value - delay).clamp(
                0.0,
                1.0,
              );
              final barHeight =
                  (widget.height * 0.3 + widget.height * 0.7 * animationValue);

              return Container(
                width: 4,
                height: barHeight,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: widget.color ?? Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

/// 실시간 음성 인식 텍스트 표시 위젯
class SpeechRecognitionTextWidget extends ConsumerWidget {
  const SpeechRecognitionTextWidget({super.key, this.onTextUpdate});

  final void Function(String)? onTextUpdate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechService = ref.watch(speechRecognitionServiceProvider);

    return StreamBuilder<SpeechRecognitionResultWrapper>(
      stream: speechService.resultStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final result = snapshot.data!;

        // 텍스트 업데이트 콜백 호출
        if (onTextUpdate != null) {
          onTextUpdate!(result.recognizedWords);
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.record_voice_over,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '음성 인식 결과',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (result.isFinal)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '완료',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                result.recognizedWords,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: result.isFinal
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              if (result.confidence > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Text(
                        '신뢰도: ',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: result.confidence,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            result.confidence > 0.7
                                ? Colors.green
                                : result.confidence > 0.4
                                ? Colors.orange
                                : Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(result.confidence * 100).toInt()}%',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// 음성 인식 진행 시간 표시 위젯
class SpeechRecognitionTimerWidget extends ConsumerStatefulWidget {
  const SpeechRecognitionTimerWidget({super.key});

  @override
  ConsumerState<SpeechRecognitionTimerWidget> createState() =>
      _SpeechRecognitionTimerWidgetState();
}

class _SpeechRecognitionTimerWidgetState
    extends ConsumerState<SpeechRecognitionTimerWidget> {
  DateTime? _startTime;
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speechState = ref.watch(speechRecognitionProvider);

    if (speechState.status == SpeechRecognitionStatus.listening) {
      _startTime ??= DateTime.now();
      _timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
        if (_startTime != null) {
          setState(() {
            _elapsedTime = DateTime.now().difference(_startTime!);
          });
        }
      });
    } else {
      _timer?.cancel();
      _timer = null;
      if (speechState.status == SpeechRecognitionStatus.completed ||
          speechState.status == SpeechRecognitionStatus.error) {
        _elapsedTime = Duration.zero;
        _startTime = null;
      }
    }

    if (speechState.status != SpeechRecognitionStatus.listening) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDuration(_elapsedTime),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
