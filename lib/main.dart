import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/config.dart';
import 'core/config/config_service.dart';
import 'core/routing/app_router.dart';
import 'core/security/screen_security_guard.dart';
import 'core/services/android_native_service_manager.dart';
import 'core/services/app_intro_service.dart';
import 'core/theme/theme_manager.dart' as theme_manager;
import 'core/utils/hot_reload_helper.dart';
import 'core/utils/logger.dart';
import 'firebase_options.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase 초기화 - 안전한 에러 처리
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      Logger.warning('⚠️ Firebase 초기화 실패, 오프라인 모드로 실행: $e');
      // Firebase 실패해도 앱 실행 지속
    }

    // 구성 시스템 초기화
    await ConfigService.instance.initialize(
      environment: Environment.production,
      loadSecretsFromAssets: false,
      loadSecretsFromEnvironment: true,
    );

    // Supabase 초기화 - 안전한 에러 처리
    try {
      await Supabase.initialize(
        url: 'https://dummy.supabase.co', // 실제 URL로 교체 필요
        anonKey: 'dummy-key', // 실제 키로 교체 필요
        debug: false,
      );
    } catch (e) {
      Logger.warning('⚠️ Supabase 초기화 실패, 오프라인 모드로 실행: $e');
      // 실패해도 앱 실행 지속
    }

    // 개발 도구 초기화
    HotReloadHelper.initialize();

    // 앱 소개 이미지 사전 로드 (백그라운드 처리)
    unawaited(AppIntroService.instance.preload());

    // 테마 매니저 초기화
    await theme_manager.ThemeManager().initialize();

    // Android 네이티브 서비스 초기화 (웹 환경에서는 건너뜀)
    if (!kIsWeb) {
      try {
        await AndroidNativeServiceManager().initialize();
      } catch (e) {
        Logger.warning('❌ Android Native Service Manager 초기화 실패: $e');
      }
    } else {
      Logger.debug('🌐 웹 환경에서는 Android Native Service Manager를 건너뜁니다');
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
        final container = ProviderScope.containerOf(context);
        final router = AppRouter.buildRouter(container);

        return MaterialApp.router(
          title: config.appName,
          debugShowCheckedModeBanner: EnvironmentConfig.isDebug,
          theme: themeManager.lightTheme,
          darkTheme: themeManager.darkTheme,
          themeMode: ThemeMode.values.firstWhere(
            (mode) => mode.name == themeManager.materialThemeMode.name,
          ),
          routerConfig: router,
          locale: const Locale('ko', 'KR'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
          builder: (context, child) {
            final mediaChild = MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
                platformBrightness: MediaQuery.of(context).platformBrightness,
              ),
              child: child!,
            );
            return ScreenSecurityGuard(child: mediaChild);
          },
        );
      },
    );
  }
}
