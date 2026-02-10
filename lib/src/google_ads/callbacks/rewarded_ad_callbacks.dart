import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/enums/ad_validation_reason.dart';

class RewardedAdCallbacks {
  /// Triggered when the package blocks an ad request (Internet, Premium, etc.)
  final Function(AdValidationReason reason)? onAdValidated;
  final Function(RewardedAd ad)? onAdLoaded;
  final Function(LoadAdError error)? onAdFailedToLoad;

  // Show Listeners
  final Function(RewardedAd ad, RewardItem reward)? onUserEarnedReward;
  final Function(RewardedAd ad)? onAdShowedFullScreenContent;
  final Function(RewardedAd ad)? onAdDismissedFullScreenContent;
  final Function(RewardedAd ad, AdError error)? onAdFailedToShowFullScreenContent;
  final Function(RewardedAd ad)? onAdClicked;

  const RewardedAdCallbacks({
    this.onAdValidated,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onUserEarnedReward,
    this.onAdShowedFullScreenContent,
    this.onAdDismissedFullScreenContent,
    this.onAdFailedToShowFullScreenContent,
    this.onAdClicked,
  });
}