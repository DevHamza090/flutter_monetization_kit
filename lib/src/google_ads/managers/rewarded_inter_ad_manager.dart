import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../callbacks/rewarded_inter_ad_callbacks.dart';
import '../core/ads_registry.dart';
import '../core/ads_settings.dart';
import '../core/ads_utils.dart';
import '../core/enums/ad_type.dart';
import '../core/enums/ad_validation_reason.dart';

/// Manages Rewarded Interstitial Ads for the package.
/// Handles preloading, validation (Premium, Internet), and professional display logic.
class RewardedInterstitialAdManager {
  RewardedInterstitialAdManager._();
  static final RewardedInterstitialAdManager instance =
      RewardedInterstitialAdManager._();

  /// Loads a Rewarded Interstitial Ad.
  Future<void> load({
    String? screenName,
    required bool screenRemote,
    required String adUnitId,
    RewardedInterAdCallbacks? callbacks,
  }) async {
    // 1. Validation Logic
    final validationReason = await AdUtils.validateAdProcess();
    if (validationReason != null) {
      debugPrint(
        "RewardedInterAdManager: Ad request blocked ($validationReason)",
      );
      callbacks?.onAdValidated?.call(validationReason);
      return;
    }

    if (!AdsSettings.instance.enableRewardedAds) {
      debugPrint(
        "RewardedInterAdManager: Rewarded ads are disabled in settings",
      );
      callbacks?.onAdValidated?.call(AdValidationReason.adDisabled);
      return;
    }

    // 2. State Management
    final registryKey = _getRegistryKey(screenName);

    if (AdRegistry.instance.isAdLoading(registryKey)) {
      debugPrint(
        AdUtils.logAlreadyLoading(
          AdType.rewardedInterstitial,
          adUnitId,
          screenName,
        ),
      );
      callbacks?.onAdValidated?.call(AdValidationReason.adAlreadyLoading);
      return;
    }

    if (AdRegistry.instance.isAdReady(registryKey)) {
      debugPrint("RewardedInterAdManager: Ad already loaded for $registryKey");
      callbacks?.onAdValidated?.call(AdValidationReason.adAlreadyReady);
      callbacks?.onAdLoaded?.call(
        AdRegistry.instance.getAd<RewardedInterstitialAd>(registryKey)!,
      );
      return;
    }

    // 3. Requesting the Ad
    AdRegistry.instance.markLoading(registryKey);
    debugPrint(
      AdUtils.logLoading(AdType.rewardedInterstitial, adUnitId, screenName),
    );

    await RewardedInterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint(
            AdUtils.logLoaded(AdType.rewardedInterstitial, screenName),
          );
          AdRegistry.instance.setAd(registryKey, ad);
          callbacks?.onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            AdUtils.logFailed(
              AdType.rewardedInterstitial,
              screenName,
              error.message,
            ),
          );
          AdRegistry.instance.removeAd(registryKey);
          callbacks?.onAdFailedToLoad?.call(error);
        },
      ),
    );
  }

  /// Shows a Rewarded Interstitial Ad.
  /// [context] (BuildContext): The context to show the ad and loading dialog.
  /// [screenName] (String?): Optional name of the screen.
  /// [screenRemote] (bool): Whether to check remote config for this screen.
  /// [adUnitId] (String): The AdMob Ad Unit ID.
  /// [callbacks] (RewardedInterAdCallbacks?): Callbacks for ad events.
  /// [loadingDialog] (bool): Whether to show a loading dialog before showing the ad.
  /// [fullScreenDialog] (bool): Whether to show the loading dialog in full screen.
  /// [customLoadingWidget] (Widget?): Optional custom widget for the loading dialog.
  /// [loadingDelay] (Duration): Initial delay before checking/showing the ad.
  /// [isDialogShowing] (bool): Whether the loading dialog is already showing.
  /// [reloadAfterShow] (bool): Whether to automatically start loading a new ad after dismissal.
  Future<void> show({
    required BuildContext context,
    String? screenName,
    required bool screenRemote,
    required String adUnitId,
    RewardedInterAdCallbacks? callbacks,
    bool loadingDialog = true,
    bool fullScreenDialog = true,
    Widget? customLoadingWidget,
    Duration loadingDelay = const Duration(milliseconds: 500),
    bool isDialogShowing = false,
    bool reloadAfterShow = true,
  }) async {
    // 1. Core Logic & Validation
    final validationReason = AdsSettings.instance.validateRewardedShow();
    if (validationReason != null) {
      debugPrint(
        "RewardedInterAdManager: Cannot show rewarded inter ad ($validationReason)",
      );
      callbacks?.onAdValidated?.call(validationReason);
      return;
    }

    if (AdRegistry.instance.isFullScreenAdShowing) {
      debugPrint(
        "RewardedInterAdManager: Another full screen ad is already showing.",
      );
      callbacks?.onAdValidated?.call(
        AdValidationReason.anotherFullScreenShowing,
      );
      return;
    }

    // 2. Fetch Ad
    String registryKey = _getRegistryKey(screenName);
    RewardedInterstitialAd? ad = AdRegistry.instance
        .getAd<RewardedInterstitialAd>(registryKey);

    if (ad == null && screenName != null) {
      registryKey = adUnitId;
      ad = AdRegistry.instance.getAd<RewardedInterstitialAd>(registryKey);
    }

    if (ad == null) {
      debugPrint(
        "RewardedInterAdManager: No preloaded ad found for adUnit:$adUnitId, screen:$screenName",
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
    if (loadingDialog && !isDialogShowing) {
      _showLoadingDialog(
        context: context,
        fullScreen: fullScreenDialog,
        customWidget: customLoadingWidget,
      );
    }

    if (loadingDialog || loadingDelay > Duration.zero) {
      await Future.delayed(loadingDelay);
    }

    // 4. Actual Show Logic
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        AdRegistry.instance.isFullScreenAdShowing = true;
        if (loadingDialog && context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        debugPrint(AdUtils.logShowing(AdType.rewardedInterstitial, screenName));
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
          "RewardedInterAdManager: Failed to show ad. Error: ${error.message}",
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
        callbacks?.onUserEarnedReward?.call(
          ad as RewardedInterstitialAd,
          reward,
        );
      },
    );
  }

  /// Loads and Shows a Rewarded Interstitial Ad in one go.
  /// If the ad is already ready, it shows it immediately.
  /// If not, it loads the ad first and then shows it.
  Future<void> loadNShow({
    required BuildContext context,
    String? screenName,
    required bool screenRemote,
    required String adUnitId,
    RewardedInterAdCallbacks? callbacks,
    bool loadingDialog = true,
    bool fullScreenDialog = true,
    Widget? customLoadingWidget,
    bool reloadAfterShow = true,
  }) async {
    final registryKey = _getRegistryKey(screenName);

    if (AdRegistry.instance.isAdReady(registryKey)) {
      debugPrint("RewardedInterAdManager: Ad already ready, showing now.");
      return show(
        context: context,
        screenName: screenName,
        screenRemote: screenRemote,
        adUnitId: adUnitId,
        callbacks: callbacks,
        loadingDialog: loadingDialog,
        fullScreenDialog: fullScreenDialog,
        customLoadingWidget: customLoadingWidget,
        loadingDelay: const Duration(seconds: 2),
        reloadAfterShow: reloadAfterShow,
      );
    }

    if (loadingDialog) {
      _showLoadingDialog(
        context: context,
        fullScreen: fullScreenDialog,
        customWidget: customLoadingWidget,
      );
    }

    await load(
      screenName: screenName,
      screenRemote: screenRemote,
      adUnitId: adUnitId,
      callbacks: RewardedInterAdCallbacks(
        onAdLoaded: (ad) async {
          callbacks?.onAdLoaded?.call(ad);
          await show(
            context: context,
            screenName: screenName,
            screenRemote: screenRemote,
            adUnitId: adUnitId,
            callbacks: callbacks,
            loadingDialog: loadingDialog,
            fullScreenDialog: fullScreenDialog,
            customLoadingWidget: customLoadingWidget,
            isDialogShowing: loadingDialog,
            loadingDelay: Duration.zero,
            reloadAfterShow: reloadAfterShow,
          );
        },
        onAdFailedToLoad: (error) {
          if (loadingDialog && context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          callbacks?.onAdFailedToLoad?.call(error);
        },
        onAdValidated: (reason) {
          if (loadingDialog && context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          callbacks?.onAdValidated?.call(reason);
        },
        onAdShowedFullScreenContent: callbacks?.onAdShowedFullScreenContent,
        onAdDismissedFullScreenContent: callbacks?.onAdDismissedFullScreenContent,
        onAdFailedToShowFullScreenContent:
            callbacks?.onAdFailedToShowFullScreenContent,
        onAdClicked: callbacks?.onAdClicked,
        onUserEarnedReward: callbacks?.onUserEarnedReward,
      ),
    );
  }

  String _getRegistryKey(String? screenName) {
    if (screenName != null && screenName.isNotEmpty) {
      return "${screenName}_rewarded_inter";
    }
    return "universal_rewarded_inter";
  }

  void _showLoadingDialog({
    required BuildContext context,
    required bool fullScreen,
    Widget? customWidget,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: !fullScreen,
      builder: (_) => PopScope(
        canPop: false,
        child: Material(
          type: MaterialType.transparency,
          child: Center(
            child: customWidget ??
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const CircularProgressIndicator(),
                ),
          ),
        ),
      ),
    );
  }
}
