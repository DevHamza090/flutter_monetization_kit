import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../monetization_kit.dart';
import '../callbacks/native_ad_callbacks.dart';
import '../core/ads_registry.dart';
import '../core/enums/native_type.dart';
import '../core/native_ad_style.dart';
import '../core/native_ad_shimmer_style.dart';
import '../managers/native_ad_manager.dart';
import 'native_shimmer.dart';

class NativeWidget extends StatefulWidget {
  final String? androidAdUnit;
  final String? iosAdUnit;
  final NativeType type;
  final bool screenRemote;
  final String? screenName;
  final NativeAdStyle style;
  final NativeAdShimmerStyle shimmerStyle;
  final NativeAdCallbacks? callback;
  final bool reloadAfterShow;

  const NativeWidget({
    super.key,
    this.androidAdUnit,
    this.iosAdUnit,
    required this.type,
    this.screenRemote = true,
    this.screenName,
    this.style = const NativeAdStyle(),
    this.shimmerStyle = const NativeAdShimmerStyle(),
    this.callback,
    this.reloadAfterShow = false,
  });

  @override
  State<NativeWidget> createState() => _NativeWidgetState();
}

class _NativeWidgetState extends State<NativeWidget> {
  bool _adLoaded = false;
  bool _adFailed = false;
  double? _dynamicHeight;

  @override
  void initState() {
    super.initState();
    _loadOrGetAd();
  }

  @override
  void didUpdateWidget(NativeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.androidAdUnit != widget.androidAdUnit ||
        oldWidget.iosAdUnit != widget.iosAdUnit ||
        oldWidget.screenName != widget.screenName ||
        oldWidget.type != widget.type) {
      _loadOrGetAd();
    }
  }

  void _loadOrGetAd() {
    _adFailed = false;
    final String finalAdUnitId = AdUtils.getAdUnitId(
      adType: AdType.native,
      androidAdUnit: widget.androidAdUnit,
      iosAdUnit: widget.iosAdUnit,
    );
    bool isPreloaded = NativeAdManager.instance.isAdPreloaded(
      widget.screenName,
    );

    if (isPreloaded) {
      setState(() {
        _adLoaded = true;
      });
      widget.callback?.onAdLoaded?.call(finalAdUnitId);
    } else {
      setState(() {
        _adLoaded = false;
      });
      _loadAd();
    }
  }

  void _loadAd() {
    final interceptCallback = NativeAdCallbacks(
      onAdLoaded: (id) {
        if (mounted) {
          setState(() {
            _adLoaded = true;
            _adFailed = false;
          });
        }
        widget.callback?.onAdLoaded?.call(id);
      },
      onAdFailedToLoad: (id, error) {
        if (mounted) {
          setState(() {
            _adLoaded = false;
            _adFailed = true;
          });
        }
        widget.callback?.onAdFailedToLoad?.call(id, error);
      },
      onAdClicked: widget.callback?.onAdClicked,
      onAdClosed: widget.callback?.onAdClosed,
      onAdImpression: widget.callback?.onAdImpression,
      onAdOpened: widget.callback?.onAdOpened,
      onAdValidated: widget.callback?.onAdValidated,
    );

    final String finalAdUnitId = AdUtils.getAdUnitId(
      adType: AdType.native,
      androidAdUnit: widget.androidAdUnit,
      iosAdUnit: widget.iosAdUnit,
    );

    NativeAdManager.instance.load(
      androidAdUnit: widget.androidAdUnit,
      iosAdUnit: widget.iosAdUnit,
      screenName: widget.screenName,
      screenRemote: widget.screenRemote,
      callbacks: interceptCallback,
    );
  }

  @override
  void dispose() {
    if (widget.reloadAfterShow) {
      final String finalAdUnitId = AdUtils.getAdUnitId(
        adType: AdType.native,
        androidAdUnit: widget.androidAdUnit,
        iosAdUnit: widget.iosAdUnit,
      );
      NativeAdManager.instance.removeAd(widget.screenName);
      NativeAdManager.instance.load(
        androidAdUnit: widget.androidAdUnit,
        iosAdUnit: widget.iosAdUnit,
        screenName: widget.screenName,
        screenRemote: widget.screenRemote,
        callbacks: null,
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AdsSettings.instance.isPremium) {
      return const SizedBox.shrink();
    }

    final height = _dynamicHeight ?? _getHeightForType(widget.type);

    if (_adLoaded) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 320, 
          minHeight: _dynamicHeight != null ? height : 0,
          maxHeight: height,
        ),
        child: _buildPlatformView(),
      );
    } else if (!_adFailed) {
      // Shimmer
      return NativeShimmer(
        type: widget.type,
        style: widget.style,
        shimmerStyle: widget.shimmerStyle,
        height: height,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildPlatformView() {
    final String finalAdUnitId = AdUtils.getAdUnitId(
      adType: AdType.native,
      androidAdUnit: widget.androidAdUnit,
      iosAdUnit: widget.iosAdUnit,
    );

    final String targetCacheId = NativeAdManager.instance.getTargetCacheId(
      widget.screenName,
    );

    String colorToHex(Color? color) {
      if (color == null) return '';
      return '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}';
    }

    final Map<String, dynamic> creationParams = <String, dynamic>{
      'cacheId': targetCacheId,
      'nativeType': widget.type.name,
      'bgColor': colorToHex(widget.style.bgColor),
      'bgStrokeColor': colorToHex(widget.style.bgStrokeColor),
      'bgStrokeWidth': widget.style.bgStrokeWidth,
      'bgCorner': widget.style.bgCorner,
      'adTextColor': colorToHex(widget.style.adTextColor),
      'adTextBgColor': colorToHex(widget.style.adTextBgColor),
      'adTextBgCorner': widget.style.adTextBgCorner,
      'adStrokeColor': colorToHex(widget.style.adStrokeColor),
      'adStrokeWidth': widget.style.adStrokeWidth,
      'headingColor': colorToHex(widget.style.headingColor),
      'bodyColor': colorToHex(widget.style.bodyColor),
      'advertiserColor': colorToHex(widget.style.advertiserColor),
      'ratingColor': colorToHex(widget.style.ratingColor),
      'ratingBgColor': colorToHex(widget.style.ratingBgColor),
      'priceColor': colorToHex(widget.style.priceColor),
      'buttonBgColor': colorToHex(widget.style.buttonBgColor),
      'buttonTextColor': colorToHex(widget.style.buttonTextColor),
      'buttonCornerRadius': widget.style.buttonCornerRadius,
      'fontFamily': widget.style.fontFamily ?? '',
    };

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'monetization_native_ad_view',
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'monetization_native_ad_view',
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return const SizedBox.shrink();
  }

  void _onPlatformViewCreated(int id) {
    NativeAdManager.instance.consumeAd(widget.screenName);

    final String finalAdUnitId = AdUtils.getAdUnitId(
      adType: AdType.native,
      androidAdUnit: widget.androidAdUnit,
      iosAdUnit: widget.iosAdUnit,
    );

    final MethodChannel channel = MethodChannel(
      'monetization_native_ad_view_$id',
    );
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onAdSized':
          final args = call.arguments as Map;
          if (mounted) {
            setState(() {
              _dynamicHeight = (args['height'] as num).toDouble();
            });
          }
          break;
        case 'onAdClicked':
          AdRegistry.instance.wasAdClickedRecently = true;
          AdRegistry.instance.lastDismissedTime = DateTime.now();
          widget.callback?.onAdClicked?.call(finalAdUnitId);
          break;
        case 'onAdImpression':
          widget.callback?.onAdImpression?.call(finalAdUnitId);
          break;
        case 'onAdClosed':
          widget.callback?.onAdClosed?.call(finalAdUnitId);
          break;
        case 'onAdOpened':
          AdRegistry.instance.wasAdClickedRecently = true;
          AdRegistry.instance.lastDismissedTime = DateTime.now();
          widget.callback?.onAdOpened?.call(finalAdUnitId);
          break;
      }
    });
  }

  double _getHeightForType(NativeType type) {
    if (type == NativeType.small1) return Platform.isAndroid ? 90.0 : 75.0;
    if (type == NativeType.small2) return 70.0;
    if (type == NativeType.small3) return 70.0;
    if (type == NativeType.small4) return 70.0;
    if (type == NativeType.small5) return 70.0;
    if (type == NativeType.small6) return 70.0;
    if (type == NativeType.small7) return 70.0;
    if (type == NativeType.small8) return 70.0;
    if (type == NativeType.medium1) return Platform.isAndroid ? 140.0 : 130;
    if (type == NativeType.medium2) return Platform.isAndroid ? 140.0 : 130;
    if (type == NativeType.medium3) return 150.0;
    if (type == NativeType.medium4) return 150.0;
    if (type == NativeType.medium5) return 140.0;
    if (type == NativeType.medium6) return 140.0;
    if (type == NativeType.large1) return 280.0;
    if (type == NativeType.large2) return 280.0;
    if (type == NativeType.large3) return 280.0;
    if (type == NativeType.large4) return 280.0;
    if (type == NativeType.large5) return 280.0;
    if (type == NativeType.large6) return 280.0;
    if (type.name.startsWith('small')) return 100.0;
    if (type.name.startsWith('medium')) return 250.0;
    if (type.name.startsWith('large')) return 350.0;
    if (type.name.startsWith('fullscreen')) return double.infinity;
    return 110.0;
  }
}
