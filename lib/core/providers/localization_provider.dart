import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/models/settings_enums.dart';
import '../localization/app_localizations.dart';

/// 다국어 지원 프로바이더
/// 앱의 언어 설정을 관리하고 다국어 지원을 제공합니다.
class LocalizationNotifier extends StateNotifier<Locale> {
  LocalizationNotifier() : super(const Locale('ko', 'KR'));

  /// 언어 변경
  Future<void> changeLanguage(Language language) async {
    try {
      final locale = _getLocaleFromLanguage(language);
      state = locale;
      debugPrint('언어 변경: ${locale.languageCode}');
    } catch (e) {
      debugPrint('언어 변경 실패: $e');
    }
  }

  /// 현재 언어 가져오기
  Language getCurrentLanguage() {
    return _getLanguageFromLocale(state);
  }

  /// 지원되는 언어 목록 가져오기
  List<Language> getSupportedLanguages() {
    return Language.values;
  }

  /// 언어별 로케일 매핑
  Locale _getLocaleFromLanguage(Language language) {
    switch (language) {
      case Language.korean:
        return const Locale('ko', 'KR');
      case Language.english:
        return const Locale('en', 'US');
      case Language.japanese:
        return const Locale('ja', 'JP');
      case Language.chineseSimplified:
        return const Locale('zh', 'CN');
      case Language.chineseTraditional:
        return const Locale('zh', 'TW');
      case Language.spanish:
        return const Locale('es', 'ES');
      case Language.french:
        return const Locale('fr', 'FR');
      case Language.german:
        return const Locale('de', 'DE');
      case Language.russian:
        return const Locale('ru', 'RU');
      case Language.arabic:
        return const Locale('ar', 'SA');
    }
  }

  /// 로케일별 언어 매핑
  Language _getLanguageFromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'ko':
        return Language.korean;
      case 'en':
        return Language.english;
      case 'ja':
        return Language.japanese;
      case 'zh':
        return locale.countryCode == 'TW'
            ? Language.chineseTraditional
            : Language.chineseSimplified;
      case 'es':
        return Language.spanish;
      case 'fr':
        return Language.french;
      case 'de':
        return Language.german;
      case 'ru':
        return Language.russian;
      case 'ar':
        return Language.arabic;
      default:
        return Language.korean;
    }
  }

  /// 언어 이름 가져오기
  String getLanguageName(Language language) {
    switch (language) {
      case Language.korean:
        return '한국어';
      case Language.english:
        return 'English';
      case Language.japanese:
        return '日本語';
      case Language.chineseSimplified:
        return '简体中文';
      case Language.chineseTraditional:
        return '繁體中文';
      case Language.spanish:
        return 'Español';
      case Language.french:
        return 'Français';
      case Language.german:
        return 'Deutsch';
      case Language.russian:
        return 'Русский';
      case Language.arabic:
        return 'العربية';
    }
  }

  /// 언어 코드 가져오기
  String getLanguageCode(Language language) {
    switch (language) {
      case Language.korean:
        return 'ko';
      case Language.english:
        return 'en';
      case Language.japanese:
        return 'ja';
      case Language.chineseSimplified:
        return 'zh-CN';
      case Language.chineseTraditional:
        return 'zh-TW';
      case Language.spanish:
        return 'es';
      case Language.french:
        return 'fr';
      case Language.german:
        return 'de';
      case Language.russian:
        return 'ru';
      case Language.arabic:
        return 'ar';
    }
  }

  /// 언어 변경 가능 여부 확인
  bool canChangeLanguage(Language language) {
    final targetLocale = _getLocaleFromLanguage(language);
    return AppLocalizations.supportedLocales.any(
      (locale) => locale.languageCode == targetLocale.languageCode,
    );
  }

  /// 현재 언어가 RTL인지 확인
  bool get isCurrentLanguageRTL {
    return state.languageCode == 'ar' ||
        state.languageCode == 'he' ||
        state.languageCode == 'fa';
  }

  /// 언어 설정 저장
  Future<void> saveLanguageSetting(Language language) async {
    try {
      // SharedPreferences에 언어 설정 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', language.name);
      await changeLanguage(language);
      debugPrint('언어 설정 저장: $language');
    } catch (e) {
      debugPrint('언어 설정 저장 실패: $e');
    }
  }

  /// 언어 설정 로드
  Future<void> loadLanguageSetting() async {
    try {
      // SharedPreferences에서 언어 설정 로드
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('selected_language');
      if (savedLanguage != null) {
        final language = Language.values.firstWhere(
          (lang) => lang.name == savedLanguage,
          orElse: () => Language.korean,
        );
        await changeLanguage(language);
      } else {
        await changeLanguage(Language.korean);
      }
      debugPrint('언어 설정 로드 완료');
    } catch (e) {
      debugPrint('언어 설정 로드 실패: $e');
    }
  }

  /// 언어 설정 초기화
  Future<void> resetLanguageSetting() async {
    try {
      await changeLanguage(Language.korean);
      debugPrint('언어 설정 초기화 완료');
    } catch (e) {
      debugPrint('언어 설정 초기화 실패: $e');
    }
  }
}

/// 다국어 지원 프로바이더
final localizationProvider =
    StateNotifierProvider<LocalizationNotifier, Locale>((ref) {
      return LocalizationNotifier();
    });

/// 현재 언어 프로바이더
final currentLanguageProvider = Provider<Language>((ref) {
  final notifier = ref.read(localizationProvider.notifier);
  return notifier.getCurrentLanguage();
});

/// 지원되는 언어 목록 프로바이더
final supportedLanguagesProvider = Provider<List<Language>>((ref) {
  final notifier = ref.read(localizationProvider.notifier);
  return notifier.getSupportedLanguages();
});

/// 언어 이름 프로바이더
final languageNameProvider = Provider.family<String, Language>((ref, language) {
  final notifier = ref.read(localizationProvider.notifier);
  return notifier.getLanguageName(language);
});

/// 언어 코드 프로바이더
final languageCodeProvider = Provider.family<String, Language>((ref, language) {
  final notifier = ref.read(localizationProvider.notifier);
  return notifier.getLanguageCode(language);
});

/// RTL 언어 여부 프로바이더
final isRTLProvider = Provider<bool>((ref) {
  final notifier = ref.read(localizationProvider.notifier);
  return notifier.isCurrentLanguageRTL;
});

/// 언어 변경 가능 여부 프로바이더
final canChangeLanguageProvider = Provider.family<bool, Language>((
  ref,
  language,
) {
  final notifier = ref.read(localizationProvider.notifier);
  return notifier.canChangeLanguage(language);
});
