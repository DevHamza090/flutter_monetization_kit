import 'package:flutter_monetization_kit/src/google_ads/core/ads_settings.dart';

class EasyAds {
  EasyAds._();
  static final EasyAds instance = EasyAds._();

  /// Initialize the package and global settings
  void initialize({
    bool isPremium = false,
    bool isDebug = true,
  }) {
    AdsSettings.instance.isPremium = isPremium;
    AdsSettings.instance.isDebugMode = isDebug;

    // Initialize Google Mobile Ads SDK here
    // MobileAds.instance.initialize();
  }

  void setPremium(bool status) => AdsSettings.instance.setPremium(status);
}