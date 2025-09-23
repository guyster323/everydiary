import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/config.dart';
import '../utils/logger.dart';
import '../utils/performance_monitor.dart';

/// 개발용 디버그 오버레이 위젯
class DebugOverlay extends StatefulWidget {
  final Widget child;
  final bool showOverlay;

  const DebugOverlay({super.key, required this.child, this.showOverlay = true});

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  bool _isVisible = false;
  bool _showPerformance = false;
  bool _showLogs = false;
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    if (FeatureFlagManager.instance.isFeatureEnabled('enableDebugMenu')) {
      _isVisible = widget.showOverlay;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!FeatureFlagManager.instance.isFeatureEnabled('enableDebugMenu') ||
        !_isVisible) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned(top: 50, right: 10, child: _buildDebugPanel()),
        if (_showPerformance)
          Positioned(top: 200, right: 10, child: _buildPerformancePanel()),
        if (_showLogs)
          Positioned(bottom: 50, left: 10, right: 10, child: _buildLogsPanel()),
      ],
    );
  }

  Widget _buildDebugPanel() {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🐛 Debug Panel',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                onPressed: () => setState(() => _isVisible = false),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Environment', EnvironmentConfig.environmentName),
          _buildInfoRow(
            'Build Mode',
            kDebugMode
                ? 'Debug'
                : kProfileMode
                ? 'Profile'
                : 'Release',
          ),
          _buildInfoRow(
            'Logging',
            ConfigManager.instance.enableLogging ? 'ON' : 'OFF',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      setState(() => _showPerformance = !_showPerformance),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showPerformance
                        ? Colors.green
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  child: const Text('Perf', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _showLogs = !_showLogs),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showLogs ? Colors.green : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  child: const Text('Logs', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ElevatedButton(
            onPressed: _clearLogs,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 4),
            ),
            child: const Text('Clear Logs', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformancePanel() {
    final report = PerformanceMonitor.generateReport();

    return Container(
      width: 250,
      height: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '⚡ Performance',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                onPressed: () => setState(() => _showPerformance = false),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: report.isEmpty
                ? const Text(
                    'No performance data',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  )
                : ListView.builder(
                    itemCount: report.length,
                    itemBuilder: (context, index) {
                      final entry = report.entries.elementAt(index);
                      final operation = entry.key;
                      final data = entry.value as Map<String, dynamic>;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '$operation: ${data['average_ms']}ms (${data['count']}x)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsPanel() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📝 Logs',
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                onPressed: () => setState(() => _showLogs = false),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _logs.isEmpty
                ? const Text(
                    'No logs available',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  )
                : ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          _logs[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
    Logger.info('Debug logs cleared');
  }
}

/// 디버그 오버레이를 쉽게 추가할 수 있는 헬퍼 함수
Widget withDebugOverlay(Widget child, {bool showOverlay = true}) {
  return DebugOverlay(showOverlay: showOverlay, child: child);
}
