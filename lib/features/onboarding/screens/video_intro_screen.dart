import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/app_constants.dart';
import '../../settings/services/preferences_service.dart';

/// 비디오 인트로 화면
/// 앱 첫 실행 시 assets/Intro/Intro.mp4 비디오를 재생합니다.
class VideoIntroScreen extends ConsumerStatefulWidget {
  const VideoIntroScreen({super.key});

  static const String introWatchedKey = 'video_intro_watched';
  static const String dontShowAgainKey = 'video_intro_dont_show_again';

  /// 비디오 인트로를 보여줘야 하는지 확인
  static Future<bool> shouldShowIntro() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dontShowAgain = prefs.getBool(dontShowAgainKey) ?? false;

      // 앱 설정에서 인트로 영상 표시 여부 확인
      final prefsService = PreferencesService();
      final settings = await prefsService.loadSettings();
      final showIntroVideoSetting = settings.showIntroVideo;

      debugPrint('🎬 [VideoIntro] shouldShowIntro: dontShowAgain=$dontShowAgain, showIntroVideoSetting=$showIntroVideoSetting');

      // "다시 보지 않기"를 선택한 경우 표시하지 않음
      if (dontShowAgain) {
        return false;
      }

      // 설정에 따라 표시 여부 결정 (ON이면 매번 표시)
      return showIntroVideoSetting;
    } catch (e) {
      debugPrint('🎬 [VideoIntro] shouldShowIntro 오류: $e');
      return false;
    }
  }

  /// 시청 기록 초기화 (설정에서 다시 보기 활성화 시 호출)
  static Future<void> resetWatchedStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(introWatchedKey, false);
      await prefs.setBool(dontShowAgainKey, false);
      debugPrint('🎬 [VideoIntro] 시청 기록 초기화됨');
    } catch (e) {
      debugPrint('🎬 [VideoIntro] 시청 기록 초기화 오류: $e');
    }
  }

  /// 시청 완료 표시
  static Future<void> markAsWatched() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(introWatchedKey, true);
      debugPrint('🎬 [VideoIntro] 시청 완료 저장됨');
    } catch (e) {
      debugPrint('🎬 [VideoIntro] 저장 오류: $e');
    }
  }

  /// 다시 보지 않기 설정
  static Future<void> setDontShowAgain() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(dontShowAgainKey, true);
      await prefs.setBool(introWatchedKey, true);
      debugPrint('🎬 [VideoIntro] 다시 보지 않기 설정됨');
    } catch (e) {
      debugPrint('🎬 [VideoIntro] 다시 보지 않기 저장 오류: $e');
    }
  }

  @override
  ConsumerState<VideoIntroScreen> createState() => _VideoIntroScreenState();
}

class _VideoIntroScreenState extends ConsumerState<VideoIntroScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showButtons = false;
  bool _isNavigating = false;
  bool _shouldSkipImmediately = false;
  Timer? _loadingTimeoutTimer;
  Timer? _maxDurationTimer;

  static const Duration _loadingTimeout = Duration(seconds: 8);
  static const Duration _maxVideoDuration = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    debugPrint('🎬 [VideoIntro] initState 호출됨');
    _checkAndInitialize();
  }

  Future<void> _checkAndInitialize() async {
    debugPrint('🎬 [VideoIntro] _checkAndInitialize 시작');

    // 이미 시청했거나 다시 보지 않기 설정된 경우 즉시 스킵
    final shouldShow = await VideoIntroScreen.shouldShowIntro();
    debugPrint('🎬 [VideoIntro] shouldShow=$shouldShow');

    if (!shouldShow) {
      debugPrint('🎬 [VideoIntro] 이미 시청함/다시보지않기 - 즉시 다음 화면으로');
      if (mounted) {
        setState(() => _shouldSkipImmediately = true);
        _navigateToNextScreen(markWatched: false);
      }
      return;
    }

    // 비디오 초기화 시작
    _initializeVideo();

    // 로딩 타임아웃 설정 (3초)
    _loadingTimeoutTimer = Timer(_loadingTimeout, () {
      if (mounted && !_isInitialized && !_isNavigating) {
        debugPrint('🎬 [VideoIntro] 로딩 타임아웃 (3초) - 자동 스킵');
        _navigateToNextScreen(markWatched: true);
      }
    });

    // 최대 재생 시간 타임아웃 (15초)
    _maxDurationTimer = Timer(_maxVideoDuration, () {
      if (mounted && !_isNavigating) {
        debugPrint('🎬 [VideoIntro] 최대 시간 초과 (15초) - 자동 스킵');
        _navigateToNextScreen(markWatched: true);
      }
    });

    // 버튼 즉시 표시
    if (mounted) {
      setState(() => _showButtons = true);
    }
  }

  Future<void> _initializeVideo() async {
    try {
      debugPrint('🎬 [VideoIntro] 비디오 초기화 시작');
      _controller = VideoPlayerController.asset('assets/Intro/Intro.mp4');

      await _controller!.initialize();
      debugPrint('🎬 [VideoIntro] 비디오 초기화 완료: duration=${_controller!.value.duration}');

      _loadingTimeoutTimer?.cancel();
      _controller!.addListener(_videoListener);

      if (mounted && !_isNavigating) {
        setState(() => _isInitialized = true);
        await _controller!.play();
        debugPrint('🎬 [VideoIntro] 비디오 재생 시작');
      }
    } catch (e) {
      debugPrint('🎬 [VideoIntro] 비디오 초기화 오류: $e');
      _loadingTimeoutTimer?.cancel();
      if (mounted && !_isNavigating) {
        setState(() => _hasError = true);
        _navigateToNextScreen(markWatched: true);
      }
    }
  }

  void _videoListener() {
    if (_isNavigating || _controller == null) return;

    final position = _controller!.value.position;
    final duration = _controller!.value.duration;

    if (duration > Duration.zero && position >= duration) {
      debugPrint('🎬 [VideoIntro] 비디오 재생 완료');
      _navigateToNextScreen(markWatched: true);
    }
  }

  Future<void> _navigateToNextScreen({required bool markWatched}) async {
    if (_isNavigating) return;
    _isNavigating = true;
    debugPrint('🎬 [VideoIntro] 다음 화면으로 이동 (markWatched=$markWatched)');

    _loadingTimeoutTimer?.cancel();
    _maxDurationTimer?.cancel();
    _controller?.pause();

    if (markWatched) {
      await VideoIntroScreen.markAsWatched();
    }

    if (!mounted) return;

    // 온보딩 완료 여부 확인하여 적절한 화면으로 이동
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('app_profile.onboarding_complete') ?? false;

    if (onboardingComplete) {
      context.go(AppConstants.homeRoute);
    } else {
      context.go(AppConstants.introRoute);
    }
  }

  void _onSkip() {
    debugPrint('🎬 [VideoIntro] 스킵 버튼 클릭');
    _navigateToNextScreen(markWatched: true);
  }

  void _onDontShowAgain() async {
    debugPrint('🎬 [VideoIntro] 다시 보지 않기 클릭');
    await VideoIntroScreen.setDontShowAgain();
    _navigateToNextScreen(markWatched: false);
  }

  @override
  void dispose() {
    _loadingTimeoutTimer?.cancel();
    _maxDurationTimer?.cancel();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 즉시 스킵해야 하는 경우 빈 화면 최소화
    if (_shouldSkipImmediately) {
      return const SizedBox.shrink();
    }

    // 전체 화면 모드 설정
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 비디오 플레이어
          if (_isInitialized && _controller != null)
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            )
          else if (!_hasError)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // 하단 버튼들
          if (_showButtons)
            Positioned(
              bottom: 48,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 다시 보지 않기 버튼
                  TextButton.icon(
                    onPressed: _onDontShowAgain,
                    icon: const Icon(Icons.visibility_off, color: Colors.white54, size: 18),
                    label: const Text(
                      '다시 보지 않기',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black26,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  // 스킵 버튼
                  TextButton.icon(
                    onPressed: _onSkip,
                    icon: const Icon(Icons.skip_next, color: Colors.white70, size: 20),
                    label: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black38,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 비디오 인트로 시청 여부를 확인하는 프로바이더
final videoIntroWatchedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(VideoIntroScreen.introWatchedKey) ?? false;
});
