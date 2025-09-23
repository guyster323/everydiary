import 'dart:async';

import 'package:flutter/material.dart';

import '../services/voice_recording_service.dart';

/// 음성녹음 다이얼로그
class VoiceRecordingDialog extends StatefulWidget {
  const VoiceRecordingDialog({super.key});

  @override
  State<VoiceRecordingDialog> createState() => _VoiceRecordingDialogState();
}

class _VoiceRecordingDialogState extends State<VoiceRecordingDialog> {
  final VoiceRecordingService _voiceService = VoiceRecordingService();
  String _recognizedText = '';
  int _recordingDuration = 0;
  bool _isInitialized = false;
  bool _hasRecorded = false; // 녹음한 적이 있는지 확인

  @override
  void initState() {
    super.initState();
    _initializeVoiceService();
  }

  /// 음성 서비스 초기화
  Future<void> _initializeVoiceService() async {
    final initialized = await _voiceService.initialize();
    setState(() {
      _isInitialized = initialized;
    });
  }

  /// 음성녹음 시작/재개
  Future<void> _startRecording() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('음성인식 서비스를 초기화할 수 없습니다.')));
      return;
    }

    final success = await _voiceService.startContinuousListening(
      onResult: (String text) {
        setState(() {
          _recognizedText = text;
          _hasRecorded = true;
        });
      },
      onDuration: (int duration) {
        setState(() {
          _recordingDuration = duration;
        });
      },
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('음성녹음을 시작할 수 없습니다.')));
    }
  }

  /// 음성녹음 중지
  Future<void> _stopRecording() async {
    await _voiceService.stopListening();
  }

  /// 음성녹음 취소
  Future<void> _cancelRecording() async {
    await _voiceService.stopListening();
    setState(() {
      _recognizedText = '';
      _recordingDuration = 0;
      _hasRecorded = false;
    });
  }

  /// 결과 확인
  void _confirmResult() {
    // 전체 텍스트 (누적된 모든 텍스트) 반환
    final fullText = _voiceService.getFullText();
    Navigator.of(context).pop(fullText);
  }

  /// 시간 포맷팅
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목
            Text(
              '음성녹음',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // 녹음 상태 표시
            if (_voiceService.isListening) ...[
              // 녹음 중
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: const Icon(Icons.mic, size: 60, color: Colors.red),
              ),
              const SizedBox(height: 16),
              Text(
                '녹음 중...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDuration(_recordingDuration),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else if (!_voiceService.isListening && _hasRecorded) ...[
              // 일시정지 중
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: const Icon(Icons.pause, size: 60, color: Colors.orange),
              ),
              const SizedBox(height: 16),
              Text(
                '일시정지 중',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDuration(_recordingDuration),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else ...[
              // 대기 중
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: const Icon(Icons.mic_none, size: 60, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text(
                _hasRecorded ? '녹음을 재개하세요' : '녹음을 시작하세요',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey),
              ),
            ],

            const SizedBox(height: 24),

            // 인식된 텍스트
            if (_recognizedText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '인식된 텍스트:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _recognizedText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 버튼들
            Column(
              children: [
                // 녹음 시작/중지 버튼 (중앙에 크게)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isInitialized
                        ? (_voiceService.isListening
                              ? _stopRecording
                              : _startRecording)
                        : null,
                    icon: Icon(
                      _voiceService.isListening ? Icons.stop : Icons.mic,
                      size: 24,
                    ),
                    label: Text(
                      _voiceService.isListening
                          ? '녹음 중지'
                          : (_hasRecorded ? '녹음 재개' : '녹음 시작'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _voiceService.isListening
                          ? Colors.red
                          : (_hasRecorded ? Colors.green : Colors.blue),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 하단 버튼들
                Row(
                  children: [
                    // 취소 버튼
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _cancelRecording();
                          Navigator.of(context).pop();
                        },
                        child: const Text('취소'),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 확인 버튼
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (_recognizedText.isNotEmpty || _hasRecorded)
                            ? _confirmResult
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('확인'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
