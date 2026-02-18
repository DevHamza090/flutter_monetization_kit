import 'dart:ui';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../callbacks/native_ad_callbacks.dart';
import '../core/native_ad_style.dart';

class NativeAdManager {
  static final NativeAdManager _instance = NativeAdManager._internal();
  factory NativeAdManager() => _instance;
  NativeAdManager._internal();

  final Map<String, NativeAd?> _ads = {};
  final Map<String, bool> _loadingStates = {};

  NativeAd? getAd(String screenName) => _ads[screenName];

  bool isLoading(String screenName) => _loadingStates[screenName] ?? false;

  void loadAd({
    required String adUnitId,
    required String screenName,
    required String designId,
    required NativeAdCallbacks callbacks,
    NativeAdStyle style = const NativeAdStyle(),
  }) {
    if (_ads[screenName] != null || (_loadingStates[screenName] ?? false)) {
      return;
    }

    _loadingStates[screenName] = true;

    NativeAd(
      adUnitId: adUnitId,
      factoryId: 'native_ad_factory',
      request: const AdRequest(),
      customOptions: {
        'designId': designId,
        'backgroundColor': _colorToHex(style.bgColor),
        'buttonColor': _colorToHex(style.buttonBgColor),
        'textColor': _colorToHex(style.headingColor),
      },
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _ads[screenName] = ad as NativeAd;
          _loadingStates[screenName] = false;
          callbacks.onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, error) {
          _loadingStates[screenName] = false;
          ad.dispose();
          callbacks.onAdFailedToLoad?.call(ad, error);
        },
        onAdClicked: (ad) => callbacks.onAdClicked?.call(ad),
        onAdOpened: (ad) => callbacks.onAdOpened?.call(ad),
        onAdClosed: (ad) => callbacks.onAdClosed?.call(ad),
        onAdImpression: (ad) => callbacks.onAdImpression?.call(ad),
      ),
    ).load();
  }

  void disposeAd(String screenName) {
    _ads[screenName]?.dispose();
    _ads.remove(screenName);
    _loadingStates.remove(screenName);
  }

  void disposeAll() {
    for (var ad in _ads.values) {
      ad?.dispose();
    }
    _ads.clear();
    _loadingStates.clear();
  }

  String _colorToHex(Color? color) {
    if (color == null) return '#FFFFFF';
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}
