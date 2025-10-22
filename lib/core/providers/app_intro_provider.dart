import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_intro_service.dart';

final appIntroSlidesProvider = FutureProvider<List<AppIntroSlide>>((ref) async {
  return AppIntroService.instance.loadSlides();
});

final appIntroProgressProvider = StreamProvider<int>((ref) {
  return AppIntroService.instance.progressStream;
});
