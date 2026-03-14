import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/enums/native_type.dart';
import '../core/native_ad_style.dart';
import '../core/native_ad_shimmer_style.dart';

class NativeShimmer extends StatelessWidget {
  final NativeType type;
  final NativeAdStyle style;
  final NativeAdShimmerStyle shimmerStyle;
  final double height;

  const NativeShimmer({
    super.key,
    required this.type,
    required this.style,
    required this.shimmerStyle,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: shimmerStyle.bgColor ?? style.bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(shimmerStyle.bgCorner),
        border: Border.all(
          color:
              shimmerStyle.bgStrokeColor ??
              style.bgStrokeColor ??
              Colors.transparent,
          width: shimmerStyle.bgStrokeWidth,
        ),
      ),
      padding: type == NativeType.small3
          ? EdgeInsets.zero
          : const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        baseColor: shimmerStyle.baseColor ?? Colors.grey[300]!,
        highlightColor: shimmerStyle.highlightColor ?? Colors.grey[100]!,
        child: _buildShimmerForType(),
      ),
    );
  }

  Widget _buildShimmerForType() {
    switch (type) {
      case NativeType.small8:
        return _buildSmall8Shimmer();
      case NativeType.small7:
        return _buildSmall7Shimmer();
      case NativeType.small6:
        return _buildSmall6Shimmer();
      case NativeType.small5:
        return _buildSmall5Shimmer();
      case NativeType.small4:
        return _buildSmall4Shimmer();
      case NativeType.small3:
        return _buildSmall3Shimmer();
      case NativeType.small2:
        return _buildSmall2Shimmer();
      case NativeType.small1:
        return _buildSmall1Shimmer();
      case NativeType.medium6:
        return _buildMedium6Shimmer();
      case NativeType.medium5:
        return _buildMedium5Shimmer();
      case NativeType.medium4:
        return _buildMedium4Shimmer();
      case NativeType.medium3:
        return _buildMedium3Shimmer();
      case NativeType.medium2:
        return _buildMedium2Shimmer();
      case NativeType.large6:
        return _buildLarge6Shimmer();
      case NativeType.large5:
        return _buildLarge5Shimmer();
      case NativeType.large4:
        return _buildLarge4Shimmer();
      case NativeType.large3:
        return _buildLarge3Shimmer();
      case NativeType.large2:
        return _buildLarge2Shimmer();
      case NativeType.large1:
        return _buildLarge1Shimmer();
      case NativeType.medium1:
      default:
        return _buildMedium1Shimmer();
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
            color: shimmerStyle.onBgColor,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: shimmerStyle.adTextBgColor ?? Colors.amber,
                      borderRadius: BorderRadius.circular(
                        shimmerStyle.adTextBgCorner,
                      ),
                    ),
                    child: Text(
                      'AD',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: shimmerStyle.adTextColor ?? Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 120,
                    height: 14,
                    color: shimmerStyle.onBgColor,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Body Text Lines
              Container(
                width: double.infinity,
                height: 12,
                color: shimmerStyle.onBgColor,
              ),
              const SizedBox(height: 4),
              Container(width: 150, height: 12, color: shimmerStyle.onBgColor),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // CTA Button Placeholder
        Container(
          width: 80,
          height: 36,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: shimmerStyle.adTextBgColor ?? Colors.amber,
                      borderRadius: BorderRadius.circular(
                        shimmerStyle.adTextBgCorner,
                      ),
                    ),
                    child: Text(
                      'AD',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: shimmerStyle.adTextColor ?? Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(height: 14, color: shimmerStyle.onBgColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                height: 12,
                color: shimmerStyle.onBgColor,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 10,
                    color: shimmerStyle.onBgColor,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 80,
                    height: 10,
                    color: shimmerStyle.onBgColor,
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
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
      ],
    );
  }

  Widget _buildSmall3Shimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Placeholder
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: shimmerStyle.onBgColor,
                    borderRadius: BorderRadius.circular(
                      16.0,
                    ), // Rounded corners based on design
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: shimmerStyle.adTextBgColor ?? Colors.amber,
                              borderRadius: BorderRadius.circular(
                                shimmerStyle.adTextBgCorner,
                              ),
                            ),
                            child: Text(
                              'AD',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: shimmerStyle.adTextColor ?? Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 100,
                            height: 14,
                            color: shimmerStyle.onBgColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Body Text Lines
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: shimmerStyle.onBgColor,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 10,
                            color: shimmerStyle.onBgColor,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 80,
                            height: 10,
                            color: shimmerStyle.onBgColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // CTA Button Placeholder matches parent height
        Container(
          width: 100,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(shimmerStyle.bgCorner),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmall4Shimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ad Badge + Headline
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: shimmerStyle.adTextBgColor ?? Colors.amber,
                        borderRadius: BorderRadius.circular(
                          shimmerStyle.adTextBgCorner,
                        ),
                      ),
                      child: Text(
                        'AD',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: shimmerStyle.adTextColor ?? Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 100,
                      height: 14,
                      color: shimmerStyle.onBgColor,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Body Text Lines
                Container(
                  width: double.infinity,
                  height: 12,
                  color: shimmerStyle.onBgColor,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 10,
                          color: shimmerStyle.onBgColor,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 80,
                          height: 10,
                          color: shimmerStyle.onBgColor,
                        ),
                      ],
                    ),
                    // Price placeholder
                    Container(
                      width: 40,
                      height: 10,
                      color: shimmerStyle.onBgColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // CTA Button Placeholder matches parent height
        Container(
          width: 100,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(shimmerStyle.bgCorner),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmall5Shimmer() => _buildSmall1Shimmer();

  Widget _buildSmall6Shimmer() => _buildSmall3Shimmer();

  Widget _buildSmall8Shimmer() => _buildSmall2Shimmer();

  Widget _buildSmall7Shimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ad Badge + Headline
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: shimmerStyle.adTextBgColor ?? Colors.amber,
                        borderRadius: BorderRadius.circular(
                          shimmerStyle.adTextBgCorner,
                        ),
                      ),
                      child: Text(
                        'AD',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: shimmerStyle.adTextColor ?? Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 100,
                      height: 14,
                      color: shimmerStyle.onBgColor,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Body Text Lines
                Container(
                  width: double.infinity,
                  height: 12,
                  color: shimmerStyle.onBgColor,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 10,
                      color: shimmerStyle.onBgColor,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 80,
                      height: 10,
                      color: shimmerStyle.onBgColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // CTA Button Placeholder matches parent height
        Container(
          width: 100,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(shimmerStyle.bgCorner),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedium1Shimmer() {
    return Row(
      children: [
        // Media (Left)
        Expanded(flex: 45, child: Container(color: shimmerStyle.onBgColor)),
        const SizedBox(width: 8),
        // Details (Right)
        Expanded(
          flex: 55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    color: shimmerStyle.onBgColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 16,
                              color: shimmerStyle.adTextBgColor ?? Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                height: 14,
                                color: shimmerStyle.onBgColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(height: 12, color: shimmerStyle.onBgColor),
              const SizedBox(height: 4),
              Container(height: 12, color: shimmerStyle.onBgColor),
              const Spacer(),
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: shimmerStyle.onBgColor,
                  borderRadius: BorderRadius.circular(style.buttonCornerRadius),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedium2Shimmer() {
    return Row(
      children: [
        // Details (Left)
        Expanded(
          flex: 55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    color: shimmerStyle.onBgColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 16,
                              color: shimmerStyle.adTextBgColor ?? Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                height: 14,
                                color: shimmerStyle.onBgColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(height: 12, color: shimmerStyle.onBgColor),
              const SizedBox(height: 4),
              Container(height: 12, color: shimmerStyle.onBgColor),
              const Spacer(),
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: shimmerStyle.onBgColor,
                  borderRadius: BorderRadius.circular(style.buttonCornerRadius),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Media (Right)
        Expanded(flex: 45, child: Container(color: shimmerStyle.onBgColor)),
      ],
    );
  }

  Widget _buildMedium3Shimmer() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(width: 80, height: 80, color: shimmerStyle.onBgColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 16,
                          color: shimmerStyle.adTextBgColor ?? Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            height: 16,
                            color: shimmerStyle.onBgColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(height: 12, color: shimmerStyle.onBgColor),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: 100,
                      color: shimmerStyle.onBgColor,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 10,
                          color: shimmerStyle.onBgColor,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 80,
                          height: 10,
                          color: shimmerStyle.onBgColor,
                        ),
                        const Spacer(),
                        Container(
                          width: 40,
                          height: 14,
                          color: shimmerStyle.onBgColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
      ],
    );
  }

  Widget _buildMedium4Shimmer() {
    return Column(
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            children: [
              Container(width: 80, height: 80, color: shimmerStyle.onBgColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 16,
                          color: shimmerStyle.adTextBgColor ?? Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            height: 16,
                            color: shimmerStyle.onBgColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(height: 12, color: shimmerStyle.onBgColor),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: 100,
                      color: shimmerStyle.onBgColor,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 10,
                          color: shimmerStyle.onBgColor,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 80,
                          height: 10,
                          color: shimmerStyle.onBgColor,
                        ),
                        const Spacer(),
                        Container(
                          width: 40,
                          height: 14,
                          color: shimmerStyle.onBgColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedium5Shimmer() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(width: 80, height: 80, color: shimmerStyle.onBgColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 16,
                          color: shimmerStyle.adTextBgColor ?? Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            height: 16,
                            color: shimmerStyle.onBgColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(height: 12, color: shimmerStyle.onBgColor),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: 100,
                      color: shimmerStyle.onBgColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
      ],
    );
  }

  Widget _buildMedium6Shimmer() {
    return Column(
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            children: [
              Container(width: 80, height: 80, color: shimmerStyle.onBgColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 16,
                          color: shimmerStyle.adTextBgColor ?? Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            height: 16,
                            color: shimmerStyle.onBgColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(height: 12, color: shimmerStyle.onBgColor),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: 100,
                      color: shimmerStyle.onBgColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLarge1Shimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(width: 64, height: 64, color: shimmerStyle.onBgColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 16,
                        color: shimmerStyle.adTextBgColor ?? Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 18,
                          color: shimmerStyle.onBgColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(height: 12, color: shimmerStyle.onBgColor),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 100,
                    color: shimmerStyle.onBgColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: Container(color: shimmerStyle.onBgColor)),
      ],
    );
  }

  Widget _buildLarge2Shimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(width: 64, height: 64, color: shimmerStyle.onBgColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 16,
                        color: shimmerStyle.adTextBgColor ?? Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 18,
                          color: shimmerStyle.onBgColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(height: 12, color: shimmerStyle.onBgColor),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 100,
                    color: shimmerStyle.onBgColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(child: Container(color: shimmerStyle.onBgColor)),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
      ],
    );
  }

  Widget _buildLarge3Shimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: Container(color: shimmerStyle.onBgColor)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(width: 56, height: 56, color: shimmerStyle.onBgColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 16,
                        color: shimmerStyle.adTextBgColor ?? Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 16,
                          color: shimmerStyle.onBgColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(height: 12, color: shimmerStyle.onBgColor),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 80,
                        height: 10,
                        color: shimmerStyle.onBgColor,
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
                color: shimmerStyle.onBgColor,
                borderRadius: BorderRadius.circular(style.buttonCornerRadius),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLarge4Shimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(width: 64, height: 64, color: shimmerStyle.onBgColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 16,
                        color: shimmerStyle.adTextBgColor ?? Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 18,
                          color: shimmerStyle.onBgColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(height: 12, color: shimmerStyle.onBgColor),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 100,
                    color: shimmerStyle.onBgColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(child: Container(color: shimmerStyle.onBgColor)),
      ],
    );
  }

  Widget _buildLarge5Shimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 16,
                        color: shimmerStyle.adTextBgColor ?? Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 18,
                          color: shimmerStyle.onBgColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(height: 12, color: shimmerStyle.onBgColor),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 100,
                    color: shimmerStyle.onBgColor,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 64, height: 64, color: shimmerStyle.onBgColor),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(child: Container(color: shimmerStyle.onBgColor)),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
      ],
    );
  }

  Widget _buildLarge6Shimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(width: 56, height: 56, color: shimmerStyle.onBgColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 16,
                        color: shimmerStyle.adTextBgColor ?? Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 16,
                          color: shimmerStyle.onBgColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(height: 12, color: shimmerStyle.onBgColor),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 80,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: shimmerStyle.onBgColor,
                borderRadius: BorderRadius.circular(style.buttonCornerRadius),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(child: Container(color: shimmerStyle.onBgColor)),
      ],
    );
  }
}
