import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/localization_provider.dart';
import '../../../core/providers/speech_recognition_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../services/voice_recording_service.dart';

/// 음성녹음 다이얼로그
class VoiceRecordingDialog extends ConsumerStatefulWidget {
  const VoiceRecordingDialog({super.key});

  @override
  ConsumerState<VoiceRecordingDialog> createState() => _VoiceRecordingDialogState();
}

class _VoiceRecordingDialogState extends ConsumerState<VoiceRecordingDialog> {
  final VoiceRecordingService _voiceService = VoiceRecordingService();
  String _recognizedText = '';
  int _recordingDuration = 0;
  bool _isInitialized = false;
  bool _hasRecorded = false; // 녹음한 적이 있는지 확인
  String _selectedLocale = 'ko_KR'; // 선택된 언어

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _initializeVoiceService();
  }

  /// 앱 언어 설정에 따라 음성 인식 언어 초기화
  void _initializeLocale() {
    final settings = ref.read(settingsProvider);
    _selectedLocale = getDefaultSpeechLocaleFromAppLanguage(settings.language);
    _voiceService.setLocale(_selectedLocale);
  }

  /// 음성 서비스 초기화
  Future<void> _initializeVoiceService() async {
    final initialized = await _voiceService.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = initialized;
      });
    }
  }

  /// 음성녹음 시작/재개
  Future<void> _startRecording() async {
    if (!_isInitialized) {
      final l10n = ref.read(localizationProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.get('voice_recording_init_failed'))));
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
      final l10n = ref.read(localizationProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.get('voice_recording_start_failed'))));
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

  /// 언어 라벨 가져오기
  String _getLocalizedLanguageLabel(String code, dynamic l10n) {
    switch (code) {
      case 'ko_KR':
        return l10n.get('speech_language_korean') as String;
      case 'en_US':
        return l10n.get('speech_language_english') as String;
      case 'ja_JP':
        return l10n.get('speech_language_japanese') as String;
      case 'zh_CN':
        return l10n.get('speech_language_chinese') as String;
      default:
        return code;
    }
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(localizationProvider);
    final theme = Theme.of(context);
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목
            Text(
              l10n.get('voice_recording_title'),
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 언어 선택
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLocale,
                        dropdownColor: theme.colorScheme.surfaceBright,
                        isExpanded: true,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        items: kSpeechLocaleOptions
                            .map(
                              (option) => DropdownMenuItem<String>(
                                value: option.code,
                                child: Text(_getLocalizedLanguageLabel(option.code, l10n)),
                              ),
                            )
                            .toList(),
                        onChanged: _voiceService.isListening
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedLocale = value;
                                  });
                                  _voiceService.setLocale(value);
                                }
                              },
                      ),
                    ),
                  ),
                ],
              ),
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
                l10n.get('voice_recording_recording'),
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
                l10n.get('voice_recording_paused'),
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
                _hasRecorded ? l10n.get('voice_recording_resume_prompt') : l10n.get('voice_recording_start_prompt'),
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
                      l10n.get('voice_recording_recognized_text'),
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
                          ? l10n.get('voice_recording_stop')
                          : (_hasRecorded ? l10n.get('voice_recording_resume') : l10n.get('voice_recording_start')),
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
                        child: Text(l10n.get('voice_recording_cancel')),
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
                        child: Text(l10n.get('voice_recording_confirm')),
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
