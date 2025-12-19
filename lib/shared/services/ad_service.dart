import 'dart:async';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 광고 서비스
/// 리워드 광고, 배너 광고, 전면 광고를 관리합니다
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  /// 광고 SDK 초기화
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    // 전면 광고 미리 로드
    loadInterstitialAd();
  }

  /// 리워드 광고 ID 가져오기 (횟수 0일 때 터치하는 광고)
  String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      // Lite 앱 보상형 광고 단위 ID
      return 'ca-app-pub-3638466356421889/9830495815';
    } else if (Platform.isIOS) {
      // iOS는 아직 미설정 (테스트 ID)
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return '';
  }

  /// 전면 광고 ID 가져오기
  String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      // 테스트 ID (실제 ID로 교체 필요)
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      // iOS 테스트 ID
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }

  /// 배너 광고 ID 가져오기
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // 테스트 ID (실제 ID로 교체 필요)
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      // iOS 테스트 ID
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  /// 네이티브 광고 ID 가져오기 (내 일기 페이지 3개당)
  String get nativeAdUnitId {
    if (Platform.isAndroid) {
      // Lite 앱 네이티브 광고 단위 ID
      return 'ca-app-pub-3638466356421889/7204332472';
    } else if (Platform.isIOS) {
      // iOS는 아직 미설정 (테스트 ID)
      return 'ca-app-pub-3940256099942544/3986624511';
    }
    return '';
  }

  /// 리워드 광고 로드
  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;

          // 광고 이벤트 리스너 설정
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {},
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdReady = false;
              // 다음 광고 미리 로드
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdReady = false;
              // 다음 광고 미리 로드
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  /// 리워드 광고 표시 (Future 반환)
  /// 광고 시청 완료 시 true, 실패/취소 시 false 반환
  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null || !_isRewardedAdReady) {
      return false;
    }

    final completer = Completer<bool>();
    bool rewarded = false;

    // 광고 표시 전에 콜백 설정
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        // 광고가 화면에 표시됨
      },
      onAdDismissedFullScreenContent: (ad) {
        // 광고가 닫힘 - 결과 반환
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdReady = false;
        // 다음 광고 미리 로드
        loadRewardedAd();
        // 보상 여부 반환
        if (!completer.isCompleted) {
          completer.complete(rewarded);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        // 광고 표시 실패
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdReady = false;
        // 다음 광고 미리 로드
        loadRewardedAd();
        // 실패 반환
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        // 광고 시청 완료 - 보상 지급
        rewarded = true;
      },
    );

    return completer.future;
  }

  /// 전면 광고 로드
  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              // 다음 광고 미리 로드
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              // 다음 광고 미리 로드
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          // 실패 시 재시도
          Future.delayed(const Duration(seconds: 30), loadInterstitialAd);
        },
      ),
    );
  }

  /// 전면 광고 표시
  Future<void> showInterstitialAd() async {
    if (_interstitialAd != null && _isInterstitialAdReady) {
      await _interstitialAd!.show();
    }
  }

  /// 광고 사용 가능 여부
  bool get isRewardedAdReady => _isRewardedAdReady;

  /// 광고 사용 가능 여부
  bool get isInterstitialAdReady => _isInterstitialAdReady;

  /// 리소스 정리
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdReady = false;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }
}
