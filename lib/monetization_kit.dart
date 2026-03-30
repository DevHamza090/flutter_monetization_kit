import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_monetization_kit/src/google_ads/core/ads_settings.dart';
import 'package:flutter_monetization_kit/src/shared_preferences/share_pref_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'src/google_ads/consent_message/google_consent_manager.dart';
import 'src/google_ads/managers/app_open_manager.dart';
import 'src/google_ads/managers/banner_ad_manager.dart';
import 'src/google_ads/managers/interstitial_ad_manager.dart';
import 'src/google_ads/managers/native_ad_manager.dart' show NativeAdManager;
import 'src/google_ads/managers/rewarded_ad_manager.dart';
import 'src/google_ads/managers/rewarded_inter_ad_manager.dart';

export 'src/app_tracking_transparency/app_tracking_status.dart';
export 'src/app_tracking_transparency/app_tracking_transparency.dart';
export 'src/google_ads/callbacks/app_open_callbacks.dart';
export 'src/google_ads/callbacks/banner_ad_callbacks.dart';
export 'src/google_ads/callbacks/interstitial_ad_callbacks.dart';
export 'src/google_ads/callbacks/native_ad_callbacks.dart';
export 'src/google_ads/callbacks/rewarded_ad_callbacks.dart';
export 'src/google_ads/callbacks/rewarded_inter_ad_callbacks.dart';
export 'src/google_ads/consent_message/google_consent_manager.dart';
export 'src/google_ads/core/ads_registry.dart';
export 'src/google_ads/core/ads_settings.dart';
export 'src/google_ads/core/ads_utils.dart';
export 'src/google_ads/core/app_open_observer.dart';
export 'src/google_ads/core/enums/ad_type.dart';
export 'src/google_ads/core/enums/ad_validation_reason.dart';
export 'src/google_ads/core/enums/banner_type.dart';
export 'src/google_ads/core/enums/native_type.dart';
export 'src/google_ads/core/native_ad_style.dart';
export 'src/google_ads/widgets/banner_widget.dart';
export 'src/google_ads/widgets/native_widget.dart';

class MonetizationKit {
  MonetizationKit._();

  static final MonetizationKit instance = MonetizationKit._();

  /// Access Point for Interstitial Ads
  InterstitialAdManager get interstitial => InterstitialAdManager.instance;

  /// Access Point for Rewarded Ads
  RewardedAdManager get rewarded => RewardedAdManager.instance;

  /// Access Point for Rewarded Interstitial Ads
  RewardedInterstitialAdManager get rewardedInterstitial => RewardedInterstitialAdManager.instance;

  /// Access Point for App Open Ads
  AppOpenManager get appOpen => AppOpenManager.instance;

  /// Access Point for Banner Ads
  BannerAdManager get banner => BannerAdManager.instance;

  /// Access Point for Native Ads
  NativeAdManager get native => NativeAdManager.instance;

  /// Access Point for Google Consent Manager
  GoogleConsentManager get consentManager => GoogleConsentManager.instance;

  /// Global navigator key to access context globally (e.g., for full-screen ad overlays)
  GlobalKey<NavigatorState>? navigatorKey;

  /// Check if the user is currently flagged as premium
  bool get isPremium => AdsSettings.instance.isPremium;

  /// Initialize the package and global settings
  Future<void> initialize({
    bool? isPremium,
    bool isDebug = kDebugMode ? true : false,
    int? interstitialMaxCountInSection,
    Duration? interstitialInterval,
    bool enableAppOpen = true,
    bool enableBannerAds = true,
    bool enableInterstitialAds = true,
    bool enableRewardedAds = true,
    bool enableNativeAds = true,
    bool enableAppOpenOnResume = true,
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    this.navigatorKey = navigatorKey;
    // Priority: parameter if provided, else SharedPrefHelper, else default (false)
    final bool initialPremium = isPremium ?? SharedPrefHelper().isPremium();

    AdsSettings.instance.isPremium = initialPremium;
    AdsSettings.instance.isDebugMode = isDebug;
    AdsSettings.instance.interstitialMaxCountInSection = interstitialMaxCountInSection;

    if (interstitialInterval != null) {
      AdsSettings.instance.interstitialInterval = interstitialInterval;
    }

    AdsSettings.instance.enableAppOpen = enableAppOpen;
    AdsSettings.instance.enableBannerAds = enableBannerAds;
    AdsSettings.instance.enableInterstitialAds = enableInterstitialAds;
    AdsSettings.instance.enableRewardedAds = enableRewardedAds;
    AdsSettings.instance.enableNativeAds = enableNativeAds;
    AdsSettings.instance.enableAppOpenOnResume = enableAppOpenOnResume;

    // Initialize Google Mobile Ads SDK here
    await MobileAds.instance.initialize();
  }

  Future<void> setPremium(bool status) async {
    AdsSettings.instance.setPremium(status);
    await SharedPrefHelper().setPremium(status);
  }

  void setAppOpenOnResume(bool status) {
    AdsSettings.instance.setAppOpenOnResume(status);
  }
}
