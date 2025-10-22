import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_intro_provider.dart';
import '../../../core/services/app_intro_service.dart';

class AppIntroSection extends ConsumerStatefulWidget {
  const AppIntroSection({super.key});

  @override
  ConsumerState<AppIntroSection> createState() => _AppIntroSectionState();
}

class _AppIntroSectionState extends ConsumerState<AppIntroSection> {
  Timer? _autoSlideTimer;
  int _currentIndex = 0;
  List<AppIntroSlide> _slides = const [];
  ProviderSubscription<AsyncValue<List<AppIntroSlide>>>? _slidesSubscription;
  late final PageController _pageController;
  ProviderSubscription<AsyncValue<int>>? _progressSubscription;
  int _completedSegments = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final initialValue = ref.read(appIntroSlidesProvider);
    initialValue.whenData(_setSlides);

    _slidesSubscription = ref.listenManual<AsyncValue<List<AppIntroSlide>>>(
      appIntroSlidesProvider,
      (previous, next) {
        next.whenData(_setSlides);
      },
    );

    final initialProgress = ref.read(appIntroProgressProvider);
    initialProgress.whenData(_updateProgress);
    _progressSubscription = ref.listenManual<AsyncValue<int>>(
      appIntroProgressProvider,
      (previous, next) {
        next.whenData(_updateProgress);
      },
    );
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _slidesSubscription?.close();
    _progressSubscription?.close();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slidesAsync = ref.watch(appIntroSlidesProvider);
    final isLoading = slidesAsync.isLoading;
    final totalSteps = AppIntroService.instance.totalSteps;
    final showProgress = isLoading || _completedSegments < totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('앱 소개', style: theme.textTheme.titleMedium),
            const Spacer(),
            if (showProgress) ...[
              Text('앱 소개 이미지를 생성하는 중', style: theme.textTheme.bodySmall),
              const SizedBox(width: 12),
              _SegmentedProgressBar(
                totalSegments: totalSteps,
                completedSegments: _completedSegments,
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 220,
              child: slidesAsync.when(
                data: (_) => _buildCarousel(context),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _buildFallback(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel(BuildContext context) {
    if (_slides.isEmpty) {
      return _buildFallback(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final slide = _slides[index % _slides.length];
                return _IntroSlideView(slide: slide);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        _IntroIndicator(
          length: _slides.length,
          currentIndex: _currentIndex % _slides.length,
        ),
      ],
    );
  }

  Widget _buildFallback(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EveryDiary 주요 기능',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'OCR · 음성 녹음 · 감정 분석 · AI 이미지 · 백업 관리 · PIN 보안 · 화면 숨김',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setSlides(List<AppIntroSlide> slides) {
    if (!mounted) return;
    _autoSlideTimer?.cancel();
    setState(() {
      _slides = List<AppIntroSlide>.from(slides);
      _currentIndex = 0;
    });

    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }

    if (_slides.length > 1) {
      _autoSlideTimer = Timer.periodic(const Duration(seconds: 6), (_) {
        if (!mounted) return;
        if (_pageController.hasClients) {
          final nextPage = (_currentIndex + 1) % _slides.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _updateProgress(int value) {
    final total = AppIntroService.instance.totalSteps;
    setState(() {
      _completedSegments = value.clamp(0, total);
    });
  }
}

class _IntroSlideView extends StatelessWidget {
  const _IntroSlideView({super.key, required this.slide});

  final AppIntroSlide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (slide.imagePath != null)
          Image.file(
            File(slide.imagePath!),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackBackground(theme),
          )
        else
          _fallbackBackground(theme),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.6),
                Colors.black.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  slide.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallbackBackground(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.3),
            theme.colorScheme.secondary.withValues(alpha: 0.3),
          ],
        ),
      ),
    );
  }
}

class _IntroIndicator extends StatelessWidget {
  const _IntroIndicator({required this.length, required this.currentIndex});

  final int length;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    if (length <= 1) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}

class _SegmentedProgressBar extends StatelessWidget {
  const _SegmentedProgressBar({
    required this.totalSegments,
    required this.completedSegments,
  });

  final int totalSegments;
  final int completedSegments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 140,
      height: 8,
      child: Row(
        children: List.generate(totalSegments, (index) {
          final isFilled = index < completedSegments;
          return Expanded(
            child: TweenAnimationBuilder<double>(
              key: ValueKey<int>(index * 10 + (isFilled ? 1 : 0)),
              tween: Tween<double>(begin: 0, end: isFilled ? 1 : 0),
              duration: const Duration(milliseconds: 450),
              curve: isFilled ? Curves.elasticOut : Curves.easeInOut,
              builder: (context, value, child) {
                final translateY = -10 * value;
                final scale = 0.9 + (0.15 * value);
                return Transform.translate(
                  offset: Offset(0, translateY),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isFilled
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
