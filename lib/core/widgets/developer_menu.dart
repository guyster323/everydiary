import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/config.dart';
import '../config/config_service.dart';
import '../utils/hot_reload_helper.dart';
import '../utils/logger.dart';
import '../utils/performance_monitor.dart';

/// 개발자 메뉴 위젯
class DeveloperMenu extends StatefulWidget {
  const DeveloperMenu({super.key});

  @override
  State<DeveloperMenu> createState() => _DeveloperMenuState();
}

class _DeveloperMenuState extends State<DeveloperMenu> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    if (!FeatureFlagManager.instance.isFeatureEnabled('enableDebugMenu') ||
        !kDebugMode) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [if (_isVisible) _buildMenuOverlay(), _buildFloatingButton()],
    );
  }

  Widget _buildFloatingButton() {
    return Positioned(
      bottom: 100,
      right: 20,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.orange,
        onPressed: () => setState(() => _isVisible = !_isVisible),
        child: const Icon(Icons.bug_report, color: Colors.white),
      ),
    );
  }

  Widget _buildMenuOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🛠️ Developer Menu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildMenuButton(
                '📊 Performance Report',
                () => _showPerformanceReport(),
              ),
              _buildMenuButton(
                '🧹 Clear Performance Data',
                () => _clearPerformanceData(),
              ),
              _buildMenuButton('📝 Test Logging', () => _testLogging()),
              _buildMenuButton('⚙️ App Config', () => _showAppConfig()),
              _buildMenuButton('🔥 Hot Reload', () => _hotReload()),
              _buildMenuButton('🔄 Hot Restart', () => _hotRestart()),
              _buildMenuButton(
                '🛠️ Dev Tools Status',
                () => _showDevToolsStatus(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() => _isVisible = false),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(onPressed: onPressed, child: Text(title)),
      ),
    );
  }

  void _showPerformanceReport() {
    final report = PerformanceMonitor.generateReport();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Performance Report'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: report.isEmpty
              ? const Text('No performance data available')
              : ListView.builder(
                  itemCount: report.length,
                  itemBuilder: (context, index) {
                    final entry = report.entries.elementAt(index);
                    final operation = entry.key;
                    final data = entry.value as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        title: Text(operation),
                        subtitle: Text(
                          'Count: ${data['count']}\n'
                          'Average: ${data['average_ms']}ms\n'
                          'Min: ${data['min_ms']}ms\n'
                          'Max: ${data['max_ms']}ms',
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearPerformanceData() {
    PerformanceMonitor.clearMeasurements();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Performance data cleared')));
  }

  void _testLogging() {
    Logger.debug('This is a debug message');
    Logger.info('This is an info message');
    Logger.warning('This is a warning message');
    Logger.error('This is an error message');
    Logger.network('GET https://api.example.com/test');
    Logger.database('SELECT * FROM users WHERE id = ?');
    Logger.userAction('button_clicked: test_logging');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Test logs generated')));
  }

  void _showAppConfig() {
    final config = ConfigService.instance.exportConfig();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚙️ App Configuration'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: config.length,
            itemBuilder: (context, index) {
              final entry = config.entries.elementAt(index);
              return ListTile(
                title: Text(entry.key),
                subtitle: Text(entry.value.toString()),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _hotReload() {
    HotReloadHelper.performHotReload();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('🔥 Hot reload performed')));
  }

  void _hotRestart() {
    HotReloadHelper.performHotRestart();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('🔄 Hot restart requested')));
  }

  void _showDevToolsStatus() {
    final status = HotReloadHelper.getDevToolsStatus();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🛠️ Development Tools Status'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: status.length,
            itemBuilder: (context, index) {
              final entry = status.entries.elementAt(index);
              return ListTile(
                title: Text(entry.key),
                subtitle: Text(entry.value.toString()),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
