import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/network_monitor_service.dart';
import '../services/offline_speech_service.dart';

/// 오프라인 음성 인식 설정 패널
class OfflineSpeechSettingsPanel extends ConsumerStatefulWidget {
  const OfflineSpeechSettingsPanel({super.key});

  @override
  ConsumerState<OfflineSpeechSettingsPanel> createState() =>
      _OfflineSpeechSettingsPanelState();
}

class _OfflineSpeechSettingsPanelState
    extends ConsumerState<OfflineSpeechSettingsPanel> {
  final OfflineSpeechService _offlineService = OfflineSpeechService();
  final NetworkMonitorService _networkMonitor = NetworkMonitorService();

  bool _showAdvancedSettings = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Icon(
                  Icons.settings_voice,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '음성 인식 설정',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showAdvancedSettings = !_showAdvancedSettings;
                    });
                  },
                  icon: Icon(
                    _showAdvancedSettings
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 네트워크 상태 표시
            _buildNetworkStatus(),
            const SizedBox(height: 16),

            // 모드 선택
            _buildModeSelector(),
            const SizedBox(height: 16),

            // 고급 설정
            if (_showAdvancedSettings) ...[
              _buildAdvancedSettings(),
              const SizedBox(height: 16),
            ],

            // 액션 버튼들
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _networkMonitor.isOnline
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _networkMonitor.isOnline
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _networkMonitor.isOnline ? Icons.wifi : Icons.wifi_off,
            color: _networkMonitor.isOnline ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _networkMonitor.isOnline ? '온라인 연결됨' : '오프라인 모드',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _networkMonitor.isOnline ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  '연결 타입: ${_getNetworkTypeText(_networkMonitor.type)}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (_networkMonitor.isOnline)
                  Text(
                    '예상 속도: ${_networkMonitor.getEstimatedSpeed().toStringAsFixed(1)} Mbps',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '음성 인식 모드',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...OfflineSpeechMode.values.map((mode) => _buildModeOption(mode)),
      ],
    );
  }

  Widget _buildModeOption(OfflineSpeechMode mode) {
    return RadioListTile<OfflineSpeechMode>(
      title: Text(_getModeTitle(mode)),
      subtitle: Text(_getModeDescription(mode)),
      value: mode,
      // ignore: deprecated_member_use
      groupValue: _offlineService.mode,
      // ignore: deprecated_member_use
      onChanged: (OfflineSpeechMode? value) async {
        if (value != null) {
          await _offlineService.setMode(value);
          setState(() {});
        }
      },
      activeColor: Theme.of(context).colorScheme.primary,
      dense: true,
    );
  }

  Widget _buildAdvancedSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '고급 설정',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        // 캐시 관리
        ListTile(
          leading: const Icon(Icons.storage),
          title: const Text('인식 결과 캐시'),
          subtitle: Text('${_offlineService.resultCache.length}개 결과 저장됨'),
          trailing: TextButton(
            onPressed: () async {
              await _offlineService.clearCache();
              setState(() {});
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('캐시가 삭제되었습니다')));
              }
            },
            child: const Text('삭제'),
          ),
        ),

        // 네트워크 상태 새로고침
        ListTile(
          leading: const Icon(Icons.refresh),
          title: const Text('네트워크 상태 새로고침'),
          trailing: IconButton(
            onPressed: () async {
              await _networkMonitor.refresh();
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _showLimitationsDialog();
            },
            icon: const Icon(Icons.info_outline),
            label: const Text('제한사항'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _showTestDialog();
            },
            icon: const Icon(Icons.mic),
            label: const Text('테스트'),
          ),
        ),
      ],
    );
  }

  String _getNetworkTypeText(NetworkType type) {
    switch (type) {
      case NetworkType.wifi:
        return 'Wi-Fi';
      case NetworkType.mobile:
        return '모바일 데이터';
      case NetworkType.ethernet:
        return '이더넷';
      case NetworkType.bluetooth:
        return '블루투스';
      case NetworkType.vpn:
        return 'VPN';
      case NetworkType.other:
        return '기타';
      case NetworkType.none:
        return '연결 없음';
    }
  }

  String _getModeTitle(OfflineSpeechMode mode) {
    switch (mode) {
      case OfflineSpeechMode.online:
        return '온라인 모드';
      case OfflineSpeechMode.offline:
        return '오프라인 모드';
      case OfflineSpeechMode.hybrid:
        return '하이브리드 모드';
    }
  }

  String _getModeDescription(OfflineSpeechMode mode) {
    switch (mode) {
      case OfflineSpeechMode.online:
        return '인터넷 연결을 통한 고품질 음성 인식';
      case OfflineSpeechMode.offline:
        return '인터넷 없이 제한적인 음성 인식';
      case OfflineSpeechMode.hybrid:
        return '온라인 우선, 오프라인 대체 모드';
    }
  }

  void _showLimitationsDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오프라인 모드 제한사항'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('오프라인 모드에서는 다음과 같은 제한이 있습니다:'),
            const SizedBox(height: 12),
            ..._offlineService.limitations.map(
              (limitation) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(limitation)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showTestDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('음성 인식 테스트'),
        content: const Text('현재 설정으로 음성 인식 기능을 테스트합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _testSpeechRecognition();
            },
            child: const Text('테스트 시작'),
          ),
        ],
      ),
    );
  }

  Future<void> _testSpeechRecognition() async {
    try {
      final success = await _offlineService.startListening();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '테스트 시작됨' : '테스트 시작 실패'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('테스트 오류: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
