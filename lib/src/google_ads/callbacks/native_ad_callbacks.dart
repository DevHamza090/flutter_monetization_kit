import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/enums/ad_validation_reason.dart';

class NativeAdCallbacks {
  /// Triggered if the package blocks the native ad (e.g. No Internet)
  final Function(AdValidationReason reason)? onAdValidated;

  /// Triggered when the native ad assets (image, text) are ready
  final Function(String adUnitId)? onAdLoaded;

  /// Triggered if the native ad fails to load
  final Function(String adUnitId, LoadAdError error)? onAdFailedToLoad;

  /// Triggered when the user taps any part of the native ad
  final Function(String adUnitId)? onAdClicked;

  /// Triggered when the ad opens a full-screen overlay
  final Function(String adUnitId)? onAdOpened;

  /// Triggered when the user closes the ad overlay
  final Function(String adUnitId)? onAdClosed;

  /// Triggered when the ad is actually visible on the screen
  final Function(String adUnitId)? onAdImpression;

  const NativeAdCallbacks({
    this.onAdValidated,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
    this.onAdOpened,
    this.onAdClosed,
    this.onAdImpression,
  });
}