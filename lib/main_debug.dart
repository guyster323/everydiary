import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/config.dart';
import 'core/config/config_service.dart';
import 'core/theme/theme_manager.dart' as theme_manager;
import 'core/utils/logger.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 단계별 초기화 테스트
    Logger.info('🚀 EveryDiary app starting...', tag: 'DebugApp');

    // 1단계: ConfigService 초기화 테스트
    Logger.info('1단계: ConfigService 초기화 중...', tag: 'DebugApp');
    await ConfigService.instance.initialize(
      environment: Environment.development,
      loadSecretsFromAssets: false, // 일단 비활성화
      loadSecretsFromEnvironment: false, // 일단 비활성화
    );
    Logger.info('✅ ConfigService 초기화 완료', tag: 'DebugApp');

    // 2단계: ThemeManager 초기화 테스트
    Logger.info('2단계: ThemeManager 초기화 중...', tag: 'DebugApp');
    await theme_manager.ThemeManager().initialize();
    Logger.info('✅ ThemeManager 초기화 완료', tag: 'DebugApp');

    // 3단계: 앱 실행
    Logger.info('3단계: 앱 실행 중...', tag: 'DebugApp');
    runApp(const ProviderScope(child: DebugApp()));
  } catch (e) {
    Logger.error('❌ Failed to initialize app: $e', tag: 'DebugApp');
    Logger.error('스택 트레이스: ${StackTrace.current}', tag: 'DebugApp');
    // 오류 발생 시에도 앱 실행
    runApp(const ProviderScope(child: DebugApp()));
  }
}

class DebugApp extends StatelessWidget {
  const DebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EveryDiary Debug',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DebugScreen(),
    );
  }
}

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EveryDiary Debug'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bug_report, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              '디버그 모드가 정상적으로 실행되었습니다!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              '이제 정식 버전의 초기화 과정을 단계별로 테스트할 수 있습니다.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
