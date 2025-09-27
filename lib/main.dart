import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/config.dart';
import 'core/config/config_service.dart';
import 'core/routing/app_router.dart';
import 'core/services/android_native_service_manager.dart';
import 'core/theme/theme_manager.dart' as theme_manager;
import 'core/utils/hot_reload_helper.dart';
import 'core/utils/logger.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 구성 시스템 초기화
    await ConfigService.instance.initialize(
      environment: Environment.development, // 환경에 따라 변경
      loadSecretsFromAssets: false, // Android에서 문제 발생 시 비활성화
      loadSecretsFromEnvironment: false, // Android에서 문제 발생 시 비활성화
    );

    // Supabase 초기화 - 안전한 에러 처리
    try {
      await Supabase.initialize(
        url: 'https://dummy.supabase.co', // 실제 URL로 교체 필요
        anonKey: 'dummy-key', // 실제 키로 교체 필요
        debug: false,
      );
      Logger.info('✅ Supabase 초기화 성공');
    } catch (e) {
      Logger.warning('⚠️ Supabase 초기화 실패, 오프라인 모드로 실행: $e');
      // 실패해도 앱 실행 지속
    }

    // 로그 출력
    Logger.info('🚀 EveryDiary app starting...');
    Logger.info('Environment: ${EnvironmentConfig.environmentName}');
    Logger.info('App Name: ${ConfigManager.instance.config.appName}');

    // 개발 도구 초기화
    HotReloadHelper.initialize();

    // 테마 매니저 초기화
    await theme_manager.ThemeManager().initialize();

    // Android 네이티브 서비스 초기화 (웹 환경에서는 건너뜀)
    if (!kIsWeb) {
      try {
        await AndroidNativeServiceManager().initialize();
        Logger.info('✅ Android Native Service Manager 초기화 완료');
      } catch (e) {
        Logger.warning('❌ Android Native Service Manager 초기화 실패: $e');
      }
    } else {
      Logger.info('🌐 웹 환경에서는 Android Native Service Manager를 건너뜁니다');
    }

    runApp(const ProviderScope(child: EveryDiaryApp()));
  } catch (e) {
    Logger.error('Failed to initialize app: $e');
    // 오류 발생 시에도 앱 실행 (기본 구성으로)
    runApp(const ProviderScope(child: EveryDiaryApp()));
  }
}

class EveryDiaryApp extends StatelessWidget {
  const EveryDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = ConfigManager.instance.config;
    final themeManager = theme_manager.ThemeManager();

    return AnimatedBuilder(
      animation: themeManager,
      builder: (context, child) {
        return MaterialApp.router(
          title: config.appName,
          debugShowCheckedModeBanner: EnvironmentConfig.isDebug,
          theme: themeManager.lightTheme,
          darkTheme: themeManager.darkTheme,
          themeMode: ThemeMode.values.firstWhere(
            (mode) => mode.name == themeManager.materialThemeMode.name,
          ),
          routerConfig: AppRouter.router,
          // 한글 로케일 설정
          locale: const Locale('ko', 'KR'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
          // 한글 입력을 위한 설정
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0), // 텍스트 스케일링 고정
                platformBrightness: MediaQuery.of(context).platformBrightness,
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
