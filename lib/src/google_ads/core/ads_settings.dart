import 'package:flutter/foundation.dart';

import '../../../flutter_monetization_kit.dart';

class AdsSettings {
  // Private constructor
  AdsSettings._();
  static final AdsSettings instance = AdsSettings._();

  /// Whether the user has purchased premium.
  /// If true, all ad requests should be blocked.
  bool isPremium = false;

  // Specific toggles
  bool enableAppOpen = true;
  bool enableAppOpenOnResume = true;
  bool enableBannerAds = true;
  bool enableInterstitialAds = true;
  bool enableRewardedAds = true;
  bool enableNativeAds = true;

  // Global Interstitial interval (to avoid annoying users)
  Duration interstitialInterval = const Duration(seconds: 45);

  /// Max number of interstitials per session/section (optional)
  /// If null, there is no limit.
  int? interstitialMaxCountInSection;

  /// Current count of interstitials shown in this session/section
  int _interstitialCurrentCountInSection = 0;
  int get interstitialCurrentCountInSection =>
      _interstitialCurrentCountInSection;

  /// Enable or disable logs for debugging
  bool isDebugMode = kDebugMode;

  /// The last time an interstitial was shown (for interval check)
  DateTime? _lastInterstitialShowTime;

  /// Set the premium status directly
  void setPremium(bool status) {
    isPremium = status;
    if (status) {
      // Logic to clear existing ads from memory if user just bought premium
      if (isDebugMode) {
        print("AdsSettings: Premium enabled. Ads will be disabled.");
      }
    }
  }
  
  /// Set the app open on resume status directly
  void setAppOpenOnResume(bool status) {
    enableAppOpenOnResume = status;
    if (isDebugMode) {
      print("AdsSettings: App Open on Resume ${status ? 'enabled' : 'disabled'}.");
    }
  }

  /// Increment the interstitial count
  void incrementInterstitialCount() {
    _interstitialCurrentCountInSection++;
    _lastInterstitialShowTime = DateTime.now();
  }

  /// Reset the interstitial count (e.g., when moving to a new section if needed)
  void resetInterstitialCount() {
    _interstitialCurrentCountInSection = 0;
  }

  /// Check if an interstitial can be shown based on premium status,
  /// toggle, and max count limit.
  /// Returns null if OK, or a reason if blocked.
  AdValidationReason? validateInterstitialShow() {
    if (isPremium) return AdValidationReason.userIsPremium;
    if (!enableInterstitialAds) return AdValidationReason.adDisabled;

    // 1. Max Count Check
    if (interstitialMaxCountInSection != null &&
        _interstitialCurrentCountInSection >= interstitialMaxCountInSection!) {
      return AdValidationReason.maxCountReached;
    }

    // 2. Interval Check
    if (_lastInterstitialShowTime != null) {
      final difference = DateTime.now().difference(_lastInterstitialShowTime!);
      if (difference < interstitialInterval) {
        return AdValidationReason.iIntervalNotReached;
      }
    }

    return null;
  }

  /// Check if a rewarded ad can be shown based on premium status
  /// and toggle. (Rewarded ads do not have interval or max count limits)
  AdValidationReason? validateRewardedShow() {
    if (isPremium) return AdValidationReason.userIsPremium;
    if (!enableRewardedAds) return AdValidationReason.adDisabled;
    return null;
  }

  /// Check if an app open ad can be shown based on premium status
  /// and toggle.
  AdValidationReason? validateAppOpenShow() {
    if (isPremium) return AdValidationReason.userIsPremium;
    if (!enableAppOpen) return AdValidationReason.adDisabled;
    return null;
  }
}
