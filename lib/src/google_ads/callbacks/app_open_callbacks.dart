import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/enums/ad_validation_reason.dart';

class AppOpenAdCallbacks {
  final Function(AdValidationReason reason)? onAdValidated;
  final Function(AppOpenAd ad)? onAdLoaded;
  final Function(LoadAdError error)? onAdFailedToLoad;

  // Show Listeners
  final Function(AppOpenAd ad)? onAdShowedFullScreenContent;
  final Function(AppOpenAd ad)? onAdDismissedFullScreenContent;
  final Function(AppOpenAd ad, AdError error)? onAdFailedToShowFullScreenContent;

  const AppOpenAdCallbacks({
    this.onAdValidated,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdShowedFullScreenContent,
    this.onAdDismissedFullScreenContent,
    this.onAdFailedToShowFullScreenContent,
  });
}