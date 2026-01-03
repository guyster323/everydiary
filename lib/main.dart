import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/config.dart';
import 'core/config/config_service.dart';
import 'core/providers/localization_provider.dart';
import 'core/routing/app_router.dart';
import 'core/security/screen_security_guard.dart';
import 'core/services/android_native_service_manager.dart';
import 'core/theme/theme_manager.dart' as theme_manager;
import 'core/utils/hot_reload_helper.dart';
import 'core/utils/logger.dart';
import 'features/settings/models/settings_enums.dart' as settings_enums;
import 'features/settings/providers/settings_provider.dart';
import 'firebase_options.dart';
import 'shared/services/ad_service.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Android 15 (SDK 35) edge-to-edge 지원: 상태바/네비게이션바 투명 설정
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // SharedPreferences 미리 초기화 (가장 먼저 - 다른 서비스들이 사용하므로)
  await SharedPreferences.getInstance();

  // 필수 초기화 병렬 실행 (빠른 시작)
  await Future.wait([
    ConfigService.instance.initialize(
      environment: Environment.production,
      loadSecretsFromAssets: true,
      loadSecretsFromEnvironment: true,
    ),
    theme_manager.ThemeManager().initialize(),
  ]).catchError((e) {
    Logger.error('필수 초기화 실패: $e');
    return <void>[];
  });

  // 개발 도구 초기화 (동기)
  HotReloadHelper.initialize();

  // 앱 먼저 시작 (UI 빠르게 표시)
  runApp(const ProviderScope(child: EveryDiaryApp()));

  // 나머지 초기화는 백그라운드에서 실행 (비차단)
  _initializeServicesInBackground();
}

/// 백그라운드에서 서비스 초기화 (UI 차단 없음)
Future<void> _initializeServicesInBackground() async {
  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    Logger.warning('⚠️ Firebase 초기화 실패, 오프라인 모드로 실행: $e');
  }

  // Supabase 초기화 (사용하지 않으므로 스킵)
  // 실제 사용 시 활성화
  // try {
  //   await Supabase.initialize(
  //     url: 'https://your-project.supabase.co',
  //     anonKey: 'your-anon-key',
  //     debug: false,
  //   );
  // } catch (e) {
  //   Logger.warning('⚠️ Supabase 초기화 실패: $e');
  // }

  // 광고 SDK 초기화 (무료 버전)
  try {
    await AdService.instance.initialize();
    // 광고 로딩은 필요할 때 지연 로딩
    AdService.instance.loadRewardedAd(); // await 제거 - 비동기로 실행
    Logger.info('✅ 광고 서비스 초기화 완료 (Lite 버전)');
  } catch (e) {
    Logger.warning('⚠️ 광고 서비스 초기화 실패: $e');
  }

  // Android 네이티브 서비스 초기화
  if (!kIsWeb) {
    try {
      await AndroidNativeServiceManager().initialize();
    } catch (e) {
      Logger.warning('❌ Android Native Service Manager 초기화 실패: $e');
    }
  }
}

class EveryDiaryApp extends ConsumerWidget {
  const EveryDiaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ConfigManager.instance.config;
    final themeManager = theme_manager.ThemeManager();
    final settings = ref.watch(settingsProvider);

    // Locale/텍스트 스케일
    final locale = getLocaleFromLanguage(settings.language);
    final textScale = _textScaleFromFontSize(settings.fontSize);

    // 알림 메시지 로컬라이즈 설정 (Android만)
    if (!kIsWeb) {
      final l10n = ref.watch(localizationProvider);
      AndroidNativeServiceManager().setNotificationLocalizedMessages(
        offlineTitle: l10n.get('network_offline_title'),
        offlineMessage: l10n.get('network_offline_message'),
      );
    }

    final container = ProviderScope.containerOf(context);
    final router = AppRouter.buildRouter(container);

    return AnimatedBuilder(
      animation: themeManager,
      builder: (context, child) {
        return MaterialApp.router(
          title: config.appName,
          debugShowCheckedModeBanner: EnvironmentConfig.isDebug,
          theme: themeManager.lightTheme,
          darkTheme: themeManager.darkTheme,
          themeMode: settings.themeMode, // SettingsProvider의 themeMode 사용
          routerConfig: router,
          locale: locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ko', 'KR'),
            Locale('en', 'US'),
            Locale('ja', 'JP'),
            Locale('zh', 'CN'),
            Locale('zh', 'TW'),
            Locale('es', 'ES'),
            Locale('fr', 'FR'),
            Locale('de', 'DE'),
            Locale('ru', 'RU'),
            Locale('ar', 'SA'),
          ],
          builder: (context, child) {
            final mediaChild = MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textScale),
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

double _textScaleFromFontSize(settings_enums.FontSize fontSize) {
  switch (fontSize) {
    case settings_enums.FontSize.small:
      return 0.9;
    case settings_enums.FontSize.medium:
      return 1.0;
    case settings_enums.FontSize.large:
      return 1.15;
    case settings_enums.FontSize.extraLarge:
      return 1.3;
  }
}
