import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
import 'shared/services/payment_service.dart';

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
      loadSecretsFromAssets: true,
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

    // 테마 매니저 초기화
    await theme_manager.ThemeManager().initialize();

    // 광고 SDK 초기화
    try {
      await AdService.instance.initialize();
      await AdService.instance.loadRewardedAd();
      Logger.info('✅ 광고 서비스 초기화 완료');
    } catch (e) {
      Logger.warning('⚠️ 광고 서비스 초기화 실패: $e');
    }

    // 인앱 구매 서비스 초기화 (비동기 초기화, 실패해도 앱 실행 계속)
    try {
      PaymentService().initialize();
      Logger.info('✅ 인앱 구매 서비스 초기화 시작');
    } catch (e) {
      Logger.warning('⚠️ 인앱 구매 서비스 초기화 실패: $e');
    }

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
