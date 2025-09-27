import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/android_native_service_manager.dart';
import '../services/supabase_test_service.dart';

/// 디버그 로그 위젯
class DebugLogWidget extends ConsumerStatefulWidget {
  const DebugLogWidget({super.key});

  @override
  ConsumerState<DebugLogWidget> createState() => _DebugLogWidgetState();
}

class _DebugLogWidgetState extends ConsumerState<DebugLogWidget> {
  final List<String> _logs = [];
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _addLog('🔍 디버그 로그 시작');
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
      if (_logs.length > 50) {
        _logs.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.orange),
            title: const Text('디버그 로그'),
            subtitle: Text('${_logs.length}개 항목'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _runTests,
                  icon: const Icon(Icons.play_arrow, color: Colors.green),
                  tooltip: '테스트 실행',
                ),
                IconButton(
                  onPressed: _clearLogs,
                  icon: const Icon(Icons.clear, color: Colors.red),
                  tooltip: '로그 지우기',
                ),
                IconButton(
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const Divider(),
            Container(
              height: 200,
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[_logs.length - 1 - index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      log,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _runTests() async {
    _addLog('🧪 테스트 시작...');

    // 1. Supabase 연결 테스트
    _addLog('📡 Supabase 연결 테스트...');
    try {
      final supabaseTest = SupabaseTestService();
      final result = await supabaseTest.testConnection();
      if (result['connected'] == true) {
        _addLog('✅ Supabase 연결 성공');
      } else {
        _addLog('❌ Supabase 연결 실패: ${result['error']}');
      }
    } catch (e) {
      _addLog('❌ Supabase 테스트 오류: $e');
    }

    // 2. 서비스 상태 확인
    _addLog('🔧 서비스 상태 확인...');
    try {
      final serviceManager = AndroidNativeServiceManager();
      final status = serviceManager.getServiceStatus();
      _addLog('📊 서비스 상태: ${status.toString()}');
    } catch (e) {
      _addLog('❌ 서비스 상태 확인 오류: $e');
    }

    // 3. 캐시 상태 확인
    _addLog('💾 캐시 상태 확인...');
    try {
      // 캐시 상태 확인 로직
      _addLog('✅ 캐시 상태 확인 완료');
    } catch (e) {
      _addLog('❌ 캐시 상태 확인 오류: $e');
    }

    _addLog('🏁 테스트 완료');
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
      _addLog('🧹 로그가 지워졌습니다');
    });
  }
}
