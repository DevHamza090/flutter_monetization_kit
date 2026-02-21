import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../callbacks/native_ad_callbacks.dart';
import '../core/enums/native_type.dart';
import '../core/native_ad_style.dart';
import '../core/native_ad_shimmer_style.dart';
import '../managers/native_ad_manager.dart';

class NativeWidget extends StatefulWidget {
  final String adUnit;
  final NativeType type;
  final bool screenRemote;
  final String? screenName;
  final NativeAdStyle style;
  final NativeAdShimmerStyle shimmerStyle;
  final NativeAdCallbacks? callback;
  final bool reloadAfterShow;

  const NativeWidget({
    super.key,
    required this.adUnit,
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

  @override
  void initState() {
    super.initState();
    _loadOrGetAd();
  }

  @override
  void didUpdateWidget(NativeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adUnit != widget.adUnit || oldWidget.screenName != widget.screenName || oldWidget.type != widget.type) {
      _loadOrGetAd();
    }
  }

  void _loadOrGetAd() {
    _adFailed = false;
    bool isPreloaded = NativeAdManager.instance.isAdPreloaded(widget.screenName, widget.adUnit);
    
    if (isPreloaded) {
      setState(() {
        _adLoaded = true;
      });
      widget.callback?.onAdLoaded?.call(widget.adUnit);
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

    NativeAdManager.instance.load(
      adUnitId: widget.adUnit,
      screenName: widget.screenName,
      screenRemote: widget.screenRemote,
      callbacks: interceptCallback,
    );
  }

  @override
  void dispose() {
    if (widget.reloadAfterShow) {
       NativeAdManager.instance.removeAd(widget.screenName);
       NativeAdManager.instance.load(
           adUnitId: widget.adUnit,
           screenName: widget.screenName,
           screenRemote: widget.screenRemote,
           callbacks: null,
       );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = _getHeightForType(widget.type);

    if (_adLoaded) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 320, 
          maxHeight: height,
        ),
        child: _buildPlatformView(),
      );
    } else if (!_adFailed) {
      // Shimmer
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: widget.shimmerStyle.bgColor ?? widget.style.bgColor ?? Colors.white,
          borderRadius: BorderRadius.circular(widget.shimmerStyle.bgCorner),
          border: Border.all(
            color: widget.shimmerStyle.bgStrokeColor ?? widget.style.bgStrokeColor ?? Colors.transparent,
            width: widget.shimmerStyle.bgStrokeWidth,
          ),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Shimmer.fromColors(
          baseColor: widget.shimmerStyle.baseColor ?? Colors.grey[300]!,
          highlightColor: widget.shimmerStyle.highlightColor ?? Colors.grey[100]!,
          child: _buildShimmerForType(),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildShimmerForType() {
    switch (widget.type) {
      case NativeType.small2:
        return _buildSmall2Shimmer();
      case NativeType.small1:
      default:
        return _buildSmall1Shimmer();
    }
  }

  Widget _buildSmall1Shimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon Placeholder
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: widget.shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        const SizedBox(width: 8),
        
        // Text Content Placeholder
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ad Badge + Headline
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.shimmerStyle.adTextBgColor ?? Colors.amber,
                      borderRadius: BorderRadius.circular(widget.shimmerStyle.adTextBgCorner),
                    ),
                    child: Text('AD', 
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.bold, 
                        color: widget.shimmerStyle.adTextColor ?? Colors.white
                      )
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 120,
                    height: 14,
                    color: widget.shimmerStyle.onBgColor,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Body Text Lines
              Container(
                width: double.infinity,
                height: 12,
                color: widget.shimmerStyle.onBgColor,
              ),
              const SizedBox(height: 4),
              Container(
                width: 150,
                height: 12,
                color: widget.shimmerStyle.onBgColor,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        
        // CTA Button Placeholder
        Container(
          width: 80,
          height: 36,
          decoration: BoxDecoration(
            color: widget.shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(widget.style.buttonCornerRadius),
          ),
        ),
      ],
    );
  }

  Widget _buildSmall2Shimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                 children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                     decoration: BoxDecoration(
                       color: widget.shimmerStyle.adTextBgColor ?? Colors.amber,
                       borderRadius: BorderRadius.circular(widget.shimmerStyle.adTextBgCorner),
                     ),
                     child: Text('AD', 
                       style: TextStyle(
                         fontSize: 10, 
                         fontWeight: FontWeight.bold, 
                         color: widget.shimmerStyle.adTextColor ?? Colors.white
                       )
                     ),
                   ),
                   const SizedBox(width: 6),
                   Expanded(
                     child: Container(
                       height: 14,
                       color: widget.shimmerStyle.onBgColor,
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 6),
               Container(
                 width: double.infinity,
                 height: 12,
                 color: widget.shimmerStyle.onBgColor,
               ),
               const SizedBox(height: 6),
               Row(
                 children: [
                   Container(
                     width: 60,
                     height: 10,
                     color: widget.shimmerStyle.onBgColor,
                   ),
                   const SizedBox(width: 8),
                   Container(
                     width: 80,
                     height: 10,
                     color: widget.shimmerStyle.onBgColor,
                   ),
                 ],
               ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 80,
          height: 36,
          decoration: BoxDecoration(
            color: widget.shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(widget.style.buttonCornerRadius),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformView() {
    final String targetCacheId = NativeAdManager.instance.getTargetCacheId(widget.screenName, widget.adUnit);

    String colorToHex(Color? color) {
      if (color == null) return '';
      return '#${color.value.toRadixString(16).padLeft(8, '0')}';
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
      'maxBodyLines': widget.style.maxBodyLines,
      'advertiserColor': colorToHex(widget.style.advertiserColor),
      'ratingColor': colorToHex(widget.style.ratingColor),
      'ratingBgColor': colorToHex(widget.style.ratingBgColor),
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
     
     final MethodChannel channel = MethodChannel('monetization_native_ad_view_$id');
     channel.setMethodCallHandler((call) async {
       switch(call.method) {
         case 'onAdClicked':
           widget.callback?.onAdClicked?.call(widget.adUnit);
           break;
         case 'onAdImpression':
           widget.callback?.onAdImpression?.call(widget.adUnit);
           break;
         case 'onAdClosed':
           widget.callback?.onAdClosed?.call(widget.adUnit);
           break;
         case 'onAdOpened':
           widget.callback?.onAdOpened?.call(widget.adUnit);
           break;
       }
     });
  }

  double _getHeightForType(NativeType type) {
    if (type.name.startsWith('small')) return 110.0;
    if (type.name.startsWith('medium')) return 250.0;
    if (type.name.startsWith('large')) return 350.0;
    if (type.name.startsWith('fullscreen')) return double.infinity;
    return 110.0;
  }
}
