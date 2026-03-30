import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../callbacks/interstitial_ad_callbacks.dart';
import '../core/ads_registry.dart';
import '../core/ads_settings.dart';
import '../core/ads_utils.dart';
import '../core/enums/ad_type.dart';
import '../core/enums/ad_validation_reason.dart';

/// Manages Interstitial Ads for the package.
/// Handles preloading, validation (Premium, Internet), and professional display logic.
class InterstitialAdManager {
  InterstitialAdManager._();
  static final InterstitialAdManager instance = InterstitialAdManager._();

  /// Loads an Interstitial Ad.
  /// [screenName] (String?): Optional name of the screen for preloading.
  /// [screenRemote] (bool): Whether to check remote config for this screen.
  /// [androidAdUnit] (String?): The AdMob Android Ad Unit ID.
  /// [iosAdUnit] (String?): The AdMob iOS Ad Unit ID.
  /// [callbacks] (InterstitialAdCallbacks?): Callbacks for ad events.
  Future<void> load({
    String? screenName,
    required bool screenRemote,
    String? androidAdUnit,
    String? iosAdUnit,
    InterstitialAdCallbacks? callbacks,
  }) async {
    // 1. Validation Logic (Premium, Internet)
    final validationReason = await AdUtils.validateAdProcess();
    if (validationReason != null) {
      debugPrint(
        "InterstitialAdManager: Ad request blocked ($validationReason)",
      );
      callbacks?.onAdValidated?.call(validationReason);
      return;
    }

    final adUnitId = AdUtils.getAdUnitId(
      adType: AdType.interstitial,
      androidAdUnit: androidAdUnit,
      iosAdUnit: iosAdUnit,
    );
    if (adUnitId.isEmpty) {
      debugPrint("InterstitialAdManager: No ad unit provided");
      callbacks?.onAdValidated?.call(AdValidationReason.adNotAvailable);
      return;
    }

    if (!AdsSettings.instance.enableInterstitialAds) {
      debugPrint(
        "InterstitialAdManager: Interstitial ads are disabled in settings",
      );
      callbacks?.onAdValidated?.call(AdValidationReason.adDisabled);
      return;
    }

    // 2. State Management (Already Loading/Loaded)
    final registryKey = _getRegistryKey(screenName);

    // [REQ] when loading does not load extra
    if (AdRegistry.instance.isAdLoading(registryKey)) {
      debugPrint(
        AdUtils.logAlreadyLoading(AdType.interstitial, adUnitId, screenName),
      );
      callbacks?.onAdValidated?.call(AdValidationReason.adAlreadyLoading);
      return;
    }

    // [REQ] when interstitial is already loaded does not load extra
    if (AdRegistry.instance.isAdReady(registryKey)) {
      debugPrint("InterstitialAdManager: Ad already loaded for $registryKey");
      callbacks?.onAdValidated?.call(AdValidationReason.adAlreadyReady);
      callbacks?.onAdLoaded?.call(
        AdRegistry.instance.getAd<InterstitialAd>(registryKey)!,
      );
      return;
    }

    // 3. Requesting the Ad
    AdRegistry.instance.markLoading(registryKey);
    debugPrint(AdUtils.logLoading(AdType.interstitial, adUnitId, screenName));

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint(AdUtils.logLoaded(AdType.interstitial, screenName));
          AdRegistry.instance.setAd(registryKey, ad);
          callbacks?.onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            AdUtils.logFailed(AdType.interstitial, screenName, error.message),
          );
          AdRegistry.instance.removeAd(registryKey);
          callbacks?.onAdFailedToLoad?.call(error);
        },
      ),
    );
  }

  /// Shows an Interstitial Ad.
  /// [context] (BuildContext): The context to show the ad and loading dialog.
  /// [screenName] (String?): Optional name of the screen.
  /// [screenRemote] (bool): Whether to check remote config for this screen.
  /// [androidAdUnit] (String?): The AdMob Android Ad Unit ID.
  /// [iosAdUnit] (String?): The AdMob iOS Ad Unit ID.
  /// [callbacks] (InterstitialAdCallbacks?): Callbacks for ad events.
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
    String? androidAdUnit,
    String? iosAdUnit,
    InterstitialAdCallbacks? callbacks,
    bool loadingDialog = true,
    bool fullScreenDialog = true,
    Widget? customLoadingWidget,
    Duration loadingDelay = const Duration(milliseconds: 500),
    bool isDialogShowing = false,
    bool reloadAfterShow = true,
  }) async {
    // 1. Core Logic & Validation
    final validationReason = AdsSettings.instance.validateInterstitialShow();
    if (validationReason != null) {
      debugPrint(
        "InterstitialAdManager: Cannot show interstitial ($validationReason)",
      );
      callbacks?.onAdValidated?.call(validationReason);
      return;
    }

    final adUnitId = AdUtils.getAdUnitId(
      adType: AdType.interstitial,
      androidAdUnit: androidAdUnit,
      iosAdUnit: iosAdUnit,
    );
    if (adUnitId.isEmpty) {
      debugPrint("InterstitialAdManager: No ad unit provided");
      callbacks?.onAdValidated?.call(AdValidationReason.adNotAvailable);
      return;
    }

    if (AdRegistry.instance.isFullScreenAdShowing) {
      debugPrint(
        "InterstitialAdManager: Another full screen ad is already showing.",
      );
      callbacks?.onAdValidated?.call(
        AdValidationReason.anotherFullScreenShowing,
      );
      return;
    }

    // 2. Fetch Ad from Registry (Priority: Screen-specific -> Universal)
    // [REQ] show preloaded with same screen
    String registryKey = _getRegistryKey(screenName);
    InterstitialAd? ad = AdRegistry.instance.getAd<InterstitialAd>(registryKey);

    // [REQ] show preloaded universal (fallback)
    if (ad == null && screenName != null) {
      registryKey = adUnitId;
      ad = AdRegistry.instance.getAd<InterstitialAd>(registryKey);
    }

    if (ad == null) {
      debugPrint(
        "InterstitialAdManager: No preloaded ad found for adUnit:$adUnitId, screen:$screenName",
      );
      callbacks?.onAdValidated?.call(AdValidationReason.adNotAvailable);

      // Professional: If not ready, load one for next time
      if (!AdRegistry.instance.isAdLoading(registryKey)) {
        load(
          screenName: screenName,
          screenRemote: screenRemote,
          androidAdUnit: androidAdUnit,
          iosAdUnit: iosAdUnit,
          callbacks: null,
        );
      }
      return;
    }

    // 3. Show Loading Dialog (if requested)
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
        AdsSettings.instance.incrementInterstitialCount();
        debugPrint(AdUtils.logShowing(AdType.interstitial, screenName));
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
            androidAdUnit: androidAdUnit,
            iosAdUnit: iosAdUnit,
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
          "InterstitialAdManager: Failed to show ad. Error: ${error.message}",
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

  /// Loads and Shows an Interstitial Ad in one go.
  /// If the ad is already ready, it shows it immediately.
  /// If not, it loads the ad first and then shows it.
  Future<void> loadNShow({
    required BuildContext context,
    String? screenName,
    required bool screenRemote,
    String? androidAdUnit,
    String? iosAdUnit,
    InterstitialAdCallbacks? callbacks,
    bool loadingDialog = true,
    bool fullScreenDialog = true,
    Widget? customLoadingWidget,
    bool reloadAfterShow = true,
  }) async {
    final registryKey = _getRegistryKey(screenName);

    if (AdRegistry.instance.isAdReady(registryKey)) {
      debugPrint("InterstitialAdManager: Ad already ready, showing now.");
      return show(
        context: context,
        screenName: screenName,
        screenRemote: screenRemote,
        androidAdUnit: androidAdUnit,
        iosAdUnit: iosAdUnit,
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
      androidAdUnit: androidAdUnit,
      iosAdUnit: iosAdUnit,
      callbacks: InterstitialAdCallbacks(
        onAdLoaded: (ad) async {
          callbacks?.onAdLoaded?.call(ad);
          await show(
            context: context,
            screenName: screenName,
            screenRemote: screenRemote,
            androidAdUnit: androidAdUnit,
            iosAdUnit: iosAdUnit,
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
      ),
    );
  }

  /// Generates a key for the [AdRegistry].
  String _getRegistryKey(String? screenName) {
    if (screenName != null && screenName.isNotEmpty) {
      return "${screenName}_interstitial";
    }
    return "universal_interstitial";
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
          child: Expanded(
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
      ),
    );
  }
}
