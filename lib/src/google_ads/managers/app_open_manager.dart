import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_monetization_kit/easy_ads.dart';

/// Manages App Open Ads for the package.
/// Handles preloading, validation (Premium, Internet), and professional display logic.
class AppOpenManager {
  AppOpenManager._();
  static final AppOpenManager instance = AppOpenManager._();

  /// Loads an App Open Ad.
  /// [screenName] (String?): Optional name of the screen for preloading.
  /// [screenRemote] (bool): Whether to check remote config for this screen.
  /// [adUnitId] (String): The AdMob Ad Unit ID.
  /// [callbacks] (AppOpenAdCallbacks?): Callbacks for ad events.
  Future<void> load({
    String? screenName,
    required bool screenRemote,
    required String adUnitId,
    AppOpenAdCallbacks? callbacks,
  }) async {
    // 1. Validation Logic (Premium, Internet)
    final validationReason = await AdUtils.validateAdProcess();
    if (validationReason != null) {
      debugPrint("AppOpenManager: Ad request blocked ($validationReason)");
      callbacks?.onAdValidated?.call(validationReason);
      return;
    }

    if (!AdsSettings.instance.enableAppOpen) {
      debugPrint("AppOpenManager: App open ads are disabled in settings");
      callbacks?.onAdValidated?.call(AdValidationReason.adDisabled);
      return;
    }

    // 2. State Management (Already Loading/Loaded)
    final registryKey = _getRegistryKey(screenName);

    if (AdRegistry.instance.isAdLoading(registryKey)) {
      debugPrint(
        AdUtils.logAlreadyLoading(AdType.appOpen, adUnitId, screenName),
      );
      callbacks?.onAdValidated?.call(AdValidationReason.adAlreadyLoading);
      return;
    }

    if (AdRegistry.instance.isAdReady(registryKey)) {
      debugPrint("AppOpenManager: Ad already loaded for $registryKey");
      callbacks?.onAdValidated?.call(AdValidationReason.adAlreadyReady);
      callbacks?.onAdLoaded?.call(
        AdRegistry.instance.getAd<AppOpenAd>(registryKey)!,
      );
      return;
    }

    // 3. Requesting the Ad
    AdRegistry.instance.markLoading(registryKey);
    debugPrint(AdUtils.logLoading(AdType.appOpen, adUnitId, screenName));

    await AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint(AdUtils.logLoaded(AdType.appOpen, screenName));
          AdRegistry.instance.setAd(registryKey, ad);
          callbacks?.onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            AdUtils.logFailed(AdType.appOpen, screenName, error.message),
          );
          AdRegistry.instance.removeAd(registryKey);
          callbacks?.onAdFailedToLoad?.call(error);
        },
      ),
    );
  }

  /// Shows an App Open Ad.
  /// [context] (BuildContext?): The context to show the ad and loading dialog. Optional for app resume showing.
  /// [screenName] (String?): Optional name of the screen.
  /// [screenRemote] (bool): Whether to check remote config for this screen.
  /// [adUnitId] (String): The AdMob Ad Unit ID.
  /// [callbacks] (AppOpenAdCallbacks?): Callbacks for ad events.
  /// [loadingDialog] (bool): Whether to show a loading dialog before showing the ad. (Requires context to be non-null)
  /// [reloadAfterShow] (bool): Whether to automatically start loading a new ad after dismissal.
  Future<void> show({
    BuildContext? context,
    String? screenName,
    required bool screenRemote,
    required String adUnitId,
    AppOpenAdCallbacks? callbacks,
    bool loadingDialog = true,
    bool reloadAfterShow = true,
  }) async {
    // 1. Core Logic & Validation
    final validationReason = AdsSettings.instance.validateAppOpenShow();
    if (validationReason != null) {
      debugPrint("AppOpenManager: Cannot show app open ($validationReason)");
      callbacks?.onAdValidated?.call(validationReason);
      return;
    }

    if (AdRegistry.instance.isFullScreenAdShowing) {
      debugPrint("AppOpenManager: Another full screen ad is already showing.");
      callbacks?.onAdValidated?.call(
        AdValidationReason.anotherFullScreenShowing,
      );
      return;
    }

    // 2. Fetch Ad from Registry (Priority: Screen-specific -> Universal)
    String registryKey = _getRegistryKey(screenName);
    AppOpenAd? ad = AdRegistry.instance.getAd<AppOpenAd>(registryKey);

    if (ad == null && screenName != null) {
      registryKey = adUnitId;
      ad = AdRegistry.instance.getAd<AppOpenAd>(registryKey);
    }

    if (ad == null) {
      debugPrint(
        "AppOpenManager: No preloaded ad found for adUnit:$adUnitId, screen:$screenName",
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
    final effectiveContext = context ?? EasyAds.instance.navigatorKey?.currentContext;
    if (loadingDialog && effectiveContext != null) {
      _showLoadingDialog(effectiveContext);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // 4. Actual Show Logic
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        AdRegistry.instance.isFullScreenAdShowing = true;
        debugPrint(AdUtils.logShowing(AdType.appOpen, screenName));
        callbacks?.onAdShowedFullScreenContent?.call(ad);
      },
      onAdDismissedFullScreenContent: (ad) {
        AdRegistry.instance.isFullScreenAdShowing = false;
        AdRegistry.instance.lastDismissedTime = DateTime.now();

        if (loadingDialog && effectiveContext != null && effectiveContext.mounted) {
          Navigator.of(effectiveContext, rootNavigator: true).pop();
        }

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
        if (loadingDialog && effectiveContext != null && effectiveContext.mounted) {
          Navigator.of(effectiveContext, rootNavigator: true).pop();
        }
        ad.dispose();
        AdRegistry.instance.removeAd(registryKey);
        debugPrint(
          "AppOpenManager: Failed to show ad. Error: ${error.message}",
        );
        callbacks?.onAdFailedToShowFullScreenContent?.call(ad, error);
      },
      onAdClicked: (ad) {
        AdRegistry.instance.wasAdClickedRecently = true;
        callbacks?.onAdClicked?.call(ad);
      },
    );

    await ad.show();
  }

  String _getRegistryKey(String? screenName) {
    if (screenName != null && screenName.isNotEmpty) {
      return "${screenName}_app_open";
    }
    return "universal_app_open";
  }

  void _showLoadingDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;

    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false, // Full screen
      builder: (_) => PopScope(
        canPop: false,
        child: Container(
          color: backgroundColor,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
