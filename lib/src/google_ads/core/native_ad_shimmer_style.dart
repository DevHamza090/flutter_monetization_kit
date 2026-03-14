import 'package:flutter/material.dart';

class NativeAdShimmerStyle {
  // Container Style
  final Color? bgColor;
  final Color? bgStrokeColor;
  final double bgStrokeWidth;
  final double bgCorner;

  // "Ad" Badge Style
  final Color? adTextColor;
  final Color? adTextBgColor;
  final double adTextBgCorner;

  // Highlight/Base colors for the shimmer effect
  final Color? baseColor;
  final Color? highlightColor;

  // Element placeholder color (blocks inside the shimmer)
  final Color? onBgColor;

  const NativeAdShimmerStyle({
    this.bgColor,
    this.bgStrokeColor,
    this.bgStrokeWidth = 0.0,
    this.bgCorner = 8.0,
    this.adTextColor = Colors.white,
    this.adTextBgColor = Colors.amber,
    this.adTextBgCorner = 2.0,
    this.baseColor,
    this.highlightColor,
    this.onBgColor = Colors.white,
  });

  // Default Factory for quick use
  factory NativeAdShimmerStyle.dark() => NativeAdShimmerStyle(
    bgColor: Colors.black,
    baseColor: Colors.grey[800],
    highlightColor: Colors.grey[600],
    onBgColor: Colors.grey[700],
  );
}
