import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../callbacks/native_ad_callbacks.dart';
import '../core/ads_registry.dart';
import '../core/ads_settings.dart';
import '../core/ads_utils.dart';
import '../core/enums/ad_type.dart';
import '../core/enums/ad_validation_reason.dart';

/// Manages Native Ads using Custom Method Channels caching.
class NativeAdManager {
  NativeAdManager._() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }
  static final NativeAdManager instance = NativeAdManager._();

  static const MethodChannel _channel = MethodChannel(
    'flutter_monetization_kit/native_ads',
  );

  final Map<String, NativeAdCallbacks> _loadCallbacks = {};

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    final args = call.arguments as Map<dynamic, dynamic>? ?? {};
    final String cacheId = args['cacheId'] as String? ?? '';
    final String adUnitId = args['adUnitId'] as String? ?? '';
    final String screenName = args['screenName'] as String? ?? '';

    switch (call.method) {
      case 'onAdLoaded':
        debugPrint(AdUtils.logLoaded(AdType.native, screenName));
        AdRegistry.instance.setAd(cacheId, 'LOADED_NATIVE_AD');
        _loadCallbacks[cacheId]?.onAdLoaded?.call(adUnitId);
        break;

      case 'onAdFailedToLoad':
        final String error = args['error'] as String? ?? 'Unknown error';
        debugPrint(AdUtils.logFailed(AdType.native, screenName, error));
        AdRegistry.instance.removeAd(cacheId);
        _loadCallbacks[cacheId]?.onAdFailedToLoad?.call(
          adUnitId,
          LoadAdError(0, error, '', null),
        );
        break;
    }
  }

  /// Loads a Native Ad raw data.
  Future<void> load({
    String? screenName,
    required bool screenRemote,
    required String adUnitId,
    NativeAdCallbacks? callbacks,
  }) async {
    final validationReason = await AdUtils.validateAdProcess();
    if (validationReason != null) {
      debugPrint("NativeAdManager: Ad request blocked ($validationReason)");
      callbacks?.onAdValidated?.call(validationReason);
      return;
    }

    if (!AdsSettings.instance.enableNativeAds) {
      debugPrint("NativeAdManager: Native ads are disabled in settings");
      callbacks?.onAdValidated?.call(AdValidationReason.adDisabled);
      return;
    }

    final cacheId = getRegistryKey(screenName);

    if (AdRegistry.instance.isAdLoading(cacheId)) {
      debugPrint(
        AdUtils.logAlreadyLoading(AdType.native, adUnitId, screenName),
      );
      callbacks?.onAdValidated?.call(AdValidationReason.adAlreadyLoading);
      return;
    }

    if (AdRegistry.instance.isAdReady(cacheId)) {
      debugPrint("NativeAdManager: Ad $cacheId already loaded in cache.");
      callbacks?.onAdValidated?.call(AdValidationReason.adAlreadyReady);
      callbacks?.onAdLoaded?.call(adUnitId);
      return;
    }

    AdRegistry.instance.markLoading(cacheId);
    debugPrint(AdUtils.logLoading(AdType.native, adUnitId, screenName));

    if (callbacks != null) {
      _loadCallbacks[cacheId] = callbacks;
    }

    try {
      await _channel.invokeMethod('loadAd', {
        'cacheId': cacheId,
        'adUnitId': adUnitId,
        'screenName': screenName ?? '',
      });
    } catch (e) {
      AdRegistry.instance.removeAd(cacheId);
      callbacks?.onAdFailedToLoad?.call(
        adUnitId,
        LoadAdError(0, e.toString(), '', null),
      );
    }
  }

  bool isAdPreloaded(String? screenName, String adUnitId) {
    bool ready = AdRegistry.instance.isAdReady(getRegistryKey(screenName));
    if (!ready && screenName != null) {
      ready = AdRegistry.instance.isAdReady(
        getRegistryKey(null),
      ); // Fallback to Universal
    }
    return ready;
  }

  String getTargetCacheId(String? screenName, String adUnitId) {
    bool screenReady = AdRegistry.instance.isAdReady(
      getRegistryKey(screenName),
    );
    if (screenReady) return getRegistryKey(screenName);
    return getRegistryKey(null);
  }

  void removeAd(String? screenName) {
    String cacheId = getRegistryKey(screenName);
    AdRegistry.instance.removeAd(cacheId);
    _channel.invokeMethod('disposeAd', {'cacheId': cacheId});
  }

  void consumeAd(String? screenName) {
    String cacheId = getRegistryKey(screenName);
    AdRegistry.instance.removeAd(cacheId);
    _channel.invokeMethod('consumeAd', {'cacheId': cacheId});
  }

  String getRegistryKey(String? screenName) {
    if (screenName != null && screenName.isNotEmpty) {
      return "${screenName}_native";
    }
    return "universal_native";
  }
}
