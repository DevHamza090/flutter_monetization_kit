import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/enums/ad_validation_reason.dart';

class RewardedInterAdCallbacks {
  /// Triggered when the package blocks an ad request (Internet, Premium, etc.)
  final Function(AdValidationReason reason)? onAdValidated;
  final Function(RewardedInterstitialAd ad)? onAdLoaded;
  final Function(LoadAdError error)? onAdFailedToLoad;

  // Show Listeners
  final Function(RewardedInterstitialAd ad, RewardItem reward)? onUserEarnedReward;
  final Function(RewardedInterstitialAd ad)? onAdShowedFullScreenContent;
  final Function(RewardedInterstitialAd ad)? onAdDismissedFullScreenContent;
  final Function(RewardedInterstitialAd ad, AdError error)? onAdFailedToShowFullScreenContent;

  const RewardedInterAdCallbacks({
    this.onAdValidated,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onUserEarnedReward,
    this.onAdShowedFullScreenContent,
    this.onAdDismissedFullScreenContent,
    this.onAdFailedToShowFullScreenContent,
  });
}