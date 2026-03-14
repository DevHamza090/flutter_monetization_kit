import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_constants.dart';
import 'ads_registry.dart';
import 'ads_settings.dart';
import 'enums/ad_type.dart';
import 'enums/ad_validation_reason.dart';
import 'enums/banner_type.dart';
import 'network_info.dart';

class AdUtils {
  AdUtils._();

  /// The ultimate check: Should we attempt to load or show an ad?
  /// This returns null if we CAN process the ad, or a reason why we CAN'T.
  static Future<AdValidationReason?> validateAdProcess() async {
    // 1. If user is premium, never process ads
    if (AdsSettings.instance.isPremium) {
      return AdValidationReason.userIsPremium;
    }

    // 2. Check internet connection
    final bool hasInternet = await NetworkInfo().isConnected;
    if (!hasInternet) {
      return AdValidationReason.noInternet;
    }
    // 3. Check platform is support
    if (!isSupportedPlatform()) {
      return AdValidationReason.platformNotSupported;
    }

    return null;
  }

  /// Checks if a specific Ad Unit is ready to be shown
  static bool isReady(String adUnitId) {
    return AdRegistry.instance.isAdReady(adUnitId);
  }

  /// Safely converts an error code to a human-readable string
  /// Useful for your `AdConstants.logFailed` calls.
  static String getReadableError(Object error) {
    // You can expand this to handle specific AdMob error codes
    return error.toString();
  }

  /// Utility to handle Platform-specific logic if needed
  /// (e.g., some features might be Android only)
  static bool isSupportedPlatform() {
    return Platform.isAndroid || Platform.isIOS;
  }

  /// --- OFFICIAL ADMOB TEST IDS ---
  /// These are used when the developer is in testing mode.
  static String testId(AdType type) {
    if (Platform.isAndroid) {
      switch (type) {
        case AdType.banner:
          return 'ca-app-pub-3940256099942544/6300978111';
        case AdType.adaptiveBanner:
          return 'ca-app-pub-3940256099942544/9214589741';
        case AdType.interstitial:
          return 'ca-app-pub-3940256099942544/1033173712';
        case AdType.rewarded:
          return 'ca-app-pub-3940256099942544/5224354917';
        case AdType.rewardedInterstitial:
          return 'ca-app-pub-3940256099942544/5354046379';
        case AdType.native:
          return 'ca-app-pub-3940256099942544/2247696110';
        case AdType.nativeVideo:
          return 'ca-app-pub-3940256099942544/1044960115';
        case AdType.appOpen:
          return 'ca-app-pub-3940256099942544/9257395921';
      }
    } else {
      switch (type) {
        case AdType.banner:
          return 'ca-app-pub-3940256099942544/2934735716';
        case AdType.adaptiveBanner:
          return 'ca-app-pub-3940256099942544/2435281174';
        case AdType.interstitial:
          return 'ca-app-pub-3940256099942544/4411468910';
        case AdType.rewarded:
          return 'ca-app-pub-3940256099942544/1712485313';
        case AdType.rewardedInterstitial:
          return 'ca-app-pub-3940256099942544/6978759866';
        case AdType.native:
          return 'ca-app-pub-3940256099942544/3986624511';
        case AdType.nativeVideo:
          return 'ca-app-pub-3940256099942544/2521693316';
        case AdType.appOpen:
          return 'ca-app-pub-3940256099942544/5575463023';
      }
    }
  }

  /// Example: [EasyAds] 🔄 Loading INTERSTITIAL for screen: Dashboard (ID: ca-app-pub...)
  static String logLoading(AdType type, String adUnitId, String? screen) {
    final screenInfo = screen != null ? "for screen: $screen" : "";
    return "${AdConstants.prefix} 🔄 Loading ${type.name.toUpperCase()} $screenInfo (ID: $adUnitId)";
  }

  /// Example: [EasyAds] 🔄 Already Loading INTERSTITIAL for screen: Dashboard (ID: ca-app-pub...)
  static String logAlreadyLoading(
    AdType type,
    String adUnitId,
    String? screen,
  ) {
    final screenInfo = screen != null ? "for screen: $screen" : "";
    return "${AdConstants.prefix} 🔄 Already Loading ${type.name.toUpperCase()} $screenInfo (ID: $adUnitId)";
  }

  /// Example: [EasyAds] ✅ INTERSTITIAL Loaded successfully for screen: Dashboard
  static String logLoaded(AdType type, String? screen) {
    final screenInfo = screen != null ? "for screen: $screen" : "";
    return "${AdConstants.prefix} ✅ ${type.name.toUpperCase()} Loaded successfully $screenInfo";
  }

  /// Example: [EasyAds] ⚠️ INTERSTITIAL Failed to load for screen: Dashboard. Error: No Fill
  static String logFailed(AdType type, String? screen, String error) {
    final screenInfo = screen != null ? "for screen: $screen" : "";
    return "${AdConstants.prefix} ⚠️ ${type.name.toUpperCase()} Failed to load $screenInfo. Error: $error";
  }

  /// Example: [EasyAds] 📺 Showing INTERSTITIAL on screen: Dashboard
  static String logShowing(AdType type, String? screen) {
    final screenInfo = screen != null ? "on screen: $screen" : "";
    return "${AdConstants.prefix} 📺 Showing ${type.name.toUpperCase()} $screenInfo";
  }
}

extension BannerTypeExtension on BannerType {
  /// Converts the package BannerType into Google AdMob's AdSize

  Future<AdSize> getAdSize({double? width, Orientation? orientation}) async {
    return switch (this) {
      StandardBanner() => AdSize.banner,
      LargeBanner() => AdSize.largeBanner,
      RectangleBanner() => AdSize.mediumRectangle,
      AdaptiveBanner() || CollapsibleBanner() =>
        width != null
            ? await AdSize.getAnchoredAdaptiveBannerAdSize(
                    orientation ?? Orientation.portrait,
                    width.truncate(),
                  ) ??
                  AdSize.banner
            : AdSize.banner,
      CustomHeightBanner(height: var h) => AdSize(
        width: width?.truncate() ?? -1,
        height: h,
      ),
      CustomSizeBanner(width: var w, height: var h) => AdSize(
        width: w,
        height: h,
      ),
    };
  }

  /// Generates the extras needed for Collapsible banners
  Map<String, String> getExtras() {
    if (this is CollapsibleBanner) {
      return {
        'collapsible': (this as CollapsibleBanner).isTop ? 'top' : 'bottom',
      };
    }
    return {};
  }
}
