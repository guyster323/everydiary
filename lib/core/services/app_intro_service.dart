import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/logger.dart';
import 'image_generation_service.dart';

class AppIntroFeature {
  const AppIntroFeature({
    required this.id,
    required this.title,
    required this.description,
    required this.prompt,
  });

  final String id;
  final String title;
  final String description;
  final String prompt;
}

class AppIntroSlide {
  const AppIntroSlide({
    required this.id,
    required this.title,
    required this.description,
    this.imagePath,
  });

  final String id;
  final String title;
  final String description;
  final String? imagePath;
}

class AppIntroService {
  AppIntroService._();

  static final AppIntroService instance = AppIntroService._();

  final StreamController<int> _progressController =
      StreamController<int>.broadcast();

  final List<AppIntroFeature> _features = const <AppIntroFeature>[
    AppIntroFeature(
      id: 'ocr',
      title: 'OCR 텍스트 추출',
      description: '종이에 적은 기록을 촬영해 텍스트로 곧바로 변환해요.',
      prompt:
          'A warm illustration of a diary page being scanned by a smartphone, handwritten text becoming clean digital letters, soft pastel background, simple UI elements, cozy desk setting',
    ),
    AppIntroFeature(
      id: 'voice',
      title: '음성 녹음',
      description: '말로 남긴 하루를 자연스럽게 일기로 전환합니다.',
      prompt:
          'A friendly diary app with a microphone capturing voice notes, gentle sound waves flowing into a notebook, bright and calming colors, minimalistic Korean diary vibe',
    ),
    AppIntroFeature(
      id: 'emotion',
      title: '감정 분석',
      description: '일기에 담긴 감정을 스스로 정리하고 통계로 보여줘요.',
      prompt:
          'An expressive illustration of a diary surrounded by emotion icons and analytics charts, balanced color palette, conveys insight and reflection, modern flat design',
    ),
    AppIntroFeature(
      id: 'ai_image',
      title: 'AI 이미지 생성',
      description: '일기 분위기에 맞는 감성 배경 이미지를 만들어 드려요.',
      prompt:
          'Dreamy watercolor style image of nature and memories blending into a diary page, AI sparks drawing calming artwork, premium detail, soft gradients',
    ),
    AppIntroFeature(
      id: 'search',
      title: '일기 검색',
      description: '키워드와 날짜로 원하는 일기를 빠르게 찾아요.',
      prompt:
          'A diary app interface highlighting a search bar with results popping up, magnifying glass icon, tags and calendar filters, clean modern Korean UI',
    ),
    AppIntroFeature(
      id: 'backup',
      title: '백업 파일 관리',
      description: '백업 파일을 내보내고 다시 불러와 언제든 안전하게 보관해요.',
      prompt:
          'A secure diary app interface exporting and importing encrypted files, lock icons, cloud and USB drive imagery, trustworthy blue and teal tones',
    ),
    AppIntroFeature(
      id: 'pin_security',
      title: 'PIN 보안',
      description: 'PIN 잠금으로 개인 일기를 안전하게 지켜 드립니다.',
      prompt:
          'Elegant illustration of a diary protected by a glowing PIN keypad and shield, subtle gradients, premium security concept, soft lighting',
    ),
    AppIntroFeature(
      id: 'screen_privacy',
      title: '배경 화면 숨김',
      description: '백그라운드에서도 화면을 흐리게 처리해 사생활을 보호해요.',
      prompt:
          'A phone switching apps while a blurred diary screen protects privacy, smooth animations, translucent overlays, muted evening colors',
    ),
  ];

  List<AppIntroSlide>? _cachedSlides;
  Directory? _cacheDirectory;

  Stream<int> get progressStream => _progressController.stream;
  int get totalSteps => _features.length;

  Future<void> preload() async {
    try {
      await _ensureSlides();
    } catch (error) {
      Logger.debug('앱 소개 이미지 사전 로드 실패: $error');
    }
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

    final directory = await _resolveDirectory();
    final generator = ImageGenerationService();
    await generator.initialize();

    final List<AppIntroSlide> slides = [];
    var completed = 0;
    _progressController.add(completed);

    for (final feature in _features) {
      final file = File(p.join(directory.path, '${feature.id}.png'));

      if (!await file.exists()) {
        final result = await generator.generateImageFromText(feature.prompt);
        final localPath = result?.localImagePath;
        if (localPath != null && await File(localPath).exists()) {
          try {
            await File(localPath).copy(file.path);
          } catch (error) {
            Logger.debug('앱 소개 이미지 복사 실패 (${feature.id}): $error');
          }
        }
      }

      slides.add(
        AppIntroSlide(
          id: feature.id,
          title: feature.title,
          description: feature.description,
          imagePath: await file.exists() ? file.path : null,
        ),
      );

      completed += 1;
      _progressController.add(completed);
    }

    _cachedSlides = slides;
    return slides;
  }

  Future<Directory> _resolveDirectory() async {
    if (_cacheDirectory != null) {
      return _cacheDirectory!;
    }

    final baseDir = await getApplicationSupportDirectory();
    final introDir = Directory(p.join(baseDir.path, 'app_intro'));
    if (!await introDir.exists()) {
      await introDir.create(recursive: true);
    }

    _cacheDirectory = introDir;
    return introDir;
  }
}
