import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/voice_recording_service.dart';

/// 지속적이고 누적형 음성녹음 다이얼로그
class VoiceRecordingDialog extends StatefulWidget {
  const VoiceRecordingDialog({super.key});

  @override
  State<VoiceRecordingDialog> createState() => _VoiceRecordingDialogState();
}

class _VoiceRecordingDialogState extends State<VoiceRecordingDialog>
    with TickerProviderStateMixin {
  final VoiceRecordingService _voiceService = VoiceRecordingService();

  String _recordedText = '';
  bool _isListening = false;
  int _recordingDuration = 0;
  String? _errorMessage;
  int _sessionCount = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Timer? _uiUpdateTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVoiceService();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeVoiceService() async {
    final initialized = await _voiceService.initialize();
    if (!initialized && mounted) {
      setState(() {
        _errorMessage =
            '음성 인식을 초기화할 수 없습니다.\n\n'
            '다음을 확인해주세요:\n'
            '1. 마이크 권한 허용\n'
            '2. 네트워크 연결 상태\n'
            '3. Google 앱 설치 및 업데이트';
      });
    }
  }

  /// UI 업데이트 타이머 시작
  void _startUIUpdateTimer() {
    _uiUpdateTimer?.cancel();
    _uiUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted && _isListening) {
        setState(() {
          final debugInfo = _voiceService.getDebugInfo();
          _sessionCount = (debugInfo['sessionCount'] as int?) ?? 0;
        });
      }
    });
  }

  /// 지속적인 음성녹음 시작
  Future<void> _startContinuousRecording() async {
    if (_errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isListening = true;
      _recordedText = '';
      _recordingDuration = 0;
      _sessionCount = 0;
      _errorMessage = null;
    });

    // 애니메이션 시작
    _pulseController.repeat(reverse: true);

    // UI 업데이트 타이머 시작
    _startUIUpdateTimer();

    // 햅틱 피드백
    HapticFeedback.lightImpact();

    final success = await _voiceService.startContinuousListening(
      onResult: (text) {
        if (mounted) {
          setState(() {
            _recordedText = text;
          });
        }
      },
      onDuration: (duration) {
        if (mounted) {
          setState(() {
            _recordingDuration = duration;
          });
        }
      },
      onStatusChanged: () {
        // 상태 변화 처리 (필요시)
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _errorMessage = error;
          });
        }
      },
      onStop: () {
        if (mounted) {
          _stopRecording();
        }
      },
    );

    if (!success && mounted) {
      setState(() {
        _isListening = false;
        _errorMessage = '음성녹음을 시작할 수 없습니다.';
      });
      _pulseController.stop();
      _uiUpdateTimer?.cancel();
    }
  }

  /// 음성녹음 중지
  Future<void> _stopRecording() async {
    if (!_isListening) return;

    setState(() {
      _isListening = false;
    });

    // 애니메이션 정지
    _pulseController.stop();
    _pulseController.reset();

    // UI 업데이트 타이머 정지
    _uiUpdateTimer?.cancel();

    // 햅틱 피드백
    HapticFeedback.mediumImpact();

    await _voiceService.stopListening();

    // 최종 텍스트 가져오기
    final finalText = _voiceService.getFullText();
    if (finalText.isNotEmpty) {
      setState(() {
        _recordedText = finalText;
      });
    }
  }

  /// 녹음 시간을 문자열로 변환
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// 녹음 상태 아이콘
  Widget _buildRecordingIcon() {
    if (_isListening) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.red.withValues(alpha: 0.8),
                    Colors.red.withValues(alpha: 0.4),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 40),
            ),
          );
        },
      );
    } else {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withValues(alpha: 0.3),
          border: Border.all(color: Colors.grey, width: 2),
        ),
        child: const Icon(Icons.mic_off, color: Colors.grey, size: 40),
      );
    }
  }

  /// 상태 정보 위젯
  Widget _buildStatusInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '상태: ${_isListening ? "녹음 중" : "대기 중"}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isListening ? Colors.red : Colors.grey,
                ),
              ),
              Text(
                '시간: ${_formatDuration(_recordingDuration)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          if (_isListening) ...[
            const SizedBox(height: 8),
            Text(
              '세션: #$_sessionCount',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            const Text(
              '💡 말을 멈춰도 자동으로 계속 인식합니다',
              style: TextStyle(
                fontSize: 11,
                color: Colors.green,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _uiUpdateTimer?.cancel();
    if (_isListening) {
      _voiceService.stopListening();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isListening,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _isListening) {
          // context를 미리 저장
          final navigator = Navigator.of(context);
          // 녹음 중일 때는 먼저 중지 확인
          final shouldStop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('녹음 중지'),
              content: const Text('녹음을 중지하고 나가시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('계속 녹음'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('중지하고 나가기'),
                ),
              ],
            ),
          );

          if (shouldStop == true) {
            await _stopRecording();
            if (mounted) {
              navigator.pop(_recordedText.isNotEmpty ? _recordedText : null);
            }
          }
        }
      },
      child: AlertDialog(
        title: const Text(
          '지속적인 음성 인식',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              // 오류 메시지 표시
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 녹음 아이콘 및 상태
              Center(child: _buildRecordingIcon()),

              const SizedBox(height: 16),

              // 상태 정보
              _buildStatusInfo(),

              const SizedBox(height: 16),

              // 인식된 텍스트 표시 영역
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.withValues(alpha: 0.05),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _recordedText.isEmpty
                          ? (_isListening
                                ? '음성을 인식하고 있습니다...'
                                : '인식된 텍스트가 여기에 표시됩니다.')
                          : _recordedText,
                      style: TextStyle(
                        fontSize: 14,
                        color: _recordedText.isEmpty
                            ? Colors.grey
                            : Colors.black,
                        fontStyle: _recordedText.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 컨트롤 버튼들
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 시작/중지 버튼
                  ElevatedButton.icon(
                    onPressed: _isListening
                        ? _stopRecording
                        : _startContinuousRecording,
                    icon: Icon(_isListening ? Icons.stop : Icons.mic),
                    label: Text(_isListening ? '중지' : '시작'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isListening ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),

                  // 텍스트 지우기 버튼
                  if (_recordedText.isNotEmpty && !_isListening)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _recordedText = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('지우기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null); // 취소
            },
            child: const Text('취소'),
          ),
          if (_recordedText.isNotEmpty && !_isListening)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_recordedText); // 텍스트 반환
              },
              child: const Text('사용하기'),
            ),
        ],
      ),
    );
  }
}
