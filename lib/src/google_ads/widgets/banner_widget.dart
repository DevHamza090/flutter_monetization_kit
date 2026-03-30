import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';
import '../core/ads_utils.dart';
import '../core/ads_settings.dart';
import '../core/enums/banner_type.dart';
import '../core/enums/ad_type.dart';
import '../callbacks/banner_ad_callbacks.dart';
import '../managers/banner_ad_manager.dart';

class BannerAdWidget extends StatefulWidget {
  final bool? screenRemote;
  final BannerType type;
  final BannerAdCallbacks? callbacks;
  final String? androidAdUnit;
  final String? iosAdUnit;
  final BannerType? androidBannerType;
  final BannerType? iosBannerType;
  final Color? backgroundColor;
  final Color? shimmerColor;
  final EdgeInsetsGeometry? padding;

  const BannerAdWidget({
    super.key,
    this.screenRemote,
    this.type = BannerType.standard,
    this.callbacks,
    this.androidAdUnit,
    this.iosAdUnit,
    this.androidBannerType,
    this.iosBannerType,
    this.backgroundColor,
    this.shimmerColor,
    this.padding,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final BannerAdManager _manager = BannerAdManager.instance;
  bool _isLoading = true;
  bool _canShowAd = false;
  AdSize? _currentAdSize;

  @override
  void initState() {
    super.initState();
    // We need the context for MediaQuery, so we use postFrameCallback or check in build.
    // However, loading should happen once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadAd();
    });
  }

  Future<void> _checkAndLoadAd() async {
    // 1. Validation Logic
    // final bool canProcess = await AdUtils.canProcessAd();
    // if (!canProcess) {
    //   if (mounted) setState(() => _isLoading = false);
    //   return;
    // }

    // if screenRemote is false, don't show ad
    if (widget.screenRemote == false) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (mounted) {
      setState(() {
        _canShowAd = true;
      });
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    String finalAdUnitId = AdUtils.getAdUnitId(
      adType: (widget.type is AdaptiveBanner || widget.type is CollapsibleBanner)
          ? AdType.adaptiveBanner
          : AdType.banner,
      androidAdUnit: widget.androidAdUnit,
      iosAdUnit: widget.iosAdUnit,
    );

    if (finalAdUnitId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Determine AdSize
    BannerType selectedType = widget.type;
    if (Platform.isAndroid && widget.androidBannerType != null) {
      selectedType = widget.androidBannerType!;
    } else if (Platform.isIOS && widget.iosBannerType != null) {
      selectedType = widget.iosBannerType!;
    }

    final double width = MediaQuery.of(context).size.width;
    AdSize size = await selectedType.getAdSize(
      width: width,
      orientation: MediaQuery.of(context).orientation,
    );

    if (mounted) {
      setState(() {
        _currentAdSize = size;
      });
    }

    _manager.loadAd(
      adUnitId: finalAdUnitId,
      size: size,
      extras: selectedType.getExtras(),
      callbacks: BannerAdCallbacks(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoading = false);
          widget.callbacks?.onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, error) {
          if (mounted) setState(() => _isLoading = false);
          widget.callbacks?.onAdFailedToLoad?.call(ad, error);
        },
        onAdClicked: widget.callbacks?.onAdClicked,
        onAdOpened: widget.callbacks?.onAdOpened,
        onAdClosed: widget.callbacks?.onAdClosed,
        onAdWillDismissScreen: widget.callbacks?.onAdWillDismissScreen,
        onAdImpression: widget.callbacks?.onAdImpression,
        onPaidEvent: widget.callbacks?.onPaidEvent,
        onAdValidated: widget.callbacks?.onAdValidated,
      ),
    );
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  double _getVerticalPadding() {
    if (widget.padding == null) return 0.0;
    return widget.padding!.vertical;
  }

  @override
  Widget build(BuildContext context) {
    if (AdsSettings.instance.isPremium) {
      return const SizedBox.shrink();
    }
    
    if (!_canShowAd) return const SizedBox.shrink();

    if (_isLoading) {
      return _buildShimmer();
    }

    if (_manager.isLoaded && _manager.bannerAd != null) {
      final size = _manager.bannerAd!.size;
      // final double width = size.width <= 0
      //     ? MediaQuery.of(context).size.width
      //     : size.width.toDouble();
      final double width = MediaQuery.of(context).size.width;
      final double height =
          (size.height <= 0 ? 50.0 : size.height.toDouble()) +
          _getVerticalPadding();

      return Container(
        alignment: Alignment.center,
        width: width,
        height: height,
        padding: widget.padding,
        color: widget.backgroundColor,
        child: AdWidget(ad: _manager.bannerAd!),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildShimmer() {
    double height = 50.0;
    double width = MediaQuery.of(context).size.width;

    if (_currentAdSize != null) {
      height = _currentAdSize!.height.toDouble();
      //   if (_currentAdSize!.width != -1 && _currentAdSize!.width != 0) {
      //     width = _currentAdSize!.width.toDouble();
      //   }
    } else {
      // Fallback for types that have fixed sizes
      if (widget.type is StandardBanner) height = 50.0;
      if (widget.type is LargeBanner) height = 100.0;
      if (widget.type is RectangleBanner) {
        height = 250.0;
        // width = 300.0;
      }
    }

    // Add padding to height
    height += _getVerticalPadding();

    // Ensure height is not zero to avoid shimmer error
    if (height <= 0) height = 50.0;

    return Shimmer.fromColors(
      baseColor: widget.shimmerColor?.withValues(alpha: 0.5) ?? Colors.grey[300]!,
      highlightColor: widget.shimmerColor ?? Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
