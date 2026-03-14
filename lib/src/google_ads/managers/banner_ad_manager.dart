import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/ads_registry.dart';
import '../callbacks/banner_ad_callbacks.dart';
import '../core/ads_utils.dart';
import '../core/enums/ad_validation_reason.dart';

class BannerAdManager {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  BannerAd? get bannerAd => _bannerAd;

  bool get isLoaded => _isLoaded;

  Future<void> loadAd({
    required String adUnitId,
    required AdSize size,
    Map<String, String>? extras,
    BannerAdCallbacks? callbacks,
  }) async {
    _isLoaded = false;
    _bannerAd?.dispose();

    // 1. Validation Logic (Premium, Internet)
    final validationReason = await AdUtils.validateAdProcess();
    if (validationReason != null) {
      callbacks?.onAdValidated?.call(validationReason);
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: AdRequest(extras: extras),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isLoaded = true;
          callbacks?.onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, error) {
          _isLoaded = false;
          ad.dispose();
          _bannerAd = null;
          callbacks?.onAdFailedToLoad?.call(ad, error);
        },
        onAdClicked: (ad) {
          AdRegistry.instance.wasAdClickedRecently = true;
          AdRegistry.instance.lastDismissedTime = DateTime.now();
          callbacks?.onAdClicked?.call(ad);
        },
        onAdOpened: (ad) {
          AdRegistry.instance.wasAdClickedRecently = true;
          AdRegistry.instance.lastDismissedTime = DateTime.now();
          callbacks?.onAdOpened?.call(ad);
        },
        onAdClosed: (ad) => callbacks?.onAdClosed?.call(ad),
        onAdImpression: (ad) => callbacks?.onAdImpression?.call(ad),
        onAdWillDismissScreen: (ad) =>
            callbacks?.onAdWillDismissScreen?.call(ad),
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          callbacks?.onPaidEvent?.call(
            ad,
            valueMicros,
            precision,
            currencyCode,
          );
        },
      ),
    )..load();
  }

  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
  }
}
