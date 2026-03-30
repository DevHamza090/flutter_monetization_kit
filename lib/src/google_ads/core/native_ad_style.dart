import 'package:flutter/material.dart';

class NativeAdStyle {
  // Container Style
  final Color? bgColor;
  final Color? bgStrokeColor;
  final double bgStrokeWidth;
  final double bgCorner;

  // "Ad" Badge Style
  final Color? adTextColor;
  final Color? adTextBgColor;
  final double adTextBgCorner;
  final Color? adStrokeColor;
  final double adStrokeWidth;

  // Content Text Style
  final Color? headingColor;
  final Color? bodyColor;
  final Color? advertiserColor;

  // Ratings Style
  final Color? ratingColor;
  final Color? ratingBgColor;
  final Color? priceColor;

  // Button (CTA) Style
  final Color? buttonBgColor;
  final Color? buttonTextColor;
  final double buttonCornerRadius;

  // Typography
  final String? fontFamily;

  const NativeAdStyle({
    this.bgColor,
    this.bgStrokeColor,
    this.bgStrokeWidth = 0.0,
    this.bgCorner = 8.0,
    this.adTextColor = Colors.white,
    this.adTextBgColor = Colors.amber,
    this.adTextBgCorner = 2.0,
    this.adStrokeColor,
    this.adStrokeWidth = 0.0,
    this.headingColor = Colors.black,
    this.bodyColor = Colors.grey,
    this.advertiserColor = Colors.grey,
    this.ratingColor = Colors.amber,
    this.ratingBgColor = Colors.black12,
    this.priceColor = Colors.grey,
    this.buttonBgColor = Colors.blue,
    this.buttonTextColor = Colors.white,
    this.buttonCornerRadius = 4.0,
    this.fontFamily = 'Poppins',
  });

  // Default Factory for quick use
  factory NativeAdStyle.dark() => const NativeAdStyle(
    bgColor: Colors.black,
    headingColor: Colors.white,
    bodyColor: Colors.white70,
  );
}
