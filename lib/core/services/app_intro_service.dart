import 'dart:async';
import 'dart:math';

import '../l10n/app_localizations.dart';

class AppIntroFeature {
  const AppIntroFeature({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.prompt,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final String prompt;

  String getTitle(AppLocalizations l10n) => l10n.get(titleKey);
  String getDescription(AppLocalizations l10n) => l10n.get(descriptionKey);
}

class AppIntroSlide {
  const AppIntroSlide({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    this.imagePath,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final String? imagePath;

  String getTitle(AppLocalizations l10n) => l10n.get(titleKey);
  String getDescription(AppLocalizations l10n) => l10n.get(descriptionKey);
}

class AppIntroService {
  AppIntroService._();

  static final AppIntroService instance = AppIntroService._();

  final StreamController<int> _progressController =
      StreamController<int>.broadcast();

  final List<AppIntroFeature> _features = const <AppIntroFeature>[
    AppIntroFeature(
      id: 'ocr',
      titleKey: 'feature_ocr_title',
      descriptionKey: 'feature_ocr_desc',
      prompt:
          'A warm illustration of a diary page being scanned by a smartphone, handwritten text becoming clean digital letters, soft pastel background, simple UI elements, cozy desk setting',
    ),
    AppIntroFeature(
      id: 'voice',
      titleKey: 'feature_voice_title',
      descriptionKey: 'feature_voice_desc',
      prompt:
          'A friendly diary app with a microphone capturing voice notes, gentle sound waves flowing into a notebook, bright and calming colors, minimalistic Korean diary vibe',
    ),
    AppIntroFeature(
      id: 'emotion',
      titleKey: 'feature_emotion_title',
      descriptionKey: 'feature_emotion_desc',
      prompt:
          'An expressive illustration of a diary surrounded by emotion icons and analytics charts, balanced color palette, conveys insight and reflection, modern flat design',
    ),
    AppIntroFeature(
      id: 'ai_image',
      titleKey: 'feature_ai_image_title',
      descriptionKey: 'feature_ai_image_desc',
      prompt:
          'Dreamy watercolor style image of nature and memories blending into a diary page, AI sparks drawing calming artwork, premium detail, soft gradients',
    ),
    AppIntroFeature(
      id: 'search',
      titleKey: 'feature_search_title',
      descriptionKey: 'feature_search_desc',
      prompt:
          'A diary app interface highlighting a search bar with results popping up, magnifying glass icon, tags and calendar filters, clean modern Korean UI',
    ),
    AppIntroFeature(
      id: 'backup',
      titleKey: 'feature_backup_title',
      descriptionKey: 'feature_backup_desc',
      prompt:
          'A secure diary app interface exporting and importing encrypted files, lock icons, cloud and USB drive imagery, trustworthy blue and teal tones',
    ),
    AppIntroFeature(
      id: 'pin_security',
      titleKey: 'feature_pin_title',
      descriptionKey: 'feature_pin_desc',
      prompt:
          'Elegant illustration of a diary protected by a glowing PIN keypad and shield, subtle gradients, premium security concept, soft lighting',
    ),
    AppIntroFeature(
      id: 'screen_privacy',
      titleKey: 'feature_privacy_title',
      descriptionKey: 'feature_privacy_desc',
      prompt:
          'A phone switching apps while a blurred diary screen protects privacy, smooth animations, translucent overlays, muted evening colors',
    ),
  ];

  List<AppIntroSlide>? _cachedSlides;

  Stream<int> get progressStream => _progressController.stream;
  int get totalSteps => _features.length;

  Future<void> preload() async {
    // Asset 이미지를 사용하므로 사전 로드 불필요
    await _ensureSlides();
  }

  Future<List<AppIntroSlide>> loadSlides() async {
    final slides = await _ensureSlides();
    final shuffled = List<AppIntroSlide>.from(slides);
    shuffled.shuffle(Random(DateTime.now().millisecondsSinceEpoch));
    return shuffled;
  }

  Future<List<AppIntroSlide>> _ensureSlides() async {
    if (_cachedSlides != null) {
      _progressController.add(_features.length);
      return _cachedSlides!;
    }

    final List<AppIntroSlide> slides = [];

    // assets/images/app_intro의 이미지를 직접 사용
    for (final feature in _features) {
      slides.add(
        AppIntroSlide(
          id: feature.id,
          titleKey: feature.titleKey,
          descriptionKey: feature.descriptionKey,
          imagePath: 'assets/images/app_intro/${feature.id}.png',
        ),
      );
    }

    _progressController.add(_features.length);
    _cachedSlides = slides;
    return slides;
  }
}
