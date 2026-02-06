import 'package:flutter/foundation.dart';

class AdsSettings {
  // Private constructor
  AdsSettings._();
  static final AdsSettings instance = AdsSettings._();

  /// Whether the user has purchased premium.
  /// If true, all ad requests should be blocked.
  bool isPremium = false;

  // Specific toggles
  bool enableAppOpen = true;
  bool enableBannerAds = true;

  // Global Interstitial interval (to avoid annoying users)
  Duration interstitialInterval = const Duration(seconds: 45);

  /// Enable or disable logs for debugging
  bool isDebugMode = kDebugMode;

  /// Set the premium status directly
  void setPremium(bool status) {
    isPremium = status;
    if (status) {
      // Logic to clear existing ads from memory if user just bought premium
      print("AdsSettings: Premium enabled. Ads will be disabled.");
    }
  }
}