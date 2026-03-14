import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/enums/ad_validation_reason.dart';

class InterstitialAdCallbacks {
  /// Triggered when the package blocks an ad request (Internet, Premium, etc.)
  final Function(AdValidationReason reason)? onAdValidated;

  final Function(InterstitialAd ad)? onAdLoaded;
  final Function(LoadAdError error)? onAdFailedToLoad;
  final Function(InterstitialAd ad)? onAdShowedFullScreenContent;
  final Function(InterstitialAd ad)? onAdDismissedFullScreenContent;
  final Function(InterstitialAd ad, AdError error)?
  onAdFailedToShowFullScreenContent;
  final Function(InterstitialAd ad)? onAdClicked;

  const InterstitialAdCallbacks({
    this.onAdValidated,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdShowedFullScreenContent,
    this.onAdDismissedFullScreenContent,
    this.onAdFailedToShowFullScreenContent,
    this.onAdClicked,
  });
}
