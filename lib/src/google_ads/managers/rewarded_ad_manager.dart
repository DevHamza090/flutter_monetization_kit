import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../callbacks/rewarded_ad_callbacks.dart';
import '../core/ads_registry.dart';
import '../core/ads_settings.dart';
import '../core/ads_utils.dart';
import '../core/enums/ad_type.dart';
import '../core/enums/ad_validation_reason.dart';

/// Manages Rewarded Ads for the package.
/// Handles preloading, validation (Premium, Internet), and professional display logic.
class RewardedAdManager {
  RewardedAdManager._();
  static final RewardedAdManager instance = RewardedAdManager._();

  /// Loads a Rewarded Ad.
  /// [screenName] (String?): Optional name of the screen for preloading.
  /// [screenRemote] (bool): Whether to check remote config for this screen.
  /// [adUnitId] (String): The AdMob Ad Unit ID.
  /// [callbacks] (RewardedAdCallbacks?): Callbacks for ad events.
  Future<void> load({
    String? screenName,
    required bool screenRemote,
    required String adUnitId,
    RewardedAdCallbacks? callbacks,
  }) async {
    // 1. Validation Logic (Premium, Internet)
    final validationReason = await AdUtils.validateAdProcess();
    if (validationReason != null) {
      debugPrint("RewardedAdManager: Ad request blocked ($validationReason)");
      callbacks?.onAdValidated?.call(validationReason);
      return;
    }

    if (!AdsSettings.instance.enableRewardedAds) {
      debugPrint("RewardedAdManager: Rewarded ads are disabled in settings");
      callbacks?.onAdValidated?.call(AdValidationReason.adDisabled);
      return;
    }

    // 2. State Management (Already Loading/Loaded)
    final registryKey = _getRegistryKey(screenName);

    if (AdRegistry.instance.isAdLoading(registryKey)) {
      debugPrint(
        AdUtils.logAlreadyLoading(AdType.rewarded, adUnitId, screenName),
      );
      callbacks?.onAdValidated?.call(AdValidationReason.adAlreadyLoading);
      return;
    }

    if (AdRegistry.instance.isAdReady(registryKey)) {
      debugPrint("RewardedAdManager: Ad already loaded for $registryKey");
      callbacks?.onAdValidated?.call(AdValidationReason.adAlreadyReady);
      callbacks?.onAdLoaded?.call(
        AdRegistry.instance.getAd<RewardedAd>(registryKey)!,
      );
      return;
    }

    // 3. Requesting the Ad
    AdRegistry.instance.markLoading(registryKey);
    debugPrint(AdUtils.logLoading(AdType.rewarded, adUnitId, screenName));

    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint(AdUtils.logLoaded(AdType.rewarded, screenName));
          AdRegistry.instance.setAd(registryKey, ad);
          callbacks?.onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            AdUtils.logFailed(AdType.rewarded, screenName, error.message),
          );
          AdRegistry.instance.removeAd(registryKey);
          callbacks?.onAdFailedToLoad?.call(error);
        },
      ),
    );
  }

  /// Shows a Rewarded Ad.
  /// [context] (BuildContext): The context to show the ad and loading dialog.
  /// [screenName] (String?): Optional name of the screen.
  /// [screenRemote] (bool): Whether to check remote config for this screen.
  /// [adUnitId] (String): The AdMob Ad Unit ID.
  /// [callbacks] (RewardedAdCallbacks?): Callbacks for ad events.
  /// [loadingDialog] (bool): Whether to show a loading dialog before showing the ad.
  /// [reloadAfterShow] (bool): Whether to automatically start loading a new ad after dismissal.
  Future<void> show({
    required BuildContext context,
    String? screenName,
    required bool screenRemote,
    required String adUnitId,
    RewardedAdCallbacks? callbacks,
    bool loadingDialog = true,
    bool reloadAfterShow = true,
  }) async {
    // 1. Core Logic & Validation
    final validationReason = AdsSettings.instance.validateRewardedShow();
    if (validationReason != null) {
      debugPrint(
        "RewardedAdManager: Cannot show rewarded ad ($validationReason)",
      );
      callbacks?.onAdValidated?.call(validationReason);
      return;
    }

    if (AdRegistry.instance.isFullScreenAdShowing) {
      debugPrint(
        "RewardedAdManager: Another full screen ad is already showing.",
      );
      callbacks?.onAdValidated?.call(
        AdValidationReason.anotherFullScreenShowing,
      );
      return;
    }

    // 2. Fetch Ad from Registry (Priority: Screen-specific -> Universal)
    String registryKey = _getRegistryKey(screenName);
    RewardedAd? ad = AdRegistry.instance.getAd<RewardedAd>(registryKey);

    if (ad == null && screenName != null) {
      registryKey = adUnitId;
      ad = AdRegistry.instance.getAd<RewardedAd>(registryKey);
    }

    if (ad == null) {
      debugPrint(
        "RewardedAdManager: No preloaded ad found for adUnit:$adUnitId, screen:$screenName",
      );
      callbacks?.onAdValidated?.call(AdValidationReason.adNotAvailable);

      if (!AdRegistry.instance.isAdLoading(registryKey)) {
        load(
          screenName: screenName,
          screenRemote: screenRemote,
          adUnitId: adUnitId,
          callbacks: null,
        );
      }
      return;
    }

    // 3. Show Loading Dialog
    if (loadingDialog) {
      _showLoadingDialog(context);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // 4. Actual Show Logic
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        AdRegistry.instance.isFullScreenAdShowing = true;
        if (loadingDialog && context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        debugPrint(AdUtils.logShowing(AdType.rewarded, screenName));
        callbacks?.onAdShowedFullScreenContent?.call(ad);
      },
      onAdDismissedFullScreenContent: (ad) {
        AdRegistry.instance.isFullScreenAdShowing = false;
        AdRegistry.instance.lastDismissedTime = DateTime.now();
        ad.dispose();
        AdRegistry.instance.removeAd(registryKey);
        callbacks?.onAdDismissedFullScreenContent?.call(ad);

        if (reloadAfterShow) {
          load(
            screenName: screenName,
            screenRemote: screenRemote,
            adUnitId: adUnitId,
            callbacks: null,
          );
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AdRegistry.instance.isFullScreenAdShowing = false;
        AdRegistry.instance.lastDismissedTime = DateTime.now();
        if (loadingDialog && context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        ad.dispose();
        AdRegistry.instance.removeAd(registryKey);
        debugPrint(
          "RewardedAdManager: Failed to show ad. Error: ${error.message}",
        );
        callbacks?.onAdFailedToShowFullScreenContent?.call(ad, error);
      },
      onAdClicked: (ad) {
        AdRegistry.instance.wasAdClickedRecently = true;
        callbacks?.onAdClicked?.call(ad);
      },
    );

    await ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        callbacks?.onUserEarnedReward?.call(ad as RewardedAd, reward);
      },
    );
  }

  String _getRegistryKey(String? screenName) {
    if (screenName != null && screenName.isNotEmpty) {
      return "${screenName}_rewarded";
    }
    return "universal_rewarded";
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
