import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/enums/ad_validation_reason.dart';

class BannerAdCallbacks {
  /// Triggered if the package blocks the banner (e.g. User is Premium)
  final Function(AdValidationReason reason)? onAdValidated;

  /// Triggered when the banner is successfully fetched
  final Function(Ad ad)? onAdLoaded;

  /// Triggered if AdMob fails to return an ad
  final Function(Ad ad, LoadAdError error)? onAdFailedToLoad;

  /// Triggered when the user taps the banner
  final Function(Ad ad)? onAdClicked;

  /// Triggered when the banner opens an overlay (e.g. browser)
  final Function(Ad ad)? onAdOpened;

  /// Triggered when the user returns to the app
  final Function(Ad ad)? onAdClosed;

  /// Triggered when the ad is about to dismiss the overlay
  final Function(Ad ad)? onAdWillDismissScreen;

  /// Triggered when an impression is recorded for the ad
  final Function(Ad ad)? onAdImpression;

  /// Triggered when the ad records a paid event
  final void Function(
    Ad ad,
    double valueMicros,
    PrecisionType precision,
    String currencyCode,
  )?
  onPaidEvent;

  const BannerAdCallbacks({
    this.onAdValidated,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
    this.onAdOpened,
    this.onAdClosed,
    this.onAdWillDismissScreen,
    this.onAdImpression,
    this.onPaidEvent,
  });
}
