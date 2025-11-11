import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 광고 서비스
/// 리워드 광고를 관리하고 보상을 처리합니다
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  /// 광고 SDK 초기화
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// 리워드 광고 ID 가져오기
  String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      // 테스트 광고 ID (실제 배포 시 변경 필요)
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      // 테스트 광고 ID (실제 배포 시 변경 필요)
      return 'ca-app-pub-3940256099942544/1712485313';
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

  /// 리워드 광고 표시
  /// [onRewarded] 광고 시청 완료 시 호출되는 콜백 (보상 처리)
  /// [onFailed] 광고 표시 실패 시 호출되는 콜백
  Future<void> showRewardedAd({
    required void Function(int amount) onRewarded,
    required void Function() onFailed,
  }) async {
    if (_rewardedAd == null || !_isRewardedAdReady) {
      onFailed();
      return;
    }

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        // 광고 시청 완료 - 보상 지급
        onRewarded(reward.amount.toInt());
      },
    );
  }

  /// 광고 사용 가능 여부
  bool get isRewardedAdReady => _isRewardedAdReady;

  /// 리소스 정리
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdReady = false;
  }
}
