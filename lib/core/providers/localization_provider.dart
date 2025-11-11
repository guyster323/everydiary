import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/providers/settings_provider.dart';
import '../l10n/app_localizations.dart';

/// 다국어 지원 Provider
/// 현재 설정된 언어에 따라 AppLocalizations 인스턴스를 제공합니다
final localizationProvider = Provider<AppLocalizations>((ref) {
  final settings = ref.watch(settingsProvider);
  return AppLocalizations(settings.language);
});
