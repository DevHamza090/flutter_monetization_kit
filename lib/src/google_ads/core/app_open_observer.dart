import 'package:flutter/widgets.dart';
import 'package:flutter_monetization_kit/monetization_kit.dart';

import '../managers/app_open_manager.dart';

/// AppOpenObserver listens to app lifecycle changes
/// and automatically requests an App Open Ad to show when the app resumes.
class AppOpenObserver extends WidgetsBindingObserver {
  /// The specific unit id for app open ads to display.
  final String? androidAdUnit;
  final String? iosAdUnit;

  /// Optional callback to hook into ad events.
  final AppOpenAdCallbacks? callbacks;

  /// Whether to do remove validation.
  final bool screenRemote;

  AppOpenObserver({
    this.androidAdUnit,
    this.iosAdUnit,
    this.callbacks,
    this.screenRemote = false,
  });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 0. Check if App Open on Resume is enabled
      if (!AdsSettings.instance.enableAppOpenOnResume) {
        debugPrint("AppOpenObserver: Skipping app open ad because it is disabled in settings.");
        return;
      }

      // 1. Check if an ad was clicked recently (e.g., user clicked a banner and is now back)
      // This persists even if the user spent a long time in the browser.
      if (AdRegistry.instance.wasAdClickedRecently) {
        debugPrint("AppOpenObserver: Skipping ad because an ad was clicked recently.");
        AdRegistry.instance.wasAdClickedRecently = false;
        return;
      }

      // 2. Professional: If a full screen ad was recently dismissed, skip showing the app open ad.
      // This prevents the "infinite loop" feel when dismissing an interstitial triggers an app-open.
      final lastDismissed = AdRegistry.instance.lastDismissedTime;
      if (lastDismissed != null) {
        final difference = DateTime.now().difference(lastDismissed).inMilliseconds;
        if (difference < 1000) {
          debugPrint("AppOpenObserver: Skipping ad show (cooldown: ${difference}ms)");
          return;
        }
      }

      debugPrint("AppOpenObserver: App Resumed. Trying to show app open ad...");
      AppOpenManager.instance.show(
        context: null,
        screenRemote: screenRemote,
        androidAdUnit: androidAdUnit,
        iosAdUnit: iosAdUnit,
        loadingDialog: true,
        reloadAfterShow: true,
        callbacks: callbacks,
      );
    }
  }
}
