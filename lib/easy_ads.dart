import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_monetization_kit/src/google_ads/core/ads_settings.dart';
import 'package:flutter_monetization_kit/src/shared_preferences/share_pref_helper.dart';

export 'src/google_ads/widgets/banner_widget.dart';
export 'src/google_ads/core/enums/banner_type.dart';
export 'src/google_ads/core/enums/ad_type.dart';
export 'src/google_ads/core/enums/ad_validation_reason.dart';
export 'src/google_ads/core/enums/native_type.dart';
export 'src/google_ads/core/ads_utils.dart';
export 'src/google_ads/core/ads_registry.dart';
export 'src/google_ads/core/ads_settings.dart';
export 'src/google_ads/callbacks/banner_ad_callbacks.dart';
export 'src/google_ads/callbacks/interstitial_ad_callbacks.dart';
export 'src/google_ads/callbacks/rewarded_ad_callbacks.dart';
export 'src/google_ads/callbacks/rewarded_inter_ad_callbacks.dart';
export 'src/google_ads/managers/banner_ad_manager.dart';
export 'src/google_ads/managers/interstitial_ad_manager.dart';
export 'src/google_ads/managers/rewarded_ad_manager.dart';
export 'src/google_ads/managers/rewarded_inter_ad_manager.dart';
export 'src/google_ads/managers/app_open_manager.dart';
export 'src/google_ads/callbacks/app_open_callbacks.dart';
export 'src/google_ads/widgets/native_widget.dart';
export 'src/google_ads/managers/native_ad_manager.dart';
export 'src/google_ads/core/native_ad_style.dart';
export 'src/google_ads/callbacks/native_ad_callbacks.dart';
export 'src/google_ads/core/app_open_observer.dart';

class EasyAds {
  EasyAds._();
  static final EasyAds instance = EasyAds._();

  /// Global navigator key to access context globally (e.g., for full-screen ad overlays)
  GlobalKey<NavigatorState>? navigatorKey;

  /// Initialize the package and global settings
  Future<void> initialize({
    bool? isPremium,
    bool isDebug = true,
    int? interstitialMaxCountInSection,
    Duration? interstitialInterval,
    bool enableAppOpen = true,
    bool enableBannerAds = true,
    bool enableInterstitialAds = true,
    bool enableRewardedAds = true,
    bool enableNativeAds = true,
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    this.navigatorKey = navigatorKey;
    // Priority: parameter if provided, else SharedPrefHelper, else default (false)
    final bool initialPremium = isPremium ?? SharedPrefHelper().isPremium();

    AdsSettings.instance.isPremium = initialPremium;
    AdsSettings.instance.isDebugMode = isDebug;
    AdsSettings.instance.interstitialMaxCountInSection =
        interstitialMaxCountInSection;

    if (interstitialInterval != null) {
      AdsSettings.instance.interstitialInterval = interstitialInterval;
    }

    AdsSettings.instance.enableAppOpen = enableAppOpen;
    AdsSettings.instance.enableBannerAds = enableBannerAds;
    AdsSettings.instance.enableInterstitialAds = enableInterstitialAds;
    AdsSettings.instance.enableRewardedAds = enableRewardedAds;
    AdsSettings.instance.enableNativeAds = enableNativeAds;

    // Initialize Google Mobile Ads SDK here
    await MobileAds.instance.initialize();
  }

  Future<void> setPremium(bool status) async {
    AdsSettings.instance.setPremium(status);
    await SharedPrefHelper().setPremium(status);
  }
}
