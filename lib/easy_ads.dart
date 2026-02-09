import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_monetization_kit/src/google_ads/core/ads_settings.dart';
import 'package:flutter_monetization_kit/src/shared_preferences/share_pref_helper.dart';

export 'src/google_ads/widgets/banner_widget.dart';
export 'src/google_ads/core/enums/banner_type.dart';
export 'src/google_ads/core/enums/ad_type.dart';
export 'src/google_ads/core/enums/ad_validation_reason.dart';
export 'src/google_ads/core/ads_utils.dart';
export 'src/google_ads/core/ads_settings.dart';
export 'src/google_ads/callbacks/banner_ad_callbacks.dart';
export 'src/google_ads/callbacks/interstitial_ad_callbacks.dart';
export 'src/google_ads/managers/banner_ad_manager.dart';
export 'src/google_ads/managers/interstitial_ad_manager.dart';

class EasyAds {
  EasyAds._();
  static final EasyAds instance = EasyAds._();

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
  }) async {
    // Priority: parameter if provided, else SharedPrefHelper, else default (false)
    final bool initialPremium =
        isPremium ?? SharedPrefHelper().isPremium();

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