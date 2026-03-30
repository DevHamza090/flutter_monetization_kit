import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_monetization_kit/flutter_monetization_kit.dart';

/// Manages App Open Ads for the package.
/// Handles preloading, validation (Premium, Internet), and professional display logic.
class AppOpenManager {
  AppOpenManager._();
  static final AppOpenManager instance = AppOpenManager._();

  /// Loads an App Open Ad.
  /// [screenName] (String?): Optional name of the screen for preloading.
  /// [screenRemote] (bool): Whether to check remote config for this screen.
  /// [androidAdUnit] (String?): The AdMob Android Ad Unit ID.
  /// [iosAdUnit] (String?): The AdMob iOS Ad Unit ID.
  /// [callbacks] (AppOpenAdCallbacks?): Callbacks for ad events.
  Future<void> load({
    String? screenName,
    required bool screenRemote,
    String? androidAdUnit,
    String? iosAdUnit,
    AppOpenAdCallbacks? callbacks,
  }) async {
    // 1. Validation Logic (Premium, Internet)
    final validationReason = await AdUtils.validateAdProcess();
    if (validationReason != null) {
      debugPrint("AppOpenManager: Ad request blocked ($validationReason)");
      callbacks?.onAdValidated?.call(validationReason);
      return;
    }

    final adUnitId = AdUtils.getAdUnitId(
      adType: AdType.appOpen,
      androidAdUnit: androidAdUnit,
      iosAdUnit: iosAdUnit,
    );
    if (adUnitId.isEmpty) {
      debugPrint("AppOpenManager: No ad unit provided");
      callbacks?.onAdValidated?.call(AdValidationReason.adNotAvailable);
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
  /// [androidAdUnit] (String?): The AdMob Android Ad Unit ID.
  /// [iosAdUnit] (String?): The AdMob iOS Ad Unit ID.
  /// [callbacks] (AppOpenAdCallbacks?): Callbacks for ad events.
  /// [loadingDialog] (bool): Whether to show a loading dialog before showing the ad. (Requires context to be non-null)
  /// [fullScreenDialog] (bool): Whether to show the loading dialog in full screen.
  /// [customLoadingWidget] (Widget?): Optional custom widget to show in the loading dialog.
  /// [loadingDelay] (Duration): Wait duration to ensure user sees the transition before ad pops up.
  /// [isDialogShowing] (bool): Internal use only to avoid double dialogs.
  /// [reloadAfterShow] (bool): Whether to automatically start loading a new ad after dismissal.
  Future<void> show({
    BuildContext? context,
    String? screenName,
    required bool screenRemote,
    String? androidAdUnit,
    String? iosAdUnit,
    AppOpenAdCallbacks? callbacks,
    bool loadingDialog = true,
    bool fullScreenDialog = true,
    Widget? customLoadingWidget,
    Duration loadingDelay = const Duration(milliseconds: 500),
    bool isDialogShowing = false,
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

    final adUnitId = AdUtils.getAdUnitId(
      adType: AdType.appOpen,
      androidAdUnit: androidAdUnit,
      iosAdUnit: iosAdUnit,
    );
    if (adUnitId.isEmpty) {
      debugPrint("AppOpenManager: No ad unit provided");
      callbacks?.onAdValidated?.call(AdValidationReason.adNotAvailable);
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
          androidAdUnit: androidAdUnit,
          iosAdUnit: iosAdUnit,
          callbacks: null,
        );
      }
      return;
    }

    // 3. Show Loading Dialog
    final effectiveContext = context ?? MonetizationKit.instance.navigatorKey?.currentContext;
    if (loadingDialog && !isDialogShowing && effectiveContext != null) {
      _showLoadingDialog(
        context: effectiveContext,
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
            androidAdUnit: androidAdUnit,
            iosAdUnit: iosAdUnit,
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

  /// Loads and Shows an App Open Ad in one go.
  /// If the ad is already ready, it shows it immediately.
  /// If not, it loads the ad first and then shows it.
  Future<void> loadAndShow({
    required BuildContext context,
    String? screenName,
    required bool screenRemote,
    String? androidAdUnit,
    String? iosAdUnit,
    AppOpenAdCallbacks? callbacks,
    bool loadingDialog = true,
    bool fullScreenDialog = true,
    Widget? customLoadingWidget,
    bool reloadAfterShow = true,
  }) async {
    final registryKey = _getRegistryKey(screenName);

    // If ad is ready, show it
    if (AdRegistry.instance.isAdReady(registryKey)) {
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
        reloadAfterShow: reloadAfterShow,
      );
      return;
    }

    // If ad is not ready, start loading process
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
      callbacks: AppOpenAdCallbacks(
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
            isDialogShowing: loadingDialog, // Pass that dialog is already visible
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
      ),
    );
  }

  String _getRegistryKey(String? screenName) {
    if (screenName != null && screenName.isNotEmpty) {
      return "${screenName}_app_open";
    }
    return "universal_app_open";
  }

  void _showLoadingDialog({
    required BuildContext context,
    required bool fullScreen,
    Widget? customWidget,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;

    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: !fullScreen,
      builder: (_) => PopScope(
        canPop: false,
        child: customWidget != null
            ? (fullScreen ? Material(color: backgroundColor, child: customWidget) : customWidget)
            : Container(
                color: fullScreen ? backgroundColor : Colors.transparent,
                child: Center(
                  child: fullScreen
                      ? const CircularProgressIndicator()
                      : Card(
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: const CircularProgressIndicator(),
                          ),
                        ),
                ),
              ),
      ),
    );
  }
}
